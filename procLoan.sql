
----------- get current loans from Avanade. Hua 20151125: drop calculations
----------- Hua 20151207 dropped ScheduleCode
-- CREATE PROCEDURE dbo.usp_getLoans AS
-- BEGIN
-- 	TRUNCATE TABLE dbo.currentLoan
-- 	
-- 	INSERT INTO dbo.currentLoan
-- 	SELECT  mpf.PFINumber, mpf.MANumber, DeliveryCommitmentNumber, mpf.LoanNumber, LoanRecordCreationDate, LastFundingEntryDate, 
-- 		ClosingDate, ISNULL(m.ScheduleEndPrincipalBal, mpf.[MPFBalance]) AS MPFBalance, LoanAmount, TransactionCode, InterestRate, ProductCode, NumberOfMonths, 
-- 		FirstPaymentDate, MaturityDate, PIAmount, NonBusDayTrnEffDate, 
-- 		RemittanceTypeID, ExcessServicingFee, ServicingFee, BatchID, ParticipationPercent AS ChicagoParticipation, OrigLTV, LOANLoanInvestmentStatus
-- 	FROM LSMPFFIVES.MPFFHLBDW.DBO.UV_AllMPFLoans_NOSHFD AS mpf LEFT JOIN LSMPFFIVES.MPFFHLBDW.DBO.uv_maxPayDate as m ON mpf.LoanNumber = m.LoanNumber
-- 	WHERE (m.loanNumber is null or m.ScheduleEndPrincipalBal>0)
-- 	and   mpf.ParticipationOrgKey = 3
-- 	and   mpf.MPFBalance>0
-- 	and   mpf.LOANLoanInvestmentStatus <> '09'
-- 	
-- 	DELETE  c
-- 	FROM dbo.currentLoan c inner join LSMPFREPOS.MPFREPOS.dbo.uv_dm_mpf_daily_loan l on c.loanNumber=l.loanNumber
-- 	WHERE (c.LOANLoanInvestmentStatus='08') AND l.Action_Code In ('60','65','70','71','72')
-- 
-- END

--- get current loans from Avanade. Hua 20151125: drop calculations
--- Hua 20151207 dropped ScheduleCode
--- Hua 20151223 use UV_FairValueOptionLoans_NOSHFD to filter sold GNMBS loans
--- Hua 20160225 changed productCode to handle the GNMBS jumbo loans ======= need manually update the commitmentNumber until the productCode GL43/5 in
CREATE PROCEDURE dbo.usp_getLoans AS
BEGIN
	TRUNCATE TABLE dbo.currentLoan
	
	INSERT INTO dbo.currentLoan
	SELECT  mpf.PFINumber, mpf.MANumber, DeliveryCommitmentNumber, mpf.LoanNumber, LoanRecordCreationDate, LastFundingEntryDate, 
		ClosingDate, ISNULL(m.ScheduleEndPrincipalBal, mpf.[MPFBalance]) AS MPFBalance, LoanAmount, TransactionCode, mpf.InterestRate, 
		CASE WHEN DeliveryCommitmentNumber IN (587414) THEN 'GL4'+RIGHT(mpf.ProductCode,1) ELSE mpf.ProductCode END AS ProductCode, 
		NumberOfMonths, FirstPaymentDate, MaturityDate, PIAmount, NonBusDayTrnEffDate, 
		mpf.RemittanceTypeID, ExcessServicingFee, ServicingFee, BatchID, ParticipationPercent AS ChicagoParticipation, OrigLTV, LOANLoanInvestmentStatus
	FROM (LSMPFFIVES.MPFFHLBDW.DBO.UV_AllMPFLoans_NOSHFD AS mpf LEFT JOIN LSMPFFIVES.MPFFHLBDW.DBO.uv_maxPayDate as m ON mpf.LoanNumber = m.LoanNumber)
	LEFT JOIN LSMPFFIVES.MPFFHLBDW.dbo.UV_FairValueOptionLoans_NOSHFD AS f ON mpf.loanNumber=f.loanNumber
	WHERE (m.loanNumber is null or m.ScheduleEndPrincipalBal>0)
	and   mpf.ParticipationOrgKey = 3
	and   mpf.MPFBalance>0
	and   mpf.LOANLoanInvestmentStatus <> '09'
	and   (mpf.LOANLoanInvestmentStatus <> '06' OR f.loanNumber IS NOT NULL)
	
	DELETE  c
	FROM dbo.currentLoan c inner join LSMPFREPOS.MPFREPOS.dbo.uv_dm_mpf_daily_loan l on c.loanNumber=l.loanNumber
	WHERE (c.LOANLoanInvestmentStatus='08') AND l.Action_Code In ('60','65','70','71','72')

END



----------- calculate the needed fields of current loans and insert them into preAggregate. 
-- Hua 20151125 Replace asOfDate for monthenddate
------- productcode: change productcode to FX20 from FX30 if NumberOfMonths between 239 and 241
------- closingdate: change to LastFundingEntryDate if '1900-01-01' or NULL
------- RemittanceTypeID: change remittance type for nine seasoned loans from AA to SS
-- Hua 20151207 dropped ScheduleCode
-- Hua 20160122 added LoanInvestmentStatus<>'06'
-- Hua 20160225 Changed fields related to productCode for GNMBS jumbo loans: coupon and couponOld, Swam, oTerm, Agency
CREATE PROCEDURE dbo.usp_setMPFCohorts AS
BEGIN
	truncate table dbo.preAggregate
	
	INSERT INTO dbo.preAggregate ( loanNumber, deliveryCommitmentNumber, maNumber, pfiNumber, loanRecordCreationDate, lastFundingEntryDate, 
		closingDate, mpfBalance, originalAmount, transactionCode, interestRate, coupon, couponOld, prepaymentInterestRate, 
		firstPaymentDate, maturityDate, piAmount, numberOfMonths, productCode, portfolioIndicator, remittanceTypeid, age, 
		chicagoParticipation, currentLoanBalance, entryDate, excessServicingFee, servicingFee, ceFee, cePerformanceFee, OrigLTV, LoanInvestmentStatus )
	SELECT m.loannumber, m.deliverycommitmentnumber, m.manumber, m.pfinumber, m.loanrecordcreationdate, m.lastFundingEntryDate, 
		CASE WHEN m.closingdate='1900-01-01' OR m.closingdate IS NULL THEN m.LastFundingEntryDate ELSE m.closingdate END AS closingdate, 
		m.mpfbalance, m.loanamount as originalAmount, m.transactioncode, m.interestrate, 	
		CASE 
		WHEN Left(m.ProductCode,2) = 'GL' THEN 
			CASE WHEN substring(m.ProductCode,3,1) IN ('0','4') THEN ROUND(InterestRate*200,0)/200-.005 
			WHEN ma.entryDate>='2007-02-01' THEN m.InterestRate - 0.0044
			ELSE m.InterestRate - 0.0046 END
		WHEN m.ProductCode = 'FX15' THEN m.InterestRate - 0.0038
		ELSE m.InterestRate - 0.0039 END AS coupon, 
		CASE 
		WHEN Left(m.ProductCode,2) = 'GL' THEN 
			CASE WHEN substring(m.ProductCode,3,1) IN ('0','4') THEN ROUND(m.InterestRate*200,0)/200-.005 ELSE m.InterestRate - (m.ServicingFee + m.ExcessServicingFee) END
		ELSE m.InterestRate - 0.0039 END AS CouponOld, 
		m.InterestRate as prepaymentinterestrate, m.firstpaymentdate, m.maturitydate, m.piamount, m.numberofmonths,  
		CASE WHEN m.productcode='FX30' AND m.NumberOfMonths between 239 and 241 THEN 'FX20' ELSE m.ProductCode END AS ProductCode, 
		CASE WHEN m.batchid IS NOT NULL THEN 'BATCH' ELSE 'FLOW' END AS portfolioindicator, 
		CASE WHEN (m.LoanNumber BETWEEN 134590 AND 134597) OR m.LoanNumber=121576 THEN 1 ELSE m.RemittanceTypeID END AS RemittanceTypeID,
		CASE WHEN Datediff(m,asOfDate,maturitydate)>numberofmonths THEN 0 ELSE numberofmonths-Datediff(m,asOfDate,maturitydate) END AS age, 
		m.chicagoparticipation, m.mpfbalance as currentloanbalance, asOfDate as entryDate, m.excessservicingfee, m.servicingfee, 
		ma.cefee + ma.CEPerformanceFee AS cefee, ma.ceperformancefee, m.OrigLTV, LOANLoanInvestmentStatus as LoanInvestmentStatus
	FROM  dbo.currentLoan as m CROSS APPLY (SELECT getdate() as asOfDate) as a
	INNER JOIN LSMPFREPOS.MPFREPOS.dbo.uv_dm_mpf_daily_masterCommitments as ma ON (m.manumber = ma.manumber) AND (m.pfinumber = ma.pfinumber)
	WHERE asOfDate >= m.nonbusdaytrneffdate 
	AND   LOANLoanInvestmentStatus<>'06'

	TRUNCATE TABLE dbo.aggMPF
	-- Hua 20151202 replace ScheduleType with RemittanceType, P/O with PO, Lag with aggLag, Lock with aggLock, Floor with aggFloor, IF with aggIF, True with 1 for [Active?], added OrigLTV, origLS 
	INSERT INTO dbo.aggMPF	
	SELECT 	OriginationYear AS accountClass, AccountType, RemittanceType, PassThruRate, 
		CASE LoanInvestmentStatus WHEN '11' THEN 'C' WHEN '12' THEN 'F' ELSE '' END + RemittanceType + CAST(OriginationYear AS varchar(4)) + AccountType + CAST(Floor(PassThruRate*100) AS varchar(3)) AS CUSIP,
		Count(LoanNumber) AS H2, Sum(chBal) AS AggNotional, Sum(CurrentLoanBalance)/Sum(OriginalAmount) AS AggFactor, 
		Sum(100*interestRate*chBal)/Sum(chBal) AS AggWac, Sum(100*Coupon*chBal)/Sum(chBal) AS AggCoup, 
		round(Sum(-log(1- MPFBalance*(InterestRate/12)*(1/PIAmount))/ log (1+ InterestRate/12)*chBal)/Sum(chBal),0) AS AggWam, 
		round((Sum(Age*chBal)/Sum(chBal)),0) AS AggAge, NULL as H1, Swam, oTerm AS AggOWAM, 0 AS AggPrice, Max(EntryDate) AS Settle, max(nextPD) as NxtPmt,
		max(nextPD) AS NxtPP, max(nextPD) AS NxtRst1, 
		Sum(100*interestRate*chBal)/Sum(chBal) AS AggPrepWac, Sum(100*Coupon*chBal)/Sum(chBal) AS AggPrepCoup, 
		max(nextPD) AS NxtRst2, Max(EntryDate) AS WamDate, Sum(chBal) AS AggBookPrice, 
		CASE WHEN AccountType IN ('03','05','43','45') THEN 'GNMA2' WHEN RemittanceType='GL' THEN 'GNMA' ELSE 'FNMA' END AS Agency,
		CASE  RemittanceType WHEN 'MA' THEN 2 WHEN 'AA' THEN 48 ELSE 18 END AS Delay, 
		Sum(interestRate*chBal)/Sum(chBal) AS PrepaymentInterestRate,
		Sum(OrigLTV*chBal)/Sum(chBal)*100 AS OrigLTV,
		Sum(originalAmount*chBal)/Sum(chBal)/1000 AS OrigLoanSize, productCode		
	FROM  dbo.preAggregate
		CROSS APPLY (SELECT CASE WHEN PortfolioIndicator='BATCH' THEN Year(ClosingDate) ELSE Year(LoanRecordCreationDate) END AS OriginationYear,
			CASE WHEN Left([ProductCode],2)='GL' THEN 'GL' 
			WHEN RemittanceTypeID=1 THEN 'SS' WHEN RemittanceTypeID=2 THEN 'AA' 
			ELSE 'MA' END AS RemittanceType,
			ROUND(interestRate*200,0)/2 AS PassThruRate, Right(ProductCode,2) AS AccountType, MPFBalance*ChicagoParticipation AS chBal,
			CASE WHEN Right(ProductCode,1) = '5' THEN 160 WHEN Right(ProductCode,2)='20' THEN 220 ELSE 335 END AS Swam, 
			CASE Right(ProductCode,1) WHEN '5' THEN 15 WHEN '3' THEN 30 ELSE Right(ProductCode,2) END *12 AS oTerm,
			dbo.NextPmtDate(Year(EntryDate),month(EntryDate),remittanceTypeId) AS nextPD
			) AS A
	GROUP BY OriginationYear, AccountType, RemittanceType, PassThruRate, Swam, oTerm, productCode, 
		CASE LoanInvestmentStatus WHEN '11' THEN 'C' WHEN '12' THEN 'F' ELSE '' END + RemittanceType + CAST(OriginationYear AS varchar(4)) + AccountType + CAST(Floor(PassThruRate*100) AS varchar(3))	
		
	UPDATE dbo.aggMPF
	SET    H1= CASE WHEN AggAge>20 THEN 'Seasoned' ELSE 'MPF' END

END
	


---- 	round(-log(1- MPFBalance*(InterestRate/12)*(1/PIAmount))/ log (1+ InterestRate/12),0) as WAM

-------- Hua 20151202 ------ create the cohorts for pricing and output
------------- aggMPF 
---====== Hua 20151207 skip all the constant fields: 'MPF' AS Portfolio, 1 as Mult, '1' AS AddAccrued, 'Mid' AS PV, 'Mid' AS Swap, 'OAS' AS PO, 0 AS OAS, 1.00 AS Repo, 
--- 'AFT' AS PP, 0 AS PPConst, 1 AS PPMult, 1 AS PPSense, 0 AS aggLag, 0 AS aggLock, 12 AS PPFq, 
--	'Fixed' AS FA, 0 AS Const1, 0 AS Const2, '3L' AS Rate, '12' AS RF, -1000000000 AS aggFloor, 1000000000 AS Cap, 1 AS PF, 1000000000 AS PF1, 1000000000 AS PF2, 
-- 1000000000 AS PC, 'Bond' AS AB, 0 AS LookBackRate, 0 AS LookBack, 'CPR' AS PPUnits, 0 AS PPCRShift, 0 AS RcvCurrEscr, 0 AS PayCurrEscr, 
-- 'StraightLine' AS AmortMethod, 'MPFProgram' AS ClientName, 1 AS Active, 
---	0 AS IntCoupMult, 1 AS PPCoupMult, -10000000000 AS SumFloor, 10000000000 AS SumCap, 'None' AS ServicingModel, 'None' AS LossModel, 0 AS SchedCap, 
--  0 AS Ballon, 1 AS aggIF, 1 AS Mult1, 0 AS Mult2, 

-- Hua 20151202 replace ScheduleType with RemittanceType, P/O with PO, Lag with aggLag, Lock with aggLock, Floor with aggFloor, IF with aggIF, True with 1 for [Active?] 

	
-- qrySetMPFPx -------- Hua 20151207
UPDATE dbo_aggMPF as a INNER JOIN MPFPrice as p ON a.CUSIP = p.CUSIP 
SET a.AggPrice = p.Price;

		Sum(OrigLTV*chBal)/Sum(chBal) AS [Orig LTV],
		Sum(originalAmount*chBal)/Sum(chBal) AS [Orig Avg Loan Size],		

-- qrySumLoan -------- get curent Chicago loans summary
-- Hua 20160307
SELECT Count(dbo_preAggregate.loanNumber) AS [#Loans], Sum([chicagoParticipation]*[originalAmount]) AS origAmount, Sum([chicagoParticipation]*[mpfBalance]) AS curBal
FROM dbo_preAggregate;


-- polypaths Input ======= create the pf file by priceBatch
-- Hua 20151209 dropped qryWALoanSize_MPF
-- Hua 20160225 Changed productCode related fields for GNMBS jumbo loans: SubActII, Orig Avg Loan Size, 
SELECT "MBS" AS [Sec Type], "Asset" AS BSAccount, "MPF" AS SubActI, a.CUSIP, "" as [OCUSIP],
	IIf(Left([CUSIP],1) IN ("C", "F"), Left(ProductCode,2) & "2" & right(ProductCode,2), 
		IIf(ProductCode in ("GL03","GL43"),"GN30", IIf(ProductCode in ("GL05","GL45"),"GN15", ProductCode)) AS SubActII, 
	"" as [Dated Date], "" as [Maturity], aggCoup AS Coupon, [AggBookPrice]-IIf(m.[month 1] Is Null,0,m.[Month 1]) AS Holding,
	"30/360" AS [DayCount], "" as [Cpn~ Freq~], "" as [SwapCusip],
	"" as [Hedged],"" as [OAS],"" as [Call Date],"" as [Call Price],"" as [Put Date],"" as [Put Price],	"T+0" AS [Settlement Type], "USER" AS [Source], 
	AggOWAM AS [Orig Term], AggWac AS [WAC(coll)], [AggWam]-IIf(M.[WAM_adj] Is Null,0,M.[WAM_Adj]) AS [WAM(coll)], AggAge AS [WALA(coll)], [Delay], 1 AS [Factor], [Agency], 
	"N" AS [Use Static Model], AggPrice AS [Price], "" as [Index], "" as [R Mult], "" as [Margin], "" as [First Coupon Date], "" as [Reset Freq~], "" as [DayCount (Pay)], 
	"" as [Index(Pay)], "" as [P Mult], "" as [Coupon (Pay)], "" as [First Coupon Date (Pay)], "" as [Cpn~ Freq~ (Pay)], "" as [margin (Pay)], "" as [Reset Freq~ (Pay)],
	"" as [Settle Date], "" as [Strike], "" as [Swaption Swap Effective Date], "" as [Swaption Swap First Pay Date], "" as [Swaption Swap Termination Date], "" as [1st Exer~],
	"" as [Option Type], "" as [Option Exercise Type], "" as [Swaption Strike Rate], "" as [Option Exercise Notice], "" as [jrnlcode], "" as [Opening Market Value], 
	A.CUSIP AS [Cust ID], "" as [Sub Type], "" as [DTM], "Asset MPF " & SubActII AS [Account], "" as [Cap], "" as [Floor], "Price" AS [PriceAnchor], 
	"dbo_aggMPF in N:\Palms\BankDB\MPF5.accdb" AS [PriceSource], origLoanSize as [Orig Avg Loan Size], origLTV AS [Orig LTV],  "" as [Factor Date]
FROM dbo_aggMPF AS A LEFT JOIN MRA_MPFPayDown AS M ON A.CUSIP=M.CUSTOM2
UNION 
SELECT "MBS" AS [Sec Type], "Asset" AS BSAccount, "MPFDC" AS SubActI, [CUSIP], "" as [OCUSIP], 
	iif(right(ProductCode,2) IN ("03","05","43","45"),"GN",Left(ProductCode,2)) AS [SubActII], "" as [Dated Date], "" as [Maturity],
	Coup AS [Coupon], Notional AS [Holding], "30/360" AS [DayCount], "" as [Cpn~ Freq~], "" as [SwapCusip],
	"" as [Hedged], "" as [OAS], "" as [Call Date], "" as [Call Price], "" as [Put Date], "" as [Put Price], "USER" AS [Settlement Type], "USER" AS [Source],
	Owam AS [Orig Term], Wac AS [WAC(coll)], Wam AS [WAM(coll)], Age AS [WALA(coll)],
	[Delay], 1 AS [Factor], [Agency], "N" AS [Use Static Model], [Price], "" as [Index], "" as [R Mult], "" as [Margin], "" as [First Coupon Date], "" as [Reset Freq~], "" as [DayCount (Pay)],
	"" as [Index(Pay)], "" as [P Mult], "" as [Coupon (Pay)], "" as [First Coupon Date (Pay)], "" as [Cpn~ Freq~ (Pay)], "" as [margin (Pay)], "" as [Reset Freq~ (Pay)],
	Settle AS [Settle Date], "" as [Strike], "" as [Swaption Swap Effective Date], "" as [Swaption Swap First Pay Date], "" as [Swaption Swap Termination Date], "" as [1st Exer~],
	"" as [Option Type], "" as [Option Exercise Type], "" as [Swaption Strike Rate], "" as [Option Exercise Notice], "" as [jrnlcode], "" as [Opening Market Value], Cusip AS [Cust ID],
	"" as [Sub Type], "" as [DTM], "Asset MPFDC " & SubActII & IIf(left(CUSIP,1)="C","2","") AS [Account], "" as [Cap], "" as [Floor], "Price" AS PriceAnchor, 
	"dbo_aggDCs in N:\Palms\BankDB\MPF5.accdb" AS [PriceSource], 
	IIf(productCode like "GL4?",465,IIf(ProductCode="FX30",179,IIf(productCode="FX15",132,IIf(productCode="FX20",143,IIf(productCode="GL30",144,130))))) AS [Orig Avg Loan Size], 
	"" as [Orig LTV], DateSerial(Year(Date()), Month(Date()), 1) as [Factor Date]
FROM dbo_aggDCs;


---======================================= output to MiddleWare begin
-------- qryAppSeasonedToIMM
-- Hua 20160104
-- INSERT INTO dbo_Instrument_MBS_MPF ( 
-- 	CUSIP, Active_q, Agency, Delay, Wac, Coup, Balloon, Owam, IF, PF, FA1, Const1, Mult1, Rate1, RF1, Floor1, Cap1, PF1, PC1, AB1, LookBack1, 
-- 	Int_Coup_Mult, PP_Coup_Mult, Sum_Floor, Sum_Cap, Servicing_Model, Loss_Model, Sched_Cap_q, BondCUSIP )
-- SELECT CUSIP, True AS Active_q, Agency, Delay, AggWac, AggCoup, 0 as Ballon, AggOWAM, 1 AS aggIF, 1 AS PF, 'Fixed' AS FA1, 0 AS Const1, 1 AS Mult1, 
-- 	'3L' AS Rate, '12' AS RF, -1000000000 AS Floor1, 1000000000 AS Cap, 1000000000 AS PF1, 1000000000 AS PC, 'Bond' AS AB, 0 AS LookBack, 0 AS IntCoupMult, 
-- 	IIf(AccountType IN ("15", "20") and aggWAC>=6.02, 1.3, IIf(AccountType="30" AND aggWAC>=7.04,1.2,1)) AS PPCoupMult, 
-- 	-10000000000 AS SumFloor, 10000000000 AS SumCap, 'None' AS ServicingModel, 'None' AS LossModel, 0 AS SchedCap, 
-- 	"MPF" AS BondCUSIP
-- FROM dbo_aggMPF;

-------- qryAppSeasonedToIMM
-- Hua 20160124: query from qryMPFOutput
INSERT INTO dbo_Instrument_MBS_MPF ( 
	CUSIP, Active_q, Agency, Delay, Wac, Coup, Balloon, Owam, IF, PF, FA1, Const1, Mult1, Rate1, RF1, Floor1, Cap1, PF1, PC1, AB1, LookBack1, 
	Int_Coup_Mult, PP_Coup_Mult, Sum_Floor, Sum_Cap, Servicing_Model, Loss_Model, Sched_Cap_q, BondCUSIP )
SELECT CUSIP, [Add Accrued?], Agency, Delay, AggWac, AggCoup, Ballon, AggOWAM, [IF], PF, FA, Const1, Mult1, Rate, RF, [Floor], Cap, PF1, PC, AB, 
	LookBack, [Int Coup Mult], [PP Coup Mult], [Sum Floor], [Sum Cap], [Servicing Model], [Loss Model], [Sched Cap?], "MPF" AS BondCUSIP
FROM qryMPFOutput;


-------- qryAppSeasonedToPCMM 
-- Hua 20160104
-- INSERT INTO dbo_Portfolio_Contents_MBS_MPF ( Portfolio, IntexID, CUSIP, Account_Class, Account_Type, Sub_Account_Type, H1, H2, Notional, Mult, Factor, Add_Accrued_q, 
-- 	PV, Swap, Wac, Coup, Wam, Age, Swam, P_O, P, OAS, Settle, Repo, NxtPmt, PP, PPConst, PPMult, PPSens, Lag, Lock, PPFq, NxtPP, NxtRst1, PrepWac, PrepCoup, 
-- 	FA2, Const2, Mult2, Rate2, RF2, Floor2, Cap2, PF2, PC2, AB2, NxtRst2, LookBack2, LookBackRate1, LookBackRate2, WamDate, PPUnits, PPCRShift, 
-- 	PayCurrEscr, RcvCurrEscr, BookPrice, AmortMethod, ClientName, BurnStrength )
-- SELECT "MPF" AS Portfolio, PassThruRate, CUSIP, AccountClass, AccountType, RemittanceType as Sub_Account_Type, 
-- 	H1, H2, AggNotional, 1 AS Mult, aggFactor, 1 AS Add_Accrued_q, "Mid" AS PV, "Mid" as Swap, aggWac, aggCoup, aggWam, aggAge, Swam, 
-- 	"OAS" AS P_O, aggPrice as P, 0 AS OAS, Settle, 1 AS Repo, NxtPmt, "AFT" AS PP, 0 AS PPConst, 
-- 	IIf(AccountType IN ("15", "20") and aggWAC>=6.02, 1.3, IIf(AccountType="30" AND aggWAC>=7.04,1.2,1)) AS PPMult, 
-- 	1 AS PPSens, 0 AS Lag, 0 AS Lock, 12 AS PPFq, NxtPmt AS NxtPP, NxtPmt AS NxtRst1, aggWAC AS PrepWac, 
-- 	aggCoup AS PrepCoup, "Fixed" AS FA2, 0 AS Const2, 0 AS Mult2, "3L" AS Rate2, 12 AS RF2, -1000000000 AS Floor2, 1000000000 AS Cap2, 
-- 	1000000000 AS PF2, 1000000000 AS PC2, "Bond" AS AB2, NxtPmt as NxtRst2, 0 AS LookBack2, 0 AS LookBackRate1, 0 AS LookBackRate2, 
-- 	Settle AS WAMDate, "CPR" AS PPUnits, 0 AS PPCRShift, 0 AS PayCurrEscr, 0 AS RcvCurrEscr, aggBookPrice AS BookPrice, 
-- 	"StraightLine" AS AmortMethod, "MPFProgram" AS ClientName, 1 AS BurnStrength
-- FROM dbo_aggMPF;

-------- qryAppSeasonedToPCMM 
-- Hua 20160124 --- query from qryMPFOutput
INSERT INTO dbo_Portfolio_Contents_MBS_MPF ( Portfolio, IntexID, CUSIP, Account_Class, Account_Type, Sub_Account_Type, H1, H2, Notional, Mult, Factor, Add_Accrued_q, 
	PV, Swap, Wac, Coup, Wam, Age, Swam, P_O, P, OAS, Settle, Repo, NxtPmt, PP, PPConst, PPMult, PPSens, Lag, Lock, PPFq, NxtPP, NxtRst1, PrepWac, PrepCoup, 
	FA2, Const2, Mult2, Rate2, RF2, Floor2, Cap2, PF2, PC2, AB2, NxtRst2, LookBack2, LookBackRate1, LookBackRate2, WamDate, PPUnits, PPCRShift, 
	PayCurrEscr, RcvCurrEscr, BookPrice, AmortMethod, ClientName, BurnStrength )
SELECT Portfolio, PassThruRate, CUSIP, AccountClass, AccountType, ScheduleType as Sub_Account_Type, H1, H2, AggNotional, Mult, aggFactor, [Add Accrued?], 
	PV, Swap, aggWac, aggCoup, aggWam, aggAge, Swam, [P/O], aggPrice, OAS, Settle, Repo, NxtPmt, PP, PPConst, PPMult, PPSense, [Lag], [Lock], PPFq, NxtPP, NxtRst1, aggWAC, aggCoup, 
	FA, Const2, Mult2, Rate, RF, [Floor], Cap, PF2, PC, AB, NxtRst2, LookBack, LookBackRate, LookBackRate, WAMDate, PPUnits, PPCRShift, 
	PayCurrEscr, RcvCurrEscr, aggBookPrice, AmortMethod, ClientName, 1 AS BurnStrength
FROM qryMPFOutput;

--------------- for testing
-- qryBackupIMM
SELECT * INTO bkIMM
FROM dbo_instrument_MBS_MPF;

-- qryBackupPCMM
SELECT * INTO bkPCMM
FROM dbo_portfolio_contents_MBS_MPF;

-- qryRestoreIMM
insert into dbo_instrument_MBS_MPF
select * from bkIMM

-- qryRestorePCMM
insert into dbo_portfolio_contents_MBS_MPF
select * from bkPCMM

-- qryDeleteIMM
DELETE *
FROM dbo_Instrument_MBS_MPF
WHERE BondCUSIP in ("MPF" , "MPFForward");

-- qryDeletePCMM
DELETE *
FROM dbo_portfolio_contents_mbs_mpf
WHERE portfolio in ("MPF" , "MPFForward");
---======================================= output to MiddleWare END


-- usp_getFVloan -------- Hua 20160107
-- Hua 20160229 updated ProductCode, AccountType, CUSIP to handle the GNMBS jumbo loans
CREATE PROCEDURE dbo.usp_getFVloan AS
BEGIN
	TRUNCATE TABLE dbo.fairValueLoan
	
	INSERT INTO dbo.fairValueLoan
	SELECT 	f.LoanNumber,
		f.LoanInvestmentStatus,
		f.ChicagoParticipation,
		f.InterestRate,
		f.FundingDate,
		a.ProductCode,
		f.Action_Code,
		a.RemittanceType, 
		a.PassThruRate,
		Right(a.ProductCode,2) AS AccountType,
		a.OriginationYear,
		CASE WHEN LoanInvestmentStatus='12' THEN 'F' ELSE '' END +
			(RemittanceType+CAST(OriginationYear AS varchar(4))+Right(a.ProductCode,2)+CAST(Floor(PassThruRate*100) AS varchar(3))) AS CUSIP,
		0 AS Price		
	FROM LSMPFFIVES.MPFFHLBDW.DBO.UV_FairValueOptionLoans_NOSHFD AS f LEFT JOIN dbo.currentLoan AS mpf ON f.LoanNumber = mpf.LoanNumber 
		CROSS APPLY (SELECT ISNULL(Year(mpf.LoanRecordCreationDate),Year(getDate())) AS OriginationYear,
			CASE WHEN Left(f.ProductCode,2)='GL' THEN 'GL' WHEN f.RemittanceTypeID=1 THEN 'SS' WHEN f.RemittanceTypeID=2 THEN 'AA' ELSE 'MA' END AS RemittanceType,
			ROUND(f.interestRate*200,0)/2 AS PassThruRate, COALESCE(mpf.ProductCode,f.ProductCode) AS ProductCode
			) AS A
	WHERE f.LoanInvestmentStatus NOT IN ('03', '11')
	AND   (f.LOANSettlementDate is NULL OR getDate()-1<f.LOANSettlementDate )

END

---====================================== output to FM 
-- qryMPFOutput  ----- 1000000000
-- Hua 20160229 updated PPMult to handle GNMBS jumbo loans
SELECT AccountClass, AccountType, RemittanceType AS ScheduleType, PrepaymentInterestRate, "MPF" AS Portfolio, PassThruRate, CUSIP, H1, H2, 
	AggNotional, 1 AS Mult, AggFactor, 1 AS [Add Accrued?], "Mid" AS PV, "Mid" as Swap, aggWac, aggCoup, aggWam, aggAge, Swam, AggOWAM, 
	"OAS" AS [P/O], AggPrice, 0 AS OAS, Settle, 1 AS Repo, NxtPmt, 0 AS PPConst,
	IIf(AccountType IN ("15","05","45","20") and aggWAC>=6.02, 1.3, IIf(AccountType IN ("03","43","30") AND aggWAC>=7.04,1.2,1)) AS PPMult, 
	1 AS PPSense, 0 AS [Lag], 0 AS [Lock], 12 AS PPFq, NxtPmt AS NxtPP, "AFT" AS PP, NxtPmt AS NxtRst1, aggWAC AS AggPrepWac, 
	aggCoup AS AggPrepCoup, "Fixed" AS FA, 0 AS Const1, 0 AS Const2, "3L" AS Rate, "12" AS RF, -1000000 as [Floor], 1000000 as Cap,
	1 AS PF, 1000000000 AS PF1, 1000000000 AS PF2, 1000000000 AS PC, "Bond" AS AB, NxtPmt AS NxtRst2, 0 AS LookBackRate, 0 AS LookBack, 
	Settle AS WAMDate, "CPR" AS PPUnits, 0 AS PPCRShift, 0 AS RcvCurrEscr, 0 AS PayCurrEscr, AggBookPrice, "StraightLine" AS AmortMethod, 
	"MPFProgram" AS ClientName, True AS [Active?], Agency, 0 AS [Int Coup Mult], 1 AS [PP Coup Mult], -10000000000 AS [Sum Floor], 10000000000 AS [Sum Cap], 
	"None" AS [Servicing Model], "None" AS [Loss Model], 0 AS [Sched Cap?], IIf([RemittanceType]="MA",2,IIf([RemittanceType]="AA",48, 18)) AS Delay, 
	0 AS Ballon, 1 AS [IF], 1 AS Mult1, 0 AS Mult2
FROM dbo_aggMPF

--- qryUpdateMiddlewareLoadStats-- ============== need to be called
EXEC usp_DataLoadStatistics_INSERT "Daily MPF Loans"


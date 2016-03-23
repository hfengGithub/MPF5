
-----------------------------------------------------------------------------------------------------------------------------------------
uv_allMPFLoans_noshfd, uv_maxpaydate, [UV_DCParticipation_MRA_NOSHFD], [UV_FairValueOptionLoans_NOSHFD], [UV_MasterCommitment_NOSHFD] (, [UV_LAS_Loan])

LSMPFREPOS.MPFREPOS.DBO.uv_DM_MPF_daily_masterCommitments
LSMPFFIVES.MPFFHLBDW.DBO.UV_MasterCommitment_NOSHFD

-- ODBC Connect Str=:ODBC;DSN=MRADB;Description=MRADB;Trusted_Connection=Yes;DATABASE=MRADB


------------------------------------------ NextPmtDate()
-- Hua 20151027 : returns next payment date for give remittance and delivery yr/mon
CREATE FUNCTION dbo.NextPmtDate (@pDelYear int, @pDelMonth int, @pRemittanceTypeID int)
RETURNS DATE AS
BEGIN
	declare @pmtDate DATE
	Set @pmtDate = cast(@pDelYear*10000+118 as char(8))
	-- set @pmtDate =  convert(datetime,replace(str(2015,4)+ str(1,2)+str(18,2),' ',0),112)
	
	If @pRemittanceTypeID=1 set @pmtDate=DATEADD(m,@pDelMonth,@pmtDate)
	else if @pRemittanceTypeID=2 set @pmtDate=DATEADD(m,1+@pDelMonth,@pmtDate)
	else set @pmtDate=DATEADD(d,-16,DATEADD(m,@pDelMonth,@pmtDate))
	RETURN @pmtDate
END


--------- for _DlyMPFDC
-- CREATE VIEW dbo.uv_fwdDC AS
-- SELECT ProductCode, Agency, Delay, SUM(UnfundedAmountP) as Notional, 1 as Age,
-- 	CASE WHEN m.investmentOption='04' THEN 'C' ELSE '' END + f.CUSIP AS CUSIP, 
-- 	CASE WHEN SUBSTRING(ProductCode,3,2)='03' THEN 30 WHEN SUBSTRING(ProductCode,3,2)='05' THEN 15 ELSE SUBSTRING(ProductCode,3,2) END *12 AS Owam, 
-- 	CASE WHEN SUBSTRING(ProductCode,3,2)='03' THEN 30 WHEN SUBSTRING(ProductCode,3,2)='05' THEN 15 ELSE SUBSTRING(ProductCode,3,2) END *12 -1 AS Wam, 
-- 	100*SUM(UnfundedAmountP*f.Coup)/SUM(UnfundedAmountP) AS Coup, 
-- 	100*SUM(UnfundedAmountP*NoteRate)/SUM(UnfundedAmountP) AS Wac, 
-- 	convert(date,replace(str(DeliveryYear,4)+ str(DeliveryMonth,2)+str(ROUND(Sum(Abs(UnfundedAmountP)*DeliveryDay)/Sum(Abs(UnfundedAmountP)),0),2),' ',0),112) as Settle
-- FROM 	dbo.ForwardSettleDCs as f 
-- INNER JOIN LSMPFREPOS.MPFREPOS.DBO.uv_DM_MPF_daily_masterCommitments as m on f.MAnumber=m.MAnumber
-- GROUP BY Agency, Delay, ProductCode, CASE WHEN m.investmentOption='04' THEN 'C' ELSE '' END + f.CUSIP, DeliveryYear, DeliveryMonth
-- HAVING SUM(UnfundedAmountP)>0
-- order by CUSIP


-- usp_getDCs -------- Hua 20151117 DeliveryAmountP=Chicago deliveryAmt
-- Hua 20160229 -- updated productCode to handle GNMBS jumbo loans ========================= need to be manually updated
CREATE PROCEDURE dbo.usp_getDCs AS
BEGIN
	TRUNCATE TABLE dbo.ForwardSettleDCs
	
	INSERT INTO dbo.ForwardSettleDCs
	SELECT a.ProductCode, 
		CASE WHEN Left(a.ProductCode,2)='GL' THEN 
			CASE WHEN Substring(a.ProductCode,3,1) IN ('0','4') THEN 'GNMA2' ELSE 'GNMA' END
		ELSE 'FNMA' END AS Agency, 
		NoteRate, Fee, 0 AS Price, ScheduleType, 
		CASE WHEN Left(a.ProductCode,2)='GL' THEN 1 ELSE v.RemittanceTypeID END AS RemittanceTypeID, RemittanceType, 
		CASE WHEN Left(a.ProductCode,2)='GL' OR v.RemittanceTypeID=1 THEN 18 WHEN v.RemittanceTypeID=2 THEN 48 ELSE 2 END AS Delay, 	
		EntryDate, EntryTime, DeliveryDate, 1 AS DTF, FullName, '1' AS PPMult, PFINumber, MANumber, DeliveryCommitmentNumber, 
		DeliveryAmount, DeliveryAmountP, FundedAmount, FundedAmountP, 
		([DeliveryAmount])-([FundedAmount]) AS UnfundedAmount, [DeliveryAmountP]-[FundedAmountP] AS UnfundedAmountP, LastUpdatedDate, Participation, 
		left(dDate,4) AS DeliveryYear, substring(dDate,5,2) AS DeliveryMonth, right(dDate,2) AS DeliveryDay, 
		RemittanceType + left(dDate,6) + Right(a.ProductCode,2) + CAST(FLOOR(ROUND(NoteRate*200,0)*500) AS varchar) AS CUSIP,		
		IsExtended, ServicingFee, ExcessServicingFee, CEFee, CEPerformanceFee,			
		CASE WHEN Substring(a.ProductCode,3,1) IN ('0','4') THEN ROUND(NoteRate*200,0)/200-0.005 
			WHEN a.ProductCode='FX15' THEN NoteRate-0.0038 WHEN a.ProductCode IN ('FX20','FX30') THEN NoteRate-0.0039 
			ELSE NoteRate-0.0044 END AS Coup,
		CASE WHEN Substring(a.ProductCode,3,1) IN ('0','4') THEN ROUND(NoteRate*200,0)/200-0.005 
			WHEN Left(a.ProductCode,2)='GL' THEN NoteRate-(ServicingFee+ExcessServicingFee+CEFee) 
			ELSE NoteRate-0.0039 END AS CoupOld
			
	FROM LSMPFFIVES.MPFFHLBDW.DBO.UV_DCParticipation_MRA_NOSHFD AS v 
		CROSS APPLY (SELECT 
			CASE WHEN DeliveryCommitmentNumber IN (587414) THEN 'GL4'+RIGHT(v.ProductCode,1) ELSE v.ProductCode END AS ProductCode, 
			CASE WHEN Left(v.ProductCode,2)='GL' THEN 'GL' WHEN RemittanceTypeID=1 THEN 'SS' WHEN RemittanceTypeID=2 THEN 'AA' ELSE 'MA' END AS RemittanceType, 
			CONVERT(varchar,DeliveryDate,112) AS dDate) a
	WHERE ParticipationOrgKey = 3
	ORDER BY NoteRate, DeliveryDate

END

------ usp_setAggDCs
-- usp_setAggDCs -- Hua 20151203
-- Hua 20160229 updated owam to handle the GNMBS jumbo loans
-- Hua 20160316 use UnfundedAmountP (instead of deliveryamount) as weight in calc of price.
CREATE PROCEDURE [dbo].[usp_setAggDCs] AS
BEGIN

	TRUNCATE TABLE dbo.aggDCs
	
	INSERT INTO  dbo.aggDCs
	SELECT a.CUSIP, 
		ProductCode, Agency, SUM(UnfundedAmountP) as Notional, 1 as Age, Sum([UnfundedAmountP]*[price])/Sum([UnfundedAmountP]) as Price, DeliveryYear, RemittanceType, Delay, 
		Round(Sum(Abs(UnfundedAmountP)*[DeliveryDay])/Sum(Abs([UnfundedAmountP])),0) AS WASettleDay, 
		100*SUM(UnfundedAmountP*f.Coup)/SUM(UnfundedAmountP) AS Coup, 
		100*SUM(UnfundedAmountP*NoteRate)/SUM(UnfundedAmountP) AS Wac, 
		Owam, Owam-1 AS Wam, CASE WHEN OWAM=180 THEN 160 WHEN oWam=360 THEN 355 WHEN oWam=240 THEN 220 END AS sWam, 
		convert(date,replace(str(DeliveryYear,4)+ str(DeliveryMonth,2)+str(ROUND(Sum(Abs(UnfundedAmountP)*DeliveryDay)/Sum(Abs(UnfundedAmountP)),0),2),' ',0),112) as Settle,
		dbo.NextPmtDate(DeliveryYear, DeliveryMonth, RemittanceTypeID) as NxtPmt, Count(NoteRate) AS NumberofCommitments,
		100*SUM(UnfundedAmountP*f.CoupOld)/SUM(UnfundedAmountP) AS CoupOld		
	FROM 	dbo.ForwardSettleDCs as f 
	INNER JOIN LSMPFREPOS.MPFREPOS.DBO.uv_DM_MPF_daily_masterCommitments as m on f.MAnumber=m.MAnumber
		CROSS APPLY (SELECT 
			CASE Right(ProductCode,1) WHEN '3' THEN 30 WHEN '5' THEN 15 ELSE SUBSTRING(ProductCode,3,2) END *12 AS Owam,
			CASE WHEN m.investmentOption='04' THEN 'C' ELSE '' END + f.CUSIP AS CUSIP ) a
	WHERE UnfundedAmountP>0
	GROUP BY Agency, Delay, ProductCode, a.CUSIP, DeliveryYear, DeliveryMonth, oWam, RemittanceTypeID, RemittanceType
	
END

-------------- qryAggDC --- Hua 20160124 : output to P:\Workspaces\Hedging\QRMMPF\tblForwardCommitmentPalmsSourceYYYYMMDD.xls
-- Hua 20160229 updated PPMult to handle GNMBS jumbo loans
SELECT ProductCode, IIf (RemittanceType="MA", 3, IIf(RemittanceType="AA", 2, 1)) AS RemittanceTypeID, RemittanceType AS ScheduleType, 
	RemittanceType AS ScheduleType2, Delay, DeliveryYear, INT(Left(RIGHT(CUSIP,8),2)) as DeliveryMonth, WASettleDay, "MPFForward" AS Portfolio, 
	CUSIP, CUSIP as CusipHedged, Owam, DeliveryYear as [Account Class], Right(ProductCode,2) AS [Account Type], RemittanceType as [Sub Account Type], 
	"MPF" as H1, WASettleDay as H2, Notional, "1" AS Mult, "1" AS Factor, "1" AS [Add Accrued?], "Mid" as PV, "Mid" as Swap, Wac, Coup, coupOld, 
	1 AS Age, Wam, Swam, "OAS" AS [P/O], 0 AS OAS, Price as P, Settle, 1 AS Repo, NxtPmt, "AFT" AS PP, "0" AS PPConst,
	Iif(Right(ProductCode,2) IN ("15","05","45","20") AND Wac>=6.02, 1.3, IIf(Right(ProductCode,2) IN ("30", "03") AND WAC>=7.04,1.2,1)) AS PPMult, 
	"1" AS PPSens, "0" AS Lag, "0" AS Lock, 0 AS PPCRShift, 12 AS PPFq, NxtPmt AS NxtPP, NxtPmt AS NxtRst1, WAC AS PrepWac, Coup AS PrepCoup,
	"F" AS FA1, "0" AS Const1, "0" AS Mult1, "3L" AS Rate1, "12" AS RF1, "None" AS Floor1, "None" AS Cap1, "None" AS PF1, "None" AS PC1, "Bond" AS AB1, 
	NxtPmt as NxtRst2, Notional AS Book, "MPFForward" AS ClientName, Notional as AggNotional, price AS WAPrice, NumberofCommitments, Agency
FROM  dbo_aggDCs



-------------------------------------------
insert into dbo_Instrument_MBS_MPF
select * from bkIMM

insert into dbo_Portfolio_Contents_MBS_MPF
select * from bkPCMM


-- qryDeleteMPFandForwardsfromInstrumenttblMiddleware ===== cmdDeleteMiddleware_Click
-- Hua 20150310 dropped the cusip filters
DELETE * FROM Instrument_MBS_MPF
WHERE (BondCUSIP="MPF" Or BondCUSIP="MPFForward")

-- qryDeleteDataFromPortfolioContentsMiddleware ========= cmdDeleteMiddleware_Click()
DELETE FROM Portfolio_Contents_MBS_MPF


--------------- PPMult 
UPDATE tblForwardCommitmentPalmsSource SET PPMult = 1.3
WHERE (((ProductCode) Like "FX15" Or (ProductCode)="GL15" 
Or (ProductCode)="FX20" Or (ProductCode)="GL20") AND ((CDbl([tblForwardCommitmentPalmsSource].[Wac]))>=6.02));

-- UpdateMPFForward30PPMult
UPDATE tblForwardCommitmentPalmsSource SET tblForwardCommitmentPalmsSource.PPMult = 1.2
WHERE (((tblForwardCommitmentPalmsSource.ProductCode) Like "FX30" Or (tblForwardCommitmentPalmsSource.ProductCode)="GL30") AND ((CDbl([tblForwardCommitmentPalmsSource].[Wac]))>=7.04));




--- qryAppDCtoIMM
---------- Hua 20151207
INSERT INTO dbo_Instrument_MBS_MPF ( CUSIP, Active_q, Agency, Delay, Wac, Coup, Balloon, Owam, IF, PF, FA1, Const1, Mult1, Rate1, RF1, Floor1, Cap1, PF1, PC1, AB1, 
	LookBack1, Int_Coup_Mult, PP_Coup_Mult, Sum_Floor, Sum_Cap, Servicing_Model, Loss_Model, Sched_Cap_q, BondCUSIP )
SELECT Cusip, True AS Active_q, Agency, Delay, Wac, Coup, 0 AS Balloon, Owam, 1 AS IF, 1 AS PF, "F" AS FA1, 0 as Const1, 1 AS Mult1, "3L" as Rate1,  
	12 as RF1, -1000000000 AS Floor1, 1000000000 AS Cap1, 1000000000 AS PF1, 1000000000 AS PC1, "Bond" as AB1, 0 AS LookBack1, 0 AS Int_Coup_Mult, 1 AS PP_Coup_Mult, 
	-10000000000 AS Sum_Floor, 10000000000 AS Sum_Cap, "None" AS Servicing_Model, "None" AS Loss_Model, 0 AS Sched_Cap_q, "MPFForward" AS BondCUSIP
FROM dbo_aggDCs;


--- qryAppDCtoPCMM 
--------- Hua 20151207
-- INSERT INTO dbo_Portfolio_Contents_MBS_MPF ( Portfolio, CUSIP, IntexId, Account_Class, Account_Type, Sub_Account_Type, H1, H2, Notional, Mult, Factor, Add_Accrued_q, 
-- 	PV, Swap, Wac, Coup, Wam, Age, Swam, P_O, P, Settle, Repo, NxtPmt, PP, PPConst, PPMult, PPSens, Lag, Lock, PPCRShift, PPFq, NxtPP, 
-- 	NxtRst1, PrepWac, PrepCoup, FA2, Const2, Mult2, Rate2, RF2, Floor2, Cap2, PF2, PC2, AB2, NxtRst2, ClientName, BookPrice, OAS, WamDate, BurnStrength )
-- SELECT "MPFForward" AS Portfolio, cusip, RIGHT(CUSIP,4)/1000 AS IntexId, DeliveryYear as Account_Class, Right(ProductCode,2) AS Account_Type, RemittanceType as Sub_Account_Type, 
-- 	"MPF" as H1, WASettleDay as H2, Notional, 1 AS Mult, 1 AS Factor, 1 AS Add_Accrued_q, "Mid" as PV, "Mid" as Swap, Wac, Coup, Wam, 1 AS Age, Swam, 
-- 	"OAS" AS P_O, Price as P, Settle, 1 AS Repo, NxtPmt, "AFT" AS PP, 0 AS PPConst, 
-- 	Iif(ProductCode IN ("FX15", "GL15", "GL05", "FX20", "GL20") AND Wac>=6.02, 1.3, IIf(ProductCode IN ("FX30", "GL03", "GL30") AND WAC>=7.04,1.2,1)) AS PPMult, 
-- 	1 AS PPSens, 0 AS Lag, 0 AS Lock, 0 AS PPCRShift, 12 AS PPFq, NxtPmt AS NxtPP, 
-- 	NxtPmt AS NxtRst1, WAC AS PrepWac, Coup AS PrepCoup, "F" AS FA2, 0 AS Const2, 0 AS Mult2, "3L" AS Rate2, 12 AS RF2, -1000000000 AS Floor2, 1000000000 AS Cap2, 
-- 	1000000000 AS PF2, 1000000000 AS PC2, "Bond" AS AB2, NxtPmt as NxtRst2, "MPFForward" AS ClientName, Notional AS Book, 0 AS OAS, Settle AS WAMDate, 1 AS BurnStrength
-- FROM dbo_aggDCs;

--- qryAppDCtoPCMM 
--------- Hua 20160125 -- use qryAggDC
INSERT INTO dbo_Portfolio_Contents_MBS_MPF ( Portfolio, CUSIP, IntexId, Account_Class, Account_Type, Sub_Account_Type, H1, H2, Notional, Mult, Factor, Add_Accrued_q, 
	PV, Swap, Wac, Coup, Wam, Age, Swam, P_O, P, Settle, Repo, NxtPmt, PP, PPConst, PPMult, PPSens, Lag, Lock, PPCRShift, PPFq, NxtPP, 
	NxtRst1, PrepWac, PrepCoup, FA2, Const2, Mult2, Rate2, RF2, Floor2, Cap2, PF2, PC2, AB2, NxtRst2, ClientName, BookPrice, OAS, WamDate, BurnStrength )
SELECT Portfolio, cusip, RIGHT(CUSIP,4)/1000 AS IntexId, [Account Class], [Account Type], [Sub Account Type], H1, H2, Notional, Mult, Factor, [Add Accrued?], 
	PV, Swap, Wac, Coup, Wam, Age, Swam, [P/O], P, Settle, Repo, NxtPmt, PP, PPConst, PPMult, PPSens, Lag, Lock, PPCRShift, PPFq, NxtPP, 
	NxtRst1, PrepWac, PrepCoup, FA1, Const1, Mult1, Rate1, RF1, -1000000000 AS Floor2, 1000000000 AS Cap2, 
	1000000000 AS PF2, 1000000000 AS PC2, AB1, NxtRst2, ClientName, Book, OAS, Settle AS WAMDate, 1 AS BurnStrength
FROM qryAggDC;


-------------============================== calculate the prices of DCs ======= begin 
DC price: FX20=FX30 for TBA, excess coupon adj, carry adj; GL03/43=GL30 and GL05/45=GL15 for carry adj 
Price = TBA price + 
		Excess Cpn Adj (0 for GNMBS) + 
		CarryAdj (in ticks) + 
		Remittance Adj (0 for GNMBS) + 
		Product Adj (in ticks, FX20, GL15(in TBApx), GL43/45 only) + 		
		volume weighted purchase adjustments (in bps, 0 for GNMBS) -
		70 bps for GNMBS 

-- qryPxAdj ----------- get the price adjustments from the spread sheet priceAdj.xlsx
-- Hua 20160129
SELECT p.productCode, px.Rate, q.daysOut, [carry]/32-IIf(p.productCode in ("GL05","GL03"),0.7,0) AS carryAdj, px.Price, 
	NZ(px.ExcessAdj,0) as excessAdj, s.ServicingFee, r.remittanceID, IIf(p.productCode in ("GL05","GL03"),0,r.remitAdj) AS remitAdj 
FROM  remittanceAdj as r, ((MPFProduct AS p INNER JOIN TBApx AS px ON IIf(p.productCode="FX20","FX30",p.productCode) = Left(px.Cusip,4)) 
INNER JOIN qryCarry AS q ON (q.Rate = px.Rate) AND (IIf(p.productCode="FX20","FX30",IIf(p.productCode="GL03","GL30",IIf(p.productCode="GL05","GL15",p.productCode))) = q.productCode))
INNER JOIN servicingFee as s ON s.productCode=p.productCode
ORDER BY p.productCode, px.rate,  r.remittanceID, q.daysOut

------- qryDCpxChk ----------- get the components for DC price: for testing
-- Hua 20160129
SELECT qp.productCode, qp.Rate, qp.daysOut, qp.carryAdj, qp.Price, qp.excessAdj, qp.ServicingFee, qp.remittanceID, qp.remitAdj, NZ(pa.prodAdj,0)/32 as prodAdj, NZ(f.spreadBps,0)/100 as FHLBadj
FROM (qryPxAdj as qp LEFT JOIN (SELECT rate, Left(cusip,4) as productCode, prodAdj from prodAdj) as pa ON qp.productCode=pa.productCode and qp.rate=pa.rate)
LEFT JOIN FHLBadj as f ON qp.productCode=f.productCode
ORDER BY qp.productCode, qp.rate, qp.remittanceID, qp.daysOut

------- qryDCpx ----------- get the DC price
-- Hua 20160129 -- get productAdj and FHLBAdj directly, others from qryPxAdj
-- Hua 20160302 -- updated join with productAdj to handle the GNMBS jumbo loans
SELECT Format(now(),"mm/dd/yyyy") AS as_of_date, qp.productCode, qp.remittanceID AS ServicingRemittanceType, qp.ServicingFee, qp.Rate AS InterestRate, qp.daysOut, 
	qp.Price+ qp.excessAdj+ qp.carryAdj+ qp.remitAdj+ NZ(pa.prodAdj,0)/32+ NZ(f.spreadBps,0)/100 as DCMatrixPrice
FROM (qryPxAdj as qp LEFT JOIN (SELECT rate, Left(cusip,4) as productCode, prodAdj from prodAdj) as pa 
	ON IIf(Mid(qp.productCode,3,1)="4","GL43",qp.productCode)=pa.productCode and qp.rate=pa.rate)
LEFT JOIN FHLBadj as f ON qp.productCode=f.productCode
ORDER BY qp.productCode, qp.rate, qp.remittanceID, qp.daysOut
-------------============================== calculate the prices of DCs ======= END 

-- qrySumDC ------ reporting DC summary
-- Hua 20160307
SELECT dbo_aggDCs.CUSIP, dbo_aggDCs.Wac, dbo_aggDCs.Owam, dbo_aggDCs.Wam, dbo_aggDCs.Coup AS Coupon, dbo_aggDCs.Price, dbo_aggDCs.NumberofCommitments AS [#Commitments], dbo_aggDCs.Notional
FROM dbo_aggDCs
ORDER BY dbo_aggDCs.CUSIP;


----------------------------- TEST
-- qrySetDCpx
UPDATE dbo_ForwardSettleDCs AS f, DCprice AS p SET f.Price = p.Price
WHERE (((p.[Date])=CDate(f.[DeliveryDate])) AND 100*f.NoteRate=p.[MPF Rate]
AND (f.[RemittanceTypeID]=p.[ServicingRemittanceType])
AND ((f.ProductCode)=p.[CatType]));



-- qryCarry ----------------------------
-- Hua 20160121 -- It's too long in Access, so divide it to 2 queries and take the union
	
SELECT Rate, Left(MPFTicker, 4) as productCode, 0 as daysOut, day00 as carry FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 1 as daysOut, day01  FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 2 as daysOut, day02  FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 3 as daysOut, day03  FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 4 as daysOut, day04  FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 5 as daysOut, day05  FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 6 as daysOut, day06  FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 7 as daysOut, day07  FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 8 as daysOut, day08  FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 9 as daysOut, day09  FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 10 as daysOut, day10 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 11 as daysOut, day11 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 12 as daysOut, day12 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 13 as daysOut, day13 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 14 as daysOut, day14 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 15 as daysOut, day15 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 16 as daysOut, day16 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 17 as daysOut, day17 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 18 as daysOut, day18 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 19 as daysOut, day19 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 20 as daysOut, day20 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 21 as daysOut, day21 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 22 as daysOut, day22 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 23 as daysOut, day23 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 24 as daysOut, day24 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 25 as daysOut, day25 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 26 as daysOut, day26 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 27 as daysOut, day27 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 28 as daysOut, day28 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 29 as daysOut, day29 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 30 as daysOut, day30 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 31 as daysOut, day31 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 32 as daysOut, day32 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 33 as daysOut, day33 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 34 as daysOut, day34 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 35 as daysOut, day35 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 36 as daysOut, day36 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 37 as daysOut, day37 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 38 as daysOut, day38 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 39 as daysOut, day39 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 40 as daysOut, day40 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 41 as daysOut, day41 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 42 as daysOut, day42 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 43 as daysOut, day43 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 44 as daysOut, day44 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 45 as daysOut, day45 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 46 as daysOut, day46 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 47 as daysOut, day47 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 48 as daysOut, day48 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 49 as daysOut, day49 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 50 as daysOut, day50 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 51 as daysOut, day51 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 52 as daysOut, day52 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 53 as daysOut, day53 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 54 as daysOut, day54 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 55 as daysOut, day55 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 56 as daysOut, day56 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 57 as daysOut, day57 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 58 as daysOut, day58 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 59 as daysOut, day59 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 60 as daysOut, day60 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 61 as daysOut, day61 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 62 as daysOut, day62 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 63 as daysOut, day63 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 64 as daysOut, day64 FROM carryAdj WHERE rate is not null UNION
SELECT Rate, Left(MPFTicker, 4) as productCode, 65 as daysOut, day65 FROM carryAdj WHERE rate is not null 


-- New Year's Day (possibly moved to Monday if on Sunday or to Friday if on Saturday 1/1)
-- Martin Luther King's birthday (third Monday in January)
-- Washington's birthday (third Monday in February)
-- Memorial Day (last Monday in May)
-- Independence Day (Monday if Sunday or Friday if Saturday 7/4)
-- Labor Day (first Monday in September)
-- Columbus Day (second Monday in October)
-- Veteran's Day (Monday if Sunday or Friday if Saturday 11/11)
-- Thanksgiving Day (fourth Thursday in November)
-- Christmas (Monday if Sunday or Friday if Saturday 12/25)

------------------- Hua 20160123 qryBusinessDay
-- SELECT [As of Date] AS asOfDate, Iif ([ISO Day of Week] > 5, "N",
--     Iif ((([Day Of Month] = 1 Or ([Day Of Month] = 2 And [ISO Day of Week] = 1)) And [Month] = 1) 
--     Or ([Day Of Month] = 31 And [ISO Day of Week] = 5 And [Month] = 12) 
--     Or (([Day Of Month] >= 15 And [Day Of Month] <= 21) And [ISO Day of Week] = 1 And [Month] = 1) 
--     Or (([Day Of Month] >= 15 And [Day Of Month] <= 21) And [ISO Day of Week] = 1 And [Month] = 2) 
--     Or ([Day Of Month] >= 25 And [ISO Day of Week] = 1 And [Month] = 5) 
--     Or (([Day Of Month] = 4 Or ([Day Of Month] = 5 And [ISO Day of Week] = 1) Or ([Day Of Month] = 3 And [ISO Day of Week] = 5)) And [Month] = 7) 
--     Or ([Day Of Month] <= 7 And [ISO Day of Week] = 1 And [Month] = 9) 
--     Or (([Day Of Month] >= 8 And [Day Of Month] <= 14) And [ISO Day of Week] = 1 And [Month] = 10) 
--     Or (([Day Of Month] = 11 Or ([Day Of Month] = 12 And [ISO Day of Week] = 1) Or ([Day Of Month] = 10 And [ISO Day of Week] = 5)) And [Month] = 11) 
--     Or (([Day Of Month] >= 22 And [Day Of Month] <= 28) And [ISO Day of Week] = 4 And [Month] = 11) 
--     Or (([Day Of Month] = 25 Or ([Day Of Month] = 26 And [ISO Day of Week] = 1) Or ([Day Of Month] = 24 And [ISO Day of Week] = 5)) And [Month] = 12)
--     Or ([Day Of Month] = 31 And [ISO Day of Week] = 5 And [Month] = 12), "N", "Y")) AS IsBusinessDay, [Weekday Name] as wDay
-- FROM dbo_UV_EDW_CALENDAR;

------------------- Hua 20160126 qryBusinessDay 
-- FHLB's Holidays: Friday FHLB will open if Saturday is a holiday
SELECT [As of Date] AS asOfDate, Iif ([ISO Day of Week] > 5, "N",
    Iif ((([Day Of Month] = 1 Or ([Day Of Month] = 2 And [ISO Day of Week] = 1)) And [Month] = 1) 
    Or ([Day Of Month] = 31 And [ISO Day of Week] = 5 And [Month] = 12) 
    Or (([Day Of Month] >= 15 And [Day Of Month] <= 21) And [ISO Day of Week] = 1 And [Month] = 1) 
    Or (([Day Of Month] >= 15 And [Day Of Month] <= 21) And [ISO Day of Week] = 1 And [Month] = 2) 
    Or ([Day Of Month] >= 25 And [ISO Day of Week] = 1 And [Month] = 5) 
    Or (([Day Of Month] = 4 Or ([Day Of Month] = 5 And [ISO Day of Week] = 1)) And [Month] = 7) 
    Or ([Day Of Month] <= 7 And [ISO Day of Week] = 1 And [Month] = 9) 
    Or (([Day Of Month] >= 8 And [Day Of Month] <= 14) And [ISO Day of Week] = 1 And [Month] = 10) 
    Or (([Day Of Month] = 11 Or ([Day Of Month] = 12 And [ISO Day of Week] = 1)) And [Month] = 11) 
    Or (([Day Of Month] >= 22 And [Day Of Month] <= 28) And [ISO Day of Week] = 4 And [Month] = 11) 
    Or (([Day Of Month] = 25 Or ([Day Of Month] = 26 And [ISO Day of Week] = 1)) And [Month] = 12), "N", 
	"Y")) AS IsBusinessDay, [Weekday Name] as wDay
FROM dbo_UV_EDW_CALENDAR;

------------------ Hua 20160123 qryMkBusinessDate
INSERT INTO tblBusinessDate (asOfDate, wDay)
SELECT qryBusinessDay.asOfDate, wDay
FROM qryBusinessDay
WHERE (((qryBusinessDay.asOfDate) Between #1/1/2016# And #12/31/2035#) AND ((qryBusinessDay.IsBusinessDay)="Y"))
ORDER BY asOfDate;


-- qryBusinessDate
SELECT bdID-(select bdID from FHLBbusinessDate where Format(Now(), "yyyymmdd")=Format(asOfDate, "yyyymmdd")) AS daysOut, asOfDate
FROM FHLBbusinessDate
WHERE datediff("d", now(), asOfDate) between 0 and 100
ORDER BY asOfDate;

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
-- Hua 20160302 -- updated carryAdj, remitAdj, join on qryCarry, JOIN on TBApx 
SELECT p.productCode, px.Rate, q.daysOut, q.carry/32-IIf(Mid(p.productCode,3,1) IN ("0","4"),0.7,0) AS carryAdj, px.Price, 
	NZ(px.ExcessAdj,0) as excessAdj, s.ServicingFee, r.remittanceID, IIf(Mid(p.productCode,3,1) IN ("0","4"),0,r.remitAdj) AS remitAdj 
FROM  remittanceAdj as r, ((MPFProduct AS p INNER JOIN TBApx AS px 
	ON IIf(p.productCode="FX20","FX30",IIf(Mid(p.productCode,3,1)="4",left(p.productCode,2) & "0" & Right(p.productCode,1),p.productCode)) = Left(px.Cusip,4)) 
INNER JOIN qryCarry AS q ON (q.Rate = px.Rate) AND (IIf(p.productCode="FX20","FX30",IIf(Right(p.productCode,1)="3","GL30",IIf(Right(p.productCode,1)="5","GL15",p.productCode))) = q.productCode))
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

=IF($A29="","",IF(ISNA(VLOOKUP($A29,$C$2:$D$700,2,0)),$B29,VLOOKUP($A29,$C$2:$D$700,2,0)))

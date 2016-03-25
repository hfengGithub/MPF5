
-- ODBC Connect Str=:ODBC;DSN=MRADB;Description=MRADB;Trusted_Connection=Yes;DATABASE=MRADB

Option Compare Database

'-------------------- Hua get current daily file dir
Function getMRODir() As String
On Error GoTo ErrProc
    Const sRootDir = "K:\MRO\Archive\"
    Dim sYrDir, sMnDir, sDayDir As String
    dCurDate = Format(Now(), "yyyymmdd")

    sYrDir = Left(dCurDate, 4)
    sMnDir = Mid(dCurDate, 5, 2)
    sDayDir = Right(dCurDate, 2)
    getMRODir = sRootDir & sYrDir & "\" & sYrDir & "-" & sMnDir & "\" & sYrDir & "-" & sMnDir & "-" & sDayDir & "\"
    Exit Function
ErrProc:
    MsgBox "ERROR " & Err.Number & " - " & Err.Description, vbCritical, "loadFile_Click"
End Function

'----------------------------------------- Hua 20151202
Private Sub getDCs_Click()
    With CurrentDb.QueryDefs("qPass")
    .SQL = "exec dbo.usp_getDCs"
    .ReturnsRecords = False
    .Execute
    End With
    MsgBox "Process Complete", vbInformation, " "
End Sub

'----------------------------------------- Hua 20151202
Private Sub SetAggDCs_Click()
    With CurrentDb.QueryDefs("qPass")
    .SQL = "exec dbo.usp_setAggDCs"
    .ReturnsRecords = False
    .Execute
    End With
    MsgBox "Process Complete", vbInformation, " "

End Sub


'-- Hua 20160120 Added setting price=100 for old DCs
'-- Hua 20160201 export DCMatrix first, link it in, replace DCprice.
' Private Sub setDCprice_Click()
' On Error GoTo err_handler
'     Dim sSQL, sStep, sDir, sFileName As String
'     dsTime = Now()
'     sStep = "Output DC price"
'     sFileName = "HAUSDCMatrix.xls"
'     ' sDir = getMRODir() & "Pricing\"
'     sDir = "K:\MRA\MPF5\SQLServer\"
'     sFileName = sDir & sFileName
' 
'     ' export the DCMatrix
' 	DoCmd.TransferSpreadsheet acExport, 9, "qryDCpx", sFileName, True
'     On Error Resume Next
'     CurrentDb().Execute ("drop table linkDCMatrix")
'     On Error GoTo err_handler
'     DoCmd.TransferSpreadsheet acLink, , "linkDCMatrix", sFileName, -1
'     
'     sStep = "Setting DC price"
'     DoCmd.SetWarnings False
'     sSQL = "UPDATE dbo_ForwardSettleDCs AS f, linkDCMatrix AS p, linkBusinessDate AS b " & _
'         "SET f.Price = p.DCMatrixPrice " & _
'         "WHERE (p.daysOut=b.daysOut AND b.asOfDate=f.DeliveryDate) " & _
'         "AND (f.NoteRate=p.InterestRate) " & _
'         "AND (f.RemittanceTypeID=p.ServicingRemittanceType) " & _
'         "AND (f.ProductCode=p.productCode) "
'     DoCmd.RunSQL sSQL
' 
'     sSQL = "UPDATE dbo_ForwardSettleDCs SET Price=100 WHERE Price=0 AND DeliveryDate < now() "
'     DoCmd.RunSQL sSQL
' 
'     ' sFileName = "\\prodfs.fhlbc.loc\softwarep\DP\HAUS\data\HAUSDCMatrix.txt"
' 	' better write to a table in SQL Server, and DBS get data there
'     sFileName = sDir & "HAUSDCMatrix.txt"
'     DoCmd.TransferText acExportDelim, "SpecHAUSDCmatrix", "qryDCpx", sFileName, True
' 	
'     MsgBox sStep & " Complete", vbInformation, " "
'     DoCmd.SetWarnings True
'     Exit Sub
' err_handler:
'     deTime = Now()
'     MsgBox "Error Number: " & Err.Number & " '" & Err.Description & "' was encountered during step '" & _
'             sStep & "'" & vbCrLf & "The Process had run " & _
'             DateDiff("n", dsTime, deTime) & " minutes.", vbCritical, "Contact Application Support"
' End Sub

'-- Hua 20160120 Added setting price=100 for old DCs
'-- Hua 20160202 export DCMatrix first, link it in, replace DCprice. Export to Archive and HAUS
Private Sub setDCprice_Click()
On Error GoTo err_handler
    Dim sSQL, sStep, sDir, sFileName As String
    Dim oXLApp As Excel.Application
    Dim xlWB As Excel.Workbook
    dsTime = Now()
    sStep = "Output DC price"
    sFileName = "HAUSDCMatrix.xls"
    ' sDir = getMRODir(Format(dsTime,"yyyymmdd")) & "Pricing\"
    sDir = "K:\MRA\MPF5\SQLServer\"
    sFileName = sDir & sFileName

    ' export the DCMatrix and link it back
    DoCmd.TransferSpreadsheet acExport, 9, "qryDCpx", sFileName, True
    On Error Resume Next
    CurrentDb().Execute ("drop table linkDCMatrix")
    On Error GoTo err_handler
    DoCmd.TransferSpreadsheet acLink, 9, "linkDCMatrix", sFileName, -1

    ' create file for HAUS
    Set oXLApp = New Excel.Application
    oXLApp.Visible = False
    Set xlWB = oXLApp.Workbooks.Open(sFileName)
    sFileName = sDir & "HAUSDCMatrix.txt"
    xlWB.SaveAs sFileName, xlCSVMSDOS
    xlWB.Close False
    
    sStep = "Setting DC price"
    DoCmd.SetWarnings False

    sSQL = "UPDATE dbo_ForwardSettleDCs AS f, linkDCMatrix AS p, linkBusinessDate AS b " & _
        "SET f.Price = p.DCMatrixPrice " & _
        "WHERE (p.daysOut=b.daysOut AND b.asOfDate=f.DeliveryDate) " & _
        "AND (f.NoteRate=p.InterestRate) " & _
        "AND (f.RemittanceTypeID=p.ServicingRemittanceType) " & _
        "AND (f.ProductCode=p.productCode) "
    DoCmd.RunSQL sSQL

    sSQL = "UPDATE dbo_ForwardSettleDCs SET Price=100 WHERE Price=0 AND DeliveryDate<now() "
    DoCmd.RunSQL sSQL

    deTime = Now()
    MsgBox "Exporting/setting DC price took " & DateDiff("s", dsTime, deTime) & " seconds.", vbInformation, " " 
    DoCmd.SetWarnings True
    Exit Sub
err_handler:
    deTime = Now()
    MsgBox "Error Number: " & Err.Number & " '" & Err.Description & "' was encountered during step '" & _
            sStep & "'" & vbCrLf & "The Process had run " & _
            DateDiff("n", dsTime, deTime) & " minutes.", vbCritical, "Contact Application Support"
End Sub

'-- Hua 20160304 put DCMatrix in a table. too slow
' Private Sub setDCprice_Click()
' On Error GoTo err_handler
'     Dim sSQL, sStep, sDir, sFileName As String
'     Dim oXLApp As Excel.Application
'     Dim xlWB As Excel.Workbook
'     dsTime = Now()
'     sStep = "Output DC price"
'     sFileName = "HAUSDCMatrix.xls"
'     ' sDir = getMRODir(Format(dsTime,"yyyymmdd")) & "Pricing\"
'     sDir = "K:\MRA\MPF5\SQLServer\"
'     sFileName = sDir & sFileName
' 
'     ' export the DCMatrix
'     DoCmd.SetWarnings False
'     On Error Resume Next
'     CurrentDb().Execute ("Select * into DCMatrix from qryDCpx")
'     On Error GoTo err_handler
'     DoCmd.TransferSpreadsheet acExport, 9, "DCMatrix", sFileName, -1
' 
'     ' create file for HAUS
'     Set oXLApp = New Excel.Application
'     oXLApp.Visible = False
'     Set xlWB = oXLApp.Workbooks.Open(sFileName)
'     sFileName = sDir & "HAUSDCMatrix.txt"
'     xlWB.SaveAs sFileName, xlCSVMSDOS
'     xlWB.Close False
'     
'     sStep = "Setting DC price"
' 
'     sSQL = "UPDATE dbo_ForwardSettleDCs AS f, DCMatrix AS p, linkBusinessDate AS b " & _
'         "SET f.Price = p.DCMatrixPrice " & _
'         "WHERE (p.daysOut=b.daysOut AND b.asOfDate=f.DeliveryDate) " & _
'         "AND (f.NoteRate=p.InterestRate) " & _
'         "AND (f.RemittanceTypeID=p.ServicingRemittanceType) " & _
'         "AND (f.ProductCode=p.productCode) "
'     DoCmd.RunSQL sSQL
' 
'     sSQL = "UPDATE dbo_ForwardSettleDCs SET Price=100 WHERE Price=0 AND DeliveryDate<now() "
'     DoCmd.RunSQL sSQL
' 
'     deTime = Now()
'     MsgBox "Exporting/setting DC price took " & DateDiff("s", dsTime, deTime) & " seconds.", vbInformation, " "
'     DoCmd.SetWarnings True
'     Exit Sub
' err_handler:
'     deTime = Now()
'     MsgBox "Error Number: " & Err.Number & " '" & Err.Description & "' was encountered during step '" & _
'             sStep & "'" & vbCrLf & "The Process had run " & _
'             DateDiff("n", dsTime, deTime) & " minutes.", vbCritical, "Contact Application Support"
' End Sub



'----------------------------------------- Hua 20151207 --- replaced by outputToMiddleware_Click(), see procLoan.vbs
' Private Sub DCtoMiddleware_Click()
' On Error GoTo err_handler
'     Dim sSQL, sStep As String
'     sStep = "Send DC to MiddleWare"
'     dsTime = Now()
'     
'     DoCmd.SetWarnings False
'     sSQL = "DELETE * FROM dbo_Instrument_MBS_MPF " & _
'         "WHERE (BondCUSIP=""MPFForward"")"
'     DoCmd.RunSQL sSQL
'     DoCmd.OpenQuery "qryAppDCtoIMM", acNormal, acEdit
'     
'     sSQL = "DELETE * FROM dbo_Portfolio_Contents_MBS_MPF " & _
'         "WHERE (Portfolio=""MPFForward"")"
'     DoCmd.RunSQL sSQL
'     DoCmd.OpenQuery "qryAppDCtoPCMM", acNormal, acEdit
'     
'     MsgBox "DCtoMiddleware Complete", vbInformation, " "
'     DoCmd.SetWarnings True
'     Exit Sub
' 
' err_handler:
'     deTime = Now()
'     MsgBox "Error Number: " & Err.Number & " '" & Err.Description & "' was encountered during step '" & _
'             sStep & "'" & vbCrLf & "The Process had run " & _
'             DateDiff("n", dsTime, deTime) & " minutes.", vbCritical, "Contact Application Support"
'     DoCmd.SetWarnings True
' 
' End Sub

'======= Hua 20151002 ---- getMRODir: get MRO dir of daily files; sDate=yyyymmdd
Function getMRODir(ByVal sDate As String) As String
On Error GoTo ErrProc
    Const sRootDir = "K:\MRO\Archive\"
    Dim sYrDir, sMnDir, sDayDir As String

    sYrDir = Left(sDate, 4)
    sMnDir = Mid(sDate, 5, 2)
    sDayDir = Right(sDate, 2)
    getMRODir = sRootDir & sYrDir & "\" & sYrDir & "-" & sMnDir & "\" & sYrDir & "-" & sMnDir & "-" & sDayDir & "\"
    Exit Function
ErrProc:
    MsgBox "ERROR " & Err.Number & " - " & Err.Description, vbCritical, "loadFile_Click"
End Function

'------------- 20151207
Private Sub LoadDCMatrix_Click()
On Error GoTo ErrProc
    Dim sFileName As String
    
    sFileName = getMRODir(inDate.Value) & "Pricing\HAUSDCMatrix.txt"
    
    On Error Resume Next
    CurrentDb().Execute ("drop table linkDCMatrix")
On Error GoTo ErrProc
    DoCmd.TransferText acLinkDelim, "specLinkDCMatrix", "linkDCMatrix", sFileName, -1
    DoCmd.SetWarnings False
    CurrentDb.Execute ("appDCMatrix")
    DoCmd.SetWarnings True
    MsgBox "LoadDCMatrix: Done! "
    Exit Sub
        
ErrProc:
    MsgBox "ERROR " & Err.Number & " - " & Err.Description, vbCritical, "LoadDCMatrix_Click"

End Sub


'------------- 20160126 not used
' Private Sub prepareDCpx_Click()
' 	' sDCDir = "\\w2kmsmrap1.fhlbc.loc\mra\Al\QRMInput\"
' 	' sHAUSDCDir = "\\prodfs.fhlbc.loc\softwarep\DP\HAUS\data\"
' 	sDir = "K:\MRA\MPF5\SQLServer\"
' 	DoCmd.TransferSpreadsheet acExport, 9, "qryBusinessDate", sDir & "priceAdj.xlsx"
' 	
'     MsgBox "prepareDCpx complete"
' End Sub

'------------- 20160131 Called from MPF-Pricing-template.xlsm
Public Sub prepareDCpx()
    ' sDCDir = "\\w2kmsmrap1.fhlbc.loc\mra\Al\QRMInput\"
    ' sHAUSDCDir = "\\prodfs.fhlbc.loc\softwarep\DP\HAUS\data\"
    sDir = "K:\MRA\MPF5\SQLServer\"
    
    DoCmd.TransferSpreadsheet acExport, 9, "qryBusinessDate", sDir & "priceAdj.xlsx"
End Sub

\\w2kmsmrap1.fhlbc.loc\mra\Al\QRMInput\DCMatrix.xlsx
\\prodfs.fhlbc.loc\softwarep\DP\HAUS\data\

'-- Hua 20160127 -- send the price adjustments to priceAdj.xlsx which linked to MPF5 db
'-- in MPF-Pricing-template.xlsm.MPF-Pricing Range("A2:BW250").Value = Workbooks(MPFPricingTemplate).Sheets("CarryAdjExpanded").Range("A3:BW251").Value
'-- Hua 20160201 Call MPF5.prepareDCpx to put the business date into priceAdj.xlsx and update carryAdjExpend tab in MPF-Pricing-template.xlsm
Sub updatePriceAdjFile()
    Dim appAccess As Object
    'get business date
    Set appAccess = CreateObject("Access.Application")
    appAccess.OpenCurrentDatabase Range("MPF5DB").Value, False
    appAccess.Run "MPF5.prepareDCpx"
    Set appAccess = Nothing
    
    MPFPricingTemplate = ActiveWorkbook.Name
	' sArchiveDir = "\\prodfs.fhlbc.loc\rcgroupp\MRO\Archive\" & Range("YYYY").Value & "\" & Range("YYYYMM").Value & "\" & Range("YYYYMMDD").Value & "\Pricing\" 
	sArchiveDir = "K:\MRA\MPF5\SQLServer\archive\" 
    ' update carryAdj
    sRange = Range("carryAdjExpSRange").Value
    tRange = Range("carryAdjExpTRange").Value
    Application.DisplayAlerts = False
    Application.Workbooks.Open Range("priceAdjFile").Value
    bookPxAdj = ActiveWorkbook.Name
    Sheets("carryAdj").Select
    Range(tRange).Value = Workbooks(MPFPricingTemplate).Sheets("CarryAdjExpanded").Range(sRange).Value

    ' update prodAdj
    sRange = Workbooks(MPFPricingTemplate).Sheets("Control").Range("prodAdjExpSRange").Value
    tRange = Workbooks(MPFPricingTemplate).Sheets("Control").Range("prodAdjExpTRange").Value
    Sheets("prodAdj").Select
    Range(tRange).Value = Workbooks(MPFPricingTemplate).Sheets("ProductAdj").Range(sRange).Value

    ' update TBApx
    sRange = Workbooks(MPFPricingTemplate).Sheets("Control").Range("TBApxExpSRange").Value
    tRange = Workbooks(MPFPricingTemplate).Sheets("Control").Range("TBApxExpTRange").Value
    Sheets("TBApx").Select
    Range(tRange).Value = Workbooks(MPFPricingTemplate).Sheets("TBA-pricing").Range(sRange).Value

    ' update FHLBadj
    sRange = Workbooks(MPFPricingTemplate).Sheets("Control").Range("FHLBAdjExpSRange").Value
    tRange = Workbooks(MPFPricingTemplate).Sheets("Control").Range("FHLBAdjExpTRange").Value
    Sheets("FHLBadj").Select
    Range(tRange).Value = Workbooks(MPFPricingTemplate).Sheets("FHLB Adjustment").Range(sRange).Value

    ' update MPFpx
    Workbooks(MPFPricingTemplate).Sheets("MPF-Pricing").Range("A6:A600, Q6:Q600, AE6:AE600, AU6:AU600").Copy
    Sheets("MPFprice").Range("A2").PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
    Sheets("MPFprice").Range("A1:F600").Copy
    Set NewBook = Application.Workbooks.Add
    With NewBook
        .Sheets("Sheet1").Range("A1").PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks:=False, Transpose:=False
        .SaveAs sArchiveDir & "SeasonedPricesMid.xls"
        .Close
    End With

    Workbooks(bookPxAdj).Save
    Workbooks(bookPxAdj).Close
	
    MsgBox "The price adjustments have been sent."
End Sub

Set NewBook = Workbooks.Add

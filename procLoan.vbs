
-- ODBC Connect Str=:ODBC;DSN=MRADB;Description=MRADB;Trusted_Connection=Yes;DATABASE=MRADB

Option Compare Database
'----------------------------------------- Hua 20151207
Private Sub getLoans_Click()
On Error GoTo err_handler
    dsTime = Now()
    With CurrentDb.QueryDefs("qPass")
    .SQL = "exec dbo.usp_getLoans"
    .ReturnsRecords = False
    .Execute
    End With
    deTime = Now()
    MsgBox "usp_getLoans Complete with " & DateDiff("s", dsTime, deTime) & " seconds.", vbInformation, " "
    Exit Sub

err_handler:
    deTime = Now()
    MsgBox "Error Number: " & Err.Number & " '" & Err.Description & "' was encountered during step '" & _
            "usp_getLoans '" & vbCrLf & "The Process had run " & _
            DateDiff("s", dsTime, deTime) & " seconds.", vbCritical, "Contact Application Support"
End Sub

'        "WHERE (BondCUSIP=""MPFForward"")"
'        "WHERE (Portfolio=""MPFForward"")"
'        "WHERE (BondCUSIP=""MPF"" Or BondCUSIP=""MPFForward"")"

'----------------------------------------- Hua 20151207
Private Sub setSeasonedCohorts_Click()
    With CurrentDb.QueryDefs("qPass")
    .SQL = "exec dbo.usp_setMPFCohorts"
    .ReturnsRecords = False
    .Execute
    End With
    MsgBox "usp_setMPFCohorts Complete", vbInformation, " "

End Sub

'----------------------------------------- Hua 20151220
Private Sub setSeasonedPx_Click()
On Error GoTo err_handler
    Dim sSQL, sStep As String
    dsTime = Now()
    sStep = "Setting Seasoned MPF price"
    DoCmd.SetWarnings False

    sSQL = "UPDATE dbo_aggMPF as a INNER JOIN MPFPrice as p ON a.CUSIP = p.CUSIP SET a.AggPrice = p.Price "
    DoCmd.RunSQL sSQL

    MsgBox sStep & " Complete", vbInformation, " "
    DoCmd.SetWarnings True
    Exit Sub
    
err_handler:
    deTime = Now()
    MsgBox "Error Number: " & Err.Number & " '" & Err.Description & "' was encountered during step '" & _
            "setSeasonedPx_Click '" & vbCrLf & "The Process had run " & _
            DateDiff("s", dsTime, deTime) & " seconds.", vbCritical, "Contact Application Support"

End Sub

'----------------------------------------- Hua 20151231 -- Not used
' Private Sub SeasonedToMiddleware_Click()
' On Error GoTo err_handler
'     Dim sSQL, sStep As String
'     sStep = "Send Seasoned MPF to MiddleWare"
'     dsTime = Now()
'     
'     DoCmd.SetWarnings False
'     sSQL = "DELETE * FROM dbo_Instrument_MBS_MPF " & _
'         "WHERE (BondCUSIP=""MPF"")"
'     DoCmd.RunSQL sSQL
'     DoCmd.OpenQuery "qryAppSeasonedToIMM", acNormal, acEdit
'     
'     sSQL = "DELETE * FROM dbo_Portfolio_Contents_MBS_MPF " & _
'         "WHERE (Portfolio=""MPF"")"
'     DoCmd.RunSQL sSQL
'     DoCmd.OpenQuery "qryAppSeasonedToPCMM", acNormal, acEdit
'     
'     MsgBox sStep & " Complete", vbInformation, " "
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


'----------------------------------------- Hua 20160106 -- replace SeasonedToMiddleware_Click() and DCtoMiddleware_click()
Private Sub outputToMiddleware_Click()
On Error GoTo err_handler
    Dim sSQL, sStep As String
    sStep = "Output to MiddleWare "
    dsTime = Now()
    
    DoCmd.SetWarnings False
    sSQL = "DELETE * FROM dbo_Instrument_MBS_MPF " & _
        "WHERE BondCUSIP in (""MPFForward"", ""MPF"") "
    DoCmd.RunSQL sSQL
    DoCmd.OpenQuery "qryAppDCtoIMM", acNormal, acEdit
    DoCmd.OpenQuery "qryAppSeasonedToIMM", acNormal, acEdit
    
    sSQL = "DELETE * FROM dbo_Portfolio_Contents_MBS_MPF " & _
        "WHERE Portfolio in (""MPFForward"", ""MPF"") "
    DoCmd.RunSQL sSQL
    DoCmd.OpenQuery "qryAppDCtoPCMM", acNormal, acEdit
    DoCmd.OpenQuery "qryAppSeasonedToPCMM", acNormal, acEdit
    
    MsgBox sStep & "Complete", vbInformation, " "
    DoCmd.SetWarnings True
    Exit Sub

err_handler:
    deTime = Now()
    MsgBox "Error Number: " & Err.Number & " '" & Err.Description & "' was encountered during step '" & _
            sStep & "'" & vbCrLf & "The Process had run " & _
            DateDiff("n", dsTime, deTime) & " minutes.", vbCritical, "Contact Application Support"
    DoCmd.SetWarnings True

End Sub

'=================================== Proc for the Fair Value loan pricing---- BEGIN
'---------- SetFVLoanPrice_click() -- get FairValue loans and set their prices
'----- Hua 20160107
Private Sub SetFVLoanPrice_Click()
On Error GoTo err_handler
    Dim sSQL, sStep As String
    dsTime = Now()
    sStep = "Get Fair Value Loans"
    With CurrentDb.QueryDefs("qPass")
    .SQL = "exec dbo.usp_getFVLoan"
    .ReturnsRecords = False
    .Execute
    End With
    
    sStep = "Set Fair Value Loan Price"
    DoCmd.SetWarnings False
    sSQL = "UPDATE dbo_fairValueLoan as f INNER JOIN MPFPrice as p ON f.CUSIP = p.CUSIP SET f.Price = p.Price "
    DoCmd.RunSQL sSQL
    DoCmd.SetWarnings True
    
    deTime = Now()
    MsgBox sStep & " Complete with " & DateDiff("s", dsTime, deTime) & " seconds.", vbInformation, " "
    Exit Sub

err_handler:
    deTime = Now()
    MsgBox "Error Number: " & Err.Number & " '" & Err.Description & "' was encountered during step '" & _
            sStep & "'" & vbCrLf & "The Process had run " & _
            DateDiff("s", dsTime, deTime) & " seconds.", vbCritical, "Contact Application Support"
End Sub



'======= Hua 20160108 ---- getMRODir: to get today's MRO daily report file dir == K:\MRO\Archive\yyyy\yyyy-mm\yyyy-mm-dd\
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


'-------- Hua 20160111
' Private Sub outputFVloanPx_Click()
' On Error GoTo ErrProc
'     Dim sFileName As String
'     Set fso = VBA.CreateObject("Scripting.FileSystemObject")
'     TPODSLoc = "K:\MRA\MPF5\SQLServer\"
'     ' TPODSLoc = "\\prodfs\SOFTWAREp\BANKAPPS\TPO\Poly\In\"
'     ' TPODSLoc = "\\testfs\softwaret\BANKAPPS\TPO\Poly\In\"
' 
'     ' sFileName = getMRODir() & "Pricing\Pricing-HFV-Loans.csv"
'     sFileName = TPODSLoc & "archive\Pricing-HFV-Loans.csv"
'     DoCmd.TransferText acExportDelim, , "dbo_uv_FVloanPrice", sFileName, True
'     fso.CopyFile sFileName, TPODSLoc, True
'     
'     MsgBox "Output FV loan Price: Done!"
'     Exit Sub
' ErrProc:
'     MsgBox "ERROR " & Err.Number & " - " & Err.Description, vbCritical, "outputFVloanPx_Click"
' 
' End Sub


'-------- Hua 20160203
Private Sub outputFVloanPx_Click()
On Error GoTo ErrProc
    Dim sSource As String
    Dim oXLApp As Excel.Application
    Dim xlWB As Excel.Workbook
    ' sSource = getMRODir() & "Pricing\Pricing-HFV-Loans.xls"
    ' sArchive = getMRODir() & "Pricing\Pricing-HFV-Loans.csv"
    sSource = "K:\MRA\MPF5\SQLServer\archive\Pricing-HFV-Loans.xls"
    sArchive = "K:\MRA\MPF5\SQLServer\archive\Pricing-HFV-Loans.csv"
    sTPODS = "K:\MRA\MPF5\SQLServer\Pricing-HFV-Loans.csv"
    ' TPODSLoc = "\\prodfs\SOFTWAREp\BANKAPPS\TPO\Poly\In\Pricing-HFV-Loans.csv"
    ' TPODSLoc = "\\testfs\softwaret\BANKAPPS\TPO\Poly\In\Pricing-HFV-Loans.csv"

    DoCmd.TransferSpreadsheet acExport, 9, "dbo_uv_FVloanPrice", sSource, True

    Set oXLApp = New Excel.Application
    oXLApp.Visible = False
    Set xlWB = oXLApp.Workbooks.Open(sSource)
    ' xlWB.SaveAs sArchive, xlCSVMSDOS
    xlWB.SaveAs sTPODS, xlCSVMSDOS
    xlWB.Close False
    
    MsgBox "Output FV loan Price: Done!"
    Exit Sub
ErrProc:
    MsgBox "ERROR " & Err.Number & " - " & Err.Description, vbCritical, "outputFVloanPx_Click"

End Sub

'----------------------------------------------------------------------------------------
Private Sub chkDCPrice_Click()
    DoCmd.OpenQuery "qryUnpricedDCs"
End Sub

Private Sub chkFVLoanPx_Click()
    DoCmd.OpenQuery "qryUnpricedFVLoans"
End Sub

Private Sub chkSeasonedPx_Click()
    DoCmd.OpenQuery "qryUnpricedCohorts"
End Sub

'---------------------------------------- send files to P:\Workspaces\Hedging\QRMMPF\; -- S:\Share\MRA\
'-- Hua 20160124
Private Sub SendFilesToFM_Click()
	sToday = Format(Now(), "yyyymmdd")
	' sDir = "P:\Workspaces\Hedging\QRMMPF\"
	sDir = "K:\MRA\MPF5\SQLServer\"
	
    DoCmd.TransferSpreadsheet acExport, 8, "qryAggDC", sDir & "tblForwardCommitmentPalmsSource" & sToday & ".xls"
    DoCmd.TransferSpreadsheet acExport, 8, "qryMPFOutput", sDir & "tblsecuritiesPalmsSource.xls"
    DoCmd.TransferSpreadsheet acExport, 8, "qryMPFOutput", sDir & "tblsecuritiesPalmsSource" & sToday & ".xls"

	MsgBox "SendFilesToFM complete")
End Sub

    DoCmd.TransferSpreadsheet acExport, 9, "qryBusinessDate", "H:\carryAdj.xlsx"  

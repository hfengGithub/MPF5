# MPF5
code for the SQL server version of MPF5

' Hua 20160120 get current daily file dir
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

' Hua 20151202 call proc usp_getDCs() to load DCs to MRADB
Private Sub getDCs_Click()
    With CurrentDb.QueryDefs("qPass")
    .SQL = "exec dbo.usp_getDCs"
    .ReturnsRecords = False
    .Execute
    End With
    MsgBox "Process Complete", vbInformation, " "
End Sub


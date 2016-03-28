;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
;CREATE TABLE PWMGR (pw BLOB, file VARCHAR(500))
Global Dim PasswordMgr.s(1)
Global iLastPasswordMgrItem.i

XIncludeFile "GFP_DRMHelpFunctions.pbi"; 2012-08-03 <PASSWORD FIX>




Procedure InitPasswordMgr(sDBFile.s)
  Protected *DB, iRow.i, Computername.s=Space(1000+1),sz=1000, ptr.i
  GetComputerName_(@Computername, @sz)
  *DB = DB_Open(sDBFile)
  If *DB
    DB_SetCryptionKey(*DB, GetSpecialFolder(#CSIDL_APPDATA)+Computername+"DB_ENC")
    DB_Query(*DB, "SELECT * FROM PWMGR")
    iRow = 0
    While DB_SelectRow(*DB, iRow):iRow + 1:Wend
    iLastPasswordMgrItem.i = iRow+2
    Global Dim PasswordMgr.s(iLastPasswordMgrItem)
    
    iRow = 0
    While DB_SelectRow(*DB, iRow)
      ptr=DB_GetAsBlobPointer(*DB, 0)
      If ptr
        PasswordMgr(iRow) = __PrintablePasswordToUnicode(PeekS(ptr, DB_GetAsBlobSize(*DB, 0), #PB_Ascii)) ;2012-08-03 <PASSWORD FIX>
      EndIf
      FreeMemory(ptr)
      iRow + 1
    Wend
    DB_EndQuery(*DB)
    DB_Close(*DB)
    
    PasswordMgr(iLastPasswordMgrItem-1) = "default"
  EndIf
  
EndProcedure


Procedure StorePassword(sDBFile.s ,sPassword.s, sFile.s)
  Protected *DB, Computername.s=Space(1000+1),sz=1000, i.i, sCodedPWD.s ; 2012-08-03 <PASSWORD FIX>
  Protected OpenDB=#True, PassowrdBuffer
  If sPassword
    For i=0 To iLastPasswordMgrItem
      If PasswordMgr(i)=sPassword
        ProcedureReturn #False
      EndIf
    Next
    
    GetComputerName_(@Computername, @sz)
    If *PLAYLISTDB:*DB=*PLAYLISTDB:OpenDB=#False:EndIf
    If OpenDB:*DB = DB_Open(sDBFile):EndIf
    If *DB
      DB_SetCryptionKey(*DB, GetSpecialFolder(#CSIDL_APPDATA)+Computername+"DB_ENC")
      If DB_Query(*DB,"INSERT INTO PWMGR (pw, file) VALUES (?,?)")
        
        ; 2012-08-03 <PASSWORD FIX>
        sCodedPWD = __GeneratePrintablePassword(sPassword); 2012-08-03 <PASSWORD FIX>
        PassowrdBuffer=__AnsiString(sCodedPWD) ; 2012-08-03 <PASSWORD FIX>
        If PassowrdBuffer
          DB_StoreAsBlob(*DB, 0, PassowrdBuffer, Len(sCodedPWD), #DB_BLOB_ENCRYPTED); 2012-08-03 <PASSWORD FIX>
          FreeMemory(PassowrdBuffer)
        EndIf
        
        DB_StoreAsString(*DB,1, sFile)
        DB_StoreRow(*DB)
        WriteLog("Save new Password!", #LOGLEVEL_DEBUG)
      EndIf
      DB_EndQuery(*DB)
      If OpenDB:DB_Close(*DB):EndIf
    EndIf
    iLastPasswordMgrItem+2
    ReDim PasswordMgr.s(iLastPasswordMgrItem)
    PasswordMgr.s(iLastPasswordMgrItem-1)=sPassword
  EndIf
EndProcedure

Procedure ClearPasswords(sDBFile.s)
  Protected *DB
  Protected OpenDB=#True
  If *PLAYLISTDB:*DB=*PLAYLISTDB:OpenDB=#False:EndIf
  If OpenDB:*DB = DB_Open(sDBFile):EndIf
  If *DB
    DB_UpdateSync(*DB,"DELETE FROM PWMGR")
    DB_Clear(*DB)
    If OpenDB:DB_Close(*DB):EndIf
    WriteLog("Delete all Passwords!", #LOGLEVEL_DEBUG) 
  EndIf
  sGlobalPassword=""
EndProcedure




; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 10
; FirstLine = 6
; Folding = -
; EnableXP
; EnableUser
; UseMainFile = Player.pb
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
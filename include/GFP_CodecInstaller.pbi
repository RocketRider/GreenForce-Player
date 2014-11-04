;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
;CREATE TABLE CODECS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(500), file VARCHAR(500), description VARCHAR(500), FOURCC VARCHAR(500), extensions VARCHAR(500), version INT, allusers INT)
EnableExplicit

Procedure CreateSubDirs(sPath.s)
  Protected i.i, sNewPath.s, oldpos
  sPath=ReplaceString(sPath, "/", "\")
  
  For i=1 To CountString(sPath, "\")
    oldpos=FindString(sPath, "\", oldpos+1)
    sNewPath = Mid(sPath, 1, oldpos)
    If FileSize(sNewPath)<>-2
      WriteLog("Create dir: "+sNewPath, #LOGLEVEL_DEBUG)
      CreateDirectory(sNewPath)
    EndIf
  Next
  
EndProcedure

Procedure IsCodecInstalled(sName.s)
  Protected iResult.i=#False, *DB
  *DB=DB_Open(sDataBaseFile)
  If *DB
    DB_Query(*DB, "SELECT * FROM CODECS WHERE name='"+sName+"'")
    If DB_SelectRow(*DB, 0)
      If DB_GetAsString(*DB, 1)
        iResult=#True
      EndIf  
    EndIf  
    DB_EndQuery(*DB)
    DB_Close(*DB)
  EndIf
  ProcedureReturn iResult
EndProcedure

Procedure.s RegisterErrorCode(RegisterErrorCode)
  Select RegisterErrorCode
    Case #ERR_INIT_FAILED:ProcedureReturn "INIT_FAILED"
    Case #ERR_DLLLOAD_FAILED:ProcedureReturn "DLLLOAD_FAILED"
    Case #ERR_FUNCTION_NOTFOUND:ProcedureReturn "FUNCTION_NOTFOUND"
    Case #ERR_FUNCTION_FAILED:ProcedureReturn "FUNCTION_FAILED"
    Case #ERR_UNEXPECTED:ProcedureReturn "INIT_FAILED"
  EndSelect 
EndProcedure  

Procedure InstallCodec_text(sText.s, sCodecfile.s, iUseRequester.i=#False, Message.i=#False)
  Protected sSettings.s, sFiles.s, RegisterErrorCode.i
  Protected sName.s, iVersion.i, iRegType.i, iAllUsers.i, sDescription.s, sFOURCC.s, sExtensions.s
  Protected sExecute.s, sRequesterText.s, RequesterResult=#False
  Protected i.i, sFile.s, sPath.s, sNewFile.s, bInstalled.i, *DB, sRegister.s, sExecinstall.s, sExecdeinstall.s
  sSettings = INI_GetGroupData(sText, "GFP-CODEC")
  sFiles = INI_GetGroupData(sText, "FILES")+Chr(13)
  sRegister = INI_GetGroupData(sText, "REGISTER")+Chr(13)
  sFiles=sFiles+Chr(13)+sRegister
  
  ;READ TAGS
  sName = INI_GetKeyData(sSettings, "name")
  sDescription = INI_GetKeyData(sSettings, "description")
  sFOURCC = INI_GetKeyData(sSettings, "fourcc")
  sExtensions = INI_GetKeyData(sSettings, "extensions")
  iVersion = Val(INI_GetKeyData(sSettings, "version"))
  iRegType = Val(INI_GetKeyData(sSettings, "regtype"));INSTALL = 0, DEINSTALL = 1
  iAllUsers = Val(INI_GetKeyData(sSettings, "allusers"))
  sExecinstall = INI_GetKeyData(sSettings, "execinstall")
  sExecdeinstall = INI_GetKeyData(sSettings, "execdeinstall")
  
  
  ;DEINSTALL REQUESTER
  If IsCodecInstalled(sName) And iRegType=0
    If Message
      sRequesterText=""
      If sName:sRequesterText+sName+" V"+Str(iVersion)+#CRLF$:EndIf
      If sDescription:sRequesterText+sDescription+#CRLF$:EndIf
      If Requester_Install_Codec(sRequesterText, #True):iRegType=1:RequesterResult=#True:EndIf
    EndIf
    WriteLog("Codec is allready installed: "+ReplaceString(sSettings,Chr(13), ", "), #LOGLEVEL_DEBUG)
    If iRegType=0
      ProcedureReturn #False
    EndIf  
  EndIf
  If IsCodecInstalled(sName)=#False And iRegType=1
    MessageRequester(Language(#L_ERROR), Language(#L_CANT_DEINSTALL_THE_CODEC), #MB_ICONERROR)
    WriteLog("Codec is not installed: "+ReplaceString(sSettings,Chr(13), ", "), #LOGLEVEL_DEBUG)
    ProcedureReturn #False
  EndIf  
  
  
  ;INSTALL REQUESTER
  If RequesterResult=#False
    sRequesterText=""
    If sName:sRequesterText+sName+" V"+Str(iVersion)+#CRLF$:EndIf
    If sDescription:sRequesterText+sDescription+#CRLF$:EndIf
    RequesterResult=Requester_Install_Codec(sRequesterText)
  EndIf
  
  If RequesterResult
    WriteLog("Install '"+sCodecfile+"' codec: "+ReplaceString(sSettings,Chr(13), ", "), #LOGLEVEL_DEBUG)
    
    
    CompilerIf #PB_editor_createexecutable
      sPath.s=GetPathPart(sDataBaseFile)+#GFP_CODEC_EXTENSION+"\"+sName+"\"
    CompilerElse
      sPath.s=GetSpecialFolder(#CSIDL_APPDATA)+"\GF-Player\"+#GFP_CODEC_EXTENSION+"\"+sName+"\"
    CompilerEndIf  
    
    
    ;COPY FILES
    If iRegType=0 ;Install
      For i=1 To CountString(sFiles, Chr(13))
        sFile.s = Trim( StringField(sFiles, i, Chr(13)))
        If sFile
          sNewFile=GetMediaPath(sCodecfile, sPath+sFile)
          sFile=GetMediaPath(sCodecfile, sFile)
          CreateSubDirs(GetPathPart(sNewFile))
          CopyFile(sFile, sNewFile)
        EndIf  
      Next
    EndIf
    
    bInstalled = #True
    For i=1 To CountString(sRegister, Chr(13))
      sFile.s = Trim( StringField(sRegister, i, Chr(13)))
      If sFile
        sNewFile=GetMediaPath(sCodecfile, sPath+sFile)
        If FileSize(sNewFile)>0
          WriteLog("Install dll "+sNewFile, #LOGLEVEL_DEBUG)
          RegisterErrorCode=SafeRegister(sNewFile, iAllUsers, iRegType)
          If RegisterErrorCode<>#S_OK
            bInstalled = #False
            WriteLog("Install dll failed: "+RegisterErrorCode(RegisterErrorCode)+" "+sNewFile, #LOGLEVEL_DEBUG)
          EndIf
        EndIf
      EndIf
    Next
    
    ;DELETE FILES
    If iRegType=1 ;Deinstall
      For i=1 To CountString(sFiles, Chr(13))
        sFile.s = Trim(StringField(sFiles, i, Chr(13)))
        If sFile
          sNewFile=GetMediaPath(sCodecfile, sPath+sFile)
          If DeleteFile(sNewFile)=#False
            WriteLog("Can't delete file: "+sNewFile, #LOGLEVEL_DEBUG)
            SecureDelete(sNewFile)
          EndIf  
        EndIf
      Next
    EndIf
    
    
    If iRegType=0 ;Install
      ;CREATE DB ITEM
      If bInstalled = #True
        *DB=DB_Open(sDataBaseFile)
        If *DB
          DB_UpdateSync(*DB, "INSERT INTO CODECS (name, file, description, FOURCC, extensions, version, allusers) VALUES ('"+sName+"', '"+sCodecfile+"', '"+sDescription+"', '"+sFOURCC+"', '"+sExtensions+"', '"+Str(iVersion)+"', '"+Str(iAllUsers)+"')")
          DB_Close(*DB)
        EndIf
        If sExecdeinstall
          RunProgram(sExecdeinstall)
        EndIf        
      Else
        WriteLog("Install codec failed! ", #LOGLEVEL_DEBUG)
        MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_INSTALL_CODEC), #MB_ICONERROR)
      EndIf  
      
    Else;Deinstall
      ;DELETE DB ITEM
      If bInstalled = #True
        *DB=DB_Open(sDataBaseFile)
        If *DB
          DB_UpdateSync(*DB, "DELETE FROM CODECS WHERE name='"+sName+"'")
          DB_Close(*DB)
        EndIf
        If sExecdeinstall
          RunProgram(sExecdeinstall)
        EndIf        
      Else
        WriteLog("Deinstall codec failed! ", #LOGLEVEL_DEBUG)
        MessageRequester(Language(#L_ERROR), Language(#L_CANT_DEINSTALL_THE_CODEC), #MB_ICONERROR)
      EndIf  
    EndIf  

    
  EndIf
  
EndProcedure

Procedure InstallCodec_mem(*mem, len, sCodecFile.s="")
  If sCodecFile="":sCodecFile="NO FILE":EndIf
  InstallCodec_text(INI_Catch(*mem, len), sCodecFile)
EndProcedure

Procedure InstallCodec(sFile.s, iUseRequester.i=#False, Message.i=#False)
  InstallCodec_text(INI_Load(sFile), sFile, iUseRequester, Message)
EndProcedure

Procedure InstallCodec_Requester(sFile.s, Message.i=#False)
  CompilerIf #USE_OEM_VERSION
    ;InstallCodec(sFile.s, #False)
  CompilerElse  
    InstallCodec(sFile.s, #True, Message)
  CompilerEndIf  
EndProcedure  

Procedure IsCodecFile(sFile.s)
  Protected iResult.i=#False
  If FileSize(sFile)>0
    If LCase(GetExtensionPart(sFile))=#GFP_CODEC_EXTENSION
      iResult=#True
    EndIf
  EndIf
  ProcedureReturn iResult
EndProcedure

;InstallCodec("testINI.txt")


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 204
; FirstLine = 107
; Folding = I0
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
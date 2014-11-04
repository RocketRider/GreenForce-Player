;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************
Global iLogWindow.i, iLogWindow_View.i
#MINIMAL_PLAYER_BUILD = 2150
Global Dim MenuLimitations.i(1)
Declare.s GetSpecialFolder(i) 

Import "Kernel32.lib";Hotfix
  GetProcAddress_(hMod.i, Name.p-ascii) As "_GetProcAddress@8"
EndImport

Enumeration
  #LOGLEVEL_NONE
  #LOGLEVEL_ERROR
  #LOGLEVEL_DEBUG
EndEnumeration




CompilerIf #USE_OEM_VERSION
  XIncludeFile "GFP_OEM.pbi"
CompilerElse
  #PLAYER_EXTENSION = "gfp" 
CompilerEndIf

Macro WriteLog(sText, iLevel = #LOGLEVEL_ERROR, UselogWindow=#True)
  PrintN(sText)
EndMacro


;Declare __AnsiString(str.s)
XIncludeFile "include\GFP_DRMHeaderV2_52_Unicode.pbi"
XIncludeFile "include\GFP_Mediadet.pbi"
XIncludeFile "include\GFP_MachineID.pbi"
XIncludeFile "include\GFP_exe-attachment4.pbi"
XIncludeFile "include\GFP_SpecialFolder.pbi"
EnableExplicit


Global sSource.s = "", sOutput.s = "", sPassword.s = "", sHint.s = "",  bEncrypt.i = #True, bReadHeader.i = #False
Global sTitle.s = "", sAlbum.s = "", sInterpreter.s = "", sComment.s, iSnapshot.i, bAllowRestore.i = #True , qLength.q = 0
Global sCoverFile.s = "", bAllowNoPassword.i = #False, qExpireDate.q = 0, sCodecLink.s="", sCodecName.s="", sMachineID.s, bStandalone.i = #False, bCopyProtection.i = #False, sMachineIDXorKey.s=""
;Global *header.DRM_HEADER_V2, sUserData.s = "", bIgnoreDRMRestore.i = #False
Global *header.DRM_HEADER_V2, sUserData.s = "", bIgnoreDRMRestore.i = #False
Global sGreenForcePlayer_Executable.s, sFile.s
Global sGlobalMachineIDXOrKey.s

Global NewList Source.s()



Procedure.s TestMachineIDPW(password.s, xorkeys.s)
  Protected masterKey.s="", res.i,testpw.s, i.i
  Protected xorKeyCount.i=Len(xorkeys)/32;32=MD5 len
  
  For i=0 To xorKeyCount-1
    sGlobalMachineIDXOrKey.s=Mid(xorkeys,i*32,32);32=MD5 len
    If password=""
      testpw=GetXorKey(sGlobalMachineIDXOrKey, MachineID(0))
      ;sGlobalMachineIDMasterKey = testpw
    Else
      testpw=password+"|"+GetXorKey(sGlobalMachineIDXOrKey, MachineID(0))
    EndIf  
    
    res = DRMV2Read_CheckPassword(*header, testpw.s)
    If res=#DRM_OK
      masterKey=testpw
      Break
    EndIf  
  Next
  
    
  ProcedureReturn masterKey
EndProcedure  

Procedure.s GetSecretString()
  Protected x= 36*7
  ProcedureReturn Chr(x/7)+Chr(x/7)+Chr(x/7)+Chr(64)+ Hex(15)
EndProcedure
Procedure.s ReadRegKey(OpenKey.l,SubKey.s,ValueName.s)
  Protected hKey.l, keyvalue.s, datasize.l
  hKey.l=0
  keyvalue.s=Space(255)
  datasize.l=255

  If RegOpenKeyEx_(OpenKey,SubKey,0,#KEY_READ,@hKey)
    keyvalue="NONE"
  Else
    If RegQueryValueEx_(hKey,ValueName,0,0,@keyvalue,@datasize)
      keyvalue="NONE"
    Else 
      keyvalue=Left(keyvalue,datasize-1)
    EndIf
    RegCloseKey_(hKey)
  EndIf

  ProcedureReturn keyvalue
EndProcedure


Procedure.i IsParamString(sStringToCheck.s, sParam.s)
  sStringToCheck.s = UCase(Trim(sStringToCheck))
  sParam.s = UCase(Trim(sParam))
  If sStringToCheck = "/" + sParam Or sStringToCheck = "\" + sParam Or sStringToCheck = "-" + sParam
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure
Procedure AnalyzeParams()
  Protected i.i, sParam.s, bPath.i, sMasterKey.s
  
  While i < CountProgramParameters()
    sParam.s = ProgramParameter(i)
    bPath = #True 
    If IsParamString(sParam, "DECRYPT")
      bPath = #False
      bEncrypt = #False
    EndIf
    
    If IsParamString(sParam, "ALLOWNOPASSWORD")
      bPath = #False
      bAllowNoPassword = #True
    EndIf
    
    If IsParamString(sParam, GetSecretString()) ; Entschluesselung auch dann erlauben, wenn dies eigentlich nicht erlaubt ist
      bPath = #False
      bIgnoreDRMRestore = #True
    EndIf
        
        
    If IsParamString(sParam, "READHEADER")
      bPath = #False
      bReadHeader = #True
    EndIf
       
    If IsParamString(sParam, "OUT")
      bPath = #False
      sOutput = ProgramParameter(i + 1)
      i+1
    EndIf
    
    If IsParamString(sParam, "PASSWORD")
      bPath = #False
      sPassword = ProgramParameter(i + 1)
      i+1
    EndIf  
    
    If IsParamString(sParam, "MACHINEID")
      bPath = #False
      sMachineID = ProgramParameter(i + 1)
      i+1
    EndIf   
    
    If IsParamString(sParam, "PLAYER")
      bPath = #False
      sGreenForcePlayer_Executable = ProgramParameter(i + 1)
      i+1
    EndIf       
    
    If IsParamString(sParam, "COPYPROTECTION")
      bPath = #False
      bCopyProtection = #True
    EndIf
    
    
    
    If IsParamString(sParam, "HINT")
      bPath = #False
      sHint = ProgramParameter(i + 1)
      i+1
    EndIf     
    
    If IsParamString(sParam, "TITLE")
      bPath = #False
      sTitle = ProgramParameter(i + 1)
      i+1
    EndIf  
     
    If IsParamString(sParam, "ALBUM")
      bPath = #False
      sAlbum = ProgramParameter(i + 1)
      i+1
    EndIf   
  
    If IsParamString(sParam, "INTERPRETER")
      bPath = #False
      sInterpreter = ProgramParameter(i + 1)
      i+1
    EndIf
    
    If IsParamString(sParam, "COMMENT")
      bPath = #False
      sComment = ProgramParameter(i + 1)
      i+1
    EndIf
    
    If IsParamString(sParam, "USERDATA")
      bPath = #False
      sUserData = ProgramParameter(i + 1)
      i+1
    EndIf
    
    If IsParamString(sParam, "LENGTH")
      bPath = #False
      qLength = Val(ProgramParameter(i + 1))
      i+1
    EndIf 
    
   
    If IsParamString(sParam, "DISALLOWRESTORE")
      bPath = #False
      bAllowRestore = #False
    EndIf 
    
    If IsParamString(sParam, "NOPASSWORD")
      bPath = #False
      sPassword = "default"
    EndIf     
    
    If IsParamString(sParam, "STANDALONE")
      bPath = #False
      bStandalone = #True
    EndIf 
    
    If IsParamString(sParam, "SNAPSHOT")
      bPath = #False
      iSnapshot = Val(ProgramParameter(i + 1))
      i+1
    EndIf 
    
    If IsParamString(sParam, "COVER")
      bPath = #False
      sCoverFile = ProgramParameter(i + 1)
      i+1
    EndIf    
    
    If IsParamString(sParam, "EXPIREDATE")
      bPath = #False
      qExpireDate = Val(ProgramParameter(i + 1))
      i+1
    EndIf    
    
    If IsParamString(sParam, "CODECNAME")
      bPath = #False
      sCodecName = ProgramParameter(i + 1)
      i+1
    EndIf  
    
    If IsParamString(sParam, "CODECLINK")
      bPath = #False
      sCodecLink = ProgramParameter(i + 1)
      i+1
    EndIf  
    
    If IsParamString(sParam, "HELP")
     sSource = ""
     ProcedureReturn 0
    EndIf
   
    If bPath = #True And Trim(sParam)<> ""
      sSource = sParam
      AddElement(Source())
      Source() = sSource
    EndIf
    i+1
  Wend
  If Trim(sOutput) = "" And bEncrypt = #True
    ;sOutput = GetPathPart(sSource)+ GetFilePart(sSource)
    If bStandalone=#True
      sOutput = Left(sSource, Len(sSource) - Len(GetExtensionPart(sSource)))+ "exe"
    Else  
      CompilerIf #USE_OEM_VERSION
        sOutput.s = sSource + "." + #PLAYER_EXTENSION  
      CompilerElse
        sOutput = Left(sSource, Len(sSource) - Len(GetExtensionPart(sSource)))+ #PLAYER_EXTENSION
      CompilerEndIf  
    EndIf
  EndIf
  
  sMachineIDXorKey.s=""
  If sMachineID<>"" And bEncrypt = #True
;     If sPassword=""
;       sPassword=sMachineID
;     Else  
;       sPassword=sPassword+"|"+sMachineID
;     EndIf  
    
    sMasterKey.s = GenerateRandomKey()
    sMachineIDXorKey = GetXorKey(sMasterKey, sMachineID)
    If sPassword=""
      sPassword=sMasterKey
    Else  
      sPassword=sPassword+"|"+sMasterKey
    EndIf  

  EndIf  
EndProcedure
Procedure.s QuoteString(str.s)
  ProcedureReturn Chr(34) + str + Chr(34)
EndProcedure
Procedure CB(p.q,s.q)
  Print(Chr(13)+"Progress: "+StrF(p*100/s, 1)+ "%"+Space(10))
  If Inkey() = Chr(27)
    PrintN("")
    PrintN("Aborted...")
    ProcedureReturn 1
  EndIf
EndProcedure
Procedure Quit(iExitCode = 0)
  ;FreeMemory(*header)
  ;PrintN("Debug: 1")
;   If *header;Can be also a Write header, so it will be closed before
;     ;PrintN("Debug: 2")
;     DRMV2Read_Free(*header)
;     *header = #Null
;   EndIf  
  ;PrintN("Debug: 3")
  ;CoUninitialize_()
  ;PrintN("Debug: 4")
  ;ExitProcess_(iExitCode)
  End iExitCode
EndProcedure

Procedure ProtectVideo(sSourceVideo.s, sOutputVideo.s, sPassword.s, sPasswordTip.s="", sTitle.s="", sAlbum.s="", sInterpret.s="", qLength.q=0, sComment.s="", fAspect.f=0, lCreationDate.l=0, bCanRemoveDRM.i=0, lSnapshotProtection.l=0, sCoverImage.s="", bAddPlayer.i=#False, qExpireDate.q=0, Codecname.s="", Codeclink.s="", CopyProtection.i=#False, sMachineIDXorKey.s="")
  Protected image.i, sTempFile.s, EncryptFileFaild.i, Result.i, *Header, stdData.DRM_STANDARD_DATA, secData.DRM_SECURITY_DATA
  If FileSize(sSourceVideo)>0
    
    If CopyProtection
      If sPassword=""
        sPassword=GetDriveSerialFromFile(sOutputVideo);+GetGraphicCardName()+GetCPUName()
        sPasswordTip=""
      EndIf
    EndIf  
    
;     InitDRMHeader(*GFP_DRM_HEADER, sSourceVideo)
;     SetDRMHeaderTitle(*GFP_DRM_HEADER, sTitle)
;     SetDRMHeaderAlbum(*GFP_DRM_HEADER, sAlbum)
;     SetDRMHeaderInterpreter(*GFP_DRM_HEADER, sInterpret)
;     SetDRMHeaderMediaLength(*GFP_DRM_HEADER, qLength)
;     SetDRMHeaderComment(*GFP_DRM_HEADER, sComment)
;     SetDRMHeaderPasswordTip(*GFP_DRM_HEADER, sPasswordTip)
;     If sCoverImage
;       image = LoadImage(#PB_Any, sCoverImage)
;       If IsImage(image)
;         SetDRMHeaderCover(*GFP_DRM_HEADER, image)
;         FreeImage(image)
;       EndIf
;     EndIf
;     
;     SetDRMHeaderAspect(*GFP_DRM_HEADER, fAspect)
;     SetDRMHeaderCreationDate(*GFP_DRM_HEADER, lCreationDate)
;     SetDRMHeaderCanRemoveDRM(*GFP_DRM_HEADER, bCanRemoveDRM)
;     SetDRMHeaderSnapshotProtection(*GFP_DRM_HEADER, lSnapshotProtection)
;     FinalizeDRMHeader(*GFP_DRM_HEADER, sPassword)

    *Header = DRMV2Write_Create(sPassword)
    If *Header
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_TITLE, sTitle, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_ALBUM, sAlbum, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_INTERPRETER, sInterpret, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_PASSWORDTIP, sPasswordTip, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_COMMENT, sComment, #DRMV2_BLOCK_COMMENTSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_ORGINALNAME, GetFilePart(sSourceVideo), #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_CODECLINK, Codeclink, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_CODECNAME, Codecname, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_PLAYERVERSION, Str(#MINIMAL_PLAYER_BUILD), #DRMV2_BLOCK_STRINGSIZE, #True)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_MACHINEID, sMachineIDXorKey, Len(sMachineIDXorKey), #False)
      
      
      If CopyProtection
        DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_PARTITION_ID, GetDriveSerialFromFile(sOutputVideo), #DRMV2_BLOCK_STRINGSIZE, #True);+GetGraphicCardName()+GetCPUName()
      EndIf  
      SecData\bCanRemoveDRM = bCanRemoveDRM
      SecData\lSnapshotProtection = lSnapshotProtection
      SecData\qExpireDate = qExpireDate
      
      stdData\fAspect = fAspect
      stdData\qLength = qLength
      DRMV2Write_AttachStandardData(*Header,  stdData.DRM_STANDARD_DATA)
      
      DRMV2Write_AttachBlock(*Header, #DRMV2_HEADER_MEDIA_SECURITYDATA, @secData, SizeOf(DRM_SECURITY_DATA), #True)
      
      If sCoverImage
        image = LoadImage(#PB_Any, sCoverImage)
        If IsImage(image)
          DRMV2Write_AttachCoverImage(*Header, image)
          FreeImage(image)
        EndIf
      EndIf  
      
      If bAddPlayer
        sTempFile=GetTemporaryDirectory()+"GFP_CRYPTFILE_"+Hex(Random($FFFF))+"."+GetExtensionPart(sSourceVideo)
        Result=EncryptFileV2(sSourceVideo, sTempFile, sPassword, *Header, @CB())
        If Result=#S_OK
          If CopyFile(sGreenForcePlayer_Executable, sOutputVideo)
            If BeginWriteEXEAttachments(sOutputVideo)
              AttachBigFileToEXEFile(sTempFile)
              EndWriteEXEAttachments()
            Else
              EncryptFileFaild=2
            EndIf
            
          Else
            EncryptFileFaild=1
          EndIf
          
          If EncryptFileFaild>0
            DeleteFile(sTempFile)
            WriteLog("ERROR: EncryptFile '" + sSourceVideo +  "' to '" + sOutputVideo + "' in ProtectVideo failed! ("+Str(EncryptFileFaild)+")")
            ;MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)  
            PrintN("Can't encrypt file!")
          EndIf  
        Else  
          WriteLog("ERROR: EncryptFile '" + sSourceVideo +  "' to '" + sOutputVideo + "' in ProtectVideo failed!")
          ;MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)   
          PrintN("Can't encrypt file!")
        EndIf
        ;If Result = #E_ABORT
          If FileSize(sTempFile)>0
            If Not DeleteFile(sTempFile)
              WriteLog("Can't delete temp file", #LOGLEVEL_DEBUG)
            EndIf  
          EndIf
        ;EndIf  
        ;CloseWindow(#WINDOW_WAIT_PROTECTVIDEO)
        
      Else  
        Result = EncryptFileV2(sSourceVideo, sOutputVideo, sPassword, *Header, @CB())
        If Result = #E_FAIL
          WriteLog("ERROR: EncryptFile '" + sSourceVideo +  "' to '" + sOutputVideo + "' in ProtectVideo failed!")
          ;MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)
          PrintN("Can't encrypt file!")
        EndIf
        If Result = #E_ABORT
          If FileSize(sOutputVideo)>0
            DeleteFile(sOutputVideo)
          EndIf
        EndIf  
        ;CloseWindow(#WINDOW_WAIT_PROTECTVIDEO)
      EndIf
      DRMV2Write_Free(*Header)
      *Header=#Null
    EndIf
  
    ProcedureReturn #True
  Else
    WriteLog("ERROR: File size of '" + sSourceVideo + "' is "+Str(FileSize(sSourceVideo)))
    ; MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)
    PrintN("Can't encrypt file!")
    ProcedureReturn #False
  EndIf
EndProcedure


Define iSize.i , iResult.i, sXorKeys.s, resKey.s
Define sPasswordMachine.s, res.i, usedMachineID.i


Procedure.s GetLastErrorString()
  Protected Err.s
  Err.s=Space(1000)
  FormatMessage_(#FORMAT_MESSAGE_FROM_SYSTEM|#FORMAT_MESSAGE_IGNORE_INSERTS,#Null,GetLastError_(),0,@Err.s,1000,#Null)
  Err.s = Trim(Err)
  Err.s = ReplaceString(Err, Chr(13), "")
  Err.s = ReplaceString(Err, Chr(10), "")
  Err.s + " (Error code: " + Str(GetLastError_()) + ")"
  ProcedureReturn Err
EndProcedure
Procedure ErrorHandler()
  Protected sText.s, LastErrorString.s
  LastErrorString.s=GetLastErrorString() 
  
  sText+"Source: "+Chr(9)+GetFilePart(ErrorFile())+#CRLF$
  sText+"Line: "+Chr(9)+Str(ErrorLine())+#CRLF$
  sText+"Desc: "+Chr(9)+ErrorMessage()+#CRLF$
  sText+"Code: "+Chr(9)+Str(ErrorCode())+#CRLF$
  sText+"Addr: "+Chr(9)+Str(ErrorAddress())+#CRLF$
  If ErrorCode() = #PB_OnError_InvalidMemory
    sText + "Target:  " + Chr(9) + Str(ErrorTargetAddress())+#CRLF$
  EndIf
  
  PrintN("Fatal error: "+#CRLF$+sText)
  End
EndProcedure




OnErrorCall(@ErrorHandler())


;Find Player exe
If FileSize("GreenForce-Player.exe")>0
  sGreenForcePlayer_Executable="GreenForce-Player.exe"
EndIf
If sGreenForcePlayer_Executable=""
  If FileSize("GFP.exe")>0
    sGreenForcePlayer_Executable="GFP.exe"
  EndIf
EndIf
If sGreenForcePlayer_Executable=""
  If FileSize("Player.exe")>0
    sGreenForcePlayer_Executable="Player.exe"
  EndIf
EndIf
If sGreenForcePlayer_Executable=""
  sFile.s=ReadRegKey(#HKEY_CURRENT_USER, "Software\Classes\GF-Player\shell\open\command", "")
  sFile=RemoveString(sFile, "%1")
  sFile=RemoveString(sFile, Chr(34))
  If FileSize(sFile)>0
    sGreenForcePlayer_Executable=sFile
  EndIf
EndIf

UsePNGImageDecoder()
UseJPEGImageDecoder()
UseJPEG2000ImageDecoder()
UseTIFFImageDecoder()
UseTGAImageDecoder()
CoInitialize_(0)
OpenConsole()
AnalyzeParams()


; If Date()>Date(2014,1,15,0,0,0)
;   bIgnoreDRMRestore.i = #False
; Else
;   bIgnoreDRMRestore.i = #True
; EndIf  

If Trim(sSource) = ""
  PrintN("GFP container file encryptor/decryptor (Version 1.6)")
  PrintN("====================================================")
  PrintN("No source file declared")
  PrintN("Parameters:")
  PrintN("/HELP             - shows this help text")
  PrintN("/DECRYPT          - decrypt the declared file (default is encrypt)")
  PrintN("/OUT              - output file")
  PrintN("/PASSWORD         - password used to encrypt/decrypt file")
  PrintN("/MACHINEID        - machine id used to encrypt/decrypt file")
  PrintN("/HINT             - hint for the password (only encryption)")
  PrintN("/TITLE            - title (only encryption)")
  PrintN("/ALBUM            - album (only encryption)")
  PrintN("/INTERPRETER      - interpreter (only encryption)")
  PrintN("/COMMENT          - comment (only encryption)")
  PrintN("/LENGTH           - length (only encryption)")
  PrintN("/DISALLOWRESTORE  - do not allow restore original file (only encryption)")
  PrintN("/SNAPSHOT         - snapshot protection 0,1,2 (only encryption)")
  PrintN("/COVER            - cover file as png,jpg,jp2,tiff,tga,bmp (only encryption)") 
  PrintN("/USERDATA         - user data (only encryption)")
  ;PrintN("/ALLOWNOPASSWORD  - allows encryption without password (only encryption)") ; Does not work correctly
  PrintN("/NOPASSWORD       - do not use a password")
  PrintN("/READHEADER       - show information of header")  
  PrintN("/EXPIREDATE       - sets the expire date of the file")  
  PrintN("/STANDALONE       - adds the player to the encypted file")  
  PrintN("/CODECNAME        - sets the name of the codec")  
  PrintN("/CODECLINK        - sets the link of the codec")
  PrintN("/COPYPROTECTION   - activates the copy protection")
  PrintN("/PLAYER           - sets the player executable")
  PrintN("Example:")
  PrintN(  GetFilePart(ProgramFilename()) +" "+Chr(34)+"test.avi"+Chr(34)+" /PASSWORD " + QuoteString("s3cret"))
  PrintN("")
  End 0
  
  
EndIf

iSize = FileSize(sSource)
If iSize < 0
  PrintN("ERROR: File " + QuoteString(sSource) + " cannot be found.")
  End #ERROR_FILE_NOT_FOUND
EndIf


If Trim(sPassword) = "" And bEncrypt
  If bAllowNoPassword = #False
    PrintN("ERROR: Password cannot be emtpy")
    Quit(#ERROR_PASSWORD_RESTRICTION)
  EndIf
EndIf

PrintN("")
Define CoverImage = #Null, iResult.i, MC.MEDIACHECK, sPartition_ID.s
Define stdData.DRM_STANDARD_DATA, secData.DRM_SECURITY_DATA
;*header = AllocateMemory(SizeOf(DRM_HEADER))


If bEncrypt And bReadHeader = #False
  *header = DRMV2Write_Create(sPassword)
  If *header = #Null
    Quit(#ERROR_OUTOFMEMORY)  
  EndIf
  If qLength <= 0
    CoInitialize_(#Null)
    DShow_CheckMedia(sSource.s, @MC)
    CoUninitialize_()
    qLength = MC\dLength
  EndIf    
  

  If ListSize(Source())=1
    ProtectVideo(sSource, sOutput, sPassword, sHint, sTitle, sAlbum, sInterpreter, qLength, sComment, 0, 0, bAllowRestore, iSnapshot, sCoverFile, bStandalone, qExpireDate, sCodecName, sCodecLink, bCopyProtection, sMachineIDXorKey.s)
  Else
     Define sTempOutput.s
    If bStandalone
      
      ForEach Source()
        sTempOutput = GetTemporaryDirectory()+"GFPCrypt_"+Str(ListIndex(Source()))+".dat"
        ProtectVideo(Source(), sTempOutput, sPassword, sHint, sTitle, sAlbum, sInterpreter, qLength, sComment, 0, 0, bAllowRestore, iSnapshot, sCoverFile, 0, qExpireDate, sCodecName, sCodecLink, bCopyProtection, sMachineIDXorKey.s)
      Next
      If CopyFile(sGreenForcePlayer_Executable, sOutput)
        If BeginWriteEXEAttachments(sOutput)
          ForEach Source()
            sTempOutput = GetTemporaryDirectory()+"GFPCrypt_"+Str(ListIndex(Source()))+".dat"
            AttachBigFileToEXEFile(sTempOutput)
            DeleteFile(sTempOutput)
          Next
          EndWriteEXEAttachments()
        Else
          PrintN("Failed! Errorcode: A1")
          iResult = #E_FAIL
        EndIf
        
      Else
        PrintN("Failed! Errorcode: A2 (no write rights)")
        iResult = #E_FAIL
      EndIf
      
      
      
    Else
      ForEach Source()
        CompilerIf #USE_OEM_VERSION
          sOutput.s = Source() + "." + #PLAYER_EXTENSION  
        CompilerElse
          sOutput = Left(Source(), Len(Source()) - Len(GetExtensionPart(Source())))+ #PLAYER_EXTENSION
        CompilerEndIf 
        
        If ProtectVideo(Source(), sOutput, sPassword, sHint, sTitle, sAlbum, sInterpreter, qLength, sComment, 0, 0, bAllowRestore, iSnapshot, sCoverFile, bStandalone, qExpireDate, sCodecName, sCodecLink, bCopyProtection)
          iResult = #S_OK
        Else
          iResult = #E_FAIL
        EndIf  
          
      Next
    EndIf
  EndIf
  
  


  If *header <> #Null
    DRMV2Write_Free(*header)
    *header=#Null
  EndIf  
    
  If iResult = #S_OK
    PrintN("")
    PrintN(QuoteString(sOutput) + " sucessfully created.")
  ElseIf iResult = #E_ABORT
    ;User arborted it...
    Quit(#ERROR_CANCEL_VIOLATION)
  Else
    PrintN("")
    PrintN("ERROR: failed to encrypt file "+ QuoteString(sSource))
    Quit(#ERROR_FILE_INVALID)   
  EndIf
  
  
  
Else
  
  
  
  ;iResult.i = ReadDRMHeader(sSource, *header, sPassword)
  *Header = DRMV2Read_ReadFromFile(sSource, sPassword, 0)
  iResult = DRMV2Read_GetLastReadResult(*Header)
  
  If iResult = #DRM_ERROR_INVALIDFILE
    PrintN("ERROR: file " + QuoteString(sSource) + " is invalid.")
    Quit(#ERROR_FILE_INVALID)
  EndIf
  If iResult = #DRM_ERROR_INVALDHEADER
    PrintN("ERROR: file " + QuoteString(sSource) + " has an invalid header.")
    Quit(#ERROR_FILE_INVALID)
  EndIf
  If *Header
    
    ;Machine ID:
    sXorKeys.s = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_MACHINEID)
    If iResult = #DRM_ERROR_INVALIDPASSWORD
      If sXorKeys<>""
        resKey = TestMachineIDPW(sPassword, sXorKeys)
        If resKey<>""
          res=#DRM_OK
          iResult = #DRM_OK
          usedMachineID.i=#True
          sPassword=resKey
          DRMV2Read_Free(*Header)
          *Header = #Null
          *Header = DRMV2Read_ReadFromFile(sSource, sPassword, 0)
          iResult = DRMV2Read_GetLastReadResult(*Header)          
        EndIf  
      EndIf
    EndIf
    If sXorKeys<>"" And usedMachineID.i=#False
      sPassword=""
      PrintN("ERROR: password is illegal for file " + QuoteString(sSource) + ".")
      Quit(#ERROR_INVALID_PASSWORD)
    EndIf  
    
    
    ;Copy Protection
    If iResult=#DRM_ERROR_INVALIDPASSWORD
      sPassword = GetDriveSerialFromFile(sSource)
      iResult = DRMV2Read_CheckPassword(*header, sPassword)
      If iResult=#DRM_OK
        DRMV2Read_Free(*Header)
        *Header = #Null
        *Header = DRMV2Read_ReadFromFile(sSource, sPassword, 0)
        iResult = DRMV2Read_GetLastReadResult(*Header)    
      EndIf   
    EndIf 
    sPartition_ID = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_PARTITION_ID)
    If sPartition_ID<>""
      If sPartition_ID<>GetDriveSerialFromFile(sSource);+GetGraphicCardName()+GetCPUName()
      PrintN("ERROR: decryption is illegal for file " + QuoteString(sSource) + ".")
      Quit(#ERROR_INVALID_DRIVE)
      EndIf  
    EndIf 
    
    
    DRMV2Read_GetBlockData(*header, #DRMV2_HEADER_MEDIA_STANDARDDATA, @stdData)
    DRMV2Read_GetBlockData(*header, #DRMV2_HEADER_MEDIA_SECURITYDATA, @secData)  
    ;Define *stdData.DRM_STANDARD_DATA
    If bReadHeader = #True
      Define sTop.s = "Showing content of " + QuoteString(sSource)
      PrintN(sTop)
      PrintN(ReplaceString(Space(Len(sTop))," ", "="))
  
      PrintN("Original file name: " + QuoteString(DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_ORGINALNAME)))
      PrintN("Password hint:      " + QuoteString(DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_PASSWORDTIP)))
      PrintN("Title:              " + QuoteString(DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_TITLE)))
      PrintN("Album:              " + QuoteString(DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_ALBUM)))
      PrintN("Interpreter:        " + QuoteString(DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_INTERPRETER)))
      PrintN("Comments:           " + QuoteString(DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_COMMENT)))
      PrintN("UserData:           " + QuoteString(DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_USERDATA)))
      PrintN("Codec name:         " + QuoteString(DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_CODECNAME)))
      PrintN("Codec link:         " + QuoteString(DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_CODECLINK)))
      
      PrintN("Snapshot protection:" + Str(secData\lSnapshotProtection))
      PrintN("Length:             " + Str(stdData\qLength))
      PrintN("Creation date:      " + FormatDate("%mm/%dd/%yyyy", stdData\lCreationDate))
      PrintN("Expire date:      " + FormatDate("%mm/%dd/%yyyy", secData\qExpireDate))
      
      
      
      PrintN("...")
      PrintN("")
    EndIf
  EndIf
  
  If bEncrypt = #False  ; really decrypt file
    If Trim(sOutput) = ""
      sOutput = GetPathPart(sSource) + DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_ORGINALNAME) ; 2012-08-03
      If FileSize(sOutput) >= 0
        PrintN("ERROR: File '"+sOutput +"' already exists!")
        Quit(#ERROR_FILE_EXISTS)
      EndIf  
      
    EndIf    
    If *header
      DRMV2Read_Free(*Header)
      *header=#Null
    EndIf  
    
    If iResult = #DRM_ERROR_INVALIDPASSWORD
      PrintN("ERROR: password is invalid for file " + QuoteString(sSource) + ".")
      Quit(#ERROR_INVALID_PASSWORD)
    EndIf
    If iResult = #DRM_ERROR_FAIL
      PrintN("ERROR: failed to decrypt file " + QuoteString(sSource) + ".")
      Quit(#ERROR_FILE_INVALID)
    EndIf
    Debug secData\lSnapshotProtection
    If secData\bCanRemoveDRM = #False And bIgnoreDRMRestore = #False
      PrintN("ERROR: it is not allowed to decrypt " + QuoteString(sSource) + ".")
      Quit(#ERROR_FILE_INVALID)    
    EndIf
    
    

    
    
    iResult = DecryptFileV2(sSource, sOutput, sPassword, @CB())
    If iResult = #S_OK
      PrintN("")
      PrintN(QuoteString(sOutput) + " sucessfully created.")
    ElseIf iResult = #E_ABORT
      ;User arborted it...
      Quit(#ERROR_CANCEL_VIOLATION)
    Else
      PrintN("")
      PrintN("ERROR: failed to decrypt file "+ QuoteString(sSource))
      Quit(#ERROR_FILE_INVALID)
    EndIf
  Else
    Quit(0)
  EndIf
  
EndIf

Quit(0)






; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 528
; FirstLine = 132
; Folding = jM-
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; UseIcon = data\Save.ico
; Executable = GFP-SDK_V1.06\GFPCrypt\GFPCrypt.exe
; EnableCompileCount = 107
; EnableBuildCount = 75
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 1,5,0,0
; VersionField1 = 1,5,0,0
; VersionField2 = RRSoftware
; VersionField3 = GFPCrypt
; VersionField4 = 1.50
; VersionField5 = 1.50
; VersionField6 = GFPCrypt for the GreenForce-Player
; VersionField7 = GFPCrypt
; VersionField8 = GFPCrypt
; VersionField9 = (c) 2011 RocketRider
; VersionField14 = http://GFP.RRSoftware.de
; VersionField16 = VFT_APP
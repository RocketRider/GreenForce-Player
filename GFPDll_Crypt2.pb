;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************

Global iLogWindow.i, iLogWindow_View.i
Global Dim MenuLimitations.i(1)

Enumeration
  #LOGLEVEL_NONE
  #LOGLEVEL_ERROR
  #LOGLEVEL_DEBUG
EndEnumeration

Macro WriteLog(sText, iLevel = #LOGLEVEL_ERROR, UselogWindow=#True)
  ;kein logging
EndMacro



Declare __AnsiString(str.s)
XIncludeFile "include\GFP_Cryption4_Unicode.pbi"
XIncludeFile "include\GFP_DRMHeaderV2_52_Unicode.pbi"
XIncludeFile "include\GFP_Mediadet.pbi"
XIncludeFile "include\GFP_MediaTags.pbi"
XIncludeFile "include\GFP_MachineID.pbi"
XIncludeFile "include\GFP_SpecialFolder.pbi"


UsePNGImageDecoder()
UsePNGImageEncoder()
UseJPEGImageDecoder()
UseJPEGImageEncoder()
UseJPEG2000ImageDecoder()
UseJPEG2000ImageEncoder()
UseTIFFImageDecoder()
UseTGAImageDecoder()



CompilerIf #USE_OEM_VERSION
  XIncludeFile "GFP_OEM.pbi"
CompilerElse
  #PLAYER_EXTENSION = "gfp" 
CompilerEndIf


#DRM_ENCRYPTION_VERSION_1_0 = 0
#DRM_ENCRYPTION_VERSION_2_0 = 1


#DRM_CONTENTPROTECTION_ON = 0
#DRM_CONTENTPROTECTION_OFF = 1
#DRM_CONTENTPROTECTION_EXTENDED = 2

Global sSource.s = "", sOutput.s = "", sPassword.s = "", sPasswordTip.s = "", sHint.s = "",  bEncrypt.i = #True
Global sTitle.s = "", sAlbum.s = "", sInterpreter.s = "", sComment.s, iSnapshot.i, bAllowRestore.i = #True , qLength.q = 0
Global sCoverFile.s = "", bAllowNoPassword.i = #False, sUserData.s = "", sCodecName.s="", sCodecLink.s=""
Global sOEMText.s = ""

Global *headerOld.DRM_HEADER

ProcedureDLL AttachProcess(Instanz)
  *headerOld = AllocateMemory(SizeOf(DRM_HEADER))  
EndProcedure

ProcedureDLL DetachProcess(Instanz)
  FreeMemory(*headerOld)  
EndProcedure

Procedure __CB(p.q,s.q)
  Protected iEvent
  ;  Print(Chr(13)+"Progress: "+StrF(p*100/s, 1)+ "%"+Space(10)) 
  If s > 0
    SetGadgetState(0, p * 1000 / s)
  EndIf
  
  Repeat
    iEvent = WindowEvent()
    If iEvent = #PB_Event_Gadget
      If EventGadget() = 1
        ProcedureReturn 1
      EndIf   
    EndIf
  Until iEvent = #WM_NULL
EndProcedure

Procedure __OpenProgressWindow()
  Protected sTitle.s = GetFilePart(ProgramFilename())
  sTitle = Left(sTitle, Len(sTitle) - Len(GetExtensionPart(sTitle)))
  If OpenWindow(0, 0, 0, 350, 21, sTitle, #PB_Window_BorderLess | #PB_Window_ScreenCentered)
    StickyWindow(0, 1) 
    ProgressBarGadget(0, 0, 0,  300, 21, 0, 1000)
    SetGadgetState(0,0)
    ButtonGadget(1,300,0,50,21, "Cancel")
  EndIf  
EndProcedure

Procedure __SetMediaHint(sHintText.s)
  sHint = sHintText
  ProcedureReturn #S_OK    
EndProcedure

Procedure __SetMediaInterpreter(sInterpreterText.s)
  sInterpreter = sInterpreterText
  ProcedureReturn #S_OK  
EndProcedure 

Procedure __SetMediaComment(sCommentText.s)
  sComment = sCommentText
  ProcedureReturn #S_OK  
EndProcedure

Procedure __SetMediaTitel(sTitleText.s)
  sTitle = sTitleText
  ProcedureReturn #S_OK  
EndProcedure

Procedure __SetMediaAlbum(sAlbumText.s)
  sAlbum = sAlbumText
  ProcedureReturn #S_OK  
EndProcedure

Procedure __SetMediaCodecName(sCodecNameText.s)
  sCodecName = sCodecNameText
  ProcedureReturn #S_OK  
EndProcedure

Procedure __SetMediaCodecLink(sCodecLinkText.s)
  sCodecLink = sCodecLinkText
  ProcedureReturn #S_OK  
EndProcedure

Procedure __SetMediaAllowRestore(bAllow)
  bAllowRestore = bAllow
  ProcedureReturn #S_OK  
EndProcedure

Procedure __SetMediaContentProtection(iSnapshotOption)
  iSnapshot = iSnapshotOption
  ProcedureReturn #S_OK  
EndProcedure
 
Procedure __SetMediaLength(qMediaLength.q)
  qLength = qMediaLength
  ProcedureReturn #S_OK  
EndProcedure

Procedure __SetMediaCoverFile(sCover.s)
  Protected image
  image = LoadImage(#PB_Any, sCover)
  If image
    sCoverFile = sCover
    ProcedureReturn #S_OK
  Else
    ProcedureReturn #E_FAIL
  EndIf  
EndProcedure

Procedure __SetMediaUserData(sFileUserData.s)
  sUserData = sFileUserData
  ProcedureReturn #S_OK  
EndProcedure

Procedure __SetMediaOemText(sNewOemText.s)
  sOEMText = sNewOemText
  ProcedureReturn #S_OK  
EndProcedure

Procedure __CheckMedia(sFile.s)
  Protected MC.MEDIACHECK
  LoadMetaFile(sFile.s)
  If MediaInfoData\qDuration>0
    ProcedureReturn #S_OK  
  EndIf  
  DShow_CheckMedia(sFile, @MC)
  If MC\dLength>0
    ProcedureReturn #S_OK  
  EndIf
  ProcedureReturn #E_FAIL
EndProcedure

Procedure __InitCheckMedia()
  InitMetaReader()
  ProcedureReturn #S_OK 
EndProcedure

Procedure __FreeCheckMedia()
  FreeMetaReader()
  ProcedureReturn #S_OK 
EndProcedure

Procedure __EncryptMediaFile(sSource.s, sOutput.s, sPassword.s, *cbCallback)
  Protected MC.MEDIACHECK, CoverImage, qTmpLen.q, iResult.i = #E_OUTOFMEMORY  
  If *headerOld
    If *cbCallback = -1
      *cbCallback = @__CB()
      __OpenProgressWindow()
    EndIf  
    
    If FileSize(sSource) > 0
      
      If Trim(sOutput) = ""
        ;sOutput = GetPathPart(sSource)+ GetFilePart(sSource)
        CompilerIf #USE_OEM_VERSION
          sOutput.s = sSource + "." + #PLAYER_EXTENSION
        CompilerElse
           sOutput = Left(sSource, Len(sSource) - Len(GetExtensionPart(sSource))) + #PLAYER_EXTENSION         
        CompilerEndIf
        
      EndIf  
      
      If sPassword <> ""
        InitDRMHeader(*headerOld, sSource)
        
        qTmpLen = qLength
        If qTmpLen <= 0
          CoInitialize_(#Null)
          DShow_CheckMedia(sSource.s, @MC)
          CoUninitialize_()
          qTmpLen = MC\dLength
        EndIf
        SetDRMHeaderMediaLength(*headerOld, qTmpLen)
        
        If sCoverFile <> ""
          CoverImage = LoadImage(#PB_Any, sCoverFile)
          If IsImage(CoverImage)
            ;PrintN("WARN: Cannot load cover file " + QuoteString(sCoverFile))      
          Else
            SetDRMHeaderCover(*headerOld, CoverImage)
            FreeImage(CoverImage)
          EndIf
        EndIf
        
        SetDRMHeaderTitle(*headerOld, sTitle)
        SetDRMHeaderAlbum(*headerOld, sAlbum)
        SetDRMHeaderInterpreter(*headerOld, sInterpreter)
        SetDRMHeaderComment(*headerOld, sComment)
        SetDRMHeaderUserData(*headerOld, sUserData)        
        
        *headerOld\bCanRemoveDRM = bAllowRestore
        *headerOld\lSnapshotProtection = iSnapshot
        FinalizeDRMHeader(*headerOld, sPassword)
        
        iResult = EncryptFile(sSource, sOutput, sPassword, *headerOld, *cbCallback)
        
      Else
        iResult = #DRM_ERROR_INVALIDPASSWORD
      EndIf
    Else
      iResult = #DRM_ERROR_INVALIDFILE
    EndIf
  
    If IsWindow(0)
      CloseWindow(0)  
    EndIf
  EndIf
  ProcedureReturn iResult
EndProcedure

Procedure __EncryptMediaFileV2(sSource.s, sOutput.s, sPassword.s, *cbCallback)
  Protected MC.MEDIACHECK, CoverImage, qTmpLen.q, iResult.i = #E_OUTOFMEMORY  
  Protected std.DRM_STANDARD_DATA, sec.DRM_SECURITY_DATA, *header
  
    If *cbCallback = -1
      *cbCallback = @__CB()
      __OpenProgressWindow()
    EndIf  
    
    If FileSize(sSource) > 0
      
      If Trim(sOutput) = ""
        CompilerIf #USE_OEM_VERSION
          sOutput.s = sSource + "." + #PLAYER_EXTENSION
        CompilerElse
           sOutput = Left(sSource, Len(sSource) - Len(GetExtensionPart(sSource))) + #PLAYER_EXTENSION         
        CompilerEndIf
        
      EndIf  
      
      If sPassword <> ""     
        
        *header = DRMV2Write_Create(sPassword, sOEMText)
               
        qTmpLen = qLength
        If qTmpLen <= 0
          CoInitialize_(#Null)
          DShow_CheckMedia(sSource.s, @MC)
          CoUninitialize_()
          qTmpLen = MC\dLength
        EndIf
        ;SetDRMHeaderMediaLength(*header, qTmpLen)       
        std\qLength = qTmpLen
        std\fAspect = 0.0
        
        sec\bCanRemoveDRM = bAllowRestore
        sec\lSnapshotProtection = iSnapshot

        DRMV2Write_AttachStandardData(*header, @std, #True)
        DRMV2Write_AttachBlock(*header, #DRMV2_HEADER_MEDIA_SECURITYDATA, @sec, SizeOf(DRM_SECURITY_DATA), #True)
        DRMV2Write_AttachString(*header, #DRMV2_HEADER_MEDIA_TITLE, sTitle,#DRMV2_BLOCK_STRINGSIZE)    
        DRMV2Write_AttachString(*header, #DRMV2_HEADER_MEDIA_ALBUM, sAlbum,#DRMV2_BLOCK_STRINGSIZE)
        DRMV2Write_AttachString(*header, #DRMV2_HEADER_MEDIA_ORGINALNAME, GetFilePart(sSource), #DRMV2_BLOCK_STRINGSIZE)
        DRMV2Write_AttachString(*header, #DRMV2_HEADER_MEDIA_PASSWORDTIP, sPasswordTip,#DRMV2_BLOCK_STRINGSIZE)
        DRMV2Write_AttachString(*header, #DRMV2_HEADER_MEDIA_INTERPRETER, sInterpreter,#DRMV2_BLOCK_STRINGSIZE)
        DRMV2Write_AttachString(*header, #DRMV2_HEADER_MEDIA_COMMENT, sComment,#DRMV2_BLOCK_COMMENTSIZE)
        DRMV2Write_AttachString(*header, #DRMV2_HEADER_MEDIA_USERDATA, sUserData,#DRMV2_BLOCK_COMMENTSIZE)
        DRMV2Write_AttachString(*header, #DRMV2_HEADER_MEDIA_CODECLINK, sCodecLink,#DRMV2_BLOCK_STRINGSIZE)
        DRMV2Write_AttachString(*header, #DRMV2_HEADER_MEDIA_CODECNAME, sCodecName,#DRMV2_BLOCK_STRINGSIZE)
        
        If sCoverFile <> ""
          CoverImage = LoadImage(#PB_Any, sCoverFile)
          If IsImage(CoverImage) = #Null
            ;PrintN("WARN: Cannot load cover file " + QuoteString(sCoverFile))      
          Else
            ;SetDRMHeaderCover(*header, CoverImage)
            DRMV2Write_AttachCoverImage(*header, CoverImage)
            FreeImage(CoverImage)
          EndIf
        EndIf       
               
        iResult = EncryptFileV2(sSource, sOutput, sPassword, *header, *cbCallback)
        DRMV2Write_Free(*header)
        
      Else
        iResult = #DRM_ERROR_INVALIDPASSWORD
      EndIf
    Else
      iResult = #DRM_ERROR_INVALIDFILE
    EndIf
  
    If IsWindow(0)
      CloseWindow(0)  
    EndIf
     
  ProcedureReturn iResult
EndProcedure

Procedure __DecryptMediaFile(sSource.s, sOutput.s, sPassword.s, *cbCallback)
  Protected iResult.i = #E_OUTOFMEMORY, iDRMResult
  
  If *headerOld
    iDRMResult.i = ReadDRMHeader(sSource, *headerOld, sPassword)
    
    If *cbCallback = -1
      *cbCallback = @__CB()
      __OpenProgressWindow()
    EndIf  
    
    If iDRMResult = #DRM_OK
      If *headerOld\bCanRemoveDRM = #True  
        If Trim(sOutput) = ""         
          sOutput = GetPathPart(sSource) + GetDRMOrgFileName(*headerOld)
        EndIf
        
        iResult = DecryptFile(sSource, sOutput, sPassword, *cbCallback)
        
      Else
        iResult = #E_ACCESSDENIED
      EndIf   
    EndIf
    
    If IsWindow(0)
      CloseWindow(0)  
    EndIf
  EndIf
  ProcedureReturn iResult
EndProcedure

Procedure __DecryptMediaFileV2(sSource.s, sOutput.s, sPassword.s, *cbCallback)
  Protected *header, iResult.i = #E_FAIL, iDRMResult.i, sec.DRM_SECURITY_DATA, sOrgFileName.s
    
  *header = DRMV2Read_ReadFromFile(sSource, sPassword)
  If *header
    iDRMResult = DRMV2Read_GetLastReadResult(*header)
    
    If *cbCallback = -1
      *cbCallback = @__CB()
      __OpenProgressWindow()
    EndIf  
    
    If iDRMResult = #DRM_OK
      
      If DRMV2Read_GetBlockData(*header, #DRMV2_HEADER_MEDIA_SECURITYDATA, @sec)
        
        If sec\bCanRemoveDRM = #True  
          If Trim(sOutput) = ""
            sOrgFileName = DRMV2Read_GetBlockString(*header, #DRMV2_HEADER_MEDIA_ORGINALNAME)
            If Trim(sOrgFileName) = ""
              sOrgFileName = GetFilePart(sSource) + "-restored"
            EndIf           
              sOutput = GetPathPart(sSource) + sOrgFileName  
          EndIf
          
          iResult = DecryptFileV2(sSource, sOutput, sPassword, *cbCallback)         
        Else
          iResult = #E_ACCESSDENIED
        EndIf
      Else
        iResult = #E_ACCESSDENIED        
      EndIf
    EndIf
    
    If IsWindow(0)
      CloseWindow(0)  
    EndIf
    DRMV2Read_Free(*header)  
  EndIf  
    
  ProcedureReturn iResult
EndProcedure


Procedure.s __GetMachineID(Version)
  ProcedureReturn MachineID(Version)
EndProcedure  



ProcedureDLL DecryptMediaFileA(*Source, *Output, *Password, Flags, *cbCallback)
  Protected sSource.s = "", sOutput.s = "", sPassword.s = ""
  If *Source
    sSource = PeekS(*Source, -1, #PB_Ascii) 
  EndIf 
  If *Output
    sOutput = PeekS(*Output, -1, #PB_Ascii) 
  EndIf  
  If *Password
    sPassword = PeekS(*Password, -1, #PB_Ascii) 
  EndIf    
  
  If Flags = #DRM_ENCRYPTION_VERSION_2_0
    ProcedureReturn __DecryptMediaFileV2(sSource, sOutput, sPassword, *cbCallback)
  Else
    ProcedureReturn __DecryptMediaFile(sSource, sOutput, sPassword, *cbCallback)    
  EndIf  
EndProcedure

ProcedureDLL DecryptMediaFileW(*Source, *Output, *Password, Flags, *cbCallback)
  Protected sSource.s = "", sOutput.s = "", sPassword.s = ""
  If *Source
    sSource = PeekS(*Source, -1, #PB_Unicode) 
  EndIf 
  If *Output
    sOutput = PeekS(*Output, -1, #PB_Unicode) 
  EndIf  
  If *Password
    sPassword = PeekS(*Password, -1, #PB_Unicode) 
  EndIf    
  
  If Flags = #DRM_ENCRYPTION_VERSION_2_0
    ProcedureReturn __DecryptMediaFileV2(sSource, sOutput, sPassword, *cbCallback)
  Else
    ProcedureReturn __DecryptMediaFile(sSource, sOutput, sPassword, *cbCallback)    
  EndIf  
EndProcedure

ProcedureDLL EncryptMediaFileW(*Source, *Output, *Password, Flags, *cbCallback)
  Protected sSource.s = "", sOutput.s = "", sPassword.s = ""
  If *Source
    sSource = PeekS(*Source, -1, #PB_Unicode) 
  EndIf 
  If *Output
    sOutput = PeekS(*Output, -1, #PB_Unicode) 
  EndIf  
  If *Password
    sPassword = PeekS(*Password, -1, #PB_Unicode) 
  EndIf    
  
  If Flags = #DRM_ENCRYPTION_VERSION_2_0
    ProcedureReturn __EncryptMediaFileV2(sSource, sOutput, sPassword, *cbCallback)
  Else
    ProcedureReturn __EncryptMediaFile(sSource, sOutput, sPassword, *cbCallback)    
  EndIf  
EndProcedure


ProcedureDLL EncryptMediaFileA(*Source, *Output, *Password, Flags, *cbCallback)
  Protected sSource.s = "", sOutput.s = "", sPassword.s = ""
  If *Source
    sSource = PeekS(*Source, -1, #PB_Ascii) 
  EndIf 
  If *Output
    sOutput = PeekS(*Output, -1, #PB_Ascii) 
  EndIf  
  If *Password
    sPassword = PeekS(*Password, -1, #PB_Ascii) 
  EndIf    
  
  If Flags = #DRM_ENCRYPTION_VERSION_2_0
    ProcedureReturn __EncryptMediaFileV2(sSource, sOutput, sPassword, *cbCallback)
  Else
    ProcedureReturn __EncryptMediaFile(sSource, sOutput, sPassword, *cbCallback)    
  EndIf  
EndProcedure

ProcedureDLL SetMediaHintA(*HintText)
  If *HintText
    ProcedureReturn __SetMediaHint(PeekS(*HintText, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf  
EndProcedure  

ProcedureDLL SetMediaHintW(*HintText)
  If *HintText  
    ProcedureReturn __SetMediaHint(PeekS(*HintText, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf    
EndProcedure 

ProcedureDLL SetMediaInterpreterA(*InterpreterText)
  If *InterpreterText
    ProcedureReturn __SetMediaInterpreter(PeekS(*InterpreterText, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure  

ProcedureDLL SetMediaInterpreterW(*InterpreterText)
  If *InterpreterText
    ProcedureReturn __SetMediaInterpreter(PeekS(*InterpreterText, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure

ProcedureDLL SetMediaCommentA(*CommentText)
  If *CommentText
    ProcedureReturn __SetMediaComment(PeekS(*CommentText, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure  

ProcedureDLL SetMediaCommentW(*CommentText)
  If *CommentText
    ProcedureReturn __SetMediaComment(PeekS(*CommentText, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure 

ProcedureDLL SetMediaTitelA(*TitleText)
  If *TitleText
    ProcedureReturn __SetMediaTitel(PeekS(*TitleText, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure  

ProcedureDLL SetMediaTiteltW(*TitleText)
  If *TitleText
    ProcedureReturn __SetMediaTitel(PeekS(*TitleText, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure 

ProcedureDLL SetMediaAlbumA(*AlbumText)
  If *AlbumText  
    ProcedureReturn __SetMediaAlbum(PeekS(*AlbumText, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure  

ProcedureDLL SetMediaAlbumW(*AlbumText)
  If *AlbumText
    ProcedureReturn __SetMediaAlbum(PeekS(*AlbumText, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure 

ProcedureDLL SetMediaAllowRestore(bAllow)
  ProcedureReturn __SetMediaAllowRestore(bAllow)
EndProcedure  

ProcedureDLL SetMediaContentProtection(iSnapshotOption)
  ProcedureReturn __SetMediaContentProtection(iSnapshotOption)
EndProcedure 

ProcedureDLL SetMediaLength(qMediaLength.q)
  ProcedureReturn __SetMediaLength(qMediaLength)
EndProcedure  

ProcedureDLL SetMediaCoverFileA(*Cover)
  If *Cover
    ProcedureReturn __SetMediaCoverFile(PeekS(*Cover, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure  

ProcedureDLL SetMediaCoverFileW(*Cover)
  If *Cover
    ProcedureReturn __SetMediaCoverFile(PeekS(*Cover, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure 


ProcedureDLL SetMediaUserDataA(*UserData)
  If *UserData 
    ProcedureReturn __SetMediaUserData(PeekS(*UserData, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure  

ProcedureDLL SetMediaUserDataW(*UserData)
  If *UserData
    ProcedureReturn __SetMediaUserData(PeekS(*UserData, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure 


ProcedureDLL SetMediaCodecNameA(*UserData)
  If *UserData 
    ProcedureReturn __SetMediaCodecName(PeekS(*UserData, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure  

ProcedureDLL SetMediaCodecNameW(*UserData)
  If *UserData
    ProcedureReturn __SetMediaCodecName(PeekS(*UserData, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure 


ProcedureDLL SetMediaCodecLinkA(*UserData)
  If *UserData 
    ProcedureReturn __SetMediaCodecLink(PeekS(*UserData, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure  

ProcedureDLL SetMediaCodecLinkW(*UserData)
  If *UserData
    ProcedureReturn __SetMediaCodecLink(PeekS(*UserData, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf      
EndProcedure 

ProcedureDLL SetMediaOemTextA(*OemText)
  If *OemText 
    ProcedureReturn __SetMediaOemText(PeekS(*OemText, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf   
EndProcedure  


ProcedureDLL SetMediaOemTextW(*OemText)
  If *OemText 
    ProcedureReturn __SetMediaOemText(PeekS(*OemText, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf   
EndProcedure  


ProcedureDLL CheckMediaA(*File)
  If *File 
    ProcedureReturn __CheckMedia(PeekS(*File, -1, #PB_Ascii))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf   
EndProcedure  

ProcedureDLL CheckMediaW(*File)
  If *File 
    ProcedureReturn __CheckMedia(PeekS(*File, -1, #PB_Unicode))
  Else
    ProcedureReturn #E_INVALIDARG
  EndIf   
EndProcedure  


ProcedureDLL InitCheckMedia()
  ProcedureReturn __InitCheckMedia() 
EndProcedure  

ProcedureDLL FreeCheckMedia()
  ProcedureReturn __FreeCheckMedia() 
EndProcedure  





ProcedureDLL.s GetMachineID(Version);W,A version benötigt?
  ProcedureReturn __GetMachineID(Version)
EndProcedure  




;Test: 
; 
; SetTitel("Title")
; SetInterpreter("Interpret")
; SetAlbum("Album")
; SetCoverFile("D:\Testbild_001.jpg")
; ; 
; Debug EncryptMediaFile("D:\sample.mp3", "", "test", -1)
; ;DecryptMediaFile("D:\sample.gfp", "", "test",-1)
; 




; IDE Options = PureBasic 5.11 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 280
; FirstLine = 260
; Folding = ----------
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; Executable = GFP-SDK_V1.06\GFPCrypt-DLL\GPFCrypt.dll
; EnableCompileCount = 41
; EnableBuildCount = 31
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 1,5,0,0
; VersionField1 = 1,5,0,0
; VersionField2 = RRSoftware
; VersionField3 = GFPCrypt DLL
; VersionField4 = 1.50
; VersionField5 = 1.50
; VersionField6 = GFPCrypt DLL
; VersionField7 = GFPCrypt DLL
; VersionField8 = GFPCrypt DLL
; VersionField9 = (c)2010-2011 RocketRider
; VersionField14 = http://GFP.RRSoftware.de
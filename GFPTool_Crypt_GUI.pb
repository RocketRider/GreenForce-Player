;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2016 RocketRider *******
;***************************************
#USE_PB_OGG = #True

#USE_VIRTUAL_FILE = #False
#USE_SWF_SUPPORT = #False
#USE_OEM_FLVPLAYER = #False
#USE_ENABLE_LAVFILTERS_DOWNLOAD = #False
#PLAYER_VERSION = "1.00"
#USE_DATABASE = #False
#WINDOW_MAIN = 0
#PANEL_HEIGHT = 0
#STATUSBAR_MAIN = 0
#MINIMAL_PLAYER_BUILD = 2150
#GFP_LANGUAGE_PLAYER = #False
Declare.s GetSpecialFolder(i) 
Global Dim MenuLimitations.i(1)


Enumeration
  #LOGLEVEL_NONE
  #LOGLEVEL_ERROR
  #LOGLEVEL_DEBUG
EndEnumeration
CompilerIf #USE_OEM_VERSION
  XIncludeFile "GFP_OEM.pbi"
CompilerElse
  #PLAYER_EXTENSION = "gfp"
  sAppDataFile.s = GetSpecialFolder(#CSIDL_APPDATA)+"\GF-Player\CryptSettings.dat"
  #GFP_PATTERN_MEDIA = "Media|*.gfp;*.gfp-codec;*.ogg;*.flac;*.m4a;*.aud;*.svx;*.voc;*.mka;*.3g2;*.3gp;*.asf;*.asx;*.avi;*.flv;*.mov;*.mp4;*.mpg;*.mpeg;*.rm;*.qt;*.swf;*.divx;*.vob;*.ts;*.ogm;*.m2ts;*.ogv;*.rmvb;*.tsp;*.ram;*.wmv;*.aac;*.aif;*.aiff;*.iff;*.m3u;*.mid;*.midi;*.mp1;*.mp2;*.mp3;*.mpa;*.ra;*.wav;*.wma;*.pls;*.xspf;*.mkv;*.m2v;*.m4v;|All Files (*.*)|*.*"
CompilerEndIf

Import "Kernel32.lib";Hotfix
  GetProcAddress_(hMod.i, Name.p-ascii) As "_GetProcAddress@8"
EndImport

    
Structure THUMBBUTTON
  dwMask.l
  iId.l
  iBitmap.l
  hIcon.i
  szTip.u[260]
  dwFlags.l
EndStructure

Interface ITaskbarList3 Extends ITaskbarList2
  SetProgressValue(hWnd, Completed.q, Total.q)
  SetProgressState(hWnd, Flags.l)
  RegisterTab(hWndTab, hWndMDI)
  UnregisterTab(hWndTab)
  SetTabOrder(hWndTab, hwndInsertBefore)
  SetTabActive(hWndTab, hWndMDI, dwReserved.l)
  ThumbBarAddButtons(hWnd, cButtons, *pButtons)
  ThumbBarUpdateButtons(hWnd, cButtons, *pButtons)
  ThumbBarSetImageList(hWnd, himl)
  SetOverlayIcon(hWnd, hIcon, pszDescription.s)
  SetThumbnailTooltip(hWnd, pszTip.s)
  SetThumbnailClip(hWnd, *prcClip.RECT)
EndInterface

  Structure MediaFile
    sFile.s
    Memory.i
    sRealFile.s
    iPlaying.i
    qOffset.q
    *StreamingFile
  EndStructure



Global iLogWindow.i, iLogWindow_View.i
Global iIsSoundMuted=#True, *PLAYLISTDB
Global iVideoRenderer=0, iAudioRenderer=0
Global *GFP_DRM_HEADER, *tb.ITaskbarList3
Global NewList CryptFiles.s()
Global sGreenForcePlayer_Executable.s, sFile.s
Global MediaFile.MediaFile
Global Design_Container_Size=82
Declare __AnsiString(str.s)
Define sDBFile.s, iDBFile

Macro WriteLog(sText, iLevel = #LOGLEVEL_ERROR, UselogWindow=#True)
  ;Nötig, da hier kein logging verwendet wird
;   If iLevel = #LOGLEVEL_ERROR
;     PrintN("ERROR: " + sText)  
;   EndIf 
;   If iLevel = #LOGLEVEL_DEBUG
;     PrintN(sText)  
;   EndIf
Debug sText
EndMacro
Procedure GetDPI()
  
EndProcedure  

XIncludeFile "include\GFP_PBCompatibility.pbi"
XIncludeFile "include\GFP_Language.pbi"
XIncludeFile "include\GFP_SkinGadget.pbi"
XIncludeFile "include\GFP_DRMHeaderV2_52_Unicode.pbi"
XIncludeFile "include\GFP_Mediadet.pbi"
XIncludeFile "include\GFP_DShow_140.pbi"
XIncludeFile "include\GFP_SoundEx.pbi"
XIncludeFile "include\GFP_MediaTags.pbi"
XIncludeFile "include\GFP_Flash12.pbi"
XIncludeFile "include\GFP_MediaLib.pbi"
XIncludeFile "include\GFP_filetype.pbi"
XIncludeFile "include\GFP_SpecialFolder.pbi"
XIncludeFile "include\GFP_ResMod37.pbi"
XIncludeFile "include\GFP_exe-attachment4.pbi"
XIncludeFile "include\GFP_ThumbButton.pbi"
XIncludeFile "include\GFP_MachineID.pbi"
EnableExplicit




Procedure DShow_GetMediaLenght(sFile.s);Nicht die Beste Lösung jede datei einzuladen!
  Protected iResult.i, iTestMediaObject.i, OldUsedOutputMediaLibrary.i
  iResult = 0
  OldUsedOutputMediaLibrary.i = UsedOutputMediaLibrary
  iTestMediaObject = LoadMedia(sFile, 0, iVideoRenderer,  iAudioRenderer)
  If iTestMediaObject
    iResult = MediaLength(iTestMediaObject)
    OnMediaEvent(iTestMediaObject)
    FreeMedia(iTestMediaObject)
    iTestMediaObject=0
  EndIf
  UsedOutputMediaLibrary.i = OldUsedOutputMediaLibrary.i
  ProcedureReturn iResult
EndProcedure
Procedure GetMediaLenght(sFile.s)
  Protected MC.MEDIACHECK
  CheckMedia(sFile, @MC)
  ;Debug MC\bUseable
  ;Debug 

  If MC\dLength<=0
    MC\dLength=DShow_GetMediaLenght(sFile.s)
  EndIf  
  ProcedureReturn MC\dLength*1000
EndProcedure
Procedure.s GetMediaPath(sPlaylist.s, sPlaytrack.s)
  
  If FindString(sPlaytrack, Chr(34), 1)
    ; Pfad scheint in Anführungszeichen zu sein
    sPlaytrack = Trim(sPlaytrack)
    If Left(sPlaytrack,1) = Chr(34) And Right(sPlaytrack,1) = Chr(34)
        sPlaytrack = Left(sPlaytrack, Len(sPlaytrack) - 1)
        sPlaytrack = Right(sPlaytrack, Len(sPlaytrack) - 1)       
    EndIf    
  EndIf
  
  If FindString(sPlaytrack, ":", 1) Or Left(sPlaytrack, 2) = "\\"  
    ; absoluter pfad, direkt zurückgeben
    ProcedureReturn sPlaytrack
  Else
    
    If Left(sPlaytrack, 1) = "\"
      sPlaytrack = Right(sPlaytrack, Len(sPlaytrack) - 1)
    EndIf    
    sPlaytrack = GetPathPart(sPlaylist) + sPlaytrack
    ProcedureReturn sPlaytrack
  EndIf
EndProcedure
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


Procedure ChangeIcon(iconFileName.s, exeFileName.s) 
  ResMod_RemoveIconGrp(exeFileName, "1")
  ResMod_AddIconGrp(exeFileName, iconFileName, "MAINICON")
EndProcedure


Procedure AddFile(sFile.s)
  Protected Add
  Protected sTitle.s, sAlbum.s, sInterpret.s, qLength.q, sCoverImage.s, lSnapshotProtection.l, lAllowRestore.l, sCoverFile.s, sGUID.s
  If sFile
    If FileSize(sFile)>0
      Add=#False
      If FindString("exe,mpvideo,jpg,png,bmp,tiff,jpeg,gfp,mmf,mme",LCase(GetExtensionPart(sFile)),1)=0
        Add=#True
        If GetGadgetState(5)=#PB_Checkbox_Checked 
          Add=#False
          If LCase(GetExtensionPart(sFile))="flv" Or GetMediaLenght(sFile)>0
            Add=#True
          EndIf
        EndIf
      EndIf
      
      If Add
        LoadMetaFile(sFile)
        
        sGUID.s=MediaInfoData\sGUID
        If sGUID
          sCoverFile.s=GetPathPart(sFile)+"\"+"AlbumArt_"+sGUID+"_Large.jpg"
          If FileSize(sCoverFile)>0
            sCoverImage=sCoverFile
          Else
            sCoverFile.s=GetPathPart(sFile)+"\"+"AlbumArt_"+sGUID+"_Large.png"
            If FileSize(sCoverFile)>0
              sCoverImage=sCoverFile
            EndIf
          EndIf
        EndIf
        
        AddGadgetItem(0, -1, sFile+Chr(10)+MediaInfoData\sAutor+Chr(10)+MediaInfoData\sAlbumTitle+Chr(10)+MediaInfoData\sTile+Chr(10)+sCoverImage)
      EndIf  
      
    EndIf  
  EndIf  
EndProcedure
Procedure AddFolder(sFolder.s)
  Protected iFolder
  If sFolder
    iFolder=ExamineDirectory(#PB_Any, sFolder, "*.*")  
    If iFolder
      While NextDirectoryEntry(iFolder)
        If DirectoryEntryType(iFolder) = #PB_DirectoryEntry_File
          AddFile(sFolder+DirectoryEntryName(iFolder))
        Else
          If DirectoryEntryName(iFolder)<>"." And DirectoryEntryName(iFolder)<>".." And DirectoryEntryName(iFolder)<>"..."
            AddFolder(sFolder+DirectoryEntryName(iFolder)+"\")
          EndIf  
        EndIf
      Wend
      FinishDirectory(iFolder)
    EndIf

    
    
  EndIf  
EndProcedure


Procedure ProcessAllEvents()
  Repeat
  Until WindowEvent()=0    
EndProcedure  

Global CryptFileCount.i, CryptFileState.i
Procedure ProtectVideo_CB(p.q,s.q)
  Protected state.d
  ;Debug "----"
  ;Debug CryptFileCount
  ;Debug CryptFileState
  ;Debug StrF(p/s)
  
  state=CryptFileState
  state=state/CryptFileCount+p/s/CryptFileCount
  state*1000
  ;Debug StrF(state)
  SetGadgetState(3, state)
  TB_SetProgressValue(*tb, WindowID(0), state, 1000)
  
  ProcessAllEvents()
EndProcedure  

Procedure ProtectVideo(sSourceVideo.s, sOutputVideo.s, sPassword.s, sPasswordTip.s="", sTitle.s="", sAlbum.s="", sInterpret.s="", qLength.q=0, sComment.s="", fAspect.f=0, lCreationDate.l=0, bCanRemoveDRM.i=0, lSnapshotProtection.l=0, sCoverImage.s="", bAddPlayer.i=#False, qExpireDate.q=0, Codecname.s="", Codeclink.s="", sMachineIDXorKey.s="")
  Protected image.i, sTempFile.s, EncryptFileFaild.i, Result.i, *Header, stdData.DRM_STANDARD_DATA, secData.DRM_SECURITY_DATA
  If FileSize(sSourceVideo)>0
    ;ProtectVideo_UpdateWindow()
    

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
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_MACHINEID, sMachineIDXorKey, Len(sMachineIDXorKey), #False)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_PLAYERVERSION, Str(#MINIMAL_PLAYER_BUILD), #DRMV2_BLOCK_STRINGSIZE, #True)
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

      Else  
        Result = EncryptFileV2(sSourceVideo, sOutputVideo, sPassword, *Header, @ProtectVideo_CB())
        If Result = #E_FAIL
          WriteLog("ERROR: EncryptFile '" + sSourceVideo +  "' to '" + sOutputVideo + "' in ProtectVideo failed!")
          ;MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)
        EndIf
        If Result = #E_ABORT
          If FileSize(sOutputVideo)>0
            DeleteFile(sOutputVideo)
          EndIf
        EndIf  
        ;CloseWindow(#WINDOW_WAIT_PROTECTVIDEO)
      EndIf
      DRMV2Write_Free(*Header)
    EndIf
  
    ProcedureReturn #True
  Else
    WriteLog("ERROR: File size of '" + sSourceVideo + "' is "+Str(FileSize(sSourceVideo)))
    ;MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)
    ProcedureReturn #False
  EndIf
EndProcedure


Procedure CryptFile(sFile.s, OutputFile.s, sPW.s, sTitle.s, sAlbum.s, sInterpret.s, sCoverImage.s, Codecname.s, Codeclink.s, sMachineIDXorKey.s)
  Protected qLength.q, lSnapshotProtection.l, lAllowRestore.l, sCoverFile.s, sGUID.s
  If sFile And OutputFile
    If FileSize(sFile)>0
      
      qLength.q=GetMediaLenght(sFile.s)
      
      lSnapshotProtection.l=GetGadgetState(12)
      If lSnapshotProtection=0:lSnapshotProtection=2:EndIf;Use Extended instead of Active!
      If lSnapshotProtection=2
        If GetGadgetState(21):lSnapshotProtection=0:EndIf
      EndIf  
      
      If GetGadgetState(13)=#PB_Checkbox_Checked
        lAllowRestore.l=#True
      EndIf  
      
      

      ProtectVideo(sFile, OutputFile, sPW, "", sTitle, sAlbum, sInterpret, qLength, "", 0, Date(), lAllowRestore, lSnapshotProtection, sCoverImage, #False, 0, Codecname.s, Codeclink.s, sMachineIDXorKey)
    EndIf  
  EndIf  
EndProcedure  
Procedure CryptAllFiles()
  Protected Count.f, i.i, sFile.s, OutputFile.s, sPW.s, state.f, sOutputPath.s, Error.i, sMachineIDXorKey.s, sMachineIDKey.s, sMasterKey.s
  Protected sTitle.s, sAlbum.s, sInterpret.s, sCoverImage.s, CreatePlayer.i, sOutputVideo.s, Codecname.s, Codeclink.s, Commands.s=""
  If GetGadgetText(9)
    count=CountGadgetItems(0)
    If count>0
      If IsGadget(16)
        CreatePlayer=GetGadgetState(16)
      EndIf 
      If CreatePlayer
        SetGadgetAttribute(3, #PB_ProgressBar_Maximum, 2000)
        sOutputPath=GetTemporaryDirectory()
      Else  
        SetGadgetAttribute(3, #PB_ProgressBar_Maximum, 1000)
        sOutputPath=GetGadgetText(9)
      EndIf
      
      
      Codecname.s = GetGadgetText(24)
      Codeclink.s = GetGadgetText(25)
      Commands.s = GetGadgetText(29)
      
      For i=0 To Count-1
        sFile.s=GetGadgetItemText(0, i, 0)
        sInterpret.s=GetGadgetItemText(0, i, 1)
        sAlbum.s=GetGadgetItemText(0, i, 2)
        sTitle.s=GetGadgetItemText(0, i, 3)
        sCoverImage.s=GetGadgetItemText(0, i, 4)
        
        OutputFile=GetFilePart(sFile)
        CompilerIf #USE_OEM_VERSION
          OutputFile=sOutputPath+OutputFile+"."+#PLAYER_EXTENSION
        CompilerElse  
          OutputFile=sOutputPath+Mid(OutputFile, 1, Len(OutputFile)-Len(GetExtensionPart(OutputFile)))+#PLAYER_EXTENSION
        CompilerEndIf
        


        sPW=GetGadgetText(7)
        sMachineIDKey.s=Trim(GetGadgetText(27))
        sMachineIDXorKey.s=""
        If sMachineIDKey.s<>""
          sMasterKey.s = GenerateRandomKey()
          sMachineIDXorKey = GetXorKey(sMasterKey, sMachineIDKey)
          
          If sPW=""
            sPW=sMasterKey
          Else  
            sPW=sPW+"|"+sMasterKey
          EndIf  
        EndIf  
          
        If sPW="":sPW="default":EndIf
        CryptFileCount = Count
        CryptFileState = i
        CryptFile(sFile, OutputFile, sPW, sTitle.s, sAlbum.s, sInterpret.s, sCoverImage.s, Codecname.s, Codeclink.s, sMachineIDXorKey)
        
        If CreatePlayer
          AddElement(CryptFiles())
          CryptFiles()=OutputFile
        EndIf  
          
        ProcessAllEvents()
        
      Next 
      SetGadgetState(3, 1000)
      
      If CreatePlayer
        sOutputVideo=GetGadgetText(9)+"\GFP_MultimediaPack.exe"
        If CopyFile(sGreenForcePlayer_Executable, sOutputVideo)
          
          ;FIRST CHANGE ICON AND THAN ADD MEDIA FILES!!!!
          If GetGadgetText(19);Change icon
            ChangeIcon(GetGadgetText(19), sOutputVideo)
          EndIf  
            
          If BeginWriteEXEAttachments(sOutputVideo)
            
            ForEach CryptFiles()
              count=ListIndex(CryptFiles())*1000
              state=1000+(count/ListSize(CryptFiles()))
              AttachBigFileToEXEFile(CryptFiles())
              DeleteFile(CryptFiles())
              ProcessAllEvents()
            Next
            
            ;FIRST ADD FILE THAN THE COMMANDLINE!
            If Commands.s<>""
              AttachMemoryToEXEFile("*COMMANDS*", @Commands, StringByteLength(Commands)+SizeOf(Character), #True)
            EndIf  
            
            EndWriteEXEAttachments()
          Else
            Error=#True
            MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)  
          EndIf
        Else
          Error=#True
          MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)
        EndIf
        
      EndIf  
      
      SetGadgetState(3, 2000)
      If Error=#False
        TB_SetProgressValue(*tb, WindowID(0), 1000, 1000)
        MessageRequester(Language(#L_INFO), Language(#L_ENCRYPTION_FINISHED), #MB_ICONINFORMATION)
        ClearGadgetItems(0)
        SetGadgetState(3, 0)
        TB_SetProgressValue(*tb, WindowID(0), 0, 1000)
      EndIf  
    Else
      MessageRequester(Language(#L_ERROR), Language(#L_A_VIDEO_HAS_TO_BE_SELECTED), #MB_ICONERROR)
    EndIf
  Else
    MessageRequester(Language(#L_ERROR), Language(#L_SELECT_AN_OUTPUT_FOLDER), #MB_ICONERROR)
  EndIf
EndProcedure  


Procedure ChangeInfo(item.i)
  Protected Event, GadgetY, sFile.s
  DisableWindow(0, #True)
  OpenWindow(1, 0, 0, 300, 225, "Video/Audio Encryption", #PB_Window_SystemMenu|#PB_Window_WindowCentered)
  
  GadgetY=5
  TextGadget(#PB_Any, 5, GadgetY, 100, 22, Language(#L_MEDIA)+":")
  GadgetY+22
  StringGadget(100, 5, GadgetY, 290, 20, GetGadgetItemText(0, item, 0), #PB_String_ReadOnly)
  GadgetY+30
          
  TextGadget(#PB_Any, 5, GadgetY+3, 100, 20, Language(#L_TITLE)+":")
  StringGadget(101, 85, GadgetY, 200, 20, GetGadgetItemText(0, item, 3))
  GadgetY+30
  TextGadget(#PB_Any, 5, GadgetY+3, 100, 20, Language(#L_ALBUM)+":")
  StringGadget(102, 85, GadgetY, 200, 20, GetGadgetItemText(0, item, 2))              
  GadgetY+30
  TextGadget(#PB_Any, 5, GadgetY+3, 100, 20, Language(#L_INTERPRET)+":")
  StringGadget(103, 85, GadgetY, 200, 20, GetGadgetItemText(0, item, 1))     
  GadgetY+30
  TextGadget(#PB_Any, 5, GadgetY+3, 100, 20, Language(#L_COVER_FILE)+":")
  GadgetY+20
  StringGadget(104, 5, GadgetY, 250, 20, GetGadgetItemText(0, item, 4))
  ButtonGadget(105, 260, GadgetY, 30, 20, "...")
  GadgetY+30
  ButtonGadget(106, 5, GadgetY, 70, 20, Language(#L_SAVE))
  ButtonGadget(107, 225, GadgetY, 70, 20, Language(#L_CANCEL))
  
  Repeat
    Event=WaitWindowEvent()
    If event=#PB_Event_Gadget
      Select EventGadget()
        Case 105  
          sFile.s=OpenFileRequester(Language(#L_COVER_FILE), "", "Image|*.jpg;*.jpeg;*.png;*.bmp;*.dib;*.tga;*.tiff;*.tif;*.jpf;*.jpx;*.jp2;*.j2c;*.j2k;*.jpc;|All Files (*.*)|*.*", 0)
          If sFile.s
            SetGadgetText(104, sFile)
          EndIf  
          
        Case 106;Save
          SetGadgetItemText(0, item, GetGadgetText(103),1)
          SetGadgetItemText(0, item, GetGadgetText(102),2)
          SetGadgetItemText(0, item, GetGadgetText(101),3)
          SetGadgetItemText(0, item, GetGadgetText(104),4)
          Event = #PB_Event_CloseWindow
          
        Case 107
          Event = #PB_Event_CloseWindow
      EndSelect    
    EndIf  
  Until Event = #PB_Event_CloseWindow
  
  CloseWindow(1)
  DisableWindow(0, #False)
  SetActiveWindow(0)
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


Define Event.i, sPath.s,FileName$, iMediaMainObject.i,Files$, Count, i.i, sPassword.s,OutputFolder.s

If ReadFile(0, sAppDataFile)
  sPassword.s=ReadString(0)
  OutputFolder.s=ReadString(0)
  CloseFile(0)
EndIf


sDBFile.s = GetPathPart(sAppDataFile)+"lngDB.sqlite"
CreateDirectory(GetPathPart(sDBFile.s))
iDBFile = CreateFile(#PB_Any, sDBFile.s)
If iDBFile
  WriteData(iDBFile, ?DS_SQLDataBase, ?DS_EndSQLDataBase-?DS_SQLDataBase)
  CloseFile(iDBFile)
EndIf  
If InitLanguage(sDBFile.s, GetOSLanguage())=#False
  MessageRequester("Error","Language database is incorrect!")
  End
EndIf  
  



OpenWindow(0, 0, 0, 550, 570, "Video/Audio encryption V1.6", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
ListIconGadget(0, 5, 40, 540, 300, Language(#L_FILE), 140, #PB_ListIcon_FullRowSelect)
AddGadgetColumn(0, 1, Language(#L_INTERPRET), 100)
AddGadgetColumn(0, 2, Language(#L_ALBUM), 100)
AddGadgetColumn(0, 3, Language(#L_TITLE), 100)
AddGadgetColumn(0, 4, Language(#L_COVER), 95)

ButtonGadget(1, 5, 5, 120, 25, Language(#L_ADD_TRACK))
ButtonGadget(2, 130, 5, 120, 25, Language(#L_ADD_FOLDER))
ProgressBarGadget(3, 5, 345, 540, 20, 0, 1000, #PB_ProgressBar_Smooth)
TintGadget(3, 10000, 10000, 10000, 0, -100, 0, 0, #False)

ButtonGadget(4, 445, 5, 100, 25, Language(#L_ENCRYPT))
CheckBoxGadget(5, 255, 5, 190, 25, Language(#L_ADD_ONLY_LOADABLE_FILES));"Add only loadable files"

CompilerIf #USE_OEM_VERSION = #False
  SetGadgetState(5, #True)
CompilerEndIf


CompilerIf #USE_OEM_VERSION
  TextGadget(6, 5, 382, 100, 22, Language(#L_ENCRYPTION_KEY)+":")
  If sPassword=""
    Define Computername.s=Space(1000+1), sz=1000, key.s, MD5.s
    GetComputerName_(@Computername, @sz)
    Key=GetSpecialFolder(#CSIDL_APPDATA)+Trim(Computername)+"_ENC"
    MD5=MD5Fingerprint(@Key, StringByteLength(Key))+Mid(Hex(CRC32Fingerprint(@Key, StringByteLength(Key))&$FFFFFFFF)+"A5F1",1, 4)
  Else
    MD5=sPassword
  EndIf
  StringGadget(7, 110, 380, 400, 22, MD5)
CompilerElse
  TextGadget(6, 5, 382, 100, 22, Language(#L_PASSWORD)+":")
  StringGadget(7, 110, 380, 100, 22, "", #PB_String_Password)
  TextGadget(26, 215, 382, 100, 22, Language(#L_MACHINE_ID)+":")
  StringGadget(27, 310, 380, 200, 22, "")  
CompilerEndIf

TextGadget(8, 5, 407, 100, 22, Language(#L_OUTPUT_FOLDER)+":")
StringGadget(9, 110, 405, 400, 22, OutputFolder)
ButtonGadget(10, 515, 405, 30, 22, "...")

TextGadget(11, 5, 437, 150, 18, Language(#L_SNAPSHOTPROTECTION)+":")
ComboBoxGadget(12, 5, 455, 100, 20)
AddGadgetItem(12, -1, Language(#L_ACTIVE))
AddGadgetItem(12, -1, Language(#L_INACTIVE))
SetGadgetState(12, 0)
CheckBoxGadget(13, 120, 450, 300, 25, Language(#L_ALLOWUNPROTECT))
CheckBoxGadget(21, 120, 430, 300, 25, Language(#L_NOT_FORCE_SCREENSHOT_PROTECTION))
SetGadgetState(21, 1)

TextGadget(22, 5, 513, 150, 18, Language(#L_USED_CODEC)+":")
TextGadget(23, 5, 540-3, 100, 26, Language(#L_CODEC_DOWNLOAD_LINK)+":")
StringGadget(24, 110, 510, 400, 22, "")
StringGadget(25, 110, 540, 400, 22, "")

UsePNGImageDecoder()
ImageGadget(14, 550-26, 570-26, 25, 25, ImageID(CatchImage(#PB_Any, ?Help)))

CompilerIf #USE_OEM_VERSION=#False
  CheckBoxGadget(16, 120, 480, 250, 25, Language(#L_INCLUDE_ALL_FILES_IN_ONE_PLAYER))
  FrameGadget(17, 2, 570, 540, 120, Language(#L_OPTIONS)) 
  TextGadget(18, 15, 590, 100, 20, Language(#L_ICON)+":")
  StringGadget(19, 15, 610, 480, 20, "")
  ButtonGadget(20, 500, 610, 30, 20, "...")
  
  TextGadget(28, 15, 635, 100, 20, Language(#L_PARAMENTER)+":")
  StringGadget(29, 15, 655, 480, 20, "")
  
  HideGadget(17, #True)
  HideGadget(18, #True)
  HideGadget(19, #True)
  HideGadget(20, #True)
  HideGadget(28, #True)
  HideGadget(29, #True)
  
CompilerEndIf  

EnableGadgetDrop(0,    #PB_Drop_Files,   #PB_Drag_Link)

CompilerIf #USE_OEM_VERSION
  HideGadget(5, #True);Könnte mit FLV dateien probleme geben, wenn kein codec installiert ist.
  HideGadget(13, #True)
CompilerEndIf





UsePNGImageDecoder()
UsePNGImageEncoder()
UseJPEGImageDecoder()
UseJPEGImageEncoder()
UseJPEG2000ImageDecoder()
UseJPEG2000ImageEncoder()
UseTIFFImageDecoder() 
UseTGAImageDecoder() 
InitMetaReader()
InitMedia()
iMediaMainObject.i = __CreateMediaObject(#False)


*GFP_DRM_HEADER=AllocateMemory(SizeOf(DRM_HEADER))
If *GFP_DRM_HEADER=#Null
  MessageRequester("Error", "Out of memory!", #MB_ICONERROR)
  End
EndIf

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

CoInitialize_(0)

*tb.ITaskbarList3 = TB_Create()
TB_SetProgressState(*tb, WindowID(0), #TBPF_Normal)

Repeat
  Event=WaitWindowEvent()
  If event=#WM_KEYDOWN And EventGadget()=0
    If EventwParam()=#VK_DELETE
      RemoveGadgetItem(0, GetGadgetState(0))
    EndIf
  EndIf  
    
  If Event=#PB_Event_Gadget Or Event = #PB_Event_GadgetDrop
    Select EventGadget()
      Case 12  
        If GetGadgetState(12)=0
          DisableGadget(21, #False)
        Else  
          DisableGadget(21, #True)
        EndIf  
        
      Case 10:
        sPath.s=PathRequester(Language(#L_OUTPUT_FOLDER),"")
        If sPath
          SetGadgetText(9, sPath)
        EndIf  
        
      Case 1:
        FileName$=OpenFileRequester(Language(#L_SELECT_A_LOAD_FILE), "", #GFP_PATTERN_MEDIA, 0, #PB_Requester_MultiSelection)
        While FileName$
          AddFile(FileName$)
          FileName$ = NextSelectedFileName() 
        Wend 
        
      Case 2:
        AddFolder(PathRequester(Language(#L_ADD_FOLDER),""))
        
      Case 0:  
        If Event = #PB_Event_GadgetDrop
          Files$ = EventDropFiles()
          Count  = CountString(Files$, Chr(10)) + 1
          For i = 1 To Count
            AddFile(StringField(Files$, i, Chr(10)))
          Next 
        EndIf  
        If EventType() = #PB_EventType_LeftDoubleClick
          ChangeInfo(GetGadgetState(0))
        EndIf  
          
      Case 4:
        DisableGadget(4, #True)
        DisableGadget(1, #True)
        DisableGadget(2, #True)
        CryptAllFiles()
        DisableGadget(4, #False)
        DisableGadget(1, #False)
        DisableGadget(2, #False)
        
      
      Case 14:
        If EventType()=#PB_EventType_LeftClick Or EventType()=#PB_EventType_LeftDoubleClick
          CompilerIf #USE_OEM_VERSION
            RunProgram(#OEM_ENCRYPTTOOL_HELP)    
          CompilerElse
            RunProgram("http://GFP.RRSoftware.de")
          CompilerEndIf
        EndIf
      
      
    Case 16
      ;CHANGE OUTPUT FOLDER TO OUTPUT FILE
      
      If sGreenForcePlayer_Executable="" And FileSize(sGreenForcePlayer_Executable)>0
        MessageRequester("Error", "Can't find GreenForce-Player executable, please select the newest executable. (Min version 1.05)", #MB_ICONERROR)
        sGreenForcePlayer_Executable=OpenFileRequester("Select GreenForce-Player", "", "Executable|*.exe", 0)
      EndIf  
      If sGreenForcePlayer_Executable="" And FileSize(sGreenForcePlayer_Executable)>0
        SetGadgetState(16, #False)
      EndIf
      
      If GetGadgetState(16)
        SetGadgetState(13, #False)
        DisableGadget(13, #True)
        ResizeWindow(0, #PB_Ignore, #PB_Ignore, #PB_Ignore, 700)
        HideGadget(17, #False)
        HideGadget(18, #False)
        HideGadget(19, #False)
        HideGadget(20, #False)
        HideGadget(28, #False)
        HideGadget(29, #False)
      Else
        DisableGadget(13, #False)
        ResizeWindow(0, #PB_Ignore, #PB_Ignore, #PB_Ignore, 570)
        HideGadget(17, #True)
        HideGadget(18, #True)
        HideGadget(19, #True)
        HideGadget(20, #True)
        HideGadget(28, #True)
        HideGadget(29, #True)
      EndIf  
      
    Case 20
      sFile.s=OpenFileRequester(Language(#L_ICON), "", "*.ico|*.ico", 0)
      If sFile
        SetGadgetText(19, sFile)
      EndIf  
        
    EndSelect
  EndIf
Until Event=#PB_Event_CloseWindow





CreateDirectory(GetPathPart(sAppDataFile))
If CreateFile(0, sAppDataFile)
  CompilerIf #USE_OEM_VERSION
    WriteStringN(0, GetGadgetText(7))
  CompilerElse
    WriteStringN(0, "NONE")
  CompilerEndIf
  WriteStringN(0, GetGadgetText(9))
  CloseFile(0)
EndIf

TB_Free(*tb)

CoUninitialize_()


  DataSection
    CompilerIf #USE_OEM_VERSION
      Help: 
      IncludeBinary "oem-data\Crypt\help.png"
    CompilerElse
      Help: 
      IncludeBinary "data\help.png"
    CompilerEndIf

    DS_SQLDataBase:
      CompilerIf #USE_OEM_VERSION
        IncludeBinary "oem-data\data.sqlite"
      CompilerElse
        IncludeBinary "data\data.sqlite"
      CompilerEndIf  
    DS_EndSQLDataBase:
EndDataSection
; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 649
; FirstLine = 468
; Folding = AB4--
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; UseIcon = data\Save.ico
; Executable = GFP-SDK_V1.06\GFPCrypt-GUI\GFPCrypt-GUI.exe
; EnableCompileCount = 471
; EnableBuildCount = 85
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 1,6,0,0
; VersionField1 = 1,6,0,0
; VersionField3 = GFPCrypt GUI
; VersionField4 = 1.60
; VersionField5 = 1.60
; VersionField6 = GFPCrypt GUI
; VersionField7 = GFPCrypt GUI
; VersionField9 = (c) 2011 RocketRider
; VersionField13 = Support@GFP.RRSoftware.de
; VersionField14 = http://GFP.RRSoftware.de
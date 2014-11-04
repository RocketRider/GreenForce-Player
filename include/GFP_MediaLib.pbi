;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

Enumeration
  #MEDIALIBRARY_DSHOW
  #MEDIALIBRARY_PBSND
  #MEDIALIBRARY_FLASH
EndEnumeration


Global UsedOutputMediaLibrary.i
Global ML_MediaVolume.i
Global ML_MediaPlaying.i
Global ML_MediaPan.i


Procedure InitMedia()
  Protected Result
  Result = InitSound()
  If Result
    UseOGGSoundDecoder()
    UseFLACSoundDecoder()
  EndIf
  Result = DShow_InitMedia()
  ProcedureReturn Result
EndProcedure

Procedure EndMedia()
  Protected Result
  Result = DShow_EndMedia()
  ProcedureReturn Result
EndProcedure



;OggS Or fLaC: #MEDIALIBRARY_PBSND
Procedure LoadMedia(filename.s, Parent=0, VidRenderer=0, AudRenderer=0, UseDShow=#False, UseWindowless=#True, OwnVMR=#False, EraseBackground=#False, forceOverlay.i=#False)
  Protected *p, file.i, long.l, iUseFLVPlayer.i
  If filename
    If UseDShow=#False
      file=ReadFile(#PB_Any, filename)
      If file
        CompilerIf #USE_PB_OGG
          long=ReadLong(file)
        CompilerEndIf
        CloseFile(file)
        
        If long = 1399285583 Or long = 1130450022;'CaLf';'SggO'
          *p = DShow_LoadMediaEx(filename.s, Parent, VidRenderer, UseWindowless, AudRenderer, #False, #True, OwnVMR.i, forceOverlay.i)
          If *p
            UsedOutputMediaLibrary = #MEDIALIBRARY_DSHOW
            WriteLog("Use Direct Show", #LOGLEVEL_DEBUG)
          Else
            UsedOutputMediaLibrary = #MEDIALIBRARY_PBSND
            WriteLog("Use PB Sound", #LOGLEVEL_DEBUG)
          EndIf
        Else
          UsedOutputMediaLibrary = #MEDIALIBRARY_DSHOW
          WriteLog("Use Direct Show", #LOGLEVEL_DEBUG)
        EndIf
      Else
        UsedOutputMediaLibrary = #MEDIALIBRARY_DSHOW
        WriteLog("Use Direct Show", #LOGLEVEL_DEBUG)
      EndIf
    Else
      UsedOutputMediaLibrary = #MEDIALIBRARY_DSHOW
      WriteLog("Use Direct Show", #LOGLEVEL_DEBUG)
    EndIf
    
    CompilerIf #USE_SWF_SUPPORT
      If LCase(GetExtensionPart(filename))="swf"
        WriteLog("Use SWF", #LOGLEVEL_DEBUG)
        UsedOutputMediaLibrary = #MEDIALIBRARY_FLASH
      EndIf
    CompilerEndIf
    
    CompilerIf #USE_OEM_VERSION And #USE_OEM_FLVPLAYER
      iUseFLVPlayer=UseFLVPlayer(filename)
      If iUseFLVPlayer
        WriteLog("Use FLV Player", #LOGLEVEL_DEBUG)
        UsedOutputMediaLibrary = #MEDIALIBRARY_FLASH
      EndIf  
    CompilerEndIf
    
    Select UsedOutputMediaLibrary
    Case #MEDIALIBRARY_DSHOW
      ;*p=DShow_CreateMedia()
      If *p=#False
        *p = DShow_LoadMediaEx(filename.s, Parent, VidRenderer, UseWindowless, AudRenderer, #False, #True, OwnVMR.i, forceOverlay.i)
      EndIf  
    Case #MEDIALIBRARY_PBSND
      *p=LoadSound(#PB_Any, filename)
      ConvertToSoftwareBuffer(*p)
      ML_MediaPlaying=0
    Case #MEDIALIBRARY_FLASH
      If iUseFLVPlayer
        CompilerIf #USE_OEM_VERSION And #USE_OEM_FLVPLAYER
          *p=LoadFLVFile(filename)
        CompilerEndIf  
        
      Else
        CompilerIf #USE_SWF_SUPPORT
          *p=LoadSWFFile(filename, "")
          If *p=#Null And MediaFile\Memory
            WriteLog("Virtual file load failed! try play from mem", #LOGLEVEL_DEBUG)
            *p=LoadSWFFile("", "", MediaFile\Memory, MediaFile\Memory + MemorySize(MediaFile\Memory))
          EndIf  
        CompilerEndIf  
      EndIf  
      UsedOutputMediaLibrary = #MEDIALIBRARY_FLASH
    EndSelect

  EndIf
  ProcedureReturn *p
EndProcedure

Procedure LoadMedia_WithoutExtension(filename.s, Parent=0, VidRenderer=0, AudRenderer=0, UseDShow=#False, UseWindowless=#True, OwnVMR=#False, EraseBackground=#False)
  Protected result,newFilename.s
  CompilerIf #USE_VIRTUAL_FILE
    If IsVirtualFileUsed
      newFilename=Mid(Filename, 1, Len(Filename)-Len(GetExtensionPart(Filename))-1)
      VritualFile_RenameFile(filename.s, newFilename)
      filename=newFilename
    EndIf
  CompilerEndIf
  result=LoadMedia(filename.s, Parent, VidRenderer, AudRenderer, UseDShow, UseWindowless, OwnVMR, EraseBackground)
  ProcedureReturn result
EndProcedure

Procedure WaitSeekCallback()
  
  Repeat
  Until WindowEvent()=0
  
EndProcedure  

Procedure MediaSeek(*p, pos.q)
  Protected Result, iWidth.i, iHeight.i
  If *p
    Select UsedOutputMediaLibrary
    Case #MEDIALIBRARY_DSHOW
      If MediaFile\StreamingFile
        If IsWindow(#WINDOW_MAIN)
          iWidth=WindowWidth(#WINDOW_MAIN)
          iHeight=WindowHeight(#WINDOW_MAIN)-MenuHeight()
          WindowBounds(#WINDOW_MAIN, iWidth,iHeight,iWidth,iHeight)
        EndIf
        Result = DShow_MediaSeekAsync(*p, pos.q, @WaitSeekCallback())
        ;WindowBounds(#WINDOW_MAIN, iWidth,iHeight,iWidth,iHeight)
        If IsWindow(#WINDOW_MAIN)
          WindowBounds(#WINDOW_MAIN, 460, Design_Container_Size+3+StatusBarHeight(#STATUSBAR_MAIN), $FFF, $FFF)
        EndIf
      Else
        Result = DShow_MediaSeek(*p, pos.q)
      EndIf
      
    Case #MEDIALIBRARY_PBSND
      ;2013-04-02
      Result = SetSoundPosition(*p,pos,#PB_Sound_Millisecond);SetSoundPosition(*p, (pos*GetSoundAvgByteSize(*p))/1000)
    EndSelect 
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure MediaPosition(*p)
  Protected Result.q
  If *p
    Select UsedOutputMediaLibrary
    Case #MEDIALIBRARY_DSHOW
      Result = DShow_GetMediaPosition(*p)
    Case #MEDIALIBRARY_PBSND
      Result = GetSoundPosition(*p, #PB_Sound_Millisecond)
      ;If GetSoundAvgByteSize(*p)
      ;  Result = (GetSoundPosition(*p)*1000)/GetSoundAvgByteSize(*p)
      ;EndIf
    EndSelect
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure PlayMedia(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_PlayMedia(*p)
    
  Case #MEDIALIBRARY_PBSND
    Result = ResumeSound(*p)
    ML_MediaPlaying=#State_Running
    
  Case #MEDIALIBRARY_FLASH
    If *p
      Result = Flash_Play(*p)
      ML_MediaPlaying=#State_Running
    EndIf
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure ResumeMedia(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_ResumeMedia(*p)
    
  Case #MEDIALIBRARY_PBSND
    Result = ResumeSound(*p)
    ML_MediaPlaying=#State_Running
    
  Case #MEDIALIBRARY_FLASH
    If *p
      Result = Flash_Play(*p)
      ML_MediaPlaying=#State_Running
    EndIf
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure PauseMedia(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_PauseMedia(*p)
    
  Case #MEDIALIBRARY_PBSND
    Result = PauseSound(*p)
    ML_MediaPlaying=#State_Paused
    
  Case #MEDIALIBRARY_FLASH
    If *p
      Result = Flash_Stop(*p)
      ML_MediaPlaying=#State_Paused
    EndIf
  EndSelect
  ProcedureReturn Result
EndProcedure


Procedure MediaStop(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaStop(*p)
    
  Case #MEDIALIBRARY_PBSND
    StopSound(*p)
    Result = SetSoundPosition(*p, 0)
    ML_MediaPlaying=#State_Stopped
    
  Case #MEDIALIBRARY_FLASH
    If *p
      Result = Flash_Stop(*p)
      ML_MediaPlaying=#State_Stopped
    EndIf
    
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaLength(*p)
  Protected Result.q
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_GetMediaLength(*p)
    
  Case #MEDIALIBRARY_PBSND
    
    Result = SoundLength(*p, #PB_Sound_Millisecond)
    ;If GetSoundAvgByteSize(*p)
    ;  Result = (GetSoundSize(*p)*1000)/GetSoundAvgByteSize(*p)
    ;EndIf
    
  Case #MEDIALIBRARY_FLASH
    If *p:Result = 1:EndIf
    
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaWidth(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_GetMediaWidth(*p)
    
  Case #MEDIALIBRARY_PBSND
    Result = 0
    
  Case #MEDIALIBRARY_FLASH
    CompilerIf (#USE_OEM_VERSION And #USE_OEM_FLVPLAYER) Or #USE_SWF_SUPPORT
      If *p:Result = #FLASH_WIDTH:EndIf
    CompilerEndIf  
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaHeight(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_GetMediaHeight(*p)
    
  Case #MEDIALIBRARY_PBSND
    Result = 0
    
  Case #MEDIALIBRARY_FLASH
    CompilerIf (#USE_OEM_VERSION And #USE_OEM_FLVPLAYER) Or #USE_SWF_SUPPORT
      If *p:Result = #FLASH_HEIGHT:EndIf
    CompilerEndIf
  EndSelect
  ProcedureReturn Result
EndProcedure




Procedure MediaState(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_GetMediaState(*p)
  Case #MEDIALIBRARY_PBSND
    
    ;2013-04-02
    ;Result = IsSoundPlaying(*p)
    If (SoundStatus(*p) = #PB_Sound_Stopped) Or (SoundStatus(*p) = #PB_Sound_Paused)
      Result = #False
    Else
      Result = #True
    EndIf 
    
    If Result=1 And ML_MediaPlaying=#State_Running:Result=#State_Running:EndIf
    If Result=0 And ML_MediaPlaying=#State_Paused:Result=#State_Paused:EndIf
    
  Case #MEDIALIBRARY_FLASH
    If *p:Result = Flash_IsPlaying(*p):EndIf
    
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure FreeMedia(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_FreeMedia(*p)
    
  Case #MEDIALIBRARY_PBSND
    Result = FreeSound(*p)
    
  Case #MEDIALIBRARY_FLASH
    CompilerIf (#USE_OEM_VERSION And #USE_OEM_FLVPLAYER) Or #USE_SWF_SUPPORT
      If *p:FreeSWFFile(*p):EndIf
    CompilerEndIf  
    
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure.f MediaFPS(*p) ; return .f cause we just need float precision
  Protected Result.f
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_GetMediaFPS(*p)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure CaptureCurrMediaImage(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_CaptureImage(*p)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure OnMediaEvent(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW 
    Result = DShow_ProcessMediaEvent(*p)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure.s MediaTime2String(time.l)
  Protected Result.s
  Result = DShow_FormatTimeToString(time.l)
  ProcedureReturn Result
EndProcedure

Procedure MediaGetVolume(*p) ; from -100db to 0db
;   Protected Result
;   Select UsedOutputMediaLibrary
;   Case #MEDIALIBRARY_DSHOW
;     Result = DShow_MediaGetVolume(*p)-100
;   Case #MEDIALIBRARY_PBSND
;     Result = ML_MediaVolume
;   EndSelect
;   ProcedureReturn Result
  ProcedureReturn ML_MediaVolume-100
EndProcedure

Procedure MediaPutVolume(*p, db.l) ; from -100db to 0db
  Protected Result
  ML_MediaVolume=db+100
  If iIsSoundMuted
    Select UsedOutputMediaLibrary
    Case #MEDIALIBRARY_DSHOW
      Result = DShow_MediaSetVolume(*p, 0)
    Case #MEDIALIBRARY_PBSND
      Result = SoundVolume(*p, 0)
    EndSelect    
  Else
    Select UsedOutputMediaLibrary
    Case #MEDIALIBRARY_DSHOW
      Result = DShow_MediaSetVolume(*p, ML_MediaVolume)
    Case #MEDIALIBRARY_PBSND
      Result = SoundVolume(*p, ML_MediaVolume)
    EndSelect
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure MediaPutBalance(*p, bal.l) ; -100 to +100
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetBalance(*p, bal.l)
  Case #MEDIALIBRARY_PBSND
    ML_MediaPan=bal
    Result = SoundPan(*p, bal)
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaGetBalance(*p) ; from -100 to +100
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaGetBalance(*p)
  Case #MEDIALIBRARY_PBSND
    Result = ML_MediaPan
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure.f MediaGetAspectRatio(*p)
  Protected Result.f
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaGetAspectRatio(*p)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure


Procedure MediaSetDestX(*p,x.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetDestX(*p,x.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaSetDestY(*p,y.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetDestY(*p,y.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaSetSrcX(*p,x.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetSrcX(*p,x.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaSetSrcY(*p,y.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetSrcY(*p,y.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure


Procedure MediaSetWindowX(*p,x.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetWindowX(*p,x.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaSetWindowY(*p,y.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetWindowY(*p,y.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaSetWindowWidth(*p,width.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetWindowWidth(*p,width.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaSetWindowHeight(*p,height.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetWindowHeight(*p,height.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure



Procedure MediaSetDestWidth(*p,width.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetDestWidth(*p,width.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaSetDestHeight(*p,height.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetDestHeight(*p,height.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaSetSrcWidth(*p,width.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetSrcWidth(*p,width.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure MediaSetSrcHeight(*p,height.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetSrcHeight(*p,height.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure.i MediaSetSpeed(*p, rate.d) ; Default is 1.0 , does not always? work, Work differnet, TODO
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetSpeed(*p, rate.d)
  Case #MEDIALIBRARY_PBSND
    Result = SetSoundFrequency(*p, rate)
  EndSelect
  ProcedureReturn Result
EndProcedure


Procedure.i MediaHideCursor(*p, bHide.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaHideCursor(*p, bHide.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure


Procedure.i MediaSetFullscreenMode(*p, bFullscreen.i)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaSetFullscreenMode(*p, bFullscreen.i)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure.i MediaIsCursorHidden(*p)
  Protected Result
  Select UsedOutputMediaLibrary
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_MediaIsCursorHidden(*p)
  Case #MEDIALIBRARY_PBSND
    Result = 0
  EndSelect
  ProcedureReturn Result
EndProcedure


Procedure CheckMedia(sFile.s, *MC.MEDIACHECK)
  Protected Result, iSound.i, iMedia.i, file, long.l
  
  iMedia = #MEDIALIBRARY_DSHOW
  file = ReadFile(#PB_Any, sfile)
  If file
    long=ReadLong(file)
    If long = 1399285583 Or long = 1130450022;'CaLf';'SggO'
      iMedia = #MEDIALIBRARY_PBSND
    EndIf
    CloseFile(file)
  EndIf  

  Select iMedia
  Case #MEDIALIBRARY_DSHOW
    Result = DShow_CheckMedia(sFile.s, *MC.MEDIACHECK)
  Case #MEDIALIBRARY_PBSND
    iSound.i=LoadSound(#PB_Any, sFile)
    If iSound.i
      
      ;
      ;If GetSoundAvgByteSize(iSound)
      *MC\dLength = SoundLength(iSound, #PB_Sound_Millisecond) / 1000.0;(GetSoundSize(iSound))/GetSoundAvgByteSize(iSound)
      *MC\bUseable = #True
      *MC\bVideo = #False
      ;EndIf
      FreeSound(iSound)
    EndIf
  EndSelect
  ProcedureReturn Result
EndProcedure




CompilerIf  #USE_DATABASE

;DB_UpdateSync(*DB,"CREATE TABLE MEDIAPOS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, file VARCHAR(800), pos BIGINT, offset BIGINT, UNIQUE (file, offset))")  
Procedure SaveMediaPos(*p, sFilename.s, offset.q)
  Protected pos.q, *DB
  If *p
    pos=MediaPosition(*p)
    If pos>=0
      *DB=DB_Open(sDataBaseFile)
      If *DB
        DB_Update(*DB, "INSERT OR REPLACE INTO MEDIAPOS (file, pos, offset) VALUES ('"+sFilename+"', '"+Str(pos)+"', '"+Str(offset)+"')")
        DB_Close(*DB)
      EndIf  
    EndIf
  EndIf
EndProcedure
Procedure LoadMediaPos(*p, sFilename.s, offset.q)
  Protected pos.q, *DB
  If *p
    *DB=DB_Open(sDataBaseFile)
    If *DB
      
      If DB_Query(*DB,"SELECT * FROM MEDIAPOS WHERE file='"+sFilename+"' AND offset='"+Str(offset)+"'")
        DB_SelectRow(*DB, 0)
        pos = DB_GetAsQuad(*DB, 2)
      EndIf
      DB_EndQuery(*DB)
      
      If pos
        MediaSeek(*p, pos.q)
      EndIf    
      DB_Close(*DB)
    EndIf 
  EndIf
EndProcedure
CompilerEndIf

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 106
; FirstLine = 75
; Folding = 0xPBAAi-
; EnableXP
; UseMainFile = Player.pb
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
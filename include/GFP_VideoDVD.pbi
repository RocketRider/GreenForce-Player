;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
Global iIsMediaObjectVideoDVD.i
Global iVideoDVDMouseX
Global iVideoDVDMouseY
Global iVideoDVDMouseButton
Global MouseUpdateCounter.i

Procedure InitVideoDVD()
  SetErrorMode_(#SEM_FAILCRITICALERRORS)
EndProcedure


; Procedure GetCDDrives()
;   Protected l.i
;   For l=67 To 90
;     If GetDriveType_(Chr(l)+":\")=#DRIVE_CDROM
;       Debug Chr(l)+":\"
;     EndIf
;   Next
; EndProcedure


Procedure VDVD_LoadDVD(sVolume.s)
  FreeMediaFile()
  iMediaObject = DShow_LoadDVDMedia(sVolume.s, GadgetID(#GADGET_VIDEO_CONTAINER))
  If iMediaObject
    WriteLog("Play DVD: "+sVolume, #LOGLEVEL_DEBUG)
    iIsMediaObjectVideoDVD.i=#True
    MediaFile\iPlaying = #True
    MediaFile\Memory = #False
    MediaFile\sFile = sVolume
    MediaFile\sRealFile = sVolume
    PlayMedia(iMediaObject)
    DShow_DVDEnableAutoControl(iMediaObject, #False)
    DShow_DVDShowMenu(iMediaObject, #DVD_MENU_Root)
    ;SetMediaSizeToDVD()
    ;Debug MediaWidth(iMediaObject)
    SetMediaSizeToOrginal()
    SetMediaAspectRation()
    StatusBarText(0, 0, DShow_DVDGetTitle(iMediaObject))
    VIS_SetDSHOWObj(IMediaObject)
  Else
    SetMediaSizeTo0()
    StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA))
  EndIf
  ProcedureReturn iMediaObject
EndProcedure

Procedure VDVD_CreatePopUpMenu(Systray.i=#False)
  Protected i.i, sTest.s, ChapterCount.i, iPlaylistCount.i, sTitle.s
  If IsMenu(#MENU_VDVD_MENU)
    FreeMenu(#MENU_VDVD_MENU)
  EndIf
  CompilerIf #USE_OEM_VERSION
    If CreatePopupMenu(#MENU_VDVD_MENU)
  CompilerElse  
    If CreatePopupImageMenu(#MENU_VDVD_MENU, #PB_Menu_ModernLook)
  CompilerEndIf  
  
  
    If Not GetGadgetData(#GADGET_CONTAINER) ;Problem mit Anzeige von dialogen in fullscreen modus (fenster immer im Forderground)
      MenuItem(#MENU_LOAD, Language(#L_LOAD), ImageID(#SPRITE_MENU_LOAD))
      
      CompilerIf #USE_SUBTITLES
        If iMediaObject And iIsMediaObjectVideoDVD=0
          If MediaWidth(iMediaObject)>0
            MenuItem(#MENU_LOAD_SUBTITLES, Language(#L_LOAD_SUBTITLES), ImageID(#SPRITE_MENU_LANGUAGE))
            If iSubtitlesLoaded
              MenuItem(#MENU_DISABLE_SUBTITLES, Language(#L_DISABLE_SUBTITLES), ImageID(#SPRITE_MENU_LANGUAGE))
              
              OpenSubMenu(Language(#L_SUBTITLE_SIZE))
                MenuItem(#MENU_SUBTITLE_SIZE_20, "20")
                MenuItem(#MENU_SUBTITLE_SIZE_30, "30")
                MenuItem(#MENU_SUBTITLE_SIZE_40, "40")
                MenuItem(#MENU_SUBTITLE_SIZE_50, "50")
                MenuItem(#MENU_SUBTITLE_SIZE_60, "60")
              CloseSubMenu()
              If UsedSubtitleSize=20:SetMenuItemState(#MENU_VDVD_MENU, #MENU_SUBTITLE_SIZE_20, 1):EndIf  
              If UsedSubtitleSize=30:SetMenuItemState(#MENU_VDVD_MENU, #MENU_SUBTITLE_SIZE_30, 1):EndIf  
              If UsedSubtitleSize=40:SetMenuItemState(#MENU_VDVD_MENU, #MENU_SUBTITLE_SIZE_40, 1):EndIf  
              If UsedSubtitleSize=50:SetMenuItemState(#MENU_VDVD_MENU, #MENU_SUBTITLE_SIZE_50, 1):EndIf  
              If UsedSubtitleSize=60:SetMenuItemState(#MENU_VDVD_MENU, #MENU_SUBTITLE_SIZE_60, 1):EndIf  
            EndIf
          EndIf
        EndIf
      CompilerEndIf
      MenuBar()
    EndIf
    
    
    
    MenuItem(#MENU_PLAY, Language(#L_PLAY)+"/"+Language(#L_BREAK), ImageID(#SPRITE_MENU_PLAY))
    MenuItem(#MENU_STOP, Language(#L_STOP), ImageID(#SPRITE_MENU_STOP))
    MenuItem(#MENU_FORWARD, Language(#L_NEXT), ImageID(#SPRITE_MENU_FORWARD))
    MenuItem(#MENU_BACKWARD, Language(#L_PREVIOUS), ImageID(#SPRITE_MENU_BACKWARD))
    MenuBar()
    If GetGadgetData(#GADGET_CONTAINER)
      MenuItem(#MENU_FULLSCREEN, Language(#L_RESET_DISPLAY), ImageID(#SPRITE_MENU_MONITOR))
    Else  
      MenuItem(#MENU_FULLSCREEN, Language(#L_FULLSCREEN), ImageID(#SPRITE_MENU_MONITOR))
      MenuItem(#MENU_MINIMALMODE, Language(#L_MINIMALMODE), ImageID(#SPRITE_MENU_MINIMALMODE))
    EndIf
    
    OpenSubMenu(Language(#L_ASPECTRATION))
      MenuItem(#MENU_ASPECTATION_AUTO, Language(#L_AUTOMATIC));, ImageID(#SPRITE_MENU_ACTION))
      MenuItem(#MENU_ASPECTATION_1_2, "1:2");, ImageID(#SPRITE_MENU_ACTION))
      MenuItem(#MENU_ASPECTATION_1_1, "1:1");, ImageID(#SPRITE_MENU_ACTION))
      MenuItem(#MENU_ASPECTATION_5_4, "5:4");, ImageID(#SPRITE_MENU_ACTION))
      MenuItem(#MENU_ASPECTATION_4_3, "4:3");, ImageID(#SPRITE_MENU_ACTION))
      MenuItem(#MENU_ASPECTATION_16_10, "16:10");, ImageID(#SPRITE_MENU_ACTION))
      MenuItem(#MENU_ASPECTATION_16_9, "16:9");, ImageID(#SPRITE_MENU_ACTION))
      MenuItem(#MENU_ASPECTATION_2_1, "2:1");, ImageID(#SPRITE_MENU_ACTION))
      MenuItem(#MENU_ASPECTATION_21_9, "21:9");, ImageID(#SPRITE_MENU_ACTION))
      For i=#MENU_ASPECTATION_AUTO To #MENU_ASPECTATION_21_9
        If IsMenu(#MENU_MAIN)
          SetMenuItemState(#MENU_VDVD_MENU, i, GetMenuItemState(#MENU_MAIN, i))
        EndIf  
      Next
    CloseSubMenu()
  
    If iIsMediaObjectVideoDVD.i
      OpenSubMenu(Language(#L_LANGUAGE))
        For i=0 To 7
          sTest.s = DShow_DVDGetAudioLanguageAsString(iMediaObject, i)
          If sTest = "":sTest = "-":EndIf
          MenuItem(#MENU_VDVD_LANGUAGE_1+i, sTest, ImageID(#SPRITE_MENU_LANGUAGE))
          DisableMenuItem(#MENU_VDVD_MENU, #MENU_VDVD_LANGUAGE_1+i, ~DShow_DVDIsAudioChannelEnabled(iMediaObject, i)&1)
        Next
      CloseSubMenu()
      OpenSubMenu(Language(#L_MENU))
        MenuItem(#MENU_VDVD_MENU_Title, Language(#L_MENU_TITLE), ImageID(#SPRITE_MENU_PLAYLIST))   
        MenuItem(#MENU_VDVD_MENU_Root, Language(#L_MENU_ROOT), ImageID(#SPRITE_MENU_PLAYLIST))
        MenuItem(#MENU_VDVD_MENU_Subpicture, Language(#L_MENU_SUBPICTURE), ImageID(#SPRITE_MENU_PLAYLIST))
        MenuItem(#MENU_VDVD_MENU_Audio, Language(#L_MENU_AUDIO), ImageID(#SPRITE_MENU_PLAYLIST))
        MenuItem(#MENU_VDVD_MENU_Angle, Language(#L_MENU_ANGLE), ImageID(#SPRITE_MENU_PLAYLIST))
        MenuItem(#MENU_VDVD_MENU_Chapter, Language(#L_MENU_CHAPTER), ImageID(#SPRITE_MENU_PLAYLIST))
      CloseSubMenu()
    
      OpenSubMenu(Language(#L_SPEED))
        MenuItem(#MENU_VDVD_SPEED_N8P0, "-8.0", ImageID(#SPRITE_MENU_BACKWARD))
        MenuItem(#MENU_VDVD_SPEED_N4P0, "-4.0", ImageID(#SPRITE_MENU_BACKWARD))
        MenuItem(#MENU_VDVD_SPEED_N2P0, "-2.0", ImageID(#SPRITE_MENU_BACKWARD))
        MenuItem(#MENU_VDVD_SPEED_N1P5, "-1.5", ImageID(#SPRITE_MENU_BACKWARD))
        MenuItem(#MENU_VDVD_SPEED_N1P0, "-1.0", ImageID(#SPRITE_MENU_BACKWARD))
        MenuItem(#MENU_VDVD_SPEED_N0P5, "-0.5", ImageID(#SPRITE_MENU_BACKWARD))
        MenuItem(#MENU_VDVD_SPEED_0P5, "0.5", ImageID(#SPRITE_MENU_FORWARD))
        MenuItem(#MENU_VDVD_SPEED_1P0, "1.0", ImageID(#SPRITE_MENU_FORWARD))
        MenuItem(#MENU_VDVD_SPEED_1P5, "1.5", ImageID(#SPRITE_MENU_FORWARD))
        MenuItem(#MENU_VDVD_SPEED_2P0, "2.0", ImageID(#SPRITE_MENU_FORWARD))
        MenuItem(#MENU_VDVD_SPEED_4P0, "4.0", ImageID(#SPRITE_MENU_FORWARD))
        MenuItem(#MENU_VDVD_SPEED_8P0, "8.0", ImageID(#SPRITE_MENU_FORWARD))
      CloseSubMenu()  
    
      OpenSubMenu(Language(#L_CHAPTER))
      ChapterCount = DShow_DVDGetChapterCount(iMediaObject, DShow_DVDGetCurrentTitle(iMediaObject))
      For i=0 To ChapterCount
        MenuItem(#MENU_VDVD_CHAPTER_1+I, Language(#L_CHAPTER)+" "+Str(i), ImageID(#SPRITE_MENU_ACTION))
      Next
      CloseSubMenu()  
      
    Else
      If SelectedOutputContainer=#GADGET_CONTAINER
        If Playlist\iID
          OpenSubMenu(Language(#L_PLAYLIST))
            iPlaylistCount=Playlist\iItemCount
            If iPlaylistCount>500:iPlaylistCount=500:EndIf
            For i=0 To iPlaylistCount
              sTitle.s=PlayListItems(i)\sTitle
              If sTitle="":sTitle=GetFilePart(PlayListItems(i)\sFile):EndIf
              If sTitle<>""
                MenuItem(#MENU_VDVD_PLAYLIST_1+i, sTitle)
                If Playlist\iCurrentMedia=i
                  SetMenuItemState(#MENU_VDVD_MENU, #MENU_VDVD_PLAYLIST_1+i, 1)
                EndIf
              EndIf
            Next
          CloseSubMenu()
        EndIf
      EndIf
    EndIf
    
    
    MenuBar()
    If Systray:MenuItem(#MENU_SHOW, Language(#L_SHOW)+"/"+Language(#L_HIDE), ImageID(#SPRITE_MENU_ABOUT)):EndIf
    MenuItem(#MENU_QUIT, Language(#L_QUIT), ImageID(#SPRITE_MENU_END))
    
  EndIf
EndProcedure

Procedure VDVD_CreateContainer()
  Protected ifont2.i, i.i
  ContainerGadget(#GADGET_VIDEODVD_CONTAINER, 2, 2, 350, Design_Container_Size-2, #PB_Container_Single)
  ifont2 = LoadFont(#PB_Any,"Times New Roman",32) 
  
;   If Design_Buttons=0
;     If Design_ID=1
;       ImageGadget(#GADGET_VDVD_BUTTON_PLAY, 3, 37, 30, 30, ImageID(#SPRITE_PLAY))
;       PlayerTrackBarGadget(#GADGET_VDVD_TRACKBAR, 38, 1, 275, 25, 0, 10000, Design_Trackbar)
;       ImageGadget(#GADGET_VDVD_BUTTON_BACKWARD, 10, 5, 30, 30, ImageID(#SPRITE_BACKWARD))
;     Else
;       ImageGadget(#GADGET_VDVD_BUTTON_PLAY, 3, 40, 30, 30, ImageID(#SPRITE_PLAY))
;       PlayerTrackBarGadget(#GADGET_VDVD_TRACKBAR, 38, 10, 275, 25, 0, 10000, Design_Trackbar)
;       ImageGadget(#GADGET_VDVD_BUTTON_BACKWARD, 3, 5, 30, 30, ImageID(#SPRITE_BACKWARD))
;     EndIf  
;       
;     ImageGadget(#GADGET_VDVD_BUTTON_PREVIOUS, 42, 40, 30, 30, ImageID(#SPRITE_PREVIOUS))
;     ImageGadget(#GADGET_VDVD_BUTTON_STOP, 76, 40, 30, 30, ImageID(#SPRITE_STOP))
;     ImageGadget(#GADGET_VDVD_BUTTON_NEXT, 110, 40,30, 30, ImageID(#SPRITE_NEXT))
;     
;     ImageGadget(#GADGET_VDVD_BUTTON_EJECT, 147, 40,30, 30, ImageID(#SPRITE_EJECT))
;     ImageGadget(#GADGET_VDVD_BUTTON_LAUFWERK, 182, 40,30, 30, ImageID(#SPRITE_CDDRIVE_BLUE))
;     ImageGadget(#GADGET_VDVD_BUTTON_SNAPSHOT, 217, 40, 30, 30, ImageID(#SPRITE_SNAPSHOT))
;     
;     
;     ImageGadget(#GADGET_VDVD_BUTTON_FORWARD, 318, 5, 30, 30, ImageID(#SPRITE_FORWARD))   
;     
;   EndIf
;   If Design_Buttons=1
;     ButtonImageGadget(#GADGET_VDVD_BUTTON_PLAY, 3, 40, 30, 30, ImageID(#SPRITE_PLAY))
;     ButtonImageGadget(#GADGET_VDVD_BUTTON_PREVIOUS, 50, 40, 30, 30, ImageID(#SPRITE_PREVIOUS))
;     ButtonImageGadget(#GADGET_VDVD_BUTTON_STOP, 80, 40, 30, 30, ImageID(#SPRITE_STOP))
;     ButtonImageGadget(#GADGET_VDVD_BUTTON_NEXT, 110, 40,30, 30, ImageID(#SPRITE_NEXT))
;     ButtonImageGadget(#GADGET_VDVD_BUTTON_EJECT, 150, 40,30, 30, ImageID(#SPRITE_EJECT))
;     ButtonImageGadget(#GADGET_VDVD_BUTTON_LAUFWERK, 180, 40,30, 30, ImageID(#SPRITE_CDDRIVE_BLUE))
;     ButtonImageGadget(#GADGET_VDVD_BUTTON_SNAPSHOT, 210, 40, 30, 30, ImageID(#SPRITE_SNAPSHOT))
;     ButtonImageGadget(#GADGET_VDVD_BUTTON_BACKWARD, 3, 5, 30, 30, ImageID(#SPRITE_BACKWARD))
;     ButtonImageGadget(#GADGET_VDVD_BUTTON_FORWARD, 318, 5, 30, 30, ImageID(#SPRITE_FORWARD))
;     
;     PlayerTrackBarGadget(#GADGET_VDVD_TRACKBAR, 38, 10, 275, 25, 0, 10000, Design_Trackbar)
;   EndIf
  
  
    If Design_Buttons=0
      ImageGadget(#GADGET_VDVD_BUTTON_PLAY, DControlX(#GADGET_VDVD_BUTTON_PLAY), DControlY(#GADGET_VDVD_BUTTON_PLAY), DControlW(#GADGET_VDVD_BUTTON_PLAY), DControlH(#GADGET_VDVD_BUTTON_PLAY), ImageID(#SPRITE_PLAY))
      ImageGadget(#GADGET_VDVD_BUTTON_BACKWARD, DControlX(#GADGET_VDVD_BUTTON_BACKWARD), DControlY(#GADGET_VDVD_BUTTON_BACKWARD), DControlW(#GADGET_VDVD_BUTTON_BACKWARD), DControlH(#GADGET_VDVD_BUTTON_BACKWARD), ImageID(#SPRITE_BACKWARD))
      ImageGadget(#GADGET_VDVD_BUTTON_PREVIOUS, DControlX(#GADGET_VDVD_BUTTON_PREVIOUS), DControlY(#GADGET_VDVD_BUTTON_PREVIOUS), DControlW(#GADGET_VDVD_BUTTON_PREVIOUS), DControlH(#GADGET_VDVD_BUTTON_PREVIOUS), ImageID(#SPRITE_PREVIOUS))
      ImageGadget(#GADGET_VDVD_BUTTON_STOP, DControlX(#GADGET_VDVD_BUTTON_STOP), DControlY(#GADGET_VDVD_BUTTON_STOP), DControlW(#GADGET_VDVD_BUTTON_STOP), DControlH(#GADGET_VDVD_BUTTON_STOP), ImageID(#SPRITE_STOP))
      ImageGadget(#GADGET_VDVD_BUTTON_NEXT, DControlX(#GADGET_VDVD_BUTTON_NEXT), DControlY(#GADGET_VDVD_BUTTON_NEXT), DControlW(#GADGET_VDVD_BUTTON_NEXT), DControlH(#GADGET_VDVD_BUTTON_NEXT), ImageID(#SPRITE_NEXT))
      ImageGadget(#GADGET_VDVD_BUTTON_EJECT, DControlX(#GADGET_VDVD_BUTTON_EJECT), DControlY(#GADGET_VDVD_BUTTON_EJECT), DControlW(#GADGET_VDVD_BUTTON_EJECT), DControlH(#GADGET_VDVD_BUTTON_EJECT), ImageID(#SPRITE_EJECT))
      ImageGadget(#GADGET_VDVD_BUTTON_LAUFWERK, DControlX(#GADGET_VDVD_BUTTON_LAUFWERK), DControlY(#GADGET_VDVD_BUTTON_LAUFWERK), DControlW(#GADGET_VDVD_BUTTON_LAUFWERK), DControlH(#GADGET_VDVD_BUTTON_LAUFWERK), ImageID(#SPRITE_CDDRIVE_BLUE))
      ImageGadget(#GADGET_VDVD_BUTTON_SNAPSHOT, DControlX(#GADGET_VDVD_BUTTON_SNAPSHOT), DControlY(#GADGET_VDVD_BUTTON_SNAPSHOT), DControlW(#GADGET_VDVD_BUTTON_SNAPSHOT), DControlH(#GADGET_VDVD_BUTTON_SNAPSHOT), ImageID(#SPRITE_SNAPSHOT))
      ImageGadget(#GADGET_VDVD_BUTTON_FORWARD, DControlX(#GADGET_VDVD_BUTTON_FORWARD), DControlY(#GADGET_VDVD_BUTTON_FORWARD), DControlW(#GADGET_VDVD_BUTTON_FORWARD), DControlH(#GADGET_VDVD_BUTTON_FORWARD), ImageID(#SPRITE_FORWARD))  
    EndIf
    If Design_Buttons=1
      ButtonImageGadget(#GADGET_VDVD_BUTTON_PLAY, DControlX(#GADGET_VDVD_BUTTON_PLAY), DControlY(#GADGET_VDVD_BUTTON_PLAY), DControlW(#GADGET_VDVD_BUTTON_PLAY), DControlH(#GADGET_VDVD_BUTTON_PLAY), ImageID(#SPRITE_PLAY))
      ButtonImageGadget(#GADGET_VDVD_BUTTON_BACKWARD, DControlX(#GADGET_VDVD_BUTTON_BACKWARD), DControlY(#GADGET_VDVD_BUTTON_BACKWARD), DControlW(#GADGET_VDVD_BUTTON_BACKWARD), DControlH(#GADGET_VDVD_BUTTON_BACKWARD), ImageID(#SPRITE_BACKWARD))
      ButtonImageGadget(#GADGET_VDVD_BUTTON_PREVIOUS, DControlX(#GADGET_VDVD_BUTTON_PREVIOUS), DControlY(#GADGET_VDVD_BUTTON_PREVIOUS), DControlW(#GADGET_VDVD_BUTTON_PREVIOUS), DControlH(#GADGET_VDVD_BUTTON_PREVIOUS), ImageID(#SPRITE_PREVIOUS))
      ButtonImageGadget(#GADGET_VDVD_BUTTON_STOP, DControlX(#GADGET_VDVD_BUTTON_STOP), DControlY(#GADGET_VDVD_BUTTON_STOP), DControlW(#GADGET_VDVD_BUTTON_STOP), DControlH(#GADGET_VDVD_BUTTON_STOP), ImageID(#SPRITE_STOP))
      ButtonImageGadget(#GADGET_VDVD_BUTTON_NEXT, DControlX(#GADGET_VDVD_BUTTON_NEXT), DControlY(#GADGET_VDVD_BUTTON_NEXT), DControlW(#GADGET_VDVD_BUTTON_NEXT), DControlH(#GADGET_VDVD_BUTTON_NEXT), ImageID(#SPRITE_NEXT))
      ButtonImageGadget(#GADGET_VDVD_BUTTON_EJECT, DControlX(#GADGET_VDVD_BUTTON_EJECT), DControlY(#GADGET_VDVD_BUTTON_EJECT), DControlW(#GADGET_VDVD_BUTTON_EJECT), DControlH(#GADGET_VDVD_BUTTON_EJECT), ImageID(#SPRITE_EJECT))
      ButtonImageGadget(#GADGET_VDVD_BUTTON_LAUFWERK, DControlX(#GADGET_VDVD_BUTTON_LAUFWERK), DControlY(#GADGET_VDVD_BUTTON_LAUFWERK), DControlW(#GADGET_VDVD_BUTTON_LAUFWERK), DControlH(#GADGET_VDVD_BUTTON_LAUFWERK), ImageID(#SPRITE_CDDRIVE_BLUE))
      ButtonImageGadget(#GADGET_VDVD_BUTTON_SNAPSHOT, DControlX(#GADGET_VDVD_BUTTON_SNAPSHOT), DControlY(#GADGET_VDVD_BUTTON_SNAPSHOT), DControlW(#GADGET_VDVD_BUTTON_SNAPSHOT), DControlH(#GADGET_VDVD_BUTTON_SNAPSHOT), ImageID(#SPRITE_SNAPSHOT))
      ButtonImageGadget(#GADGET_VDVD_BUTTON_FORWARD, DControlX(#GADGET_VDVD_BUTTON_FORWARD), DControlY(#GADGET_VDVD_BUTTON_FORWARD), DControlW(#GADGET_VDVD_BUTTON_FORWARD), DControlH(#GADGET_VDVD_BUTTON_FORWARD), ImageID(#SPRITE_FORWARD))  
    EndIf
    ImageGadget(#GADGET_VDVD_BUTTON_MUTE, DControlX(#GADGET_VDVD_BUTTON_MUTE), DControlY(#GADGET_VDVD_BUTTON_MUTE), DControlW(#GADGET_VDVD_BUTTON_MUTE), DControlH(#GADGET_VDVD_BUTTON_MUTE), ImageID(#SPRITE_MENU_SOUND))
    
    PlayerTrackBarGadget(#GADGET_VDVD_TRACKBAR, DControlX(#GADGET_VDVD_TRACKBAR), DControlY(#GADGET_VDVD_TRACKBAR), DControlW(#GADGET_VDVD_TRACKBAR), DControlH(#GADGET_VDVD_TRACKBAR), 0, 10000, Design_Trackbar)
    iVDVD_VolumeGadget = VolumeGadget(DControlX(#GADGET_VDVD_VOLUME), DControlY(#GADGET_VDVD_VOLUME), ifont2, 50)
    
    
    If DControlX(#GADGET_VDVD_TRACKBAR)=-1:HideGadget(#GADGET_VDVD_TRACKBAR, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_BACKWARD)=-1:HideGadget(#GADGET_VDVD_BUTTON_BACKWARD, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_FORWARD)=-1:HideGadget(#GADGET_VDVD_BUTTON_FORWARD, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_PLAY)=-1:HideGadget(#GADGET_VDVD_BUTTON_PLAY, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_PREVIOUS)=-1:HideGadget(#GADGET_VDVD_BUTTON_PREVIOUS, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_STOP)=-1:HideGadget(#GADGET_VDVD_BUTTON_STOP, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_NEXT)=-1:HideGadget(#GADGET_VDVD_BUTTON_NEXT, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_SNAPSHOT)=-1:HideGadget(#GADGET_VDVD_BUTTON_SNAPSHOT, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_LAUFWERK)=-1:HideGadget(#GADGET_VDVD_BUTTON_LAUFWERK, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_EJECT)=-1:HideGadget(#GADGET_VDVD_BUTTON_EJECT, #True):EndIf
    If DControlX(#GADGET_VDVD_BUTTON_MUTE)=-1:HideGadget(#GADGET_VDVD_BUTTON_MUTE, #True):EndIf
    ;If DControlX(#GADGET_VDVD_BUTTON_FULLSCREEN)=-1:HideGadget(#GADGET_VDVD_BUTTON_FULLSCREEN, #True):EndIf
    If DControlX(#GADGET_VDVD_VOLUME)=-1:HideGadget(iVDVD_VolumeGadget, #True):EndIf
    
    
    If IsGadget(#GADGET_VDVD_BUTTON_PLAY):GadgetToolTip(#GADGET_VDVD_BUTTON_PLAY, Language(#L_PLAY)):EndIf
    If IsGadget(#GADGET_VDVD_BUTTON_PREVIOUS):GadgetToolTip(#GADGET_VDVD_BUTTON_PREVIOUS, Language(#L_PREVIOUS)):EndIf
    If IsGadget(#GADGET_VDVD_BUTTON_STOP):GadgetToolTip(#GADGET_VDVD_BUTTON_STOP, Language(#L_STOP)):EndIf
    If IsGadget(#GADGET_VDVD_BUTTON_NEXT):GadgetToolTip(#GADGET_VDVD_BUTTON_NEXT, Language(#L_NEXT)):EndIf
    If IsGadget(#GADGET_VDVD_BUTTON_EJECT):GadgetToolTip(#GADGET_VDVD_BUTTON_EJECT, Language(#L_EJECT)):EndIf
    If IsGadget(#GADGET_VDVD_BUTTON_LAUFWERK):GadgetToolTip(#GADGET_VDVD_BUTTON_LAUFWERK, Language(#L_DRIVE)):EndIf
    If IsGadget(#GADGET_VDVD_BUTTON_SNAPSHOT):GadgetToolTip(#GADGET_VDVD_BUTTON_SNAPSHOT, Language(#L_SNAPSHOT)):EndIf
    If IsGadget(#GADGET_VDVD_BUTTON_BACKWARD):GadgetToolTip(#GADGET_VDVD_BUTTON_BACKWARD, Language(#L_BACKWARD)):EndIf
    If IsGadget(#GADGET_VDVD_BUTTON_FORWARD):GadgetToolTip(#GADGET_VDVD_BUTTON_FORWARD, Language(#L_FORWARD)):EndIf
  
  
  
  
  
;   iVDVD_VolumeGadget = VolumeGadget(260, 50, ifont2, 50)
;   ImageGadget(#GADGET_VDVD_BUTTON_MUTE, 243, 50, 16, 16, ImageID(#SPRITE_MENU_SOUND))
  
  CreatePopupImageMenu(#MENU_VDVD_DRIVES, #PB_Menu_ModernLook)
  MenuItem(#MENU_VDVD_FROM_DICTIONARY, Language(#L_LOAD_FROM_DIRECTORY), ImageID(#SPRITE_MENU_LOAD))
  MenuBar() 
  For i=67 To 90
    If GetDriveType_(Chr(i)+":\") = #DRIVE_CDROM
      MenuItem(#MENU_VDVD_DRIVES_1+(i-67), Chr(i)+":\", ImageID(#SPRITE_MENU_AUDIOCD))
    EndIf
  Next
  VDVD_CreatePopUpMenu()
  
  CloseGadgetList()
  HideGadget(#GADGET_VIDEODVD_CONTAINER, #True)
EndProcedure


Procedure VDVD_RunCommand(iCommand.i, fParam.f=0, sParam.s="")
  Protected iState.i, qLength.q, sLaufwerk.s, i.i, sDrive.s
  Select iCommand
  Case #COMMAND_PLAY 
    If iMediaObject  
      If MediaState(iMediaObject)<>#STATE_RUNNING;#STATE_STOPPED
        If MediaState(iMediaObject)=#STATE_PAUSED
          ResumeMedia(iMediaObject)
        Else
          PlayMedia(iMediaObject)
        EndIf
        DShow_DVDPlayForwards(IMediaObject, 1.0)
      Else
        DShow_PauseMedia(iMediaObject)
      EndIf
    Else
      sDrive=PathRequester(Language(#L_LOAD_FROM_DIRECTORY), "")
      If sDrive
        VDVD_LoadDVD(sDrive)
      EndIf
    EndIf  
      
  Case #COMMAND_STOP
    DShow_MediaStop(iMediaObject)
    
  Case #COMMAND_NEXTTRACK
    DShow_DVDNextChapter(iMediaObject)
    
  Case #COMMAND_PREVIOUSTRACK
    DShow_DVDPrevChapter(iMediaObject)
  
  Case #COMMAND_FORWARD
    qLength = DShow_DVDGetLength(iMediaObject)
    If qLength
      qLength = (DShow_DVDGetPosition(iMediaObject)+qLength/100)+5
      If qLength>DShow_DVDGetLength(iMediaObject):qLength=DShow_DVDGetLength(iMediaObject):EndIf
      DShow_DVDPlayAtTime(iMediaObject, qLength)
    EndIf  
    
  Case #COMMAND_BACKWARD
    qLength = DShow_DVDGetLength(iMediaObject)
    If qLength
      qLength = (DShow_DVDGetPosition(iMediaObject)-qLength/100)-5
      If qLength<0:qLength=0:EndIf
      DShow_DVDPlayAtTime(iMediaObject, qLength)
    EndIf
  
  Case #COMMAND_DVD_EJECT
    iCDDrive.i= ~iCDDrive.i
    
    sLaufwerk.s=DShow_GetDVDDrive(iMediaObject)
    If sLaufwerk
      EjectCDDrive(Left(sLaufwerk, 2), iCDDrive)
    Else  
      For i=67 To 90
        If GetDriveType_(Chr(i)+":\")=#DRIVE_CDROM
          EjectCDDrive(Chr(i)+":", iCDDrive)
        EndIf
      Next
    EndIf
    
  
  EndSelect
EndProcedure  


Procedure VDVD_GadGetEvents(iEventGadget.i)
  Protected iState
  Select iEventGadget
  
  Case #GADGET_VDVD_BUTTON_PLAY
    If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      VDVD_RunCommand(#COMMAND_PLAY)
    EndIf
    
  Case #GADGET_VDVD_BUTTON_STOP
    If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      VDVD_RunCommand(#COMMAND_STOP)
    EndIf
  
  Case #GADGET_VDVD_BUTTON_NEXT
    If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      VDVD_RunCommand(#COMMAND_NEXTTRACK)
    EndIf
    
  Case #GADGET_VDVD_BUTTON_PREVIOUS
    If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      VDVD_RunCommand(#COMMAND_PREVIOUSTRACK)
    EndIf

  Case #GADGET_VDVD_BUTTON_FORWARD
    If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      VDVD_RunCommand(#COMMAND_FORWARD)
    EndIf
    
  Case #GADGET_VDVD_BUTTON_BACKWARD
    If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      VDVD_RunCommand(#COMMAND_BACKWARD)
    EndIf
  
  Case #GADGET_VDVD_BUTTON_EJECT
    If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      VDVD_RunCommand(#COMMAND_DVD_EJECT)
    EndIf
    
  Case iVDVD_VolumeGadget
    If Design_Volume=0
      iState = Int((WindowMouseX(#WINDOW_MAIN)-GadgetX(iVDVD_VolumeGadget))/80*100)
      SetVolumeGadgetState(iVDVD_VolumeGadget, iState)
      SetVolumeGadgetState(iVolumeGadget, iState)
      MediaPutVolume(iMediaObject, -100+iState)
      SetFocus_(GadgetID(iVDVD_VolumeGadget))
    EndIf
    If Design_Volume=1
      SetVolumeGadgetState(iVolumeGadget, GetVolumeGadgetState(iVDVD_VolumeGadget))
      MediaPutVolume(iMediaObject, -100+GetVolumeGadgetState(iVDVD_VolumeGadget))
    EndIf
    If Design_Volume=2
      If EventType() = #PB_EventType_LeftButtonDown Or (EventType() = #PB_EventType_MouseMove And GetGadgetAttribute(iVDVD_VolumeGadget, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
        SetVolumeGadgetState(iVolumeGadget, GetGadgetAttribute(iVDVD_VolumeGadget, #PB_Canvas_MouseX)*100/70)
        SetVolumeGadgetState(iVDVD_VolumeGadget, GetGadgetAttribute(iVDVD_VolumeGadget, #PB_Canvas_MouseX)*100/70)
        MediaPutVolume(iMediaObject, -100+GetVolumeGadgetState(iVDVD_VolumeGadget))
      EndIf
    EndIf
    
  
  Case #GADGET_VDVD_BUTTON_SNAPSHOT
    If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      RunCommand(#COMMAND_SNAPSHOT)
    EndIf

  Case #GADGET_VDVD_TRACKBAR
    If GetGadgetState(#GADGET_VDVD_TRACKBAR)<>IntQ((DShow_DVDGetPosition(iMediaObject)/DShow_DVDGetLength(iMediaObject))*10000)
     DShow_DVDPlayAtTime(iMediaObject, IntQ(DShow_DVDGetLength(iMediaObject)/10000*GetGadgetState(#GADGET_VDVD_TRACKBAR)))
    EndIf
    
  Case #GADGET_VDVD_BUTTON_LAUFWERK
    If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      DisplayPopupMenu(#MENU_VDVD_DRIVES, WindowID(#WINDOW_MAIN)) 
    EndIf
    
  Case #GADGET_VDVD_BUTTON_MUTE
    If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      RunCommand(#COMMAND_MUTE)
    EndIf  
    
    
  EndSelect
EndProcedure


Procedure VDVD_MenuEvents(iEventMenu)
  Protected sDrive.s
  If iEventMenu>=#MENU_VDVD_DRIVES_1 And iEventMenu<=#MENU_VDVD_DRIVES_24
    sDrive=GetMenuItemText(#MENU_VDVD_DRIVES, iEventMenu)
    If sDrive
      VDVD_LoadDVD(sDrive)
    EndIf
  EndIf
  
  If iEventMenu>=#MENU_VDVD_LANGUAGE_1 And iEventMenu<=#MENU_VDVD_LANGUAGE_8
    DShow_DVDSelectAudio(iMediaObject, iEventMenu-#MENU_VDVD_LANGUAGE_1)
  EndIf

  If iEventMenu>=#MENU_VDVD_CHAPTER_1 And iEventMenu<=#MENU_VDVD_CHAPTER_100
    ;Debug iEventMenu-#MENU_VDVD_CHAPTER_1
    DShow_DVDPlayChapter(iMediaObject, iEventMenu-#MENU_VDVD_CHAPTER_1)
  EndIf  
  
  
  Select iEventMenu
    Case #MENU_VDVD_FROM_DICTIONARY
      sDrive=PathRequester(Language(#L_LOAD_FROM_DIRECTORY), "")
      If sDrive
        VDVD_LoadDVD(sDrive)
      EndIf
    
    Case #MENU_VDVD_MENU_Title
      DShow_DVDShowMenu(iMediaObject, #DVD_MENU_Title)
    Case #MENU_VDVD_MENU_Root
      DShow_DVDShowMenu(iMediaObject, #DVD_MENU_Root)
    Case #MENU_VDVD_MENU_Subpicture
      DShow_DVDShowMenu(iMediaObject, #DVD_MENU_Subpicture)
    Case #MENU_VDVD_MENU_Audio
      DShow_DVDShowMenu(iMediaObject, #DVD_MENU_Audio)
    Case #MENU_VDVD_MENU_Angle
      DShow_DVDShowMenu(iMediaObject, #DVD_MENU_Angle)
    Case #MENU_VDVD_MENU_Chapter
      DShow_DVDShowMenu(iMediaObject, #DVD_MENU_Chapter)

    Case #MENU_VDVD_SPEED_N8P0
      DShow_DVDPlayBackwards(iMediaObject, 8.0)
    Case #MENU_VDVD_SPEED_N4P0
      DShow_DVDPlayBackwards(iMediaObject, 4.0)
    Case #MENU_VDVD_SPEED_N2P0
      DShow_DVDPlayBackwards(iMediaObject, 2.0)
    Case #MENU_VDVD_SPEED_N1P5
      DShow_DVDPlayBackwards(iMediaObject, 1.5)
    Case #MENU_VDVD_SPEED_N1P0
      DShow_DVDPlayBackwards(iMediaObject, 1.0)
    Case #MENU_VDVD_SPEED_N0P5
      DShow_DVDPlayBackwards(iMediaObject, 0.5)
    Case #MENU_VDVD_SPEED_0P5
      DShow_DVDPlayForwards(iMediaObject, 0.5)
    Case #MENU_VDVD_SPEED_1P0
      DShow_DVDPlayForwards(iMediaObject, 1.0)
    Case #MENU_VDVD_SPEED_1P5
      DShow_DVDPlayForwards(iMediaObject, 1.5)
    Case #MENU_VDVD_SPEED_2P0
      DShow_DVDPlayForwards(iMediaObject, 2.0)
    Case #MENU_VDVD_SPEED_4P0
      DShow_DVDPlayForwards(iMediaObject, 4.0)
    Case #MENU_VDVD_SPEED_8P0
      DShow_DVDPlayForwards(iMediaObject, 8.0)
  
  EndSelect
EndProcedure



; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 65
; FirstLine = 49
; Folding = 4+
; EnableXP
; EnableUser
; UseMainFile = Player.pb
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
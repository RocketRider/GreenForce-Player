;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

#IOCTL_STORAGE_EJECT_MEDIA  = $2D4808 
#IOCTL_STORAGE_LOAD_MEDIA   = $2D480C 

Global ACD_NbCDDrives.i
Global SelectedOutputContainer.i = #GADGET_CONTAINER
Global UsedAudioDevice.i=-1
Global ACD_CurrentTrack.i
Global ACD_NbAudioTracks.i
Global ACD_AudioCDStatus.i
Global ACD_Init.i
Global IsHookdisabled.i
Global iCDDrive.i
Global OrgDesign_Container_Size.i

Procedure ACD_InitAudioCD()
  If ACD_Init=0
    ;Debug "Init"
    ACD_NbCDDrives = InitAudioCD()
    ACD_Init = ACD_NbCDDrives
    If ACD_Init
      UseAudioCD(0)
    EndIf  
  EndIf
  ProcedureReturn ACD_NbCDDrives
EndProcedure

Procedure EjectCDDrive(LW.s, State.i)
  Protected hLwStatus.l, Ret
  hLwStatus = CreateFile_("\\.\"+LW, #GENERIC_READ, #FILE_SHARE_READ, 0, #OPEN_EXISTING, 0, 0) 
  If hLwStatus 
    If State
      DeviceIoControl_(hLwStatus, #IOCTL_STORAGE_EJECT_MEDIA, 0, 0, 0, 0, @Ret, 0)
    Else
      DeviceIoControl_(hLwStatus, #IOCTL_STORAGE_LOAD_MEDIA, 0, 0, 0, 0, @Ret, 0) 
    EndIf
    CloseHandle_(hLwStatus)
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure ACD_CreateContainer()
  Protected k.i
  OrgDesign_Container_Size=Design_Container_Size
  ContainerGadget(#GADGET_AUDIOCD_CONTAINER, 2, 2, 350, 80, #PB_Container_Single);Design_Container_Size
  
;     If Design_Buttons=0
;       If Design_ID=1
;         ImageGadget(#GADGET_ACD_BUTTON_PLAY, 3, 37, 30, 30, ImageID(#SPRITE_PLAY))
;       Else
;         ImageGadget(#GADGET_ACD_BUTTON_PLAY, 3, 40, 30, 30, ImageID(#SPRITE_PLAY))
;       EndIf  
;       ImageGadget(#GADGET_ACD_BUTTON_PREVIOUS, 42, 40, 30, 30, ImageID(#SPRITE_PREVIOUS))
;       ImageGadget(#GADGET_ACD_BUTTON_STOP, 76, 40, 30, 30, ImageID(#SPRITE_STOP))
;       ImageGadget(#GADGET_ACD_BUTTON_NEXT, 110, 40,30, 30, ImageID(#SPRITE_NEXT))
;       ImageGadget(#GADGET_ACD_BUTTON_EJECT, 145, 40,30, 30, ImageID(#SPRITE_EJECT))
;     EndIf
;     If Design_Buttons=1
;       ButtonImageGadget(#GADGET_ACD_BUTTON_PLAY, 3, 40, 30, 30, ImageID(#SPRITE_PLAY))
;       ButtonImageGadget(#GADGET_ACD_BUTTON_PREVIOUS, 50, 40, 30, 30, ImageID(#SPRITE_PREVIOUS))
;       ButtonImageGadget(#GADGET_ACD_BUTTON_STOP, 80, 40, 30, 30, ImageID(#SPRITE_STOP))
;       ButtonImageGadget(#GADGET_ACD_BUTTON_NEXT, 110, 40,30, 30, ImageID(#SPRITE_NEXT))
;       ButtonImageGadget(#GADGET_ACD_BUTTON_EJECT, 145, 40,30, 30, ImageID(#SPRITE_EJECT))
;     EndIf
    
    
    
    If Design_Buttons=0
      ImageGadget(#GADGET_ACD_BUTTON_PLAY, DControlX(#GADGET_ACD_BUTTON_PLAY), DControlY(#GADGET_ACD_BUTTON_PLAY), DControlW(#GADGET_ACD_BUTTON_PLAY), DControlH(#GADGET_ACD_BUTTON_PLAY), ImageID(#SPRITE_PLAY))
      ImageGadget(#GADGET_ACD_BUTTON_PREVIOUS, DControlX(#GADGET_ACD_BUTTON_PREVIOUS), DControlY(#GADGET_ACD_BUTTON_PREVIOUS), DControlW(#GADGET_ACD_BUTTON_PREVIOUS), DControlH(#GADGET_ACD_BUTTON_PREVIOUS), ImageID(#SPRITE_PREVIOUS))
      ImageGadget(#GADGET_ACD_BUTTON_STOP, DControlX(#GADGET_ACD_BUTTON_STOP), DControlY(#GADGET_ACD_BUTTON_STOP), DControlW(#GADGET_ACD_BUTTON_STOP), DControlH(#GADGET_ACD_BUTTON_STOP), ImageID(#SPRITE_STOP))
      ImageGadget(#GADGET_ACD_BUTTON_NEXT, DControlX(#GADGET_ACD_BUTTON_NEXT), DControlY(#GADGET_ACD_BUTTON_NEXT), DControlW(#GADGET_ACD_BUTTON_NEXT), DControlH(#GADGET_ACD_BUTTON_NEXT), ImageID(#SPRITE_NEXT))
      ImageGadget(#GADGET_ACD_BUTTON_EJECT, DControlX(#GADGET_ACD_BUTTON_EJECT), DControlY(#GADGET_ACD_BUTTON_EJECT), DControlW(#GADGET_ACD_BUTTON_EJECT), DControlH(#GADGET_ACD_BUTTON_EJECT), ImageID(#SPRITE_EJECT))
    EndIf
    If Design_Buttons=1
      ButtonImageGadget(#GADGET_ACD_BUTTON_PLAY, DControlX(#GADGET_ACD_BUTTON_PLAY), DControlY(#GADGET_ACD_BUTTON_PLAY), DControlW(#GADGET_ACD_BUTTON_PLAY), DControlH(#GADGET_ACD_BUTTON_PLAY), ImageID(#SPRITE_PLAY))
      ButtonImageGadget(#GADGET_ACD_BUTTON_PREVIOUS, DControlX(#GADGET_ACD_BUTTON_PREVIOUS), DControlY(#GADGET_ACD_BUTTON_PREVIOUS), DControlW(#GADGET_ACD_BUTTON_PREVIOUS), DControlH(#GADGET_ACD_BUTTON_PREVIOUS), ImageID(#SPRITE_PREVIOUS))
      ButtonImageGadget(#GADGET_ACD_BUTTON_STOP, DControlX(#GADGET_ACD_BUTTON_STOP), DControlY(#GADGET_ACD_BUTTON_STOP), DControlW(#GADGET_ACD_BUTTON_STOP), DControlH(#GADGET_ACD_BUTTON_STOP), ImageID(#SPRITE_STOP))
      ButtonImageGadget(#GADGET_ACD_BUTTON_NEXT, DControlX(#GADGET_ACD_BUTTON_NEXT), DControlY(#GADGET_ACD_BUTTON_NEXT), DControlW(#GADGET_ACD_BUTTON_NEXT), DControlH(#GADGET_ACD_BUTTON_NEXT), ImageID(#SPRITE_NEXT))
      ButtonImageGadget(#GADGET_ACD_BUTTON_EJECT, DControlX(#GADGET_ACD_BUTTON_EJECT), DControlY(#GADGET_ACD_BUTTON_EJECT), DControlW(#GADGET_ACD_BUTTON_EJECT), DControlH(#GADGET_ACD_BUTTON_EJECT), ImageID(#SPRITE_EJECT))
    EndIf    
    ComboBoxGadget(#GADGET_ACD_COMBOBOX_DEVICE, DControlX(#GADGET_ACD_COMBOBOX_DEVICE), DControlY(#GADGET_ACD_COMBOBOX_DEVICE), DControlW(#GADGET_ACD_COMBOBOX_DEVICE), DControlH(#GADGET_ACD_COMBOBOX_DEVICE))
    ComboBoxGadget(#GADGET_ACD_COMBOBOX_TRACKS, DControlX(#GADGET_ACD_COMBOBOX_TRACKS), DControlY(#GADGET_ACD_COMBOBOX_TRACKS), DControlW(#GADGET_ACD_COMBOBOX_TRACKS), DControlH(#GADGET_ACD_COMBOBOX_TRACKS))
    
    If DControlX(#GADGET_ACD_BUTTON_PLAY)=-1:HideGadget(#GADGET_ACD_BUTTON_PLAY, #True):EndIf
    If DControlX(#GADGET_ACD_BUTTON_PREVIOUS)=-1:HideGadget(#GADGET_ACD_BUTTON_PREVIOUS, #True):EndIf
    If DControlX(#GADGET_ACD_BUTTON_STOP)=-1:HideGadget(#GADGET_ACD_BUTTON_STOP, #True):EndIf
    If DControlX(#GADGET_ACD_BUTTON_NEXT)=-1:HideGadget(#GADGET_ACD_BUTTON_NEXT, #True):EndIf
    If DControlX(#GADGET_ACD_BUTTON_EJECT)=-1:HideGadget(#GADGET_ACD_BUTTON_EJECT, #True):EndIf
    
    
    If IsGadget(#GADGET_ACD_BUTTON_PLAY):GadgetToolTip(#GADGET_ACD_BUTTON_PLAY, Language(#L_PLAY)):EndIf
    If IsGadget(#GADGET_ACD_BUTTON_PREVIOUS):GadgetToolTip(#GADGET_ACD_BUTTON_PREVIOUS, Language(#L_PREVIOUS)):EndIf
    If IsGadget(#GADGET_ACD_BUTTON_STOP):GadgetToolTip(#GADGET_ACD_BUTTON_STOP, Language(#L_STOP)):EndIf
    If IsGadget(#GADGET_ACD_BUTTON_NEXT):GadgetToolTip(#GADGET_ACD_BUTTON_NEXT, Language(#L_NEXT)):EndIf
    If IsGadget(#GADGET_ACD_BUTTON_EJECT):GadgetToolTip(#GADGET_ACD_BUTTON_EJECT, Language(#L_EJECT)):EndIf
    
    
    
    For k=1 To ACD_NbCDDrives
      UseAudioCD(k-1)
      AddGadgetItem(#GADGET_ACD_COMBOBOX_DEVICE, -1, Left(AudioCDName(),2))
    Next
    SetGadgetState(#GADGET_ACD_COMBOBOX_DEVICE, 0)
    
  
    If ACD_NbCDDrives = 1
      DisableGadget(#GADGET_ACD_COMBOBOX_DEVICE, #True)
    EndIf
    
    
    DisableGadget(#GADGET_ACD_COMBOBOX_TRACKS, #True)
    
  CloseGadgetList()
  HideGadget(#GADGET_AUDIOCD_CONTAINER, #True)
EndProcedure

Procedure ACD_RunCommand(iCommand.i, fParam.f=0, sParam.s="")
  Protected k.i, iState.i
  If ACD_Init
    Select iCommand
    Case #COMMAND_PLAY
      ACD_CurrentTrack = GetGadgetState(#GADGET_ACD_COMBOBOX_TRACKS)+1
      PlayAudioCD(ACD_CurrentTrack, AudioCDTracks())
      
    Case #COMMAND_PAUSE
      PauseAudioCD()
      
    Case #COMMAND_STOP
      StopAudioCD()
      
    Case #COMMAND_NEXTTRACK
      iState=AudioCDStatus()
      If iState>0 And iState<AudioCDTracks()
        ACD_CurrentTrack = iState+1
        PlayAudioCD(ACD_CurrentTrack, AudioCDTracks())
        SetGadgetState(#GADGET_ACD_COMBOBOX_TRACKS, ACD_CurrentTrack-1)
      EndIf
      
    Case #COMMAND_PREVIOUSTRACK
      iState=AudioCDStatus()
      If iState>1
        ACD_CurrentTrack = iState-1
        PlayAudioCD(ACD_CurrentTrack, AudioCDTracks())
        SetGadgetState(#GADGET_ACD_COMBOBOX_TRACKS, ACD_CurrentTrack-1)
      EndIf
    
    Case #COMMAND_ACD_EJECT 
      iCDDrive.i= ~iCDDrive.i
      EjectAudioCD(iCDDrive)
    
    Case #COMMAND_ACD_UPDATEDTRACKS
      If UsedAudioDevice<>GetGadgetState(#GADGET_ACD_COMBOBOX_DEVICE) Or ACD_NbAudioTracks <> AudioCDTracks() Or (AudioCDStatus()<>ACD_AudioCDStatus And AudioCDStatus()<1)
        ACD_AudioCDStatus = AudioCDStatus()
        UsedAudioDevice=GetGadgetState(#GADGET_ACD_COMBOBOX_DEVICE)
        StopAudioCD()
        UseAudioCD(UsedAudioDevice)
        ClearGadgetItems(#GADGET_ACD_COMBOBOX_TRACKS)
        ACD_NbAudioTracks = AudioCDTracks()
        ;- TODO ERKENNT VIDEO DVD ALS 1 TRACK
        If ACD_NbAudioTracks>0
          DisableGadget(#GADGET_ACD_COMBOBOX_TRACKS, #False)
          For k=1 To ACD_NbAudioTracks
            AddGadgetItem(#GADGET_ACD_COMBOBOX_TRACKS, -1, "Track "+Str(k))
          Next
        Else
          DisableGadget(#GADGET_ACD_COMBOBOX_TRACKS, #True)
        EndIf
        SetGadgetState(#GADGET_ACD_COMBOBOX_TRACKS, 0)
      EndIf
    EndSelect
  EndIf
EndProcedure

Procedure ACD_GadGetEvents(iEventGadget.i)
  Select iEventGadget
  
  Case #GADGET_ACD_BUTTON_PLAY
    If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      RunCommand(#COMMAND_PLAY)
    EndIf  
      
  Case #GADGET_ACD_BUTTON_STOP
    If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      RunCommand(#COMMAND_STOP)
    EndIf
    
  Case #GADGET_ACD_BUTTON_NEXT
    If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      RunCommand(#COMMAND_NEXTTRACK)
    EndIf 
    
  Case #GADGET_ACD_BUTTON_PREVIOUS
    If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      RunCommand(#COMMAND_PREVIOUSTRACK)
    EndIf
    
  Case #GADGET_ACD_BUTTON_EJECT
    If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick  
      RunCommand(#COMMAND_ACD_EJECT)
    EndIf
  
  Case #GADGET_ACD_COMBOBOX_DEVICE
    RunCommand(#COMMAND_ACD_UPDATEDTRACKS)
    
  EndSelect
EndProcedure



Procedure ChangeContainer(iContainer.i)
  If SelectedOutputContainer<>iContainer
    RunCommand(#COMMAND_STOP)
    SetMediaSizeTo0()
    FreeMediaFile()
    SelectedOutputContainer=iContainer
    Design_Container_Size=OrgDesign_Container_Size
    Select iContainer
    Case #GADGET_CONTAINER
      CompilerIf #USE_VIRTUAL_FILE
        If IsHookdisabled
          If IsVirtualFileUsed
            VirtualFile_ReactivateHook(#False, #True)
            WriteLog("Reactivate Hook", #LOGLEVEL_DEBUG)
            IsHookdisabled = #False
          EndIf
        EndIf
      CompilerEndIf
      HideGadget(#GADGET_AUDIOCD_CONTAINER, #True)
      HideGadget(#GADGET_VIDEODVD_CONTAINER, #True)
      HideGadget(#GADGET_CONTAINER, #False)
      SetMediaSizeTo0()
      
    Case #GADGET_AUDIOCD_CONTAINER
      Design_Container_Size=82
      ACD_InitAudioCD()
      HideGadget(#GADGET_AUDIOCD_CONTAINER, #False)
      HideGadget(#GADGET_CONTAINER, #True)
      HideGadget(#GADGET_VIDEODVD_CONTAINER, #True)
      RunCommand(#COMMAND_ACD_UPDATEDTRACKS)   
      SetMediaSizeTo0()
      
    Case #GADGET_VIDEODVD_CONTAINER
      HideGadget(#GADGET_AUDIOCD_CONTAINER, #True)
      HideGadget(#GADGET_CONTAINER, #True)
      HideGadget(#GADGET_VIDEODVD_CONTAINER, #False)
      CompilerIf #USE_VIRTUAL_FILE
        If IsVirtualFileUsed
          VirtualFile_DeactivateHook(#False, #True)
          WriteLog("Deactivate Hook", #LOGLEVEL_DEBUG)
          IsHookdisabled = #True
        EndIf
      CompilerEndIf
      SetMediaSizeTo0()
      VDVD_LoadDVD("")
    EndSelect
  
  EndIf
EndProcedure




; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 237
; FirstLine = 150
; Folding = t-
; EnableXP
; UseMainFile = Player.pb
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
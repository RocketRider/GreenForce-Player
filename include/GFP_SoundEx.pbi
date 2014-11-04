;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
Structure DSBCAPS
  dwSize.l 
  dwFlags.l
  dwBufferBytes.l 
  dwUnlockTransferRate.l
  dwPlayCpuOverhead.l
EndStructure


;2013-04-02 now directly available with PB
; Procedure IsSoundPlaying(Sound);returns weather the Sound is playing or not.
;   Protected Address, *DSB.IDirectSoundBuffer, Status
;   If IsSound(Sound)
;     Address=IsSound(Sound)
;     If Address=0:ProcedureReturn 0:EndIf
;     *DSB.IDirectSoundBuffer=PeekL(Address)
;     *DSB\GetStatus(@Status)
;     If Status=1 Or Status=5
;       ProcedureReturn 1
;     EndIf
;   EndIf
;   ProcedureReturn 0
; EndProcedure
; 
; Procedure GetSoundPosition(Sound);returns the current position of the Sound.(in bytes)
;   Protected Address, *DSB.IDirectSoundBuffer, Position
;   If IsSound(Sound)
;     Address=IsSound(Sound)
;     If Address=0:ProcedureReturn 0:EndIf
;     *DSB.IDirectSoundBuffer=PeekL(Address)
;     *DSB\GetCurrentPosition(@Position,0)
;   EndIf
;   ProcedureReturn Position
; EndProcedure
; 
; Procedure PauseSound(Sound);pause sound
;   Protected Address, *DSB.IDirectSoundBuffer, Position
;   If IsSound(Sound)
;     Address=IsSound(Sound)
;     If Address=0:ProcedureReturn 0:EndIf
;     *DSB.IDirectSoundBuffer=PeekL(Address)
;     *DSB\Stop()
;   EndIf
; EndProcedure
; 
; Procedure ResumeSound(Sound);pause sound
;   Protected Address, *DSB.IDirectSoundBuffer, Position
;   If IsSound(Sound)
;     Address=IsSound(Sound)
;     If Address=0:ProcedureReturn 0:EndIf
;     *DSB.IDirectSoundBuffer=PeekL(Address)
;     *DSB\Play(0,0,0)
;   EndIf
; EndProcedure
; 
; Procedure SetSoundPosition(Sound,Position);sets the current position of the Sound.(in bytes)
;   Protected Address, *DSB.IDirectSoundBuffer
;   If IsSound(Sound)
;     Address=IsSound(Sound)
;     If Address=0:ProcedureReturn 0:EndIf
;     *DSB.IDirectSoundBuffer=PeekL(Address)
;   EndIf
;   ProcedureReturn *DSB\SetCurrentPosition(Position)
; EndProcedure
; 
; Procedure GetSoundSize(Sound);Returns the size of the Sound in bytes.
;   Protected Address, *DSB.IDirectSoundBuffer, Caps.DSBCAPS
;   If IsSound(Sound)
;     Address=IsSound(Sound)
;     If Address=0:ProcedureReturn 0:EndIf
;     *DSB.IDirectSoundBuffer=PeekL(Address)
;     Caps.DSBCAPS\dwSize=SizeOf(DSBCAPS)
;     *DSB\GetCaps(@Caps)
;   EndIf
;   ProcedureReturn Caps\dwBufferBytes
; EndProcedure



 Structure _WAVEFORMATEX
   nFormatTag.w
   nChannels.w
   lSamplesPerSec.l
   lAvgBytesPerSec.l
   nBlockAlign.w
   nBitsPerSample.w
   nSize.w
 EndStructure
; 
; Procedure GetSoundAvgByteSize(Sound)
;   Protected *dsb.IDirectSoundBuffer, w._WAVEFORMATEX
;   If IsSound(Sound)
;     *dsb.IDirectSoundBuffer = PeekL(IsSound(Sound))
;     *dsb\GetFormat(w._WAVEFORMATEX,SizeOf(_WAVEFORMATEX),0)
;     ProcedureReturn w\lAvgBytesPerSec
;   EndIf
; EndProcedure

 
 Structure DSBUFFERDESC 
  dwSize.l 
  dwFlags.l 
  dwBufferBytes.l 
  dwReserved.l 
  lpwfxFormat.l ; pointer to WAVEFORMATEX 
  ;guid3DAlgorithm.GUID
EndStructure

Enumeration ; CONST_DSBCAPSFLAGS
  #DSBCAPS_PRIMARYBUFFER=1
  #DSBCAPS_STATIC=2
  #DSBCAPS_LOCHARDWARE=4
  #DSBCAPS_LOCSOFTWARE=8
  #DSBCAPS_CTRL3D=16
  #DSBCAPS_CTRLFREQUENCY=32
  #DSBCAPS_CTRLPAN=64
  #DSBCAPS_CTRLVOLUME=128
  #DSBCAPS_CTRLPOSITIONNOTIFY=256
  #DSBCAPS_CTRLFX=512
  #DSBCAPS_CTRLCHANNELVOLUME=1024
  #DSBCAPS_STICKYFOCUS=16384
  #DSBCAPS_GLOBALFOCUS=32768
  #DSBCAPS_GETCURRENTPOSITION2=65536
  #DSBCAPS_MUTE3DATMAXDISTANCE=131072
  #DSBCAPS_LOCDEFER=262144
EndEnumeration

#DSBLOCK_ENTIREBUFFER=2

Procedure ConvertToSoftwareBuffer(sound.i)
  Protected ds.IDirectSound,  dsb.IDirectSoundBuffer, desc.DSBUFFERDESC, wfx._WAVEFORMATEX, newdsb.IDirectSoundBuffer, Result, *ptr, Size, *newptr, newSize, OS
  If IsSound(Sound)
    OS=OSVersion()
    If OS<#PB_OS_Windows_Vista;2013-04-03 OS <> #PB_OS_Windows_Vista And OS <> #PB_OS_Windows_Server_2008 And OS <> #PB_OS_Windows_7 And OS <> #PB_OS_Windows_Future 
      WriteLog("Convert Buffer to Software", #LOGLEVEL_DEBUG)
      ds.IDirectSound
      !EXTRN _PB_DirectSound
      !MOV EAX, [_PB_DirectSound]
      !MOV [p.v_ds],EAX
      
      If IsSound(sound)
        dsb.IDirectSoundBuffer = PeekL(IsSound(sound))
        
        desc.DSBUFFERDESC
        desc\dwSize = SizeOf(DSBUFFERDESC)
        dsb\GetCaps(desc)
        
        wfx._WAVEFORMATEX
        dsb\GetFormat(wfx,SizeOf(_WAVEFORMATEX), #Null)
        desc\lpwfxFormat = wfx
        desc\dwFlags = desc\dwFlags| #DSBCAPS_LOCSOFTWARE
        ds\CreateSoundBuffer(desc, @newdsb.IDirectSoundBuffer, #Null)  
        
        If newdsb
          Result=dsb\Lock(0,0,@*ptr,@Size,0,0,#DSBLOCK_ENTIREBUFFER)
          If Result = #S_OK
            Result=newdsb\Lock(0,0,@*newptr,@newSize,0,0,#DSBLOCK_ENTIREBUFFER)
            If Result = #S_OK
              CopyMemory(*ptr,*newptr,newSize)
              newdsb\UnLock(*newptr,newSize,0,0)
              dsb\UnLock(*ptr,Size,0,0)
              dsb\Release()
              PokeL(IsSound(sound), newdsb)
              ProcedureReturn #True 
            EndIf  
          dsb\UnLock(*ptr,Size,0,0)
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure





;{ Example:


; InitSound()
; UseOGGSoundDecoder()
; UseFLACSoundDecoder()
; 
; File$=OpenFileRequester("Load wav-file","*.wav","wav-file |*.ogg",0) 
; 
; Result=LoadSound(1,File$)
; 
; If Result=0:MessageRequester("ERROR","Can't load sound."):End:EndIf
; 
; OpenWindow(1,0,0,400,25,"Play",#PB_Window_MinimizeGadget|#PB_Window_SystemMenu|#PB_Window_ScreenCentered)
; 
; Debug IsSoundPlaying(1)
; 
; PlaySound(1)
; Debug IsSoundPlaying(1)
; Repeat
;   Event=WaitWindowEvent(1)
;  ; For t=0 To 100 Step 4
;   If Random(50)=5
;   PauseSound(1)
;   Debug IsSoundPlaying(1)
;   ;Delay(100)
;   ResumeSound(1)
;   EndIf
; ;Next
; ;End
;   
;   SetWindowTitle(1,Str(GetSoundPosition(1)));+"/"+Str(GetSoundSize(1)))
; Until Event=#PB_Event_CloseWindow Or IsSoundPlaying(1)=0


;}

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 139
; FirstLine = 128
; Folding = -
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
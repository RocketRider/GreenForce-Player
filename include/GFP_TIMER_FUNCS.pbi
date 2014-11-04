;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************


#THREAD_MODE_BACKGROUND_BEGIN   = $00010000
#THREAD_MODE_BACKGROUND_END     = $00020000

Global TIMER_timecaps.TIMECAPS
Global TIMER_TLSIndex = #TLS_OUT_OF_INDEXES
Global TIMER_Initalized = #False

Procedure TIMER_Init()
  If TIMER_Initalized = #False
    timeGetDevCaps_(TIMER_timecaps,SizeOf(TIMECAPS))  
    timeBeginPeriod_(TIMER_timecaps\wPeriodMin)
    TIMER_TLSIndex = TlsAlloc_()  
    If TIMER_TLSIndex <> #TLS_OUT_OF_INDEXES
      TIMER_Initalized = #True
    EndIf  
  EndIf
  ProcedureReturn TIMER_Initalized
EndProcedure

Procedure __TIMER_Wait(ns.i)
  Protected nsCount.i, msCount.i
  nsCount = TlsGetValue_(TIMER_TLSIndex)
  nsCount + ns
  msCount = nsCount / 1000
  If msCount > 0
    Sleep_(msCount)
  Else
    !PAUSE
  EndIf
  nsCount - msCount * 1000
  TlsSetValue_(TIMER_TLSIndex, nsCount)
EndProcedure  

Procedure TIMER_Wait(ns.q)
  Protected time
  If TIMER_Initalized
    If ns > 0
      !PAUSE
      Repeat
        !PAUSE     
        If ns >= 100000
          __TIMER_Wait(100000)
          ns - 100000
        Else
          __TIMER_Wait(ns)    
          ns=0
        EndIf   
      Until ns = 0
    Else
      !PAUSE
    EndIf
  Else
    ;Fallback...
    time.i = ns/1000
    If time > 0
      Sleep_(time)
    Else
      !PAUSE
    EndIf  
  EndIf
EndProcedure  


Procedure TIMER_Free()
  If TIMER_Initalized  
    timeEndPeriod_(TIMER_timecaps\wPeriodMin)
    TlsFree_(TIMER_TLSIndex)
    TIMER_Initalized = #False
  EndIf
EndProcedure

Procedure TIMER_BeginBackgroundMode()
  SetThreadPriority_(GetCurrentThread_(), #THREAD_MODE_BACKGROUND_BEGIN)
EndProcedure  


Procedure TIMER_EndBackgroundMode()
  SetThreadPriority_(GetCurrentThread_(), #THREAD_MODE_BACKGROUND_END)
EndProcedure  

; 
; start=GetTickCount_()
; 
; ;TIMER_BeginBackgroundMode()
; For Z=0 To 1000000
; For T=0 To 1000000
; Next  
; Next
; ;TIMER_EndBackgroundMode()
; Ende= GetTickCount_()-start
;  MessageRequester("",Str(ende))
; ; TIMER_Init()
; ; 
; ; 
; ; For t=0 To 1000000
; ;   TIMER_Wait(12)
; ; Next  
; ; 
; 

; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 4
; Folding = --
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
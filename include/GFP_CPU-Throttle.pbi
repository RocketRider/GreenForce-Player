;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
DisableExplicit
#FACTOR = 10

Procedure ThPause(Thread)
timecaps.TIMECAPS
timeGetDevCaps_(timecaps,SizeOf(TIMECAPS))  
timeBeginPeriod_(timecaps\wPeriodMin)
Repeat  
  SuspendThread_(Thread)
  Sleep_(#FACTOR)  
  ResumeThread_(Thread)
  Sleep_(1)
ForEver
  timeEndPeriod_(timecaps\wPeriodMin)
EndProcedure

Procedure Throttle_CPU()
  DuplicateHandle_(GetCurrentProcess_(),GetCurrentThread_(), GetCurrentProcess_(),@Thread, #THREAD_GET_CONTEXT, #False,#DUPLICATE_SAME_ACCESS)
  TH=CreateThread(@ThPause(),Thread)  
EndProcedure 

Throttle_CPU()




; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 26
; Folding = -
; EnableXP
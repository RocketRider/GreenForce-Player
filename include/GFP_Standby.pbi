;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2017 RocketRider *******
;***************************************
EnableExplicit


#ES_AWAYMODE_REQUIRED = $00000040
#ES_CONTINUOUS 		    = $80000000
#ES_DISPLAY_REQUIRED  = $00000002
#ES_SYSTEM_REQUIRED   = $00000001

Prototype SetThreadExecutionState(flags)

Procedure DisAllowStandby(disallow)
	Protected SetThreadExecutionState.SetThreadExecutionState = GetProcAddress_(GetModuleHandle_("Kernel32.dll"), "SetThreadExecutionState")
	If SetThreadExecutionState
		If disallow
		  SetThreadExecutionState(#ES_CONTINUOUS | #ES_SYSTEM_REQUIRED | #ES_AWAYMODE_REQUIRED | #ES_DISPLAY_REQUIRED)
		Else
		  SetThreadExecutionState(#ES_CONTINUOUS)
		EndIf
	EndIf
EndProcedure

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 21
; Folding = -
; EnableXP
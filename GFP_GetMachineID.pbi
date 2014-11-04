;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************
EnableExplicit

XIncludeFile "include\GFP_MachineID.pbi"

CoInitialize_(0)
InputRequester("GreenForce-Player machine ID", "Your machine ID:", machineID(0))
CoUninitialize_()


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 3
; EnableUnicode
; EnableThread
; EnableXP
; UseIcon = data\GFP.ico
; Executable = GFP-SDK\MachineID\MachineID.exe
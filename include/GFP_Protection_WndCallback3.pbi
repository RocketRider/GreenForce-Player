;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

EnableExplicit
#DISPLAY_DEVICE_ATTACHED_TO_DESKTOP = $1 
#DISPLAY_DEVICE_MULTI_DRIVER        = $2 
#DISPLAY_DEVICE_PRIMARY_DEVICE      = $4 
#DISPLAY_DEVICE_MIRRORING_DRIVER    = $8 
#DISPLAY_DEVICE_VGA_COMPATIBLE      = $10 
#DISPLAY_DEVICE_REMOVABLE           = $20 
#DISPLAY_DEVICE_MODESPRUNED         = $8000000 
#DISPLAY_DEVICE_REMOTE              = $4000000 
#DISPLAY_DEVICE_DISCONNECT          = $2000000 
#DISPLAY_DEVICE_ACTIVE              = $1 
#DISPLAY_DEVICE_ATTACHED            = $2 

;#ENUM_CURRENT_SETTINGS = -1 
;#ENUM_REGISTRY_SETTINGS = -2 


;Detects mirror drivers
Procedure __SearchMirrorDrivers()
  Protected bResult, device.DISPLAY_DEVICE, settings.DEVMODE, n.i, DC.i
  bResult = #False
  device.DISPLAY_DEVICE
  device\cb = SizeOf(DISPLAY_DEVICE) 
  settings.DEVMODE
  settings\dmSize = SizeOf(settings) 
  settings\dmDriverExtra = 0 
          
  While EnumDisplayDevices_(0,n,@device,0) > 0
    n + 1
    If device\StateFlags & #DISPLAY_DEVICE_MIRRORING_DRIVER And device\StateFlags & #DISPLAY_DEVICE_ATTACHED_TO_DESKTOP
      ; Active mirror driver!
      If EnumDisplaySettings_(@device\DeviceName, #ENUM_CURRENT_SETTINGS, @settings)     
        If settings\dmPelsWidth > 1 Or settings\dmPelsHeight > 1  
;           ;First draw a black box on the mirror driver
;           DC.i = CreateDC_(@device\DeviceName,0,0,0)
;           If DC 
;             BitBlt_(DC, 0, 0, settings\dmPelsWidth, settings\dmPelsHeight, 0 , 0, 0, #BLACKNESS)
;             DeleteDC_(DC)
;           EndIf
;           ;then change the resolution of the mirror driver
;           settings\dmFields = #DM_PELSWIDTH | #DM_PELSHEIGHT
;           settings\dmPelsWidth = 1
;           settings\dmPelsHeight = 1
;           ChangeDisplaySettingsEx_(@device\DeviceName, settings, #Null, 0, #Null)     
          bResult = #True    
        EndIf     
      EndIf 
    EndIf
  Wend
  ProcedureReturn bResult
EndProcedure

Procedure __cbWnd(hWnd.i, Msg.i, wParam.i, lParam.i)
  Protected *CB, oldCB.i
  
  ;Debug "protection callback running...."
  If Msg = #WM_PRINT ;Or #WM_PRINTCLIENT  ;WM_PRINTCLIENT hangs application
    If GetProp_(hWnd, "Win7Protection") = #False ; 2011-04-08 only if no new win 7 protection active...
      ;Do nothing
      ProcedureReturn #True
    EndIf
  EndIf
  
  If Msg = #WM_TIMER And wParam = 1349993282 ;'PwCB'
    ;Debug "protection timer running..."
    
    If GetProp_(hWnd, "DetectMirrorDrivers")
      ;Debug "Check Mirror Drivers"
      ;Time to detect mirror devices
      If __SearchMirrorDrivers()
        *CB = GetProp_(hWnd, "EndAppCB")
        If *CB
          CallFunctionFast(*CB)
        EndIf
      EndIf  
    EndIf
    
    If GetProp_(hWnd, "CheckDWM")
      ;Debug "Check DWM"
      If DWM_IsEnabled() = #False And GetProp_(hWnd, "Win7Protection")
        
        SetProp_(hWnd, "CheckDWM", #False)
        ;First try to swith to Vista protection....
        If __ChangeDWMProtection(hWnd) = #False   
          ; If failed then terminate!
          *CB = GetProp_(hWnd, "EndAppCB")
          If *CB
            CallFunctionFast(*CB)
          EndIf                        
        EndIf  

      EndIf  
    EndIf  
    ProcedureReturn #False   
  EndIf
  
  oldCB.i = GetProp_(hWnd, "ProtectWndCB")
  If oldCB
    ProcedureReturn CallWindowProc_(oldCB, hWnd.i, Msg.i, wParam.i, lParam.i)
  Else
    ProcedureReturn DefWindowProc_(hWnd.i, Msg.i, wParam.i, lParam.i)
  EndIf
EndProcedure

Procedure InstallCallBack(hWnd.i, bDetectMirrorDriver.i, bCheckDWM.i, *EndAppCB)
  Protected oldCB.i
  If hWnd
  
    oldCB = GetWindowLongPtr_(hWnd, #GWLP_WNDPROC)
    
    If oldCB
      SetProp_(hWnd, "ProtectWndCB", oldCB)
      SetProp_(hWnd, "EndAppCB", *EndAppCB)
      
      If bCheckDWM
        SetProp_(hWnd, "CheckDWM", #True)
      Else
        SetProp_(hWnd, "CheckDWM", #False)        
      EndIf  
      
      SetWindowLongPtr_(hWnd, #GWLP_WNDPROC, @__cbWnd())
      If bDetectMirrorDriver
        SetProp_(hWnd, "DetectMirrorDrivers" ,#True)
        If __SearchMirrorDrivers()
          If *EndAppCB
            CallFunctionFast(*EndAppCB)
          EndIf
        EndIf
      Else
        SetProp_(hWnd, "DetectMirrorDrivers" ,#False)
      EndIf
      SetTimer_(hWnd, 1349993282, 50, #Null)   ; 'PwCB'    
      ProcedureReturn #True   
    EndIf
  
  EndIf
  ProcedureReturn #False
EndProcedure


Procedure UnInstallCallBack(hWnd.i)
  Protected oldCB.i
  If hWnd
    oldCB.i = GetProp_(hWnd, "ProtectWndCB")
    If oldCB
      If SetWindowLongPtr_(hWnd, #GWLP_WNDPROC, oldCB)
        RemoveProp_(hWnd, "ProtectWndCB")
        RemoveProp_(hWnd, "EndAppCB")
        RemoveProp_(hWnd, "DetectMirrorDrivers")
        RemoveProp_(hWnd, "CheckDWM")
      EndIf
    EndIf
    KillTimer_(hWnd, 1349993282) ; 'PwCB'
  EndIf
EndProcedure
; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = -
; EnableXP
; EnableCompileCount = 3
; EnableBuildCount = 0
; EnableExeConstant
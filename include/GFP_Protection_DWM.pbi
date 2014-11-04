;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
#DWMFLIP3D_DEFAULT = 0
#DWMFLIP3D_EXCLUDEBELOW = 1
#DWMFLIP3D_EXCLUDEABOVE = 2
 
#DWMWA_FLIP3D_POLICY = 8
#DWMWA_FORCE_ICONIC_REPRESENTATION = 7

#DWM_EC_DISABLECOMPOSITION = 0
#DWM_EC_ENABLECOMPOSITION = 1

Prototype.i __DwmIsCompositionEnabled(*ptrEnabled)
Prototype.i __DwmEnableComposition(enable.i)  
Prototype.i __DwmSetWindowAttribute(hwnd.i ,dwAttribute.i ,pvAttribute.i ,iSize.i)

Structure GLOBAL_DWM
  DWMModule.i
  DwmIsCompositionEnabled.__DwmIsCompositionEnabled
  DwmEnableComposition.__DwmEnableComposition
  DwmSetWindowAttribute.__DwmSetWindowAttribute
EndStructure

Global g_DWM.GLOBAL_DWM

Procedure DWM_IsEnabled()
  Protected bDWMEnabled.i
  bDWMEnabled.i = #False
  If g_DWM\DwmIsCompositionEnabled
    g_DWM\DwmIsCompositionEnabled(@bDWMEnabled)
  EndIf
  ProcedureReturn bDWMEnabled
EndProcedure

Procedure DWM_Enable(enable.i)
  Protected iResult.i
  iResult = #E_FAIL 
  If g_DWM\DwmEnableComposition
    iResult = g_DWM\DwmEnableComposition(enable)
  EndIf
  ProcedureReturn iResult
EndProcedure


Procedure DWM_Init()
  If g_DWM\DWMModule = #Null
    g_DWM\DWMModule = LoadLibrary_("dwmapi.dll")
    If g_DWM\DWMModule
      g_DWM\DwmIsCompositionEnabled = GetProcAddress_(g_DWM\DWMModule, "DwmIsCompositionEnabled")
      g_DWM\DwmEnableComposition = GetProcAddress_(g_DWM\DWMModule, "DwmEnableComposition")
      g_DWM\DwmSetWindowAttribute = GetProcAddress_(g_DWM\DWMModule, "DwmSetWindowAttribute")
    EndIf
  EndIf
EndProcedure

Procedure DWM_Free()
  If g_DWM\DWMModule
    FreeLibrary_(g_DWM\DWMModule)
    g_DWM\DwmIsCompositionEnabled = #Null
    g_DWM\DwmEnableComposition = #Null
    g_DWM\DwmSetWindowAttribute = #Null
  EndIf
EndProcedure

Procedure DWM_DisableFlip3DAndThumbnail(hWnd.i)
  Protected value.i
  If g_DWM\DwmSetWindowAttribute
    value.i = #DWMFLIP3D_EXCLUDEABOVE
    If g_DWM\DwmSetWindowAttribute(hWnd, #DWMWA_FLIP3D_POLICY, @value, SizeOf(Integer)) = #S_OK
      value.i = #True
      If g_DWM\DwmSetWindowAttribute(hWnd, #DWMWA_FORCE_ICONIC_REPRESENTATION, @value, SizeOf(Integer)) = #S_OK
        ProcedureReturn #True
      EndIf
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure DWM_EnableFlip3DAndThumbnail(hWnd.i)
  Protected value.i
  If g_DWM\DwmSetWindowAttribute
    value.i = #DWMFLIP3D_DEFAULT
    If g_DWM\DwmSetWindowAttribute(hWnd, #DWMWA_FLIP3D_POLICY, @value, SizeOf(Integer)) = #S_OK
      value.i = #False
      If g_DWM\DwmSetWindowAttribute(hWnd, #DWMWA_FORCE_ICONIC_REPRESENTATION, @value, SizeOf(Integer)) = #S_OK
        ProcedureReturn #True
      EndIf
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure




; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = A-
; DisableDebugger
; EnableCompileCount = 2
; EnableBuildCount = 0
; EnableExeConstant
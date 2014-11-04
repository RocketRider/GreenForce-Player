;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

; Procedure DWM_IsEnabled()
;   ProcedureReturn 1
; EndProcedure

#WDA_MONITOR = 1
Prototype SetWindowDisplayAffinity(hwnd.i, dwAffinity)

Structure GLOBAL_USER
  user32.i
  SetWindowDisplayAffinity.SetWindowDisplayAffinity
EndStructure

Global g_USER.GLOBAL_USER 

Procedure USER_Init()
  g_USER\user32 = LoadLibrary_("user32.dll")
  If g_USER\user32
    g_USER\SetWindowDisplayAffinity = GetProcAddress_(g_USER\user32, ReplaceString("SetName", "Name", "Window") + ReplaceString(ReplaceString("Volume Information", "Volume", "Display"), " Information", "Affinity") ); "SetWindowDisplayAffinity"
  EndIf
  ProcedureReturn g_USER\SetWindowDisplayAffinity
EndProcedure

Procedure USER_EnableHWNDProtection(hWnd) ;This function succeeds only when the window is layered and Desktop Windows Manager is composing the desktop. 
  Protected bResult = #False
  If DWM_IsEnabled()
    If g_USER\SetWindowDisplayAffinity
      If g_USER\SetWindowDisplayAffinity(hWnd, #WDA_MONITOR)
        SetProp_(hWnd, "Win7Protection", #True)
        bResult = #True
      EndIf  
    EndIf  
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure USER_DisableHWNDProtection(hWnd)
  Protected bResult = #False
  If g_USER\SetWindowDisplayAffinity
    If GetProp_(hWnd, "Win7Protection")
      If g_USER\SetWindowDisplayAffinity(hWnd, 0)
        RemoveProp_(hWnd, "Win7Protection")
        bResult = #True
      EndIf  
    EndIf
  EndIf  
  ProcedureReturn bResult  
EndProcedure

Procedure USER_IsProtectionPossible()
  If g_USER\SetWindowDisplayAffinity
    If DWM_IsEnabled()
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure
  
; Procedure USER_IsWindowProtectionEnabled(hWnd)
;   If GetProp_(hWnd, "Win7Protection")
;     ProcedureReturn #True
;   Else
;     ProcedureReturn #False
;   EndIf
; EndProcedure
; 
; Procedure USER_IsWindowProtectionWorking(hWnd)
;   Protected bResult = #False
;   If GetProp_(hWnd, "Win7Protection")
;     If DWM_IsEnabled()
;       bResult = #True
;     EndIf  
;   EndIf  
;   Debug bResult
;   ProcedureReturn bResult
; EndProcedure  

Procedure USER_Free()
  If g_USER\user32
    g_USER\SetWindowDisplayAffinity = #Null
    FreeLibrary_(g_USER\user32)
  EndIf  
  g_USER\user32 = #Null
EndProcedure


; USER_Init()
; 
;   Procedure NavigationCallback(Gadget, Url$) 
;     If Url$= "http://www.purebasic.com/news.php" 
;       MessageRequester("", "No news today!") 
;       ProcedureReturn #False 
;     Else 
;       ProcedureReturn #True 
;     EndIf 
;   EndProcedure 
;   
;   If OpenWindow(0, 0, 0, 600, 300, "WebGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered) 
;     Debug USER_EnableHWNDProtection(WindowID(0))
;     WebGadget(0, 10, 10, 580, 280, "http://www.purebasic.com") 
;     SetGadgetAttribute(0, #PB_Web_NavigationCallback, @NavigationCallback())
;     Repeat 
;       If USER_IsProtectionWorking(WindowID(0)) = #False
;         !INT 3
;       EndIf  
;     Until WaitWindowEvent(50) = #PB_Event_CloseWindow 
;   EndIf


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 106
; Folding = -
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
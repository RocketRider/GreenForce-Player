;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************


Declare __ChangeDWMProtection(hWnd)
  

XIncludeFile "GFP_Protection_DWM.pbi"
XIncludeFile "GFP_Protection_Misc.pbi"
XIncludeFile "GFP_Protection_User.pbi"
XIncludeFile "GFP_Protection_WndCallback3.pbi"
EnableExplicit

Structure GLOBAL_PROTECTION
  bInitalized.i
  ;hModule.i
  bDWMDisabled.i
  bHotkeysDisabled.i
  iCountProtectedWindows.i
  iErrorCode.i
EndStructure

Enumeration
  #PROTECTION_ERR_OK
  #PROTECTION_ERR_NOLAYEREDWINDOW
  ;#PROTECTION_ERR_CANTCREATETEMPFILE
  ;#PROTECTION_ERR_CANTLOADTEMPFILE
  ;#PROTECTION_ERR_CANTINSTALLHOOK
  #PROTECTION_ERR_NOVALIDWINDOWHANDLE
  #PROTECTION_ERR_INITIALIZATIONFALIED
  #PROTECTION_ERR_ALREADYPROTECTED
  #PROTECTION_ERR_INVALIDPARAMETER
EndEnumeration


Global g_Protection.GLOBAL_PROTECTION


#PROTECT_DISABLEPRINTHOTKEYS = 1
;It is highly recommended to use this flag. However this completly deactivates the printscreen hotkeys.

#PROTECT_FORCELAYEREDWINDOW = 2
;Turns the window handle in a layered window 

#PROTECT_ENABLECONTENTPROTECTION = 4
;Turns the window into a mirrored window (Vista and above) or turns on new Windows  7 / Server 2008 R2 protection


#PROTECT_DETECTMIRRORDRIVERS = 16
;Detect if mirror driver are active and calls the callback funtion in this case


Procedure __ChangeDWMProtection(hWnd)
  Protected bResult.i = #False
  If IsWindow_(hWnd)   
    USER_DisableHWNDProtection(hWnd)   
    If MAGNIFICATION_Add(hWnd)
      If g_Protection\bDWMDisabled = #False
        If DWM_Enable(#False) = #S_OK
          g_Protection\bDWMDisabled = #True
          bResult = #True
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure
        
        
        

ProcedureDLL.i ProtectWindow(hWnd.i, iFlags.i, *EndAppCB)
  Protected iErrorCode = #PROTECTION_ERR_OK, bWin7Protection = #False
  If g_Protection\bInitalized
    If IsWindow_(hWnd)
      
      If GetProp_(hWnd, "ProtectWndCB") = #Null
        
        If (iFlags & #PROTECT_ENABLECONTENTPROTECTION) Or (iFlags & #PROTECT_FORCELAYEREDWINDOW)
          If ForceLayeredWindow(hWnd) = #False
            iErrorCode = #PROTECTION_ERR_NOLAYEREDWINDOW
          EndIf
        EndIf
              
        If iErrorCode = #PROTECTION_ERR_OK          
          
          If iFlags & #PROTECT_ENABLECONTENTPROTECTION     
            ;Use new WIndows 7 protection if possible
            If USER_IsProtectionPossible()
              bWin7Protection = #True
            Else   
              bWin7Protection = #False
            EndIf  
            
            If bWin7Protection
              USER_EnableHWNDProtection(hWnd)
            Else         
              ;Disable DWM if not already disabled
              If g_Protection\bDWMDisabled = #False
                DWM_Enable(#False)
                g_Protection\bDWMDisabled = #True
              EndIf
              
              If DWM_IsEnabled() = #False
                 MAGNIFICATION_Add(hWnd) ; Call only if aero is disabled or no aero!!!! (flackert ansonsten!)
              EndIf 
            EndIf           
          EndIf  
          
          If iFlags & #PROTECT_DISABLEPRINTHOTKEYS And g_Protection\bHotkeysDisabled = #False
            g_Protection\bHotkeysDisabled = #True
            DisablePrintHotkeys()
          EndIf
                
          If iFlags & #PROTECT_DETECTMIRRORDRIVERS
            InstallCallBack(hWnd, #True, bWin7Protection, *EndAppCB)
          Else
            InstallCallBack(hWnd, #False, bWin7Protection, *EndAppCB)
          EndIf
     
          SetProp_(hWnd, "Protect", #True)
          g_Protection\iCountProtectedWindows + 1                            
        EndIf       

      Else
        iErrorCode = #PROTECTION_ERR_ALREADYPROTECTED
      EndIf  
        
    Else
      iErrorCode = #PROTECTION_ERR_NOVALIDWINDOWHANDLE
    EndIf
  Else
    iErrorCode = #PROTECTION_ERR_INITIALIZATIONFALIED    
  EndIf  
  
  If iErrorCode <> #PROTECTION_ERR_OK
    g_Protection\iErrorCode = iErrorCode
    ProcedureReturn #False
  Else
    g_Protection\iErrorCode = #PROTECTION_ERR_OK
    ProcedureReturn #True    
  EndIf  
EndProcedure


ProcedureDLL.i UnProtectWindow(hWnd.i)
  Protected iErrorCode.i = #PROTECTION_ERR_OK
  
  If g_Protection\bInitalized
    If IsWindow_(hWnd)
      If GetProp_(hWnd, "Protect") = #True
        
        UnInstallCallBack(hWnd)     
        ;DWM_EnableFlip3DAndThumbnail(hWnd)      
        ;If GetProp_(hWnd, "Win7Protection")
        USER_DisableHWNDProtection(hWnd)  
        ;Else  
        MAGNIFICATION_Remove(hWnd)
        ;EndIf  
        RestoreLayeredWindow(hWnd)
        
        RemoveProp_(hWnd, "Protect")
        
        g_Protection\iCountProtectedWindows - 1
        
        If g_Protection\iCountProtectedWindows <= 0     
          If g_Protection\bDWMDisabled
            DWM_Enable(#True)
            g_Protection\bDWMDisabled = #False
          EndIf     
          
          If g_Protection\bHotkeysDisabled
            EnablePrintHotkeys()
            g_Protection\bHotkeysDisabled = #False
          EndIf      
        EndIf
        ProcedureReturn #True
      EndIf
      
    Else
      iErrorCode = #PROTECTION_ERR_NOVALIDWINDOWHANDLE
    EndIf
  Else
    iErrorCode = #PROTECTION_ERR_INITIALIZATIONFALIED
  EndIf
  
  If iErrorCode <> #PROTECTION_ERR_OK
    g_Protection\iErrorCode = iErrorCode
    ProcedureReturn #False
  Else
    g_Protection\iErrorCode = #PROTECTION_ERR_OK
    ProcedureReturn #True    
  EndIf   
EndProcedure
  
  




; #PROTECT_DISABLEPRINTHOTKEYS = 1
; ;It is highly recommended to use this flag. However this completly deactivates the printscreen hotkeys.
; #PROTECT_DISABLEDWM = 4 ; (Only supported layered windows in ProtectWindowEx)
; ;forces DWM to be disabled while the application is running. This is needed because if Aero is used some protection methods are not working.
; ;You should at least eigher use this flag or PROTECT_INSTALLHOOK to protect your window. 
; #PROTECT_DETECTMIRRORDRIVERS = 8
; 
; ProcedureDLL.i ProtectWindow(hWnd.i, iFlags.i, *EndAppCB)
;   If g_Protection\bInitalized = #False
;     g_Protection\iErrorCode = #PROTECTION_ERR_INITIALIZATIONFALIED
;     ProcedureReturn #False
;   EndIf
; 
;   If IsWindow_(hWnd)
;     
;     If GetProp_(hWnd, "ProtectWndCB")
;       ProcedureReturn #PROTECTION_ERR_ALREADYPROTECTED
;     EndIf
;     
;     g_Protection\iErrorCode = #PROTECTION_ERR_OK
;     
;     
;     If iFlags & #PROTECT_DISABLEDWM  ; 2010-05-29 ansonsten Problem mit Screenshot Schutz "Active"
;       ;2010-04-04 Vorrest wieder hereingenommen
;       If ForceLayeredWindow(hWnd) = #False
;         g_Protection\iErrorCode = #PROTECTION_ERR_NOLAYEREDWINDOW
;         ProcedureReturn #False
;       EndIf
;     EndIf
;     
;     SetProp_(hWnd, "Protect", #True)
;     g_Protection\iCountProtectedWindows + 1
;     
;      If iFlags & #PROTECT_DISABLEDWM And g_Protection\bDWMDisabled = #False
;        DWM_Enable(#False)
;        g_Protection\bDWMDisabled = #True
;      EndIf    
;      ;     
;      
;       ;2010-04-04 Vorrest wieder hereingenommen
;      If iFlags & #PROTECT_DISABLEDWM Or DWM_IsEnabled() = #False
;        MAGNIFICATION_Add(hWnd) ; Call only if aero is disabled or no aero!!!! (flackert ansonsten!)
;      EndIf
;     
;     
;     If iFlags & #PROTECT_DISABLEPRINTHOTKEYS And g_Protection\bHotkeysDisabled = #False
;       g_Protection\bHotkeysDisabled = #True
;       DisablePrintHotkeys()
;     EndIf
;     
;     If iFlags & #PROTECT_DETECTMIRRORDRIVERS
;       InstallCallBack(hWnd, #True, *EndAppCB)
;     Else
;       InstallCallBack(hWnd, #False, *EndAppCB)
;     EndIf
; 
;     ;DWM_DisableFlip3DAndThumbnail(hWnd)
;     
;     ProcedureReturn #True
;   Else
;     g_Protection\iErrorCode = #PROTECTION_ERR_NOVALIDWINDOWHANDLE
;     ProcedureReturn #False
;   EndIf
; EndProcedure
; 
; 
; ProcedureDLL.i ProtectWindowEx(hWnd.i, iFlags.i, *EndAppCB)
;   If g_Protection\bInitalized = #False
;     g_Protection\iErrorCode = #PROTECTION_ERR_INITIALIZATIONFALIED
;     ProcedureReturn #False
;   EndIf
; 
;   If IsWindow_(hWnd)
;     
;     If GetProp_(hWnd, "ProtectWndCB")
;       ProcedureReturn #PROTECTION_ERR_ALREADYPROTECTED
;     EndIf
;     
;     g_Protection\iErrorCode = #PROTECTION_ERR_OK
;     
;     If ForceLayeredWindow(hWnd) = #False
;       g_Protection\iErrorCode = #PROTECTION_ERR_NOLAYEREDWINDOW
;       ProcedureReturn #False
;     EndIf
;     
;     SetProp_(hWnd, "Protect", #True)
;     g_Protection\iCountProtectedWindows + 1
;     
;     If iFlags & #PROTECT_DISABLEDWM And g_Protection\bDWMDisabled = #False
;       DWM_Enable(#False)
;       g_Protection\bDWMDisabled = #True
;     EndIf    
;     
;     If iFlags & #PROTECT_DISABLEDWM Or DWM_IsEnabled() = #False
;       MAGNIFICATION_Add(hWnd) ; Call only if aero is disabled or no aero!!!! (flackert ansonsten!)
;     EndIf
;     
;     
;     If iFlags & #PROTECT_DISABLEPRINTHOTKEYS And g_Protection\bHotkeysDisabled = #False
;       g_Protection\bHotkeysDisabled = #True
;       DisablePrintHotkeys()
;     EndIf
;     
;     If iFlags & #PROTECT_DETECTMIRRORDRIVERS
;       InstallCallBack(hWnd, #True, *EndAppCB)
;     Else
;       InstallCallBack(hWnd, #False, *EndAppCB)
;     EndIf
; 
;     DWM_DisableFlip3DAndThumbnail(hWnd)
;     
;     ProcedureReturn #True
;   Else
;     g_Protection\iErrorCode = #PROTECTION_ERR_NOVALIDWINDOWHANDLE
;     ProcedureReturn #False
;   EndIf
; EndProcedure
; 
; 
; ProcedureDLL.i UnProtectWindow(hWnd.i)
;   If g_Protection\bInitalized = #False
;     g_Protection\iErrorCode = #PROTECTION_ERR_INITIALIZATIONFALIED
;     ProcedureReturn #False
;   EndIf
; 
;   If IsWindow_(hWnd)
;     If GetProp_(hWnd, "Protect") = #True
;       RemoveProp_(hWnd, "Protect")
;       UnInstallCallBack(hWnd)
;       ;DWM_EnableFlip3DAndThumbnail(hWnd)
;       RestoreLayeredWindow(hWnd) ; 2010-04-11 Wieder rein
;       MAGNIFICATION_Remove(hWnd) ; 2010-04-11 Wieder rein
;       g_Protection\iCountProtectedWindows - 1
;       
;       If g_Protection\iCountProtectedWindows <= 0
;       
;          If g_Protection\bDWMDisabled
;            DWM_Enable(#True)
;            g_Protection\bDWMDisabled = #False
;          EndIf     
;         
;         If g_Protection\bHotkeysDisabled
;           EnablePrintHotkeys()
;           g_Protection\bHotkeysDisabled = #False
;         EndIf
;         
;       EndIf
;       ProcedureReturn #True
;     EndIf
;     
;   Else
;     g_Protection\iErrorCode = #PROTECTION_ERR_NOVALIDWINDOWHANDLE
;     ProcedureReturn #False
;   EndIf
; EndProcedure
; 
; 
; ProcedureDLL.i UnProtectWindowEx(hWnd.i)
;   If g_Protection\bInitalized = #False
;     g_Protection\iErrorCode = #PROTECTION_ERR_INITIALIZATIONFALIED
;     ProcedureReturn #False
;   EndIf
; 
;   If IsWindow_(hWnd)
;     If GetProp_(hWnd, "Protect") = #True
;       RemoveProp_(hWnd, "Protect")
;       UnInstallCallBack(hWnd)
;       DWM_EnableFlip3DAndThumbnail(hWnd)
;       RestoreLayeredWindow(hWnd)
;       MAGNIFICATION_Remove(hWnd)
;       g_Protection\iCountProtectedWindows - 1
;       
;       If g_Protection\iCountProtectedWindows <= 0
;       
;         If g_Protection\bDWMDisabled
;           DWM_Enable(#True)
;           g_Protection\bDWMDisabled = #False
;         EndIf     
;         
;         If g_Protection\bHotkeysDisabled
;           EnablePrintHotkeys()
;           g_Protection\bHotkeysDisabled = #False
;         EndIf
;         
;       EndIf
;       ProcedureReturn #True
;     EndIf
;     
;   Else
;     g_Protection\iErrorCode = #PROTECTION_ERR_NOVALIDWINDOWHANDLE
;     ProcedureReturn #False
;   EndIf
; EndProcedure
; 


ProcedureDLL.i GetProtectionLastError()
  ProcedureReturn g_Protection\iErrorCode
EndProcedure


ProcedureDLL InitWindowProtector()
  DWM_Init()
  MAGNIFICATION_Init()
  USER_Init()
  g_Protection\bDWMDisabled = #False
  g_Protection\bHotkeysDisabled = #False
  ;g_Protection\hModule = #Null  
  g_Protection\iCountProtectedWindows = 0
  g_Protection\bInitalized = #True
EndProcedure

ProcedureDLL FreeWindowProtector()
  If g_Protection\bDWMDisabled
    DWM_Enable(#True)
    g_Protection\bDWMDisabled = #False
  EndIf
  
  If g_Protection\bHotkeysDisabled
    EnablePrintHotkeys()
    g_Protection\bHotkeysDisabled = #False
  EndIf
  
  g_Protection\bInitalized = #False
  g_Protection\iCountProtectedWindows = 0
  
  USER_Free()
  MAGNIFICATION_Free()
  DWM_Free()
EndProcedure















;{ Example



; DisableExplicit
; Procedure EndProgram()
;   CloseWindow(0)
;  MessageRequester("","OUT OF MEMORY!") 
; EndProcedure
; InitWindowProtector()
; If OpenWindow(0, 100, 200, 195, 260, "PureBasic Window", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)
;   WebGadget(0, 10, 10, 580, 280, "http://www.purebasic.com")
;   
;   Debug ProtectWindow(WindowID(0), #PROTECT_DISABLEPRINTHOTKEYS | #PROTECT_DETECTMIRRORDRIVERS | #PROTECT_FORCELAYEREDWINDOW | #PROTECT_ENABLECONTENTPROTECTION, @EndProgram())
;   
; Debug GetProtectionLastError()
;   
;   Repeat
;     Event = WaitWindowEvent()
; 
;     If Event = #PB_Event_CloseWindow  ; If the user has pressed on the close button
;       Quit = 1
;     EndIf
; 
;   Until Quit = 1
;   
; EndIf
; 
; End   ; All the opened windows are closed automatically by PureBasic
; 
;}



; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 13
; FirstLine = 6
; Folding = --
; EnableXP
; Executable = WndProtector.exe
; EnableCompileCount = 19
; EnableBuildCount = 0
; EnableExeConstant
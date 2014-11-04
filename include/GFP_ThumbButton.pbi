;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

    
; Structure THUMBBUTTON
;   dwMask.l
;   iId.l
;   iBitmap.l
;   hIcon.i
;   szTip.u[260]
;   dwFlags.l
; EndStructure

; Interface ITaskbarList3 Extends ITaskbarList2
;   SetProgressValue(hWnd, Completed.q, Total.q)
;   SetProgressState(hWnd, Flags.l)
;   RegisterTab(hWndTab, hWndMDI)
;   UnregisterTab(hWndTab)
;   SetTabOrder(hWndTab, hwndInsertBefore)
;   SetTabActive(hWndTab, hWndMDI, dwReserved.l)
;   ThumbBarAddButtons(hWnd, cButtons, *pButtons)
;   ThumbBarUpdateButtons(hWnd, cButtons, *pButtons)
;   ThumbBarSetImageList(hWnd, himl)
;   SetOverlayIcon(hWnd, hIcon, pszDescription.s)
;   SetThumbnailTooltip(hWnd, pszTip.s)
;   SetThumbnailClip(hWnd, *prcClip.RECT)
; EndInterface

#TBPF_NoProgress    = $00
#TBPF_Indeterminate = $01
#TBPF_Normal        = $02
#TBPF_Error         = $04
#TBPF_Paused        = $08

#CLSCTX_INPROC_SERVER = 1
#CLSCTX_LOCAL_SERVER  = 4
#TB_CLSCTX_SERVER        = #CLSCTX_INPROC_SERVER | #CLSCTX_LOCAL_SERVER
#THB_BITMAP    = $00000001
#THB_ICON      = $00000002
#THB_TOOLTIP   = $00000004
#THB_FLAGS     = $00000008 

Procedure TB_Create()
  Protected *tb.ITaskbarList3, ret.i,*tb2
  ;If OSVersion()>=#PB_OS_Windows_7
    ret = CoCreateInstance_(?CLSID_TaskbarList, 0, #TB_CLSCTX_SERVER, ?IID_ITaskbarList3, @*tb)
    If ret = #S_OK And *tb
      ProcedureReturn *tb
    EndIf
  ;EndIf
  ProcedureReturn #Null
EndProcedure

Procedure TB_Free(*tb.ITaskbarList3)
  If *tb
    *tb\Release()
  EndIf  
EndProcedure  


Procedure TB_SetProgressState(*tb.ITaskbarList3, WindowID, State.i)
  If *tb
    *tb\SetProgressState(WindowID, State)
  EndIf  
EndProcedure

Procedure TB_SetProgressValue(*tb.ITaskbarList3, WindowID, State.i, Max.i)
  If *tb
    *tb\SetProgressValue(WindowID, State, Max)
  EndIf  
EndProcedure

Procedure TB_AddButtons(*tb.ITaskbarList3, WindowID, NumButtons.i, *Buttons)
  If *tb
     *tb\ThumbBarAddButtons(WindowID, NumButtons, *Buttons)
  EndIf  
EndProcedure

Procedure TB_UpdateButtons(*tb.ITaskbarList3, WindowID, NumButtons.i, *Buttons)
  If *tb
    *tb\ThumbBarUpdateButtons(WindowID, NumButtons, *Buttons)
  EndIf  
EndProcedure



;{ Sample
; 
; 
; 
;   Procedure WinCallback(hWnd, uMsg, wParam, lParam) 
;     ; Windows füllt die Parameter automatisch, welche wir im Callback verwenden...
;     
;     If uMsg = #WM_COMMAND
;       Debug wParam&$FFFF
;     EndIf  
;     
;     If uMsg = #WM_SIZE 
;       Select wParam 
;         Case #SIZE_MINIMIZED 
;           Debug "Fenster wurde minimiert"
;         Case #SIZE_RESTORED 
;           Debug "Fenster wurde wiederhergestellt"
;         Case #SIZE_MAXIMIZED 
;           Debug "Fenster wurde maximiert"
;       EndSelect 
;     EndIf 
;   
;     ProcedureReturn #PB_ProcessPureBasicEvents 
;   EndProcedure 
;   
;   
; 
; 
; 
; OpenWindow(0, 10, 0, 300, 50, "Test")
;     SetWindowCallback(@WinCallback())    ; Callback aktivieren
;     
; 
; CoInitialize_(0)
; 
; 
; *tb.ITaskbarList3=TB_Create()
; If *tb
;   TB_SetProgressState(*tb, WindowID(0), #TBPF_Normal)
;   
;   Dim Test.THUMBBUTTON(4)
;   Test(0)\iId=10
;   Test(0)\dwMask = #THB_ICON
;   Test(0)\hIcon = LoadIcon_(0,101)
;   
;   Test(1)\iId=11
;   Test(1)\dwMask = #THB_ICON
;   Test(1)\hIcon = LoadIcon_(0,101)
;   
;   Test(2)\iId=12
;   test(2)\dwMask = #THB_ICON
;   Test(2)\hIcon = LoadIcon_(0,101)
;   
;   Test(3)\iId=13
;   test(3)\dwMask = #THB_ICON
;   Test(3)\hIcon = LoadIcon_(0,101)
;   
;   TB_AddButtons(*tb, WindowID(0), 4, @Test())
; EndIf
; 
; i = 0
; Repeat
;   i + 1
;   TB_SetProgressValue(*tb, WindowID(0), i%5000, 5000)
;   
; 
;   Event = WindowEvent()
;  
;   Select Event
;     Case #PB_Event_CloseWindow
;       Break
;   EndSelect
;   Delay(1)
; ForEver
; 
; CoUninitialize_()
; 
; End
;}




DataSection
  CLSID_TaskbarList:
    ; 56FDF344-FD6D-11D0-958A-006097C9A090
    Data.l $56FDF344
    Data.w $FD6D, $11D0, $8A95
    Data.b $00, $60, $97, $C9, $A0, $90
    
  IID_ITaskbarList:
    ; {56FDF342-FD6D-11D0-958A-006097C9A090}
    Data.l $56FDF342
    Data.w $FD6D, $11D0, $8A95
    Data.b $00, $60, $97, $C9, $A0, $90
    
  IID_ITaskbarList2:
    ; {602D4995-B13A-429b-A66E-1935E44F4317}
    Data.l $602D4995
    Data.w $B13A, $429b, $A66E
    Data.b $19, $35, $E4, $4F, $43, $17
    
  IID_ITaskbarList3:
    ; {EA1AFB91-9E28-4B86-90E9-9E9F8A5EEFAF}
    Data.l $EA1AFB91
    Data.w $9E28, $4B86, $E990
    Data.b $9E, $9F, $8A, $5E, $EF, $af
    
EndDataSection
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 44
; Folding = --
; EnableXP
; EnableCompileCount = 61
; EnableBuildCount = 0
; EnableExeConstant
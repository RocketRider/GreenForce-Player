;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit


Structure PLAYER_TRACKBAR
  Gadget.i
  rect.RECT
  *OrginalCB
EndStructure

#CDDS_ITEM = $10000
#CDDS_PREPAINT = 1
#CDDS_ITEMPREPAINT = #CDDS_ITEM | #CDDS_PREPAINT
#CDDS_SUBITEM = $20000
#CDRF_DODEFAULT = 0
#CDRF_NOTIFYITEMDRAW = $20
#CDRF_SKIPDEFAULT = 4
#TBCD_CHANNEL = 3
#TBCD_THUMB = 2
#TBCD_TICS = 1


Procedure __CBTrackBar(hWnd, Msg, wParam, lParam)
  Protected pt.point, minimum.i, maximum.i, re.rect, iResult.i, PlayerTrackbar.PLAYER_TRACKBAR, iSize.i, iPos.i
  
  
  If GetProp_(hWnd, "player") 
    CopyMemory(GetProp_(hWnd, "player"), PlayerTrackbar, SizeOf(PLAYER_TRACKBAR))         
    If Msg = #WM_LBUTTONDOWN Or Msg = #WM_LBUTTONDBLCLK ;Or Msg = #WM_LBUTTONUP
        GetCursorPos_(pt.point)
        ScreenToClient_(hWnd, pt)
        If pt\x < PlayerTrackbar\rect\left And pt\y >= PlayerTrackbar\rect\top And pt\y < PlayerTrackbar\rect\bottom  
          SetGadgetState(PlayerTrackbar\Gadget, GetGadgetAttribute(PlayerTrackbar\Gadget, #PB_TrackBar_Minimum))
          SendMessage_(GetParent_(GadgetID(PlayerTrackbar\Gadget)), #WM_COMMAND, 2<<16 + GetDlgCtrlID_(GadgetID(PlayerTrackbar\Gadget)), GadgetID(PlayerTrackbar\Gadget))
          ;ProcedureReturn 0
        EndIf
        If pt\x > PlayerTrackbar\rect\right And pt\y >= PlayerTrackbar\rect\top And pt\y < PlayerTrackbar\rect\bottom  
          SetGadgetState(PlayerTrackbar\Gadget, GetGadgetAttribute(PlayerTrackbar\Gadget, #PB_TrackBar_Maximum))
          SendMessage_(GetParent_(GadgetID(PlayerTrackbar\Gadget)), #WM_COMMAND, 2<<16 + GetDlgCtrlID_(GadgetID(PlayerTrackbar\Gadget)), GadgetID(PlayerTrackbar\Gadget))
          ;ProcedureReturn 0
        EndIf  
        
        If pt\x >= PlayerTrackbar\rect\left And pt\x < PlayerTrackbar\rect\right And pt\y >= PlayerTrackbar\rect\top And pt\y < PlayerTrackbar\rect\bottom  
          iSize.i = GetGadgetAttribute(PlayerTrackbar\Gadget, #PB_TrackBar_Maximum) - GetGadgetAttribute(PlayerTrackbar\Gadget, #PB_TrackBar_Minimum)        
          iPos.i = GetGadgetAttribute(PlayerTrackbar\Gadget, #PB_TrackBar_Minimum) + (pt\x - PlayerTrackbar\rect\left) * iSize / (PlayerTrackbar\rect\right - PlayerTrackbar\rect\left)     
          SetGadgetState(PlayerTrackbar\Gadget, iPos) 
          SendMessage_(GetParent_(GadgetID(PlayerTrackbar\Gadget)), #WM_COMMAND, 2<<16 + GetDlgCtrlID_(GadgetID(PlayerTrackbar\Gadget)), GadgetID(PlayerTrackbar\Gadget))
          ;ProcedureReturn 0  
        EndIf 
        ;SetFocus_(hWnd) 
        ;CopyMemory(PlayerTrackbar, GetProp_(hWnd, "player"), SizeOf(PLAYER_TRACKBAR))       
    EndIf
    
    If Msg=#WM_SETFOCUS
      SetFocus_(GetParent_(hWnd))
    EndIf
    
    If Msg = #WM_DESTROY
      FreeMemory(GetProp_(hWnd, "player"))
      SetProp_(hWnd, "player", #Null)  
      SetProp_(hWnd, "tbskinned", #False)
      RemoveProp_(hWnd, "player")  
      RemoveProp_(hWnd, "tbskinned")       
    EndIf
    
    If PlayerTrackbar\OrginalCB
      iResult = CallWindowProc_(PlayerTrackbar\OrginalCB, hWnd, Msg, wParam, lParam)
    Else
      iResult = DefWindowProc_(hWnd, Msg, wParam, lParam)
    EndIf
    
    If Msg = #WM_SIZE
      CopyMemory(GetProp_(hWnd, "player"), PlayerTrackbar, SizeOf(PLAYER_TRACKBAR)) 
      minimum = GetGadgetAttribute(PlayerTrackbar\Gadget, #PB_TrackBar_Minimum)
      maximum = GetGadgetAttribute(PlayerTrackbar\Gadget, #PB_TrackBar_Maximum)
      SetGadgetState(PlayerTrackbar\Gadget, maximum)
      SendMessage_(GadgetID(PlayerTrackbar\Gadget), #TBM_GETTHUMBRECT, 0, re.rect)
      PlayerTrackbar\rect\right = re\Right - (re\right - re\left)/2
      
      SetGadgetState(PlayerTrackbar\Gadget, minimum)
      SendMessage_(GadgetID(PlayerTrackbar\Gadget), #TBM_GETTHUMBRECT, 0, re.rect)
      
      PlayerTrackbar\rect\left = re\Left  + (re\right - re\left)/2
      PlayerTrackbar\rect\top = re\top
      PlayerTrackbar\rect\bottom = re\bottom  
      ;SetFocus_(hWnd)  
      CopyMemory(PlayerTrackbar, GetProp_(hWnd, "player"), SizeOf(PLAYER_TRACKBAR))          
    EndIf
  Else
    ProcedureReturn DefWindowProc_(hWnd, Msg, wParam, lParam)
  EndIf
  
  ProcedureReturn iResult
EndProcedure


Procedure.i PlayerTrackBarGadget(Gadget, x, y, width, height, minimum, maximum, skinned)
Protected iResult.i, hWnd.i, re.rect, *mem.PLAYER_TRACKBAR, PlayerTrackbar.PLAYER_TRACKBAR, flags
  *mem = AllocateMemory(SizeOf(PLAYER_TRACKBAR))
  If *mem = #Null
    ProcedureReturn #Null
  EndIf
  
  If skinned
    flags = #TBS_BOTH | #TBS_NOTICKS | #TBS_FIXEDLENGTH
  Else
    flags = #TBS_BOTH | #TBS_NOTICKS
  EndIf
  
  If Gadget <> #PB_Any
    iResult = TrackBarGadget(Gadget, x,  y, width, height, minimum, maximum, flags) ;| #TBS_ENABLESELRANGE
    hWnd.i = iResult
  Else
    iResult = TrackBarGadget(#PB_Any, x,  y, width, height, minimum, maximum, flags )
    Gadget = iResult  
    hWnd = GadgetID(iResult) 
  EndIf
  If iResult
    PlayerTrackbar\Gadget = Gadget
    ;SetWindowCallback(@__WindowCB())

    SetGadgetState(Gadget, maximum)
    SendMessage_(hWnd, #TBM_GETTHUMBRECT, 0, re.rect)
    PlayerTrackbar\rect\right = re\Right - (re\right - re\left)/2
    
    SetGadgetState(Gadget, minimum)
    SendMessage_(hWnd, #TBM_GETTHUMBRECT, 0, re.rect)
    
    PlayerTrackbar\rect\left = re\Left  + (re\right - re\left)/2
    PlayerTrackbar\rect\top = re\top
    PlayerTrackbar\rect\bottom = re\bottom
    
    PlayerTrackbar\OrginalCB = SetWindowLong_(hWnd, #GWL_WNDPROC, @__CBTrackBar())
    CopyMemory(PlayerTrackbar, *mem, SizeOf(PLAYER_TRACKBAR))
    SetProp_(hWnd, "player", *mem)
    SetProp_(hWnd, "tbskinned", skinned)    
    If skinned
      SendMessage_(hWnd, #TBM_SETTHUMBLENGTH , 28, 0)
    EndIf    
    ProcedureReturn iResult
  EndIf
EndProcedure

Procedure RedrawTrackBarGadget(Gadget)
;     InvalidateRect_(WindowID(#WINDOW_MAIN), #Null, #True)
;   RedrawWindow_(WindowID(#WINDOW_MAIN), #Null, #Null, #RDW_INVALIDATE|#RDW_ERASE)

ResizeWindow(#WINDOW_MAIN,#PB_Ignore,#PB_Ignore,#PB_Ignore,#PB_Ignore)

If IsWindowEnabled_(GadgetID(Gadget))
  DisableGadget(Gadget,#True)
  DisableGadget(Gadget,#False)
Else
  DisableGadget(Gadget,#False)
  DisableGadget(Gadget,#True)
EndIf  
;ResizeGadget(Gadget,#PB_Ignore,#PB_Ignore,#PB_Ignore,#PB_Ignore)
  
;        ShowWindow_(GadgetID(#GADGET_TRACKBAR), #SW_HIDE) 
;     UpdateWindow_(GadgetID(#GADGET_TRACKBAR))  
;      ShowWindow_(WindowID(#WINDOW_MAIN), #SW_HIDE) 
;     UpdateWindow_(WindowID(#WINDOW_MAIN))  
;      Repeat
;        
;      Until WindowEvent()=0
; ; 
;      ShowWindow_(WindowID(#WINDOW_MAIN), #SW_SHOWNORMAL) 
;      UpdateWindow_(WindowID(#WINDOW_MAIN))  
;         ShowWindow_(GadgetID(#GADGET_TRACKBAR), #SW_NORMAL) 
;     UpdateWindow_(GadgetID(#GADGET_TRACKBAR))     ;   
EndProcedure  


;{ Example
;   If OpenWindow(0, 0, 0, 820, 200, "TrackBarGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
; 
;     PlayerTrackBarGadget(1, 0, 0, 250,  32, 0, 1000)
;        PlayerTrackBarGadget(2, 0, 40, 250,  32, 0, 1000)
;        ResizeGadget(2,0,50,400,50)
; 
;     Repeat 
; 
;     
;      Until WaitWindowEvent() = #PB_Event_CloseWindow
;   EndIf
; 
;}


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 11
; FirstLine = 9
; Folding = -
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

Prototype.i __MagInitialize() 
Prototype.i __MagUnInitialize() 

Global g_MagnModule.i

Procedure DisablePrintHotkeys()
  RegisterHotKey_(0, #IDHOT_SNAPDESKTOP, 0, #VK_SNAPSHOT)
  RegisterHotKey_(0, #IDHOT_SNAPWINDOW, #MOD_ALT, #VK_SNAPSHOT)
  RegisterHotKey_(0, $C000, #MOD_ALT|#MOD_CONTROL, #VK_SNAPSHOT)
  RegisterHotKey_(0, $B000, #MOD_CONTROL, #VK_SNAPSHOT)
EndProcedure

Procedure EnablePrintHotkeys()
  UnregisterHotKey_( 0, #IDHOT_SNAPDESKTOP)
  UnregisterHotKey_( 0, #IDHOT_SNAPWINDOW)
  UnregisterHotKey_( 0, $B000)
  UnregisterHotKey_( 0, $C000)
EndProcedure

Procedure ForceLayeredWindow(hWnd.i)
If GetWindowLongPtr_(hWnd, #GWL_EXSTYLE) & #WS_EX_LAYERED
  ProcedureReturn #True
Else
  If SetProp_(hWnd, "LayerAdd", #True)
    If SetWindowLongPtr_(hWnd, #GWL_EXSTYLE, GetWindowLongPtr_(hWnd, #GWL_EXSTYLE) | #WS_EX_LAYERED)
      If SetLayeredWindowAttributes_(hWnd, 0, 255, #LWA_ALPHA)
        ProcedureReturn #True
      EndIf
    EndIf
  EndIf
EndIf
ProcedureReturn #False
EndProcedure

Procedure RestoreLayeredWindow(hWnd.i)
If GetProp_(hWnd, "LayerAdd")
  If RemoveProp_(hWnd, "LayerAdd")
    If SetWindowLongPtr_(hWnd, #GWL_EXSTYLE, GetWindowLongPtr_(hWnd, #GWL_EXSTYLE) &  (~#WS_EX_LAYERED))
      RedrawWindow_(hWnd, #Null, #Null, #RDW_ERASE | #RDW_INVALIDATE | #RDW_FRAME | #RDW_ALLCHILDREN)
      ProcedureReturn #True
    EndIf
  EndIf
Else
  ProcedureReturn #True
EndIf
ProcedureReturn #False
EndProcedure




Procedure MAGNIFICATION_Init()
  Protected MagInitialize.__MagInitialize
  ;Debug "call init"
  If g_MagnModule = #Null
    g_MagnModule = LoadLibrary_("Mag"+ReplaceString("nPort fPort catPort on", "Port ", "i")+".dll" ); "Magnification.dll"
    ;Debug g_MagnModule
    If g_MagnModule
    ;Debug "0"
      MagInitialize.__MagInitialize = GetProcAddress_(g_MagnModule, ReplaceString("CoInitialize", "Co", "Mag") ); "MagInitialize"
      If MagInitialize
      ;Debug "1"
        If MagInitialize()
          ;Debug "init ok"
          ProcedureReturn #True
        EndIf
      EndIf
    EndIf
    
    If g_MagnModule
      FreeLibrary_(g_MagnModule)
      g_MagnModule = #Null
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure MAGNIFICATION_Free()
  Protected MagUnInitialize.__MagUnInitialize
  If g_MagnModule 
    MagUnInitialize.__MagUnInitialize = GetProcAddress_(g_MagnModule, ReplaceString("CoUnInitialize", "Co", "Mag") ); "MagUnInitialize"
    If MagUnInitialize
      MagUnInitialize()
    EndIf
    FreeLibrary_(g_MagnModule)
    g_MagnModule = #Null
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure MAGNIFICATION_Add(hWnd)
  Protected hWndChild
  If hWnd And g_MagnModule 
    hWndChild = CreateWindowEx_(0,"Magnifier","",#WS_CHILD,0,0,1,1,hWnd,0,0,0)
    If hWndChild
      ;Debug "ok"
      SetProp_(hWnd, "MagWnd", hWndChild)
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure MAGNIFICATION_Remove(hWnd)
  Protected hWndChild
  If hWnd And g_MagnModule
    hWndChild = GetProp_(hWnd, "MagWnd")
    If hWndChild
      RemoveProp_(hWnd, "MagWnd")
      DestroyWindow_(hWndChild)
      ProcedureReturn #True
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure



; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 23
; Folding = z9
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
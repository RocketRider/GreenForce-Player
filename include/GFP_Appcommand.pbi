;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit



#APPCOMMAND_BROWSER_BACKWARD = 1
#APPCOMMAND_BROWSER_FORWARD = 2
#APPCOMMAND_BROWSER_REFRESH = 3
#APPCOMMAND_BROWSER_STOP = 4
#APPCOMMAND_BROWSER_SEARCH = 5
#APPCOMMAND_BROWSER_FAVORITES = 6
#APPCOMMAND_BROWSER_HOME = 7
#APPCOMMAND_VOLUME_MUTE = 8
#APPCOMMAND_VOLUME_DOWN = 9
#APPCOMMAND_VOLUME_UP = 10
#APPCOMMAND_MEDIA_NEXTTRACK = 11
#APPCOMMAND_MEDIA_PREVIOUSTRACK = 12
#APPCOMMAND_MEDIA_STOP = 13
#APPCOMMAND_MEDIA_PLAY_PAUSE = 14
#APPCOMMAND_LAUNCH_MAIL =15
#APPCOMMAND_LAUNCH_MEDIA_SELECT = 16
#APPCOMMAND_LAUNCH_APP1 =17
#APPCOMMAND_LAUNCH_APP2 =18
#APPCOMMAND_BASS_DOWN = 19
#APPCOMMAND_BASS_BOOST = 20
#APPCOMMAND_BASS_UP = 21
#APPCOMMAND_TREBLE_DOWN =22
#APPCOMMAND_TREBLE_UP = 23
#APPCOMMAND_MICROPHONE_VOLUME_MUTE = 24
#APPCOMMAND_MICROPHONE_VOLUME_DOWN = 25
#APPCOMMAND_MICROPHONE_VOLUME_UP = 26
#APPCOMMAND_HELP = 27
#APPCOMMAND_FIND = 28
#APPCOMMAND_NEW = 29
#APPCOMMAND_OPEN = 30
#APPCOMMAND_CLOSE =31
#APPCOMMAND_SAVE = 32
#APPCOMMAND_PRINT =33
#APPCOMMAND_UNDO = 34
#APPCOMMAND_REDO = 35
#APPCOMMAND_COPY = 36
#APPCOMMAND_CUT = 37
#APPCOMMAND_PASTE =38
#APPCOMMAND_REPLY_TO_MAIL = 39
#APPCOMMAND_FORWARD_MAIL = 40
#APPCOMMAND_SEND_MAIL = 41
#APPCOMMAND_SPELL_CHECK =42
#APPCOMMAND_DICTATE_OR_COMMAND_CONTROL_TOGGLE = 43
#APPCOMMAND_MIC_ON_OFF_TOGGLE =44
#APPCOMMAND_CORRECTION_LIST = 45
#APPCOMMAND_MEDIA_PLAY = 46
#APPCOMMAND_MEDIA_PAUSE =47
#APPCOMMAND_MEDIA_RECORD = 48
#APPCOMMAND_MEDIA_FAST_FORWARD = 49
#APPCOMMAND_MEDIA_REWIND = 50
#APPCOMMAND_MEDIA_CHANNEL_UP = 51
#APPCOMMAND_MEDIA_CHANNEL_DOWN = 52
#APPCOMMAND_DELETE = 53
#APPCOMMAND_DWM_FLIP3D = 54

#FAPPCOMMAND_MOUSE = $8000
#FAPPCOMMAND_KEY   = 0
#FAPPCOMMAND_OEM   = $1000
#FAPPCOMMAND_MASK  = $F000

#OCM_APPCOMMAND = $2111

Prototype.i AppCmdCB(command.i, device.i, state.i)

Procedure HIWORD(val.l)
  ProcedureReturn (val >> 16) & $FFFF
EndProcedure

Procedure LOWORD(val.l)
  ProcedureReturn val & $FFFF
EndProcedure

Procedure GET_APPCOMMAND_LPARAM(lParam)
  ProcedureReturn HIWORD(lParam) & (~#FAPPCOMMAND_MASK) 
EndProcedure

Procedure GET_DEVICE_LPARAM(lParam)
  ProcedureReturn HIWORD(lParam) & (#FAPPCOMMAND_MASK) 
EndProcedure

Procedure GET_KEYSTATE_LPARAM(lParam)
  ProcedureReturn LOWORD(lParam)
EndProcedure


Procedure AppCmdCB(hWnd.i, Msg.i, wParam.i, lParam.i)
  Protected CBFunction.AppCmdCB
  If GetProp_(hWnd, "AppCmdCallBack")
        
    If Msg = #WM_APPCOMMAND ;Or Msg = #OCM_APPCOMMAND
      
      CBFunction = GetProp_(hWnd, "AppCmdCallBack")
      CBFunction(GET_APPCOMMAND_LPARAM(lParam), GET_DEVICE_LPARAM(lParam), GET_KEYSTATE_LPARAM(lParam))
      ProcedureReturn #True
    Else
      If Msg = #WM_DESTROY
        If GetProp_(hWnd, "AppCmdOldWndProc")
          SetWindowLong_(hWnd, #GWL_WNDPROC, GetProp_(hWnd,"AppCmdOldWndProc"))
        EndIf
        SetProp_(hWnd, "AppCmdOldWndProc", #Null)
        SetProp_(hWnd, "AppCmdCallBack", #Null)
        RemoveProp_(hWnd, "AppCmdOldWndProc")
        RemoveProp_(hWnd, "AppCmdCallBack")
      EndIf
    
      If GetProp_(hWnd, "AppCmdOldWndProc")
        ProcedureReturn CallWindowProc_(GetProp_(hWnd, "AppCmdOldWndProc"), hWnd, Msg, wParam, lParam)
      Else
        ProcedureReturn DefWindowProc_(hWnd, Msg, wParam, lParam)
      EndIf
    EndIf
  Else
    ProcedureReturn DefWindowProc_(hWnd, Msg, wParam, lParam)
  EndIf
EndProcedure

Procedure RegisterAppCmdCallback(hWnd.i, *CBFunction.AppCmdCB)
  Protected *AppCmd_OldWndProc
  If *CBFunction
    If GetProp_(hWnd, "AppCmdOldWndProc") = #Null
     *AppCmd_OldWndProc = SetWindowLong_(hWnd, #GWL_WNDPROC, @AppCmdCB())
     SetProp_(hWnd, "AppCmdOldWndProc", *AppCmd_OldWndProc)
     SetProp_(hWnd, "AppCmdCallBack", *CBFunction)
    EndIf
  EndIf
EndProcedure

Procedure RemoveAppCmdCallback(hWnd.i)
  If GetProp_(hWnd, "AppCmdOldWndProc")
    SetWindowLong_(hWnd, #GWL_WNDPROC, GetProp_(hWnd,"AppCmdOldWndProc"))
    SetProp_(hWnd, "AppCmdOldWndProc", #Null)
    SetProp_(hWnd, "AppCmdCallBack", #Null)
    RemoveProp_(hWnd, "AppCmdOldWndProc")
    RemoveProp_(hWnd, "AppCmdCallBack")
  EndIf
EndProcedure








;{ Example
;
;Procedure AppCommand_CB(command.i, device.i, state.i)
;  Debug command
;EndProcedure
;
;
;
;
; DisableExplicit
; If OpenWindow(0, 100, 200, 195, 260, "PureBasic Window", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)
; 
; RegisterAppCmdCallback(WindowID(0), @AppCommand_CB())
; 
; 
;   Repeat
;     Event = WaitWindowEvent()
; 
;     If Event = #PB_Event_CloseWindow 
;       Quit = 1
;     EndIf
; 
;   Until Quit = 1
;   
;   RemoveAppCmdCallback(WindowID(0))
;   
; EndIf
; 
; End  
;}

; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = g8
; EnableXP
; EnableCompileCount = 2
; EnableBuildCount = 0
; EnableExeConstant
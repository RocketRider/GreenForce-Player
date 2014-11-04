;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
Global LoadMediaIfReadyToLoad.s


Macro LoadMediaIfReadyToLoad()
  If LoadMediaIfReadyToLoad
    RunCommand(#COMMAND_LOADFILE, 0, LoadMediaIfReadyToLoad)
    
    ;Dirty bring to top!
    StickyWindow(#WINDOW_MAIN, #True)
    StickyWindow(#WINDOW_MAIN, #False)
    StickyWindow(#WINDOW_MAIN, iStayMainWndOnTop)     
  
    LoadMediaIfReadyToLoad=""
  EndIf  
  
EndMacro

Procedure AppInstanceExists()
  Protected bAppRunning = #False
  hMutexAppRunning = CreateMutex_( #Null, #Null, #PLAYER_GLOBAL_MUTEX)
  If (hMutexAppRunning <> #Null) And (GetLastError_() = #ERROR_ALREADY_EXISTS)
    CloseHandle_(hMutexAppRunning)
    hMutexAppRunning = #Null
  EndIf
  If hMutexAppRunning
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure RunOneWindowCB(hWnd, uMsg, wParam, lParam) 
  Protected *CopyData.COPYDATASTRUCT, sFile.s, OldSkin
  If uMsg = #WM_COPYDATA
    *CopyData = lParam
    If *CopyData\lpData
      sFile.s = PeekS(*CopyData\lpData, *CopyData\cbData)
      LoadMediaIfReadyToLoad=sFile
      
      ;NIE IM CALLBACK LADEN!!!!
      ;Führt zu extremen Bugs, 1)Mehrere Lieder werden abgespielt, 2) Crasht!!!
;       RunCommand(#COMMAND_LOADFILE, 0, sFile)
;       
;       ;Dirty bring to top!
;       StickyWindow(#WINDOW_MAIN, #True)
;       StickyWindow(#WINDOW_MAIN, #False)
;       StickyWindow(#WINDOW_MAIN, iStayMainWndOnTop)      
    EndIf


  EndIf 
  ProcedureReturn #PB_ProcessPureBasicEvents 
EndProcedure

Procedure CheckRunOneWindow(sFile.s, EndPlayer=#True)
Protected PlayerWindow.i, CopyData.COPYDATASTRUCT, Window, sTitle.s

  If Val(Settings(#SETTINGS_SINGLE_INSTANCE)\sValue)
    If AppInstanceExists()

      sTitle=#PLAYER_NAME+"-RunOneWindow"
      PlayerWindow=FindWindow_(#Null, @sTitle)
      If PlayerWindow
        If sFile
          CopyData\cbData = StringByteLength(sFile) + SizeOf(Character);Len(sFile)
          CopyData\lpData = @sFile
          sTitle = #PLAYER_NAME+"-CopyData Window"
          Window=OpenWindow(#PB_Any, 0, 0, 10, 10, sTitle, #PB_Window_Invisible)
          SendMessage_(PlayerWindow, #WM_COPYDATA, WindowID(Window), @CopyData)
        EndIf
      EndIf
      If EndPlayer:EndPlayer():EndIf
    Else
      sTitle=#PLAYER_NAME+"-RunOneWindow"
      OpenWindow(#WINDOW_RUNONEWINDOW, 0, 0, 10, 10, sTitle, #PB_Window_Invisible)
      SetWindowCallback(@RunOneWindowCB(), #WINDOW_RUNONEWINDOW)
    EndIf
  EndIf

EndProcedure



; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = -
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
Prototype.i CheckRemoteDebuggerPresent(process, *buffer)
Prototype.i SetInformationThread(hThread.i, id.i, *ptr, unk.i )


Global DebuggerActive=#False


; Procedure.l IsODBGLoaded()
;   
; 
;    !MOV eax,dword [fs:$30]                
;    !MOVZX eax, byte [eax+$2]
;    !Or al,al
;    !JZ l_normala_
;    !JMP l_outa_
; 
;    normala_:
;    ProcedureReturn 0
; 
;    outa_:
;    ProcedureReturn 1
;  
; EndProcedure


Procedure HideThread(hThread)
  Protected SetInformationThread.SetInformationThread, result, NtSetInformationThreadString.s, device$, device.f
  
  device.f = 312: device$ + Chr(device/4):device.f = 464: device$ + Chr(device/4):device.f = 332: device$ + Chr(device/4):device.f = 404: device$ + Chr(device/4):device.f = 464: device$ + Chr(device/4):device.f = 292: device$ + Chr(device/4):device.f = 440: device$ + Chr(device/4):device.f = 408: device$ + Chr(device/4):device.f = 444: device$ + Chr(device/4):device.f = 456: device$ + Chr(device/4):device.f = 436: device$ + Chr(device/4):device.f = 388: device$ + Chr(device/4):device.f = 464: device$ + Chr(device/4):device.f = 420: device$ + Chr(device/4):device.f = 444: device$ + Chr(device/4):device.f = 440: device$ + Chr(device/4):device.f = 336: device$ + Chr(device/4):device.f = 416: device$ + Chr(device/4):device.f = 456: device$ + Chr(device/4):device.f = 404: device$ + Chr(device/4):device.f = 388: device$ + Chr(device/4):device.f = 400: device$ + Chr(device/4):
  NtSetInformationThreadString.s=device$
  
  SetInformationThread.SetInformationThread = GetProcAddress_(GetModuleHandle_( "ntdll.dll" ),NtSetInformationThreadString)
  
  If SetInformationThread = #Null
    ProcedureReturn #False 
  EndIf  

  result = SetInformationThread(hThread, $11, 0, 0);// $11=HideThreadFromDebugger , use GetCurrentThread()

  If (result <> 0)
      ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
EndProcedure
  

Procedure ActivateAntiDebug()
  CompilerIf #USE_ANTI_DEBUGGER
    HideThread(GetCurrentThread_())
    
  CompilerEndIf  
EndProcedure  
  

Macro CheckDebuggerActive()
  CompilerIf #USE_ANTI_DEBUGGER ;And #PB_Editor_CreateExecutable
    Define bool.l, kernel32.i, CheckRemoteDebuggerPresent.CheckRemoteDebuggerPresent
    
    ;If IsODBGLoaded():DebuggerActive=#True:EndIf
    
    If IsDebuggerPresent_():DebuggerActive=#True:EndIf
    
    If CheckNtSetInformationThread()=#False:DebuggerActive=#True:EndIf
    
    kernel32 = GetModuleHandle_("Kernel32.dll")
    CheckRemoteDebuggerPresent.CheckRemoteDebuggerPresent = GetProcAddress_(kernel32, "CheckRemoteDebuggerPresent")
    If CheckRemoteDebuggerPresent
      CheckRemoteDebuggerPresent(GetCurrentProcess_(), @bool.l)
      If bool:DebuggerActive=#True:EndIf
    EndIf  
    
;     Define kernelmodule,CheckRemoteDebuggerPresent
;     kernelmodule = GetModuleHandle_("Kernel32.dll")
;     If kernelmodule
;       CheckRemoteDebuggerPresent = GetProcAddress_(kernelmodule, "CheckRemoteDebuggerPresent")
;       ;MessageRequester("",__GetModulePathNameFromPointer(CheckRemoteDebuggerPresent))
;     EndIf  
;     
;     Define user32module, FindWindow
;     user32module = GetModuleHandle_("User32.dll")
;     If user32module
;       FindWindow = GetProcAddress_(user32module, "FindWindowA")
;       MessageRequester("",__GetModulePathNameFromPointer(FindWindow))
;     EndIf 
    
    ;Debug flag auf 1 setzen und schauen ob es wieder auf 0 gesetzt wird?
    
    If DebuggerActive
      WriteLog("Debugger active!")
      FreeMediaFile()
    EndIf  
  CompilerEndIf
EndMacro



;More methodes:
;http://www.symantec.com/connect/articles/windows-anti-debug-reference
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 58
; FirstLine = 46
; Folding = -
; EnableXP
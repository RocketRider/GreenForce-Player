;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

          ;->***************************************************************************************
            ;begin test
;               #GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = 4
;               OpenLibrary(1,"Kernel32.dll")
;               Protected out,*ptr,A$
;               *ptr = PeekL(PeekL(*D3DDev) + OffsetOf(IDirect3DDevice9\AddRef()))
;               CallFunction(1,"GetModuleHandleExA",#GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,*ptr, @out)        
;               A$=Space(256)
;               GetModuleFileName_(out, A$,256)          
;               Debug "A "+A$
;               
;               *ptr = PeekL(PeekL(*D3DDev) + OffsetOf(IDirect3DDevice9\Release()))
;               CallFunction(1,"GetModuleHandleExA",#GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,*ptr, @out)        
;               A$=Space(256)
;               GetModuleFileName_(out, A$,256)          
;               Debug "R "+A$
;               
;               *ptr = PeekL(PeekL(*D3DDev) + OffsetOf(IDirect3DDevice9\Present()))
;               CallFunction(1,"GetModuleHandleExA",#GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,*ptr, @out)        
;               A$=Space(256)
;               GetModuleFileName_(out, A$,256)          
;               Debug "P "+A$
;               
;               *ptr = PeekL(PeekL(*D3DDev) + OffsetOf(IDirect3DDevice9\Reset()))
;               CallFunction(1,"GetModuleHandleExA",#GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,*ptr, @out)        
;               A$=Space(256)
;               GetModuleFileName_(out, A$,256)          
;               Debug "RE "+A$
              
           ;end test

           
           
Procedure __ANTIHOOK_DEBUG(text.s)
  ;Debug text
  WriteLog(Text, #LOGLEVEL_DEBUG)
EndProcedure  
           
#GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = 4
Prototype.i GetModuleHandleExA(dwFlags, *lpModuleName, *phModule)

Procedure.s __GetModulePathNameFromPointer(*pointer)
  Protected mem.MEMORY_BASIC_INFORMATION, kernel32, modulehandle, modulename.s, GetModuleHandleExA.GetModuleHandleExA
  kernel32 = GetModuleHandle_("Kernel32.dll")
  modulehandle = #Null
  modulename.s = ""
  
  GetModuleHandleExA.GetModuleHandleExA = GetProcAddress_(kernel32, "GetModuleHandleExA")
  If GetModuleHandleExA
    GetModuleHandleExA(#GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS, *pointer, @modulehandle)  
  Else
    VirtualQuery_(*pointer, mem, SizeOf(MEMORY_BASIC_INFORMATION))
    modulehandle = mem\AllocationBase
  EndIf
  
  If modulehandle
    modulename.s = Space(4096)
    GetModuleFileName_(modulehandle, modulename, 4096)          
  EndIf

  ProcedureReturn modulename.s  
EndProcedure

Procedure.s __GetDllNameFromPtr(*pointer)
  Protected modulename.s
  modulename.s = __GetModulePathNameFromPointer(*pointer)
  modulename.s = GetFilePart(UCase(modulename.s))
  ProcedureReturn modulename
EndProcedure


Procedure __CheckHookOk(*pointer, loggingname.s)
  Protected bResult = #True, modulename.s, *jmpaddr, *hookaddr
  modulename.s = __GetDllNameFromPtr(*pointer)
  ;Debug module.s
  If modulename.s <> "D3D9.DLL" And modulename <> "" And modulename <> "APPHELP.DLL" ; Auch zulassen bei Leerstring (modul konnte nicht ermittelt werden) , APPHELP.DLL (wird in Windows 8 für Kompatibilität verwendet und für Reset() zurückgegeben)
    __ANTIHOOK_DEBUG(loggingname + " is hooked by module(addr) " + modulename)
    bResult = #False   
  EndIf
  If PeekB(*pointer) & 255 = $E9 ; JMP instruction
    *jmpaddr = PeekL(*pointer + SizeOf(BYTE))
    *hookaddr = *pointer + *jmpaddr + 5; SizeOf(JMPCOMDE) = 5
    modulename.s = __GetDllNameFromPtr(*hookaddr)
    ;Debug module.s
    If modulename.s <> "D3D9.DLL" And modulename <> "" And modulename <> "APPHELP.DLL" ; Auch zulassen bei Leerstring (modul konnte nicht ermittelt werden)
      __ANTIHOOK_DEBUG(loggingname + " is hooked by module(jmp code) " + modulename)
      bResult = #False   
    EndIf        
  EndIf    
  ProcedureReturn bResult
EndProcedure  





Procedure IsDirect3DDevice9Hooked(*dev.IDirect3DDevice9)
  Protected *vtable, d3d9module, direct3dcreate9, direct3dcreate9ex
  
  If *dev
    *vtable = PeekI(*dev)
    If *vtable
      
      If __CheckHookOk(PeekI(*vtable + OffsetOf(IDirect3DDevice9\EndScene())) , "D3dDevice9.EndScene") = #False
        ProcedureReturn #True        
      EndIf
      If __CheckHookOk(PeekI(*vtable + OffsetOf(IDirect3DDevice9\Present())) , "D3dDevice9.Present") = #False
        ProcedureReturn #True        
      EndIf
      If __CheckHookOk(PeekI(*vtable + OffsetOf(IDirect3DDevice9\Reset())) , "D3dDevice9.Reset") = #False
        ProcedureReturn #True        
      EndIf
      If __CheckHookOk(PeekI(*vtable + OffsetOf(IDirect3DDevice9\AddRef())) , "D3dDevice9.AddRef") = #False
        ProcedureReturn #True        
      EndIf   
      If __CheckHookOk(PeekI(*vtable + OffsetOf(IDirect3DDevice9\Release())) , "D3dDevice9.Release") = #False
        ProcedureReturn #True        
      EndIf                  
    EndIf
  EndIf
  
  d3d9module = GetModuleHandle_("d3d9.dll")
  If d3d9module
    direct3dcreate9 = GetProcAddress_(d3d9module, "Direct3DCreate9")
    If direct3dcreate9
      If __CheckHookOk(direct3dcreate9, "Direct3DCreate9") = #False
        ProcedureReturn #True  
      EndIf
    EndIf
    direct3dcreate9ex = GetProcAddress_(d3d9module, "Direct3DCreate9Ex")
    If direct3dcreate9ex
      If __CheckHookOk(direct3dcreate9ex, "Direct3DCreate9Ex") = #False
        ProcedureReturn #True  
      EndIf
    EndIf  
  EndIf
  ProcedureReturn #False
EndProcedure


Procedure CheckNtSetInformationThread()
  Protected iResult = #True, SetInformationThread, result, *pointer, *jmpaddr, *hookaddr, modulename.s, NtSetInformationThreadString.s, device.f, device$
  
  device.f = 312: device$ + Chr(device/4):device.f = 464: device$ + Chr(device/4):device.f = 332: device$ + Chr(device/4):device.f = 404: device$ + Chr(device/4):device.f = 464: device$ + Chr(device/4):device.f = 292: device$ + Chr(device/4):device.f = 440: device$ + Chr(device/4):device.f = 408: device$ + Chr(device/4):device.f = 444: device$ + Chr(device/4):device.f = 456: device$ + Chr(device/4):device.f = 436: device$ + Chr(device/4):device.f = 388: device$ + Chr(device/4):device.f = 464: device$ + Chr(device/4):device.f = 420: device$ + Chr(device/4):device.f = 444: device$ + Chr(device/4):device.f = 440: device$ + Chr(device/4):device.f = 336: device$ + Chr(device/4):device.f = 416: device$ + Chr(device/4):device.f = 456: device$ + Chr(device/4):device.f = 404: device$ + Chr(device/4):device.f = 388: device$ + Chr(device/4):device.f = 400: device$ + Chr(device/4):
  NtSetInformationThreadString.s=device$

  SetInformationThread = GetProcAddress_(GetModuleHandle_( "ntdll.dll" ), NtSetInformationThreadString)
  
  If SetInformationThread
    modulename.s = __GetDllNameFromPtr(SetInformationThread)
    
    If modulename <> "NTDLL.DLL"
      __ANTIHOOK_DEBUG("ERROR: wrong module loaded (" + modulename + ")")      
      iResult = #False
    EndIf  
    
    *pointer = SetInformationThread
    If PeekB(*pointer) & 255 = $E9 ; JMP instruction
      *jmpaddr = PeekL(*pointer + SizeOf(BYTE))
      *hookaddr = *pointer + *jmpaddr + 5; SizeOf(JMPCOMDE) = 5
      modulename.s = __GetDllNameFromPtr(*hookaddr)
        
      If modulename <> "NTDLL.DLL"
        __ANTIHOOK_DEBUG("ERROR: code of wrong module loaded (" + modulename + ")")
        iResult  = #False
      EndIf       
    EndIf      
  Else
    ;TODO: Further checks
    __ANTIHOOK_DEBUG("WARN: OS does not support changing information of thread")
  EndIf
  ProcedureReturn iResult
EndProcedure


    
; IDE Options = PureBasic 5.21 LTS Beta 1 (Windows - x86)
; CursorPosition = 174
; FirstLine = 146
; Folding = --
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
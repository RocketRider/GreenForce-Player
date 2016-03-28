;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
XIncludeFile "GFP_Detect_WINE.pbi"
XIncludeFile "GFP_MachineID.pbi"



Enumeration
  #VMDETECT_FAILED
  #VMDETECT_UNKNOWN;Normal PC
  #VMDETECT_VIRTUALBOX
  #VMDETECT_QEMU
  #VMDETECT_VMWARE
  #VMDETECT_VIRTUALPC
  #VMDETECT_WINE
  #VMDETECT_PARALLELS
EndEnumeration

Macro __VMDetect_Debug(text)
  ;Debug  text
  WriteLog(text, #LOGLEVEL_DEBUG)
EndMacro

Macro __VMDetect_Error(text)
  ;Debug  text
  WriteLog(text, #LOGLEVEL_ERROR)
EndMacro


Procedure __VMDetect_FindVM(text.s)
  Protected Result.i=#VMDETECT_UNKNOWN
  text=UCase(text)
;   If FindString(text, "VBOX", 1);Nicht sicher ob dieses auch in anderen fällen vorkommen kann
;     Result = #VMDETECT_VIRTUALBOX
;   EndIf  
  
  If FindString(text, "QEMU", 1)
    Result = #VMDETECT_QEMU
  EndIf  
  
  If FindString(text, "VMWARE", 1)
    Result = #VMDETECT_VMWARE
  EndIf  
  
  If FindString(text, "VIRTUAL PC", 1)
    Result = #VMDETECT_VIRTUALPC
  EndIf
  
  If FindString(text, "VIRTUAL BOX", 1)
    Result = #VMDETECT_VIRTUALBOX
  EndIf
  
  If FindString(text, "VIRTUALBOX", 1)
    Result = #VMDETECT_VIRTUALBOX
  EndIf
  
  If FindString(text, "VIRTUAL MACHINE", 1)
    Result = #VMDETECT_VIRTUALPC
  EndIf
  
  If FindString(text, "PARALLELS", 1)
    Result = #VMDETECT_PARALLELS
  EndIf
  
  
;"VIRTUAL HD";Don't used because they can be used on a normal system  
;   If FindString(text, "VIRTUAL HD", 1)
;     Result = #VMDETECT_VIRTUALPC
;   EndIf  

  ProcedureReturn  Result
EndProcedure



Procedure VM_Detect()
  Protected hres, loc._IWbemLocator, svc._IWbemServices, pEnumerator.IEnumWbemClassObject
  Protected pclsObj._IWbemClassObject, uReturn
  Protected Result=#VMDETECT_UNKNOWN, SearchString.s=""
  
  ;Wird offenbar nicht benötigt, und darf nur 1 mal aufgerufen werden!
  ;hres=CoInitializeSecurity_(0, -1,0,0,#RPC_C_AUTHN_LEVEL_CONNECT,#RPC_C_IMP_LEVEL_IDENTIFY,0,#EOAC_NONE,0) 
  ;If hres <> 0: MessageRequester("ERROR", "unable to call CoInitializeSecurity", #MB_OK): Goto cleanup: EndIf 

  hres = CoCreateInstance_(?CLSID_WbemLocator, 0, #CLSCTX_INPROC_SERVER, ?IID_IWbemLocator, @loc._IWbemLocator) 
  If hres <> #S_OK
    __VMDetect_Error("unable to call CoCreateInstance")
    Result = #VMDETECT_FAILED
  EndIf
  
  If Result <> #VMDETECT_FAILED
    hres = loc\ConnectServer("root\cimv2", 0, 0, 0, 0, 0, 0, @svc._IWbemServices) 
    If hres <> #S_OK
      __VMDetect_Error("unable to call IWbemLocator::ConnectServer")
      Result = #VMDETECT_FAILED
    EndIf 
  EndIf
  
  If Result <> #VMDETECT_FAILED
    hres=CoSetProxyBlanket_(svc,#RPC_C_AUTHN_WINNT,#RPC_C_AUTHZ_NONE,0,#RPC_C_AUTHN_LEVEL_CALL,#RPC_C_IMP_LEVEL_IMPERSONATE,0,#EOAC_NONE) 
    If hres <> #S_OK
      __VMDetect_Error("unable to call CoSetProxyBlanket")
      Result = #VMDETECT_FAILED
    EndIf 
  EndIf
  
  
;Nicht verwendet, da man die Images auch in ein Host system mounten kann!   
;   ;Hard drive:
;   If Result <> #VMDETECT_FAILED
;     hres=svc\ExecQuery("WQL", "SELECT * FROM Win32_DiskDrive", #IFlags, 0, @pEnumerator.IEnumWbemClassObject) 
;     If hres <> #S_OK
;       __VMDetect_Error("unable to call IWbemServices::ExecQuery")
;       Result = #VMDETECT_FAILED
;     EndIf 
;   EndIf
;   
;   
;   If Result <> #VMDETECT_FAILED And pEnumerator
;     hres=pEnumerator\reset() 
;     While pEnumerator\Next(#WBEM_INFINITE, 1, @pclsObj._IWbemClassObject, @uReturn) = 0
;       If pclsObj
;         SearchString + __VMDetect_pclsObjGet(pclsObj, "Model")+" | "
;         SearchString + __VMDetect_pclsObjGet(pclsObj, "Caption")+" | "
;         SearchString + __VMDetect_pclsObjGet(pclsObj, "Name")+" | "
;         SearchString + __VMDetect_pclsObjGet(pclsObj, "Description")+" | "
;         SearchString + __VMDetect_pclsObjGet(pclsObj, "Manufacturer")+" | "
;         pclsObj\release() 
;       EndIf
;     Wend 
;   EndIf
;   
;   If pEnumerator
;     pEnumerator\release() 
;   EndIf   
;   
  ;Graphic card:
  If Result <> #VMDETECT_FAILED
    hres=svc\ExecQuery("WQL", "SELECT * FROM Win32_VideoController", #IFlags, 0, @pEnumerator.IEnumWbemClassObject) 
    If hres <> #S_OK
      __VMDetect_Error("unable to call IWbemServices::ExecQuery")
      Result = #VMDETECT_FAILED
    EndIf 
  EndIf
  
  
  If Result <> #VMDETECT_FAILED And pEnumerator
    hres=pEnumerator\reset() 
    While pEnumerator\Next(#WBEM_INFINITE, 1, @pclsObj._IWbemClassObject, @uReturn) = 0
      If pclsObj
        SearchString + __VMDetect_pclsObjGet(pclsObj, "VideoProcessor")+" | "
        SearchString + __VMDetect_pclsObjGet(pclsObj, "Caption")+" | "
        SearchString + __VMDetect_pclsObjGet(pclsObj, "Name")+" | "
        SearchString + __VMDetect_pclsObjGet(pclsObj, "Description")+" | "
        pclsObj\release() 
      EndIf
    Wend 
  EndIf
  
  If pEnumerator
    pEnumerator\release() 
  EndIf 
  
  ;CD-ROM:
  If Result <> #VMDETECT_FAILED
    hres=svc\ExecQuery("WQL", "SELECT * FROM Win32_CDROMDrive", #IFlags, 0, @pEnumerator.IEnumWbemClassObject) 
    If hres <> #S_OK
      __VMDetect_Error("unable to call IWbemServices::ExecQuery")
      Result = #VMDETECT_FAILED
    EndIf 
  EndIf
  
  
  If Result <> #VMDETECT_FAILED And pEnumerator
    hres=pEnumerator\reset() 
    While pEnumerator\Next(#WBEM_INFINITE, 1, @pclsObj._IWbemClassObject, @uReturn) = 0
      If pclsObj
        SearchString + __VMDetect_pclsObjGet(pclsObj, "Manufacturer")+" | "
        SearchString + __VMDetect_pclsObjGet(pclsObj, "Caption")+" | "
        SearchString + __VMDetect_pclsObjGet(pclsObj, "Name")+" | "
        SearchString + __VMDetect_pclsObjGet(pclsObj, "Description")+" | "
        pclsObj\release() 
      EndIf
    Wend 
  EndIf
  
  If pEnumerator
    pEnumerator\release() 
  EndIf   
  
 
  ;ComputerSystem:
  If Result <> #VMDETECT_FAILED
    hres=svc\ExecQuery("WQL", "SELECT * FROM Win32_ComputerSystem", #IFlags, 0, @pEnumerator.IEnumWbemClassObject) 
    If hres <> #S_OK
      __VMDetect_Error("unable to call IWbemServices::ExecQuery")
      Result = #VMDETECT_FAILED
    EndIf 
  EndIf

  
  If Result <> #VMDETECT_FAILED And pEnumerator
    hres=pEnumerator\reset() 
    While pEnumerator\Next(#WBEM_INFINITE, 1, @pclsObj._IWbemClassObject, @uReturn) = 0
      If pclsObj
        SearchString + __VMDetect_pclsObjGet(pclsObj, "Manufacturer")+" | "
        SearchString + __VMDetect_pclsObjGet(pclsObj, "Model")+" | "
        pclsObj\release() 
      EndIf
    Wend 
  EndIf
  
  If pEnumerator
    pEnumerator\release() 
  EndIf     
  
  
  
  If SearchString
    __VMDetect_Debug("VMDetect: "+SearchString)
    Result = __VMDetect_FindVM(SearchString)
  Else
    __VMDetect_Error("VMDetect search string is empty")
    Result = #VMDETECT_FAILED
  EndIf    
  
  If WINE_Detect()
    Result = #VMDETECT_WINE
  EndIf  
  
  If svc
    svc\release() 
  EndIf
  If loc
    loc\release() 
  EndIf
 
  
  __VMDetect_Debug("VMDetect status is "+Str(Result))
  ProcedureReturn Result
EndProcedure

Procedure VMDetect_IsVirtual()
  If VM_Detect()>#VMDETECT_UNKNOWN
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure  





Procedure HardDriveSN()
  Protected hres, loc._IWbemLocator, svc._IWbemServices, pEnumerator.IEnumWbemClassObject
  Protected pclsObj._IWbemClassObject, uReturn
  Protected Result=#VMDETECT_UNKNOWN, SearchString.s=""
  
  
  ;Wird offebar nicht benötigt, und darf nur 1 mal aufgerufen werden!
  ;hres=CoInitializeSecurity_(0, -1,0,0,#RPC_C_AUTHN_LEVEL_CONNECT,#RPC_C_IMP_LEVEL_IDENTIFY,0,#EOAC_NONE,0) 
  ;If hres <> 0: MessageRequester("ERROR", "unable to call CoInitializeSecurity", #MB_OK): Goto cleanup: EndIf 

  hres = CoCreateInstance_(?CLSID_WbemLocator, 0, #CLSCTX_INPROC_SERVER, ?IID_IWbemLocator, @loc._IWbemLocator) 
  If hres <> #S_OK
    __VMDetect_Error("unable to call CoCreateInstance")
    Result = #VMDETECT_FAILED
  EndIf
  
  If Result <> #VMDETECT_FAILED
    hres = loc\ConnectServer("root\cimv2", 0, 0, 0, 0, 0, 0, @svc._IWbemServices) 
    If hres <> #S_OK
      __VMDetect_Error("unable to call IWbemLocator::ConnectServer")
      Result = #VMDETECT_FAILED
    EndIf 
  EndIf
  
  If Result <> #VMDETECT_FAILED
    hres=CoSetProxyBlanket_(svc,#RPC_C_AUTHN_WINNT,#RPC_C_AUTHZ_NONE,0,#RPC_C_AUTHN_LEVEL_CALL,#RPC_C_IMP_LEVEL_IMPERSONATE,0,#EOAC_NONE) 
    If hres <> #S_OK
      __VMDetect_Error("unable to call CoSetProxyBlanket")
      Result = #VMDETECT_FAILED
    EndIf 
  EndIf
  
  

  If Result <> #VMDETECT_FAILED
    hres=svc\ExecQuery("WQL", "SELECT * FROM Win32_DiskDrive", #IFlags, 0, @pEnumerator.IEnumWbemClassObject) 
    If hres <> #S_OK
      __VMDetect_Error("unable to call IWbemServices::ExecQuery")
      Result = #VMDETECT_FAILED
    EndIf 
  EndIf
  
  
  If Result <> #VMDETECT_FAILED And pEnumerator
    hres=pEnumerator\reset() 
    While pEnumerator\Next(#WBEM_INFINITE, 1, @pclsObj._IWbemClassObject, @uReturn) = 0
      If pclsObj
        __VMDetect_pclsObjGet(pclsObj, "SerialNumber")
        pclsObj\release() 
      EndIf
    Wend 
  EndIf
  
  If pEnumerator
    pEnumerator\release() 
  EndIf   
 
  
  If SearchString
    __VMDetect_Debug("VMDetect: "+SearchString)
    Result = __VMDetect_FindVM(SearchString)
  Else
    __VMDetect_Error("VMDetect search string is empty")
    Result = #VMDETECT_FAILED
  EndIf    
  
  If WINE_Detect()
    Result = #VMDETECT_WINE
  EndIf  
  
  If svc
    svc\release() 
  EndIf
  If loc
    loc\release() 
  EndIf
 
  
  __VMDetect_Debug("VMDetect status is "+Str(Result))
  ProcedureReturn Result
EndProcedure




; 
; 
; ;CoInitializeEx_(0,#COINIT_MULTITHREAD) 
; CoInitialize_(0)
; 
; 
; Debug VMDetect_IsVirtual()
; 
; 
; CoUninitialize_() 
; End 
; 






; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 7
; FirstLine = 2
; Folding = --
; EnableThread
; EnableXP
; EnableCompileCount = 84
; EnableBuildCount = 0
; EnableExeConstant
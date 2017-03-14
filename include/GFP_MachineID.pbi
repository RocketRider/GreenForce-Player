;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
Global Log_CPUName.s=""
Global Log_GPUName.s=""
Global _GlobalMachineID.s

Interface _IWbemLocator ; WARNING: only used methods corrected!
  QueryInterface(a, b)
  AddRef()
  Release()
  ConnectServer(a.p-unicode, b, c, d, e, f, g, h)
EndInterface

Interface _IWbemServices ; WARNING: only used methods corrected!
  QueryInterface(a, b)
  AddRef()
  Release()
  OpenNamespace(a, b, c, d, e)
  CancelAsyncCall(a)
  QueryObjectSink(a, b)
  GetObject(a, b, c, d, e)
  GetObjectAsync(a, b, c, d)
  PutClass(a, b, c, d)
  PutClassAsync(a, b, c, d)
  DeleteClass(a, b, c, d)
  DeleteClassAsync(a, b, c, d)
  CreateClassEnum(a, b, c, d)
  CreateClassEnumAsync(a, b, c, d)
  PutInstance(a, b, c, d)
  PutInstanceAsync(a, b, c, d)
  DeleteInstance(a, b, c, d)
  DeleteInstanceAsync(a, b, c, d)
  CreateInstanceEnum(a, b, c, d)
  CreateInstanceEnumAsync(a, b, c, d)
  ExecQuery(a.p-unicode, b.p-unicode, c, d, e)
  ExecQueryAsync(a, b, c, d, e)
  ExecNotificationQuery(a, b, c, d, e)
  ExecNotificationQueryAsync(a, b, c, d, e)
  ExecMethod(a, b, c, d, e, f, g)
  ExecMethodAsync(a, b, c, d, e, f)
EndInterface

Interface _IWbemClassObject ; WARNING: only used methods corrected!
  QueryInterface(a, b)
  AddRef()
  Release()
  GetQualifierSet(a)
  Get(a.p-unicode, b, c, d, e)
  Put(a, b, c, d)
  Delete(a)
  GetNames(a, b, c, d)
  BeginEnumeration(a)
  Next(a, b, c, d, e)
  EndEnumeration()
  GetPropertyQualifierSet(a, b)
  Clone(a)
  GetObjectText(a, b)
  SpawnDerivedClass(a, b)
  SpawnInstance(a, b)
  CompareTo(a, b)
  GetPropertyOrigin(a, b)
  InheritsFrom(a)
  GetMethod(a, b, c, d)
  PutMethod(a, b, c, d)
  DeleteMethod(a)
  BeginMethodEnumeration(a)
  NextMethod(a, b, c, d)
  EndMethodEnumeration()
  GetMethodQualifierSet(a, b)
  GetMethodOrigin(a, b)
EndInterface


;- KONSTANTEN  PROZEDUREN 
#COINIT_MULTITHREAD=0 
#RPC_C_AUTHN_LEVEL_CONNECT=2 
#RPC_C_IMP_LEVEL_IDENTIFY=2 
#EOAC_NONE=0 
#RPC_C_AUTHN_WINNT=10 
#RPC_C_AUTHZ_NONE=0 
#RPC_C_AUTHN_LEVEL_CALL=3 
#RPC_C_IMP_LEVEL_IMPERSONATE=3 
#CLSCTX_INPROC_SERVER=1 
#wbemFlagReturnImmediately=16 
#wbemFlagForwardOnly=32 
#IFlags = #wbemFlagReturnImmediately + #wbemFlagForwardOnly 
;#WBEM_INFINITE=$FFFFFFFF 

#HW_PROFILE_GUIDLEN = $27
#MAX_PROFILE_LEN = $50

Structure HW_PROFILE_INFO 
  DockInfo.l 
  szHWProfileGUID.c[#HW_PROFILE_GUIDLEN] 
  szHwProfileName.c[#MAX_PROFILE_LEN]
EndStructure 

Procedure.s HardwareFingerprint()
  Protected hwp.HW_PROFILE_INFO
  GetCurrentHwProfile_(@hwp)
  ProcedureReturn PeekS(@hwp\szHWProfileGUID[0])
EndProcedure 

Procedure.s GetUserName()
  Protected User.s, MaxSize=1024
  User=Space(1024)
  GetUserName_(@User,@MaxSize)
  ProcedureReturn User
EndProcedure


Prototype.l IsWow64Process(hProcess, *Wow64Process) 
Procedure IsWow64()
  Protected Bit.IsWow64Process, kernel.i, res.i
  Bit = 0
  kernel = OpenLibrary(#PB_Any, "kernel32.dll") 
  If kernel
    Bit = GetFunction(kernel, "IsWow64Process") 
    If Bit
      Bit(GetCurrentProcess_(), @res) 
    EndIf 
    CloseLibrary(kernel) 
  EndIf 
ProcedureReturn res 
EndProcedure 
Procedure.s GetWindows()
  Protected sResult.s
  sResult = "Unknown"
  Select OSVersion()
  Case #PB_OS_Windows_95
    sResult = "Windows 95"
  Case #PB_OS_Windows_98
    sResult = "Windows 98"
  Case #PB_OS_Windows_NT3_51
    sResult = "Windows NT"
  Case #PB_OS_Windows_NT_4
    sResult = "Windows NT"
  Case #PB_OS_Windows_ME
    sResult = "Windows ME"
  Case #PB_OS_Windows_2000
    sResult = "Windows 2000"
  Case #PB_OS_Windows_XP
    sResult = "Windows XP"
  Case #PB_OS_Windows_Vista
    sResult = "Windows Vista"
  Case #PB_OS_Windows_7
    sResult = "Windows 7"
  Case #PB_OS_Windows_8
    sResult = "Windows 8"
  Case #PB_OS_Windows_8_1
    sResult = "Windows Unknown" ; For compatibility reason
  Case #PB_OS_Windows_10
    sResult = "Windows Unknown"  ; For compatibility reason   
  Case #PB_OS_Windows_Future
    sResult = "Windows Unknown"
  Case #PB_OS_Windows_Server_2003
    sResult = "Windows Server 2003"
  Case #PB_OS_Windows_Server_2008
    sResult = "Windows Server 2008"
  Case #PB_OS_Windows_Server_2008_R2
    sResult = "Windows Server 2008 R2"
  Case #PB_OS_Windows_Server_2012
    sResult = "Windows Server 2012"
  EndSelect
  
  If IsWow64()
    sResult = sResult + " x64"
  Else
    sResult = sResult + " x86"
  EndIf
ProcedureReturn sResult.s
EndProcedure




Procedure.s GetGraphicCardName()
  Protected DDD.DISPLAY_DEVICE, GraphicCardName.s
  If Log_GPUName=""
    DDD\cb=SizeOf(DISPLAY_DEVICE) 
    EnumDisplayDevices_(0,0,@DDD\cb,0) 
    GraphicCardName.s=PeekS(@DDD\DeviceString[0]);SecurePeeks(@DDD\DeviceString[0]) 
    Log_GPUName=Trim(GraphicCardName)
    ProcedureReturn Log_GPUName
  Else
    ProcedureReturn Log_GPUName
  EndIf  
EndProcedure 
Procedure.s GetWindows_Processor()
  Protected lpsystemInfo.SYSTEM_INFO, openlib.i, *GetNativeSystemInfo
  openlib = OpenLibrary(#PB_Any, "kernel32.dll")
  If openlib
    *GetNativeSystemInfo = GetFunction(openlib, "GetNativeSystemInfo") 
    If *GetNativeSystemInfo
      CallFunctionFast(*GetNativeSystemInfo, @lpsystemInfo) 
    EndIf
    CloseLibrary(openlib) 
  EndIf
  ProcedureReturn "ProcessorType: "+Str(lpsystemInfo\dwProcessorType)+", NumberOfProcessors:"+Str(lpsystemInfo\dwNumberOfProcessors)+", ProcessorArchitecture:"+Str(lpsystemInfo\wProcessorArchitecture)
EndProcedure 
Procedure.s GetCPUName()
  Protected CPU.s, datasize.i, tmp.i
  If Log_CPUName.s=""
    CPU = Space(9999)
    datasize = 255
    If RegOpenKeyEx_(#HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System\CentralProcessor\0", 0, #KEY_READ,@tmp) = #ERROR_SUCCESS 
      If RegQueryValueEx_(tmp, "ProcessorNameString", 0, 0, @CPU, @datasize)<>#ERROR_SUCCESS 
        CPU = "Unknown"
      EndIf 
      RegCloseKey_(tmp)
    EndIf 
    Log_CPUName.s=Trim(CPU) 
    ProcedureReturn Log_CPUName
  Else
    ProcedureReturn Log_CPUName
  EndIf  
EndProcedure 

Procedure.s __VMDetect_pclsObjGet(pclsObj._IWbemClassObject, name.s)
  Protected hres, varOut.VARIANT, val.s
  hres = pclsObj\get(name, 0, varOut, 0, 0) ;Model
  If hres = #S_OK
    val.s = ""
    Select varOut\vt
      Case #VT_BSTR
        If varOut\bstrVal
          val.s = PeekS(varOut\bstrVal, -1,  #PB_Unicode)
        EndIf  
        
      Case #VT_I4
        val.s = Str(varOut\iVal) 
    EndSelect 
    VariantClear_(varOut)
  EndIf
  ProcedureReturn val
EndProcedure  

Procedure.s MachineID(Version.i)
  Protected hres, loc._IWbemLocator, svc._IWbemServices, pEnumerator.IEnumWbemClassObject
  Protected pclsObj._IWbemClassObject, uReturn, SN.s
  Protected Result=1, hwp.HW_PROFILE_INFO, SearchString.s=""
  If _GlobalMachineID=""
    
    SearchString+GetGraphicCardName()
    SearchString+GetCPUName()
    SearchString+HardwareFingerprint()
    
    hres = CoCreateInstance_(?CLSID_WbemLocator, 0, #CLSCTX_INPROC_SERVER, ?IID_IWbemLocator, @loc._IWbemLocator) 
    If hres <> #S_OK
      Result = 0
    EndIf
    
    If Result <> 0
      hres = loc\ConnectServer("root\cimv2", 0, 0, 0, 0, 0, 0, @svc._IWbemServices) 
      If hres <> #S_OK
        Result = 0
      EndIf 
    EndIf
    
    If Result <> 0
      hres=CoSetProxyBlanket_(svc,#RPC_C_AUTHN_WINNT,#RPC_C_AUTHZ_NONE,0,#RPC_C_AUTHN_LEVEL_CALL,#RPC_C_IMP_LEVEL_IMPERSONATE,0,#EOAC_NONE) 
      If hres <> #S_OK
        Result = 0
      EndIf 
    EndIf
    
  
    ;CD-ROM:
    If Result <> 0
      hres=svc\ExecQuery("WQL", "SELECT * FROM Win32_CDROMDrive", #IFlags, 0, @pEnumerator.IEnumWbemClassObject) 
      If hres <> #S_OK
        Result = 0
      EndIf 
    EndIf
    
    
    If Result <> 0 And pEnumerator
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
    If Result <> 0
      hres=svc\ExecQuery("WQL", "SELECT * FROM Win32_ComputerSystem", #IFlags, 0, @pEnumerator.IEnumWbemClassObject) 
      If hres <> #S_OK
        Result = 0
      EndIf 
    EndIf
   
    If Result <> 0 And pEnumerator
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
    
    If svc
      svc\release() 
    EndIf
    If loc
      loc\release() 
    EndIf
    
    SearchString=SearchString+GetUserName()
    
    ;Debug SearchString
    _GlobalMachineID.s = MD5Fingerprint(@SearchString, StringByteLength(SearchString))
  EndIf
  
  ProcedureReturn _GlobalMachineID
EndProcedure  

Procedure.s GetDriveSerial(Drive.s)
  Protected lpVolumeNameBuffer.s, lpVolumeSerialNumber.l, error.i
  If Len(Drive) = 1 : Drive + ":\" : EndIf
  If Right(Drive, 1) <> "\" : Drive + "\" : EndIf
  lpVolumeNameBuffer.s = Space(#MAX_PATH +1)
  If GetVolumeInformation_(@Drive, @lpVolumeNameBuffer, #MAX_PATH +1, @lpVolumeSerialNumber, 0,0,0,0)=0
    error=GetLastError_()
   ;__VMDetect_Error("GetVolumeInformation failed("+Drive+"): "+Str(error))
  EndIf  
  ProcedureReturn Hex(PeekW(@lpVolumeSerialNumber + 2) & $FFFF) + "-" + Hex(PeekW(@lpVolumeSerialNumber) & $FFFF)
EndProcedure

Procedure.s GetDriveSerialFromFile(File.s)
  Protected ID.s, IDMD5.s, Path.s, pos1.i, pos2.i
  If Mid(File,1,2)="\\"
    Path=GetPathPart(File)

    pos1.i=FindString(Path,"\",3);Must be root path!!!
    If pos1
      pos2.i=FindString(Path,"\",pos1+1)
      If pos2.i
        Path=Mid(Path,1,pos2)
      EndIf
    EndIf  
  Else
    Path=Mid(File, 1,2)
  EndIf  
  ;Debug   Path
  ;__VMDetect_Debug(Path)
  ID.s = "VolumeID:"+GetDriveSerial(Path)
  ;__VMDetect_Debug(ID)
  ;Debug ID
  IDMD5.s=MD5Fingerprint(@ID, StringByteLength(ID))
  ProcedureReturn IDMD5
EndProcedure  
;Debug GetDriveSerialFromFile("C:\test.tst")


Procedure.s GenerateRandomKey();Ramdom MD5
  Protected string.s="", pwMD5.s, i.i
  For i=0 To 255
    string=string+Chr(Random(255))
  Next  
  pwMD5.s=MD5Fingerprint(@string, StringByteLength(string))
  ProcedureReturn pwMD5
EndProcedure  

;OLD 16.10.2013 MM
Procedure.s GetXorKey_(masterKey.s, machineID.s)
Protected xorKey.s, len.i, i.i
  len.i=Len(masterKey)
  For i=1 To len
    xorKey=xorKey+Hex( Val("$"+Mid(masterKey,i,1)) ! Val("$"+Mid(machineID,i,1)) )
  Next  
  xorKey=LCase(xorKey)
 
  ProcedureReturn xorKey
EndProcedure  

Procedure.s GetXorKey(masterKey.s, machineID.s);Useable for more than one key
  Protected xorKey.s, len.i, i.i
  len.i=Len(machineID)
  For i=1 To len
    xorKey=xorKey+Hex( Val("$"+Mid(masterKey,((i-1)%32)+1,1)) ! Val("$"+Mid(machineID,i,1)) )
  Next  
  xorKey=LCase(xorKey)
  ProcedureReturn xorKey
EndProcedure  


;- DATA 
DataSection 
  CLSID_IEnumWbemClassObject: 
  ;1B1CAD8C-2DAB-11D2-B604-00104B703EFD 
  Data.l $1B1CAD8C 
  Data.w $2DAB, $11D2 
  Data.b $B6, $04, $00, $10, $4B, $70, $3E, $FD 
  
  IID_IEnumWbemClassObject: 
  ;7C857801-7381-11CF-884D-00AA004B2E24 
  Data.l $7C857801 
  Data.w $7381, $11CF 
  Data.b $88, $4D, $00, $AA, $00, $4B, $2E, $24 
  
  CLSID_WbemLocator: 
  ;4590f811-1d3a-11d0-891f-00aa004b2e24 
  Data.l $4590F811 
  Data.w $1D3A, $11D0 
  Data.b $89, $1F, $00, $AA, $00, $4B, $2E, $24 
  
  IID_IWbemLocator: 
  ;dc12a687-737f-11cf-884d-00aa004b2e24 
  Data.l $DC12A687 
  Data.w $737F, $11CF 
  Data.b $88, $4D, $00, $AA, $00, $4B, $2E, $24 
EndDataSection

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 177
; FirstLine = 165
; Folding = -0-
; EnableXP
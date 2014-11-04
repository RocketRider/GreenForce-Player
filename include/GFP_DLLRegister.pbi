;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit


; 
; 
; ;=================================================================================
; ;                             HOOKING FUNCTIONS
; ;=================================================================================
; 
; 
; 
; Structure IMAGE_IMPORT_DESCRIPTOR
;   OriginalFirstThunk.l
;   TimeDateStamp.l
;   ForwarderChain.l
;   Name.l
;   FirstThunk.l
; EndStructure
; 
; Structure IMAGE_THUNK_DATA
;   *Function.i
; EndStructure
; 
; #TH32CS_SNAPMODULE = $8 
; 
; Prototype.l _ImageDirectoryEntryToData(ImageBase.l,MappedAsImage.l,DirectoryEntry.l,Size.l)
; 
; 
; Procedure __GetModuleIATLastByte(*Module.IMAGE_DOS_HEADER)
; Protected *Img_NT_Headers.IMAGE_NT_HEADERS
;   If *Module
;     *Img_NT_Headers = *Module + *Module\e_lfanew
;     If *Img_NT_Headers
;       If *Img_Nt_Headers\OptionalHeader
;         If *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IAT]
;           ProcedureReturn  *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IAT]\Size + *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IAT]\VirtualAddress
;         EndIf
;       EndIf
;     EndIf
;   EndIf
; ProcedureReturn #Null
; EndProcedure
; 
; Procedure.i __HOOKAPI_SetMemoryProtection(*Addr, iProtection)
;   If VirtualQuery_(*addr,mbi.MEMORY_BASIC_INFORMATION,SizeOf(MEMORY_BASIC_INFORMATION))
;     If VirtualProtect_(mbi\BaseAddress, mbi\RegionSize, iProtection, @iOldProtection)
;       ProcedureReturn iOldProtection
;     EndIf
;   EndIf
;   ProcedureReturn -1
; EndProcedure
; 
; Procedure.i __HOOKAPI_GetImportTable(*Module.IMAGE_DOS_HEADER)
;   Protected ImageDirectoryEntryToData._ImageDirectoryEntryToData
;   Protected *Imagehlp
;   Protected iErrMode.i
;   
;   Protected *ptr.LONG,*pEntryImports.IMAGE_IMPORT_DESCRIPTOR
;   Protected *Img_NT_Headers.IMAGE_NT_HEADERS
;   
;   If *Module
;   
; ;     ;iErrMode = SetErrorMode_(#SEM_FAILCRITICALERRORS) ; Don't display error messages
; ;     *Imagehlp = GetModuleHandle_("imagehlp.dll")
; ;     
; ;     ;First try To use imagehlp API (2000/XP/Vista)
; ;     If *Imagehlp
; ;       ImageDirectoryEntryToData = GetProcAddress_(*Imagehlp,"ImageDirectoryEntryToData")
; ;       If ImageDirectoryEntryToData
; ;         *pEntryImports = ImageDirectoryEntryToData(*Module, #True, #IMAGE_DIRECTORY_ENTRY_IMPORT, @lSize)    
; ;         If *pEntryImports
; ;           ProcedureReturn *pEntryImports
; ;         EndIf
; ;       EndIf   
; ;     EndIf
;     
;     ;If imagehlp api is not available
;     *Img_NT_Headers = *Module + *Module\e_lfanew
;     If *Img_NT_Headers
;       *ptr = *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IMPORT]
;       If *ptr
;         *pEntryImports = *Module + *ptr\l
;         ProcedureReturn *pEntryImports
;       EndIf
;     EndIf
;   
;   EndIf
;   ProcedureReturn #Null
; EndProcedure
; 
; Procedure.i __HOOKAPI_GetExportTable(*Module.IMAGE_DOS_HEADER)
;   Protected ImageDirectoryEntryToData._ImageDirectoryEntryToData
;   Protected *Imagehlp
;   Protected iErrMode.i
;   
;   Protected *ptr.LONG,*pEntryExports.IMAGE_EXPORT_DIRECTORY
;   Protected *Img_NT_Headers.IMAGE_NT_HEADERS
;   
;   If *Module
;   
; ;     ;iErrMode = SetErrorMode_(#SEM_FAILCRITICALERRORS) ; Don't display error messages
; ;     *Imagehlp = GetModuleHandle_("imagehlp.dll")
; ;     ;SetErrorMode_(iErrMode)
; ;     
; ;     ; First try to use imagehlp API (2000/XP/Vista)
; ;      If *Imagehlp
; ;        ImageDirectoryEntryToData = GetProcAddress_(*Imagehlp,"ImageDirectoryEntryToData")
; ;        If ImageDirectoryEntryToData
; ;          *pEntryExports = ImageDirectoryEntryToData(*Module, #True, #IMAGE_DIRECTORY_ENTRY_EXPORT, @lSize)    
; ;          If *pEntryExports
; ;            ProcedureReturn *pEntryExports
; ;          EndIf
; ;        EndIf   
; ;      EndIf
;     
;     ;If imagehlp api is not available
;     *Img_NT_Headers = *Module + *Module\e_lfanew
;     If *Img_NT_Headers
;       *ptr = *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_EXPORT]
;       If *ptr
;         *pEntryExports = *Module + *ptr\l
;         ProcedureReturn *pEntryExports
;       EndIf
;     EndIf
;   
;   EndIf
;   ProcedureReturn #Null
; EndProcedure
; 
; Procedure.i __HOOKAPI_ReplaceImportedFunctionInModule(hModule.i,sModuleName.s, sFunction.s, *NewFunctionPtr.i)
; 
; 
; *OldFunction.i = GetProcAddress_(GetModuleHandle_(sModuleName.s), sFunction)
; If *OldFunction
; 
;   *ImportedDLLs.IMAGE_IMPORT_DESCRIPTOR = __HOOKAPI_GetImportTable(hModule)
;   If *ImportedDLLs
;     LastByte.i = __GetModuleIATLastByte(hModule) + hModule
;   
;   
;     While *ImportedDLLs\Name And *ImportedDLLs\FirstThunk
;       
;       sName.s = ""
;       If *ImportedDLLs\Name And *ImportedDLLs\FirstThunk
;       
;         addr1 = *ImportedDLLs\Name + hModule;RvaToVa(hModule,*ImportedDLLs\Name)
;         If *ImportedDLLs\Name And LastByte - (*ImportedDLLs\FirstThunk + hModule) > 0 And hModule
;         ;XXXDebug = *ImportedDLLs\Name
;         ;sName.s = UCase(PeekS(hModule + *ImportedDLLs\Name))
;         sName.s = UCase(PeekS(addr1))
;         EndIf
;         
;       EndIf
;       ;__MyDebug( sName
;       
;     
;       If UCase(sName) = UCase(sModuleName)
;         *itd.IMAGE_THUNK_DATA = *ImportedDLLs\FirstThunk + hModule
;         If *ImportedDLLs\FirstThunk
;         
;         
;         ;*itd.IMAGE_THUNK_DATA = RvaToVa(hModule,*ImportedDLLs\FirstThunk)
;         ;If *itd 
;                 
;         While *itd\Function
;           If *itd\Function = *OldFunction
;             iOldProtection.i = __HOOKAPI_SetMemoryProtection(*itd, #PAGE_EXECUTE_READWRITE)
; 
;             If iOldProtection <> -1
;               *itd\Function = *NewFunctionPtr ; Set new Function pointer
; 
;               __HOOKAPI_SetMemoryProtection(*itd, iOldProtection)
;             EndIf
;             
;           EndIf
;           *itd + SizeOf(IMAGE_THUNK_DATA)
;         Wend
;         EndIf
;         
;       EndIf
;       
;       *ImportedDLLs + SizeOf(IMAGE_IMPORT_DESCRIPTOR)
;     Wend
;   
;   Else
; 
;   EndIf
; 
; Else
; 
; EndIf
; 
; EndProcedure
; 
; 
; 
; Procedure.i __HOOKAPI_ReplaceExportedFunctionInModule(sModuleName.s, sFunction.s, *NewFunctionPtr.i)
; hModule.i = GetModuleHandle_(sModuleName.s)
; *OldFunction.i = GetProcAddress_(hModule, sFunction)
; 
; If *OldFunction And *NewFunctionPtr And hModule
; 
; 
;   *ExportedFunctions.IMAGE_EXPORT_DIRECTORY = __HOOKAPI_GetExportTable(hModule)
;   If *ExportedFunctions
;   
;     *Addr.Integer = *ExportedFunctions\AddressOfFunctions + hModule
;     
;     If *Addr
;       For i = 0 To *ExportedFunctions\NumberOfFunctions - 1
;    
;         If *Addr\i + hModule = *OldFunction
; 
;           iOldProtection.i = __HOOKAPI_SetMemoryProtection(*Addr, #PAGE_EXECUTE_READWRITE)
;           If iOldProtection <> -1
;             ;k= *Addr\i
;             ;MessageBox_(0,Str(*Addr),Str(IsBadWritePtr_(*addr,4)),#MB_OK)
;             
;             *Addr\i = *NewFunctionPtr - hModule
;             ;new = k;*NewFunctionPtr - hModule
;             ;WriteProcessMemory_(GetCurrentProcess_(),*Addr,@new,4,#Null)
;             
;             __HOOKAPI_SetMemoryProtection(*Addr, iOldProtection)
;           EndIf
;         EndIf
;         *Addr + SizeOf(Integer)
;       Next
;     EndIf
;       
;   EndIf
; EndIf
; 
; EndProcedure
; 
; Procedure.i __HOOKAPI_ReplaceImportedFunctionInAllModules(sModuleName.s, sFunction.s, *NewFunctionPtr.i)
; 
;     iResult.i = #False
;     snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPMODULE, 0) 
;     If snapshot 
;     
;         module.MODULEENTRY32
;         module\dwSize = SizeOf(MODULEENTRY32) 
;         
;         If Module32First_(snapshot, @module) 
;             While Module32Next_(snapshot, @module)         
;               If module\hModule
;                 iResult = __HOOKAPI_ReplaceImportedFunctionInModule(module\hModule, sModuleName, sFunction, *NewFunctionPtr)             
;               EndIf
;             Wend
;         EndIf    
;         CloseHandle_(snapshot)
;     EndIf 
;      
;     iResult = __HOOKAPI_ReplaceImportedFunctionInModule(GetModuleHandle_(0), sModuleName, sFunction, *NewFunctionPtr)             
;     
;   ProcedureReturn iResult
; EndProcedure
; 
; 
; Procedure.i __HookApi(sModule.s, sFunction.s, *NewFunction.i)
; If *NewFunction
;   *OldFunction = GetProcAddress_(GetModuleHandle_(sModule), sFunction)
;   __HOOKAPI_ReplaceImportedFunctionInAllModules(sModule.s, sFunction.s, *NewFunction)
;   __HOOKAPI_ReplaceExportedFunctionInModule(sModule.s, sFunction.s, *NewFunction)
;   ProcedureReturn *OldFunction
; EndIf
; EndProcedure
; 
; ;=================================================================================
; 
; 






Global DLLREGISTER_LastError.s = "", DLLREGISTER_OverwritePerUserPath.s = ""

Prototype.i DllRegisterServer()
;Prototype.i DllUnRegisterServer()


Enumeration
  #ERR_OK
  #ERR_INIT_FAILED
  #ERR_DLLLOAD_FAILED
  #ERR_FUNCTION_NOTFOUND
  #ERR_FUNCTION_FAILED
  #ERR_UNEXPECTED
EndEnumeration


Prototype.i OaEnablePerUserTLibRegistration()
Prototype.i RegOverridePredefKey(hKey.i,hNewKey.i)


Structure APIHOOKS
  bRegisterTypeLibHooked.i
  OrgRegisterTypeLib.i
  NewRegisterTypeLib.i
EndStructure

Structure LOADEDDLL
  oleaut32.i
  advapi32.i
EndStructure

Global g_DLLs.LOADEDDLL
Global g_Hooks.APIHOOKS

Procedure.i __DLLReg_Init()
  Protected bResult.i
  bResult.i = #True
  g_DLLs\oleaut32 = LoadLibrary_("oleaut32.dll")
  g_DLLs\advapi32 = LoadLibrary_("advapi32.dll")
  If g_DLLs\oleaut32 = #Null Or g_DLLs\advapi32 = #Null
    ProcedureReturn #ERR_INIT_FAILED
  EndIf
  ProcedureReturn #ERR_OK
EndProcedure


Procedure.i __DLLReg_OverrideClassesRoot()
  Protected sPath.s = "Software\Classes", bResult.i = #False, hNewKey
  Protected RegOverridePredefKey.RegOverridePredefKey
  
If DLLREGISTER_OverwritePerUserPath <> ""
  If RegCreateKey_(#HKEY_CURRENT_USER, DLLREGISTER_OverwritePerUserPath, @hNewKey) = #ERROR_SUCCESS
    ;Nur wenn erfolgreich, dann setzen!
    sPath = DLLREGISTER_OverwritePerUserPath   
    RegCloseKey_(hNewKey)
;    Debug "OKEY"
  EndIf
EndIf

RegOverridePredefKey.RegOverridePredefKey = GetProcAddress_(g_DLLs\advapi32, "RegOverridePredefKey")
If RegOverridePredefKey
  
  If RegOpenKeyEx_(#HKEY_CURRENT_USER, sPath, 0 ,#KEY_ALL_ACCESS, @hNewKey) = #ERROR_SUCCESS

    If RegOverridePredefKey(#HKEY_CLASSES_ROOT, hNewKey) = #ERROR_SUCCESS
      bResult = #True
      RegCloseKey_(hNewKey)
    EndIf
  EndIf  
EndIf
ProcedureReturn bResult 
EndProcedure

Procedure __DLLReg_RestoreClassesRoot()
  Protected RegOverridePredefKey.RegOverridePredefKey
  RegOverridePredefKey.RegOverridePredefKey = GetProcAddress_(g_DLLs\advapi32, "RegOverridePredefKey")
  If RegOverridePredefKey
    RegOverridePredefKey(#HKEY_CLASSES_ROOT, #Null)
  EndIf
EndProcedure

Procedure.i __DLLReg_EnablePerUserRegistration()
  Protected bResult.i, OaEnablePerUserTLibRegistration.OaEnablePerUserTLibRegistration
  bResult.i =  #True
  
  OaEnablePerUserTLibRegistration.OaEnablePerUserTLibRegistration = GetProcAddress_(g_DLLs\oleaut32, "OaEnablePerUserTLibRegistration")
  If OaEnablePerUserTLibRegistration ; erst ab Windows Vista ohne SP1 verfügbar
    OaEnablePerUserTLibRegistration()
  Else
    If OSVersion() = #PB_OS_Windows_Vista
      ; Hooking ist nur notwendig bei Windows Vista ohne SP1 und nur wenn UAC angeschalten ist(?)
      g_Hooks\NewRegisterTypeLib = GetProcAddress_(g_DLLs\oleaut32, "RegisterTypeLibForUser")
      If g_Hooks\NewRegisterTypeLib
        CompilerIf #USE_VIRTUAL_FILE
          If IsVirtualFileUsed
            g_Hooks\OrgRegisterTypeLib = __HookApi("oleaut32.dll", "RegisterTypeLib", g_Hooks\NewRegisterTypeLib)
          EndIf
        CompilerEndIf
        g_Hooks\bRegisterTypeLibHooked = #True
      Else
       bResult = #False
      EndIf
    Else
      g_Hooks\bRegisterTypeLibHooked = #False
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure


Procedure __DLLReg_Free()
  __DLLReg_RestoreClassesRoot()
  If g_Hooks\bRegisterTypeLibHooked
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed
        __HookApi("oleaut32.dll", "RegisterTypeLib", g_Hooks\OrgRegisterTypeLib)
      EndIf
    CompilerEndIf
  EndIf
  If g_DLLs\oleaut32:FreeLibrary_(g_DLLs\oleaut32):EndIf
  If g_DLLs\advapi32:FreeLibrary_(g_DLLs\advapi32):EndIf
  g_DLLs\oleaut32 = #Null
  g_DLLs\advapi32 = #Null
EndProcedure

Procedure __DLLReg_ErrorMsg(sDLLFilename.s,bRegister.i, bRegisterAllUsers.i, iCode.i, iRegisterResult.i)
  Protected sDLL.s, sText.s, sRegister.s, sUser.s
  
  sDLL.s = Chr(34) + sDLLFilename + Chr(34)
  sText.s = ""
  Select iCode
  Case #ERR_INIT_FAILED
    sText = "Can not load necessary system dlls!"
  Case #ERR_DLLLOAD_FAILED
    sText = "Failed to load dll/ocx file " + sDLL
  Case #ERR_FUNCTION_NOTFOUND
    If bRegister
      sText = "The function DllRegisterServer was not found in: " + sDLL 
    Else
      sText = "The function DllUnregisterServer was not found in: " + sDLL
    EndIf
  Case #ERR_UNEXPECTED
     sText = "Registering failed with unexpected error: " + ErrorMessage()
  Case #ERR_FUNCTION_FAILED  
    If bRegister
      sText = "DllRegisterServer for " + sDLL + " failed with error code: "+Str(iRegisterResult) 
    Else
      sText = "DllUnregisterServer for " + sDLL + " failed with error code: "+Str(iRegisterResult) 
    EndIf
  Case #ERR_OK
    If bRegister
      sRegister.s = " registered"
    Else
      sRegister.s = " unregistered"  
    EndIf
    If bRegisterAllUsers
      sUser.s = "all users."
    Else
       sUser.s = "the current user." 
    EndIf
    sText = sDLL + sRegister + " sucessfully for " + sUser
  Default
    sText = "Registering failed with unknown error!"
EndSelect
DLLREGISTER_LastError = sText
EndProcedure

Procedure.i __CallRegister(sDLLFilename.s, sFunction.s, bRegisterAllUsers.i, *outRegisterResult.Integer)
  Protected iErrorMode, hModule.i, registerFunction.DllRegisterServer
  If bRegisterAllUsers = #False
    If __DLLReg_EnablePerUserRegistration() = #False
      ProcedureReturn #ERR_INIT_FAILED
    EndIf
    If __DLLReg_OverrideClassesRoot() = #False
      ProcedureReturn #ERR_INIT_FAILED
    EndIf
  Else
    ;Register for all Users
  EndIf
  iErrorMode = SetErrorMode_(#SEM_FAILCRITICALERRORS)
  hModule.i = LoadLibrary_(sDLLFilename)
  SetErrorMode_(iErrorMode)
  If hModule
    registerFunction.DllRegisterServer = GetProcAddress_(hModule, sFunction)
    If registerFunction
      *outRegisterResult\i = registerFunction()
      If *outRegisterResult\i <> #S_OK
        ProcedureReturn #ERR_FUNCTION_FAILED
      EndIf
    Else
      ProcedureReturn #ERR_FUNCTION_NOTFOUND
    EndIf
    FreeLibrary_(hModule)
  Else
    ProcedureReturn #ERR_DLLLOAD_FAILED
  EndIf
  ProcedureReturn #ERR_OK
EndProcedure

Procedure DLLREGISTER_Register(sDLLFile.s, bAllUsers.i)
  Protected iResult.i, registerResult.i
  iResult = __DLLReg_Init()
  If iResult = #ERR_OK
    iResult = __CallRegister(sDLLFile, "DllRegisterServer", bAllUsers, @registerResult)    
    __DLLReg_ErrorMsg(sDLLFile,#True, bAllUsers, iResult, RegisterResult)
    __DLLReg_Free()
  Else
    __DLLReg_ErrorMsg("",#True, bAllUsers, iResult, 0)
  EndIf  
  ProcedureReturn iResult  
EndProcedure

Procedure DLLREGISTER_UnRegister(sDLLFile.s, bAllUsers.i)
  Protected iResult.i, registerResult.i
  iResult = __DLLReg_Init()
  If iResult = #ERR_OK
   iResult = __CallRegister(sDLLFile, "DllUnregisterServer", bAllUsers, @registerResult)    
    __DLLReg_ErrorMsg(sDLLFile, #False, bAllUsers, iResult, RegisterResult)  
    __DLLReg_Free()
  Else
    __DLLReg_ErrorMsg("",#False, bAllUsers, iResult, 0)
  EndIf  
  ProcedureReturn iResult  
EndProcedure


Procedure.s DLLREGISTER_GetLastError()
ProcedureReturn DLLREGISTER_LastError
EndProcedure

Procedure.s DLLREGISTER_OverwritePerUserPath(sAddPath.s)
DLLREGISTER_OverwritePerUserPath = sAddPath
EndProcedure




Global lESP.i, lEAX.i, lOldErrorMode.i

Macro STORE_ESP
  !MOV [v_lEAX],EAX
  !MOV EAX,ESP
  !MOV [v_lESP],EAX
  !MOV EAX,[v_lEAX]
EndMacro

Macro RESTORE_ESP
  !MOV [v_lEAX],EAX
  !MOV EAX,[v_lESP]
  !MOV ESP,EAX  
  !MOV EAX,[v_lEAX]  
EndMacro
  
Procedure SafeRegister(sDLL.s,bAllUser.i, bUnRegister.i)
  Protected iResult
  lOldErrorMode = SetErrorMode_(#SEM_FAILCRITICALERRORS)
  STORE_ESP
  OnErrorGoto(?DLLRegisterExceptionHandler)
  If bUnRegister
    iResult = DLLREGISTER_UnRegister(sDLL,bAllUser)
  Else
    iResult = DLLREGISTER_Register(sDLL,bAllUser)   
  EndIf
  SetErrorMode_(lOldErrorMode)
  OnErrorCall(@ErrorHandler())
  ProcedureReturn iResult
  DLLRegisterExceptionHandler:
  RESTORE_ESP
  OnErrorCall(@ErrorHandler())
  SetErrorMode_(lOldErrorMode)
  If bUnRegister
    ;Debug "Error while unregistering " + sDLL ;+ Exception INFO
    WriteLog("Error while unregistering " + sDLL +" Line:"+Str(ErrorLine())+" Message:"+ErrorMessage())
  Else
    ;Debug "Error while registering " + sDLL ;+ Exception INFO 
    WriteLog("Error while registering " + sDLL +" Line:"+Str(ErrorLine())+" Message:"+ErrorMessage())
  EndIf
  ProcedureReturn #ERR_UNEXPECTED
EndProcedure


;{ Sample

; ;DLLREGISTER_OverwritePerUserPath("Software\GFP-CODECS")
; 
; DLLREGISTER_Register("C:\Program Files (x86)\Dirac\DiracSplitter-Dirac.ax",#True)
; Debug DLLREGISTER_GetLastError()
; 

;}




; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 333
; FirstLine = 304
; Folding = ag8
; EnableXP
; EnableAdmin
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
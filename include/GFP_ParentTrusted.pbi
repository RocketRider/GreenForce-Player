;Thanks to Gustavo J. Fiorenza (aim: gushhfx)
EnableExplicit

Prototype.l GetModuleFileNameEx(hProcess.l, hModule.l, *lpFilename, nSize)
Prototype.l EnumProcessModules(hProcess, *lphModule, cb, lpchNeeded)
Prototype.l GetProcessImageFileName(hProcess.l,*lpImageFileName,nSize)

Global GetModuleFileNameEx.GetModuleFileNameEx
Global EnumProcessModules.EnumProcessModules
Global GetProcessImageFileName.GetProcessImageFileName
Global processlib

Prototype.i protoGetProcessImageFileName(hProcess, lpImageFileName, nSize)
Global GetProcessImageFileName.protoGetProcessImageFileName

Prototype.b protoQueryFullProcessImageName(hProcess, dwFlags, lpExeName, lpdwSize)
Global QueryFullProcessImageName.protoQueryFullProcessImageName


#WTD_UI_NONE 					= 2
#WTD_CHOICE_FILE 				= 1
#WTD_REVOKE_NONE 				= 0
#WTD_STATEACTION_IGNORE 			= 0
#WTD_HASH_ONLY_FLAG 				= $00000200
#WTD_REVOCATION_CHECK_NONE			= $00000010

#TRUST_E_PROVIDER_UNKNOWN 			= $800B0001
#TRUST_E_ACTION_UNKNOWN				= $800B0002
#TRUST_E_SUBJECT_FORM_UNKNOWN			= $800B0003
#TRUST_E_SUBJECT_NOT_TRUSTED			= $800B0004
#TRUST_E_NOSIGNATURE				= $800B0100
 
 
Macro LOWORD( word ) 	: ( word & $FFFF ) 	: EndMacro
Macro LOBYTE( byte ) 	: ( byte & $FF ) 	: EndMacro
 
; Macro GUID(name, l1, w1, w2, b1b2, brest)
;   DataSection
;   name:
;     Data.l $l1
;     Data.w $w1, $w2
;     Data.b $b1b2 >> 8, $b1b2 & $FF
;     Data.b $brest >> 40 & $FF
;     Data.b $brest >> 32 & $FF
;     Data.b $brest >> 24 & $FF
;     Data.b $brest >> 16 & $FF
;     Data.b $brest >> 8 & $FF
;     Data.b $brest & $FF
;   EndDataSection
; EndMacro

GUID(WINTRUST_ACTION_GENERIC_VERIFY_V2, 00AAC56B, CD44, 11D0, 8CC2, 00C04FC295EE)
GUID(WINTRUST_ACTION_GENERIC_CERT_VERIFY, 189A3842, 3041, 11d1, 85E1, 00C04FC295EE)
GUID(WINTRUST_ACTION_GENERIC_CHAIN_VERIFY, fc451c16, ac75, 11d1, b4b8, 00c04fb66ea0)

Structure WINTRUST_DATA
	cbStruct.l
	pPolicyCallbackData.l
	pSIPClientData.l
	dwUIChoice.l
	fdwRevocationChecks.l
	dwUnionChoice.l
 
	StructureUnion
		*pFile.WINTRUST_FILE_INFO
		*pCatalog.WINTRUST_CATALOG_INFO
		*pBlob.WINTRUST_BLOB_INFO
		*pSgnr.WINTRUST_SGNR_INFO
		*pCert.WINTRUST_CERT_INFO
	EndStructureUnion
 
	dwStateAction.l
	hWVTStateData.l
	*pwszURLReference
	dwProvFlags.l
	dwUIContext.l
EndStructure
 
Structure WINTRUST_FILE_INFO
  cbStruct.l
  *pcwszFilePath
  hFile.l
  pgKnownSubject.l
EndStructure


Procedure.l VerifyFile( Filename.s )
	If OSVersion()<#PB_OS_Windows_XP;Older than xp is not supported!
		ProcedureReturn 2
	EndIf
 
	Define.WINTRUST_DATA 		WinTD
	Define.WINTRUST_FILE_INFO 	wf
 
	Define.l gAction 			= ?WINTRUST_ACTION_GENERIC_CHAIN_VERIFY
	Define.s wszPath 			= Space(#MAX_PATH*2)
 
	PokeS( @wszPath, FileName, Len(FileName)+1, #PB_Unicode )
	With wf
		\cbStruct 			= SizeOf(WINTRUST_FILE_INFO)
		\hFile 				= #Null
		\pcwszFilePath 			= @wszPath
	EndWith
 
	With WinTD
		\cbStruct 			= SizeOf(WINTRUST_DATA)
		\dwUIChoice 			= #WTD_UI_NONE
		\dwUnionChoice 			= #WTD_CHOICE_FILE
		\fdwRevocationChecks 		= #WTD_REVOKE_NONE
		\pFile 				= wf
		\dwStateAction 			= #WTD_STATEACTION_IGNORE
		\dwProvFlags 			= #WTD_HASH_ONLY_FLAG | #WTD_REVOCATION_CHECK_NONE
	EndWith
 
	ProcedureReturn WinVerifyTrust_( 0, gAction, WinTD )
EndProcedure
 
Procedure.s TrustStatus( ReturnCode.l )
	Select ReturnCode
		Case #ERROR_SUCCESS
			ProcedureReturn "Trusted"
		Case #TRUST_E_PROVIDER_UNKNOWN
			ProcedureReturn "Provider Unknown"
		Case #TRUST_E_SUBJECT_FORM_UNKNOWN
			ProcedureReturn "Form Unknown"
		Case #TRUST_E_SUBJECT_NOT_TRUSTED
			ProcedureReturn "Not Trusted"
		Case #TRUST_E_NOSIGNATURE
			ProcedureReturn "Not signed"
	EndSelect
EndProcedure

Procedure.i isFileTrusted(File.s)
  If VerifyFile(File)=#ERROR_SUCCESS
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False  
EndProcedure


Procedure InitProcessLib()
  processlib = OpenLibrary(#PB_Any, "psapi.dll")
  If processlib
   GetModuleFileNameEx = GetFunction(processlib, "GetModuleFileNameExW")
   EnumProcessModules = GetFunction(processlib, "EnumProcessModules")
   GetProcessImageFileName = GetFunction(processlib,"GetProcessImageFileNameW")
  EndIf
EndProcedure  

Procedure CloseProcessLib()
  If processlib
    CloseLibrary(processlib)
  EndIf
EndProcedure

Procedure GetProcessParentID(pid)
  Protected ProcessEntry.PROCESSENTRY32
  Protected ProcessSnapHandle.l, ok.l 
  If GetModuleFileNameEx
    ProcessEntry\dwSize = SizeOf(ProcessEntry)
    ProcessSnapHandle = CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS,0)
    ok = Process32First_(ProcessSnapHandle, ProcessEntry)
      
    While ok
      If ProcessEntry\th32ProcessID = pid
        CloseHandle_(ProcessSnapHandle)
        ProcedureReturn ProcessEntry\th32ParentProcessID
      EndIf
      ok = Process32Next_(ProcessSnapHandle, ProcessEntry)
    Wend
    
    CloseHandle_(ProcessSnapHandle)
  EndIf
  ProcedureReturn 0
EndProcedure



Procedure.s GetProcessParentFile()
  Protected sFile.s, pid.i, ppid.i, hProcess.i, handle, res, Entry.MODULEENTRY32, hModule,kernel32,FileSize
  If GetModuleFileNameEx
    FileSize=#MAX_PATH
    sFile = Space(FileSize)
    pid = GetCurrentProcessId_()
    If pid
      ppid = GetProcessParentID(pid)
      If ppid
        hProcess = OpenProcess_(#PROCESS_QUERY_INFORMATION | #PROCESS_VM_READ, 0, ppid)
        kernel32 = OpenLibrary(#PB_Any, "kernel32.dll")

        If IsLibrary(kernel32)
          QueryFullProcessImageName = GetFunction(kernel32, "QueryFullProcessImageNameW")
          If QueryFullProcessImageName
            QueryFullProcessImageName(hProcess, 0, @sFile, @FileSize)
          EndIf
          CloseLibrary(kernel32)
        EndIf
        
      EndIf
    EndIf
  EndIf
  ProcedureReturn Trim(sFile)
EndProcedure

Procedure isParentProcessTrusted()
  Protected result=#False
  InitProcessLib()
  result = isFileTrusted(GetProcessParentFile())
  CloseProcessLib()
  ProcedureReturn result
EndProcedure  


;Debug isParentProcessTrusted()

; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 196
; FirstLine = 146
; Folding = --
; EnableThread
; EnableXP
; EnableOnError
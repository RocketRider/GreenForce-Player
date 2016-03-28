;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************

; Es gibt Probleme, wenn das Hooking aktiv ist, und dann ein FileRequester geöffnet wird, da hierbei jede menge DLLs nachgeladen werden.
; Es tritt speziell ein Access Violation mit Turtoise SVN(rechtsklick auf einen SVN ordner) auf. Deshalb wird nun vor dem öffnen des Requesters die Export-Table der KErnel32.dll wiederhergestellt, damit die neu geladenen DLLs nicht gehookt werden.
; Die genaue Uhrsache für das Prblem ist allerdings nicht bekannt.

;ACHTUNG: Fix für .mkv ist alles andere als gut. Es wird overlapped unterstüzung benötigig
;Diesen komplett zu implemenitieren wäre allerdings sehr aufwändig...

;ACHTUNG:
;__GetFileAttributesW hat ein Problem mit SQLite, wenn der PB-Debugger aktiv ist
;veruhsacht dann Fehler "DB: disk I/O error" z.B. beim Löschen von Passwörtern
;Es scheint aber trotzdem zu funktionieren

;ACHTUNG!!!:
; Bei gehookten Funktionen gibt es ein Problem mit den Stringbefehlen von PureBasic.
; Sobald ein dynamischer String erstellt wird wie z.B: test(A$ + "test") führt das dazu das die "Basisstrings" übeerschrieben werden.
; Dies ist z.B. bei RunProgram der Fall. Andere Thread sollten nicht betriffen sein.

;#USE_BUGGY_VIRTUALFILE_LOGGING = #False;#True;


;===========================================================
;==================== WIN 8 BUGFIX =========================
;
; UNBEDINGT BEI DER FINAL WIN8 TESTEN, OB api-ms-win-core-file-l1-1-1.dll NÖTIG IST!!!
;
; Für Windows 8 muss Hooking selsamerweise über api-ms-win-core-file-l1-1-1.dll
; erfolgen, obwohl GetModuleHandle genau das gleiche wie für Kernel32.dll zurückgibt
; Für Windows 7 funktioniert es aber nicht mit api-ms-win-core-file-l1-1-0.dll sonder nur mit Kernel32.dll
;
; --> JA Nötig, nun aber Hooking über KernelBase.dll
;
;===========================================================

#USE_NOT_RECOMMENDED_WIN8_VIRTUAL_FILE_FIX = #False


EnableExplicit

XIncludeFile "GFP_MYLIST.pbi"
XIncludeFile "GFP_StringCommands_3.pbi"

; Import "Kernel32.lib"
;   GetProcAddress_(hMod.i, Name.p-ascii) As "_GetProcAddress@8"
; EndImport
; 
; #USE_VIRTUALFILE_SECURE_MEMORY = #True

#LOADLIBRARYCOPY_ID = "693w2i"
;#MAX_DUPLICATED_HANDLES = 256 ; 2010-07-01

#VIRTUAL_LOG_NONE = 0
#VIRTUAL_LOG_ERROR = 1
#VIRTUAL_LOG_WARN = 2
#VIRTUAL_LOG_DEBUG = 3


#INVALID_SET_FILE_POINTER = -1
#INVALID_FILE_SIZE = -1

#TH32CS_SNAPMODULE = $8 

Structure VirtualFile
    bUsed.i
    iUseCount.i
    bCanCreateNewHandles.i
    sFileName.s
    *BufferPtr
    qSize.q
    bFreeBuffer.i
   
;      bAsync.i
;      iLoadedBytes.i    
;      hMutex.i
;      iOrginalFile.i
    *DecryptionBuffer.byte
    bIsEncrypted.i
    iHeaderOffset.i
    sExistingFileName.s
    
    ;2011-03-04 added
    bDownloadFromURL.i
    iUniqueDownloadID.i
    
    hMutex.i ; 2011-03-04
    
EndStructure

Structure VirtualFileHandle
    bUsed.i
    ;hPipeHandle.i   ;2010-07-03
    ;hPipeFileHandle.i
    iVirtualFile.i    
    qPosition.q
    bOverlapped.i
    ;bWriteAccess.i ;NOT SUPPORTED AT THE MOMENT
    ;hLoadLockMutex.i
    hDecryptedFileHandle.i
    
    
    iUseCound.i ; 2010-07-01 used for duplicated handles
    ;hDuplicatedHandles.i[#MAX_DUPLICATED_HANDLES]; 2010-07-01
    ;List handles.i()
    handles.MYLIST
EndStructure
  
Structure IMAGE_IMPORT_DESCRIPTOR
  OriginalFirstThunk.l
  TimeDateStamp.l
  ForwarderChain.l
  Name.l
  FirstThunk.l
EndStructure

Structure IMAGE_THUNK_DATA
  *Function
EndStructure


; Structure WIN32_FILE_ATTRIBUTE_DATA
;   dwFileAttributes.l
;   ftCreationTime.FILETIME
;   ftLastAccessTime.FILETIME
;   ftLastWriteTime.FILETIME
;   nFileSizeHigh.l
;   nFileSizeLow.l
; EndStructure

#GetFileExInfoStandard = 0
#GEtFileExMaxInfoLevel = 1

Structure WIN32_FIND_DATA_ANSI
  dwFileAttributes.l
  ftCreationTime.FILETIME
  ftLastAccessTime.FILETIME
  ftLastWriteTime.FILETIME
  nFileSizeHigh.l
  nFileSizeLow.l
  dwReserved0.l
  dwReserved1.l
  cFileName.b[260]
  cAlternate.b[14]
EndStructure

Structure WIN32_FIND_DATA_UNICODE
  dwFileAttributes.l
  ftCreationTime.FILETIME
  ftLastAccessTime.FILETIME
  ftLastWriteTime.FILETIME
  nFileSizeHigh.l
  nFileSizeLow.l
  dwReserved0.l
  dwReserved1.l
  cFileName.w[260]
  cAlternate.w[14]
EndStructure


Prototype.i MyGetFileType(handle)
Prototype.i MyCreateFile(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
Prototype.i MySetFilePointer(hFile,lDistanceToMove,lpDistanceToMoveHigh,dwMoveMethod)
Prototype.i MySetFilePointerEx(hFile,liDistanceToMove.q,lpNewFilePointer,dwMoveMethod) ; ,liDistanceToMove is a QUAD!!!
Prototype.i MyReadFile(hFile,lpBuffer,nNumberOfBytesToRead,lpNumberOfBytesRead,lpOverlapped);
Prototype.i CBFileIOCompletionRoutine(dwErrorCode,dwNumberOfBytesTransfered,lpOverlapped)
Prototype.i MyGetFileSizeEx(hFile,lpFileSize);
Prototype.i MyGetFileSize(hFile,lpFileSizeHigh)
Prototype.i MyReadFileEx(hFile,lpBuffer,nNumberOfBytesToRead,lpOverlapped,lpCompletionRoutine)
Prototype.i MyGetFileInformationByHandle(hFile, *lpFileInformation.BY_HANDLE_FILE_INFORMATION)
Prototype.i MyCloseHandle(hFile)
Prototype.i MyDuplicateHandle(hSourceProcessHandle,hSourceHandle,hTargetProcessHandle,lpTargetHandle,dwDesiredAccess,bInheritHandle,dwOptions);

Prototype.i MyGetFileAttributes(lpFileName)
Prototype.i MyGetFileAttributesEx(lpFileName, fInfoLevelId, lpFileInformation)
Prototype.i MyFindFirstFile(lpFileName, lpFindFileData)


Prototype.l _ImageDirectoryEntryToData(ImageBase.l,MappedAsImage.l,DirectoryEntry.l,Size.l)


Structure APIHOOK
  OrgCreateFileA.MyCreateFile
  OrgCreateFileW.MyCreateFile
  OrgReadFile.MyReadFile
  OrgSetFilePointer.MySetFilePointer
  OrgSetFilePointerEx.MySetFilePointerEx
  OrgGetFileSizeEx.MyGetFileSizeEx
  OrgGetFileSize.MyGetFileSize
  OrgGetFileType.MyGetFileType
  OrgGetFileInformationByHandle.MyGetFileInformationByHandle
  OrgReadFileEx.MyReadFileEx
  OrgCloseHandle.MyCloseHandle
  OrgDuplicateHandle.MyDuplicateHandle
  
  ; 2010-07-23 hinz  
  OrgGetFileAttributesA.MyGetFileAttributes
  OrgGetFileAttributesExA.MyGetFileAttributesEx
  OrgFindFirstFileA.MyFindFirstFile
  OrgGetFileAttributesW.MyGetFileAttributes
  OrgGetFileAttributesExW.MyGetFileAttributesEx
  OrgFindFirstFileW.MyFindFirstFile
  
  CodeReplaceCreateFileA.MyCreateFile
  CodeReplaceCreateFileW.MyCreateFile
  CodeReplaceReadFile.MyReadFile
  CodeReplaceSetFilePointer.MySetFilePointer
  CodeReplaceSetFilePointerEx.MySetFilePointerEx
  CodeReplaceGetFileSizeEx.MyGetFileSizeEx
  CodeReplaceGetFileSize.MyGetFileSize
  CodeReplaceGetFileType.MyGetFileType
  CodeReplaceGetFileInformationByHandle.MyGetFileInformationByHandle
  CodeReplaceReadFileEx.MyReadFileEx
  CodeReplaceCloseHandle.MyCloseHandle
  CodeReplaceDuplicateHandle.MyDuplicateHandle
  
  ; 2010-07-23 hinz  
  CodeReplaceGetFileAttributesA.MyGetFileAttributes
  CodeReplaceGetFileAttributesExA.MyGetFileAttributesEx
  CodeReplaceFindFirstFileA.MyFindFirstFile
  CodeReplaceGetFileAttributesW.MyGetFileAttributes
  CodeReplaceGetFileAttributesExW.MyGetFileAttributesEx
  CodeReplaceFindFirstFileW.MyFindFirstFile  
  
  OrgCreateFileAData.i
  OrgCreateFileWData.i
  OrgReadFileData.i
  OrgSetFilePointerData.i
  OrgSetFilePointerExData.i
  OrgGetFileSizeExData.i
  OrgGetFileSizeData.i
  OrgGetFileTypeData.i
  OrgGetFileInformationByHandleData.i
  OrgReadFileExData.i
  OrgCloseHandleData.i  
  OrgDuplicateHandleData.i  
    
  ; 2010-07-23 hinz
  OrgGetFileAttributesAData.i
  OrgGetFileAttributesExAData.i
  OrgFindFirstFileAData.i
  OrgGetFileAttributesWData.i
  OrgGetFileAttributesExWData.i
  OrgFindFirstFileWData.i
    
EndStructure

Structure VIRTUALFILE_GLOBALS
Hooks.APIHOOK
iMaxVirtualFiles.i
iMaxVirtualFileHandles.i
bActive.i
hLockMutex.i
;hLockMutex.CRITICAL_SECTION
iRunningCalls.i
;iStartTime
;bLogLevel.i
hNewKernelModuleFile.i ; 2012-03-18
hNewKernelModuleHandle.i ; 2012-03-18
bReplaceCode.i
bHookedExport.i
bHookedImport.i

bFirstFunctionModuleOutput.i
sModuleBlackList.s
EndStructure

Global Dim VirtualFiles.VirtualFile(1)
Global Dim VirtualFileHandles.VirtualFileHandle(1)
Global g_VirtualFile.VIRTUALFILE_GLOBALS



Procedure __MyDebug(Text.s)
;  Debug Text  
;   AddGadgetItem(1,-1,Text)
;   Repeat
;   Until WindowEvent() = 0
;- CHECK!, MUST NOT BE COMMENTED!
WriteLog(Text, #LOGLEVEL_DEBUG, #False)
EndProcedure


Procedure __MyError(Text.s)
  ;Debug Text
;- CHECK!, MUST NOT BE COMMENTED!
  WriteLog(Text, #LOGLEVEL_ERROR, #False)
;   AddGadgetItem(1,-1,Text)
;   Repeat
;   Until WindowEvent() = 0
EndProcedure

Procedure __MyWarn(Text.s)
  ;Debug Text
;- CHECK!, MUST NOT BE COMMENTED!
WriteLog(Text, #LOGLEVEL_ERROR, #False)
EndProcedure
; 

Macro __HookLogDebug(param)
  CompilerIf #USE_BUGGY_VIRTUALFILE_LOGGING
    __MyDebug(param)
  CompilerEndIf  
EndMacro  

Macro __HookLogError(param)
  CompilerIf #USE_BUGGY_VIRTUALFILE_LOGGING
    __MyError(param)
  CompilerEndIf  
EndMacro  

Macro __HookLogWarn(param)
  CompilerIf #USE_BUGGY_VIRTUALFILE_LOGGING
    __MyWarn(param)
  CompilerEndIf  
EndMacro  


Procedure.s GetKernelCoreFile()
  
  ;DIRTY FIX 2013-11-05 for Server 2008R2
  If OSVersion() = #PB_OS_Windows_Server_2008_R2
    If GetModuleHandle_("api-ms-win-core-file-l1-2-0.dll")
      ProcedureReturn "api-ms-win-core-file-l1-2-0.dll"  
    EndIf    
    If GetModuleHandle_("api-ms-win-core-file-l1-1-1.dll")
      ProcedureReturn "api-ms-win-core-file-l1-1-1.dll"
    EndIf
    If GetModuleHandle_("api-ms-win-core-file-l1-1-0.dll")
      ProcedureReturn "api-ms-win-core-file-l1-1-0.dll"
    EndIf    
    ProcedureReturn "kernel32.dll" 
  EndIf  
  
  
  CompilerIf #USE_NOT_RECOMMENDED_WIN8_VIRTUAL_FILE_FIX
    If OSVersion() > #PB_OS_Windows_7
      ;If GetModuleHandle_("api-ms-win-core-file-l2-1-0.dll")  -- hat niocht die nötigen funktionen drin
      ;  ProcedureReturn "api-ms-win-core-file-l2-1-0.dll"  
      ;EndIf
      If GetModuleHandle_("api-ms-win-core-file-l1-2-0.dll")
        ProcedureReturn "api-ms-win-core-file-l1-2-0.dll"  
      EndIf    
      If GetModuleHandle_("api-ms-win-core-file-l1-1-1.dll")
        ProcedureReturn "api-ms-win-core-file-l1-1-1.dll"
      EndIf
      If GetModuleHandle_("api-ms-win-core-file-l1-1-0.dll")
        ProcedureReturn "api-ms-win-core-file-l1-1-0.dll"
      EndIf    
    EndIf  
    ProcedureReturn "kernel32.dll" 
  CompilerElse
    ;2012-08-21 comon case, #USE_NOT_RECOMMENDED_WIN8_VIRTUAL_FILE_FIX should be usually false!
    If OSVersion() > #PB_OS_Windows_7
      ProcedureReturn "KernelBase.dll"
    Else
      ProcedureReturn "Kernel32.dll"
    EndIf  
  CompilerEndIf
EndProcedure  

Procedure.s GetKernelCoreHandle() 
  
  ;DIRTY FIX 2013-11-05 for Server 2008R2
  If OSVersion() = #PB_OS_Windows_Server_2008_R2
    If GetModuleHandle_("api-ms-win-core-file-l1-2-0.dll")
      ProcedureReturn "api-ms-win-core-file-l1-2-0.dll"  
    EndIf    
    If GetModuleHandle_("api-ms-win-core-file-l1-1-1.dll")
      ProcedureReturn "api-ms-win-core-file-l1-1-1.dll"
    EndIf
    If GetModuleHandle_("api-ms-win-core-file-l1-1-0.dll")
      ProcedureReturn "api-ms-win-core-file-l1-1-0.dll"
    EndIf    
    ProcedureReturn "kernel32.dll" 
  EndIf  
  
  
  CompilerIf #USE_NOT_RECOMMENDED_WIN8_VIRTUAL_FILE_FIX  
    If OSVersion() > #PB_OS_Windows_7
      If GetModuleHandle_("api-ms-win-core-handle-l1-1-1.dll")
        ProcedureReturn "api-ms-win-core-handle-l1-1-1.dll"
      EndIf
      If GetModuleHandle_("api-ms-win-core-handle-l1-1-0.dll")
        ProcedureReturn "api-ms-win-core-handle-l1-1-0.dll"
      EndIf   
    EndIf  
    ProcedureReturn "kernel32.dll"  
  CompilerElse
    ;2012-08-21 comon case, #USE_NOT_RECOMMENDED_WIN8_VIRTUAL_FILE_FIX should be usually false!
    If OSVersion() > #PB_OS_Windows_7
      ProcedureReturn "KernelBase.dll"
    Else
      ProcedureReturn "Kernel32.dll"
    EndIf  
  CompilerEndIf
  
EndProcedure 

; Procedure.s GetKernelCore()
;   ProcedureReturn "kernel32.dll"  
; EndProcedure 






; ; 0 Nichts, 1 Error, 2 Warn, 3 Debug
; Macro LOG_BEGIN(Text)
;   Protected sDCommandDebug.s = "", sLogOutput.s = "", sLogTmp.s, iLogPos.i
;   If g_VirtualFile\bLogLevel > #VIRTUAL_LOG_NONE
;     sDCommandDebug = Text
;   EndIf
; EndMacro
; 
; Macro LOG_DEBUG(Text)
;   If g_VirtualFile\bLogLevel >= #VIRTUAL_LOG_DEBUG
;     sLogOutput = sLogOutput + "DEB:" + Text + #LFCR$
;   EndIf
; EndMacro
; 
; Macro LOG_WARN(Text)
;   If g_VirtualFile\bLogLevel >= #VIRTUAL_LOG_WARN
;     sLogOutput = sLogOutput + "WRN:" + Text + #LFCR$
;   EndIf
; EndMacro
; 
; Macro LOG_ERROR(Text)
;   If g_VirtualFile\bLogLevel >= #VIRTUAL_LOG_ERROR
;     sLogOutput = sLogOutput + "ERR:" + Text + #LFCR$
;   EndIf
; EndMacro
; 
; Macro LOG_END
;   If g_VirtualFile\bLogLevel > 0  
;     If sLogOutput <> ""      
;       __HookLogDebug(sDCommandDebug)
;       For iLogPos = 1 To CountString(sLogOutput, #LFCR$)
;         sLogTmp = StringField(sLogOutput, iLogPos, #LFCR$)
;         If Left(sLogTmp,4) = "DEB:"
;           __HookLogDebug(Right(sLogTmp,Len(sLogTmp)-4))  
;         EndIf
;         If Left(sLogTmp,4) = "WRN:"
;           __HookLogWarn(Right(sLogTmp,Len(sLogTmp)-4))    
;         EndIf        
;         If Left(sLogTmp,4) = "ERR:"
;           __HookLogError(Right(sLogTmp,Len(sLogTmp)-4))   
;         EndIf        
;       Next     
;     EndIf
;   EndIf
; EndMacro  


Procedure Mutex_Create()
  g_VirtualFile\hLockMutex = CreateMutex_(#Null, #False, #Null)
  ProcedureReturn g_VirtualFile\hLockMutex 
EndProcedure

Procedure Mutex_TryLock()
  Protected iWaitResult = WaitForSingleObject_(g_VirtualFile\hLockMutex, 16)     
  If iWaitResult = #WAIT_OBJECT_0
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure Mutex_UnLock()
  ReleaseMutex_(g_VirtualFile\hLockMutex)
EndProcedure

Procedure Mutex_Recreate()
  If g_VirtualFile\Hooks\OrgCloseHandle
    g_VirtualFile\Hooks\OrgCloseHandle(g_VirtualFile\hLockMutex)
  EndIf
  g_VirtualFile\hLockMutex = CreateMutex_(#Null, #False, #Null)
EndProcedure

Procedure Mutex_Free()
  Protected hMutex = g_VirtualFile\hLockMutex 
  __HookLogDebug("Releasing Mutex")
  g_VirtualFile\hLockMutex = #Null ; Make sure there will be no deadloack wenn calling closehande
  CloseHandle_(hMutex)
EndProcedure




Procedure SecureCopyMemory(*Src, *Dest, size.i) ; is slow, but secure, speed is only 50% of CopyMemory...
  ProcedureReturn WriteProcessMemory_(GetCurrentProcess_(), *Dest, *Src, size, #Null)
EndProcedure

Procedure SecurePokeL(*Dest, lValue.l)
  ProcedureReturn WriteProcessMemory_(GetCurrentProcess_(), *Dest, @lValue, SizeOf(Long), #Null)  
EndProcedure



Macro INIT_VIRTUAL_MUTEX
Protected start, bTryOk, __iLastErrorCode.i
EndMacro

Macro LOCK_VIRTUAL_MUTEX
  ;__HookLogError( "LOCK " +Str(  g_VirtualFile\iRunningCalls) + "   "+Str(GetCurrentThreadId_()))

  If g_VirtualFile\hLockMutex
    start = GetTickCount_()
    !PAUSE
    Repeat
      !PAUSE
      bTryOk = Mutex_TryLock()
    Until bTryOk Or GetTickCount_()-start > 2500  ; MACHT EVTL. PROBLEME -> WIEDER AUF 1000 setzen
    ;__HookLogError("waited for ms "+Str(GetTickCount_()-start) +"      "+Str(GetCurrentThreadId_()))   
    If bTryOk = #False
      __HookLogError("Critical section is already in use... continue without thread safety")
      Mutex_Recreate()
      bTryOk = Mutex_TryLock()
      ;Continue without thead safety
    EndIf

    g_VirtualFile\iRunningCalls + 1
  Else
    __HookLogError("WARN: no mutex available")
  EndIf

EndMacro


Macro UNLOCK_VIRTUAL_MUTEX
    __iLastErrorCode = GetLastError_()
  ;__HookLogError( "UNLOCK "+Str(GetCurrentThreadId_()))
  If g_VirtualFile\hLockMutex 
    If bTryOk 
      Mutex_UnLock() ; Nur, wenn lock erfogreich war!
    EndIf
    g_VirtualFile\iRunningCalls - 1
    ;Debug "time elapsed: "+ Str(GetTickCount_() - g_VirtualFile\iStartTime)   
    ;UnlockMutex( g_VirtualFile\hLockMutex)
  Else
    __HookLogError("WARN: no mutex available")
  EndIf  
  SetLastError_(__iLastErrorCode)
EndMacro






; 2011-03-06 added
;==============================================================
Procedure IndividualMutex_Create()
  ProcedureReturn CreateMutex_(#Null, #False, #Null)
EndProcedure


Procedure IndividualMutex_IsAvaialable(*ptrMutex.integer)
  Protected iWaitResult 
  If *ptrMutex
    If *ptrMutex\i
      ProcedureReturn #True  
    EndIf
  EndIf  
  ProcedureReturn #False
EndProcedure

Procedure IndividualMutex_TryLock(*ptrMutex.integer)
  Protected iWaitResult 
  If *ptrMutex
    If *ptrMutex\i
      iWaitResult = WaitForSingleObject_(*ptrMutex\i, 16)     
      If iWaitResult = #WAIT_OBJECT_0
        ProcedureReturn #True
      EndIf      
    EndIf
  EndIf  
  ProcedureReturn #False
EndProcedure


Procedure IndividualMutex_UnLock(*ptrMutex.integer)
  If *ptrMutex
    If *ptrMutex\i
      ReleaseMutex_(*ptrMutex\i)
    EndIf
  EndIf
EndProcedure

Procedure IndividualMutex_Recreate(*ptrMutex.integer)
  If *ptrMutex
    If *ptrMutex\i
      If g_VirtualFile\Hooks\OrgCloseHandle
        g_VirtualFile\Hooks\OrgCloseHandle(*ptrMutex\i)
      EndIf
      *ptrMutex\i = #Null
    EndIf
    *ptrMutex\i = CreateMutex_(#Null, #False, #Null)
  EndIf
EndProcedure

Procedure IndividualMutex_Free(*ptrMutex.integer)
  Protected hMutex = #Null
  If *ptrMutex
    hMutex = *ptrMutex\i 
    __HookLogDebug("Releasing Mutex")
    *ptrMutex\i = #Null
    If g_VirtualFile\Hooks\OrgCloseHandle
      g_VirtualFile\Hooks\OrgCloseHandle(hMutex)
    EndIf
  EndIf 
EndProcedure


Macro INIT_VIRTUAL_INDIVIDUALMUTEX
Protected startIndividual, bTryOkIndividual, __iLastErrorCodeIndividual.i
EndMacro


Macro LOCK_VIRTUAL_INDIVIDUALMUTEX(ptrMutex) 
  If IndividualMutex_IsAvaialable(ptrMutex)
    startIndividual = GetTickCount_()
    !PAUSE
    Repeat
      !PAUSE
      bTryOkIndividual = IndividualMutex_TryLock(ptrMutex)
    Until bTryOkIndividual Or GetTickCount_() - startIndividual > 2500
    
    If bTryOkIndividual = #False
      __HookLogError("individual Critical section is already in use... continue without thread safety")
      IndividualMutex_Recreate(ptrMutex)
      bTryOkIndividual = IndividualMutex_TryLock(ptrMutex)
      ;Continue without thead safety
    EndIf
    ;g_VirtualFile\iRunningCalls + 1
  Else
    __HookLogError("WARN: no individual mutex available")
  EndIf

EndMacro


Macro UNLOCK_VIRTUAL_INDIVIDUALMUTEX(ptrMutex) 
  __iLastErrorCodeIndividual = GetLastError_()
  If IndividualMutex_IsAvaialable(ptrMutex)
    If bTryOkIndividual 
      IndividualMutex_UnLock(ptrMutex) ; Nur, wenn lock erfogreich war!
    EndIf
    ;g_VirtualFile\iRunningCalls - 1
  Else
    __HookLogError("WARN: no individual mutex available")
  EndIf  
  SetLastError_(__iLastErrorCodeIndividual)
EndMacro



;TESTCODE:
; Global mutex = IndividualMutex_Create()
; 
; Procedure TEST(dummy)
;   Delay(Random(1000))
;   INIT_VIRTUAL_INDIVIDUALMUTEX  
;   LOCK_VIRTUAL_INDIVIDUALMUTEX(@mutex)
;   Debug "OPEN"
;   Delay(Random(100))
;   Debug "CLOSE"
;   UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@mutex)
; EndProcedure  
; 
; 
; For X=0 To 1000
;   CreateThread(@TEST(),0)
; Next  
; 
; Delay(10000)

;==============================================================









Procedure __GetModuleIATLastByte(*Module.IMAGE_DOS_HEADER)
Protected *Img_NT_Headers.IMAGE_NT_HEADERS
  If *Module
    *Img_NT_Headers = *Module + *Module\e_lfanew
    If *Img_NT_Headers
      If *Img_Nt_Headers\OptionalHeader
        If *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IAT]
          ProcedureReturn  *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IAT]\Size + *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IAT]\VirtualAddress
        EndIf
      EndIf
    EndIf
  EndIf
ProcedureReturn #Null
EndProcedure

Procedure.i __HOOKAPI_SetMemoryProtection(*Addr, iProtection)
  Protected mbi.MEMORY_BASIC_INFORMATION, iOldProtection.i
  If VirtualQuery_(*addr, mbi.MEMORY_BASIC_INFORMATION,SizeOf(MEMORY_BASIC_INFORMATION))
    If VirtualProtect_(mbi\BaseAddress, mbi\RegionSize, iProtection, @iOldProtection)
      ProcedureReturn iOldProtection
    EndIf
  EndIf
  ProcedureReturn -1
EndProcedure

Procedure.i __HOOKAPI_GetImportTable(*Module.IMAGE_DOS_HEADER)
  Protected ImageDirectoryEntryToData._ImageDirectoryEntryToData
  Protected *Imagehlp
  Protected iErrMode.i
  
  Protected *ptr.LONG,*pEntryImports.IMAGE_IMPORT_DESCRIPTOR
  Protected *Img_NT_Headers.IMAGE_NT_HEADERS
  
  If *Module
  
;     ;iErrMode = SetErrorMode_(#SEM_FAILCRITICALERRORS) ; Don't display error messages
;     *Imagehlp = GetModuleHandle_("imagehlp.dll")
;     
;     ;First try To use imagehlp API (2000/XP/Vista)
;     If *Imagehlp
;       ImageDirectoryEntryToData = GetProcAddress_(*Imagehlp,"ImageDirectoryEntryToData")
;       If ImageDirectoryEntryToData
;         *pEntryImports = ImageDirectoryEntryToData(*Module, #True, #IMAGE_DIRECTORY_ENTRY_IMPORT, @lSize)    
;         If *pEntryImports
;           ProcedureReturn *pEntryImports
;         EndIf
;       EndIf   
;     EndIf
    
    ;If imagehlp api is not available
    *Img_NT_Headers = *Module + *Module\e_lfanew
    If *Img_NT_Headers
      *ptr = *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_IMPORT]
      If *ptr
        *pEntryImports = *Module + *ptr\l
        ProcedureReturn *pEntryImports
      EndIf
    EndIf
  
  EndIf
  ProcedureReturn #Null
EndProcedure

Procedure.i __HOOKAPI_GetExportTable(*Module.IMAGE_DOS_HEADER)
  Protected ImageDirectoryEntryToData._ImageDirectoryEntryToData
  Protected *Imagehlp
  Protected iErrMode.i
  
  Protected *ptr.LONG,*pEntryExports.IMAGE_EXPORT_DIRECTORY
  Protected *Img_NT_Headers.IMAGE_NT_HEADERS
  
  If *Module
  
;     ;iErrMode = SetErrorMode_(#SEM_FAILCRITICALERRORS) ; Don't display error messages
;     *Imagehlp = GetModuleHandle_("imagehlp.dll")
;     ;SetErrorMode_(iErrMode)
;     
;     ; First try to use imagehlp API (2000/XP/Vista)
;      If *Imagehlp
;        ImageDirectoryEntryToData = GetProcAddress_(*Imagehlp,"ImageDirectoryEntryToData")
;        If ImageDirectoryEntryToData
;          *pEntryExports = ImageDirectoryEntryToData(*Module, #True, #IMAGE_DIRECTORY_ENTRY_EXPORT, @lSize)    
;          If *pEntryExports
;            ProcedureReturn *pEntryExports
;          EndIf
;        EndIf   
;      EndIf
    
    ;If imagehlp api is not available
    *Img_NT_Headers = *Module + *Module\e_lfanew
    If *Img_NT_Headers
      *ptr = *Img_Nt_Headers\OptionalHeader\DataDirectory[#IMAGE_DIRECTORY_ENTRY_EXPORT]
      If *ptr
        *pEntryExports = *Module + *ptr\l
        ProcedureReturn *pEntryExports
      EndIf
    EndIf
  
  EndIf
  ProcedureReturn #Null
EndProcedure


Procedure.s __GetRealModuleName(sModule.s)
  CompilerIf #USE_NOT_RECOMMENDED_WIN8_VIRTUAL_FILE_FIX
    ProcedureReturn sModule ; Just always return the file name 
  CompilerElse
    If OSVersion() >= #PB_OS_Windows_8 ; Für WINDOWS 8
      Protected modulehandle, result.s = sModule
      ; Echten Modulnamen ermittelt notwendig, weil in den Importtabellen der DLLs steht api-ms...
      ; Da wir aber KernelBase.dll anstelle von Kernel32.dll hooken und GetModuleHandle("api-ms...") das gleiche wie für KernelBase.dll zurückgibt,
      ; müssen wir sicherstellen, das die Funktionen auch gehookt werden (ohne __GetRealModuleName() würde es nicht gehookt werden, das api-ms...dll <> KernelBase.dll!)
      modulehandle = GetModuleHandle_(sModule)
      If modulehandle <> #Null;If it fails return at least sModule
        result.s = Space(2048 + 1)
        If GetModuleFileName_(modulehandle, @result, 2048) = 0
          result = sModule ; 0 bedeuted fehler
        EndIf  
      EndIf
      ProcedureReturn result
      
    Else
      ProcedureReturn sModule ; FÜR < WIN 8 einfach den Modulnamen zurückgeben
    EndIf

  CompilerEndIf  
EndProcedure 

Procedure.i __HOOKAPI_ReplaceImportedFunctionInModule(hModule.i,sModuleName.s, sFunction.s, *NewFunctionPtr, *OldFunction)
Protected  *ImportedDLLs.IMAGE_IMPORT_DESCRIPTOR, LastByte.i
Protected sName.s, addr1.i, *itd.IMAGE_THUNK_DATA, iOldProtection.i

If *OldFunction

  *ImportedDLLs.IMAGE_IMPORT_DESCRIPTOR = __HOOKAPI_GetImportTable(hModule)
  If *ImportedDLLs
    LastByte.i = __GetModuleIATLastByte(hModule) + hModule
  
  
    While *ImportedDLLs\Name And *ImportedDLLs\FirstThunk
      
      sName.s = ""
      If *ImportedDLLs\Name And *ImportedDLLs\FirstThunk
      
        addr1 = *ImportedDLLs\Name + hModule;RvaToVa(hModule,*ImportedDLLs\Name)
        If *ImportedDLLs\Name And LastByte - (*ImportedDLLs\FirstThunk + hModule) > 0 And hModule
          ;XXXDebug = *ImportedDLLs\Name
          ;sName.s = UCase(PeekS(hModule + *ImportedDLLs\Name))
          sName.s = UCase(PeekS(addr1,-1, #PB_Ascii))   ; 2010-08-31
        EndIf
        
      EndIf
      ;__HookLogDebug( sName
      
      If UCase(__GetRealModuleName(sName)) = UCase(__GetRealModuleName(sModuleName))
        *itd.IMAGE_THUNK_DATA = *ImportedDLLs\FirstThunk + hModule
        If *ImportedDLLs\FirstThunk
          
        ;*itd.IMAGE_THUNK_DATA = RvaToVa(hModule,*ImportedDLLs\FirstThunk)
        ;If *itd 
                
        While *itd\Function
          If *itd\Function = *OldFunction
            iOldProtection.i = __HOOKAPI_SetMemoryProtection(*itd, #PAGE_EXECUTE_READWRITE)

            If iOldProtection <> -1
              *itd\Function = *NewFunctionPtr ; Set new Function pointer
              __MyDebug("replace pointer for " + sFunction)
              __HOOKAPI_SetMemoryProtection(*itd, iOldProtection)
            Else
              __MyError("ERROR: cannot set memory protection")
            EndIf
            
          EndIf
          *itd + SizeOf(IMAGE_THUNK_DATA)
        Wend
        EndIf
        
      EndIf
      
      *ImportedDLLs + SizeOf(IMAGE_IMPORT_DESCRIPTOR)
    Wend
  
  Else
    __MyError("ERROR: cannot get import table")
  EndIf

Else

EndIf

EndProcedure

Procedure.i __HOOKAPI_ReplaceExportedFunctionInModule(sModuleName.s, sFunction.s, *NewFunctionPtr, *OldFunction)
Protected hModule.i, *ExportedFunctions.IMAGE_EXPORT_DIRECTORY
Protected *Addr.Integer, i.i, iOldProtection.i

hModule.i = GetModuleHandle_(sModuleName.s)

If *OldFunction And *NewFunctionPtr And hModule


  *ExportedFunctions.IMAGE_EXPORT_DIRECTORY = __HOOKAPI_GetExportTable(hModule)
  If *ExportedFunctions
  
    *Addr.Integer = *ExportedFunctions\AddressOfFunctions + hModule
    
    If *Addr
      For i = 0 To *ExportedFunctions\NumberOfFunctions - 1
   
        If *Addr\i + hModule = *OldFunction

          iOldProtection.i = __HOOKAPI_SetMemoryProtection(*Addr, #PAGE_EXECUTE_READWRITE)
          If iOldProtection <> -1
            ;k= *Addr\i
            ;MessageBox_(0,Str(*Addr),Str(IsBadWritePtr_(*addr,4)),#MB_OK)
            
            *Addr\i = *NewFunctionPtr - hModule
            ;new = k;*NewFunctionPtr - hModule
            ;WriteProcessMemory_(GetCurrentProcess_(),*Addr,@new,4,#Null)
            
            __HOOKAPI_SetMemoryProtection(*Addr, iOldProtection)
          EndIf
        EndIf
        *Addr + SizeOf(Integer)
      Next
    EndIf
      
  EndIf
EndIf

EndProcedure


Procedure.s __GetModuleFullPath(sModule.s)
  Protected hModule.i,sName.s
  hModule = GetModuleHandle_(sModule)
  If hModule
    sName.s =Space(#MAX_PATH+1)
    GetModuleFileName_(hModule, @sName, #MAX_PATH)
    If Trim(sName) <> ""
      sModule = sName  
    EndIf
  EndIf
  ProcedureReturn sModule
EndProcedure

Procedure.i __IsModuleInBlackList(sModule.s)
  sModule = Trim(sModule)
  sModule = UCase(sModule)
  sModule = "["+GetFilePart(sModule)+"]"
  ProcedureReturn FindString(UCase(g_VirtualFile\sModuleBlackList), sModule, 1)
  
  ;If sModule = "[QUARTZ.DLL]" Or sModule = "[QASF.DLL]" Or sModule ="[DXMASF.DLL]"
  ;  ProcedureReturn #False   
  ;Else
  ;  ProcedureReturn #True
  ;EndIf
EndProcedure


  

Procedure.i __HOOKAPI_ReplaceImportedFunctionInAllModules(sModuleName.s, sFunction.s, *NewFunctionPtr, *OldFunction)
  Protected iResult.i, snapshot.i, modulehandle.MODULEENTRY32
  
  iResult.i = #False
  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPMODULE, 0) 
  If snapshot 
  
      modulehandle.MODULEENTRY32
      modulehandle\dwSize = SizeOf(MODULEENTRY32) 
      
      If Module32First_(snapshot, @modulehandle)
        While Module32Next_(snapshot, @modulehandle)         
          If modulehandle\hModule
            
            If Not __IsModuleInBlackList(PeekS(@modulehandle\szModule))  ; 2010-08-30 ; 2010-09-13 Unicode Bugfix  
              If g_VirtualFile\bFirstFunctionModuleOutput
                __MyDebug("Hooking import table of " + __GetModuleFullPath(PeekS(@modulehandle\szModule)))  ; 2010-08-30  ; 2010-09-13 Unicode Bugfix 
              EndIf
              iResult = __HOOKAPI_ReplaceImportedFunctionInModule(modulehandle\hModule, sModuleName, sFunction, *NewFunctionPtr, *OldFunction)             
            Else
                __MyDebug(PeekS(@modulehandle\szModule) + " is in black list, ignoring...")  ; 2010-08-30   ; 2010-09-13 Unicode Bugfix        
            EndIf  
          EndIf
        Wend
      EndIf    
        
      If g_VirtualFile\Hooks\OrgCloseHandle
        g_VirtualFile\Hooks\OrgCloseHandle(snapshot)
      Else
        __MyWarn("Orginal CloseHandle is null, handle cannot be released!")
      EndIf  
      ;CloseHandle_(snapshot)
  EndIf 
   
  iResult = __HOOKAPI_ReplaceImportedFunctionInModule(GetModuleHandle_(0), sModuleName, sFunction, *NewFunctionPtr, *OldFunction)             
  
  g_VirtualFile\bFirstFunctionModuleOutput = #False
   
  ProcedureReturn iResult
EndProcedure


Procedure.i __HookApi(sModule.s, sFunction.s, *NewFunction, bHookExport = #True, bHookImport = #True)
  Protected *OldFunction
  
  If *NewFunction
    __MyDebug("Hooking function " + sModule + " " + sFunction)
    *OldFunction = GetProcAddress_(GetModuleHandle_(sModule), sFunction)
    If bHookImport
      __HOOKAPI_ReplaceImportedFunctionInAllModules(sModule.s, sFunction.s, *NewFunction, *OldFunction)
    EndIf
    If bHookExport
      __HOOKAPI_ReplaceExportedFunctionInModule(sModule.s, sFunction.s, *NewFunction, *OldFunction)
    EndIf  
    ProcedureReturn *OldFunction
  EndIf
EndProcedure


;Procedure.s GetSystemPath()
;  Protected sPath.s
;  sPath.s = Space(#MAX_PATH+1)
;  GetSystemDirectory_(@sPath, #MAX_PATH)
;  ProcedureReturn sPath
;EndProcedure


;Procedure LoadLibraryCopy(sDLL.s)  
;  Protected sNewDll.s, hModule.i
;   If GetPathPart(sDLL.s) = ""
;     sDLL = GetSystemPath() + "\" + sDLL
;   EndIf
;   sNewDll.s =  GetTemporaryDirectory()  + #LOADLIBRARYCOPY_ID + "_Cpy" + GetFilePart(sDLL)
;   If FileSize(sNewDll) <= 0
;     If CopyFile(sDLL, sNewDll)
;       MoveFileEx_(sNewDll, "", #MOVEFILE_DELAY_UNTIL_REBOOT)
;     EndIf
;   EndIf
  
  ;Debug sNewDll
  ;hModule = ImageLoad_("",sNewDll) ; 2010-06-17 muss imageload sein, bei LoadLibrary Endlosschleife
;  hModule = LoadLibrary_(sDLL) 
;  ProcedureReturn hModule
;EndProcedure


;OLD HOOKING CODE...
; Procedure CodeReplace_HookFunction(*addr,*newAddr, bLogging = #True) 
;   Protected *oldBinData, *newBinData, iResult.i, numRead.i, numWrite.i
;   If *addr And *newAddr
;     *oldBinData = GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT, 9)  
;     If *oldBinData
;       *newBinData = GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT, 5)
;       If *newBinData
;         FlushInstructionCache_(GetCurrentProcess_(), *addr , 5)
;         ReadProcessMemory_(GetCurrentProcess_(), *addr, *oldBinData, 5, @numRead)
;         PokeL(*oldBinData + 5, *addr)
; 
;         CopyMemory(?__HookFunction, *newBinData, 5)
;         PokeL(*newBinData + 1, *newAddr - *addr - 5)
;         iResult = WriteProcessMemory_(GetCurrentProcess_(), *addr ,*newBinData, 5, @numWrite)
;         GlobalFree_(*newBinData)
;         FlushInstructionCache_(GetCurrentProcess_(), *addr , 5)
;       EndIf
;     EndIf
;   EndIf
;   
;   If iResult And *oldBinData    
;     If bLogging
;       __HookLogDebug("Hooking ok")
;     EndIf
;     ProcedureReturn *oldBinData
;   Else
;     If bLogging
;       __HookLogError("Hooking failed result is " + Str(iResult) + " lasterrror: "+Str(GetLastError_())) 
;     EndIf
;     ProcedureReturn #Null
;   EndIf      
;         
;   __HookFunction:
;   !JMP 99999999
; EndProcedure
; 
; Procedure CodeReplace_UnHookFunction(*oldBinData, bLogging = #True)
;   Protected iResult.i, *addr, numWrite
;   If *oldBinData
;     *addr = PeekL(*oldBinData + 5)
;     FlushInstructionCache_(GetCurrentProcess_(), *addr , 5)
;     iResult = WriteProcessMemory_(GetCurrentProcess_(), *addr ,*oldBinData, 5, @numWrite)
;     GlobalFree_(*oldBinData)
;     FlushInstructionCache_(GetCurrentProcess_(), *addr , 5)
;     If iResult
;       ProcedureReturn *addr
;     Else
;       If bLogging
;         __HookLogError("unhooking failed")
;       EndIf
;     EndIf
;   EndIf
; EndProcedure
; 
; Procedure CodeReplace_HookApi(sModule.s, sFunctionName.s, *NewFunction, bLogging = #True)
;   If bLogging
;     __HookLogDebug("Hook by replacing code in module" + sModule + " function " + sFunctionName)
;   EndIf
;   ProcedureReturn CodeReplace_HookFunction(GetProcAddress_(GetModuleHandle_(sModule), sFunctionName),*NewFunction, bLogging) 
; EndProcedure






Structure JMPCOMDE
  instr.b
  addr.l
EndStructure


Procedure __FlushCacheForCodePtr(*ptr)
  Protected mbi.MEMORY_BASIC_INFORMATION
  If *ptr
     ; VirtualQuery is very slow...
     ; If VirtualQuery_(*ptr, mbi.MEMORY_BASIC_INFORMATION,SizeOf(MEMORY_BASIC_INFORMATION))
     ;   FlushInstructionCache_(GetCurrentProcess_(), mbi\BaseAddress, mbi\RegionSize)
     ; EndIf
     ; is this correct???
     ;FlushInstructionCache_(GetCurrentProcess_(), *ptr, SizeOf(JMPCOMDE))
     FlushInstructionCache_(GetCurrentProcess_(), #Null, 0) ; better use this here (seems to work also without it)
  EndIf
EndProcedure

Procedure __WriteJMPCode(*ptr, *jmpAddr, *oldBinData, bLogging = #True)
  Protected iResult, numBytes, jmp.JMPCOMDE, bResult = #False
  
  If *ptr
    If *jmpAddr
      If *oldBinData
        jmp\instr = $E9
        jmp\addr = *jmpAddr - *ptr - SizeOf(JMPCOMDE)
        __FlushCacheForCodePtr(*ptr)  
        iResult = ReadProcessMemory_(GetCurrentProcess_(), *ptr, *oldBinData, SizeOf(JMPCOMDE), @numBytes)  
        If numBytes = SizeOf(JMPCOMDE)
      
          numBytes = 0
          iResult = WriteProcessMemory_(GetCurrentProcess_(), *ptr ,@jmp, SizeOf(JMPCOMDE), @numBytes)
          __FlushCacheForCodePtr(*ptr)
          If numBytes = SizeOf(JMPCOMDE)
            bResult = #True  
          Else
            If bLogging
              __HookLogError("WriteProcessMemory failed in __WriteJMPCode")
            EndIf
            
          EndIf
        Else
          
          If bLogging
            __HookLogError("ReadProcessMemory failed in __WriteJMPCode")
          EndIf
        EndIf
        
      Else
        If bLogging
          __HookLogError("oldBinData is null in __WriteJMPCode")
        EndIf
      EndIf
      
    Else
      If bLogging
        __HookLogError("jmpAddr is null in __WriteJMPCode")
      EndIf
    EndIf
  Else
    
    If bLogging
      __HookLogError("ptr is null in __WriteJMPCode")
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure __RestoreOldCode(*ptr, *oldBinData, bLogging = #True)
  Protected iResult, numBytes, bResult = #False  
  If *ptr
    If *oldBinData
      iResult = WriteProcessMemory_(GetCurrentProcess_(), *ptr ,*oldBinData, SizeOf(JMPCOMDE), @numBytes)
      __FlushCacheForCodePtr(*ptr)  
      If numBytes = SizeOf(JMPCOMDE)
        bResult = #True
      Else
        If bLogging
          __HookLogError("WriteProcessMemory failed in __RestoreOldCode")
        EndIf         
      EndIf
      
    Else
      If bLogging
        __HookLogError("oldBinData is null in __RestoreOldCode")
      EndIf
    EndIf
  Else
    If bLogging
      __HookLogError("ptr is null in __RestoreOldCode")
    EndIf  
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure CodeReplace_HookFunction(*addr, *newAddr, *oldBinData, bLogging = #True) 
ProcedureReturn __WriteJMPCode(*addr, *newAddr, *oldBinData, bLogging)
EndProcedure

Procedure CodeReplace_UnHookFunction(*addr, *oldBinData, bLogging = #True)
ProcedureReturn __RestoreOldCode(*addr, *oldBinData, bLogging)
EndProcedure

Procedure CodeReplace_HookApi(sModule.s, sFunctionName.s, *NewFunction, bLogging = #True)
  Protected *binData
  If bLogging
    __HookLogDebug("Hook by replacing code in module " + sModule + " function " + sFunctionName)
  EndIf
  *binData = AllocateMemory(SizeOf(JMPCOMDE))
  If *binData
    CodeReplace_HookFunction(GetProcAddress_(GetModuleHandle_(sModule), sFunctionName),*NewFunction, *binData, bLogging) 
  Else
    If bLogging
      __HookLogError("Cannot allocate memory in CodeReplace_HookApi!")
    EndIf      
  EndIf
  ProcedureReturn *binData
EndProcedure







; Procedure.i __Thread_LoadFileAsync(iID.i)
; LockMutex(g_VirtualFile\hLoadLockMutex)
; 
; If VirtualFiles(iID)\BufferPtra
;   Repeat
;     LockMutex(VirtualFiles(iID)\hMutex)
;     iRemaining.i = VirtualFiles(iID)\iSize - VirtualFiles(iID)\iLoadedBytes
;     If iRemaining > 0
;       If iRemaining > 1024 * 1024 :iRemaining = 1024 * 1024:EndIf
;       ReadData(VirtualFiles(iID)\iOrginalFile, VirtualFiles(iID)\BufferPtr + VirtualFiles(iID)\iLoadedBytes, iRemaining)
;       VirtualFiles(iID)\iLoadedBytes + iRemaining
;     Else
;       bDone = #True
;     EndIf
;     UnlockMutex(VirtualFiles(iID)\hMutex)
;     Delay(1)
;   Until bDone Or g_VirtualFile\bActive = #False
; EndIf
; CloseFile(VirtualFiles(iID)\iOrginalFile)
; VirtualFiles(iID)\iOrginalFile = 0
; UnlockMutex(g_VirtualFile\hLoadLockMutex)
; 
; EndProcedure

Procedure.i __GetVirtualFileHandleIDFromKernelHandle(handle.i)
  Protected iResult.i, iInSize.i, iOutSize.i
  Protected handleIdx.i, *handlePtr.integer
  iResult = -1
  If g_VirtualFile\bActive
    If handle <> #INVALID_HANDLE_VALUE
      If g_VirtualFile\Hooks\OrgGetFileType
        ;Debug "a1" + Str(g_VirtualFile\Hooks\OrgGetFileType(handle))
        If g_VirtualFile\Hooks\OrgGetFileType(handle) = #FILE_TYPE_PIPE
          ; iInSize = g_VirtualFile\Hooks\OrgGetFileSize(handle, #Null)
         ;  Debug "hon:"+Str(handle)
         ;  Debug "size is "+Str(iInSize)
          ; If iInSize
          If GetNamedPipeInfo_(handle, #Null, @iInSize, @iOutSize, #Null)
            If iInSize > 0 And (iInSize - 1) < g_VirtualFile\iMaxVirtualFileHandles
              
              If VirtualFileHandles(iInSize - 1)\bUsed
                
                ; 2010-07-03 old code
                ;If VirtualFileHandles(iInSize - 1)\hPipeHandle = handle  ; Is it really our handle?           
                ;  iResult = iInSize -1
                ;EndIf
                
;                 ForEach VirtualFileHandles(iInSize- 1)\handles()       ; Process all the elements...
;                  If VirtualFileHandles(iInSize- 1)\handles() = handle  ; Is it really our handle?           
;                    iResult = iInSize -1
;                    Break
;                   EndIf
;                 Next

                For handleIdx = 0 To VirtualFileHandles(iInSize- 1)\handles\size - 1
                  *handlePtr = VirtualFileHandles(iInSize- 1)\handles\entries + handleIdx *SizeOf(Integer)
                  If *handlePtr\i = handle  ; Is it really our handle?           
                   iResult = iInSize -1
                   Break
                  EndIf
                Next

              
              EndIf
            
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn iResult
EndProcedure

Procedure.i __CreatePipeHandle(iID.i)
  Protected iInSize.i, iOutSize.i, handle.i, *strPtr, *strPtrNumber
  If iID >= 0
    iInSize.i = iID + 1
    iOutSize.i = iInSize
    
    ; 2010-09-12 Stringhandling umgestellt
    *strPtr = Str_Alloc(@"\\.\pipe\MMEncMemVirtFile_") 
    *strPtrNumber = Str_Str(iID)
    If *strPtr And *strPtrNumber
      *strPtr = Str_Combine(*strPtr, *strPtrNumber)
    EndIf  
    ;handle = CreateNamedPipe_("\\.\pipe\MMEncMemVirtFile_" + Str(iID), #PIPE_ACCESS_DUPLEX, #PIPE_TYPE_BYTE|#PIPE_READMODE_BYTE|#PIPE_NOWAIT, 1, iInSize, iOutSize, #NMPWAIT_USE_DEFAULT_WAIT, #Null) 
    
    If *strPtr
      handle = CreateNamedPipe_(*strPtr, #PIPE_ACCESS_DUPLEX, #PIPE_TYPE_BYTE|#PIPE_READMODE_BYTE|#PIPE_NOWAIT, 1, iInSize, iOutSize, #NMPWAIT_USE_DEFAULT_WAIT, #Null) 
    EndIf
    Str_Free(*strPtr)
    Str_Free(*strPtrNumber)
    
  Else
    handle = #INVALID_HANDLE_VALUE
  EndIf
  ProcedureReturn handle
EndProcedure

; 
; Procedure.i __CreateKernelHandle(iID.i)
;   hPipeFileHandle = CreateFile_("\\.\pipe\VirtualFile_" + Str(iID), #GENERIC_READ,#FILE_SHARE_READ,0,#CREATE_ALWAYS,0,0)
;   ProcedureReturn hPipeFileHandle
; EndProcedure



; Procedure.s __AdoptPath(sFilename.s) ; 2010-09-12 Stringhandling umgestellt
;   Protected sFullPath.s, sTmp.s, sCoumputerName.s
;   Protected iComputerNameSize
;   ; Real IP missing
;     
;   sFullPath.s = Space(32768) 
;   GetFullPathName_(@sFilename, 32767, @sFullPath, 0)
;     
;   sFilename.s = UCase(sFullPath)
;    
;   If Left(sFilename, Len("\\.\")) = "\\.\"
;     sFilename = Right(sFilename, Len(sFilename) - Len("\\.\"))
;   EndIf
;   If Left(sFilename, Len("\\?\")) = "\\?\"
;     sFilename = Right(sFilename, Len(sFilename) - Len("\\?\"))
;   EndIf
;   
;   sTmp.s = sFilename
;   
;   sCoumputerName.s = Space(#MAX_PATH+1)
;   iComputerNameSize = #MAX_PATH
;   GetComputerName_(@sCoumputerName,@iComputerNameSize)
;   sCoumputerName = "\\"+Trim(UCase(sCoumputerName))+ "\"
;   
;   If Left(sTmp, Len(sCoumputerName)) = sCoumputerName
;     sTmp = Right(sTmp, Len(sTmp) - Len(sCoumputerName))    
;   EndIf
;   
;   If Left(sTmp, Len("\\127.0.0.1\")) = "\\127.0.0.1\"
;     sTmp = Right(sTmp, Len(sTmp) - Len("\\127.0.0.1\"))
;   EndIf  
;   
;   If Left(sTmp, Len("\\LOCALHOST\")) = "\\LOCALHOST\"
;     sTmp = Right(sTmp, Len(sTmp) - Len("\\LOCALHOST\"))
;   EndIf    
;   
;   If Mid(sTmp, 2, 2) = "$\"
;     sFilename = Left(sTmp, 1) + ":\" + Right(sTmp, Len(sTmp) - 3)
;   EndIf  
;   
;   ProcedureReturn sFilename 
; EndProcedure



Procedure __AdoptPath(*ptrFilename) ; 2010-09-12 Stringhandling umgestellt
  Protected sFullPath, sTmp, sCoumputerName, sTmpLeft, sTmpRight, sFilename
  Protected iComputerNameSize
  ; Real IP missing
  
  STRING_INIT
  
  STRING_NEW(sFilename, *ptrFilename) ; sFilename,sFilename würde hier nicht funktionieren
  
  ;sFullPath.s = Space(32768) 
  STRING_ALLOCSIZE(sFullPath, 32768)
  GetFullPathName_(sFilename, 32767, sFullPath, 0)
  
  ;sFilename.s = UCase(sFullPath)
  STRING_UCASE(sFilename, sFullPath)
      ;Debug PeekS(sFilename)
   
  ;If Left(sFilename, Len("\\.\")) = "\\.\"
  ;  sFilename = Right(sFilename, Len(sFilename) - Len("\\.\"))
  ;EndIf
;   If Left(sFilename, Len("\\?\")) = "\\?\"
;     sFilename = Right(sFilename, Len(sFilename) - Len("\\?\"))
;   EndIf
  
  STRING_LEFT(sTmpLeft, sFilename, Str_Len(@"\\.\"))
  
  If Str_Compare(sTmpLeft, @"\\.\") Or Str_Compare(sTmpLeft, @"\\?\") 
    STRING_RIGHT(sFilename, sFilename, Str_Len(sFilename) - Str_Len(@"\\?\"))
  EndIf

  ;sTmp.s = sFilename
  
  STRING_NEW(sTmp, sFilename)
  
  ;sCoumputerName.s = Space(#MAX_PATH+1)
  
  STRING_SPACE(sCoumputerName, #MAX_PATH+1)
  iComputerNameSize = #MAX_PATH
  
  GetComputerName_(sCoumputerName,@iComputerNameSize)
  
  ;sCoumputerName = "\\"+Trim(UCase(sCoumputerName))+ "\"
  
  STRING_UCASE(sCoumputerName,sCoumputerName)
  STRING_COMBINE(sCoumputerName, @"\\", sCoumputerName)
  STRING_COMBINE(sCoumputerName, sCoumputerName, @"\") 
  
  ;If Left(sTmp, Len(sCoumputerName)) = sCoumputerName
  ;  sTmp = Right(sTmp, Len(sTmp) - Len(sCoumputerName))    
  ;EndIf
  
  STRING_LEFT(sTmpLeft, sTmp, Str_Len(sCoumputerName))
  If Str_Compare(sTmpLeft, sCoumputerName)
    STRING_RIGHT(sTmp, sTmp, Str_Len(sTmp) - Str_Len(sCoumputerName))
  EndIf
  
  ;If Left(sTmp, Len("\\127.0.0.1\")) = "\\127.0.0.1\"
  ;  sTmp = Right(sTmp, Len(sTmp) - Len("\\127.0.0.1\"))
  ;EndIf    
  
  STRING_LEFT(sTmpLeft, sTmp, Str_Len(@"\\127.0.0.1\"))
  If Str_Compare(sTmpLeft, @"\\127.0.0.1\")
    STRING_RIGHT(sTmp, sTmp, Str_Len(sTmp) - Str_Len(@"\\127.0.0.1\"))
  EndIf
  
  ;If Left(sTmp, Len("\\LOCALHOST\")) = "\\LOCALHOST\"
  ;  sTmp = Right(sTmp, Len(sTmp) - Len("\\LOCALHOST\"))
  ;EndIf  
  
  STRING_LEFT(sTmpLeft, sTmp, Str_Len(@"\\LOCALHOST\"))
  If Str_Compare(sTmpLeft, @"\\LOCALHOST\")
    STRING_RIGHT(sTmp, sTmp, Str_Len(sTmp) - Str_Len(@"\\LOCALHOST\"))
  EndIf
    
  ;If Mid(sTmp, 2, 2) = "$\"
  ;  sFilename = Left(sTmp, 1) + ":\" + Right(sTmp, Len(sTmp) - 3)
  ;EndIf
  

  STRING_MID(sTmpLeft, sTmp, 2,2)
  If Str_Compare(sTmpLeft,@"$\")
    STRING_LEFT(sFilename, sTmp, 1)
    STRING_COMBINE(sFilename, sFilename, @":\")
    STRING_RIGHT(sTmpRight, sTmp, Str_Len(sTmp) - 3)
    STRING_COMBINE(sFilename, sFilename, sTmpRight)   
  EndIf
  
  
  STRING_FREE(sTmpLeft)
  STRING_FREE(sTmpRight)
  STRING_FREE(sTmp)
  STRING_FREE(sCoumputerName)
  STRING_FREE(sFullPath)  
   
  ProcedureReturn sFilename 
EndProcedure



; Procedure __AdoptPath(*filename) ; 2010-09-12 Stringhandling umgestellt
;   Protected *ptrNewfilename, *PtrTmp, *PtrTmpNew, *PtrTmpLeft, *PtrTmpRight, *CoumputerName, *CoumputerNameNew , *ptrFullPath
;   Protected iComputerNameSize
;   ; Real IP missing
;     
;   *ptrFullPath = Str_Space(32768);Space(32768) 
;   
;   GetFullPathName_(*filename, 32767, *ptrFullPath, 0)
;     
;   Str_UCase(*ptrFullPath)
;   
;   *PtrTmp = Str_Left(*filename, Str_Len(@"\\.\"))
;   
;   If Str_Compare(*PtrTmp, @"\\.\") Or Str_Compare(*PtrTmp, @"\\?\")
;     *ptrNewfilename = Str_Right(*filename, Str_Len(*filename) - Str_Len(@"\\.\"))
;     Str_FreeAndNull(*filename)
;     *filename = *ptrNewfilename 
;   EndIf  
;   
;   Str_FreeAndNull(*PtrTmp)
;   
; ;  sTmp.s = sFilename  
;   *PtrTmp = Str_Alloc(*filename)
; 
; ;  sCoumputerName.s = Space(#MAX_PATH+1)  
;   *CoumputerName = Str_Space(#MAX_PATH +1)
;   iComputerNameSize = #MAX_PATH
;   
;   GetComputerName_(*CoumputerName,@iComputerNameSize)
;   
;   *CoumputerName = Str_Combine(*CoumputerName, @"\")
;   
;   *CoumputerNameNew = Str_CombineNew(@"\\", *CoumputerName)
;   
;   Str_FreeAndNull(*CoumputerName)
;   *CoumputerName = *CoumputerNameNew
;   
;   ;sCoumputerName = "\\"+Trim(UCase(sCoumputerName))+ "\"
;   
;   
;   ;If Left(sTmp, Len(sCoumputerName)) = sCoumputerName
;   ;  sTmp = Right(sTmp, Len(sTmp) - Len(sCoumputerName))    
;   ;EndIf
;   *PtrTmpLeft = Str_Left(*PtrTmp, Str_Len(*CoumputerName))
;   If Str_Compare(*PtrTmp, *PtrTmpLeft)  
;     *PtrTmpNew = Str_Right(*PtrTmp, Str_Len(*PtrTmp) - Str_Len(*CoumputerName))
;     Str_FreeAndNull(*PtrTmp)
;     *PtrTmp = *PtrTmpNew
;   EndIf  
;   Str_FreeAndNull(*PtrTmpLeft)
;   
;   
;   ;If Left(sTmp, Len("\\127.0.0.1\")) = "\\127.0.0.1\"
;   ;  sTmp = Right(sTmp, Len(sTmp) - Len("\\127.0.0.1\"))
;   ;EndIf    
;   
;   *PtrTmpLeft = Str_Left(*PtrTmp, Str_Len(@"\\127.0.0.1\"))
;   If Str_Compare(*PtrTmp,  @"\\127.0.0.1\")  
;     *PtrTmpNew = Str_Right(*PtrTmp, Str_Len(*PtrTmp) - Str_Len(@"\\127.0.0.1\"))
;     Str_FreeAndNull(*PtrTmp)
;     *PtrTmp = *PtrTmpNew
;   EndIf  
;   Str_FreeAndNull(*PtrTmpLeft)  
;   
;  
;   ;If Left(sTmp, Len("\\LOCALHOST\")) = "\\LOCALHOST\"
;   ;  sTmp = Right(sTmp, Len(sTmp) - Len("\\LOCALHOST\"))
;   ;EndIf 
;   
;   *PtrTmpLeft = Str_Left(*PtrTmp, Str_Len(@"\\LOCALHOST\"))
;   If Str_Compare(*PtrTmp,  @"\\LOCALHOST\")  
;     *PtrTmpNew = Str_Right(*PtrTmp, Str_Len(*PtrTmp) - Str_Len(@"\\LOCALHOST\"))
;     Str_FreeAndNull(*PtrTmp)
;     *PtrTmp = *PtrTmpNew
;   EndIf  
;   Str_FreeAndNull(*PtrTmpLeft)  
;   
;   
;   ;If Mid(sTmp, 2, 2) = "$\"
;   ;  sFilename = Left(sTmp, 1) + ":\" + Right(sTmp, Len(sTmp) - 3)
;   ;EndIf  
;   
;   *PtrTmpLeft = Str_Mid(*PtrTmp, 2,2)
;    
;   If Str_Compare(*PtrTmpLeft, @"$\")
;     Str_FreeAndNull(*filename)
;     *filename = Str_Left(*PtrTmp, 1)
;     *filename = Str_Combine(*filename, @":\")
;     *PtrTmpRight = Str_Right(*PtrTmp, Str_Len(*PtrTmp) - 3)
;     *filename = Str_Combine(*filename, *PtrTmpRight) 
;     Str_FreeAndNull(*PtrTmpRight)
;   EndIf
;   
;   Str_FreeAndNull(*ptrNewfilename)
;   Str_FreeAndNull(*PtrTmp)
;   Str_FreeAndNull(*PtrTmpNew)
;   Str_FreeAndNull(*PtrTmpLeft)
;   Str_FreeAndNull(*PtrTmpRight)
;   Str_FreeAndNull(*CoumputerName)
;   Str_FreeAndNull(*CoumputerNameNew)
;   Str_FreeAndNull(*ptrFullPath)
;   
;   ProcedureReturn *filename 
; EndProcedure


Procedure.i __GetVirtualFileIndexForFile(*ptrFile)  ; 2010-09-12 Stringhandling umgestellt
  Protected iResult.i, iIndex.i, bFound.i
  Protected sFile, sVirtualFile
  Protected *ptrAdoptVirtualFile, *ptrAdopFile
  iResult.i = -1
  
  STRING_INIT
  
  STRING_NEW(sFile, *ptrFile)
  STRING_UCASE(sFile, sFile)
  
  If g_VirtualFile\bActive
    For iIndex = 0 To g_VirtualFile\iMaxVirtualFiles - 1
      If VirtualFiles(iIndex)\bUsed
        If VirtualFiles(iIndex)\bCanCreateNewHandles
          
          bFound = #False
          
          
          STRING_NEW(sVirtualFile, @VirtualFiles(iIndex)\sFileName)
          STRING_UCASE(sVirtualFile, sVirtualFile)
          
          ;If UCase(VirtualFiles(iIndex)\sFileName) = UCase(sFile) ; 2010-07-01
          ;  bFound = #True
          ;EndIf
          
          If Str_Compare(sVirtualFile, sFile)
            bFound = #True
          EndIf
          
          
          ;2010-07-27 use function instead        
          If bFound = #False
            
            *ptrAdoptVirtualFile = __AdoptPath(sVirtualFile)
            *ptrAdopFile = __AdoptPath(sFile)
            
            
            ;If __AdoptPath(VirtualFiles(iIndex)\sFileName) = __AdoptPath(sFile)
            ;  bFound = #True 
            ;EndIf    
            If Str_Compare(*ptrAdoptVirtualFile, *ptrAdopFile)
              bFound = #True 
            EndIf 
            Str_Free(*ptrAdoptVirtualFile)
            Str_Free(*ptrAdopFile) 
          EndIf
          
          
          ;"\..\" support missing!!!
          ; Real IP missing
;           If GetPathPart(sFile) <> "" And bFound = #False
;             If UCase(GetCurrentDirectory() + VirtualFiles(iIndex)\sFileName) = UCase(sFile) ; 2010-07-01
;               bFound = #True
;             EndIf
;             If bFound = #False
;               If "\\.\" + UCase(GetCurrentDirectory() + VirtualFiles(iIndex)\sFileName) = UCase(sFile) ; 2010-07-01
;                 bFound = #True
;               EndIf
;             EndIf
;             If bFound = #False
;               If "\\?\" + UCase(GetCurrentDirectory() + VirtualFiles(iIndex)\sFileName) = UCase(sFile) ; 2010-07-01
;                 bFound = #True
;               EndIf
;             EndIf    
;             If bFound = #False
;               If "\\LOCALHOST\" + UCase(ReplaceString(GetCurrentDirectory(), ":", "$") + VirtualFiles(iIndex)\sFileName) = UCase(sFile) ; 2010-07-01
;                 bFound = #True
;               EndIf
;             EndIf   
;             If bFound = #False
;               If "\\127.0.0.1\" + UCase(ReplaceString(GetCurrentDirectory(), ":", "$") + VirtualFiles(iIndex)\sFileName) = UCase(sFile) ; 2010-07-01
;                 bFound = #True
;               EndIf
;             EndIf  
;             If bFound = #False
;               sCoumputerName = Space(#MAX_PATH+1)
;               iComputerNameSize = #MAX_PATH
;               GetComputerName_(@sCoumputerName,@iComputerNameSize)
;               If "\\"+ UCase(sCoumputerName) + "\" + UCase(ReplaceString(GetCurrentDirectory(), ":", "$") + VirtualFiles(iIndex)\sFileName) = UCase(sFile) ; 2010-07-01
;                 bFound = #True
;               EndIf
;             EndIf             
;           EndIf      
          
          
          If bFound
            iResult = iIndex
            Break
          EndIf
        EndIf
      EndIf
    Next
  EndIf
  
  STRING_FREE(sFile)
  STRING_FREE(sVirtualFile)
  ProcedureReturn iResult
EndProcedure

Procedure.i __CreateNewVirtualFileHandle(*ptrFile, bOverlapped) ; 2010-09-12 Stringhandling umgestellt  ; Returns the kernel handle!
  Protected iResult.i, iVirtualFile.i, iIndex, handle
  ;__HookLogDebug("CreateNewVirtualFileHandle(" + PeekS(*ptrFile, -1, #PB_Ascii) + "," +Str(bOverlapped) + ")")
  __HookLogDebug("CreateNewVirtualFileHandle(" + PeekS(*ptrFile) + "," +Str(bOverlapped) + ")")
    
  iResult.i = #INVALID_HANDLE_VALUE
  iVirtualFile.i = __GetVirtualFileIndexForFile(*ptrFile)
  If iVirtualFile > -1  
    For iIndex = 0 To g_VirtualFile\iMaxVirtualFileHandles - 1
    
      If VirtualFileHandles(iIndex)\bUsed = #False  
        handle = __CreatePipeHandle(iIndex) ; Create our dummy handle
        If handle <> #INVALID_HANDLE_VALUE
          ;fileHandle = __CreateKernelHandle(iIndex)
          ;If fileHandle <> #INVALID_HANDLE_VALUE
            
            If VirtualFiles(iVirtualFile)\bIsEncrypted And VirtualFiles(iVirtualFile)\bDownloadFromURL = #False ; 2011-03-04
            
              CompilerIf #PB_Compiler_Unicode
                If g_VirtualFile\Hooks\OrgCreateFileW
                  VirtualFileHandles(iIndex)\hDecryptedFileHandle = g_VirtualFile\Hooks\OrgCreateFileW(@VirtualFiles(iVirtualFile)\sExistingFileName, #GENERIC_READ, #FILE_SHARE_READ, #Null, #OPEN_EXISTING, #FILE_ATTRIBUTE_NORMAL, 0)    
                Else
                  SetLastError_(#ERROR_BAD_COMMAND)
                  __HookLogError("CreateFileW function pointer is null!")            
                EndIf
              CompilerElse   
                If g_VirtualFile\Hooks\OrgCreateFileA                
                  VirtualFileHandles(iIndex)\hDecryptedFileHandle = g_VirtualFile\Hooks\OrgCreateFileA(@VirtualFiles(iVirtualFile)\sExistingFileName, #GENERIC_READ, #FILE_SHARE_READ, #Null, #OPEN_EXISTING, #FILE_ATTRIBUTE_NORMAL, 0)        
                Else
                  SetLastError_(#ERROR_BAD_COMMAND)
                  __HookLogError("CreateFileA function pointer is null!")                     
                EndIf  
              CompilerEndIf
            EndIf
            
            If VirtualFileHandles(iIndex)\hDecryptedFileHandle <> #INVALID_HANDLE_VALUE
              VirtualFileHandles(iIndex)\bUsed = #True
              ;VirtualFileHandles(iIndex)\hPipeHandle = handle ; 2010-07-03
              
              ; 2010-07-03 new list
              ;ClearList(VirtualFileHandles(iIndex)\handles())
              MYLIST_Delete(@VirtualFileHandles(iIndex)\handles)
              MYLIST_Add(@VirtualFileHandles(iIndex)\handles, handle)
              ;VirtualFileHandles(iIndex)\handles() = handle
              
              ;VirtualFileHandles(iIndex)\hPipeFileHandle = fileHandle
              VirtualFileHandles(iIndex)\iVirtualFile = iVirtualFile
              VirtualFiles(iVirtualFile)\iUseCount + 1
              VirtualFileHandles(iIndex)\qPosition = 0
              ;VirtualFileHandles(iIndex)\bWriteAccess = bWriteAccess
              VirtualFileHandles(iIndex)\bOverlapped = bOverlapped 
              
              VirtualFileHandles(iIndex)\iUseCound = 1 ; 2010-07-01
              iResult = handle
            Else
              If g_VirtualFile\Hooks\OrgCloseHandle
                g_VirtualFile\Hooks\OrgCloseHandle(handle)
              Else
                SetLastError_(#ERROR_BAD_COMMAND)
                __HookLogError("CloseHandle function pointer is null!")
              EndIf  
            EndIf
            Break
          ;Else
          ;  CloseHandle_(handle)
          ;EndIf
        EndIf
      EndIf
    Next
  EndIf
  ProcedureReturn iResult
EndProcedure

ProcedureDLL __CreateFileA(lpFileName, dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
  Protected hPipeHandle.i, iResult.i, *ptrFileName
  INIT_VIRTUAL_MUTEX    
  
  If lpFileName
    __HookLogDebug("CreateFileA(" + PeekS(lpFileName,-1,  #PB_Ascii) + ",...)")
  Else
    __HookLogDebug("CreateFileA(NULL, ...)")    
  EndIf  

 
  If lpFileName <> #Null   
    LOCK_VIRTUAL_MUTEX ; 2011-03-06    
    *ptrFileName = Str_PeekAnsi(lpFileName)
    
    ;hPipeHandle.i = __CreateNewVirtualFileHandle(PeekS(lpFileName, -1, #PB_Ascii), dwFlagsAndAttributes  & #FILE_FLAG_OVERLAPPED)     
    hPipeHandle.i = __CreateNewVirtualFileHandle(*ptrFileName, dwFlagsAndAttributes  & #FILE_FLAG_OVERLAPPED)     
    Str_Free(*ptrFileName)   
    
    If hPipeHandle <> #INVALID_HANDLE_VALUE    
    __HookLogDebug("virtual handle created " + Hex(hPipeHandle))
      iResult = hPipeHandle
    Else
      If g_VirtualFile\Hooks\OrgCreateFileA
        iResult = g_VirtualFile\Hooks\OrgCreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
      Else
        SetLastError_(#ERROR_BAD_COMMAND)
        __HookLogError("CreateFileA function pointer is null!")            
      EndIf
      __HookLogDebug("create normal file handle " + Hex(iResult))
    EndIf
    UNLOCK_VIRTUAL_MUTEX 
    
  Else
    iResult = #INVALID_HANDLE_VALUE
  EndIf

  ProcedureReturn iResult
EndProcedure

ProcedureDLL __CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
  Protected hPipeHandle.i, iResult.i, *ptrFileName
  INIT_VIRTUAL_MUTEX   
  If lpFileName
    __HookLogDebug("CreateFileW(" + PeekS(lpFileName,-1,  #PB_Unicode) + ",...)")
  Else
    __HookLogDebug("CreateFileW(NULL, ...)")      
  EndIf  

  
  If lpFileName <> #Null
    LOCK_VIRTUAL_MUTEX ; 2011-03-06    
    *ptrFileName = Str_PeekUnicode(lpFileName)  
    ;hPipeHandle.i = __CreateNewVirtualFileHandle(PeekS(lpFileName, -1, #PB_Unicode), dwFlagsAndAttributes  & #FILE_FLAG_OVERLAPPED)      
    
    hPipeHandle.i = __CreateNewVirtualFileHandle(*ptrFileName, dwFlagsAndAttributes  & #FILE_FLAG_OVERLAPPED)      
    Str_Free(*ptrFileName)    
    
    If hPipeHandle <> #INVALID_HANDLE_VALUE    
      __HookLogDebug("virtual handle created " + Hex(hPipeHandle))
      iResult = hPipeHandle
    Else
      If g_VirtualFile\Hooks\OrgCreateFileW
        iResult = g_VirtualFile\Hooks\OrgCreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
      Else
        SetLastError_(#ERROR_BAD_COMMAND)
        __HookLogError("CreateFileW function pointer is null!")            
      EndIf
      __HookLogDebug("create normal file handle " + Hex(iResult))
    EndIf
    UNLOCK_VIRTUAL_MUTEX  
    
  Else
    iResult = #INVALID_HANDLE_VALUE
  EndIf

  ProcedureReturn iResult
EndProcedure


ProcedureDLL __SetFilePointer(hFile,lDistanceToMove,*lpDistanceToMoveHigh.Long,dwMoveMethod)
  Protected VirtualFileHandle.i,VirtualFile.i, qSize.q, qPosition.q, iResult.i = #INVALID_SET_FILE_POINTER, qMove.q, bPosOk = #True
  __HookLogDebug("SetFilePointer("+ Hex(hFile)+ "," + Str(lDistanceToMove) +"," + Hex(*lpDistanceToMoveHigh) +"," + Str(dwMoveMethod) + ")")
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX  
  
 
  If hFile <> #INVALID_HANDLE_VALUE
    
    
     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hFile)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
    ;================ 
        
        
        If *lpDistanceToMoveHigh
          qMove.q = (lDistanceToMove)&$FFFFFFFF + (*lpDistanceToMoveHigh\l & $FFFFFFFF) << 32
        Else
          qMove.q = lDistanceToMove ; Sign must remain!!!   
        EndIf
        
        qSize = VirtualFiles(VirtualFile)\qSize
        qPosition =  VirtualFileHandles(VirtualFileHandle)\qPosition
        If dwMoveMethod = #FILE_BEGIN
          qPosition = qMove
          ;If qPosition < 0:qPosition = -qPosition:EndIf
        EndIf
        If dwMoveMethod = #FILE_CURRENT
          qPosition = qPosition + qMove
        EndIf  
         If dwMoveMethod = #FILE_END
          qPosition = qSize + qMove
          
        EndIf
             
        If *lpDistanceToMoveHigh = #Null
          If (qPosition & $FFFFFFFF) <> qPosition
            bPosOk = #False 
          EndIf
        EndIf
        
  ;2010-05-31
  ;       If qPosition < qSize And qPosition >= 0 And bPosOk
  ;         VirtualFileHandles(VirtualFileHandle)\qPosition = qPosition
  ;         If *lpDistanceToMoveHigh
  ;           *lpDistanceToMoveHigh\l = (qPosition >> 32) & $FFFFFFFF
  ;         EndIf
  ;         SetLastError_(#NO_ERROR)
  ;         iResult = qPosition & $FFFFFFFF  
  ;       Else
  ;         If qPosition < 0
  ;           SetLastError_(#ERROR_NEGATIVE_SEEK)
  ;           __HookLogWarn("SetFilePointer failed for handle " + Hex(hFile) + " with errocode ERROR_NEGATIVE_SEEK")
  ;         EndIf
  ;   
  ;         Else
  ;           SetLastError_(#ERROR_INVALID_PARAMETER)
  ;           __HookLogWarn("SetFilePointer failed for handle " + Hex(hFile) + " with errocode ERROR_INVALID_PARAMETER; position is " + Str(qPosition) + "/" + Str(qSize))
  ;         EndIf         
  ;         iResult = #INVALID_SET_FILE_POINTER
  ;       EndIf
        
        If qPosition >= 0 And bPosOk
          VirtualFileHandles(VirtualFileHandle)\qPosition = qPosition
          If *lpDistanceToMoveHigh
            *lpDistanceToMoveHigh\l = (qPosition >> 32) & $FFFFFFFF
          EndIf
          SetLastError_(#NO_ERROR)
          iResult = qPosition & $FFFFFFFF  
        Else
          
          ;SetFilePointer funktioniert auch für pos > size!
          If qPosition < 0
            SetLastError_(#ERROR_NEGATIVE_SEEK)
            __HookLogWarn("SetFilePointer failed for handle " + Hex(hFile) + " with errocode ERROR_NEGATIVE_SEEK")
            
          Else
            SetLastError_(#ERROR_INVALID_PARAMETER) ; 2010-07-01                
          EndIf
    
          ;Else
          ;  SetLastError_(#ERROR_INVALID_PARAMETER)
          ;  __HookLogWarn("SetFilePointer failed for handle " + Hex(hFile) + " with errocode ERROR_INVALID_PARAMETER; position is " + Str(qPosition) + "/" + Str(qSize))
          ;EndIf         
          iResult = #INVALID_SET_FILE_POINTER
        EndIf
        
        
      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================
      
      
      
    Else 
      If g_VirtualFile\Hooks\OrgSetFilePointer
        iResult = g_VirtualFile\Hooks\OrgSetFilePointer(hFile,lDistanceToMove,*lpDistanceToMoveHigh,dwMoveMethod)
      Else
        SetLastError_(#ERROR_BAD_COMMAND)
        __HookLogError("SetFilePointer function pointer is null!")        
      EndIf  
      UNLOCK_VIRTUAL_MUTEX
      
    EndIf
  Else 
    SetLastError_(#ERROR_INVALID_PARAMETER)
    iResult = #INVALID_SET_FILE_POINTER
    __HookLogError("SetFilePointer failed with invalid handle")
  EndIf

  ProcedureReturn iResult
EndProcedure


ProcedureDLL __SetFilePointerEx(hFile,qDistanceToMove.q,*lpNewFilePointer,dwMoveMethod)
  Protected VirtualFileHandle.i,VirtualFile.i, qSize.q, qPosition.q, iResult.i = #False
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX    
  
  __HookLogDebug("SetFilePointerEx("+ Hex(hFile)+ "," + Str(qDistanceToMove) +"," + Hex(*lpNewFilePointer) +"," +Str(dwMoveMethod) + ")")
  
  
  If hFile <> #INVALID_HANDLE_VALUE
    
    
     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hFile)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
    ;================ 
       
        
        qSize = VirtualFiles(VirtualFile)\qSize
        qPosition = VirtualFileHandles(VirtualFileHandle)\qPosition  
      
        If dwMoveMethod = #FILE_BEGIN
          qPosition = qDistanceToMove
          ;If qPosition < 0:qPosition = -qPosition:EndIf
        EndIf
        If dwMoveMethod = #FILE_CURRENT
          qPosition = qPosition + qDistanceToMove
        EndIf  
         If dwMoveMethod = #FILE_END
          qPosition = qSize + qDistanceToMove        
        EndIf
        
        
        ;2010-05-31
        ;If qPosition < qSize And qPosition >= 0
        ; Allow positions greater than the size
        If  qPosition >= 0
          VirtualFileHandles(VirtualFileHandle)\qPosition = qPosition
          If *lpNewFilePointer
            PokeQ(*lpNewFilePointer, qPosition)
          EndIf
          SetLastError_(#NO_ERROR)  
          iResult = #True
        Else
          If qPosition < 0
            SetLastError_(#ERROR_NEGATIVE_SEEK)
            __HookLogWarn("SetFilePointerEx failed for handle " + Hex(hFile) + " with errocode ERROR_NEGATIVE_SEEK")
          Else
            SetLastError_(#ERROR_INVALID_PARAMETER)
            __HookLogWarn("SetFilePointerEx failed for handle " + Hex(hFile) + " with errocode ERROR_INVALID_PARAMETER; position is " + Str(qPosition) + "/" + Str(qSize))
          EndIf
          iResult = #False
        EndIf
      
      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================  
 
      
    Else
      
      If g_VirtualFile\Hooks\OrgSetFilePointerEx
        iResult = g_VirtualFile\Hooks\OrgSetFilePointerEx(hFile,qDistanceToMove.q,*lpNewFilePointer ,dwMoveMethod)
      Else
        SetLastError_(#ERROR_BAD_COMMAND)
        __HookLogError("SetFilePointerEx function pointer is null!")
      EndIf
      UNLOCK_VIRTUAL_MUTEX     
    EndIf
    
    
    
    
  Else
    SetLastError_(#ERROR_INVALID_PARAMETER)
    iResult = #False
    __HookLogError("SetFilePointerEx failed with invalid handle")
  EndIf
  
  ProcedureReturn iResult
EndProcedure


ProcedureDLL __ReadFile(hFile,lpBuffer,nNumberOfBytesToRead,lpNumberOfBytesRead,*lpOverlapped.OVERLAPPED)
  Protected VirtualFileHandle.i, VirtualFile.i, qSize.q, qPosition.q, *BufferPtr, res.i = #False, qTmpPos.q, iNumBytesRead.i
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX    
  
  ;Nicht so interresant
  __HookLogDebug("ReadFile("+Hex(hFile) + "," + Hex(lpBuffer) +","  + Str(nNumberOfBytesToRead) +"," + Hex(lpNumberOfBytesRead) + "," + Hex(*lpOverlapped.OVERLAPPED) + ")")


  If hFile <> #INVALID_HANDLE_VALUE And nNumberOfBytesToRead > 0 And lpBuffer <> #Null
      
     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hFile)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
    ;================     
    
      qSize = VirtualFiles(VirtualFile)\qSize
      qPosition =  VirtualFileHandles(VirtualFileHandle)\qPosition
 
      ;Debug "iSize:"+Str(iSize)
      ;Debug "iPosition:"+Str(iPosition)
      ;Debug "*BufferPtr:"+Str(*BufferPtr)
      ;Debug "nNumberOfBytesToRead:"+Str(nNumberOfBytesToRead)
      
      If VirtualFiles(VirtualFile)\bIsEncrypted = #False
      
        *BufferPtr = VirtualFiles(VirtualFile)\BufferPtr            
        If *BufferPtr <> #Null
              
          If *lpOverlapped ; 2010-7-28 Bed. VirtualFileHandles(VirtualFileHandle)\bOverlapped ist nicht notwendig (.mkv sonst nicht abspielbar...)
            qPosition = (*lpOverlapped\Offset & $FFFFFFFF) + ((*lpOverlapped\OffsetHigh & $FFFFFFFF) << 32)
          EndIf
              
          If qPosition + nNumberOfBytesToRead > qSize
            nNumberOfBytesToRead = qSize - qPosition
            ;Debug "correct nNumberOfBytesToRead to "+Str(nNumberOfBytesToRead)
          EndIf   
          
          ;2010-05-31
          If nNumberOfBytesToRead < 0
            nNumberOfBytesToRead = 0  
          EndIf      
          
          CompilerIf #USE_VIRTUALFILE_SECURE_MEMORY
            SecureCopyMemory(*BufferPtr + qPosition, lpBuffer, nNumberOfBytesToRead)
          CompilerElse
            CopyMemory(*BufferPtr + qPosition, lpBuffer, nNumberOfBytesToRead)            
          CompilerEndIf
          
          qPosition + nNumberOfBytesToRead
          If lpNumberOfBytesRead
            
            CompilerIf #USE_VIRTUALFILE_SECURE_MEMORY
              SecurePokeL(lpNumberOfBytesRead, nNumberOfBytesToRead)
            CompilerElse  
              PokeL(lpNumberOfBytesRead, nNumberOfBytesToRead)
            CompilerEndIf  
            
          EndIf
          VirtualFileHandles(VirtualFileHandle)\qPosition  = qPosition
          SetLastError_(#NO_ERROR) ; 2010-07-03
          res = #True
        
        Else
          SetLastError_(#ERROR_INVALID_PARAMETER)
          __HookLogError("internal buffer is null!")        
        EndIf
        
      Else

        If *lpOverlapped
          ;qPosition  = *lpOverlapped\Offset + *lpOverlapped\OffsetHigh << 32; + VirtualFiles(iVirtualFile)\iHeaderOffset
          qPosition = (*lpOverlapped\Offset & $FFFFFFFF) + ((*lpOverlapped\OffsetHigh & $FFFFFFFF) << 32) ;2012-08-21
          ;*lpOverlapped\Offset = qTmpPos & $FFFFFFFF ;2010-07-29 TEST
          ;*lpOverlapped\OffsetHigh = (qTmpPos >> 32) & $FFFFFFFF ;2010-07-29 TEST
        EndIf
        
        iNumBytesRead = 0
        res = #False
        
       ; Debug VirtualFiles(iVirtualFile)\bDownloadFromURL
        
        If VirtualFiles(VirtualFile)\bDownloadFromURL
          ;From Streaming manager
          
          res = ReadBytes(VirtualFiles(VirtualFile)\iUniqueDownloadID, lpBuffer.i, qPosition  + VirtualFiles(VirtualFile)\iHeaderOffset, nNumberOfBytesToRead, @iNumBytesRead)
          
          If res 
            If VirtualFiles(VirtualFile)\DecryptionBuffer And lpBuffer
              CryptBuffer(lpBuffer, qPosition, VirtualFiles(VirtualFile)\DecryptionBuffer, iNumBytesRead.i)
            EndIf             
            SetLastError_(#NO_ERROR)
          Else  
            SetLastError_(#ERROR_ACCESS_DENIED)
            __HookLogError("ReadBytes in streaming manager failed!")      
          EndIf          
          
          
        Else
          ;From file
          
          LOCK_VIRTUAL_MUTEX  
          If g_VirtualFile\Hooks\OrgSetFilePointerEx
            If g_VirtualFile\Hooks\OrgReadFile
              If g_VirtualFile\Hooks\OrgSetFilePointerEx(VirtualFileHandles(VirtualFileHandle)\hDecryptedFileHandle, qPosition  + VirtualFiles(VirtualFile)\iHeaderOffset, #Null, #FILE_BEGIN)  
                res = g_VirtualFile\Hooks\OrgReadFile(VirtualFileHandles(VirtualFileHandle)\hDecryptedFileHandle,lpBuffer,nNumberOfBytesToRead,@iNumBytesRead, #Null) ;2010-07-29 TEST *lpOverlapped)
                If res
                  SetLastError_(#NO_ERROR) ; 2010-07-03
                  ;- CHECK!, MUST NOT BE COMMENTED!
                  If VirtualFiles(VirtualFile)\DecryptionBuffer And lpBuffer
                    CryptBuffer(lpBuffer,qPosition,VirtualFiles(VirtualFile)\DecryptionBuffer,iNumBytesRead.i)
                  EndIf  
                EndIf
              EndIf
            Else
             SetLastError_(#ERROR_BAD_COMMAND)
            __HookLogError("ReadFile function pointer is null!")           
            EndIf
          Else
            SetLastError_(#ERROR_BAD_COMMAND)
            __HookLogError("SetFilePointerEx function pointer is null!") 
          EndIf
          UNLOCK_VIRTUAL_MUTEX
        
        EndIf
        
        
        If lpNumberOfBytesRead
          PokeL(lpNumberOfBytesRead, iNumBytesRead)
        EndIf
        qPosition + iNumBytesRead       
        VirtualFileHandles(VirtualFileHandle)\qPosition  = qPosition      
      EndIf
      
      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================
           
      
    Else     
      If g_VirtualFile\Hooks\OrgReadFile
        res = g_VirtualFile\Hooks\OrgReadFile(hFile,lpBuffer,nNumberOfBytesToRead,lpNumberOfBytesRead,*lpOverlapped)
      Else
         SetLastError_(#ERROR_BAD_COMMAND)
       __HookLogError("ReadFile function pointer is null!")     
      EndIf 
      UNLOCK_VIRTUAL_MUTEX
    EndIf
  Else
    res = #False
     SetLastError_(#ERROR_INVALID_PARAMETER)
    __HookLogError("ReadFile failed with invalid parameter")
  EndIf
  
  
  ProcedureReturn res
EndProcedure


ProcedureDLL __ReadFileEx(hFile,lpBuffer,nNumberOfBytesToRead,*lpOverlapped.OVERLAPPED,lpCompletionRoutine.CBFileIOCompletionRoutine)
  Protected VirtualFileHandle.i, VirtualFile.i, qSize.q, qPosition.q, *BufferPtr, res.i, qTmpPos.q, iNumBytesRead.i
   INIT_VIRTUAL_MUTEX
   INIT_VIRTUAL_INDIVIDUALMUTEX  
   
   __HookLogDebug("ReadFileEx("+Hex(hFile) + "," + Hex(lpBuffer) +"," + Str(nNumberOfBytesToRead) + "," + Hex(*lpOverlapped) + "," + Hex(lpCompletionRoutine)+ ")")
 
  
  If hFile <> #INVALID_HANDLE_VALUE And nNumberOfBytesToRead > 0 

     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hFile)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
    ;================  
   
      qSize = VirtualFiles(VirtualFile)\qSize
      *BufferPtr = VirtualFiles(VirtualFile)\BufferPtr   
      
      If VirtualFiles(VirtualFile)\bIsEncrypted = #False
        ;Not implemented for encrypted Buffers!!!    
      
        If VirtualFileHandles(VirtualFileHandle)\bOverlapped <> #False And *lpOverlapped <> #Null And lpBuffer<> #Null
          qPosition = (*lpOverlapped\Offset & $FFFFFFFF) + (*lpOverlapped\OffsetHigh << 32)
          
          If qPosition + nNumberOfBytesToRead > qSize
            nNumberOfBytesToRead = qSize - qPosition
          EndIf                
          
          
          CompilerIf #USE_VIRTUALFILE_SECURE_MEMORY
            SecureCopyMemory(*BufferPtr + qPosition, lpBuffer, nNumberOfBytesToRead)            
          CompilerElse
            CopyMemory(*BufferPtr + qPosition, lpBuffer, nNumberOfBytesToRead)
          CompilerEndIf
          
          qPosition + nNumberOfBytesToRead
          If lpCompletionRoutine
            lpCompletionRoutine(#ERROR_SUCCESS ,nNumberOfBytesToRead, *lpOverlapped)
          EndIf 
          res = #True
          SetLastError_(#NO_ERROR) ; 2010-07-03
               
        Else
          If lpCompletionRoutine
            lpCompletionRoutine(#ERROR_BAD_ARGUMENTS, 0, *lpOverlapped)
          EndIf      
        EndIf 

      Else      
        
        
        
        iNumBytesRead = 0
        res = #False
        
        If *lpOverlapped ; 2011-03-05 must not be NULL!
          ;CopyMemory(*lpOverlapped, internalOverlapped, SizeOf(OVERLAPPED))
          ;qPosition  = *lpOverlapped\Offset + *lpOverlapped\OffsetHigh << 32 + VirtualFiles(iVirtualFile)\iHeaderOffset
          ;internalOverlapped\Offset = qTmpPos & $FFFFFFFF
          ;internalOverlapped\OffsetHigh = (qTmpPos >> 32) & $FFFFFFFF
          qPosition  = *lpOverlapped\Offset + *lpOverlapped\OffsetHigh << 32
          
        EndIf  
          
        If VirtualFiles(VirtualFile)\bDownloadFromURL
          ;From Streaming manager
          
          If *lpOverlapped                    
                res = ReadBytes(VirtualFiles(VirtualFile)\iUniqueDownloadID, lpBuffer.i, qPosition + VirtualFiles(VirtualFile)\iHeaderOffset, nNumberOfBytesToRead, @iNumBytesRead)              
             If res       
               If VirtualFiles(VirtualFile)\DecryptionBuffer And lpBuffer
                 CryptBuffer(lpBuffer,qPosition,VirtualFiles(VirtualFile)\DecryptionBuffer,iNumBytesRead.i)
               EndIf
               If lpCompletionRoutine
                 lpCompletionRoutine(#ERROR_SUCCESS ,iNumBytesRead, *lpOverlapped)
               EndIf                   
               SetLastError_(#NO_ERROR)
             Else  
               __HookLogError("ReadBytes in streaming manager failed!")                 
               SetLastError_(#ERROR_ACCESS_DENIED)
             EndIf
          EndIf
           
          
        Else
          ;From file
          If *lpOverlapped
              LOCK_VIRTUAL_MUTEX 
              If g_VirtualFile\Hooks\OrgSetFilePointerEx
                If g_VirtualFile\Hooks\OrgReadFile
                  If g_VirtualFile\Hooks\OrgSetFilePointerEx(VirtualFileHandles(VirtualFileHandle)\hDecryptedFileHandle, qPosition  + VirtualFiles(VirtualFile)\iHeaderOffset, #Null, #FILE_BEGIN)  
                    res = g_VirtualFile\Hooks\OrgReadFile(VirtualFileHandles(VirtualFileHandle)\hDecryptedFileHandle, lpBuffer, nNumberOfBytesToRead, @iNumBytesRead, #Null) ; 2011-03-05 no overlapped strucutre...
                    If res
                      ;- CHECK!, MUST NOT BE COMMENTED! 
                      If VirtualFiles(VirtualFile)\DecryptionBuffer And lpBuffer
                        CryptBuffer(lpBuffer,qPosition,VirtualFiles(VirtualFile)\DecryptionBuffer,iNumBytesRead.i)
                      EndIf
                      If lpCompletionRoutine
                        lpCompletionRoutine(#ERROR_SUCCESS ,iNumBytesRead, *lpOverlapped)
                      EndIf
                      ; Not needed
                      ;qPosition + iNumBytesRead       
                      ;VirtualFileHandles(VirtualFileHandle)\qPosition  = qPosition  
                      SetLastError_(#NO_ERROR) ; 2010-07-03
                    EndIf
                  EndIf
                Else
                 SetLastError_(#ERROR_BAD_COMMAND)
                __HookLogError("ReadFile function pointer is null!")           
                EndIf
              Else
                SetLastError_(#ERROR_BAD_COMMAND)
                __HookLogError("SetFilePointerEx function pointer is null!") 
              EndIf
              UNLOCK_VIRTUAL_MUTEX
            EndIf
            
        EndIf       
            
        If res = #False
          If lpCompletionRoutine
            lpCompletionRoutine(#ERROR_BAD_ARGUMENTS, 0, *lpOverlapped)
          EndIf  
        EndIf    
        
      EndIf
      
      
      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================      
      
    Else    
      If g_VirtualFile\Hooks\OrgReadFileEx
        res = g_VirtualFile\Hooks\OrgReadFileEx(hFile,lpBuffer,nNumberOfBytesToRead,*lpOverlapped.OVERLAPPED,lpCompletionRoutine.CBFileIOCompletionRoutine)
      Else
        SetLastError_(#ERROR_BAD_COMMAND)
        __HookLogError("ReadFileEx function pointer is null!")         
      EndIf 
      UNLOCK_VIRTUAL_MUTEX
      
    EndIf
  EndIf
  
  ProcedureReturn res
EndProcedure

ProcedureDLL __GetFileSizeEx(hFile,ptrQSize)
  Protected VirtualFileHandle.i, VirtualFile.i, res.i = #False, qSize.q
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX 
  
  __HookLogDebug("GetFileSizeEx(" + Hex(hFile)+"," + Hex(ptrQSize) + ")")
  
  
  If hFile <> #INVALID_HANDLE_VALUE   
    
     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hFile)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
    ;================  
      
      
      qSize = VirtualFiles(VirtualFile)\qSize  
      If ptrQSize
        PokeQ(ptrQSize, qSize)
      EndIf
      SetLastError_(#NO_ERROR) ; 2010-07-01
      res = #True
      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================      
      
    Else
      
      
      If g_VirtualFile\Hooks\OrgGetFileSizeEx
        res = g_VirtualFile\Hooks\OrgGetFileSizeEx(hFile, ptrQSize)
      Else
         SetLastError_(#ERROR_BAD_COMMAND)
       __HookLogError("GetFileSizeEx function pointer is null!")        
      EndIf
     UNLOCK_VIRTUAL_MUTEX
     
    EndIf
    
  Else
    SetLastError_(#ERROR_INVALID_HANDLE)
  EndIf
  
  ProcedureReturn res
EndProcedure


ProcedureDLL __GetFileSize(hFile,ptrLSize)
  Protected VirtualFileHandle.i, VirtualFile.i, qSize.q, res.i =  #INVALID_FILE_SIZE
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX  
  __HookLogDebug("GetFileSize(" + Hex(hFile) + "," +  Hex(ptrLSize)+ ")")
  
  
  If hFile <> #INVALID_HANDLE_VALUE ;And hFile <> #Null 
    
    
     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hFile)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
        ;================  
        
      qSize = VirtualFiles(VirtualFile)\qSize        
      If ptrLSize
        PokeL(ptrLSize,(qSize >> 32) & $FFFFFFFF)
      EndIf 
      SetLastError_(#NO_ERROR) ; 2010-07-01
      res = qSize & $FFFFFFFF
      
      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================      
      
    Else
      If g_VirtualFile\Hooks\OrgGetFileSize
        res = g_VirtualFile\Hooks\OrgGetFileSize(hFile, ptrLSize)
      Else
        SetLastError_(#ERROR_BAD_COMMAND)
       __HookLogError("GetFileSize function pointer is null!")  
     EndIf
     UNLOCK_VIRTUAL_MUTEX
     
    EndIf
  Else
    SetLastError_(#ERROR_INVALID_HANDLE)
  EndIf
  ProcedureReturn res
EndProcedure


ProcedureDLL __GetFileType(hFile)
  Protected VirtualFileHandle.i, VirtualFile.i, res.i = #FILE_TYPE_UNKNOWN
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX 
  __HookLogDebug("GetFileType(" + Hex(hFile) + ")")
  

  If hFile <> #INVALID_HANDLE_VALUE
   
     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hFile)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
        ;================  
        
      SetLastError_(#NO_ERROR) ; 2010-07-01
      res = #FILE_TYPE_DISK 
      
      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================      
    Else
     If g_VirtualFile\Hooks\OrgGetFileType
       res = g_VirtualFile\Hooks\OrgGetFileType(hFile)
     Else
       SetLastError_(#ERROR_BAD_COMMAND)
       __HookLogError("GetFileType function pointer is null!")      
     EndIf
     UNLOCK_VIRTUAL_MUTEX
     
    EndIf
  Else
    SetLastError_(#ERROR_INVALID_HANDLE)
  EndIf
 
  ProcedureReturn res
EndProcedure



ProcedureDLL __GetFileInformationByHandle(hFile, *lpFileInformation.BY_HANDLE_FILE_INFORMATION)
  Protected VirtualFileHandle.i, VirtualFile.i, qSize.q, res.i = #False
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX  
  __HookLogDebug("GetFileInformationByHandle(" + Hex(hFile) + "," + Hex(*lpFileInformation) + ")") 

  
  If hFile <>#INVALID_HANDLE_VALUE
    
     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hFile)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
        ;================  
        
      VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile
      qSize = VirtualFiles(VirtualFile)\qSize      
      *lpFileInformation\nFileSizeLow = qSize & $FFFFFFFF
      *lpFileInformation\nFileSizeHigh = (qSize >> 32) & $FFFFFFFF
      *lpFileInformation\dwFileAttributes = #FILE_ATTRIBUTE_NORMAL
      *lpFileInformation\nNumberOfLinks = 0
      *lpFileInformation\dwVolumeSerialNumber = 0
      SetLastError_(#NO_ERROR) ; 2010-07-01
      res = #True
      
      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================
      
    Else   
      If g_VirtualFile\Hooks\OrgGetFileInformationByHandle
        res = g_VirtualFile\Hooks\OrgGetFileInformationByHandle(hFile, *lpFileInformation)
      Else
        SetLastError_(#ERROR_BAD_COMMAND)
        __HookLogError("GetFileInformationByHandle function pointer is null!")
      EndIf
      UNLOCK_VIRTUAL_MUTEX       
      
    EndIf
  Else
    SetLastError_(#ERROR_INVALID_HANDLE)
  EndIf

  ProcedureReturn res
EndProcedure



ProcedureDLL __CloseHandle(hFile)
  Protected VirtualFileHandle.i, VirtualFile.i, iSize.q, res.i = #False
  Protected handleIdx.i, *handlePtr.integer
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX 
  ;__HookLogDebug("CloseHandle(" + Hex(hFile) + ")") ; nicht so interresant
  
  
  If hFile <> #INVALID_HANDLE_VALUE
    
    
     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hFile)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
    ;================  
    
      If VirtualFileHandles(VirtualFileHandle)\bUsed
        
        VirtualFileHandles(VirtualFileHandle)\iUseCound - 1
        
        
        ; 2010-07-03 handle muss auf jeden fall freigegeben werden
        If g_VirtualFile\Hooks\OrgCloseHandle
          res = g_VirtualFile\Hooks\OrgCloseHandle(hFile)  
          

;           ForEach VirtualFileHandles(VirtualFileHandle)\handles()       ; Process all the elements...
;             If VirtualFileHandles(VirtualFileHandle)\handles() = hFile  ; Is it really our handle?           
;               DeleteElement(VirtualFileHandles(VirtualFileHandle)\handles())
;               Break
;             EndIf
;           Next
            For handleIdx = 0 To VirtualFileHandles(VirtualFileHandle)\handles\size - 1
              *handlePtr = VirtualFileHandles(VirtualFileHandle)\handles\entries + handleIdx *SizeOf(Integer)
              If *handlePtr\i = hFile  ; Is it really our handle?           
                MYLIST_Remove(@VirtualFileHandles(VirtualFileHandle)\handles, hFile)
                Break
              EndIf
            Next
          
          
        Else
          SetLastError_(#ERROR_BAD_COMMAND)
          __HookLogError("CloseHandle function pointer is null!")
        EndIf        
        
        
        If VirtualFileHandles(VirtualFileHandle)\iUseCound <=0
        
          VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile
          If VirtualFile => 0
            VirtualFiles(VirtualFile)\iUseCount - 1
          EndIf             
          
          ;SetLastError_(#NO_ERROR)
          If g_VirtualFile\Hooks\OrgCloseHandle
            
            ;2010-07-03 nach oben verschoben
            ;res = g_VirtualFile\Hooks\OrgCloseHandle(VirtualFileHandles(VirtualFileHandle)\hPipeHandle)
            ;If res
            If VirtualFileHandles(VirtualFileHandle)\hDecryptedFileHandle
              res = g_VirtualFile\Hooks\OrgCloseHandle(VirtualFileHandles(VirtualFileHandle)\hDecryptedFileHandle)
            EndIf
            VirtualFileHandles(VirtualFileHandle)\hDecryptedFileHandle = #Null
            ;EndIf        
          Else
            SetLastError_(#ERROR_BAD_COMMAND)
            __HookLogError("CloseHandle function pointer is null!")
          EndIf 
          
          VirtualFileHandles(VirtualFileHandle)\bUsed = #False  
          ;VirtualFileHandles(VirtualFileHandle)\hPipeHandle = #Null  ;2010-07-03
          ;ClearList(VirtualFileHandles(VirtualFileHandle)\handles())  ;2010-07-03 sollte aber beireits leer sein
          MYLIST_Delete(@VirtualFileHandles(VirtualFileHandle)\handles)
          
          VirtualFileHandles(VirtualFileHandle)\iVirtualFile = 0
          VirtualFileHandles(VirtualFileHandle)\qPosition = 0
          VirtualFileHandles(VirtualFileHandle)\bOverlapped = #False
          VirtualFileHandles(VirtualFileHandle)\iUseCound = 0
        Else
          SetLastError_(#NO_ERROR)
          __HookLogDebug("VirtualFileHandle " + Hex(VirtualFileHandle) + " still referenced")
          ;res = #True
        EndIf
        
      EndIf  
      

      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================      
      
    Else
      If g_VirtualFile\Hooks\OrgCloseHandle
        res = g_VirtualFile\Hooks\OrgCloseHandle(hFile)
      Else
        SetLastError_(#ERROR_BAD_COMMAND)
        __HookLogError("CloseHandle function pointer is null!")
      EndIf
      UNLOCK_VIRTUAL_MUTEX       
      
    EndIf
  Else
    SetLastError_(#ERROR_INVALID_HANDLE)
  EndIf
  
  If res = #False
    __HookLogWarn("CloseHandle failed for handle "+ Hex(hFile)+ "; GetLastError is "+Str(GetLastError_()))
  EndIf
  

  ProcedureReturn res
EndProcedure


ProcedureDLL __DuplicateHandle(hSourceProcessHandle, hSourceHandle, hTargetProcessHandle, *lpTargetHandle.integer, dwDesiredAccess,bInheritHandle ,dwOptions)
  Protected bRes.i = #False, handle, VirtualFileHandle.i, VirtualFile.i 
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX 
  __HookLogDebug("DuplicateHandle(" + Hex(hSourceHandle) + ",...)") 
  
  handle = 0
  
  SetLastError_(#ERROR_INVALID_PARAMETER) ; evtl. anpassen
  
  If hSourceHandle <> #INVALID_HANDLE_VALUE
    
    
     ;=== BEGIN BLOCK === 
    LOCK_VIRTUAL_MUTEX     
    VirtualFileHandle.i = __GetVirtualFileHandleIDFromKernelHandle(hSourceHandle)

    If VirtualFileHandle > -1         
        VirtualFile.i = VirtualFileHandles(VirtualFileHandle)\iVirtualFile     
        LOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
        UNLOCK_VIRTUAL_MUTEX 
        ;================ 
        
      ; virtual kernel handle
      
      If hSourceProcessHandle = hTargetProcessHandle
        If VirtualFileHandles(VirtualFileHandle)\bUsed
          ;handle = VirtualFileHandles(VirtualFileHandle)\hPipeHandle

          If Not dwOptions & #DUPLICATE_CLOSE_SOURCE
            handle = __CreatePipeHandle(VirtualFileHandle) 
            If handle
              ;InsertElement(VirtualFileHandles(VirtualFileHandle)\handles())
              ;VirtualFileHandles(VirtualFileHandle)\handles() = handle  
              MYLIST_Add(@VirtualFileHandles(VirtualFileHandle)\handles, handle)
            EndIf
          
          Else
            handle = hSourceHandle ; just return the same handle....
          EndIf  
          
          If *lpTargetHandle
            *lpTargetHandle\i = handle  
          EndIf
          If handle
            bRes = #True
            SetLastError_(#NO_ERROR)
          EndIf
        
        Else
          __HookLogError("virtual file handle not used...")
        EndIf
        
      Else
        __HookLogDebug("failed, virtual handle cannot be shared between different processes")
      EndIf
      
      ;=== END BLOCK ===  
      UNLOCK_VIRTUAL_INDIVIDUALMUTEX(@VirtualFiles(VirtualFile)\hMutex)  
      ;=================  

    Else
     ;Normal kernel handle
      __HookLogDebug("dublicate normal handle....")
      If g_VirtualFile\Hooks\OrgDuplicateHandle ; 2011-03-06 if...
        bRes = g_VirtualFile\Hooks\OrgDuplicateHandle(hSourceProcessHandle, hSourceHandle, hTargetProcessHandle, *lpTargetHandle, dwDesiredAccess,bInheritHandle ,dwOptions)  
      Else
        SetLastError_(#ERROR_BAD_COMMAND)        
        bRes = #False
      EndIf
      UNLOCK_VIRTUAL_MUTEX
      
    EndIf
    
  Else
    __HookLogDebug("invalid handle")    
    SetLastError_(#ERROR_INVALID_PARAMETER)
  EndIf

  ProcedureReturn bRes
EndProcedure  


ProcedureDLL __GetFileAttributesA(lpFileName.i)
  Protected VirtualFile.i, iResult.i = -1, *ptrFileName
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX    
  
  If lpFileName
    __HookLogDebug("GetFileAttributesA(" + PeekS(lpFileName,-1,  #PB_Ascii) + ")")
  Else
    __HookLogDebug("GetFileAttributesA(NULL)")    
  EndIf 
  

  LOCK_VIRTUAL_MUTEX    ; 2011-03-06 only global Mutex (returns just constant)        
  If lpFileName
    *ptrFileName = Str_PeekAnsi(lpFileName)
    ;iVirtualFile.i = __GetVirtualFileIndexForFile(PeekS(lpFileName,-1,  #PB_Ascii) )
    VirtualFile.i = __GetVirtualFileIndexForFile(*ptrFileName)
    Str_Free(*ptrFileName)
  Else
    VirtualFile  -1
  EndIf
  
  If VirtualFile >= 0
    SetLastError_(#ERROR_SUCCESS)
    iResult = #FILE_ATTRIBUTE_NORMAL
  Else
    If g_VirtualFile\Hooks\OrgGetFileAttributesA
      iResult = g_VirtualFile\Hooks\OrgGetFileAttributesA(lpFileName)
    Else
      SetLastError_(#ERROR_BAD_COMMAND)
      __HookLogError("GetFileAttributeeA function pointer is null!")
    EndIf 
  EndIf
  UNLOCK_VIRTUAL_MUTEX
   
  ProcedureReturn iResult  
EndProcedure

ProcedureDLL __GetFileAttributesW(lpFileName.i)
  Protected VirtualFile.i, iResult.i = -1, *ptrFileName;, iLastError.i
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX
  
  If lpFileName
    __HookLogDebug("GetFileAttributesW(" + PeekS(lpFileName,-1,  #PB_Unicode) + ")")
  Else
    __HookLogDebug("GetFileAttributesW(NULL)")    
  EndIf 
 
  
  LOCK_VIRTUAL_MUTEX    ; 2011-03-06 only global Mutex (returns just constant)
  If lpFileName
    ;iVirtualFile.i = __GetVirtualFileIndexForFile(PeekS(lpFileName,-1,  #PB_Unicode) )
    *ptrFileName = Str_PeekUnicode(lpFileName)
    VirtualFile.i = __GetVirtualFileIndexForFile(*ptrFileName)
    Str_Free(*ptrFileName)
  Else
    VirtualFile  -1
  EndIf
  
  If VirtualFile >= 0   
    SetLastError_(#ERROR_SUCCESS)
    iResult = #FILE_ATTRIBUTE_NORMAL
  Else
    If g_VirtualFile\Hooks\OrgGetFileAttributesW
      iResult = g_VirtualFile\Hooks\OrgGetFileAttributesW(lpFileName) 
      ;iLastError = GetLastError_()
    Else
      SetLastError_(#ERROR_BAD_COMMAND)
      __HookLogError("GetFileAttributesW function pointer is null!")
    EndIf 
  EndIf
  UNLOCK_VIRTUAL_MUTEX 

  ;SetLastError_(iLastError)
  ProcedureReturn iResult    
EndProcedure




ProcedureDLL __GetFileAttributesExA(lpFileName.i, fInfoLevelId.i, *lpFileInformation.WIN32_FILE_ATTRIBUTE_DATA)
  Protected VirtualFile.i, bResult.i = #False, qSize.q, *ptrFileName
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX  
  If lpFileName
    __HookLogDebug("GetFileAttributesExA(" + PeekS(lpFileName,-1,  #PB_Ascii) + ",...)")
  Else
    __HookLogDebug("GetFileAttributesExA(NULL, ...)")    
  EndIf 

  LOCK_VIRTUAL_MUTEX  
  
  If lpFileName 
    ;iVirtualFile.i = __GetVirtualFileIndexForFile(PeekS(lpFileName,-1,  #PB_Ascii) )
    *ptrFileName = Str_PeekAnsi(lpFileName)
    VirtualFile.i = __GetVirtualFileIndexForFile(*ptrFileName )   
    Str_Free(*ptrFileName)
  Else
    VirtualFile  -1
  EndIf
  
  If VirtualFile >= 0
    If fInfoLevelId = #GetFileExInfoStandard And *lpFileInformation
      SetLastError_(#ERROR_SUCCESS)
      bResult = #True
      qSize = VirtualFiles(VirtualFile)\qSize
      *lpFileInformation\dwFileAttributes = #FILE_ATTRIBUTE_NORMAL
      *lpFileInformation\nFileSizeLow = qSize & $FFFFFFFF
      *lpFileInformation\nFileSizeHigh = (qSize >> 32) & $FFFFFFFF
    Else
      SetLastError_(#ERROR_INVALID_PARAMETER)      
    EndIf  
  Else
    If g_VirtualFile\Hooks\OrgGetFileAttributesExA
      bResult = g_VirtualFile\Hooks\OrgGetFileAttributesExA(lpFileName, fInfoLevelId, *lpFileInformation)
    Else
      SetLastError_(#ERROR_BAD_COMMAND)
      __HookLogError("GetFileAttributesExA function pointer is null!")
    EndIf
  EndIf
  
  UNLOCK_VIRTUAL_MUTEX 
  ProcedureReturn bResult  
EndProcedure




ProcedureDLL __GetFileAttributesExW(lpFileName.i, fInfoLevelId.i, *lpFileInformation.WIN32_FILE_ATTRIBUTE_DATA)
  Protected VirtualFile.i, bResult.i = #False, qSize.q, *ptrFileName
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX  
  If lpFileName
    __HookLogDebug("GetFileAttributesExW(" + PeekS(lpFileName,-1,  #PB_Unicode) + ",...)")
  Else
    __HookLogDebug("GetFileAttributesExW(NULL, ...)")    
  EndIf 
  
  LOCK_VIRTUAL_MUTEX  
  
  If lpFileName   
    ;iVirtualFile.i = __GetVirtualFileIndexForFile(PeekS(lpFileName,-1,  #PB_Unicode) )
    *ptrFileName = Str_PeekAnsi(lpFileName)
    VirtualFile.i = __GetVirtualFileIndexForFile(*ptrFileName)
    Str_Free(*ptrFileName)
  Else
    VirtualFile  -1
  EndIf
  
  If VirtualFile >= 0
    If fInfoLevelId = #GetFileExInfoStandard And *lpFileInformation
      SetLastError_(#ERROR_SUCCESS)
      bResult = #True
      qSize = VirtualFiles(VirtualFile)\qSize
      *lpFileInformation\dwFileAttributes = #FILE_ATTRIBUTE_NORMAL
      *lpFileInformation\nFileSizeLow = qSize & $FFFFFFFF
      *lpFileInformation\nFileSizeHigh = (qSize >> 32) & $FFFFFFFF
    Else
      SetLastError_(#ERROR_INVALID_PARAMETER)      
    EndIf  
  Else
    If g_VirtualFile\Hooks\OrgGetFileAttributesExW
      bResult = g_VirtualFile\Hooks\OrgGetFileAttributesExW(lpFileName, fInfoLevelId, *lpFileInformation)
    Else
      SetLastError_(#ERROR_BAD_COMMAND)
      __HookLogError("GetFileAttributesExW function pointer is null!")
    EndIf
  EndIf
  
  UNLOCK_VIRTUAL_MUTEX 
  ProcedureReturn bResult  
EndProcedure

ProcedureDLL __FindFirstFileA(lpFileName.i, *lpFindFileData.WIN32_FIND_DATA_ANSI )
  Protected VirtualFile.i, iResult.i = #INVALID_HANDLE_VALUE, qSize.q, dummy.WIN32_FIND_DATA_ANSI
  Protected sFileName, sPathPart, sProgramName, sTmp
  STRING_INIT
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX    
  
  If lpFileName
    __HookLogDebug("FindFirstFileA(" + PeekS(lpFileName,-1,  #PB_Ascii) + ")")
  Else
    __HookLogDebug("FindFirstFileA(NULL, ...)")    
  EndIf 
  
  
  LOCK_VIRTUAL_MUTEX    
  
  If lpFileName
    ;iVirtualFile.i = __GetVirtualFileIndexForFile(PeekS(lpFileName, -1,  #PB_Ascii) )
    sFileName = Str_PeekAnsi(lpFileName)
    VirtualFile.i = __GetVirtualFileIndexForFile(sFileName)
    Str_Free(sFileName)
  Else
    VirtualFile  -1
  EndIf
  
  If VirtualFile >= 0
    qSize = VirtualFiles(VirtualFile)\qSize    
    SetLastError_(#ERROR_SUCCESS)
    *lpFindFileData\nFileSizeLow = qSize & $FFFFFFFF
    *lpFindFileData\nFileSizeHigh = (qSize >> 32) & $FFFFFFFF
    *lpFindFileData\dwFileAttributes = #FILE_ATTRIBUTE_NORMAL
    
    Str_PokeAnsi(@*lpFindFileData\cAlternate, @"", 1)
    ;PokeS(@*lpFindFileData\cAlternate, "", 1, #PB_Ascii)
    ;PokeS(@*lpFindFileData\cFileName, GetFilePart(VirtualFiles(iVirtualFile)\sFileName), 259, #PB_Ascii)
    
    STRINGEX_GETPATHPART(sPathPart, @VirtualFiles(VirtualFile)\sFileName)
    Str_PokeAnsi(@*lpFindFileData\cFileName, sPathPart, 259)
    Str_Free(sPathPart)
    
    If g_VirtualFile\Hooks\OrgFindFirstFileA
      ;sTmp.s = Space(260 * 2)
      ;PokeS(@sTmp, ProgramFilename(), 259, #PB_Ascii)
      
      STRING_SPACE(sTmp, 260 * 2)
      STRINGEX_PROGRAMNAME(sProgramName)
      Str_PokeAnsi(sTmp, sProgramName, 259)
      
      iResult = g_VirtualFile\Hooks\OrgFindFirstFileA(sTmp, dummy)
      
      Str_Free(sTmp)
      Str_Free(sProgramName)
      
    Else
      SetLastError_(#ERROR_BAD_COMMAND)
      __HookLogError("FindFirstFileA function pointer is null!")
    EndIf
    
  Else
    If g_VirtualFile\Hooks\OrgFindFirstFileA
      iResult = g_VirtualFile\Hooks\OrgFindFirstFileA(lpFileName, *lpFindFileData)
    Else
      SetLastError_(#ERROR_BAD_COMMAND)
      __HookLogError("FindFirstFileA function pointer is null!")
    EndIf
  EndIf
  
  UNLOCK_VIRTUAL_MUTEX 
  ProcedureReturn iResult  
EndProcedure




ProcedureDLL __FindFirstFileW(lpFileName.i, *lpFindFileData.WIN32_FIND_DATA_UNICODE )
  Protected VirtualFile.i, iResult.i = #INVALID_HANDLE_VALUE, qSize.q, dummy.WIN32_FIND_DATA_UNICODE
  Protected sPathPart, sProgramName, sTmp, sFileName
  STRING_INIT
  INIT_VIRTUAL_MUTEX
  INIT_VIRTUAL_INDIVIDUALMUTEX   
  
  If lpFileName
    __HookLogDebug("FindFirstFileW(" + PeekS(lpFileName, -1,  #PB_Unicode) + ")")
  Else
    __HookLogDebug("FindFirstFileW(NULL, ...)")    
  EndIf 
  
  
  LOCK_VIRTUAL_MUTEX    
  If lpFileName
    ;iVirtualFile.i = __GetVirtualFileIndexForFile(PeekS(lpFileName, -1,  #PB_Unicode) )
    sFileName = Str_PeekUnicode(lpFileName)
    VirtualFile.i = __GetVirtualFileIndexForFile(sFileName)
    Str_Free(sFileName)
  Else
    VirtualFile  -1
  EndIf
  
  If VirtualFile >= 0
    qSize = VirtualFiles(VirtualFile)\qSize    
    SetLastError_(#ERROR_SUCCESS)
    *lpFindFileData\nFileSizeLow = qSize & $FFFFFFFF
    *lpFindFileData\nFileSizeHigh = (qSize >> 32) & $FFFFFFFF
    *lpFindFileData\dwFileAttributes = #FILE_ATTRIBUTE_NORMAL
    ;PokeS(@*lpFindFileData\cAlternate, "", 1, #PB_Unicode)
    ;PokeS(@*lpFindFileData\cFileName, GetFilePart(VirtualFiles(iVirtualFile)\sFileName), 259, #PB_Unicode)
    
     Str_PokeUnicode(@*lpFindFileData\cAlternate, @"", 1)

    STRINGEX_GETPATHPART(sPathPart, @VirtualFiles(VirtualFile)\sFileName)
    Str_PokeUnicode(@*lpFindFileData\cFileName, sPathPart, 259)
    Str_Free(sPathPart)   
    
    If g_VirtualFile\Hooks\OrgFindFirstFileW
      ;sTmp.s = Space(260 * 2)
      ;PokeS(@sTmp, ProgramFilename(), 259, #PB_Unicode)
      
      STRING_SPACE(sTmp, 260 * 2)
      STRINGEX_PROGRAMNAME(sProgramName)
      Str_PokeAnsi(sTmp, sProgramName, 259)
      
      iResult = g_VirtualFile\Hooks\OrgFindFirstFileW(sTmp, dummy)
      
      Str_Free(sTmp)
      Str_Free(sProgramName)   
      
    Else
      SetLastError_(#ERROR_BAD_COMMAND)
      __HookLogError("FindFirstFileW function pointer is null!")
    EndIf
    
  Else
    If g_VirtualFile\Hooks\OrgFindFirstFileW
      iResult = g_VirtualFile\Hooks\OrgFindFirstFileW(lpFileName, *lpFindFileData)
    Else
      SetLastError_(#ERROR_BAD_COMMAND)
      __HookLogError("FindFirstFileW function pointer is null!")
    EndIf
  EndIf
  
  UNLOCK_VIRTUAL_MUTEX 
  ProcedureReturn iResult  
EndProcedure



; ProcedureDLL VirtualFile_SetLogLevel(iLevel.i)
;   g_VirtualFile\bLogLevel = iLevel
; EndProcedure



Procedure CODEREPLACE_CreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceCreateFileA, g_VirtualFile\Hooks\OrgCreateFileAData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceCreateFileA(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceCreateFileA, @__CreateFileA(), g_VirtualFile\Hooks\OrgCreateFileAData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure

Procedure CODEREPLACE_CreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceCreateFileW, g_VirtualFile\Hooks\OrgCreateFileWData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceCreateFileW(lpFileName,dwDesiredAccess,dwShareMode,lpSecurityAttributes,dwCreationDisposition,dwFlagsAndAttributes,hTemplateFile)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceCreateFileW, @__CreateFileW(), g_VirtualFile\Hooks\OrgCreateFileWData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure

Procedure CODEREPLACE_SetFilePointer(hFile,lDistanceToMove,*lpDistanceToMoveHigh.Long,dwMoveMethod)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceSetFilePointer, g_VirtualFile\Hooks\OrgSetFilePointerData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceSetFilePointer(hFile,lDistanceToMove,*lpDistanceToMoveHigh.Long,dwMoveMethod)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceSetFilePointer, @__SetFilePointer(), g_VirtualFile\Hooks\OrgSetFilePointerData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure


Procedure CODEREPLACE_SetFilePointerEx(hFile,qDistanceToMove.q,*lpNewFilePointer,dwMoveMethod)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceSetFilePointerEx, g_VirtualFile\Hooks\OrgSetFilePointerExData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceSetFilePointerEx(hFile,qDistanceToMove.q,*lpNewFilePointer,dwMoveMethod)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceSetFilePointerEx, @__SetFilePointerEx(), g_VirtualFile\Hooks\OrgSetFilePointerExData,#False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure

Procedure CODEREPLACE_ReadFile(hFile,lpBuffer,nNumberOfBytesToRead,lpNumberOfBytesRead,*lpOverlapped.OVERLAPPED)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceReadFile, g_VirtualFile\Hooks\OrgReadFileData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceReadFile(hFile,lpBuffer,nNumberOfBytesToRead,lpNumberOfBytesRead,*lpOverlapped.OVERLAPPED)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceReadFile, @__ReadFile(), g_VirtualFile\Hooks\OrgReadFileData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure


Procedure CODEREPLACE_ReadFileEx(hFile,lpBuffer,nNumberOfBytesToRead,*lpOverlapped.OVERLAPPED,lpCompletionRoutine.CBFileIOCompletionRoutine)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceReadFileEx, g_VirtualFile\Hooks\OrgReadFileExData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceReadFileEx(hFile,lpBuffer,nNumberOfBytesToRead,*lpOverlapped.OVERLAPPED,lpCompletionRoutine.CBFileIOCompletionRoutine)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceReadFileEx, @__ReadFileEx(), g_VirtualFile\Hooks\OrgReadFileExData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure


Procedure CODEREPLACE_GetFileSizeEx(hFile,ptrQSize)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileSizeEx, g_VirtualFile\Hooks\OrgGetFileSizeExData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceGetFileSizeEx(hFile,ptrQSize)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileSizeEx, @__GetFileSizeEx(), g_VirtualFile\Hooks\OrgGetFileSizeExData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure


Procedure CODEREPLACE_GetFileSize(hFile,ptrLSize)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileSize, g_VirtualFile\Hooks\OrgGetFileSizeData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceGetFileSize(hFile,ptrLSize)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileSize, @__GetFileSize(), g_VirtualFile\Hooks\OrgGetFileSizeData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure


Procedure CODEREPLACE_GetFileType(hFile)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileType, g_VirtualFile\Hooks\OrgGetFileTypeData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceGetFileType(hFile)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileType, @__GetFileType(), g_VirtualFile\Hooks\OrgGetFileTypeData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure


Procedure CODEREPLACE_GetFileInformationByHandle(hFile, *lpFileInformation.BY_HANDLE_FILE_INFORMATION)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileInformationByHandle, g_VirtualFile\Hooks\OrgGetFileInformationByHandleData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceGetFileInformationByHandle(hFile, *lpFileInformation.BY_HANDLE_FILE_INFORMATION)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileInformationByHandle, @__GetFileInformationByHandle(), g_VirtualFile\Hooks\OrgGetFileInformationByHandleData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure


Procedure CODEREPLACE_CloseHandle(hFile)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceCloseHandle, g_VirtualFile\Hooks\OrgCloseHandleData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceCloseHandle(hFile)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceCloseHandle, @__CloseHandle(), g_VirtualFile\Hooks\OrgCloseHandleData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure


Procedure CODEREPLACE_DuplicateHandle(hSourceProcessHandle, hSourceHandle, hTargetProcessHandle, *lpTargetHandle.integer, dwDesiredAccess,bInheritHandle ,dwOptions)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceDuplicateHandle, g_VirtualFile\Hooks\OrgDuplicateHandleData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceDuplicateHandle(hSourceProcessHandle, hSourceHandle, hTargetProcessHandle, *lpTargetHandle.integer, dwDesiredAccess,bInheritHandle ,dwOptions)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceDuplicateHandle, @__DuplicateHandle(), g_VirtualFile\Hooks\OrgDuplicateHandleData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure



;2010-07-24 hinz.
Procedure CODEREPLACE_GetFileAttributesA(lpFileName.i)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesA, g_VirtualFile\Hooks\OrgGetFileAttributesAData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceGetFileAttributesA(lpFileName)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesA, @__GetFileAttributesA(), g_VirtualFile\Hooks\OrgGetFileAttributesAData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure

Procedure CODEREPLACE_GetFileAttributesW(lpFileName.i)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesW, g_VirtualFile\Hooks\OrgGetFileAttributesWData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceGetFileAttributesW(lpFileName)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesW, @__GetFileAttributesW(), g_VirtualFile\Hooks\OrgGetFileAttributesWData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure

Procedure CODEREPLACE_GetFileAttributesExA(lpFileName.i, fInfoLevelId, lpFileInformation)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExA, g_VirtualFile\Hooks\OrgGetFileAttributesExAData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExA(lpFileName, fInfoLevelId, lpFileInformation)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExA, @__GetFileAttributesExA(), g_VirtualFile\Hooks\OrgGetFileAttributesExAData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure

Procedure CODEREPLACE_GetFileAttributesExW(lpFileName.i, fInfoLevelId, lpFileInformation)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExW, g_VirtualFile\Hooks\OrgGetFileAttributesExWData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExW(lpFileName, fInfoLevelId, lpFileInformation)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExW, @__GetFileAttributesExW(), g_VirtualFile\Hooks\OrgGetFileAttributesExWData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure

Procedure CODEREPLACE_FindFirstFileA(lpFileName.i, *lpFindFileData)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceFindFirstFileA, g_VirtualFile\Hooks\OrgFindFirstFileAData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceFindFirstFileA(lpFileName, *lpFindFileData)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceFindFirstFileA, @__FindFirstFileA(), g_VirtualFile\Hooks\OrgFindFirstFileAData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure

Procedure CODEREPLACE_FindFirstFileW(lpFileName.i, *lpFindFileData)
  Protected iResult.i, lastError.i
  CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceFindFirstFileW, g_VirtualFile\Hooks\OrgFindFirstFileWData, #False)  
  iResult = g_VirtualFile\Hooks\CodeReplaceFindFirstFileW(lpFileName, *lpFindFileData)
  lastError.i = GetLastError_()
  CodeReplace_HookFunction(g_VirtualFile\Hooks\CodeReplaceFindFirstFileW, @__FindFirstFileW(), g_VirtualFile\Hooks\OrgFindFirstFileWData, #False)
  SetLastError_(lastError.i)
  ProcedureReturn iResult
EndProcedure








ProcedureDLL.i VirtualFile_Init(MaxVirtualFiles = 1000,MaxVirtualFileHandles = 1000, ReplaceCode = #False)
  Protected iIndex = 0
  __MyDebug("VirtualFile_Init(" +Str(MaxVirtualFiles) + "," +Str(MaxVirtualFileHandles) + ")")
  If g_VirtualFile\bActive = #False
    ReDim VirtualFiles.VirtualFile(MaxVirtualFiles)
    ReDim VirtualFileHandles.VirtualFileHandle(MaxVirtualFileHandles)
    
    ;2010-07-03 Schrott BUG!!! in Linked List
;     For iIndex = 0 To MaxVirtualFileHandles - 1
;       NewList VirtualFileHandles(iIndex)\handles()
;     Next
    For iIndex = 0 To MaxVirtualFileHandles ; - 1
      VirtualFileHandles(iIndex)\handles\invalidvalue = #INVALID_HANDLE_VALUE
      ;NewList VirtualFileHandles(iIndex)\handles()
    Next
    
    g_VirtualFile\bReplaceCode = ReplaceCode
    
    If ReplaceCode
      
      g_VirtualFile\hNewKernelModuleFile = LoadLibrary_(GetKernelCoreFile());LoadLibraryCopy("Kernel32.dll")
      If g_VirtualFile\hNewKernelModuleFile = #Null
        g_VirtualFile\bReplaceCode = #False
      EndIf
      
      g_VirtualFile\hNewKernelModuleHandle = LoadLibrary_(GetKernelCoreHandle());LoadLibraryCopy("Kernel32.dll")
      If g_VirtualFile\hNewKernelModuleHandle = #Null
        g_VirtualFile\bReplaceCode = #False
      EndIf
      
    EndIf  
    
    g_VirtualFile\iMaxVirtualFiles = MaxVirtualFiles
    g_VirtualFile\iMaxVirtualFileHandles = MaxVirtualFileHandles
    ;g_VirtualFile\hLoadLockMutex = CreateMutex()
    
    Mutex_Create()
    ;g_VirtualFile\hLockMutex = CreateMutex() 
    ;InitializeCriticalSection_(g_VirtualFile\hLockMutex)
    
    g_VirtualFile\iRunningCalls = 0
    
    
    If g_VirtualFile\bReplaceCode = #False
      g_VirtualFile\bFirstFunctionModuleOutput = #True
      
      ; Is nötig, da die Funktion beim Hooking benötigt wird
      g_VirtualFile\Hooks\OrgCloseHandle = GetProcAddress_(GetModuleHandle_(GetKernelCoreHandle()), "CloseHandle")  
      
      g_VirtualFile\Hooks\OrgCreateFileA = __HookApi(GetKernelCoreFile(), "CreateFileA", @__CreateFileA())
      g_VirtualFile\Hooks\OrgCreateFileW = __HookApi(GetKernelCoreFile(), "CreateFileW", @__CreateFileW()) 
      g_VirtualFile\Hooks\OrgReadFile =  __HookApi(GetKernelCoreFile(), "ReadFile", @__ReadFile())
      ;g_VirtualFile\Hooks\OrgReadFileEx =  __HookApi(GetKernelCoreFile(), "ReadFileEx", @__ReadFileEx())
      g_VirtualFile\Hooks\OrgSetFilePointer =  __HookApi(GetKernelCoreFile(), "SetFilePointer", @__SetFilePointer())
      g_VirtualFile\Hooks\OrgSetFilePointerEx =  __HookApi(GetKernelCoreFile(), "SetFilePointerEx", @__SetFilePointerEx())
      g_VirtualFile\Hooks\OrgGetFileSizeEx =  __HookApi(GetKernelCoreFile(), "GetFileSizeEx", @__GetFileSizeEx())
      g_VirtualFile\Hooks\OrgGetFileSize =  __HookApi(GetKernelCoreFile(), "GetFileSize", @__GetFileSize())
      g_VirtualFile\Hooks\OrgGetFileType =  __HookApi(GetKernelCoreFile(), "GetFileType", @__GetFileType())
      g_VirtualFile\Hooks\OrgGetFileInformationByHandle =  __HookApi(GetKernelCoreFile(), "GetFileInformationByHandle", @__GetFileInformationByHandle())
      
      
      g_VirtualFile\Hooks\OrgCloseHandle =  __HookApi(GetKernelCoreHandle(), "CloseHandle", @__CloseHandle())
      g_VirtualFile\Hooks\OrgDuplicateHandle =  __HookApi(GetKernelCoreHandle(), "DuplicateHandle", @__DuplicateHandle())
      
      ;2010-07-23
      g_VirtualFile\Hooks\OrgFindFirstFileA = __HookApi(GetKernelCoreFile(), "FindFirstFileA", @__FindFirstFileA())
      g_VirtualFile\Hooks\OrgFindFirstFileW = __HookApi(GetKernelCoreFile(), "FindFirstFileW", @__FindFirstFileW())
      g_VirtualFile\Hooks\OrgGetFileAttributesA = __HookApi(GetKernelCoreFile(), "GetFileAttributesA", @__GetFileAttributesA())
      g_VirtualFile\Hooks\OrgGetFileAttributesW = __HookApi(GetKernelCoreFile(), "GetFileAttributesW", @__GetFileAttributesW())  
      g_VirtualFile\Hooks\OrgGetFileAttributesExA = __HookApi(GetKernelCoreFile(), "GetFileAttributesExA", @__GetFileAttributesExA())
      g_VirtualFile\Hooks\OrgGetFileAttributesExW = __HookApi(GetKernelCoreFile(), "GetFileAttributesExW", @__GetFileAttributesExW())

    Else
         
      g_VirtualFile\Hooks\OrgCreateFileA = @CODEREPLACE_CreateFileA()
      g_VirtualFile\Hooks\OrgCreateFileW = @CODEREPLACE_CreateFileW()
      g_VirtualFile\Hooks\OrgReadFile =  @CODEREPLACE_ReadFile()
      ;g_VirtualFile\Hooks\OrgReadFileEx =  @CODEREPLACE_ReadFileEx()
      g_VirtualFile\Hooks\OrgSetFilePointer =  @CODEREPLACE_SetFilePointer()
      g_VirtualFile\Hooks\OrgSetFilePointerEx =  @CODEREPLACE_SetFilePointerEx()
      g_VirtualFile\Hooks\OrgGetFileSizeEx =  @CODEREPLACE_GetFileSizeEx()
      g_VirtualFile\Hooks\OrgGetFileSize =  @CODEREPLACE_GetFileSize()
      g_VirtualFile\Hooks\OrgGetFileType =  @CODEREPLACE_GetFileType()
      g_VirtualFile\Hooks\OrgGetFileInformationByHandle = @CODEREPLACE_GetFileInformationByHandle()
      g_VirtualFile\Hooks\OrgCloseHandle =  @CODEREPLACE_CloseHandle()
      g_VirtualFile\Hooks\OrgDuplicateHandle = @CODEREPLACE_DuplicateHandle()
      
      
      ;2010-07-23
      g_VirtualFile\Hooks\OrgFindFirstFileA = @CODEREPLACE_FindFirstFileA()
      g_VirtualFile\Hooks\OrgFindFirstFileW = @CODEREPLACE_FindFirstFileW()
      g_VirtualFile\Hooks\OrgGetFileAttributesA = @CODEREPLACE_GetFileAttributesA()
      g_VirtualFile\Hooks\OrgGetFileAttributesW = @CODEREPLACE_GetFileAttributesW()
      g_VirtualFile\Hooks\OrgGetFileAttributesExA = @CODEREPLACE_GetFileAttributesExA()
      g_VirtualFile\Hooks\OrgGetFileAttributesExW = @CODEREPLACE_GetFileAttributesExW()
            
      
      
      g_VirtualFile\Hooks\CodeReplaceCreateFileA = GetProcAddress_(g_VirtualFile\hNewKernelModuleFile, "CreateFileA")
      g_VirtualFile\Hooks\CodeReplaceCreateFileW = GetProcAddress_(g_VirtualFile\hNewKernelModuleFile, "CreateFileW") 
      g_VirtualFile\Hooks\CodeReplaceReadFile =  GetProcAddress_(g_VirtualFile\hNewKernelModuleFile, "ReadFile")
      ;g_VirtualFile\Hooks\OrgReadFileEx =  GetProcAddress_(g_VirtualFile\hNewKernelModule, "ReadFileEx")
      g_VirtualFile\Hooks\CodeReplaceSetFilePointer =  GetProcAddress_(g_VirtualFile\hNewKernelModuleFile, "SetFilePointer")
      g_VirtualFile\Hooks\CodeReplaceSetFilePointerEx =  GetProcAddress_(g_VirtualFile\hNewKernelModuleFile, "SetFilePointerEx")
      g_VirtualFile\Hooks\CodeReplaceGetFileSizeEx =  GetProcAddress_(g_VirtualFile\hNewKernelModuleFile, "GetFileSizeEx")
      g_VirtualFile\Hooks\CodeReplaceGetFileSize =  GetProcAddress_(g_VirtualFile\hNewKernelModuleFile,  "GetFileSize")
      g_VirtualFile\Hooks\CodeReplaceGetFileType =  GetProcAddress_(g_VirtualFile\hNewKernelModuleFile,  "GetFileType")
      g_VirtualFile\Hooks\CodeReplaceGetFileInformationByHandle =  GetProcAddress_(g_VirtualFile\hNewKernelModuleFile,  "GetFileInformationByHandle")
      
      g_VirtualFile\Hooks\CodeReplaceCloseHandle =  GetProcAddress_(g_VirtualFile\hNewKernelModuleHandle,  "CloseHandle")
      g_VirtualFile\Hooks\CodeReplaceDuplicateHandle = GetProcAddress_(g_VirtualFile\hNewKernelModuleHandle,  "DuplicateHandle")
           
      ;2010-07-23
      g_VirtualFile\Hooks\CodeReplaceFindFirstFileA = GetProcAddress_(g_VirtualFile\hNewKernelModuleHandle, "FindFirstFileA")
      g_VirtualFile\Hooks\CodeReplaceFindFirstFileW = GetProcAddress_(g_VirtualFile\hNewKernelModuleHandle, "FindFirstFileW")
      g_VirtualFile\Hooks\CodeReplaceGetFileAttributesA = GetProcAddress_(g_VirtualFile\hNewKernelModuleHandle, "GetFileAttributesA")
      g_VirtualFile\Hooks\CodeReplaceGetFileAttributesW = GetProcAddress_(g_VirtualFile\hNewKernelModuleHandle, "GetFileAttributesW")
      g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExA = GetProcAddress_(g_VirtualFile\hNewKernelModuleHandle, "GetFileAttributesExA")
      g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExW = GetProcAddress_(g_VirtualFile\hNewKernelModuleHandle, "GetFileAttributesExW")
                  
      
      g_VirtualFile\Hooks\OrgCreateFileAData = CodeReplace_HookApi(GetKernelCoreFile(), "CreateFileA", @__CreateFileA())
      g_VirtualFile\Hooks\OrgCreateFileWData = CodeReplace_HookApi(GetKernelCoreFile(), "CreateFileW", @__CreateFileW()) 
      g_VirtualFile\Hooks\OrgReadFileData =  CodeReplace_HookApi(GetKernelCoreFile(), "ReadFile", @__ReadFile())
      ;g_VirtualFile\Hooks\OrgReadFileExData =  CodeReplace_HookApi(GetKernelCoreFile(), "ReadFileEx", @__ReadFileEx())
      g_VirtualFile\Hooks\OrgSetFilePointerData =  CodeReplace_HookApi(GetKernelCoreFile(), "SetFilePointer", @__SetFilePointer())
      g_VirtualFile\Hooks\OrgSetFilePointerExData =  CodeReplace_HookApi(GetKernelCoreFile(), "SetFilePointerEx", @__SetFilePointerEx())
      g_VirtualFile\Hooks\OrgGetFileSizeExData =  CodeReplace_HookApi(GetKernelCoreFile(), "GetFileSizeEx", @__GetFileSizeEx())
      g_VirtualFile\Hooks\OrgGetFileSizeData =  CodeReplace_HookApi(GetKernelCoreFile(), "GetFileSize", @__GetFileSize())
      g_VirtualFile\Hooks\OrgGetFileTypeData =  CodeReplace_HookApi(GetKernelCoreFile(), "GetFileType", @__GetFileType())
      g_VirtualFile\Hooks\OrgGetFileInformationByHandleData =  CodeReplace_HookApi(GetKernelCoreFile(), "GetFileInformationByHandle", @__GetFileInformationByHandle())
      
      
      g_VirtualFile\Hooks\OrgCloseHandleData =  CodeReplace_HookApi(GetKernelCoreHandle(), "CloseHandle", @__CloseHandle())
      g_VirtualFile\Hooks\OrgDuplicateHandleData =  CodeReplace_HookApi(GetKernelCoreHandle(), "DuplicateHandle", @__DuplicateHandle())
      
      ;2010-07-24
      g_VirtualFile\Hooks\OrgFindFirstFileAData = CodeReplace_HookApi(GetKernelCoreFile(), "FindFirstFileA", @__FindFirstFileA())
      g_VirtualFile\Hooks\OrgFindFirstFileWData = CodeReplace_HookApi(GetKernelCoreFile(), "FindFirstFileW", @__FindFirstFileW())
      g_VirtualFile\Hooks\OrgGetFileAttributesAData = CodeReplace_HookApi(GetKernelCoreFile(), "GetFileAttributesA", @__GetFileAttributesA())
      g_VirtualFile\Hooks\OrgGetFileAttributesWData = CodeReplace_HookApi(GetKernelCoreFile(), "GetFileAttributesW", @__GetFileAttributesW())
      g_VirtualFile\Hooks\OrgGetFileAttributesExAData = CodeReplace_HookApi(GetKernelCoreFile(), "GetFileAttributesExA", @__GetFileAttributesExA())
      g_VirtualFile\Hooks\OrgGetFileAttributesExWData = CodeReplace_HookApi(GetKernelCoreFile(), "GetFileAttributesExW", @__GetFileAttributesExW())   
    EndIf
    
    g_VirtualFile\bHookedImport = #True
    g_VirtualFile\bHookedExport = #True    
    g_VirtualFile\bActive = #True
  Else
    __MyDebug("VirtualFile_Init() was already called...")      
  EndIf
  __MyDebug("VirtualFile_Init() is finished")  
EndProcedure

ProcedureDLL.i VirtualFile_Free() ; must be called befor the application ends
  Protected iIndex.i, bCanFree.i = #False, iTries.i = 0, hMutex.i
  __MyDebug("VirtualFile_Free()")
  If g_VirtualFile\bActive 
  ;LockMutex( g_VirtualFile\hLoadLockMutex) ; make sure no thread is running
  INIT_VIRTUAL_MUTEX
  LOCK_VIRTUAL_MUTEX ; make sure no thread is running
  g_VirtualFile\bActive = #False  
  
  If g_VirtualFile\bReplaceCode = #False
    ; First unhook! (Access violation!)
    __HookApi(GetKernelCoreFile(), "CreateFileA", g_VirtualFile\Hooks\OrgCreateFileA)
    __HookApi(GetKernelCoreFile(), "CreateFileW", g_VirtualFile\Hooks\OrgCreateFileW) 
    __HookApi(GetKernelCoreFile(), "ReadFile", g_VirtualFile\Hooks\OrgReadFile)
    ;__HookApi(GetKernelCoreFile(), "ReadFileEx", g_VirtualFile\Hooks\OrgReadFileEx)
    __HookApi(GetKernelCoreFile(), "SetFilePointer", g_VirtualFile\Hooks\OrgSetFilePointer)
    __HookApi(GetKernelCoreFile(), "SetFilePointerEx", g_VirtualFile\Hooks\OrgSetFilePointerEx)
    __HookApi(GetKernelCoreFile(), "GetFileSizeEx", g_VirtualFile\Hooks\OrgGetFileSizeEx)
    __HookApi(GetKernelCoreFile(), "GetFileSize", g_VirtualFile\Hooks\OrgGetFileSize)
    __HookApi(GetKernelCoreFile(), "GetFileType", g_VirtualFile\Hooks\OrgGetFileType)  
    __HookApi(GetKernelCoreFile(), "GetFileInformationByHandle", g_VirtualFile\Hooks\OrgGetFileInformationByHandle)  
    ; restore orginal hook for CloseHandle (and only CloseHandle!) does not seems to work for win7 with compatible xp sp2 (DEP enabled?)
    
    
    __HookApi(GetKernelCoreHandle(), "CloseHandle", g_VirtualFile\Hooks\OrgCloseHandle)
    __HookApi(GetKernelCoreHandle(), "DuplicateHandle",  g_VirtualFile\Hooks\OrgDuplicateHandle) 
    
    ;2010-07-24
    __HookApi(GetKernelCoreFile(), "FindFirstFileA",  g_VirtualFile\Hooks\OrgFindFirstFileA) 
    __HookApi(GetKernelCoreFile(), "FindFirstFileW",  g_VirtualFile\Hooks\OrgFindFirstFileW)     
    __HookApi(GetKernelCoreFile(), "GetFileAttributesA",  g_VirtualFile\Hooks\OrgGetFileAttributesA) 
    __HookApi(GetKernelCoreFile(), "GetFileAttributesW",  g_VirtualFile\Hooks\OrgGetFileAttributesW)     
    __HookApi(GetKernelCoreFile(), "GetFileAttributesExA",  g_VirtualFile\Hooks\OrgGetFileAttributesExA) 
    __HookApi(GetKernelCoreFile(), "GetFileAttributesExW",  g_VirtualFile\Hooks\OrgGetFileAttributesExW)     
          
    
  Else
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceCreateFileA, g_VirtualFile\Hooks\OrgCreateFileAData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceCreateFileW, g_VirtualFile\Hooks\OrgCreateFileWData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceReadFile, g_VirtualFile\Hooks\OrgReadFileData)
    ;g_VirtualFile\Hooks\OrgReadFileExData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceSetFilePointer, g_VirtualFile\Hooks\OrgSetFilePointerData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceSetFilePointerEx, g_VirtualFile\Hooks\OrgSetFilePointerExData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileSizeEx, g_VirtualFile\Hooks\OrgGetFileSizeExData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileSize, g_VirtualFile\Hooks\OrgGetFileSizeData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileType, g_VirtualFile\Hooks\OrgGetFileTypeData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileInformationByHandle, g_VirtualFile\Hooks\OrgGetFileInformationByHandleData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceCloseHandle, g_VirtualFile\Hooks\OrgCloseHandleData)
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceDuplicateHandle, g_VirtualFile\Hooks\OrgDuplicateHandleData) 
    
    ;2010-07-24
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceFindFirstFileA, g_VirtualFile\Hooks\OrgFindFirstFileAData) 
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceFindFirstFileW, g_VirtualFile\Hooks\OrgFindFirstFileWData)     
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesA, g_VirtualFile\Hooks\OrgGetFileAttributesAData) 
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesW, g_VirtualFile\Hooks\OrgGetFileAttributesWData) 
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExA, g_VirtualFile\Hooks\OrgGetFileAttributesExAData) 
    CodeReplace_UnHookFunction(g_VirtualFile\Hooks\CodeReplaceGetFileAttributesExW, g_VirtualFile\Hooks\OrgGetFileAttributesExWData)         
    
    
    FreeMemory(g_VirtualFile\Hooks\OrgCreateFileAData)
    FreeMemory(g_VirtualFile\Hooks\OrgCreateFileWData)
    FreeMemory(g_VirtualFile\Hooks\OrgReadFileData)
    ;FreeMemory(g_VirtualFile\Hooks\OrgReadFileExData)
    FreeMemory(g_VirtualFile\Hooks\OrgSetFilePointerData)
    FreeMemory(g_VirtualFile\Hooks\OrgSetFilePointerExData)
    FreeMemory(g_VirtualFile\Hooks\OrgGetFileSizeExData)
    FreeMemory(g_VirtualFile\Hooks\OrgGetFileSizeData)
    FreeMemory(g_VirtualFile\Hooks\OrgGetFileTypeData)
    FreeMemory(g_VirtualFile\Hooks\OrgGetFileInformationByHandleData)
    FreeMemory(g_VirtualFile\Hooks\OrgCloseHandleData)
    FreeMemory(g_VirtualFile\Hooks\OrgDuplicateHandleData)
    
    ;2010-07-24
    FreeMemory(g_VirtualFile\Hooks\OrgFindFirstFileAData) 
    FreeMemory(g_VirtualFile\Hooks\OrgFindFirstFileWData)     
    FreeMemory(g_VirtualFile\Hooks\OrgGetFileAttributesAData) 
    FreeMemory(g_VirtualFile\Hooks\OrgGetFileAttributesWData) 
    FreeMemory(g_VirtualFile\Hooks\OrgGetFileAttributesExAData) 
    FreeMemory(g_VirtualFile\Hooks\OrgGetFileAttributesExWData)         
    
    
    g_VirtualFile\Hooks\OrgCreateFileAData = #Null
    g_VirtualFile\Hooks\OrgCreateFileWData = #Null
    g_VirtualFile\Hooks\OrgReadFileData = #Null
    ;g_VirtualFile\Hooks\OrgReadFileExData = #NULL
    g_VirtualFile\Hooks\OrgSetFilePointerData = #Null
    g_VirtualFile\Hooks\OrgSetFilePointerExData = #Null
    g_VirtualFile\Hooks\OrgGetFileSizeExData = #Null
    g_VirtualFile\Hooks\OrgGetFileSizeData = #Null
    g_VirtualFile\Hooks\OrgGetFileTypeData = #Null
    g_VirtualFile\Hooks\OrgGetFileInformationByHandleData = #Null
    g_VirtualFile\Hooks\OrgCloseHandleData = #Null
    g_VirtualFile\Hooks\OrgDuplicateHandleData = #Null 
    
    g_VirtualFile\Hooks\OrgFindFirstFileAData = #Null 
    g_VirtualFile\Hooks\OrgFindFirstFileWData = #Null     
    g_VirtualFile\Hooks\OrgGetFileAttributesAData = #Null 
    g_VirtualFile\Hooks\OrgGetFileAttributesWData = #Null 
    g_VirtualFile\Hooks\OrgGetFileAttributesExAData = #Null 
    g_VirtualFile\Hooks\OrgGetFileAttributesExWData = #Null         
    
    
  EndIf
  g_VirtualFile\bHookedImport = #False
  g_VirtualFile\bHookedExport = #False
  
  For iIndex = 0 To g_VirtualFile\iMaxVirtualFileHandles - 1
    VirtualFileHandles(iIndex)\bUsed = #False
  Next
  For iIndex = 0 To g_VirtualFile\iMaxVirtualFiles - 1
    If VirtualFiles(iIndex)\bUsed
      VirtualFiles(iIndex)\bUsed = #False
      If VirtualFiles(iIndex)\BufferPtr And VirtualFiles(iIndex)\bFreeBuffer
        FreeMemory(VirtualFiles(iIndex)\BufferPtr)
        VirtualFiles(iIndex)\BufferPtr = #Null
      EndIf
    EndIf
  Next  
  g_VirtualFile\iMaxVirtualFiles = 0
  g_VirtualFile\iMaxVirtualFileHandles = 0 
  ReDim VirtualFiles.VirtualFile(0)
  ReDim VirtualFileHandles.VirtualFileHandle(0)
  ;UnlockMutex(g_VirtualFile\hLoadLockMutex)
  ;FreeMutex(g_VirtualFile\hLoadLockMutex)
  
  ;hMutex = g_VirtualFile\hLockMutex
  ;g_VirtualFile\hLockMutex = #Null 
  
  If g_VirtualFile\hLockMutex 
    Mutex_Free()
    ;UnlockMutex(hMutex)
    ;FreeMutex(hMutex) ;    
    ;DeleteCriticalSection_(g_VirtualFile\hLockMutex)
  EndIf
  
  If g_VirtualFile\hNewKernelModuleFile
    FreeLibrary_(g_VirtualFile\hNewKernelModuleFile)
    ;ImageUnload_(g_VirtualFile\hNewKernelModule)
    g_VirtualFile\hNewKernelModuleFile = #Null
  EndIf
  If g_VirtualFile\hNewKernelModuleHandle
    FreeLibrary_(g_VirtualFile\hNewKernelModuleHandle)
    ;ImageUnload_(g_VirtualFile\hNewKernelModule)
    g_VirtualFile\hNewKernelModuleHandle = #Null
  EndIf  
  
  
  
  ;UNLOCK_VIRTUAL_MUTEX ; already released....
  
  ;   Repeat
  ;   LOCK_VIRTUAL_MUTEX ; make sure no thread is running
  ;   If g_VirtualFile\iRunningCalls <= 1
  ;     bCanFree = #True
  ;   Else
  ;     __HookLogError("Cannot free mutex at the moment. Running calls: "+Str(g_VirtualFile\iRunningCalls))
  ;   EndIf
  ;   UNLOCK_VIRTUAL_MUTEX 
  ;   Delay(5)
  ;   iTries +1
  ;   Until bCanFree Or iTries > 25
  ;   If bCanFree
  ;     If g_VirtualFile\hLockMutex
  ;       FreeMutex( g_VirtualFile\hLockMutex) ; make sure no thread is running    
  ;       ;DeleteCriticalSection_(g_VirtualFile\hLockMutex)
  ;     EndIf
  ;     g_VirtualFile\hLockMutex = #Null
  ;   Else
  ;     __HookLogWarn("We cannot free the mutex, because it is still used... so continue execution whitout freeing it")
  ;   EndIf
  Else
    __MyDebug("freeing failed: nothing was initalized...")
  EndIf
  __MyDebug("VirtualFile_Free() is finished")
EndProcedure

ProcedureDLL.i VirtualFile_CreateFromMemory(sUniqueFilename.s, *MemoryPtr, iSize.i, bCopyBuffer.i = #True)
  Protected iResult, iIndex.i, *mem, hMutex
  __MyDebug("VirtualFile_CreateFromMemory(" + sUniqueFilename + "," + Hex(*MemoryPtr) + "," +Str(iSize) + "," + Str(bCopyBuffer)+")")
  iResult = #E_FAIL
  If *MemoryPtr
    If iSize > 0
  
      For iIndex = 0 To g_VirtualFile\iMaxVirtualFiles - 1
        If VirtualFiles(iIndex)\bUsed = #False
        
          If bCopyBuffer
            *mem = AllocateMemory(iSize)
            If *mem
              
              CompilerIf #USE_VIRTUALFILE_SECURE_MEMORY
                SecureCopyMemory(*MemoryPtr, *mem, iSize)                
              CompilerElse  
                CopyMemory(*MemoryPtr, *mem, iSize)
              CompilerEndIf
            Else
              ProcedureReturn #E_OUTOFMEMORY
            EndIf 
          Else
            *mem = *MemoryPtr
          EndIf      
          
          hMutex = IndividualMutex_Create() ; 2011-03-06
          
          If hMutex ; 2011-03-06
            VirtualFiles(iIndex)\bused = #True
            VirtualFiles(iIndex)\bCanCreateNewHandles = #True
            VirtualFiles(iIndex)\qSize = iSize
            VirtualFiles(iIndex)\sFilename = sUniqueFilename
            VirtualFiles(iIndex)\BufferPtr =*mem
            VirtualFiles(iIndex)\iUseCount = 0
            VirtualFiles(iIndex)\bIsEncrypted = #False
            VirtualFiles(iIndex)\DecryptionBuffer = #Null
            VirtualFiles(iIndex)\bFreeBuffer = bCopyBuffer
            VirtualFiles(iIndex)\bDownloadFromURL = #False ; 2011-03-06
            VirtualFiles(iIndex)\iUniqueDownloadID = 0 ; 2011-03-06
            VirtualFiles(iIndex)\hMutex = hMutex
            iResult = #S_OK
            Break
          Else
            If *mem And bCopyBuffer ; 2011-03-06
              FreeMemory(*mem)
            EndIf  
            ProcedureReturn #E_OUTOFMEMORY ; 2011-03-06
          EndIf

        EndIf
      Next
  
    Else
      iResult = #E_INVALIDARG  
    EndIf
  Else
    iResult = #E_POINTER
  EndIf
  
  If iResult <> #S_OK
      __MyError("VirtualFile_CreateFromMemory failed with error code " + Str(iResult))    
  EndIf
  
  ProcedureReturn iResult
EndProcedure

Procedure.i __VirtualFile_RemoveFile(sUniqueFilename.s)
  Protected i.i
  
  ;-MUTEX Sperren?!?
  For i = 0 To g_VirtualFile\iMaxVirtualFiles - 1
    If VirtualFiles(i)\bUsed = #True
      If UCase(VirtualFiles(i)\sFileName) = UCase(sUniqueFilename) 

        If VirtualFiles(i)\iUseCount <= 0
          
            If IndividualMutex_TryLock(@VirtualFiles(i)\hMutex)  ;2011-03-06
              ; File is not used anymore and can be removed
              VirtualFiles(i)\bUsed = #False
              VirtualFiles(i)\bCanCreateNewHandles = #False
              VirtualFiles(i)\sFilename = ""
              VirtualFiles(i)\qSize = 0
              If VirtualFiles(i)\bFreeBuffer
                If VirtualFiles(i)\BufferPtr
                  FreeMemory(VirtualFiles(i)\BufferPtr)
                EndIf
                If VirtualFiles(i)\DecryptionBuffer
                  FreeMemory(VirtualFiles(i)\DecryptionBuffer)
                EndIf
              EndIf
              VirtualFiles(i)\DecryptionBuffer = #Null
              VirtualFiles(i)\BufferPtr = #Null
              VirtualFiles(i)\iUseCount = 0
              VirtualFiles(i)\bIsEncrypted = #False
              VirtualFiles(i)\bDownloadFromURL = #False ; 2011-03-06
              VirtualFiles(i)\iUniqueDownloadID = 0 ; 2011-03-06
              
              IndividualMutex_UnLock(@VirtualFiles(i)\hMutex)
              If VirtualFiles(i)\hMutex ; 2011-03-06
                IndividualMutex_Free(@VirtualFiles(i)\hMutex)
              EndIf      
              ProcedureReturn #S_OK              
            Else  ;2011-03-06
                VirtualFiles(i)\bCanCreateNewHandles = #False
                ProcedureReturn #E_ABORT              
            EndIf
          
            
        Else
          ;File cannot be removed, but no new handles will be generated
          VirtualFiles(i)\bCanCreateNewHandles = #False
          ProcedureReturn #E_ABORT
        EndIf

      EndIf
    EndIf
  Next
  ProcedureReturn #E_FAIL
EndProcedure

Procedure VritualFile_RenameFile(sUniqueFilename.s, sNewUniqueFilename.s)
  Protected i.i
  __MyDebug("VritualFile_RenameFile("+sUniqueFilename + "," + sNewUniqueFilename + ")")
  For i = 0 To g_VirtualFile\iMaxVirtualFiles - 1
    If VirtualFiles(i)\bUsed = #True
      If UCase(VirtualFiles(i)\sFileName) = UCase(sUniqueFilename) 
        __HookLogDebug("found file to rename...")
        VirtualFiles(i)\sFileName = sNewUniqueFilename
      EndIf
    EndIf
  Next  
EndProcedure

ProcedureDLL.i VirtualFile_RemoveFile(sUniqueFilename.s)
  Protected iResult
  __MyDebug("VirtualFile_RemoveFile("+sUniqueFilename+")")
  iResult = __VirtualFile_RemoveFile(sUniqueFilename.s)
  If iResult <> #S_OK
    __HookLogError("VirtualFile_RemoveFile Failed with error code "+Str(iResult))  
  EndIf
  ProcedureReturn iResult
EndProcedure

ProcedureDLL.i VirtualFile_AddEncryptedFile(sUniqueFilename.s, sExistingFile.s, *decryptionBuffer, iOffset.i, qOrgSize.q, bFreeDecryptionBuffer.i = #True, bDownloadFromURL.i = #False, iUniqueDownloadID = 0)
Protected iResult, iIndex.i, *mem, hMutex.i
Protected iFile
__MyDebug("VirtualFile_AddEncryptedFile(" + sUniqueFilename + "," + sExistingFile + "," + Hex(*decryptionBuffer) + "," +Str(iOffset) + "," + Str(qOrgSize) + "," +Str(bFreeDecryptionBuffer) + ")")
iResult = #E_FAIL
    If sUniqueFilename <> sExistingFile
      For iIndex = 0 To g_VirtualFile\iMaxVirtualFiles - 1
        If VirtualFiles(iIndex)\bUsed = #False    
          
          hMutex = IndividualMutex_Create()
          If hMutex
            
            
            ;################ WIN 8 TEST            
;             iFile = CreateFile(#PB_Any, sUniqueFilename)
;             WriteStringN(iFile, "THIS IS A PLACEHOLDER FOR A TEMPORARY VIDEO FILE...")
;             CloseFile(iFile)
            ;################ WIN 8 END
            
            VirtualFiles(iIndex)\bUsed = #True
            VirtualFiles(iIndex)\bCanCreateNewHandles = #True
            VirtualFiles(iIndex)\qSize = qOrgSize
            VirtualFiles(iIndex)\sFilename = sUniqueFilename
            VirtualFiles(iIndex)\sExistingFileName = sExistingFile
            VirtualFiles(iIndex)\BufferPtr = #Null
            VirtualFiles(iIndex)\iUseCount = 0
            VirtualFiles(iIndex)\bFreeBuffer = bFreeDecryptionBuffer
            VirtualFiles(iIndex)\bIsEncrypted = #True
            VirtualFiles(iIndex)\DecryptionBuffer = *decryptionBuffer
            VirtualFiles(iIndex)\iHeaderOffset = iOffset
            
            ;2011-03-04 added
            VirtualFiles(iIndex)\iUniqueDownloadID = iUniqueDownloadID
            VirtualFiles(iIndex)\bDownloadFromURL = bDownloadFromURL
            VirtualFiles(iIndex)\hMutex = hMutex ; 2011-03-06          
            iResult = #S_OK
          Else
            iResult = #E_OUTOFMEMORY
          EndIf
        
          Break
        EndIf
      Next
    EndIf
ProcedureReturn iResult
EndProcedure

ProcedureDLL VirtualFile_DeactivateHook(bImport.i = #True, bExport.i = #True)
  Protected bOk = #True
  __MyDebug("VirtualFile_DeactivateHook()")
  
  If g_VirtualFile\bReplaceCode = #False   
    
       If bImport And g_VirtualFile\bHookedImport = #False
        bOk = #False  
        __HookLogError("aborted because import table hook is already removed!")
      EndIf  
      If bExport And g_VirtualFile\bHookedExport = #False
        bOk = #False 
        __HookLogError("aborted because export table hook is already removed!")
      EndIf  
      
      If bOk
        __HookApi(GetKernelCoreFile(), "CreateFileA", g_VirtualFile\Hooks\OrgCreateFileA, bExport, bImport)
        __HookApi(GetKernelCoreFile(), "CreateFileW", g_VirtualFile\Hooks\OrgCreateFileW, bExport, bImport) 
        __HookApi(GetKernelCoreFile(), "ReadFile", g_VirtualFile\Hooks\OrgReadFile, bExport, bImport)
        ;__HookApi(GetKernelCoreFile(), "ReadFileEx", g_VirtualFile\Hooks\OrgReadFileEx, bExport, bImport)
        __HookApi(GetKernelCoreFile(), "SetFilePointer", g_VirtualFile\Hooks\OrgSetFilePointer, bExport, bImport)
        __HookApi(GetKernelCoreFile(), "SetFilePointerEx", g_VirtualFile\Hooks\OrgSetFilePointerEx, bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileSizeEx", g_VirtualFile\Hooks\OrgGetFileSizeEx, bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileSize", g_VirtualFile\Hooks\OrgGetFileSize, bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileType", g_VirtualFile\Hooks\OrgGetFileType, bExport, bImport)  
        __HookApi(GetKernelCoreFile(), "GetFileInformationByHandle", g_VirtualFile\Hooks\OrgGetFileInformationByHandle, bExport, bImport)
        
        __HookApi(GetKernelCoreHandle(), "CloseHandle", g_VirtualFile\Hooks\OrgCloseHandle, bExport, bImport)     
        __HookApi(GetKernelCoreHandle(), "DuplicateHandle",  g_VirtualFile\Hooks\OrgDuplicateHandle, bExport, bImport)  ; 2010-07-02
         
        ;2010-07-24
        __HookApi(GetKernelCoreFile(), "FindFirstFileA",  g_VirtualFile\Hooks\OrgFindFirstFileA, bExport, bImport) 
        __HookApi(GetKernelCoreFile(), "FindFirstFileW",  g_VirtualFile\Hooks\OrgFindFirstFileW, bExport, bImport)     
        __HookApi(GetKernelCoreFile(), "GetFileAttributesA",  g_VirtualFile\Hooks\OrgGetFileAttributesA, bExport, bImport) 
        __HookApi(GetKernelCoreFile(), "GetFileAttributesW",  g_VirtualFile\Hooks\OrgGetFileAttributesW, bExport, bImport)     
        __HookApi(GetKernelCoreFile(), "GetFileAttributesExA",  g_VirtualFile\Hooks\OrgGetFileAttributesExA, bExport, bImport) 
        __HookApi(GetKernelCoreFile(), "GetFileAttributesExW",  g_VirtualFile\Hooks\OrgGetFileAttributesExW, bExport, bImport)         
        
        If bImport
          g_VirtualFile\bHookedImport = #False
        EndIf  
        If bExport
          g_VirtualFile\bHookedExport = #False
        EndIf  
        
      EndIf
    Else
      ; Wird wahrscheinlich nicht mehr benötigt.... bitte Testen
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgCreateFileAData)
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgCreateFileWData)
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgReadFileData)
;       ;g_VirtualFile\Hooks\OrgReadFileExData)
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgSetFilePointerData)
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgSetFilePointerExData)
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgGetFileSizeExData)
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgGetFileSizeData)
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgGetFileTypeData)
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgGetFileInformationByHandleData)
;       CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgCloseHandleData)
;       ;CodeReplace_UnHookFunction(g_VirtualFile\Hooks\OrgDuplicateHandleData) 
    EndIf
EndProcedure


ProcedureDLL VirtualFile_ReactivateHook(bImport.i = #True, bExport.i = #True)
  Protected bOk = #True
  __MyDebug("VirtualFile_ReactivateHook()")
  
  If  g_VirtualFile\bReplaceCode = #False
    
      
      If bImport And g_VirtualFile\bHookedImport = #True
        bOk = #False  
        __HookLogError("aborted because import table is already hooked!")
      EndIf  
      If bExport And g_VirtualFile\bHookedExport = #True
        bOk = #False 
        __HookLogError("aborted because export table is already hooked!")
      EndIf  
    
      
      If bOk
        g_VirtualFile\bFirstFunctionModuleOutput = #True
        
        __HookApi(GetKernelCoreFile(), "CreateFileA", @__CreateFileA(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "CreateFileW", @__CreateFileW(), bExport, bImport) 
        __HookApi(GetKernelCoreFile(), "ReadFile", @__ReadFile(), bExport, bImport)
        ;__HookApi(GetKernelCoreFile(), "ReadFileEx", @__ReadFileEx(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "SetFilePointer", @__SetFilePointer(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "SetFilePointerEx", @__SetFilePointerEx(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileSizeEx", @__GetFileSizeEx(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileSize", @__GetFileSize(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileType", @__GetFileType(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileInformationByHandle", @__GetFileInformationByHandle(), bExport, bImport)
        
        __HookApi(GetKernelCoreHandle(), "CloseHandle", @__CloseHandle(), bExport, bImport)       
        __HookApi(GetKernelCoreHandle(), "DuplicateHandle",  @__DuplicateHandle(), bExport, bImport)  ; 2010-07-02
        
            
        ;2010-07-23
        __HookApi(GetKernelCoreFile(), "FindFirstFileA", @__FindFirstFileA(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "FindFirstFileW", @__FindFirstFileW(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileAttributesA", @__GetFileAttributesA(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileAttributesW", @__GetFileAttributesW(), bExport, bImport)  
        __HookApi(GetKernelCoreFile(), "GetFileAttributesExA", @__GetFileAttributesExA(), bExport, bImport)
        __HookApi(GetKernelCoreFile(), "GetFileAttributesExW", @__GetFileAttributesExW(), bExport, bImport)
        
        
        
        
        If bImport
          g_VirtualFile\bHookedImport = #True
        EndIf  
        If bExport
          g_VirtualFile\bHookedExport = #True
        EndIf
      EndIf
    Else
            ; Wird wahrscheinlich nicht mehr benötigt.... bitte Testen
;       g_VirtualFile\Hooks\OrgCreateFileAData = CodeReplace_HookApi("Kernel32.dll", "CreateFileA", @__CreateFileA())
;       g_VirtualFile\Hooks\OrgCreateFileWData = CodeReplace_HookApi("Kernel32.dll", "CreateFileW", @__CreateFileW()) 
;       g_VirtualFile\Hooks\OrgReadFileData =  CodeReplace_HookApi("Kernel32.dll", "ReadFile", @__ReadFile())
;       ;g_VirtualFile\Hooks\OrgReadFileExData =  CodeReplace_HookApi("Kernel32.dll", "ReadFileEx", @__ReadFileEx())
;       g_VirtualFile\Hooks\OrgSetFilePointerData =  CodeReplace_HookApi("Kernel32.dll", "SetFilePointer", @__SetFilePointer())
;       g_VirtualFile\Hooks\OrgSetFilePointerExData =  CodeReplace_HookApi("Kernel32.dll", "SetFilePointerEx", @__SetFilePointerEx())
;       g_VirtualFile\Hooks\OrgGetFileSizeExData =  CodeReplace_HookApi("Kernel32.dll", "GetFileSizeEx", @__GetFileSizeEx())
;       g_VirtualFile\Hooks\OrgGetFileSizeData =  CodeReplace_HookApi("Kernel32.dll", "GetFileSize", @__GetFileSize())
;       g_VirtualFile\Hooks\OrgGetFileTypeData =  CodeReplace_HookApi("Kernel32.dll", "GetFileType", @__GetFileType())
;       g_VirtualFile\Hooks\OrgGetFileInformationByHandleData =  CodeReplace_HookApi("Kernel32.dll", "GetFileInformationByHandle", @__GetFileInformationByHandle())
;       g_VirtualFile\Hooks\OrgCloseHandleData =  CodeReplace_HookApi("Kernel32.dll", "CloseHandle", @__CloseHandle())
;       ;g_VirtualFile\Hooks\OrgDuplicateHandleData =  CodeReplace_HookApi("Kernel32.dll", "DuplicateHandle", @__DuplicateHandle())   
;       
    EndIf
  
EndProcedure

ProcedureDLL VirtualFile_SetBlackList(sList.s) ; z.B. "[Test1.dll][Test2.dll]"
  g_VirtualFile\sModuleBlackList = sList
EndProcedure


CompilerIf #PB_Compiler_Thread = #False
  CompilerError "Enable Threadsafe"  
CompilerEndIf
; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 45
; FirstLine = 40
; Folding = ------------------
; EnableUnicode
; EnableThread
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
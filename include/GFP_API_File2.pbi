;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit






Prototype.i __API_SetFilePointerEx(hFile,liDistanceToMove.q,*lpNewFilePointer.quad,dwMoveMethod.i)

Procedure API_CreateFile(lpFileName.i, bMarkTemporary.i = #False) 
  Protected iFlags.i
  If bMarkTemporary
    iFlags = #FILE_ATTRIBUTE_NORMAL | #FILE_ATTRIBUTE_TEMPORARY
  Else
    iFlags = #FILE_ATTRIBUTE_NORMAL
  EndIf     
  ProcedureReturn CreateFile_(lpFileName, #GENERIC_READ | #GENERIC_WRITE, 0, #Null, #CREATE_ALWAYS, iFlags , #Null)
EndProcedure  

Procedure API_ReadFile(lpFileName.i)
   ProcedureReturn CreateFile_(lpFileName, #GENERIC_READ, #FILE_SHARE_READ, #Null, #OPEN_EXISTING, #FILE_ATTRIBUTE_NORMAL , #Null)
EndProcedure 

Procedure API_OpenFile(lpFileName.i, bMarkTemporary.i = #False)
  Protected iFlags.i
  If bMarkTemporary
    iFlags = #FILE_ATTRIBUTE_NORMAL | #FILE_ATTRIBUTE_TEMPORARY
  Else
    iFlags = #FILE_ATTRIBUTE_NORMAL
  EndIf       
  ProcedureReturn CreateFile_(lpFileName, #GENERIC_READ | #GENERIC_WRITE, 0, #Null, #OPEN_ALWAYS, iFlags , #Null)
EndProcedure 

Procedure API_CloseFile(hFile)  
  Protected bResult = #False
  If hFile
    bResult = CloseHandle_(hFile)
  EndIf  
  ProcedureReturn bResult
EndProcedure

Procedure.q API_GetFileSize(hFile)
  Protected sz.q = 0
  If hFile
    GetFileSizeEx_(hFile, @sz)
  EndIf
  ProcedureReturn sz
EndProcedure
  
Procedure API_WriteFileData(hFile, lpBuffer, nNumberOfBytesToWrite)
  Protected lpNumberOfBytesWritten.i = 0
  If hFile
    WriteFile_(hFile, lpBuffer, nNumberOfBytesToWrite, @lpNumberOfBytesWritten, #Null)
    FlushFileBuffers_(hFile)
  EndIf
  ProcedureReturn lpNumberOfBytesWritten
EndProcedure  

Procedure API_ReadFileData(hFile, lpBuffer, nNumberOfBytesToRead)
  Protected lpNumberOfBytesRead.i = 0
  If hFile
    ReadFile_(hFile, lpBuffer, nNumberOfBytesToRead, @lpNumberOfBytesRead, #Null)
  EndIf  
  ProcedureReturn lpNumberOfBytesRead
EndProcedure  

Procedure API_SeekFile(hFile, newPosition.q)
  Protected __SetFilePointerEx.__API_SetFilePointerEx, bResult = #False, hKernel32.i = #Null
  hKernel32 = GetModuleHandle_("Kernel32.dll")
  If hFile
    If hKernel32
      __SetFilePointerEx = GetProcAddress_(hKernel32, "SetFilePointerEx")
      If __SetFilePointerEx
        bResult = __SetFilePointerEx(hFile, newPosition, #Null, #FILE_BEGIN)
      EndIf
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure  

Procedure.q API_GetPosition(hFile)
  Protected __SetFilePointerEx.__API_SetFilePointerEx, qPosition.q = 0, hKernel32.i = #Null
  hKernel32 = GetModuleHandle_("Kernel32.dll")
  If hFile
    If hKernel32  
      __SetFilePointerEx = GetProcAddress_(hKernel32, "SetFilePointerEx")
      If __SetFilePointerEx
        __SetFilePointerEx(hFile, 0, @qPosition, #FILE_CURRENT)
      EndIf
    EndIf
  EndIf
  ProcedureReturn qPosition
EndProcedure  


; 
; hFile = CreateFile_("k:\Test.dat", #GENERIC_READ | #GENERIC_WRITE, 0, #Null, #CREATE_ALWAYS, #FILE_FLAG_POSIX_SEMANTICS , #Null)
; A$="ABCD"
; API_WriteFileData(hFile, @A$,4)
; API_CloseFile(hFile)
; 
; hFile = CreateFile_("k:\test.dat", #GENERIC_READ | #GENERIC_WRITE, 0, #Null, #CREATE_ALWAYS, #FILE_FLAG_POSIX_SEMANTICS , #Null)
; A$="1234"
; API_WriteFileData(hFile, @A$,4)
; API_CloseFile(hFile)
; 
; hFile = CreateFile_("k:\Test.dat", #GENERIC_READ, 0, #Null, #OPEN_EXISTING, #FILE_FLAG_POSIX_SEMANTICS , #Null)
; A$="   "
; API_ReadFileData(hFIle,@A$,4)
; Debug A$
; API_CloseFile(hFile)
; 



; hFile = API_CreateFile(@"H:\TEST.TXT")
; A$="teststring"
; API_WriteFileData(hFile, @A$,Len(A$))
; Debug API_GetPosition(hFile)
; API_SeekFile(hFile,1)
; Debug API_GetPosition(hFile)
; A$="11111"
; API_WriteFileData(hFile, @A$,Len(A$))
; Debug API_GetFileSize(hFile)
; API_CloseFile(hFile)
; 
; 
; 
; hFile = CreateFile_(@"\\.\PhysicalDrive0", 0, #FILE_SHARE_READ, #Null, #OPEN_EXISTING , 0 , #Null)
;   Debug hFile
;   
;   A$=Space(10000)
;   Debug API_ReadFileData(hFile,@A$,512*128)
;   Debug API_GetFileSize(hFIle)
  
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 127
; FirstLine = 66
; Folding = --
; EnableXP
; EnableCompileCount = 1
; EnableBuildCount = 0
; EnableExeConstant
;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

Structure STATSTG 
  *pwcsName
  type.l
  cbSize.q
  mtime.FILETIME
  ctime.FILETIME
  atime.FILETIME
  grfMode.l
  grfLocksSupported.l
  clsid.CLSID
  grfStateBits.l
  reserved.l
EndStructure

#STATFLAG_DEFAULT	= 0
#STATFLAG_NONAME	= 1
#STATFLAG_NOOPEN	= 2

#STGTY_STORAGE = 1
#STGTY_STREAM = 2
#STGTY_LOCKBYTES = 3
#STGTY_PROPERTY = 4

#STREAM_SEEK_SET = 0
#STREAM_SEEK_CUR = 1
#STREAM_SEEK_END = 2

Structure MEMORYSTREAM
  strm.IStream
  stat.STATSTG
  userData.i
  size.q
EndStructure

Procedure MEMORYSTREAM_Create()
  Protected *mem.MEMORYSTREAM, bResult = #False
  *mem.MEMORYSTREAM = AllocateMemory(SizeOf(MEMORYSTREAM))
  If *mem
    *mem\size = -1
    *mem\userData = 0
    *mem\strm = #Null
    CreateStreamOnHGlobal_(#Null, #True, @*mem\strm)
    If *mem\strm
      bResult = #True
    EndIf  
  EndIf  
  If bResult = #False
    If *mem
      FreeMemory(*mem)
      *mem = #Null
    EndIf  
  EndIf
  ProcedureReturn *mem
EndProcedure

Procedure MEMORYSTREAM_CreateFromPointer(*buffer, size)
  Protected *mem.MEMORYSTREAM, bResult = #False, retSize = 0
  If *buffer And size > 0
    *mem.MEMORYSTREAM = MEMORYSTREAM_Create()
    If *mem
      If *mem\strm
        *mem\strm\Write(*buffer, size, @retSize)
        If retSize = size
          bResult = #True
        EndIf
      EndIf
    EndIf   
  EndIf
  
  If bResult = #False
    If *mem
      If *mem\strm
        *mem\strm\Release()
        *mem\strm = #Null
      EndIf  
      FreeMemory(*mem)
      *mem = #Null
    EndIf  
  EndIf  
  ProcedureReturn *mem
EndProcedure


Procedure MEMORYSTREAM_Free(*mem.MEMORYSTREAM)
  If *mem
    If *mem\strm
      *mem\strm\Release()
      *mem\strm = #Null
    EndIf  
    FreeMemory(*mem)
    *mem = #Null
  EndIf  
EndProcedure

Procedure MEMORYSTREAM_SetUserData(*mem.MEMORYSTREAM, userData)
  If *mem
    *mem\userData = userData
    ProcedureReturn #True  
  EndIf  
  ProcedureReturn #False
EndProcedure

Procedure MEMORYSTREAM_GetUserData(*mem.MEMORYSTREAM)
  If *mem
    ProcedureReturn *mem\userData 
  EndIf  
  ProcedureReturn 0
EndProcedure

Procedure.q MEMORYSTREAM_GetSize(*mem.MEMORYSTREAM)
  If *mem
    If *mem\size = -1
      If *mem\strm
        If *mem\strm\Stat(@*mem\stat, #STATFLAG_NONAME) = #S_OK
          *mem\size = *mem\stat\cbSize
        EndIf  
      EndIf  
    EndIf
    ProcedureReturn *mem\size
  EndIf  
  ProcedureReturn -1
EndProcedure

Procedure MEMORYSTREAM_SetSize(*mem.MEMORYSTREAM, newSize.q)
  Protected bResult = #False
  If *mem
      If *mem\strm
        If *mem\strm\SetSize(newSize) = #S_OK
          *mem\size = newSize
          bResult = #True
        EndIf  
      EndIf  
   EndIf
   ProcedureReturn bResult 
EndProcedure

Procedure MEMORYSTREAM_Read(*mem.MEMORYSTREAM, *buffer, size.q)
  Protected iResult.i = 0
  If *mem And *buffer
      If *mem\strm
        *mem\strm\Read(*buffer, size, @iResult)
      EndIf  
   EndIf
   ProcedureReturn iResult 
EndProcedure

Procedure MEMORYSTREAM_Write(*mem.MEMORYSTREAM, *buffer, size.i)
  Protected iResult.i = 0
  If *mem And *buffer
      If *mem\strm
        *mem\strm\write(*buffer, size, @iResult) 
        *mem\size = -1
      EndIf  
   EndIf
   ProcedureReturn iResult 
EndProcedure

Procedure.q MEMORYSTREAM_GetPosition(*mem.MEMORYSTREAM)
  Protected qResult = -1
  If *mem
      If *mem\strm
        If *mem\strm\Seek(0, #STREAM_SEEK_CUR, @qResult) <> #S_OK
          qResult = -1
        EndIf  
      EndIf  
   EndIf
   ProcedureReturn qResult 
EndProcedure

Procedure.q MEMORYSTREAM_SetPosition(*mem.MEMORYSTREAM, position.q)
  Protected bResult = #False
  If *mem
      If *mem\strm
        If *mem\strm\Seek(position, #STREAM_SEEK_SET, #Null)
          bResult = #True
        EndIf  
      EndIf  
   EndIf
   ProcedureReturn bResult 
 EndProcedure
 
Procedure MEMORYSTREAM_ReadPos(*mem.MEMORYSTREAM, position.q, *buffer, size.q)
  Protected iResult.i = 0, qLastPos.q = 0
  qLastPos = MEMORYSTREAM_GetPosition(*mem)
  If qLastPos <> -1
    iResult = MEMORYSTREAM_Read(*mem, *buffer, size)
    MEMORYSTREAM_SetPosition(*mem, qLastPos)
  EndIf
  ProcedureReturn iResult 
EndProcedure

Procedure MEMORYSTREAM_WritePos(*mem.MEMORYSTREAM, position.q, *buffer, size.q)
  Protected iResult.i = 0, qLastPos.q = 0
  qLastPos = MEMORYSTREAM_GetPosition(*mem)
  If qLastPos <> -1
    iResult = MEMORYSTREAM_Write(*mem, *buffer, size)
    MEMORYSTREAM_SetPosition(*mem, qLastPos)
  EndIf
  ProcedureReturn iResult 
EndProcedure

Procedure.q MEMORYSTREAM_GetBufferSize(*mem.MEMORYSTREAM)
  Protected size.q, hGlobal
  If *mem
    If *mem\strm
      GetHGlobalFromStream_(*mem\strm, @hGlobal)
      If hGlobal
        size = GlobalSize_(hGlobal)
      EndIf
    EndIf  
  EndIf
  ProcedureReturn size
EndProcedure

Procedure MEMORYSTREAM_LockBuffer(*mem.MEMORYSTREAM)
  Protected *ptr = #Null, hGlobal
  If *mem
    If *mem\strm
      GetHGlobalFromStream_(*mem\strm, @hGlobal)
      If hGlobal
        *ptr = GlobalLock_(hGlobal)
      EndIf
    EndIf  
  EndIf
  ProcedureReturn *ptr 
EndProcedure

Procedure MEMORYSTREAM_UnLockBuffer(*mem.MEMORYSTREAM)
  Protected bResult = #False, hGlobal
  If *mem
    If *mem\strm
      GetHGlobalFromStream_(*mem\strm, @hGlobal)
      If hGlobal
        If GlobalUnlock_(hGlobal)
          bResult = #True
        EndIf  
      EndIf
    EndIf  
  EndIf
  ProcedureReturn bResult 
EndProcedure

Procedure MEMORYSTREAM_CopyToFile(*mem.MEMORYSTREAM, hFile.i, size.i = -1)
  Protected bResult = 0, hGlobal, *ptr, iResult
  If *mem And hFile And (size > 0 Or size = -1)
    If *mem\strm
      GetHGlobalFromStream_(*mem\strm, @hGlobal)
      If hGlobal
        *ptr = GlobalLock_(hGlobal)
        If size = -1
          size = GlobalSize_(hGlobal)         
        EndIf   
        If size > GlobalSize_(hGlobal)
          size = GlobalSize_(hGlobal)
        EndIf  
      If *ptr
        WriteFile_(hFile, *ptr, size, @iResult, #Null)
      EndIf  
      GlobalUnlock_(hGlobal)
      EndIf
    EndIf  
  EndIf
  ProcedureReturn iResult 
EndProcedure
 
 Procedure MEMORYSTREAM_CopyFromFile(*mem.MEMORYSTREAM, hFile, size.i = -1)
  Protected iResult = 0, hGlobal, *ptr
  If *mem And hFile And size > 0
    If *mem\strm
        *mem\size = -1
        If size = -1
          GetFileSizeEx_(hFile, @size)
        EndIf  
        If *mem\strm\SetSize(size) = #S_OK
          GetHGlobalFromStream_(*mem\strm, @hGlobal)
          If hGlobal
            *ptr = GlobalLock_(hGlobal)
            If *ptr
              ReadFile_(hFile, *ptr, GlobalSize_(hGlobal), @iResult, #Null)
              GlobalUnlock_(hGlobal)
            EndIf
          EndIf
          *mem\strm\SetSize(iResult)
        EndIf
    EndIf  
   EndIf
   ProcedureReturn iResult 
 EndProcedure
 
 
;  strm = MEMORYSTREAM_Create()
;  Debug strm
; A$="TEST 1"+Chr(13)
; MEMORYSTREAM_Write(strm, @A$, Len(A$))
; 
; 
; Debug MEMORYSTREAM_GetPosition(strm)
; A$="TEST 2"+Chr(13)
; MEMORYSTREAM_Write(strm, @A$, Len(A$))
; 
; 
; 
; CreateFile(1,"D:\test.txt")
; MEMORYSTREAM_CopyToFile(strm, FileID(1))
; CloseFile(1)
; 
; 

  
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 308
; FirstLine = 256
; Folding = ----
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
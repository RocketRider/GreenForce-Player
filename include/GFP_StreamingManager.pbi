;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************


;XIncludeFile "GFP_BIT_HELPER.pbi"
XIncludeFile "GFP_MultipleReadExclusiveWrite_Mutex.pbi"
XIncludeFile "GFP_WINHTTP55.pbi"
EnableExplicit
Global STREAMING_BLOCK_SIZE.i = 1024*150;Darf nicht während dem Herunterladen geändert werden
Global StreamingThreadsNotEnd.i=#False
#STREAMING_CACHE_SUFFIX = "_dw"
#STREAMING_THREADS = 2
#STREAMING_LOCK_DOWNLOAD_THREADS = #True
#STREAMING_BUFFERING_COUNT = 15

Structure StreamingThread
  *File.StreamingFile
  Thread.i
  ThreadID.i
EndStructure  


Structure StreamingFile
  handle.i
  *filename
  size.q
  *blocks
  blockCount.i
  *URL
  *thread.StreamingThread[#STREAMING_THREADS]
  blockAddCounter.i
  Streaming_Mutex.i
  DownloadBlock_Mutex.i
  endThread_Mutex.i
  lastDownloadedBlock.i
  lastDownloadedBlock_Mutex.i
  Connection.i[#STREAMING_THREADS+1]
  ;2011-03-07
  hLockThreadMutex.i
EndStructure  

Declare EndStreamingThreads(*file.StreamingFile)



Macro __StreamingDebug(sText)
 ;Debug sText
 WriteLog(sText, #LOGLEVEL_DEBUG)
EndMacro

Macro __StreamingError(sText)
 ;Debug sText
 WriteLog(sText, #LOGLEVEL_ERROR)
EndMacro


;USED IN VIRTUAL FILES OR THREAD!!!
Macro _StreamingDebug(sText)
  CompilerIf #USE_BUGGY_VIRTUALFILE_LOGGING
  ;  Debug sText
    WriteLog(sText, #LOGLEVEL_DEBUG)
  CompilerEndIf
EndMacro
Macro _StreamingError(sText)
  CompilerIf #USE_BUGGY_VIRTUALFILE_LOGGING
;    Debug sText
   WriteLog(sText, #LOGLEVEL_ERROR)
  CompilerEndIf
EndMacro



#BLOCK_UNINITALIZED = -1
#BLOCK_PENDING = -2


Procedure.l GetBlockPos(*file.StreamingFile, block.i)
  Protected result.l, bOk.i = #False
  If *file
    If block >= 0 And block < *file\blockCount
      MREWMUTEX_LockRead(*file\DownloadBlock_Mutex)      
      result = PeekL(*file\blocks + block * SizeOf(long))
      bOk = #True
      MREWMUTEX_UnLockRead(*file\DownloadBlock_Mutex)
    EndIf   
  EndIf  
  If bOk = #False
   _StreamingError("GetBlockPos failed!!! "+Str(block))    
  EndIf  
  ProcedureReturn result
EndProcedure

Procedure SetBlockPos(*file.StreamingFile, block.i, Pos.l)
  Protected bOk.i = #False
  If *file  
    If block >= 0 And block < *file\blockCount    
      MREWMUTEX_LockWrite(*file\DownloadBlock_Mutex)
      PokeL(*file\blocks + block * SizeOf(long), Pos.l)
      bOk = #True
      MREWMUTEX_UnLockWrite(*file\DownloadBlock_Mutex)      
    EndIf
  EndIf  
  If bOk = #False
   _StreamingError("SetBlockPos failed!!!")    
  EndIf  
  ProcedureReturn bOk
EndProcedure

Procedure CheckSetBlockPos(*file.StreamingFile, block.i, Pos.l, Check.l)
  Protected result.i
  If *file
    MREWMUTEX_LockWrite(*file\DownloadBlock_Mutex)
      If PeekL(*file\blocks+block*SizeOf(long))=Check
        result=PokeL(*file\blocks+block*SizeOf(long), Pos.l)
      Else
        result=#False
      EndIf  
    MREWMUTEX_UnLockWrite(*file\DownloadBlock_Mutex)
  EndIf  
  ProcedureReturn result
EndProcedure



Procedure.i GetLastDLBlock(*file.StreamingFile)
  Protected result.i
  If *file
    MREWMUTEX_LockRead(*file\lastDownloadedBlock_Mutex)
      result=*file\lastDownloadedBlock
    MREWMUTEX_UnLockRead(*file\lastDownloadedBlock_Mutex)
  EndIf  
  ProcedureReturn result
EndProcedure

Procedure SetLastDLBlock(*file.StreamingFile, block.i)
  Protected result.i
  If *file
    MREWMUTEX_LockWrite(*file\lastDownloadedBlock_Mutex)
      *file\lastDownloadedBlock=block
      result=#True
    MREWMUTEX_UnLockWrite(*file\lastDownloadedBlock_Mutex)
  EndIf  
  ProcedureReturn result
EndProcedure



;Läd einen bestimten Block herunter
Procedure DownloadBlock(*file.StreamingFile, block.i, Connection.i)
  Protected result.i=#False, blockAdd.q, startPos.q, endPos.q, size.q, *DLData
  If *file
    _StreamingDebug("Download block "+Str(block) +" Con: "+Str(Connection))

    If Connection=0
      SetLastDLBlock(*file, block)
    EndIf  
        
    startPos=STREAMING_BLOCK_SIZE*block
    endPos=startPos+STREAMING_BLOCK_SIZE -1  

    result=HTTPCONTEXT_Download(*file\Connection[Connection], #True, startPos.q, endPos.q, @*DLData, @size)
    
    If result And *DLData And size>0
    Else  
      _StreamingError("Download block "+Str(block)+" second try!")
      If *dLData
        GlobalFree_(*dLData)
        *dLData=#Null
      EndIf 
      size=0
      result=HTTPCONTEXT_Download(*file\Connection[Connection], #True, startPos.q, endPos.q, @*DLData, @size)
    EndIf  
    
    If result And *DLData And size>0
      MREWMUTEX_LockWrite(*file\Streaming_Mutex)
      blockAdd=*file\blockAddCounter
      *file\blockAddCounter+1
      
      SetBlockPos(*file, block, blockAdd)
      API_SeekFile(*file\handle, blockAdd * STREAMING_BLOCK_SIZE)
      API_WriteFileData(*file\handle, *DLData, size)
      MREWMUTEX_UnLockWrite(*file\Streaming_Mutex)
    Else
      _StreamingError("Download block failed"+Str(block))
      SetBlockPos(*file, block, #BLOCK_UNINITALIZED)
    EndIf 
    
    If *dLData
      GlobalFree_(*dLData)
    EndIf  
    
  Else
    SetBlockPos(*file, block, #BLOCK_UNINITALIZED)
  EndIf
  ProcedureReturn result
EndProcedure



;Überprüft ob der Bereich schon heruntergeladen wurde, wenn nicht läd es ihn direkt herunter
Procedure WaitBlockAvailable(*file.StreamingFile, offset.q, len.q)
  Protected IsAvailable.i, startpos.i, endpos.i, block.i
  If *file
    IsAvailable=#True
    startpos=Int(offset/STREAMING_BLOCK_SIZE)
    endpos=Int((offset+len)/STREAMING_BLOCK_SIZE)
    
    For block=startpos To endpos
      If block<*file\blockCount
        
        If CheckSetBlockPos(*file, block, #BLOCK_PENDING, #BLOCK_UNINITALIZED)
          ;Debug "MUST DOWNLOAD BLOCK "+Str(block)
          
          ;Thread bremse an
          If *file\hLockThreadMutex
            LockMutex(*file\hLockThreadMutex)
          EndIf  
          
          If Not DownloadBlock(*file, block, 0)
            IsAvailable.i=#False
            _StreamingError("File part can not be downloaded")
          EndIf  
          
          ;Thread bremse aus          
          If *file\hLockThreadMutex
            UnlockMutex(*file\hLockThreadMutex)
          EndIf  
          
        Else
          TIMER_BeginBackgroundMode()
          While (GetBlockPos(*file, block)=#BLOCK_PENDING)
            ;Debug "MUST WAIT FOR BLOCK "+Str(block)
            ;Delay(1)
            TIMER_Wait(1000)
            ;Debug "WAIT..."
          Wend  
          TIMER_EndBackgroundMode()
          If GetBlockPos(*file, block)<0
            IsAvailable.i=#False
            _StreamingError("File part is not downloaded!!!")
          EndIf  
          
        EndIf  
      EndIf
    Next
  EndIf
  ProcedureReturn IsAvailable
EndProcedure  


Procedure __ReadDataOfBlock(*file.StreamingFile, block, *memBufferInBlock, offsetInBlock.q, lengthInBlock.q)
  Protected BlockBase.q, readed = 0
  BlockBase = GetBlockPos(*file, block) * STREAMING_BLOCK_SIZE 
  MREWMUTEX_LockRead(*file\Streaming_Mutex)
  If Not BlockBase = #BLOCK_UNINITALIZED
    API_SeekFile(*file\handle, BlockBase + offsetInBlock)
    readed = API_ReadFileData(*file\handle, *memBufferInBlock, lengthInBlock)    
  Else
    _StreamingError("File part to read is not downloaded")    
  EndIf
  MREWMUTEX_UnLockRead(*file\Streaming_Mutex)
  ProcedureReturn readed
EndProcedure  



;Ließt den Speziellen Bereich aus den Datei Blöcken in den RAM
Procedure.i _ReadData(*file.StreamingFile, *memBuffer, offset.q, length.i)
  Protected startpos.i, endpos.i, block.i, readed.i = 0, rest.i, offsetInBlock.i, lengthInBlock.i
  If *file   
    If length > 0     
      startpos = Int(offset / STREAMING_BLOCK_SIZE)
      endpos = Int((offset+length) / STREAMING_BLOCK_SIZE)
      
      rest = length
      
      offsetInBlock = offset % STREAMING_BLOCK_SIZE
      lengthInBlock = STREAMING_BLOCK_SIZE - (offset % STREAMING_BLOCK_SIZE)
      If rest < lengthInBlock
        lengthInBlock = rest  
      EndIf
      
      For block = startpos To endpos    
        readed + __ReadDataOfBlock(*file, block, *memBuffer, offsetInBlock, lengthInBlock)
        rest - lengthInBlock
        *memBuffer + lengthInBlock
        If rest >= STREAMING_BLOCK_SIZE
          lengthInBlock = STREAMING_BLOCK_SIZE
        Else
          lengthInBlock = rest 
        EndIf  
        offsetInBlock = 0
        
      Next     
    Else
      _StreamingError("length is less than 1 in _ReadData!")         
    EndIf
  Else
    _StreamingError("StreamingFile object is null!")      
  EndIf  
  ProcedureReturn readed
EndProcedure



;Wird von Virtual File zum auslesen der Datei verwendet.
Procedure ReadBytes(*file.StreamingFile, *ptrData, offset.q, len.q, *readedBytes)
  Protected result.i = #False, readedBytes.q
  ;Debug "read "+Str(offset)+"-"+Str(len)
  If *file And *ptrData And len > 0
    If *file\size > offset
      If WaitBlockAvailable(*file, offset.q, len.q)
        readedBytes = _ReadData(*file, *ptrData, offset, len)

        If *readedBytes
          PokeL(*readedBytes, readedBytes)
        EndIf
        If readedBytes > 0
          result = #True
        EndIf            
      Else
        ;Ist nicht vorhanden und konnte auch nicht herunter geladen werden!!!
        _StreamingError("Block can't downloaded!")
      EndIf  

    Else
      _StreamingError("Offset is not part of the file")
    EndIf
  Else
    _StreamingError("Can't read from null pointer")
  EndIf  
  ProcedureReturn result
EndProcedure  



Procedure.q GetStramingFileSize(*file.StreamingFile)
  If *file
    ProcedureReturn *file\size
  EndIf  
EndProcedure


;Ein Thread der im Hintergrund die nächsten Teile der Datei herunterläd
Procedure StreamingDownloadThread(*StreamingThreadData.StreamingThread)
  Protected block.i, allBlocksDownloaded.i, *file.StreamingFile, numThread.i, AllBlocksChecked.i, lock.i
  *file = *StreamingThreadData\File
  numThread = *StreamingThreadData\Thread
  !PAUSE
  Repeat  
    !PAUSE 
    
    If *file\hLockThreadMutex
      lock = TryLockMutex(*file\hLockThreadMutex)
      If lock
        UnlockMutex(*file\hLockThreadMutex) ; WICHTIG!!!: gleich wieder freigeben (sonst = bremse)
      EndIf 
    Else
      lock = #True
    EndIf  
    
    If lock
      block = GetLastDLBlock(*file)
      AllBlocksChecked=#False
      Repeat
        block+1
        If block>=*file\blockCount And AllBlocksChecked=#False
          AllBlocksChecked=#True
          block=0
        EndIf
      Until GetBlockPos(*file, block) = #BLOCK_UNINITALIZED Or (block>=*file\blockCount-1 And AllBlocksChecked)
      
      If CheckSetBlockPos(*file, block, #BLOCK_PENDING, #BLOCK_UNINITALIZED)
        If Not DownloadBlock(*file, block, numThread+1)
          _StreamingError("File part can not be downloaded in thread")
        EndIf  
      EndIf  
      
      If block>=*file\blockCount-1 And AllBlocksChecked
        allBlocksDownloaded=#True
      EndIf
    EndIf  
      
      
    If TryLockMutex(*file\endThread_Mutex)
      UnlockMutex(*file\endThread_Mutex) ; 2011-03-04
      _StreamingDebug("Thread will be stopped")
      ProcedureReturn 0      
    EndIf    
    
    If lock = #False
      ;Debug "Thread must wait"
      ;Delay(1)
      TIMER_Wait(1000)
    EndIf  
    
  Until allBlocksDownloaded  
  _StreamingDebug("All blocks are downloaded")
EndProcedure




;Befehl wird nicht über Virtual File verwendet, sondern nur zum erstellen einer neuen Datei.
Procedure CreateStreamingFile(file.s, URL.s, Agent.s)
  Protected *file.StreamingFile, result.i, i.i, cacheFile.i, size.q, cacheFileName.s, *ThreadData.StreamingThread, hMutex.i
  Protected  proxy.s, bypassLocal, useIESettings, noRedirect, EndLoop.i, ConFailed.i
  *file = AllocateMemory(SizeOf(StreamingFile))
  If *file

    *file\handle = API_OpenFile(@File, #True)
    If *file\handle
      
      For i=0 To #STREAMING_THREADS-1
        EndLoop=#False
        Repeat
          If *file\Connection[i]
            HTTPCONTEXT_Close(*file\Connection[i])
            *file\Connection[i]=#Null
          EndIf  
          
          
          If Settings(#SETTINGS_PROXY)\sValue<>"" And Settings(#SETTINGS_PROXY_PORT)\sValue<>""
            Proxy=Settings(#SETTINGS_PROXY)\sValue+":"+Settings(#SETTINGS_PROXY_PORT)\sValue
          Else  
            Proxy.s=""
          EndIf  
          bypassLocal=Val(Settings(#SETTINGS_PROXY_BYPASS_LOCAL)\sValue)
          useIESettings=Val(Settings(#SETTINGS_PROXY_USE_IE_SETTINGS)\sValue)
          noRedirect=Val(Settings(#SETTINGS_PROXY_NoRedirect)\sValue)
          
          *file\Connection[i] = HTTPCONTEXT_OpenURL(URL, Agent, #True, proxy, bypassLocal, #False, useIESettings, noRedirect)
          
          If i=0
            If *file\Connection[0]
              size = HTTPCONTEXT_QuerySize(*file\Connection[0]) 
            EndIf     
          EndIf
          
          If size>0
            EndLoop=#True
          ElseIf ConFailed=#False  
            If ConnectionFailedRequester()=#False
              ConFailed=#True
              EndLoop=#True
            EndIf  
          EndIf  
            
        Until EndLoop=#True Or ConFailed=#True
        If Not *file\Connection[i]
          __StreamingError("Can't Connect to Server ["+Str(i)+"]")
          result = #False
          Break
        EndIf
      Next
      


      *file\size = size
      If *file\size>0

        
        ;2011-03-04 Exakten blockcount ermitteln
        *file\blockCount = *file\size / STREAMING_BLOCK_SIZE
        If *file\size % STREAMING_BLOCK_SIZE
          *file\blockCount + 1
        EndIf  
        

        *file\blocks = AllocateMemory(*file\blockCount * SizeOf(long))
        *file\blockAddCounter = 0
        
        CompilerIf #STREAMING_LOCK_DOWNLOAD_THREADS
          *file\hLockThreadMutex = CreateMutex() ; 2011-03-07 ist egal, wenn fehlschlägt
        CompilerEndIf
        
        If *file\blocks
          For i.i=0 To *file\blockCount - 1 ;2011-03-04 
            PokeL(*file\blocks + i * SizeOf(long), #BLOCK_UNINITALIZED)
          Next  
          
          ;read Cache file if available
          cacheFileName=file + #STREAMING_CACHE_SUFFIX
          cacheFile = API_ReadFile(@cacheFileName)  
          If cacheFile
            If *file\blockCount * SizeOf(long) + SizeOf(long) = API_GetFileSize(cacheFile) And API_GetFileSize(*file\handle)>0
              API_ReadFileData(cacheFile, @*file\blockAddCounter, SizeOf(long))
              API_ReadFileData(cacheFile, *file\blocks, *file\blockCount * SizeOf(long))
            Else
              __StreamingError("Cachefile size is incorrect!")
            EndIf
            API_CloseFile(cacheFile) 
          EndIf
          
          
          *file\URL = AllocateMemory(StringByteLength(URL) + SizeOf(Character))
          If *file\URL
            If PokeS(*file\URL, URL)
              
              *file\filename = AllocateMemory(StringByteLength(file) + SizeOf(Character))
              If *file\filename
                If PokeS(*file\filename, file)
                  
                  *file\Streaming_Mutex = MREWMUTEX_Create()
                  *file\DownloadBlock_Mutex = MREWMUTEX_Create()
                  *file\lastDownloadedBlock_Mutex = MREWMUTEX_Create()
                  *file\endThread_Mutex = CreateMutex()
                  If *file\Streaming_Mutex And *file\DownloadBlock_Mutex And *file\endThread_Mutex And *file\lastDownloadedBlock_Mutex
                    LockMutex(*file\endThread_Mutex) ; 2011-03-04 
                    result = #True
                  Else
                    __StreamingError("Can't create Mutex")
                  EndIf  
                EndIf
              Else
                __StreamingError("Can't allocate memory (filename)")
              EndIf
              
            Else
              __StreamingError("Can't PokeS(URL)")
            EndIf  
          Else
            __StreamingError("Can't allocate memory (URL)")
          EndIf  
        Else
          __StreamingError("Can't allocate memory (blocks)")
        EndIf 
        
      Else
        __StreamingError("size is null")
      EndIf 
    Else
      __StreamingError("Can't create file")
    EndIf
  Else
    __StreamingError("Can't allocate memory (Streamingfile)")
  EndIf
  
  If result
    For i=0 To #STREAMING_THREADS-1
      *ThreadData=AllocateMemory(SizeOf(StreamingThread))
      If *ThreadData
        *ThreadData\File=*file
        *ThreadData\Thread=i
        *ThreadData\ThreadID=CreateThread(@StreamingDownloadThread(), *ThreadData)
        *file\thread[i] = *ThreadData
        If Not *ThreadData\ThreadID
          result = #False
        EndIf
      Else
        __StreamingError("Can't allocate memory (ThreadData)")
      EndIf
    Next
  EndIf
  
  If result
    ProcedureReturn *file
  Else
    __StreamingError("Can't create streaming file")
    If *file
      
      If Not EndStreamingThreads(*file)
        ProcedureReturn 0
      EndIf 
      
      ;Thread blockier Mutex freigeben
      hMutex = *file\hLockThreadMutex
      If hMutex
        LockMutex(hMutex)
        *file\hLockThreadMutex = #Null
        UnlockMutex(hMutex)
        FreeMutex(hMutex)
      EndIf
      
      If *file\handle
        API_CloseFile(*file\handle) 
      EndIf
      If *file\blocks
        FreeMemory(*file\blocks)
      EndIf
      If *file\URL
        FreeMemory(*file\URL)
      EndIf
      If *file\filename
        FreeMemory(*file\filename)
      EndIf      
      
      If *file\Streaming_Mutex
        MREWMUTEX_Free(*file\Streaming_Mutex)
      EndIf  
      If *file\DownloadBlock_Mutex
        MREWMUTEX_Free(*file\DownloadBlock_Mutex)
      EndIf 
      If *file\endThread_Mutex
        FreeMutex(*file\endThread_Mutex)
      EndIf  
      If *file\lastDownloadedBlock_Mutex
        MREWMUTEX_Free(*file\lastDownloadedBlock_Mutex)
      EndIf  
      For i=0 To #STREAMING_THREADS-1
        If *file\Connection[i]
          HTTPCONTEXT_Close(*file\Connection[i])
          *file\Connection[i]=#Null
        EndIf  
      Next
      
      FreeMemory(*file)
    EndIf
    ProcedureReturn #Null
  EndIf  
EndProcedure



Procedure EndStreamingThreads(*file.StreamingFile)
  Protected i.i, Count.i
  If *file
    If *file\endThread_Mutex
      UnlockMutex(*file\endThread_Mutex)
    EndIf   
    
    For i=0 To #STREAMING_THREADS-1
      If *file\thread[i]
        If *file\thread[i]\ThreadID And IsThread(*file\thread[i]\ThreadID)
          Count=0
          Repeat
            Count+1
            Delay(10)
          Until count>=250 Or Not IsThread(*file\thread[i]\ThreadID)  
          If IsThread(*file\thread[i]\ThreadID)
            StreamingThreadsNotEnd=#True
            __StreamingError("Thread " +Str(i)+ " doesn't end, memory is not free!!!")
            ProcedureReturn #False
          EndIf  
        Else
          __StreamingDebug("thread " +Str(i)+ " is not active")
        EndIf
        FreeMemory(*file\thread[i])
      EndIf
    Next
  EndIf  
  ProcedureReturn #True
EndProcedure  

;Befehl wird nicht über Virtual File verwendet, sondern nur zum freigeben einer Datei.
Procedure FreeStreamingFile(*file.StreamingFile, saveCache.i = #True)
  Protected result.i = #True, Count.i=0, cacheFile.i, file.s, i.i, hMutex.i
  If *file

    
    If Not EndStreamingThreads(*file)
      ProcedureReturn 0
    EndIf  
    

    If saveCache And *file\blockAddCounter And *file\blocks
      MREWMUTEX_LockWrite(*file\DownloadBlock_Mutex)
      file=PeekS(*file\filename)+#STREAMING_CACHE_SUFFIX
      cacheFile=API_CreateFile(@file)
      If cacheFile
        API_WriteFileData(cacheFile, @*file\blockAddCounter, SizeOf(long))
        API_WriteFileData(cacheFile, *file\blocks, *file\blockCount*SizeOf(long))
        API_CloseFile(cacheFile) 
      Else
        __StreamingError("Can't create cache file")
      EndIf
      MREWMUTEX_UnLockWrite(*file\DownloadBlock_Mutex)
    EndIf  
    
    ;Thread blockier Mutex freigeben
    hMutex = *file\hLockThreadMutex
    If hMutex
      LockMutex(hMutex)
      *file\hLockThreadMutex = #Null
      UnlockMutex(hMutex)
      FreeMutex(hMutex)
    EndIf
        
    
    If *file\handle
      API_CloseFile(*file\handle) 
    Else
      __StreamingError("No file handle")
      result=#False
    EndIf
    If Not saveCache
      file=PeekS(*file\filename)
      DeleteFile(file)
    EndIf  
    
    If *file\blocks
      FreeMemory(*file\blocks)
    Else  
      __StreamingError("No block memory")
      result=#False
    EndIf  

    If *file\URL
      FreeMemory(*file\URL)
    Else  
      __StreamingError("No url memory")
      result=#False
    EndIf 
    If *file\filename
      FreeMemory(*file\filename)
    Else
      __StreamingError("No filename memory")
      result=#False
    EndIf   

    If *file\Streaming_Mutex
      MREWMUTEX_Free(*file\Streaming_Mutex)
    Else  
      __StreamingError("No Streaming_Mutex")
      result=#False
    EndIf  

    If *file\DownloadBlock_Mutex
      MREWMUTEX_Free(*file\DownloadBlock_Mutex)
    Else  
      __StreamingError("No DownloadBlock Mutex")
      result=#False
    EndIf 

    If *file\endThread_Mutex
      FreeMutex(*file\endThread_Mutex)
    Else  
      __StreamingError("No endThread Mutex")
      result=#False
    EndIf  
    
    If *file\lastDownloadedBlock_Mutex
      MREWMUTEX_Free(*file\lastDownloadedBlock_Mutex)
    Else  
      __StreamingError("No lastDownloadedBlock Mutex")
      result=#False
    EndIf  
    
    For i=0 To #STREAMING_THREADS-1
      If *file\Connection[i]
        HTTPCONTEXT_Close(*file\Connection[i])
      Else  
        __StreamingError("No Connection ["+Str(i)+"]")
        result=#False
      EndIf  
    Next
    
    
    FreeMemory(*file)
  Else  
    __StreamingError("No streaming file")
    result = #False
  EndIf
  ProcedureReturn result
EndProcedure  


Procedure GetDownloadedBlockCount(*file.StreamingFile)
  Protected result.i
  If *file
    MREWMUTEX_LockWrite(*file\Streaming_Mutex)
      result=*file\blockAddCounter
    MREWMUTEX_UnLockWrite(*file\Streaming_Mutex)
  EndIf  
  ProcedureReturn result
EndProcedure  

Procedure SetNextDownloadBlock(*file.StreamingFile, block.i)
  Protected result.i
  If *file
    result=SetLastDLBlock(*file, block)
  EndIf  
  ProcedureReturn result
EndProcedure  

Procedure GetMaxDownloadedBlocks(*file.StreamingFile)
  Protected result.i
  If *file
    MREWMUTEX_LockWrite(*file\Streaming_Mutex)
      result=*file\blockCount
    MREWMUTEX_UnLockWrite(*file\Streaming_Mutex)
  EndIf  
  ProcedureReturn result
EndProcedure  






;{ Sample
; 
; DisableExplicit
; 
; HTTPCONTEXT_Initialize()
; url.s="http://test123456789.com/files/Videos/M4H02266.wmv"
; ;url.s="http://test123456789.com/videos/MPEG-4(DivX 5)-2.avi"
; ;start.q=ElapsedMilliseconds()
; 
; *file.StreamingFile=CreateStreamingFile("test.mp4", url, "My Agent", "", #True, #False)
; ;Debug IsBlockAvailable(*file, 0, 6048)
; ; *a=AllocateMemory(100000)
; ; 
; ; Debug ReadBytes(*file, *a, 100, 100000, @test)
; ; Debug test
; ; CreateFile(22,"test.txt")
; ; WriteData(22, *a, 100000)
; ; CloseFile(22)
; ; FreeMemory(*a)
; 
; Repeat 
;   Delay(10)
; Until Not IsThread(*file\thread)
; FreeStreamingFile(*file)
; ;Debug ElapsedMilliseconds()-start
; 
; 
; HTTPCONTEXT_UnInitialize()
;}

; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 8
; FirstLine = 4
; Folding = -----
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; EnablePurifier
; EnableCompileCount = 298
; EnableBuildCount = 0
; EnableExeConstant
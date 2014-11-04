;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
;===================================
;Multiple Read/Exclusive Write Mutex
;===================================
EnableExplicit

Structure MREW_MUTEX
  hMutex.i
  iReadCount.i
  bNewRead.i
  bWrite.i
EndStructure  

Procedure __MREWMUTEX_Lock(hMutex)
  Protected iWaitResult.i
  If hMutex
    !PAUSE 
    Repeat
      !PAUSE
      iWaitResult = WaitForSingleObject_(hMutex, 16)     
    Until iWaitResult = #WAIT_OBJECT_0
  EndIf
EndProcedure

Procedure MREWMUTEX_Create()
  Protected *mutex.MREW_MUTEX
  *mutex.MREW_MUTEX = AllocateMemory(SizeOf(MREW_MUTEX))
  If *mutex
    *mutex\hMutex = CreateMutex_(#Null, #False, #Null)
    *mutex\bNewRead = #True
    *mutex\bWrite = #False
    *mutex\iReadCount = 0
      
    If *mutex\hMutex = #Null
      FreeMemory(*mutex)
      *mutex = #Null
    EndIf  
  EndIf  
  ProcedureReturn *mutex
EndProcedure

Procedure MREWMUTEX_Free(*mutex.MREW_MUTEX)
  If *mutex
    If *mutex\hMutex
      CloseHandle_(*mutex\hMutex)
      *mutex\hMutex = #Null
    EndIf  
    FreeMemory(*mutex)
    *mutex = #Null
  EndIf  
EndProcedure

Procedure MREWMUTEX_LockRead(*mutex.MREW_MUTEX)
  Protected bOk = #False
  If *mutex
    If *mutex\hMutex
      !PAUSE 
      Repeat
        !PAUSE   
        __MREWMUTEX_Lock(*mutex\hMutex)
        If *mutex\bNewRead = #True And *mutex\bWrite = #False ; Wenn Lesezugriff erlaubt und derzeit kein Schreibzugriff 
          bOk = #True
          *mutex\iReadCount + 1  
        EndIf  
        ReleaseMutex_(*mutex\hMutex)
      Until bOk = #True
    EndIf
  EndIf   
  ProcedureReturn bOk
EndProcedure  

Procedure MREWMUTEX_UnLockRead(*mutex.MREW_MUTEX)
  Protected bOk = #False  
  If *mutex  
    If *mutex\hMutex
      !PAUSE 
      Repeat
        !PAUSE   
        __MREWMUTEX_Lock(*mutex\hMutex)
        If  *mutex\bWrite = #False ; *mutex\bNewRead = #True darf nicht sein!
          *mutex\iReadCount - 1  
          If *mutex\iReadCount < 0
            *mutex\iReadCount = 0
          EndIf  
          bOk = #True
        EndIf  
        ReleaseMutex_(*mutex\hMutex)
      Until bOk = #True
    EndIf
  EndIf   
  ProcedureReturn bOk
EndProcedure  


Procedure MREWMUTEX_LockWrite(*mutex.MREW_MUTEX)
  Protected bOk = #False    
  If *mutex       
    If *mutex\hMutex
      __MREWMUTEX_Lock(*mutex\hMutex)
      *mutex\bNewRead = #False ; zunächstmal keine neuen Lesevorgänge mehr zulassen 
      ReleaseMutex_(*mutex\hMutex)   
      !PAUSE 
      Repeat    
        !PAUSE   
        __MREWMUTEX_Lock(*mutex\hMutex)
        If  *mutex\iReadCount = 0 And *mutex\bWrite = #False ; nur 1 mal schreibzugriff erlaubt // *mutex\bNewRead = #False darf nicht abgefragt werden (2 write-Zugriffe gleichzeitig -> PROBLEM!!!)
          bOk = #True
          *mutex\bWrite = #True       
        EndIf  
        ReleaseMutex_(*mutex\hMutex)
      Until bOk = #True
    EndIf
  EndIf   
  ProcedureReturn bOk  
EndProcedure  


Procedure MREWMUTEX_UnLockWrite(*mutex.MREW_MUTEX)
  Protected bOk = #False  
  If *mutex
    If *mutex\hMutex
      !PAUSE 
      Repeat
        !PAUSE   
        __MREWMUTEX_Lock(*mutex\hMutex)
        If  *mutex\bWrite = #True And *mutex\iReadCount = 0 ; *mutex\bNewRead = #False auch nicht?!!
          bOk = #True
          *mutex\bWrite = #False
          *mutex\bNewRead = #True
        EndIf  
        ReleaseMutex_(*mutex\hMutex)
      Until bOk = #True
    EndIf
  EndIf   
  ProcedureReturn bOk  
EndProcedure  




; Procedure MyThreadRead(*ptr)
;   Delay(Random(10000))   
;  ; Debug "PRE READ"
;   MREWMUTEX_LockRead(*ptr)
;   Debug "ENTER READ"
;   Delay(100+Random(100))
;   Debug "LEAVE READ"
;   MREWMUTEX_UnLockRead(*ptr)
;  ; Debug "READ UNLOCK"
; EndProcedure  
; 
; 
; Procedure MyThreadWrite(*ptr)
;   Delay(Random(10000))  
;   ;Debug "PRE WRITE"
;   MREWMUTEX_LockWrite(*ptr)
;   Debug "ENTER WRITE"
;    Delay(100+Random(100))
;   Debug "LEAVE WRITE"
;   MREWMUTEX_UnLockWrite(*ptr)
;  ; Debug "WRITE UNLOCK"
; EndProcedure  
; 
; mutex = MREWMUTEX_Create()
; 
; OpenWindow(0, 100, 200, 195, 260, "PureBasic Window", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget)
; 
;  For T=0 To 10
;  Debug CreateThread(@MyThreadRead(), mutex)
;  Next
;  For Z=0 To 10
;  Debug CreateThread(@MyThreadWrite(), mutex)
;  Next
; 
; 
; Repeat
;   Event = WaitWindowEvent()
; 
;   If Event = #PB_Event_CloseWindow  ; If the user has pressed on the close button
;     Quit = 1
;   EndIf
; 
; Until Quit = 1










; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 170
; FirstLine = 139
; Folding = --
; EnableThread
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
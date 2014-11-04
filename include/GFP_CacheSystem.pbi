;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
;{ Declaration
  Structure MediaCache
    sFile.s{#MAX_PATH}
    iMemory.i
    iSize.i
  EndStructure
  
  Structure MediaPrevious
    sFile.s{#MAX_PATH}
    iItem.i
  EndStructure
  
  #MEDIACACHE_SIZE = 100
  Global Dim MediaCache.MediaCache(#MEDIACACHE_SIZE)
  Global Dim MediaPrevious.MediaPrevious(#MEDIACACHE_SIZE)
  Global iUsedMediaCache.i
  Global LastMediaItem
  
;}


Procedure CheckMediaCache(sFile.s)
  Protected i.i
  For i=0 To #MEDIACACHE_SIZE-1
    If MediaCache(i)\sFile = sFile And MediaCache(i)\iMemory
      ProcedureReturn MediaCache(i)\iMemory
    EndIf
  Next
  ProcedureReturn #False
EndProcedure
Procedure AddMediaCache(sFile.s, iMemory.i, iSize.i)
  If sFile And iMemory.i And iSize
    If MediaCache(#MEDIACACHE_SIZE)\iMemory
      FreeMemory(MediaCache(#MEDIACACHE_SIZE)\iMemory)
    EndIf
    CopyMemory(@MediaCache(), @MediaCache()+SizeOf(MediaCache), SizeOf(MediaCache)*(#MEDIACACHE_SIZE-1))
    MediaCache(0)\iMemory = iMemory
    MediaCache(0)\sFile = sFile
    MediaCache(0)\iSize = iSize
    iUsedMediaCache+iSize
  EndIf
  ProcedureReturn #False
EndProcedure
Procedure AddMediaCachePerFile(sFile.s)
  Protected iFile.i, iSize.i, iMemory.i
  iFile = ReadFile(#PB_Any, sFile)
  If iFile
    iSize.i = Lof(iFile)
    If iSize
      iMemory.i = AllocateMemory(iSize)
      If iMemory
        ReadData(iFile, iMemory, iSize)
      EndIf
    EndIf
    CloseFile(iFile)
  EndIf
  ProcedureReturn AddMediaCache(sFile.s, iMemory.i, iSize.i)
EndProcedure

Procedure FreeAllMediaCacheFiles()
  Protected i.i
  For i=0 To #MEDIACACHE_SIZE-1
    If MediaCache(i)\iMemory
      FreeMemory(MediaCache(i)\iMemory)
      MediaCache(i)\iMemory = 0
      MediaCache(i)\iSize = 0
      MediaCache(i)\sFile = ""
    EndIf
  Next
EndProcedure
Procedure FreeMediaCache(iSize.i, iMaxSize.i)
  Protected i.i
  For i=#MEDIACACHE_SIZE-1 To 0 Step -1
    If iMaxSize-iUsedMediaCache>=iSize
      ProcedureReturn #True
    EndIf
    If MediaCache(i)\iMemory
      FreeMemory(MediaCache(i)\iMemory)
      iUsedMediaCache - MediaCache(i)\iSize 
      MediaCache(i)\iMemory = 0
      MediaCache(i)\iSize = 0
    EndIf
  Next
  ProcedureReturn #False
EndProcedure


;DB_UpdateSync(*DB,"CREATE TABLE CHRONIC (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, file VARCHAR(500), date INT)")
Procedure SetChronicList(*DB)
  If IsMenu(#MENU_MAIN) And #USE_ONLY_ABOUT_MENU=#False
    Protected iRow, i.i, loadDB.i
    If *DB=#Null
      If *PLAYLISTDB:*DB=*PLAYLISTDB:EndIf
      If *DB=#Null
        *DB=DB_Open(sDataBaseFile)
        loadDB=#True
      EndIf
    EndIf  
  
    If *DB
      For i=0 To 9
        SetMenuItemText(#MENU_MAIN, #MENU_CHRONIC_1+i, "-")
        DisableMenuItem(#MENU_MAIN, #MENU_CHRONIC_1+i, #True)
      Next
      DB_Query(*DB,"SELECT * FROM CHRONIC ORDER BY id DESC LIMIT 10")
      iRow = 0
      While DB_SelectRow(*DB, iRow)
        SetMenuItemText(#MENU_MAIN, #MENU_CHRONIC_1+iRow, GetFilePart(DB_GetAsString(*DB, 1)))
        DisableMenuItem(#MENU_MAIN, #MENU_CHRONIC_1+iRow, #False)
        iRow+1
      Wend  
      DB_EndQuery(*DB)
  
      If loadDB=#True
        If *DB
          DB_Close(*DB)
        EndIf
      EndIf  
    EndIf  
  EndIf
EndProcedure  
Procedure AddChronicFile(sFile.s)
  Protected loadDB
  Protected *DB
  CompilerIf #PB_editor_createexecutable
    If sFile.s  
      If *PLAYLISTDB:*DB=*PLAYLISTDB:EndIf
      If *DB=#Null:*DB = DB_Open(sDataBaseFile):loadDB=#True:EndIf
      If *DB
        If DB_Query(*DB,"INSERT INTO CHRONIC (file, date) VALUES (?, ?)")
          DB_StoreAsString(*DB,0, sFile)
          DB_StoreAsQuad(*DB, 1, Date())
          DB_StoreRow(*DB)
        EndIf
        DB_EndQuery(*DB)
        SetChronicList(*DB)
        If loadDB=#True
          DB_Close(*DB)
        EndIf
      EndIf  
    EndIf
  CompilerEndIf
EndProcedure
Procedure ClearChronic()
  Protected *DB
  Protected loadDB
  If *PLAYLISTDB:*DB=*PLAYLISTDB:EndIf
  If *DB=#Null:*DB = DB_Open(sDataBaseFile):loadDB=#True:EndIf
  If *DB
    DB_UpdateSync(*DB,"DELETE FROM CHRONIC")
    DB_Clear(*DB)
    SetChronicList(*DB)
    If loadDB=#True:DB_Close(*DB):EndIf
    WriteLog("Delete chronic!", #LOGLEVEL_DEBUG) 
  EndIf
EndProcedure
Procedure LoadChronicFile(iRow.i)
  Protected *DB, sFile.s
  *DB=DB_Open(sDataBaseFile)
  If *DB
    DB_Query(*DB,"SELECT * FROM CHRONIC ORDER BY id DESC LIMIT 10")
      DB_SelectRow(*DB, iRow)
      sFile.s=DB_GetAsString(*DB, 1)
    DB_EndQuery(*DB)
    
    DB_Close(*DB)
  EndIf
  
  If sFile
    ;LoadMediaFile(sFile, #False)
    LoadFiles(sFile)
  EndIf  
  
EndProcedure



Procedure AddPreviousFile(sFile.s, iItem)
  If MediaPrevious(0)\sFile <> sFile
    AddChronicFile(sFile.s)
    
    CopyMemory(@MediaPrevious(0), @MediaPrevious(0)+SizeOf(MediaPrevious), SizeOf(MediaPrevious)*(#MEDIACACHE_SIZE))
    MediaPrevious(0)\sFile = sFile
    MediaPrevious(0)\iItem = iItem
  EndIf
EndProcedure
Procedure.s GetLastMediaFile()
  LastMediaItem=-1
  If MediaPrevious(1)\sFile=""
    ProcedureReturn ""
  Else
    CopyMemory(@MediaPrevious(0)+SizeOf(MediaPrevious), @MediaPrevious(0), SizeOf(MediaPrevious)*(#MEDIACACHE_SIZE))
  EndIf
  LastMediaItem=MediaPrevious(0)\iItem
  ProcedureReturn MediaPrevious(0)\sFile
EndProcedure
Procedure GetLastMediaItem()
  ProcedureReturn LastMediaItem
EndProcedure  


; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 22
; FirstLine = 12
; Folding = Bx-
; EnableXP
; UseMainFile = Player.pb
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
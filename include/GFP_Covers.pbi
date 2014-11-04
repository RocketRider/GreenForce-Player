;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
;DB_UpdateSync(*PLAYLISTDB,"CREATE TABLE COVER (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, interpret VARCHAR(200), album VARCHAR(200), md5 VARCHAR(100) UNIQUE, data BLOB)")


;{ Declare

Structure CoverCache
  iCoverID.i
  iMemory.i
  iSize.i
EndStructure

#COVERCACHE_SIZE = 1000
#COVERCACHE_MB_SIZE = 20*1024*1024
#COVER_QUALITY = 7 ;Wert von 0 (schlechteste Qualität) bis 10 (maximale Qualität). 

Global Dim CoverCache.CoverCache(#COVERCACHE_SIZE)
Global iUsedCoverCache.i
;}


;Returns a pointer to the data. FreeMemory() must be called after the memory is not needed anymore.
Procedure SaveToJPEGInMem(iImage.i, iQuality.i)
  Protected ImageFile, iSize, *mem = #Null, iNumBytes, iResult.i
  ImageFile = CreateNamedPipe_("\\.\pipe\ImageFileJPEG",#PIPE_ACCESS_INBOUND,#PIPE_TYPE_BYTE|#PIPE_READMODE_BYTE|#PIPE_NOWAIT,1,0,-1,#NMPWAIT_USE_DEFAULT_WAIT,#Null) 
  If ImageFile
    SaveImage(iImage,"\\.\pipe\ImageFileJPEG",#PB_ImagePlugin_JPEG, iQuality) 
    iSize = GetFileSize_(ImageFile, 0)
    If iSize > 0
      *mem = AllocateMemory(iSize)
      If *mem
        iResult = ReadFile_(ImageFile, *mem, iSize ,@iNumBytes, #Null)
        If iResult = #False
          FreeMemory(*mem)
          *mem = #Null
        EndIf 
      EndIf
    EndIf 
    CloseHandle_(ImageFile)  
  EndIf
  ProcedureReturn *mem
EndProcedure
;If there is a CoverFile it will use this File and not the buffer!
;If You set an Image, this will be used, and it will be released!
Procedure.s AddCover_Fast(*DB, sInterpret.s, sAlbum.s, pPicture.i, iPictureSize.i, sCoverFile.s="", Image=#False)
  Protected sMD5.s, pNewPicture.i, pNewPictureSize.i, i.i
  Protected iCoverFile.i, iResult.i, iImage.i, iHeight.i
  If *DB  
    If (pPicture And iPictureSize) Or sCoverFile Or Image
      If sCoverFile:iImage = LoadImage(#PB_Any, sCoverFile):EndIf
      If pPicture:iImage = CatchImage(#PB_Any, pPicture, iPictureSize):EndIf
      If Image:iImage = Image:EndIf
      If iImage
        If ImageWidth(iImage)>512
          iHeight = 512*ImageHeight(iImage)/ImageWidth(iImage)
          ResizeImage(iImage, 512,  iHeight, #PB_Image_Smooth)
        EndIf
        pNewPicture = SaveToJPEGInMem(iImage.i, #COVER_QUALITY)
        pNewPictureSize = MemorySize(pNewPicture)
        
        If pNewPicture And pNewPictureSize
;           If DB_Query(*DB,"INSERT INTO COVER (interpret, album, md5, data) VALUES (?,?,?,?)")
;             If pPicture:sMD5.s=MD5Fingerprint(pPicture, iPictureSize):EndIf
;             If sCoverFile:sMD5.s=MD5FileFingerprint(sCoverFile):EndIf
;             If Image:sMD5.s="":For i=0 To 31:sMD5.s+LCase(Hex(Random(15))):Next:EndIf;Kann nicht mehr ermittelt werden
;             DB_StoreAsString(*DB,0, sInterpret)
;             DB_StoreAsString(*DB,1, sAlbum)
;             DB_StoreAsString(*DB,2, sMD5)
;             DB_StoreAsBlob(*DB, 3, pNewPicture, pNewPictureSize, #DB_BLOB_DEFAULT)
;             DB_StoreRow(*DB)
;             WriteLog("Save new Cover", #LOGLEVEL_DEBUG)
;           EndIf
;           DB_EndQuery(*DB)
;           
          ;Verursacht IO Error
          If pPicture:sMD5.s=MD5Fingerprint(pPicture, iPictureSize):EndIf
          If sCoverFile:sMD5.s=MD5FileFingerprint(sCoverFile):EndIf
          If Image:sMD5.s="":For i=0 To 31:sMD5.s+LCase(Hex(Random(15))):Next:EndIf;Kann nicht mehr ermittelt werden
          DB_UpdateBlob(*DB, "INSERT INTO COVER (interpret, album, md5, data) VALUES ('"+sInterpret+"','"+sAlbum+"','"+sMD5+"',?)", pNewPicture, pNewPictureSize)
       

          FreeImage(iImage)
          FreeMemory(pNewPicture)
          pNewPicture = #Null
          iImage=#Null
        EndIf
        
      EndIf
    EndIf
    If iCoverFile And pPicture:FreeMemory(pPicture):EndIf
    If iImage:FreeImage(iImage):EndIf
  EndIf
  ProcedureReturn sMD5
EndProcedure
;If there is a CoverFile it will use this File and not the buffer!
Procedure.s AddCover(sDBFile.s, sInterpret.s, sAlbum.s, pPicture.i, iPictureSize.i, sCoverFile.s="")
  Protected *DB, iCoverFile.i, sResult.s
  *DB=DB_Open(sDBFile)
  If *DB
    ;Adds the Cover:
    sResult=AddCover_Fast(*DB, sInterpret.s, sAlbum.s, pPicture.i, iPictureSize.i, sCoverFile.s)
    DB_Close(*DB)
  EndIf
  ProcedureReturn sResult
EndProcedure

Structure CoverIDCache
  ID.i
  md5.s
  Interpret.s
  Album.s
EndStructure  
Global NewList CoverIDCache.CoverIDCache()
Procedure FindCoverID_List(sInterpret.s, sAlbum.s, sMD5.s="")
Protected iCoverID.i, searchMD5.i
  If sMD5 Or (sInterpret And sAlbum)
    If sMD5
      searchMD5=#True
    Else
      searchMD5=#False
      If sInterpret="" And sAlbum="":ProcedureReturn #False:EndIf
    EndIf
    ForEach CoverIDCache()
      If searchMD5 And CoverIDCache()\md5=sMD5
        ProcedureReturn CoverIDCache()\ID
      EndIf  
      If searchMD5=#False And LCase(CoverIDCache()\Interpret)=LCase(sInterpret) And LCase(CoverIDCache()\Album)=LCase(sAlbum) 
        ProcedureReturn CoverIDCache()\ID
      EndIf  
    Next
  EndIf
ProcedureReturn #False
EndProcedure
Procedure FindCoverID_Fast(*DB, sInterpret.s, sAlbum.s, sMD5.s="")
Protected iCoverID.i, sWhere.s, searchMD5.i
  If sMD5 Or (sInterpret And sAlbum)
    If sMD5
      sWhere="md5 = '"+sMD5+"'"
      searchMD5=#True
    Else
      sWhere="interpret = '"+sInterpret+"' AND album = '"+sAlbum+"'"
      searchMD5=#False
      If sInterpret="" And sAlbum="":ProcedureReturn #False:EndIf
    EndIf
    ForEach CoverIDCache()
      If searchMD5 And CoverIDCache()\md5=sMD5
        ProcedureReturn CoverIDCache()\ID
      EndIf  
      If searchMD5=#False And LCase(CoverIDCache()\Interpret)=LCase(sInterpret) And LCase(CoverIDCache()\Album)=LCase(sAlbum) 
        ProcedureReturn CoverIDCache()\ID
      EndIf  
    Next
    
    If DB_Query(*DB,"SELECT * FROM COVER WHERE "+sWhere.s+" LIMIT 1")
      DB_SelectRow(*DB, 0)
      iCoverID.i = DB_GetAsLong(*DB, 0)
      If iCoverID
        If ListSize(CoverIDCache())>1000
          ClearList(CoverIDCache()) 
        EndIf  
        AddElement(CoverIDCache())
        CoverIDCache()\md5=sMd5
        CoverIDCache()\Album=sAlbum
        CoverIDCache()\Interpret=sInterpret
        CoverIDCache()\ID=iCoverID
      EndIf  
    EndIf
    DB_EndQuery(*DB)
  EndIf
ProcedureReturn iCoverID.i
EndProcedure

Procedure ChangeCover(*DB ,iTrackID.i, iCoverID.i)
  DB_Update(*DB,"UPDATE PLAYTRACKS SET cover='" + Str(iCoverID) + "' WHERE id='"+Str(iTrackID)+"'")
EndProcedure





Procedure CheckCoverCache(iCoverID)
  Protected i.i
  For i=0 To #COVERCACHE_SIZE-1
    If CoverCache(i)\iCoverID = iCoverID And CoverCache(i)\iMemory
      ProcedureReturn CoverCache(i)\iMemory
    EndIf
  Next
  ProcedureReturn #False
EndProcedure
Procedure AddCoverCache(iCoverID, iMemory.i, iSize.i)
  If CoverCache(#COVERCACHE_SIZE)\iMemory
    FreeMemory(CoverCache(#COVERCACHE_SIZE)\iMemory)
  EndIf
  CopyMemory(@CoverCache(), @CoverCache()+SizeOf(CoverCache), SizeOf(CoverCache)*(#COVERCACHE_SIZE-1))
  CoverCache(0)\iMemory = iMemory
  CoverCache(0)\iCoverID = iCoverID
  CoverCache(0)\iSize = iSize
  iUsedCoverCache+iSize
  ProcedureReturn #False
EndProcedure
Procedure FreeAllCoverCacheData()
  Protected i.i
  For i=0 To #COVERCACHE_SIZE-1
    If CoverCache(i)\iMemory
      FreeMemory(CoverCache(i)\iMemory)
      CoverCache(i)\iMemory = 0
      CoverCache(i)\iSize = 0
      CoverCache(i)\iCoverID = 0
    EndIf
  Next
EndProcedure
Procedure FreeCoverCache(iSize.i, iMaxSize.i)
  Protected i.i
  For i=#COVERCACHE_SIZE-1 To 0 Step -1
    If iMaxSize-iUsedCoverCache>=iSize
      ProcedureReturn #True
    EndIf
    If CoverCache(i)\iMemory
      FreeMemory(CoverCache(i)\iMemory)
      iUsedCoverCache - CoverCache(i)\iSize 
      CoverCache(i)\iMemory = 0
      CoverCache(i)\iSize = 0
    EndIf
  Next
  ProcedureReturn #False
EndProcedure

Procedure GetCover(*DB, iCoverID.i);Zurückgegebener Speicher nicht freigeben, da dieser im Cache verwendet wird.
  Protected iMemory.i, iSize.i, iLoadDB.i
  If iCoverID<1
    ProcedureReturn #False
  EndIf
  iMemory = CheckCoverCache(iCoverID)
  If iMemory
    ProcedureReturn iMemory
  EndIf
  If *DB=0
    *DB=DB_Open(sDataBaseFile)
    iLoadDB=#True
  EndIf
  If *DB=0
    WriteLog("Can't open database!", #LOGLEVEL_DEBUG)
    ProcedureReturn #Null
  EndIf

  If DB_Query(*DB,"SELECT * FROM COVER WHERE id = "+Str(iCoverID))
    DB_SelectRow(*DB, 0)
    iSize.i = DB_GetAsBlobSize(*DB, 4)
    iMemory.i = DB_GetAsBlobPointer(*DB, 4)
    If iSize And iMemory
      FreeCoverCache(iSize.i, #COVERCACHE_MB_SIZE)
      AddCoverCache(iCoverID, iMemory.i, iSize.i)
    EndIf
  EndIf
  DB_EndQuery(*DB)
  If iLoadDB
    DB_Close(*DB)
  EndIf
  ProcedureReturn iMemory
EndProcedure
Procedure LoadCoverImage(*DB, iCoverID.i)
Protected iMemory.i, iImage.i
  iMemory=GetCover(*DB, iCoverID.i)
  If iMemory
    iImage=CatchImage(#PB_Any, iMemory)
  EndIf
ProcedureReturn iImage
EndProcedure



; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 266
; FirstLine = 158
; Folding = 9m-
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
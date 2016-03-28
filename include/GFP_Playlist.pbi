;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

Declare.s _PLS_ImportPlaylist_GetType(sFile.s, iReadFlag.i)
Structure PlsArray
  sFile.s
  qLength.q
  sTitle.s
EndStructure



Procedure LoadPlayList()
  Protected iRow.i
  If *PLAYLISTDB
    ClearGadgetItems(#GADGET_LIST_PLAYLIST) 
    If DB_Query(*PLAYLISTDB, "SELECT * FROM PLAYLISTS")
      While DB_SelectRow(*PLAYLISTDB, iRow)
        AddGadgetItem(#GADGET_LIST_PLAYLIST, -1, DB_GetAsString(*PLAYLISTDB, 1), ImageID(#SPRITE_PLAYLIST))
        iRow+1
      Wend
    EndIf
    DB_EndQuery(*PLAYLISTDB)
  EndIf
EndProcedure
Procedure CheckPlayListName(sName.s)
Protected iRow.i
If *PLAYLISTDB
  If DB_Query(*PLAYLISTDB, "SELECT * FROM PLAYLISTS")
    While DB_SelectRow(*PLAYLISTDB, iRow)
      If UCase(DB_GetAsString(*PLAYLISTDB, 1)) = UCase(sName)
        DB_EndQuery(*PLAYLISTDB)
        ProcedureReturn #False
      EndIf
      iRow+1
    Wend
  EndIf
  DB_EndQuery(*PLAYLISTDB)
  ProcedureReturn #True
EndIf
EndProcedure
Procedure GetPlayListID(sName.s)
Protected iRow.i, iResult.i
If *PLAYLISTDB
  If DB_Query(*PLAYLISTDB, "SELECT * FROM PLAYLISTS")
    While DB_SelectRow(*PLAYLISTDB, iRow)
      If UCase(DB_GetAsString(*PLAYLISTDB, 1)) = UCase(sName)
        iResult.i = DB_GetAsLong(*PLAYLISTDB, 0)
        DB_EndQuery(*PLAYLISTDB)
        ProcedureReturn iResult
      EndIf
      iRow+1
    Wend
  EndIf
  DB_EndQuery(*PLAYLISTDB)
  ProcedureReturn #False
EndIf
EndProcedure

Procedure DShow_GetMediaLenght(sFile.s);Nicht die Beste Lösung jede datei einzuladen!
  Protected iResult.i, iTestMediaObject.i, OldUsedOutputMediaLibrary.i
  iResult = 0
  OldUsedOutputMediaLibrary.i = UsedOutputMediaLibrary
  iTestMediaObject = LoadMedia(sFile, 0, iVideoRenderer,  iAudioRenderer)
  If iTestMediaObject
    iResult = MediaLength(iTestMediaObject)
    OnMediaEvent(iTestMediaObject)
    FreeMedia(iTestMediaObject)
    iTestMediaObject=0
  EndIf
  UsedOutputMediaLibrary.i = OldUsedOutputMediaLibrary.i
  ProcedureReturn iResult
EndProcedure
Procedure GetMediaLenght(sFile.s, AlsoUseDShowLoading=#True)
  Protected MC.MEDIACHECK
  CheckMedia(sFile, @MC)
  ;Debug MC\bUseable
  ;Debug 
  
  If AlsoUseDShowLoading
    If MC\dLength<=0 And FindString(#GFP_FORMAT_MEDIA, ";"+LCase(GetExtensionPart(sFile))+";", 1)
      MC\dLength=DShow_GetMediaLenght(sFile.s)
    EndIf  
  EndIf
  ProcedureReturn MC\dLength*1000
EndProcedure


Procedure AddPlayListTrack(sFile.s, iPlaylist.i, sTitle.s="", qLenght.q=0, sDescription.s="", sInterpret.s="", sAlbum.s="")
  Protected sValues.s, iType.i, isURL.i, isEncrypted.i, iCover.i, sLCFile.s
  Protected MC.MEDIACHECK, sGUID.s, sMD5.s, sCoverFile.s, CoverImage.i, res.i, *Header, stdData.DRM_STANDARD_DATA
  If *PLAYLISTDB
    If FindString("exe,png,jpg,jpeg,bmp,gif,txt,ico,html,mht,zip,rar,7z,pdf,docx,xls,tar,dll,pb,com,bat,pbi,sys,ini,log,xml,rtf", LCase(GetExtensionPart(sFile)),1)
      ProcedureReturn #False
    EndIf
    sLCFile=LCase(sFile)
    If sFile And sLCFile<>"http://" And sLCFile<>"https://" And (FileSize(sFile)>0 Or Mid(sLCFile,1, 8)="https://" Or Mid(sLCFile,1, 7)="http://")
      ;Debug sFile
      ;Protected time=GetTickCount_()
      
      
      If Mid(sLCFile,1, 7)="http://" Or Mid(sLCFile,1, 7)="https://" Or Mid(sLCFile,1, 7)="gfp://":isURL.i=#True:iType=2:EndIf
      If isURL=#False:isEncrypted = IsFileEncrypted(sFile.s):EndIf
      ;Debug "1: "+Str(GetTickCount_()-time):time=GetTickCount_()
      
      If isURL = #False And isEncrypted=#False
;         ;qLenght = GetmediaLenght(sFile.s)
;         CheckMedia(sFile, @MC)
;   
;         ;If MC\dLength<=0
;         ;  MC\dLength=GetMediaLenght(sFile.s, #False);DShow_GetMediaLenght(sFile.s)
;         ;  MC\dLength/1000
;         ;EndIf
;         qLenght = MC\dLength
;         iType = MC\bVideo   

        LoadMetaFile(sFile.s)
        qLenght = MediaInfoData\qDuration/10000000
        iType = MediaInfoData\iHasVideo
        If qLenght<=0
          CheckMedia(sFile, @MC)
          qLenght = MC\dLength
          iType = MC\bVideo   
        EndIf  
        
      Else
        ClearMetaArray()
      EndIf
      ;Debug "2: "+Str(GetTickCount_()-time):time=GetTickCount_()
      If qLenght Or isURL Or isEncrypted
;         If isURL=#False And isEncrypted=#False
;           LoadMetaFile(sFile.s)
;         Else
;           ClearMetaArray()
;         EndIf
        ;Debug "3: "+Str(GetTickCount_()-time):time=GetTickCount_()
        
        sFile = ConvertStringDBCompartible(sFile, #True)
        If isURL = #False And isEncrypted=#False
          If sTitle=""
            If MediaInfoData\sTile
              sTitle = MediaInfoData\sTile
            Else
              sTitle = GetFilePart(sFile)
            EndIf
          EndIf
          If sDescription="":sDescription = MediaInfoData\sGenere:EndIf
          If sInterpret="":sInterpret = MediaInfoData\sComposer:EndIf
          If sAlbum="":sAlbum = MediaInfoData\sAlbumTitle:EndIf
          sInterpret=ConvertStringDBCompartible(sInterpret, #True)
          sAlbum=ConvertStringDBCompartible(sAlbum, #True)
          
          If FindCoverID_List(sInterpret, sAlbum)=#False
            sGUID.s=MediaInfoData\sGUID
            If MediaInfoData\iHasAttachedImages And MediaInfoData\pPicture And MediaInfoData\iPictureSize
              sMD5 = AddCover_Fast(*PLAYLISTDB, sInterpret.s, sAlbum.s, MediaInfoData\pPicture, MediaInfoData\iPictureSize)
            Else
              If sGUID
                sCoverFile.s=GetPathPart(sFile)+"\"+"AlbumArt_"+sGUID+"_Large.jpg"
                If FileSize(sCoverFile)>0
                  sMD5 = AddCover_Fast(*PLAYLISTDB, sInterpret.s, sAlbum.s, 0, 0, sCoverFile)
                Else
                  sCoverFile.s=GetPathPart(sFile)+"\"+"AlbumArt_"+sGUID+"_Large.png"
                  If FileSize(sCoverFile)>0
                    sMD5 = AddCover_Fast(*PLAYLISTDB, sInterpret.s, sAlbum.s, 0, 0, sCoverFile)
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
          ;Debug "4: "+Str(GetTickCount_()-time):time=GetTickCount_()
        Else
          If isEncrypted
;             ReadDRMHeader(sFile.s, *GFP_DRM_HEADER, "RR is Testing")
;             If GetDRMHeaderTitle(*GFP_DRM_HEADER) And sTitle=""
;               sTitle = GetDRMHeaderTitle(*GFP_DRM_HEADER)
;             EndIf
;             If sDescription="":sDescription = GetDRMHeaderComments(*GFP_DRM_HEADER):EndIf
;             If sInterpret="":sInterpret = GetDRMHeaderInterpreter(*GFP_DRM_HEADER):EndIf
;             If sAlbum="":sAlbum = GetDRMHeaderAlbum(*GFP_DRM_HEADER):EndIf
;             If qLenght=0:qLenght = GetDRMHeaderMediaLength(*GFP_DRM_HEADER)/1000:EndIf
;             CoverImage = GetDRMHeaderCover(*GFP_DRM_HEADER)

            *Header = DRMV2Read_ReadFromFile(sFile, "Default", 0)
            If *Header
              If sTitle = "":sTitle = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_TITLE):EndIf
              If sInterpret = "":sInterpret = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_INTERPRETER):EndIf
              If sDescription = "":sDescription = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_COMMENT):EndIf
              If sAlbum = "":sAlbum = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_ALBUM):EndIf
              If CoverImage = 0:CoverImage = DRMV2Read_GetCoverImage(*Header):EndIf
              If qLenght=0
                If DRMV2Read_GetBlockData(*Header, #DRMV2_HEADER_MEDIA_STANDARDDATA, @stdData)
                  qLenght = stdData\qLength /1000
                EndIf  
              EndIf
              
              
              DRMV2Read_Free(*Header)
            EndIf  
            sInterpret=ConvertStringDBCompartible(sInterpret, #True)
            sAlbum=ConvertStringDBCompartible(sAlbum, #True)
            If FindCoverID_List(sInterpret, sAlbum)=#False
              sMD5 = AddCover_Fast(*PLAYLISTDB, sInterpret.s, sAlbum.s, 0, 0, "", CoverImage);Bild wird freigegeben!
            EndIf  
            CoverImage=#Null
          EndIf
          If sTitle="":sTitle = GetFilePart(sFile):EndIf
        EndIf
        
        sTitle=ConvertStringDBCompartible(sTitle, #True)
        sDescription=ConvertStringDBCompartible(sDescription, #True)
        ;sInterpret=ConvertStringDBCompartible(sInterpret, #True)
        ;sAlbum=ConvertStringDBCompartible(sAlbum, #True)
        
        iCover = FindCoverID_Fast(*PLAYLISTDB, sInterpret, sAlbum, sMD5)
        sValues = "'" + Str(iPlaylist) + "', '" + sFile.s + "', '"  + Str(qLenght) + "', '" + Str(iType) + "', '" + sTitle.s + "', '" + sDescription.s + "', '"  + sInterpret.s + "', '"  + sAlbum.s + "', '"  + Str(iCover.i) + "'"
        DB_Update(*PLAYLISTDB,"INSERT INTO PLAYTRACKS (playlist, filename, lenght, type, title, description,  interpret, album, cover) VALUES (" + sValues.s + ")")
        
        
        ;Debug "5: "+Str(GetTickCount_()-time):time=GetTickCount_()
      EndIf
    EndIf
    
  EndIf
EndProcedure
Procedure LoadPlayListTracks(iPlaylist.i)
  Protected iRow.i, sText.s, iImageID.i, iType.i
  If *PLAYLISTDB
    Playlist\iTempID = iPlaylist
    ClearGadgetItems(#GADGET_LIST_TRACKLIST)
    If DB_Query(*PLAYLISTDB, "SELECT * FROM PLAYTRACKS WHERE playlist = '"+Str(iPlaylist)+"'")
      While DB_SelectRow(*PLAYLISTDB, iRow)

        sText = DB_GetAsString(*PLAYLISTDB, 5)+Chr(10)
        If DB_GetAsLong(*PLAYLISTDB, 3)>0
          sText = sText + Time2String(DB_GetAsLong(*PLAYLISTDB, 3)*1000) + Chr(10)
        Else
          sText = sText + "" + Chr(10)
        EndIf
        
        sText = sText + DB_GetAsString(*PLAYLISTDB, 7) + Chr(10) + DB_GetAsString(*PLAYLISTDB, 8)
        sText = ConvertStringDBCompartible(sText, #False)
        iType=DB_GetAsLong(*PLAYLISTDB, 4)
        If iType=0
          iImageID=ImageID(#SPRITE_PLAYTRACK)
        EndIf
        If iType=1
          iImageID=ImageID(#SPRITE_MENU_PROJEKTOR)
        EndIf
        If iType=2
          iImageID=ImageID(#SPRITE_EARTHFILE)
        EndIf
        
        AddGadgetItem(#GADGET_LIST_TRACKLIST, -1, sText, iImageID)
        SetGadgetItemData(#GADGET_LIST_TRACKLIST, CountGadgetItems(#GADGET_LIST_TRACKLIST)-1, DB_GetAsLong(*PLAYLISTDB, 0))
        
        iRow+1
      Wend
    EndIf
    DB_EndQuery(*PLAYLISTDB)
  EndIf
EndProcedure
Procedure SetPlayList(iPlaylist.i, iCurrentMediaID.i)
Protected iRow, iID.i, sTitle.s, sAutor.s
If *PLAYLISTDB
  DB_Query(*PLAYLISTDB,"SELECT * FROM PLAYTRACKS WHERE (playlist = '" + Str(iPlaylist) + "') ")
  
  While DB_SelectRow(*PLAYLISTDB, iRow)
    iRow+1
  Wend
  Playlist\iItemCount = iRow - 1
  Global Dim PlayListItems.PlayListItem(Playlist\iItemCount+1)
  
  iRow = 0
  While DB_SelectRow(*PLAYLISTDB, iRow)
    PlayListItems(iRow)\sFile = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 2), #False)
    sTitle.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 5), #False)
    sAutor.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 7), #False)
    If sTitle ="": sTitle = GetFilePart(PlayListItems(iRow)\sFile):EndIf
    If sAutor
      sTitle = sAutor + " - " + sTitle
    EndIf
    PlayListItems(iRow)\sTitle = sTitle
    
    iID.i = DB_GetAsLong(*PLAYLISTDB, 0)
    If iCurrentMediaID = iID:Playlist\iCurrentMedia=iRow:EndIf
    
    iRow+1
  Wend
  DB_EndQuery(*PLAYLISTDB)
EndIf
EndProcedure
Procedure AddPlayListFolder(sDirectory.s, iPlaylist.i)
  Protected iDirectory.i, sFile.s

  iDirectory = ExamineDirectory(#PB_Any, sDirectory, "*.*")
  If iDirectory
    While NextDirectoryEntry(iDirectory)
      sFile.s = DirectoryEntryName(iDirectory)
      If sFile<>"." And sFile<>".." And sFile<>"..."
        If DirectoryEntryType(iDirectory) = #PB_DirectoryEntry_Directory
          AddPlayListFolder(sDirectory+"\"+sFile, iPlaylist.i)
        Else
          AddPlayListTrack(sDirectory+"\"+sFile, iPlaylist.i)
          ProcessAllEvents()
        EndIf
      EndIf
    Wend
  EndIf

EndProcedure

Procedure DisableAddTracks(iStatus)
  DisableGadget(#GADGET_LIST_TRACKLIST, iStatus)
  DisableToolBarButton(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_ADDTRACK, iStatus)
  DisableToolBarButton(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_ADDFOLDERTRACKS, iStatus)
  DisableToolBarButton(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_ADDURL, iStatus)
  DisableToolBarButton(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_DELETETRACK, iStatus)
  DisableToolBarButton(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_EXPORTPLAYLIST, iStatus)
  DisableToolBarButton(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_PLAYPLAYLIST, iStatus)
EndProcedure

Procedure.s XMLStringConvert(sText.s)
   sText = ReplaceString(sText, "&nbsp;", " ")
   sText = ReplaceString(sText, "&sect;", "§")
   sText = ReplaceString(sText, "&sup2;", "²")
   sText = ReplaceString(sText, "&sup3;", "³") 
   sText = ReplaceString(sText, "&amp;", "&")
   sText = ReplaceString(sText, "&lt;", "<")
   sText = ReplaceString(sText, "&gt;", ">")
   sText = ReplaceString(sText, "&quot;",Chr(34))
   sText = ReplaceString(sText, "&euro;", "€")
   sText = ReplaceString(sText, "&auml;", "ä")
   sText = ReplaceString(sText, "&Auml;", "Ä")
   sText = ReplaceString(sText, "&ouml;", "ö")
   sText = ReplaceString(sText, "&Ouml;", "Ö")
   sText = ReplaceString(sText, "&uuml;", "ü")
   sText = ReplaceString(sText, "&Uuml;", "Ü")
   sText = ReplaceString(sText, "&szlig;", "ß")
  ProcedureReturn sText
EndProcedure


Structure CHAR
  c.c
EndStructure

;Nun auch unicode Kompatible
Procedure.s FindStringInBuffer(*ptr.CHAR, len.i, sFindBegin.s, sFindEnd.s) ;len must be Len(String)
  Protected iFindFirstSize.i, iFindEndSize.i, cBeginFirstChar.c, cEndFirstChar.c, bSaveString.i, sSaveString.s, sSaveStrings.s
  Protected i.i
  If *ptr
    iFindFirstSize.i = Len(sFindBegin)
    iFindEndSize.i = Len(sFindEnd)
    
    cBeginFirstChar.c = Asc(Left(sFindBegin, 1))
    cEndFirstChar.c = Asc(Left(sFindEnd, 1))
    
    
    bSaveString.i = #False
    sSaveString.s = ""
    sSaveStrings.s = ""
    
    For i = 0 To len - 1
      
      If *ptr\c = cBeginFirstChar
        
        If (len - i) > iFindFirstSize
          
          If PeekS(*ptr, iFindFirstSize) = sFindBegin
            bSaveString = #True
    
            sSaveString.s = ""
            *ptr + iFindFirstSize * SizeOf(CHAR)
          EndIf
          
        EndIf 
      EndIf
    
      If bSaveString
        If *ptr\c = cEndFirstChar
          If (len - i) > iFindEndSize
            If PeekS(*ptr, iFindEndSize) = sFindEnd        
        
              bSaveString = #False
            
              sSaveString = ReplaceString(sSaveString, "|", "/")
              sSaveStrings + sSaveString + "|"
              *ptr + iFindEndSize * SizeOf(CHAR) - SizeOf(CHAR)
            EndIf
          EndIf      
        EndIf    
      EndIf
      If bSaveString
        sSaveString.s + Chr(*ptr\c)   
      EndIf 
      
      *ptr + SizeOf(CHAR)
    
    Next
    
    If Right(sSaveStrings, 1) = "|"
      sSaveStrings = Left(sSaveStrings, Len(sSaveStrings) - 1)
    EndIf
    
  EndIf
  ProcedureReturn sSaveStrings
EndProcedure
Procedure.s FindTagValue(sText.s, sTag.s)
Protected sResult.s, pos.i
  pos=FindString(sText, sTag, 1)
  If pos
    pos=FindString(sText, "=", pos)
    sResult=Mid(sText, pos+1, FindString(sText, ">", pos)-2-pos)
    sResult=RemoveString(sResult, "<")
    sResult=RemoveString(sResult, ">")
    sResult=RemoveString(sResult, Chr(34))
    sResult=Trim(sResult)
  EndIf
ProcedureReturn sResult.s
EndProcedure


Procedure PLS_IsPlayList(sFile.s)
  Protected sFileExt.s, sType.s
  Protected sFileExtension.s=LCase(GetExtensionPart(sFile))
  If FileSize(sFile)>0
    
    If FindString(#GFP_FORMAT_MEDIA, ";"+sFileExtension+";", 1)
      ProcedureReturn #False
    EndIf
    If FindString(#GFP_FORMAT_PLAYLIST, ";"+sFileExtension+";", 1)
      ProcedureReturn #True
    EndIf
    
    If FILEINFO_GetFileFormat(sFile.s)<>#DATATYPE_BINARY
      sType.s=_PLS_ImportPlaylist_GetType(sFile.s, #DATATYPE_TEXT_ASCII)
      If sType = "ASX" Or sType = "XSPF" Or sType = "#EXTM3U" Or sType = "[PLAYLIST]" Or FindString(sType, ":\", 1) Or FindString(sType, "http", 1) 
        ProcedureReturn #True
      EndIf
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure
Procedure PLS_ExportPlaylist(sFile.s="")
  Protected iFile.i, iRow.i
  If sFile=""
    sFile.s=SaveFileRequesterEx(Language(#L_SAVE), "", #GFP_PATTERN_PLAYLIST_EXPORT, 0)
  EndIf
  If sFile
    If GetExtensionPart(sFile)="":sFile+".m3u":EndIf
    iFile=CreateFile(#PB_Any, sFile)
    If iFile
    
      If *PLAYLISTDB
        If DB_Query(*PLAYLISTDB, "SELECT * FROM PLAYTRACKS WHERE playlist = '"+Str(Playlist\iTempID)+"'")
          While DB_SelectRow(*PLAYLISTDB, iRow)
             WriteStringN(iFile, DB_GetAsString(*PLAYLISTDB, 2))
            iRow+1
          Wend
        EndIf
        DB_EndQuery(*PLAYLISTDB)
      EndIf
      
      CloseFile(iFile)
    EndIf
  EndIf
EndProcedure
Procedure.s _PLS_ImportPlaylist_GetType(sFile.s, iReadFlag.i)
Protected iFile.i, sMediaFile.s
  iFile=ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
  If iFile
    While Eof(iFile) = 0 And sMediaFile=""
      sMediaFile=UCase(Trim(ReadString(iFile, iReadFlag.i)))
      If FindString(sMediaFile, "XML", 1)
        sMediaFile+UCase(Trim(ReadString(iFile, iReadFlag.i)))
        sMediaFile+UCase(Trim(ReadString(iFile, iReadFlag.i)))
        sMediaFile+UCase(Trim(ReadString(iFile, iReadFlag.i)))
      EndIf
    Wend
    CloseFile(iFile)
  EndIf
  If FindString(sMediaFile, "ASX", 1):sMediaFile="ASX":EndIf
  If FindString(sMediaFile, "<PLAYLIST", 1):sMediaFile="XSPF":EndIf
ProcedureReturn sMediaFile
EndProcedure

Procedure.s GetMediaPath(sPlaylist.s, sPlaytrack.s)
  
  If FindString(sPlaytrack, Chr(34), 1)
    ; Pfad scheint in Anführungszeichen zu sein
    sPlaytrack = Trim(sPlaytrack)
    If Left(sPlaytrack,1) = Chr(34) And Right(sPlaytrack,1) = Chr(34)
        sPlaytrack = Left(sPlaytrack, Len(sPlaytrack) - 1)
        sPlaytrack = Right(sPlaytrack, Len(sPlaytrack) - 1)       
    EndIf    
  EndIf
  
  If FindString(sPlaytrack, ":", 1) Or Left(sPlaytrack, 2) = "\\"  
    ; absoluter pfad, direkt zurückgeben
    ProcedureReturn sPlaytrack
  Else
    
    If Left(sPlaytrack, 1) = "\"
      sPlaytrack = Right(sPlaytrack, Len(sPlaytrack) - 1)
    EndIf    
    sPlaytrack = GetPathPart(sPlaylist) + sPlaytrack
    ProcedureReturn sPlaytrack
  EndIf
EndProcedure

Procedure _PLS_ImportPlaylist_M3U_Simple(sFile.s, sName.s, iReadFlag.i, iImport=#True);Player Standard Format
  Protected iFile.i, iRow.i, iPlaylist.i, sMediaFile.s, i.i
  If iImport
    DB_UpdateSync(*PLAYLISTDB,"INSERT INTO PLAYLISTS (name) VALUES ('" + sName.s + "')")
    LoadPlayList()
    ClearGadgetItems(#GADGET_LIST_TRACKLIST)
    iPlaylist=GetPlayListID(sName.s)
    Playlist\iTempID=iPlaylist
    DisableAddTracks(#False)
    SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME+" - " + Language(#L_PLAYLIST)+" "+sName)
  Else
    NewList TempPlaylist.s()
  EndIf
  
  iFile=ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
  If iFile
    While Eof(iFile) = 0
      sMediaFile=Trim(ReadString(iFile, iReadFlag.i))
      sMediaFile=GetMediaPath(sFile, sMediaFile)
      If iImport
        ;If FileSize(sMediaFile)>0
          ;Debug sMediaFile
          AddPlayListTrack(sMediaFile, iPlaylist)
        ;EndIf 
      Else
        ;If FileSize(sMediaFile)>0
          AddElement(TempPlaylist())
          TempPlaylist()=sMediaFile
        ;EndIf
      EndIf
    Wend
    CloseFile(iFile)
  EndIf
  
  
  If iImport
    LoadPlayListTracks(iPlaylist)
  Else
    Playlist\iItemCount = ListSize(TempPlaylist())-1
    Global Dim PlayListItems.PlayListItem(Playlist\iItemCount+1)
    ForEach TempPlaylist()
      PlayListItems(i)\sFile=TempPlaylist()
      i+1
    Next
    ClearList(TempPlaylist()) 
  EndIf
EndProcedure
Procedure _PLS_ImportPlaylist_M3U_Ext(sFile.s, sName.s, iReadFlag.i, iImport=#True)
  Protected iFile.i, iRow.i, iPlaylist.i, sMediaFile.s, pos, qLength.q, sTitle.s, i.i
  If iImport
    DB_UpdateSync(*PLAYLISTDB,"INSERT INTO PLAYLISTS (name) VALUES ('" + sName.s + "')")
    LoadPlayList()
    ClearGadgetItems(#GADGET_LIST_TRACKLIST)
    iPlaylist=GetPlayListID(sName.s)
    Playlist\iTempID=iPlaylist
    DisableAddTracks(#False)
    SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME+" - " + Language(#L_PLAYLIST)+" "+sName)
  Else
    NewList TempPlaylist.PlsArray()
  EndIf
  
  iFile=ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
  If iFile
    While Eof(iFile) = 0
      sMediaFile=Trim(ReadString(iFile, iReadFlag.i))
      If UCase(sMediaFile)="#EXTM3U":sMediaFile="":EndIf
      If FindString(UCase(sMediaFile), "#EXTINF",1)
        pos=FindString(sMediaFile, ",", 1)
        qLength.q = Val(Mid(sMediaFile, Len("#EXTINF:")+1, pos))
        sTitle.s = Mid(sMediaFile, pos+1)
        sMediaFile=""
        While Eof(iFile) = 0 And sMediaFile=""
          sMediaFile=Trim(ReadString(iFile, iReadFlag.i))
        Wend
      EndIf
      If sMediaFile<>""
        sMediaFile=GetMediaPath(sFile, sMediaFile)
        If iImport
          AddPlayListTrack(sMediaFile, iPlaylist, sTitle, qLength)
        Else
          AddElement(TempPlaylist())
          TempPlaylist()\sFile=sMediaFile
          TempPlaylist()\sTitle=sTitle
          TempPlaylist()\qLength=qLength
        EndIf
        
      EndIf
    Wend
    CloseFile(iFile)
  EndIf
  
  If iImport
    LoadPlayListTracks(iPlaylist)
  Else
    Playlist\iItemCount = ListSize(TempPlaylist())-1
    Global Dim PlayListItems.PlayListItem(Playlist\iItemCount+1)
    ForEach TempPlaylist()
      PlayListItems(i)\sFile=TempPlaylist()\sFile
      PlayListItems(i)\sTitle=TempPlaylist()\sTitle
      i+1
    Next
    ClearList(TempPlaylist()) 
  EndIf
EndProcedure
Procedure _PLS_ImportPlaylist_PLS(sFile.s, sName.s, iReadFlag.i, iImport=#True)
  Protected iFile.i, iRow.i, iPlaylist.i, sMediaFile.s, pos, qLength.q, sTitle.s
  Protected sNum.s, iheighstNum.i, iNum.i, iType.i, pos2.i, i.i
  If iImport
    DB_UpdateSync(*PLAYLISTDB,"INSERT INTO PLAYLISTS (name) VALUES ('" + sName.s + "')")
    LoadPlayList()
    ClearGadgetItems(#GADGET_LIST_TRACKLIST)
    iPlaylist=GetPlayListID(sName.s)
    Playlist\iTempID=iPlaylist
    DisableAddTracks(#False)
    SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME+" - " + Language(#L_PLAYLIST)+" "+sName)
  EndIf
  
  iFile=ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
  If iFile
    While Eof(iFile) = 0
      sMediaFile=UCase(Trim(ReadString(iFile, iReadFlag.i)))
      pos=0
      If Mid(sMediaFile, 1, Len("FILE"))="FILE":pos=Len("FILE"):EndIf
      If Mid(sMediaFile, 1, Len("TITLE"))="TITLE":pos=Len("TITLE"):EndIf
      If Mid(sMediaFile, 1, Len("LENGTH"))="LENGTH":pos=Len("LENGTH"):EndIf
      If pos
        sNum.s=Mid(sMediaFile, pos+1, FindString(sMediaFile, "=", pos)-pos-1)
        iNum=Val(sNum.s)
        If sNum.s=Str(iNum)
          If iheighstNum<iNum:iheighstNum=iNum:EndIf
        EndIf
      EndIf
    Wend
    
    Dim TempPlsArray.PlsArray(iheighstNum+1)
    FileSeek(iFile, 0)
    While Eof(iFile) = 0
      sMediaFile=Trim(ReadString(iFile, iReadFlag.i))
      pos=0
      If UCase(Mid(sMediaFile, 1, Len("FILE")))="FILE":pos=Len("FILE"):iType.i=1:EndIf
      If UCase(Mid(sMediaFile, 1, Len("TITLE")))="TITLE":pos=Len("TITLE"):iType.i=2:EndIf
      If UCase(Mid(sMediaFile, 1, Len("LENGTH")))="LENGTH":pos=Len("LENGTH"):iType.i=3:EndIf
      If pos
        pos2=FindString(sMediaFile, "=", pos)
        sNum.s=Trim(Mid(sMediaFile, pos+1, pos2-pos-1))
        iNum=Val(sNum.s)
        If sNum.s=Str(iNum) And iNum>=0
          If iType.i=1:TempPlsArray(iNum)\sFile=Trim(Mid(sMediaFile, pos2+1)):EndIf
          TempPlsArray(iNum)\sFile=GetMediaPath(sFile, TempPlsArray(iNum)\sFile)
          
          If iType.i=2:TempPlsArray(iNum)\sTitle=Trim(Mid(sMediaFile, pos2+1)):EndIf
          If iType.i=3:TempPlsArray(iNum)\qLength=Val(Trim(Mid(sMediaFile, pos2+1))):EndIf
        EndIf
      EndIf
    Wend
    
    If iImport
      For i=0 To iheighstNum
        If TempPlsArray(i)\sFile
          AddPlayListTrack(TempPlsArray(i)\sFile, iPlaylist, TempPlsArray(i)\sTitle, TempPlsArray(i)\qLength)
        EndIf
      Next
    Else
      Playlist\iItemCount = iheighstNum
      Global Dim PlayListItems.PlayListItem(Playlist\iItemCount+1)
      For i=0 To Playlist\iItemCount
        If TempPlsArray(i)\sFile
          PlayListItems(i)\sFile=TempPlsArray(i)\sFile
          PlayListItems(i)\sTitle=TempPlsArray(i)\sTitle
        EndIf
      Next
    EndIf
        
    CloseFile(iFile)
  EndIf
  
  
  If iImport
    LoadPlayListTracks(iPlaylist)
  EndIf
EndProcedure
Procedure _PLS_ImportPlaylist_ASX(sFile.s, sName.s, iReadFlag.i, iImport=#True)
  Protected iFile.i, iRow.i, iPlaylist.i, sMediaFile.s, pos, qLength.q, sTitle.s
  Protected length.q, sString.s, *MemoryID, sEntrys.s, sEntry.s, i.i, sAuthor.s
  Protected sDuration.s, qDuration.q, iCount.i, iD.i, sDescription.s
  If iImport
    DB_UpdateSync(*PLAYLISTDB,"INSERT INTO PLAYLISTS (name) VALUES ('" + sName.s + "')")
    LoadPlayList()
    ClearGadgetItems(#GADGET_LIST_TRACKLIST)
    iPlaylist=GetPlayListID(sName.s)
    Playlist\iTempID=iPlaylist
    DisableAddTracks(#False)
    SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME+" - " + Language(#L_PLAYLIST)+" "+sName)
  Else
    NewList TempPlaylist.PlsArray()
  EndIf
  
  iFile=ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
  If iFile
    length = Lof(iFile) 
    If length
      *MemoryID = AllocateMemory(length) 
      If *MemoryID
        ReadData(iFile, *MemoryID, length)
        sString.s = PeekS(*MemoryID, length, #PB_Ascii)
        FreeMemory(*MemoryID)
        sString = ReplaceString(sString, "<entry>", "<entry>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</entry>", "</entry>", #PB_String_NoCase)
        sString = ReplaceString(sString, "<title>", "<title>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</title>", "</title>", #PB_String_NoCase)
        sString = ReplaceString(sString, "<author>", "<author>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</author>", "</author>", #PB_String_NoCase)
        sString = ReplaceString(sString, "<abstract>", "<abstract>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</abstract>", "</abstract>", #PB_String_NoCase)
        sString = ReplaceString(sString, "<duration", "<duration", #PB_String_NoCase)
        sString = ReplaceString(sString, "<ref", "<ref", #PB_String_NoCase)
        ;-> Add Banner
        ;<BANNER HREF="http://sample.microsoft.com/art/banner1.bmp" />
        
        sEntrys.s = FindStringInBuffer(@sString, Len(sString), "<entry>", "</entry>")
        For i=1 To CountString(sEntrys.s, "|")+1
          sEntry.s = StringField(sEntrys+"|", i, "|")
          sTitle.s=FindStringInBuffer(@sEntry, Len(sEntry), "<title>", "</title>")
          sAuthor.s=FindStringInBuffer(@sEntry, Len(sEntry), "<author>", "</author>")
          sDescription.s=FindStringInBuffer(@sEntry, Len(sEntry), "<abstract>", "</abstract>")
          
          sDuration.s=FindTagValue(sEntry, "<duration")
          pos=FindString(sDuration, ".", 1)
          If pos
            sDuration=Mid(sDuration, 1, pos-1)
          EndIf
          sDuration.s=Trim(sDuration)
          sDuration=sDuration+":"
          iCount=0
          For iD=CountString(sDuration, ":") To 1 Step -1
            iCount+1
            If iCount=1
              qLength+Val(StringField(sDuration, 1, ":"))
            EndIf
            If iCount=2
              qLength+Val(StringField(sDuration, 1, ":"))*60
            EndIf
            If iCount=3
              qLength+Val(StringField(sDuration, 1, ":"))*60*60
            EndIf                        
          Next
          sMediaFile.s = FindTagValue(sEntry, "<ref")
          If sMediaFile
            sMediaFile=GetMediaPath(sFile, sMediaFile)
            If iImport
              AddPlayListTrack(sMediaFile, iPlaylist, sTitle, qLength, sDescription.s, sAuthor)
            Else
              AddElement(TempPlaylist())
              TempPlaylist()\sFile = sMediaFile
              TempPlaylist()\sTitle = sTitle
            EndIf
            
          EndIf
        Next
        
      EndIf
    EndIf
    CloseFile(iFile)
  EndIf
  
  
  If iImport
    LoadPlayListTracks(iPlaylist)
  Else
    Playlist\iItemCount = ListSize(TempPlaylist())-1
    Global Dim PlayListItems.PlayListItem(Playlist\iItemCount+1)
    ForEach TempPlaylist()
      PlayListItems(i)\sFile=TempPlaylist()\sFile
      PlayListItems(i)\sTitle=TempPlaylist()\sTitle
      i+1
    Next
    ClearList(TempPlaylist()) 
  EndIf
EndProcedure
Procedure _PLS_ImportPlaylist_XSPF(sFile.s, sName.s, iReadFlag.i, iImport=#True)
  Protected iFile.i, iRow.i, iPlaylist.i, sMediaFile.s, pos, qLength.q, sTitle.s
  Protected length.q, sString.s, *MemoryID, sEntrys.s, sEntry.s, i.i, sAuthor.s
  Protected sDuration.s, qDuration.q, iCount.i, iD.i, sDescription.s, iEntryLen.i, sAlbum.s
  If iImport
    DB_UpdateSync(*PLAYLISTDB,"INSERT INTO PLAYLISTS (name) VALUES ('" + sName.s + "')")
    LoadPlayList()
    ClearGadgetItems(#GADGET_LIST_TRACKLIST)
    iPlaylist=GetPlayListID(sName.s)
    Playlist\iTempID=iPlaylist
    DisableAddTracks(#False)
    SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME+" - " + Language(#L_PLAYLIST)+" "+sName)
  Else
    NewList TempPlaylist.PlsArray()
  EndIf
  
  iFile=ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
  If iFile
    length = Lof(iFile) 
    If length
      *MemoryID = AllocateMemory(length) 
      If *MemoryID
        ReadData(iFile, *MemoryID, length)
        sString.s = PeekS(*MemoryID, length, #PB_Ascii)
        FreeMemory(*MemoryID)
        sString = ReplaceString(sString, "<track>", "<track>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</track>", "</track>", #PB_String_NoCase)
        sString = ReplaceString(sString, "<title>", "<title>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</title>", "</title>", #PB_String_NoCase)
        sString = ReplaceString(sString, "<creator>", "<creator>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</creator>", "</creator>", #PB_String_NoCase)
        sString = ReplaceString(sString, "<annotation>", "<annotation>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</annotation>", "</annotation>", #PB_String_NoCase)
        sString = ReplaceString(sString, "<location>", "<location>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</location>", "</location>", #PB_String_NoCase)
        sString = ReplaceString(sString, "<album>", "<album>", #PB_String_NoCase)
        sString = ReplaceString(sString, "</album>", "</album>", #PB_String_NoCase)
        ;-> Add Image
        ;<image>http://images.amazon.com/images/P/B000002J0B.01.MZZZZZZZ.jpg</image>
        
        sEntrys.s = FindStringInBuffer(@sString, Len(sString), "<track>", "</track>")
        For i=1 To CountString(sEntrys.s, "|")+1
          sEntry.s = StringField(sEntrys+"|", i, "|")
          iEntryLen.i = Len(sEntry)
          sTitle.s=FindStringInBuffer(@sEntry, iEntryLen, "<title>", "</title>")
          sAuthor.s=FindStringInBuffer(@sEntry, iEntryLen, "<creator>", "</creator>")
          sDescription.s=FindStringInBuffer(@sEntry, iEntryLen, "<annotation>", "</annotation>")
          sAlbum.s=FindStringInBuffer(@sEntry, iEntryLen, "<album>", "</album>")
          qLength=Val(FindStringInBuffer(@sEntry, iEntryLen, "<duration>", "</duration>"))/1000

          sMediaFile.s = FindStringInBuffer(@sEntry, iEntryLen, "<location>", "</location>")
          If sMediaFile
            sMediaFile=GetMediaPath(sFile, sMediaFile)
            If iImport
              AddPlayListTrack(sMediaFile, iPlaylist, sTitle, qLength, sDescription.s, sAuthor, sAlbum)
            Else
              AddElement(TempPlaylist())
              TempPlaylist()\sFile = sMediaFile
              TempPlaylist()\sTitle = sTitle
            EndIf
          EndIf
        Next
        
      EndIf
    EndIf
    CloseFile(iFile)
  EndIf
  
  
  If iImport
    LoadPlayListTracks(iPlaylist)
  Else
    Playlist\iItemCount = ListSize(TempPlaylist())-1
    Global Dim PlayListItems.PlayListItem(Playlist\iItemCount+1)
    ForEach TempPlaylist()
      PlayListItems(i)\sFile=TempPlaylist()\sFile
      PlayListItems(i)\sTitle=TempPlaylist()\sTitle
      i+1
    Next
    ClearList(TempPlaylist()) 
  EndIf
EndProcedure

Procedure PLS_ImportPlaylist(sFile.s="", iReadFlag.i=-1, iImport=#True)
  Protected iFile.i, sName.s, sFileType.s
  If sFile.s=""
    sFile.s=OpenFileRequesterEx(Language(#L_LOAD), "", #GFP_PATTERN_PLAYLIST_IMPORT, 0)
  EndIf
  If sFile
    sName=Mid(GetFilePart(sFile), 1, FindString(GetFilePart(sFile), ".", 1)-1)
    If sName
      If IsWindow(#WINDOW_LIST)=#False And iImport
        CreateListWindow()
      EndIf
      If CheckPlayListName(sName) Or iImport=#False
        If iReadFlag.i=-1:iReadFlag.i=FILEINFO_GetFileFormat(sFile.s):EndIf
        If iReadFlag=#DATATYPE_TEXT_ASCII:iReadFlag=#PB_Ascii:EndIf
        If iReadFlag=#DATATYPE_TEXT_UNICODE:iReadFlag=#PB_Unicode:EndIf
        If iReadFlag=#DATATYPE_TEXT_UTF8:iReadFlag=#PB_UTF8:EndIf
        If iReadFlag=#DATATYPE_TEXT_UNKNOWN:iReadFlag=#PB_Ascii:EndIf
        
        sFileType.s=_PLS_ImportPlaylist_GetType(sFile.s, iReadFlag.i)
        ;Debug sFileType
        Select sFileType
        Case "ASX"
          _PLS_ImportPlaylist_ASX(sFile.s, sName.s, iReadFlag.i, iImport)
        Case "XSPF"
          _PLS_ImportPlaylist_XSPF(sFile.s, sName.s, iReadFlag.i, iImport)
        Case "#EXTM3U"
          _PLS_ImportPlaylist_M3U_Ext(sFile.s, sName.s, iReadFlag.i, iImport)
        Case "[PLAYLIST]"
          _PLS_ImportPlaylist_PLS(sFile.s, sName.s, iReadFlag.i, iImport)
        Default
          _PLS_ImportPlaylist_M3U_Simple(sFile.s, sName.s, iReadFlag.i, iImport);Player Standard Format
        EndSelect
        
      Else
        MessageBoxCheck(Language(#L_PLAYLIST), Language(#L_NAMEEXISTS), #MB_ICONERROR, "GFP_PLAYLIST_EXISTS "+#GFP_GUID)
      EndIf
    EndIf
  EndIf
  ProcedureReturn #True
EndProcedure


Procedure ShowCoverLogo(ChangeCover=#False)
  Protected iID
  
  iID = GetGadgetItemData(#GADGET_LIST_TRACKLIST,  GetGadgetState(#GADGET_LIST_TRACKLIST))
  If iPLS_CoverTrackID <> iID Or ChangeCover
    iPLS_CoverTrackID = iID
    If iPLS_CoverImage
      FreeImage(iPLS_CoverImage)
    EndIf
    iPLS_CoverImage=#False
    DB_Query(*PLAYLISTDB,"SELECT * FROM PLAYTRACKS WHERE (id = '" + Str(iID) + "') ")
    DB_SelectRow(*PLAYLISTDB, 0)
    iPLS_CoverID.i = DB_GetAsLong(*PLAYLISTDB, 9)
    DB_EndQuery(*PLAYLISTDB)
    If iPLS_CoverID
      iPLS_CoverImage = LoadCoverImage(*PLAYLISTDB, iPLS_CoverID)
      If iPLS_CoverImage
        If ImageWidth(iPLS_CoverImage)>ImageHeight(iPLS_CoverImage)
          ResizeImage(iPLS_CoverImage, 100, 100*ImageHeight(iPLS_CoverImage)/ImageWidth(iPLS_CoverImage), #PB_Image_Smooth)
        Else
          ResizeImage(iPLS_CoverImage, 100*ImageWidth(iPLS_CoverImage)/ImageHeight(iPLS_CoverImage), 100, #PB_Image_Smooth)
        EndIf
        SetGadgetState(#GADGET_LIST_IMAGE, ImageID(iPLS_CoverImage))
      EndIf
    EndIf
    If iPLS_CoverImage=#False
      SetGadgetState(#GADGET_LIST_IMAGE, ImageID(#SPRITE_NOIMAGE))
    EndIf
  EndIf

EndProcedure




; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 810
; FirstLine = 429
; Folding = RJof-
; EnableXP
; EnableUser
; UseMainFile = Player.pb
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
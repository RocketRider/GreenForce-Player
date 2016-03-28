;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
#GREENFORCE_PLUGIN_COVERFLOW_VERSION = 110

Structure VIS_CF_Tracks
  sFile.s
  sTitle.s
  iCoverID.i
  sInterpret.s
  sAlbum.s
  iID.i
  qOffset.q
EndStructure
Structure VIS_CF_Covers
  iTexture.IDirect3DTexture9
  iSprite.i
  iCoverID.i
  iWidth.i
  iHeight.i
EndStructure
Structure VIS_CF_Albums
  sInterpretAlbum.s
  sInterpret.s
  sAlbum.s
  sFile.s
  sTitle.s
  iCoverID.i
  iSprite.i
  fAlpha.f
  iWidth.i
  iHeight.i
  qOffset.q
EndStructure

Structure VIS_CF_MenuItems
  sText.s
  iLength.i
  fAlpha.f
  X.i
  iSelected.i
EndStructure

Global VIS_Coverflow_BK_Sprite, VIS_Coverflow_Light_Sprite, VIS_Coverflow_NoCover_Sprite
Global VIS_Coverflow_CoverEffect_Sprite
Global *VIS_Coverflow_BK_Texture.IDirect3DTexture9, *VIS_Coverflow_Light_Texture.IDirect3DTexture9
Global *VIS_Coverflow_NoCover_Texture.IDirect3DTexture9, *VIS_Coverflow_CoverEffect_Texture.IDirect3DTexture9
Global iVIS_Coverflow_Width, iVIS_Coverflow_Height
Global *VIS_Coverflow_D3DDevice.IDirect3DDevice9
Global *VIS_Coverflow_Font.Sprite2D_Font, VIS_Coverflow_SelectedAlbum.s, VIS_Coverflow_SelectedInterpret.s
Global VIS_Coverflow_Font_Alpha.i
Global VIS_CF_LanstItemsPos.i
Global VIS_CF_CoverScrollPos.i, VIS_CF_MouseOldPosX.i, VIS_CF_MouseOldPosY.i, VIS_CF_MouseButtonPressed
Global VIS_CF_CoverScrollSpeed.f, VIS_CF_CoverScrollRirection
Global *VIS_Coverflow_PlayingCover_Texture.IDirect3DTexture9, *VIS_Coverflow_PlayingCover_Sprite.DX9Sprite3D
Global sVIS_CF_Playing_track.s, VIS_CF_Selected3DCover.i
Global *VIS_Coverflow_BK2_Texture.IDirect3DTexture9, VIS_Coverflow_BK2_Sprite
Global *VIS_Coverflow_GFP_Texture.IDirect3DTexture9, VIS_Coverflow_GFP_Sprite
Global VIS_Coverflow_Counter
Global VIS_Coverflow_SortCovers.i

Global NewList VIS_CF_Tracks.VIS_CF_Tracks()
Global NewList VIS_CF_Covers.VIS_CF_Covers()
Global NewList VIS_CF_Albums.VIS_CF_Albums()
Global NewList VIS_CF_MenuItems.VIS_CF_MenuItems()




Procedure LoadCovers()
  Protected iRow.i, sText.s, iImageID.i, iType.i, *DB, iID.i, iFound.i
  Protected sFile.s, sTitle.s, sInterpret.s, sAlbum.s, iCoverID.i, iMemory.i
  Protected Width.f, Height.f, *Surface.IDirect3DSurface9
  Protected orgWidth.l, orgHeight.l, iCoverCount.i
  
  ClearList(VIS_CF_Tracks())
  ClearList(VIS_CF_Covers())
  ClearList(VIS_CF_Albums())
  
  *DB=DB_Open(sDataBaseFile)
  If *DB
    DB_Query(*DB, "SELECT * FROM PLAYTRACKS")
    While DB_SelectRow(*DB, iRow)
      iID.i = DB_GetAsLong(*DB, 1);ID
      sFile.s = ConvertStringDBCompartible(DB_GetAsString(*DB, 2), #False);File
      sTitle.s = ConvertStringDBCompartible(DB_GetAsString(*DB, 5), #False);Title
      sInterpret.s = ConvertStringDBCompartible(DB_GetAsString(*DB, 7), #False);Interpret
      sAlbum.s = ConvertStringDBCompartible(DB_GetAsString(*DB, 8), #False);Album
      iCoverID.i = DB_GetAsLong(*DB, 9);Cover
      If sTitle="":sTitle=GetFilePart(sFile):EndIf
      
      AddElement(VIS_CF_Tracks())
      VIS_CF_Tracks()\iID=iID
      VIS_CF_Tracks()\sFile=sFile
      VIS_CF_Tracks()\sTitle=sTitle
      VIS_CF_Tracks()\iCoverID=iCoverID
      VIS_CF_Tracks()\sInterpret=sInterpret
      VIS_CF_Tracks()\sAlbum=sAlbum
      
      iRow+1
    Wend
    DB_EndQuery(*DB)
    
    
    
    ForEach VIS_CF_Tracks()
      If VIS_CF_Tracks()\iCoverID>0
        iFound=#False
        ForEach VIS_CF_Covers()
          If VIS_CF_Tracks()\iCoverID=VIS_CF_Covers()\iCoverID:iFound=#True:Break:EndIf
        Next
        If iFound=#False 
          If iCoverCount<250;DIRTY FIX, IF TO MUCH COVERS
            iMemory = GetCover(*DB, VIS_CF_Tracks()\iCoverID)
            If iMemory
              ;Debug iCoverCount
              iCoverCount+1
              AddElement(VIS_CF_Covers())
              VIS_CF_Covers()\iCoverID=VIS_CF_Tracks()\iCoverID
              VIS_CF_Covers()\iTexture = CatchD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, iMemory, #True, 512, @orgWidth, @orgHeight)
              If VIS_CF_Covers()\iTexture
                VIS_CF_Covers()\iSprite = Sprite2D_Create(VIS_CF_Covers()\iTexture)
                Width = orgWidth
                Height = orgHeight
                If Width = Height
                  Width = 100
                  Height = 100
                Else
                  If Width>Height
                    Width = 100
                    Height = 100 * orgHeight/orgWidth
                  Else
                    Height = 100
                    Width = 100 * orgWidth/orgHeight
                  EndIf
                EndIf
                VIS_CF_Covers()\iWidth=Width
                VIS_CF_Covers()\iHeight=Height  
              Else
                VIS_CF_Tracks()\iCoverID=0;If the Cover is not loaded, set it to the default
              EndIf
            Else
              VIS_CF_Tracks()\iCoverID=0;If the Cover is not loaded, set it to the default
            EndIf
          Else
            VIS_CF_Tracks()\iCoverID=0;If the Cover is not loaded, set it to the default
          EndIf
        EndIf
      EndIf
    Next
    
    ForEach VIS_CF_Tracks()
      If VIS_CF_Tracks()\sInterpret<>"" Or VIS_CF_Tracks()\sAlbum <> ""
        iFound=#False
        ForEach VIS_CF_Albums()
          If VIS_CF_Albums()\sInterpretAlbum=VIS_CF_Tracks()\sInterpret+" "+VIS_CF_Tracks()\sAlbum:iFound=#True:Break:EndIf
        Next
        If iFound=#False      
          AddElement(VIS_CF_Albums())
          VIS_CF_Albums()\fAlpha = 255
          VIS_CF_Albums()\sInterpretAlbum=VIS_CF_Tracks()\sInterpret+" "+VIS_CF_Tracks()\sAlbum
          VIS_CF_Albums()\sInterpret=VIS_CF_Tracks()\sInterpret
          VIS_CF_Albums()\sAlbum=VIS_CF_Tracks()\sAlbum
          VIS_CF_Albums()\iCoverID=VIS_CF_Tracks()\iCoverID
          
          If VIS_CF_Albums()\iCoverID = #Null
            VIS_CF_Albums()\iSprite = VIS_Coverflow_NoCover_Sprite
            VIS_CF_Albums()\iWidth=100
            VIS_CF_Albums()\iHeight=100
          Else
            ForEach VIS_CF_Covers()
              If VIS_CF_Albums()\iCoverID=VIS_CF_Covers()\iCoverID
                VIS_CF_Albums()\iSprite = VIS_CF_Covers()\iSprite
                VIS_CF_Albums()\iWidth=VIS_CF_Covers()\iWidth
                VIS_CF_Albums()\iHeight=VIS_CF_Covers()\iHeight
                Break
              EndIf
            Next
            If VIS_CF_Albums()\iSprite=0
              VIS_CF_Albums()\iSprite = VIS_Coverflow_NoCover_Sprite
            EndIf
          EndIf
        EndIf
      EndIf
    Next
    SortStructuredList(VIS_CF_Albums(), #PB_Sort_NoCase, OffsetOf(VIS_CF_Albums\sInterpretAlbum), #PB_String)
    
    DB_Close(*DB)
    
    VIS_Coverflow_SelectedInterpret=""
    VIS_Coverflow_SelectedAlbum=""
  EndIf
EndProcedure

Procedure LoadAlbumPlaylist()
  Protected iCount.i, i.i
  ;Count the Track items

  ForEach VIS_CF_Tracks()
    If VIS_CF_Albums()\sInterpretAlbum = VIS_CF_Tracks()\sInterpret+" "+VIS_CF_Tracks()\sAlbum
      iCount+1
    EndIf
  Next
  
  Playlist\iID = #True
  Playlist\iItemCount = iCount-1
  Global Dim PlayListItems.PlayListItem(Playlist\iItemCount+1)
  i=0
  ForEach VIS_CF_Tracks()
    If VIS_CF_Albums()\sInterpretAlbum = VIS_CF_Tracks()\sInterpret+" "+VIS_CF_Tracks()\sAlbum
      PlayListItems(i)\sFile=VIS_CF_Tracks()\sFile
      PlayListItems(i)\sTitle=GetFilePart(VIS_CF_Tracks()\sFile)
      PlayListItems(i)\qOffset = VIS_CF_Tracks()\qOffset
      If VIS_CF_Tracks()\sTitle:PlayListItems(i)\sTitle=VIS_CF_Tracks()\sTitle:EndIf
      If VIS_CF_Tracks()\sInterpret
        PlayListItems(i)\sTitle = VIS_CF_Tracks()\sInterpret + " - " + PlayListItems(i)\sTitle
      EndIf
      i+1
    EndIf
  Next

EndProcedure


Procedure Add_VIS_CF_MenuItem(sText.s, iLength.i, iSelected.i=#False)
  AddElement(VIS_CF_MenuItems())
  VIS_CF_MenuItems()\sText=sText
  VIS_CF_MenuItems()\iLength=iLength
  VIS_CF_MenuItems()\fAlpha=150
  VIS_CF_MenuItems()\X = VIS_CF_LanstItemsPos
  VIS_CF_MenuItems()\iSelected=iSelected
  VIS_CF_LanstItemsPos+iLength+5
EndProcedure
Procedure Draw_VIS_CF_Menu(iHeight.i, iWidth.i, iMouseX.i, iMouseY.i, iLeftMButton.i)
  Protected iColor.i, iIndex.i
  Sprite2D_Zoom(VIS_Coverflow_BK_Sprite, iWidth, 25)
  Sprite2D_DisplayEx(VIS_Coverflow_BK_Sprite, 0, iHeight-25, 150)
  
  Sprite2D_Zoom(VIS_Coverflow_BK_Sprite, 5, 25)
  ForEach VIS_CF_MenuItems()
    Sprite2D_DisplayEx(VIS_Coverflow_BK_Sprite, VIS_CF_MenuItems()\X+2, iHeight-25, 250)
    If VIS_CF_MenuItems()\iSelected
      iColor = RGBA(255,255,255, VIS_CF_MenuItems()\fAlpha)
    Else
      iColor = RGBA(150,150,150, VIS_CF_MenuItems()\fAlpha)
    EndIf
    Sprite2D_DrawFont(*VIS_Coverflow_Font, VIS_CF_MenuItems()\X, iHeight-22, VIS_CF_MenuItems()\sText, iColor, 5)
    If iMouseY>iHeight-25 And iMouseY<iHeight
      If iMouseX>VIS_CF_MenuItems()\X+7 And iMouseX<VIS_CF_MenuItems()\X+VIS_CF_MenuItems()\iLength
        VIS_CF_MenuItems()\fAlpha+20
        If iLeftMButton
          iIndex=ListIndex(VIS_CF_MenuItems())
          ForEach VIS_CF_MenuItems()
            VIS_CF_MenuItems()\iSelected = #False
          Next
          SelectElement(VIS_CF_MenuItems(), iIndex)
          
          VIS_CF_MenuItems()\iSelected = #True
        EndIf
      EndIf
    EndIf
    VIS_CF_MenuItems()\fAlpha-10
    If VIS_CF_MenuItems()\fAlpha>255:VIS_CF_MenuItems()\fAlpha=255:EndIf
    If VIS_CF_MenuItems()\fAlpha<150:VIS_CF_MenuItems()\fAlpha=150:EndIf
  Next
  Sprite2D_DisplayEx(VIS_Coverflow_BK_Sprite, VIS_CF_MenuItems()\X+2+VIS_CF_MenuItems()\iLength, iHeight-25, 250)
EndProcedure

Procedure LoadPlayingCover()
  Protected sCoverFile.s, CoverImage, *Header, res.i
  If MediaFile\sRealFile<>sVIS_CF_Playing_track
    If *VIS_Coverflow_PlayingCover_Sprite:Sprite2D_Free(*VIS_Coverflow_PlayingCover_Sprite):*VIS_Coverflow_PlayingCover_Sprite=#Null:EndIf
    If *VIS_Coverflow_PlayingCover_Texture:*VIS_Coverflow_PlayingCover_Texture\Release():*VIS_Coverflow_PlayingCover_Texture=#Null:EndIf
  
    sVIS_CF_Playing_track=MediaFile\sRealFile
    
    If isFileEncrypted(sVIS_CF_Playing_track)
      ;ReadDRMHeader(sVIS_CF_Playing_track, *GFP_DRM_HEADER, "RR is Testing")
      ;CoverImage = GetDRMHeaderCover(*GFP_DRM_HEADER)
      *Header = DRMV2Read_ReadFromFile(sVIS_CF_Playing_track, "Default", 0)
      If *Header
        CoverImage = DRMV2Read_GetCoverImage(*Header)
        DRMV2Read_Free(*Header)
      EndIf  
      
      
      If CoverImage
        *VIS_Coverflow_PlayingCover_Texture=LoadD3DTexture9FromPBImage(*VIS_Coverflow_D3DDevice, CoverImage)
        FreeImage(CoverImage)
        If *VIS_Coverflow_PlayingCover_Texture
          *VIS_Coverflow_PlayingCover_Sprite = Sprite2D_Create(*VIS_Coverflow_PlayingCover_Texture)
        EndIf
      EndIf
    Else
      LoadMetaFile(sVIS_CF_Playing_track)
      If MediaInfoData\iHasAttachedImages And MediaInfoData\pPicture And MediaInfoData\iPictureSize
        *VIS_Coverflow_PlayingCover_Texture = CatchD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, MediaInfoData\pPicture)
        If *VIS_Coverflow_PlayingCover_Texture
          *VIS_Coverflow_PlayingCover_Sprite = Sprite2D_Create(*VIS_Coverflow_PlayingCover_Texture)
        EndIf
      Else
        If MediaInfoData\sGUID
          sCoverFile.s=GetPathPart(sVIS_CF_Playing_track)+"\"+"AlbumArt_"+MediaInfoData\sGUID+"_Large.jpg"
          If FileSize(sCoverFile)>0
            *VIS_Coverflow_PlayingCover_Texture = LoadD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, sCoverFile)
            If *VIS_Coverflow_PlayingCover_Texture
              *VIS_Coverflow_PlayingCover_Sprite = Sprite2D_Create(*VIS_Coverflow_PlayingCover_Texture)
            EndIf
          Else
            sCoverFile.s=GetPathPart(sVIS_CF_Playing_track)+"\"+"AlbumArt_"+MediaInfoData\sGUID+"_Large.png"
            If FileSize(sCoverFile)>0
              *VIS_Coverflow_PlayingCover_Texture = LoadD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, sCoverFile)
              If *VIS_Coverflow_PlayingCover_Texture
                *VIS_Coverflow_PlayingCover_Sprite = Sprite2D_Create(*VIS_Coverflow_PlayingCover_Texture)
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    
    EndIf
    
    
    
  EndIf
EndProcedure


Procedure LoadCoverFlowFormAttachment(sFile.s)
  Protected i.i, Num.i, FileStruc.EXE_ATTACHMENT_FILEENTRY
  Protected orgWidth.i, orgHeight.i, Width.i, Height.i, image, *mem, res.i, *Header
  VIS_SetVIS(#VIS_COVERFLOW)
  VIS_Coverflow_SortCovers=#False
    
  ClearList(VIS_CF_Tracks())
  ClearList(VIS_CF_Covers())
  ClearList(VIS_CF_Albums())
  
  If OpenEXEAttachements(sFile)
    Num.i=GetNumEXEAttachments()
    If Num>0
      For i=0 To Num-1
        If ReadEXEAttachment(i, FileStruc)
          If FileStruc\filename<>"*COMMANDS*"
          
  ;           Debug FileStruc\filename
  ;           *mem=ExtractEXEAttachmentToMem(FileStruc\filename)
  ;           CreateFile(22, Str(i)+".gfp")
  ;           WriteData(22, *mem, FileStruc\size)
  ;           CloseFile(22)
  ;           FreeMemory(*mem)
            
            ;ReadDRMHeader(sFile, *GFP_DRM_HEADER, "RR is Testing", FileStruc\absoluteOffset)
            ;TestDecryptPW(sFile, FileStruc\absoluteOffset)
            ;If CheckDRMHeader(*GFP_DRM_HEADER, sGlobalPassword)<>#DRM_OK
  ;           If TestDecryptPW(sFile, FileStruc\absoluteOffset)
  ;             VIS_SetVIS(#VIS_OFF)
  ;             ProcedureReturn #False
  ;           EndIf  
              
            AddElement(VIS_CF_Tracks())
            VIS_CF_Tracks()\sFile = sFile
            VIS_CF_Tracks()\iID = i
            VIS_CF_Tracks()\qOffset = FileStruc\absoluteOffset
                      
            
  ;OLD DRM VERSION          
  ;           VIS_CF_Tracks()\sAlbum = GetDRMHeaderAlbum(*GFP_DRM_HEADER)
  ;           VIS_CF_Tracks()\sInterpret = GetDRMHeaderInterpreter(*GFP_DRM_HEADER)
  ;           VIS_CF_Tracks()\sTitle = GetDRMHeaderTitle(*GFP_DRM_HEADER)
  ;           image=GetDRMHeaderCover(*GFP_DRM_HEADER)
            
            
            *Header = DRMV2Read_ReadFromFile(sFile, "Default", VIS_CF_Tracks()\qOffset)
            If *Header
              VIS_CF_Tracks()\sAlbum = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_ALBUM)
              VIS_CF_Tracks()\sInterpret = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_INTERPRETER)
              VIS_CF_Tracks()\sTitle = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_TITLE)
              image=DRMV2Read_GetCoverImage(*Header)
              DRMV2Read_Free(*Header)
            EndIf 
        
  
            
            
            If image
              AddElement(VIS_CF_Covers())
              VIS_CF_Covers()\iTexture =  LoadD3DTexture9FromPBImage(*VIS_Coverflow_D3DDevice, image, #False, 512, @orgWidth, @orgHeight)
              If VIS_CF_Covers()\iTexture
                VIS_CF_Tracks()\iCoverID = i
                VIS_CF_Covers()\iCoverID = VIS_CF_Tracks()\iCoverID
                VIS_CF_Covers()\iSprite = Sprite2D_Create(VIS_CF_Covers()\iTexture)
                Width = orgWidth
                Height = orgHeight
                If Width = Height
                  Width = 100
                  Height = 100
                Else
                  If Width>Height
                    Width = 100
                    Height = 100 * orgHeight/orgWidth
                  Else
                    Height = 100
                    Width = 100 * orgWidth/orgHeight
                  EndIf
                EndIf
                VIS_CF_Covers()\iWidth=Width
                VIS_CF_Covers()\iHeight=Height 
              EndIf  
              FreeImage(image)
            EndIf
            
            
            AddElement(VIS_CF_Albums())
            
            ;
              If image And VIS_CF_Covers()\iSprite
                VIS_CF_Albums()\iSprite = VIS_CF_Covers()\iSprite
                VIS_CF_Albums()\iCoverID = VIS_CF_Covers()\iCoverID
                VIS_CF_Albums()\iWidth = VIS_CF_Covers()\iWidth
                VIS_CF_Albums()\iHeight = VIS_CF_Covers()\iHeight
              Else
                VIS_CF_Albums()\iSprite = VIS_Coverflow_NoCover_Sprite
                VIS_CF_Albums()\iWidth=100
                VIS_CF_Albums()\iHeight=100
              EndIf
              
            ;EndIf
            
            VIS_CF_Albums()\fAlpha = 255
            VIS_CF_Albums()\sInterpretAlbum=VIS_CF_Tracks()\sInterpret+" "+VIS_CF_Tracks()\sAlbum
            VIS_CF_Albums()\sInterpret=VIS_CF_Tracks()\sInterpret
            VIS_CF_Albums()\sAlbum=VIS_CF_Tracks()\sAlbum
            
            If VIS_CF_Albums()\iSprite=0
              VIS_CF_Albums()\iSprite = VIS_Coverflow_NoCover_Sprite
              VIS_CF_Albums()\iWidth=100
              VIS_CF_Albums()\iHeight=100
            EndIf
            ;VIS_CF_Albums()\ = VIS_CF_Covers()\iCoverID
            
            VIS_CF_Albums()\sFile=VIS_CF_Tracks()\sFile
            VIS_CF_Albums()\sTitle=VIS_CF_Tracks()\sTitle
            VIS_CF_Albums()\qOffset=VIS_CF_Tracks()\qOffset
            
          EndIf
        EndIf
      Next
    EndIf  
  EndIf
  
  ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, 640, 480)
EndProcedure


ProcedureDLL VIS_Coverflow_Init(*p.IVisualisationCanvas)
  sVIS_CF_Playing_track=""
  ;Create the Direct3D device
  *VIS_Coverflow_D3DDevice.IDirect3DDevice9 = *p\GetD3DDevice9()
  Sprite2D_Init(*VIS_Coverflow_D3DDevice, 640, 480)
  Sprite2D_SetQuality(#True)
  
  
  
  ;Load the Textures
  *VIS_Coverflow_BK_Texture = CatchD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, ?DS_VIS_DCT_BK)
  *VIS_Coverflow_BK2_Texture = CatchD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, ?DS_VIS_CF_BK2)
  *VIS_Coverflow_Light_Texture = CatchD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, ?DS_VIS_WhiteLight_WL)
  *VIS_Coverflow_NoCover_Texture = CatchD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, ?DS_VIS_CF_NoCover)
  *VIS_Coverflow_CoverEffect_Texture = CatchD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, ?DS_VIS_CF_CoverEffect)
  *VIS_Coverflow_GFP_Texture = CatchD3DTexture9FromImage(*VIS_Coverflow_D3DDevice, ?DS_VIS_CF_GFP)


  ;Creates the 2D sprites
  VIS_Coverflow_BK_Sprite = Sprite2D_Create(*VIS_Coverflow_BK_Texture)
  VIS_Coverflow_BK2_Sprite = Sprite2D_Create(*VIS_Coverflow_BK2_Texture)
  VIS_Coverflow_Light_Sprite = Sprite2D_Create(*VIS_Coverflow_Light_Texture)
  VIS_Coverflow_NoCover_Sprite = Sprite2D_Create(*VIS_Coverflow_NoCover_Texture)
  VIS_Coverflow_CoverEffect_Sprite = Sprite2D_Create(*VIS_Coverflow_CoverEffect_Texture)
  VIS_Coverflow_GFP_Sprite = Sprite2D_Create(*VIS_Coverflow_GFP_Texture)
  ;Sprite2D_Color(VIS_Coverflow_BK_Sprite, RGBA(255,100,100,255), RGBA(255,100,100,255), RGBA(255,100,100,255), RGBA(255,100,100,255))  
  Sprite2D_Color(VIS_Coverflow_BK_Sprite, RGBA(255,100,100,255), RGBA(255,100,100,255), RGBA(125,40,40,255), RGBA(125,40,40,255))  
  
  *VIS_Coverflow_Font = Sprite2D_CatchFont(*VIS_Coverflow_D3DDevice, ?DS_Sprite2D_Font)
  
  
  
  ClearList(VIS_CF_MenuItems()):VIS_CF_LanstItemsPos=0
  Add_VIS_CF_MenuItem("2D", 30)
  Add_VIS_CF_MenuItem("3D", 30, #True)
  ;Add_VIS_CF_MenuItem("Special", 80)
  
  VIS_Coverflow_SelectedInterpret.s=""
  VIS_Coverflow_SelectedAlbum.s=""
  
  VIS_Coverflow_SortCovers=#True
  
  LoadCovers()
  *p\Clear(#Black)
  ProcedureReturn #True
EndProcedure

ProcedureDLL VIS_Coverflow_Run(*p.IVisualisationCanvas)
  Protected t.i, x.i, y.i, i.i, iColor, iWidth, iHeight, c.f
  Protected iPictureSize.i, iMouseX.i, iMouseY.i, iLeftMButton.i
  Protected len1.i, len2.i, MouseOldPosX, MouseOldPosY, MouseOldPressed
  Protected iCoverWidth, iCoverHeight, temp.f, MaxScroll.i
  Protected Clearscreen
  Protected sLoadMediaFile.s, sLoadMediaFileTitle.s, qLoadMediaFileOffset.q
  
  ;Sets the screensize
  iWidth=*p\GetWidth()
  iHeight=*p\GetHeight()
  iMouseX = WindowMouseX(#WINDOW_MAIN)-GadgetX(#GADGET_VIDEO_CONTAINER)
  iMouseY = WindowMouseY(#WINDOW_MAIN)-GadgetY(#GADGET_VIDEO_CONTAINER)
  MouseOldPressed=VIS_CF_MouseButtonPressed
  MouseOldPosX=VIS_CF_MouseOldPosX
  MouseOldPosY=VIS_CF_MouseOldPosY  
  If GetAsyncKeyState_(#VK_LBUTTON)<>0 And GetActiveWindow() = #WINDOW_MAIN
    iLeftMButton=#True
    VIS_CF_MouseOldPosX=iMouseX
    VIS_CF_MouseOldPosY=iMouseY
    VIS_CF_MouseButtonPressed=#True
  Else
    VIS_CF_MouseOldPosX=0
    VIS_CF_MouseOldPosY=0
    VIS_CF_MouseButtonPressed=#False
  EndIf
  
  If iVIS_Coverflow_Width <> iWidth Or iVIS_Coverflow_Height <> iHeight:Clearscreen=#True:EndIf
  iVIS_Coverflow_Width = iWidth
  iVIS_Coverflow_Height = iHeight
  Sprite2D_SetScreenSize(iWidth, iHeight)
  
  
  If *p\CanRender()
    If Clearscreen:*p\Clear(#Black):EndIf
    If *p\BeginScene()
      If Sprite2D_Start()
        
        ;Draw the background
        Sprite2D_Zoom(VIS_Coverflow_BK_Sprite, iWidth, iHeight)
        Sprite2D_DisplayEx(VIS_Coverflow_BK_Sprite, 0, 0, 100)
        
        
        
       
        
        ;Coverflow 2D:
        SelectElement(VIS_CF_MenuItems(), 0)
        If VIS_CF_MenuItems()\iSelected
          ;Cover drawing
          X=10-VIS_CF_CoverScrollPos
          Y=10
          iPictureSize=150
          If VIS_Coverflow_Font_Alpha>0:VIS_Coverflow_Font_Alpha-20:EndIf
          ForEach VIS_CF_Albums()
            If iMouseX>X And iMouseX<X + VIS_CF_Albums()\iWidth * iPictureSize/100 And iMouseY>Y And iMouseY<Y+VIS_CF_Albums()\iHeight * iPictureSize/100; Mouse over cover.
              If VIS_CF_Albums()\fAlpha<250:VIS_CF_Albums()\fAlpha+5:EndIf
              If iLeftMButton=#False And MouseOldPressed=#True And MouseOldPosX=iMouseX And MouseOldPosY=iMouseY
                LoadAlbumPlaylist()
                Playlist\iCurrentMedia = 0
                ;LoadMediaFile(PlayListItems(0)\sFile, #True, PlayListItems(0)\sTitle)
                sLoadMediaFile.s=PlayListItems(0)\sFile
                sLoadMediaFileTitle.s=PlayListItems(0)\sTitle
                qLoadMediaFileOffset=PlayListItems(0)\qOffset
              EndIf
              VIS_Coverflow_Font_Alpha+30
              VIS_Coverflow_SelectedInterpret.s=VIS_CF_Albums()\sInterpret
              VIS_Coverflow_SelectedAlbum.s=VIS_CF_Albums()\sAlbum
            Else
              If VIS_CF_Albums()\fAlpha>150:VIS_CF_Albums()\fAlpha-5:EndIf
            EndIf
            Sprite2D_Zoom(VIS_Coverflow_CoverEffect_Sprite, VIS_CF_Albums()\iWidth * iPictureSize/100 + 40, VIS_CF_Albums()\iHeight * iPictureSize/100 + 40)
            Sprite2D_DisplayEx(VIS_Coverflow_CoverEffect_Sprite, X-20, Y-20, (VIS_CF_Albums()\fAlpha-140)*2)
            Sprite2D_Zoom(VIS_CF_Albums()\iSprite, VIS_CF_Albums()\iWidth * iPictureSize/100, VIS_CF_Albums()\iHeight * iPictureSize/100)
            Sprite2D_DisplayEx(VIS_CF_Albums()\iSprite, X, Y, VIS_CF_Albums()\fAlpha)
            Y+iPictureSize+20
            If (Y+iPictureSize+30)>iHeight:Y=10:X+iPictureSize+20:EndIf
          Next
  
          
          ;Cover title:
          If VIS_Coverflow_Font_Alpha>0 And iMouseX>0 And iMouseY>0 And (VIS_Coverflow_SelectedInterpret<>"" Or VIS_Coverflow_SelectedAlbum<>"")
            If VIS_Coverflow_Font_Alpha>255:VIS_Coverflow_Font_Alpha=255:EndIf
            If *VIS_Coverflow_Font
              len1=(Len(VIS_Coverflow_SelectedInterpret)+2)* *VIS_Coverflow_Font\DWidth*6/20
              len2=(Len(VIS_Coverflow_SelectedAlbum)+2)* *VIS_Coverflow_Font\DWidth*6/20
              If len2>len1:len1=len2:EndIf
            EndIf
            Sprite2D_Zoom(VIS_Coverflow_NoCover_Sprite, len1, 38)
            Sprite2D_Color(VIS_Coverflow_NoCover_Sprite, RGBA(50,50,50,255), RGBA(50,50,50,255), RGBA(50,50,50,255), RGBA(50,50,50,255))  
            Sprite2D_DisplayEx(VIS_Coverflow_NoCover_Sprite, iMouseX+5, iMouseY+5, VIS_Coverflow_Font_Alpha/2)
            Sprite2D_Color(VIS_Coverflow_NoCover_Sprite, RGBA(255,255,255,255), RGBA(255,255,255,255), RGBA(255,255,255,255), RGBA(255,255,255,255))  
            If *VIS_Coverflow_Font
              Sprite2D_DrawFont(*VIS_Coverflow_Font, iMouseX+5, iMouseY+5, VIS_Coverflow_SelectedInterpret.s, RGBA(255,255,255,VIS_Coverflow_Font_Alpha), 6)
              Sprite2D_DrawFont(*VIS_Coverflow_Font, iMouseX+5, iMouseY+20, VIS_Coverflow_SelectedAlbum, RGBA(255,255,255,VIS_Coverflow_Font_Alpha), 6)
            EndIf
          EndIf      
          
          ;Cover scrolling:
          If iMouseY>0 And iMouseY<iHeight    
            If MouseOldPosX>0 And MouseOldPosY>0
              VIS_CF_CoverScrollSpeed+Pow(MouseOldPosX-iMouseX, 2)
              If MouseOldPosX>iMouseX
                VIS_CF_CoverScrollRirection=#True
              EndIf
              If MouseOldPosX<iMouseX
                VIS_CF_CoverScrollRirection=#False
              EndIf
            EndIf
          EndIf
          VIS_CF_CoverScrollSpeed/1.5
          If VIS_CF_CoverScrollRirection
            VIS_CF_CoverScrollPos+Sqr(VIS_CF_CoverScrollSpeed)
          Else
            VIS_CF_CoverScrollPos-Sqr(VIS_CF_CoverScrollSpeed)
          EndIf
          If VIS_CF_CoverScrollPos>X+VIS_CF_CoverScrollPos+iPictureSize-iWidth:VIS_CF_CoverScrollPos=X+VIS_CF_CoverScrollPos+iPictureSize-iWidth:EndIf
          If VIS_CF_CoverScrollPos<0:VIS_CF_CoverScrollPos=VIS_CF_CoverScrollPos-VIS_CF_CoverScrollPos/2:EndIf
        EndIf
        
        
        ;Coverflow 3D:
        SelectElement(VIS_CF_MenuItems(), 1)
        If VIS_CF_MenuItems()\iSelected
          iPictureSize=iHeight/2
          X=(iWidth-iPictureSize)/2-VIS_CF_Selected3DCover*iPictureSize/5-VIS_CF_CoverScrollPos
          Y=(iHeight-30-iPictureSize)/2
          i=0
          ForEach VIS_CF_Albums()
            
            iCoverWidth = VIS_CF_Albums()\iWidth * iPictureSize/100
            iCoverHeight = VIS_CF_Albums()\iHeight * iPictureSize/100
            
            If i<VIS_CF_Selected3DCover
              ;Sprite2D_Transform(VIS_CF_Albums()\iSprite, 0, 0, iCoverWidth/4, iCoverHeight/8, iCoverWidth/4, iCoverHeight-iCoverHeight/8, 0, iCoverHeight)
              Sprite2DHelper_TransformHorizontal(VIS_CF_Albums()\iSprite, 0, 0, iCoverWidth/4, iCoverHeight/8, iCoverWidth/4, iCoverHeight-iCoverHeight/8, 0, iCoverHeight)
              Sprite2D_DisplayEx(VIS_CF_Albums()\iSprite, X, Y+(iPictureSize-iCoverHeight)/2, 240)
              X+iPictureSize/5
            EndIf
            If i=VIS_CF_Selected3DCover
              Sprite2D_Zoom(VIS_CF_Albums()\iSprite, iCoverWidth, iCoverHeight)
              Sprite2D_DisplayEx(VIS_CF_Albums()\iSprite, X, Y+(iPictureSize-iCoverHeight)/2, 240)
              VIS_Coverflow_SelectedInterpret=VIS_CF_Albums()\sInterpret
              VIS_Coverflow_SelectedAlbum=VIS_CF_Albums()\sAlbum
              
              If iLeftMButton=#False And MouseOldPressed=#True And MouseOldPosX=iMouseX And MouseOldPosY=iMouseY
                If iMouseX>X And iMouseX<X+iCoverWidth
                  If iMouseY>Y+(iPictureSize-iCoverHeight)/2 And iMouseY<Y+(iPictureSize-iCoverHeight)/2+iCoverHeight
                    If VIS_Coverflow_SortCovers
                      LoadAlbumPlaylist()
                      Playlist\iCurrentMedia = 0
                      ;LoadMediaFile(PlayListItems(0)\sFile, #True, PlayListItems(0)\sTitle)
                      sLoadMediaFile.s=PlayListItems(0)\sFile
                      sLoadMediaFileTitle.s=PlayListItems(0)\sTitle
                      qLoadMediaFileOffset=PlayListItems(0)\qOffset
                    Else
                      Playlist\iID = #False
                      Playlist\iItemCount = 0
                      sLoadMediaFile=VIS_CF_Albums()\sFile
                      sLoadMediaFileTitle = VIS_CF_Albums()\sInterpret + " - " + VIS_CF_Albums()\sTitle
                      qLoadMediaFileOffset = VIS_CF_Albums()\qOffset
                    EndIf
                  EndIf
                EndIf
              EndIf
              
              X+iCoverWidth
            EndIf     
            If i>VIS_CF_Selected3DCover
              Break
            EndIf          
            
            i+1
          Next
          X+iPictureSize/5*(ListSize(VIS_CF_Albums())-VIS_CF_Selected3DCover-2)
          For i=ListSize(VIS_CF_Albums())-1 To VIS_CF_Selected3DCover+1 Step -1
            SelectElement(VIS_CF_Albums(), i)
            iCoverWidth = VIS_CF_Albums()\iWidth * iPictureSize/100
            iCoverHeight = VIS_CF_Albums()\iHeight * iPictureSize/100
            
            ;Sprite2D_Transform(VIS_CF_Albums()\iSprite, 0, iCoverHeight/8, iCoverWidth/4, 0, iCoverWidth/4, iCoverHeight, 0, iCoverHeight-iCoverHeight/8)
            Sprite2DHelper_TransformHorizontal(VIS_CF_Albums()\iSprite, 0, iCoverHeight/8, iCoverWidth/4, 0, iCoverWidth/4, iCoverHeight, 0, iCoverHeight-iCoverHeight/8)
  
            Sprite2D_DisplayEx(VIS_CF_Albums()\iSprite, X, Y+(iPictureSize-iCoverHeight)/2, 240)
            X-iPictureSize/5
          Next
          iPictureSize=iPictureSize/5
          
          ;Text:
          If *VIS_Coverflow_Font
            len1=(Len(VIS_Coverflow_SelectedInterpret)+2)* *VIS_Coverflow_Font\DWidth*8/20
            len2=(Len(VIS_Coverflow_SelectedAlbum)+2)* *VIS_Coverflow_Font\DWidth*8/20
            Sprite2D_DrawFont(*VIS_Coverflow_Font, (iWidth-len1)/2, iHeight-80, VIS_Coverflow_SelectedInterpret, RGBA(255,255,255,220), 8)
            Sprite2D_DrawFont(*VIS_Coverflow_Font, (iWidth-len2)/2, iHeight-55, VIS_Coverflow_SelectedAlbum, RGBA(200,200,200,220), 8)
          EndIf
              
          ;Scrolling:
          If GetWindowKeyState(#VK_RIGHT):VIS_CF_Selected3DCover+1:EndIf
          If GetWindowKeyState(#VK_LEFT):VIS_CF_Selected3DCover-1:EndIf
          If iMouseY>0 And iMouseY<iHeight    
            If MouseOldPosX>0 And MouseOldPosY>0
              VIS_CF_CoverScrollSpeed+Pow(MouseOldPosX-iMouseX, 2)
              If MouseOldPosX>iMouseX
                VIS_CF_CoverScrollRirection=#True
              EndIf
              If MouseOldPosX<iMouseX
                VIS_CF_CoverScrollRirection=#False
              EndIf
            EndIf
          EndIf
          VIS_CF_CoverScrollSpeed/1.5
          If VIS_CF_CoverScrollRirection
            VIS_CF_CoverScrollPos+Sqr(VIS_CF_CoverScrollSpeed)
          Else
            VIS_CF_CoverScrollPos-Sqr(VIS_CF_CoverScrollSpeed)
          EndIf
          If VIS_CF_CoverScrollPos>iPictureSize:VIS_CF_CoverScrollPos=0:VIS_CF_Selected3DCover+1:EndIf
          If VIS_CF_CoverScrollPos<-iPictureSize:VIS_CF_CoverScrollPos=0:VIS_CF_Selected3DCover-1:EndIf
          If VIS_CF_Selected3DCover<0:VIS_CF_Selected3DCover=0:VIS_CF_CoverScrollSpeed/15:EndIf
          If VIS_CF_Selected3DCover>(ListSize(VIS_CF_Albums())-1):VIS_CF_CoverScrollSpeed/15:VIS_CF_Selected3DCover=(ListSize(VIS_CF_Albums())-1):EndIf
          
        EndIf
        
        
  
      
        ;No Covers:
        If ListSize(VIS_CF_Albums())=0
          If *VIS_Coverflow_PlayingCover_Sprite
            Sprite2D_DisplayEx(*VIS_Coverflow_PlayingCover_Sprite, (iWidth-*VIS_Coverflow_PlayingCover_Sprite\RealWidth)/2, (iHeight-*VIS_Coverflow_PlayingCover_Sprite\RealHeight)/2, 200)
          EndIf        
          Sprite2D_DrawFont(*VIS_Coverflow_Font, 10, 10, Language(#L_NO_COVERS), RGBA(255,255,255, 255), 10)
          Sprite2D_DrawFont(*VIS_Coverflow_Font, 10, 40, Language(#L_HOW_TO_CREATE_COVERFLOW), RGBA(255,255,255, 255), 4)
        EndIf
        
        Sprite2D_Color(VIS_Coverflow_BK2_Sprite, RGBA(100,20,20,255), RGBA(100,20,20,255), RGBA(20,20,20,255), RGBA(20,20,20,255))  
        SelectElement(VIS_CF_MenuItems(), 1)
        If VIS_CF_MenuItems()\iSelected
          Sprite2D_Zoom(VIS_Coverflow_BK2_Sprite, iWidth, iHeight)
          Sprite2D_DisplayEx(VIS_Coverflow_BK2_Sprite, 0, 0, 230)
        EndIf
        
        ;Draw GUI
        Draw_VIS_CF_Menu(iHeight.i, iWidth.i, iMouseX.i, iMouseY.i, iLeftMButton.i)
        
        
        ;VIS_Coverflow_Counter+10
        ;If 70-(VIS_Coverflow_Counter)/10>0
        ;  Sprite2D_Zoom(VIS_Coverflow_GFP_Sprite, VIS_Coverflow_Counter, VIS_Coverflow_Counter)
        ;  Sprite2D_Rotate(VIS_Coverflow_GFP_Sprite, 1, 1)
        ;  Sprite2D_DisplayEx(VIS_Coverflow_GFP_Sprite, (iWidth-VIS_Coverflow_Counter)/2, (iHeight-VIS_Coverflow_Counter)/2, 70-(VIS_Coverflow_Counter)/10)
        ;EndIf
        
        Sprite2D_Stop()
      EndIf
      *p\EndScene()
    EndIf
    If ListSize(VIS_CF_Albums())=0
      LoadPlayingCover()  
    EndIf
  EndIf
  
  If sLoadMediaFile
    LoadMediaFile(sLoadMediaFile, #True, sLoadMediaFileTitle, qLoadMediaFileOffset)
  EndIf
  
EndProcedure

ProcedureDLL VIS_Coverflow_BeforeReset(*p.IVisualisationCanvas)
EndProcedure
ProcedureDLL VIS_Coverflow_AfterReset(*p.IVisualisationCanvas)
EndProcedure
ProcedureDLL VIS_Coverflow_Terminate(*p.IVisualisationCanvas)
  Protected *dev.IDirect3DDevice9 = #Null
  ForEach VIS_CF_Covers()
    If VIS_CF_Covers()\iSprite:Sprite2D_Free(VIS_CF_Covers()\iSprite):EndIf
    If VIS_CF_Covers()\iTexture:VIS_CF_Covers()\iTexture\Release():EndIf
    VIS_CF_Covers()\iSprite = #Null
    VIS_CF_Covers()\iTexture = #Null
  Next
  ClearList(VIS_CF_MenuItems())
  ClearList(VIS_CF_Covers())
  ClearList(VIS_CF_Albums())
  ClearList(VIS_CF_Tracks())

  If VIS_Coverflow_BK_Sprite:Sprite2D_Free(VIS_Coverflow_BK_Sprite):VIS_Coverflow_BK_Sprite=#Null:EndIf
  If VIS_Coverflow_Light_Sprite:Sprite2D_Free(VIS_Coverflow_Light_Sprite):VIS_Coverflow_Light_Sprite=#Null:EndIf
  If VIS_Coverflow_NoCover_Sprite:Sprite2D_Free(VIS_Coverflow_NoCover_Sprite):VIS_Coverflow_NoCover_Sprite=#Null:EndIf
  If VIS_Coverflow_CoverEffect_Sprite:Sprite2D_Free(VIS_Coverflow_CoverEffect_Sprite):VIS_Coverflow_CoverEffect_Sprite=#Null:EndIf
  If *VIS_Coverflow_PlayingCover_Sprite:Sprite2D_Free(*VIS_Coverflow_PlayingCover_Sprite):*VIS_Coverflow_PlayingCover_Sprite=#Null:EndIf
  If VIS_Coverflow_GFP_Sprite:Sprite2D_Free(VIS_Coverflow_GFP_Sprite):VIS_Coverflow_GFP_Sprite=#Null:EndIf
  If VIS_Coverflow_BK2_Sprite:Sprite2D_Free(VIS_Coverflow_BK2_Sprite):VIS_Coverflow_BK2_Sprite=#Null:EndIf
  
  
  If *VIS_Coverflow_BK_Texture:*VIS_Coverflow_BK_Texture\Release():*VIS_Coverflow_BK_Texture=#Null:EndIf
  If *VIS_Coverflow_Light_Texture:*VIS_Coverflow_Light_Texture\Release():*VIS_Coverflow_Light_Texture=#Null:EndIf
  If *VIS_Coverflow_NoCover_Texture:*VIS_Coverflow_NoCover_Texture\Release():*VIS_Coverflow_NoCover_Texture=#Null:EndIf
  If *VIS_Coverflow_CoverEffect_Texture:*VIS_Coverflow_CoverEffect_Texture\Release():*VIS_Coverflow_CoverEffect_Texture=#Null:EndIf
  If *VIS_Coverflow_PlayingCover_Texture:*VIS_Coverflow_PlayingCover_Texture\Release():*VIS_Coverflow_PlayingCover_Texture=#Null:EndIf
  If *VIS_Coverflow_GFP_Texture:*VIS_Coverflow_GFP_Texture\Release():*VIS_Coverflow_GFP_Texture=#Null:EndIf
  If *VIS_Coverflow_BK2_Texture:*VIS_Coverflow_BK2_Texture\Release():*VIS_Coverflow_BK2_Texture=#Null:EndIf
  
  
  Sprite2D_FreeFont(*VIS_Coverflow_Font)
  *VIS_Coverflow_Font=#Null
  
  Sprite2D_Terminate()
  
EndProcedure
ProcedureDLL VIS_Coverflow_GetVersion()
  ProcedureReturn #GREENFORCE_PLUGIN_COVERFLOW_VERSION
EndProcedure


Procedure LoadCoverFlow()
  Protected UseAttached.i, sFile.s=ProgramFilename()
  If OpenEXEAttachements(sFile)
    If GetNumEXEAttachments()>1
      UseAttached=#True
    EndIf
  EndIf  
  If UseAttached
    LoadAttachedMedia(sFile)
  Else
    VIS_SetVIS(#VIS_COVERFLOW)
  EndIf  
    
EndProcedure  


; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 755
; FirstLine = 613
; Folding = hD+
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
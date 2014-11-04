;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
Macro GUID(name, l1, w1, w2, b1b2, brest) 
  DataSection 
  name: 
    Data.l $l1 
    Data.w $w1, $w2 
    Data.b $b1b2 >> 8, $b1b2 & $FF 
    Data.b $brest >> 40 & $FF 
    Data.b $brest >> 32 & $FF 
    Data.b $brest >> 24 & $FF 
    Data.b $brest >> 16 & $FF 
    Data.b $brest >> 8 & $FF 
    Data.b $brest & $FF 
  EndDataSection 
EndMacro 

;{ Declaration
  GUID(IID_IWMMetadataEditor, 96406bd9, 2b2b, 11d3, b36b, 00c04f6108ff) 
  GUID(IID_IWMHeaderInfo,     96406bda, 2b2b, 11d3, b36b, 00c04f6108ff) 
  GUID(IID_IWMHeaderInfo2,    15cf9781, 454e, 482e, b393, 85fae487a810) 
  GUID(IID_IWMHeaderInfo3,    15CC68E3, 27CC, 4ecd, B222, 3F5D02D80BD5) 
  
  #NS_E_SDK_BUFFERTOOSMALL = $C00D0BD4 
  
  Enumeration 
    #WMT_TYPE_DWORD 
    #WMT_TYPE_STRING 
    #WMT_TYPE_BINARY 
    #WMT_TYPE_BOOL 
    #WMT_TYPE_QWORD 
    #WMT_TYPE_WORD 
    #WMT_TYPE_GUID 
  EndEnumeration 
  
  Structure WMPicture
    *pwszMIMEType
    bPictureType.b
    *pwszDescription
    dwDataLen.l
    *pbData.byte
  EndStructure
  
  Interface IWMMetadataEditor Extends IUnknown 
    Open(filename.p-unicode) 
    Close() 
    Flush() 
  EndInterface 
  
  Interface IWMHeaderInfo Extends IUnknown 
    GetAttributeCount.l(wStreamNum.W, *pcAttributes.w) 
    GetAttributeByIndex.l(wIndex.w, *pwStreamNum.w, pwszName.p-unicode, *pcchNameLen.w, *pType.l, *pValue.b, *pcbLength.w) 
    GetAttributeByName(*pwStreamNum.w,  pszName.p-unicode, *pType.l, *pValue.l, *pcbLength.w) 
    SetAttribute(wStreamNum.w,  pszName.p-unicode, Type.l,  *pValue.b, cbLength.w) 
    GetMarkerCount(*pcMarkers.w) 
    GetMarker(wIndex.w, pwszMarkerName.p-unicode, *pcchMarkerNameLen.w, *pcnsMarkerTime.q) 
    AddMarker(pwszMarkerName.p-unicode,  cnsMarkerTime.q) 
    RemoveMarker(wIndex.w) 
    GetScriptCount(*pcScripts.w) 
    GetScript(wIndex.w, pwszType.p-unicode, *pcchTypeLen.w, pwszCommand.p-unicode, *pcchCommandLen.w, *pcnsScriptTime.q) 
    AddScript(pwszType, pwszCommand.p-unicode, cnsScriptTime.q) 
    RemoveScript(wIndex.w) 
  EndInterface 
  
  Interface IWMHeaderInfo2 Extends IWMHeaderInfo 
    GetCodecInfoCount(*pcCodecInfos.l) 
    GetCodecInfo(wIndex.l, *pcchName.w, pwszName.p-unicode, *pcchDescription.w, pwszDescription.p-unicode, *pCodecType.l, *pcbCodecInfo.w, *pbCodecInfo.b) 
  EndInterface 
  
  Interface IWMHeaderInfo3 Extends IWMHeaderInfo2 
    GetAttributeCountEx(wStreamNum.w, *pcAttributes.w) 
    GetAttributeIndices(wStreamNum.w, pwszName.p-unicode, *pwLangIndex.w, *pwIndices.w, *pwCount.w) 
    GetAttributeByIndexEx(wStreamNum.w, wIndex.w, pwszName, *pwNameLen.w, *pType.l, *pwLangIndex.w, *pValue.b, *pdwDataLength.l) 
    ModifyAttribute(wStreamNum.w, wIndex.w, Type.l, wLangIndex.w, *pValue.b, dwLength.l) 
    AddAttribute(wStreamNum.w, pszName.p-unicode, *pwIndex.w, Type.l, wLangIndex.w, *pValue.b, dwLength.l) 
    DeleteAttribute(wStreamNum, wIndex.w) 
    AddCodecInfo(pwszName.p-unicode, pwszDescription.p-unicode, codecType.l, cbCodecInfo.w, *pbCodecInfo.b) 
  EndInterface 
  Global medit.IWMMetadataEditor 
  Global hinfo3.IWMHeaderInfo3 
  Global iMediaLibrary.i
  
  Structure MediaInfoData
    sTile.s
    sAutor.s
    sGenere.s
    sAlbumTitle.s  
    sComposer.s
    sLyrics.s  
    qDuration.q
    iBitrate.i
    iFileSize.i
    iTrackNumber.i
    iTrack.i
    iYear.i
    iHasAttachedImages.i
    iHasVideo.i
    pPicture.i
    iPictureSize.i
    sGUID.s
  EndStructure
  Global MediaInfoData.MediaInfoData
;}



Procedure GetAttribute(Index)
  Protected iResult.i = 1, KeyName.i, DataContent.i, DataLen.i, KeyLen.i
  Protected t.i, sKeyName.s, *pict.WMPicture, sGUID.s, *mem

  DataLen = 200000
  KeyLen = 2048
  hinfo3\GetAttributeByIndexEx(0, Index, #Null, @KeyLen, @t, #Null, #Null, @DataLen)
  If KeyLen And DataLen
    KeyName = AllocateMemory(2 * KeyLen + 16)
    DataContent = AllocateMemory(DataLen + 16)
 
    If KeyName And DataContent
      hinfo3\GetAttributeByIndexEx(0, Index, KeyName, @KeyLen, @t, #Null, DataContent, @DataLen)
      
      If DataLen = 0 
        WriteLog("Invalid data length")
        iResult = 0
      Else
        If PeekS(KeyName,-1,#PB_Unicode) = ""
          iResult = 0
        Else
          sKeyName.s = Trim(LCase(PeekS(KeyName,-1,#PB_Unicode)))
          ;Debug sKeyName+" --- "+PeekS(DataContent, DataLen/2,#PB_Unicode)   
          Select sKeyName
          Case "duration"
            MediaInfoData\qDuration = PeekQ(DataContent)
          Case "bitrate"
            MediaInfoData\iBitrate = PeekL(DataContent)
          Case "hasattachedimages"
            MediaInfoData\iHasAttachedImages = PeekL(DataContent)
            ;Debug PeekL(DataContent)
          Case "hasvideo"
            MediaInfoData\iHasVideo = PeekL(DataContent)
          Case "filesize"
            MediaInfoData\iFileSize = PeekQ(DataContent)
          Case "title"
            MediaInfoData\sTile = PeekS(DataContent, DataLen/2,#PB_Unicode)
          Case "author"
            MediaInfoData\sAutor = PeekS(DataContent, DataLen/2,#PB_Unicode)
            MediaInfoData\sComposer = PeekS(DataContent, DataLen/2,#PB_Unicode)  
          Case "wm/genre"
            MediaInfoData\sGenere = PeekS(DataContent, DataLen/2,#PB_Unicode)   
          Case "wm/albumtitle"
            MediaInfoData\sAlbumTitle = PeekS(DataContent, DataLen/2,#PB_Unicode)   
          Case "track"
            MediaInfoData\iTrack = PeekL(DataContent)
          Case "wm/tracknumber"
            MediaInfoData\iTrackNumber = PeekL(DataContent)
          Case "wm/year"
            MediaInfoData\iYear = Val(PeekS(DataContent, DataLen/2,#PB_Unicode))
          ;Case "author";"wm/albumartist";"wm/composer"
          ;  MediaInfoData\sComposer = PeekS(DataContent, DataLen/2,#PB_Unicode)   
          Case "wm/lyrics"
            MediaInfoData\sLyrics = PeekS(DataContent, DataLen/2,#PB_Unicode)
          Case "wm/picture"
            
            If MediaInfoData\pPicture:FreeMemory(MediaInfoData\pPicture):MediaInfoData\pPicture=#Null:EndIf
            WriteLog("Cover found", #LOGLEVEL_DEBUG)
            *pict = DataContent
            MediaInfoData\iPictureSize = *pict\dwDataLen
            MediaInfoData\pPicture = AllocateMemory(*pict\dwDataLen + 16)
            CopyMemory(*pict\pbData, MediaInfoData\pPicture, *pict\dwDataLen)  
                      
          Case "wm/wmcollectionid";"wm/wmcollectiongroupid";"wm/wmcontentid";
            sGUID.s = "" 
            StringFromCLSID_(DataContent,@*mem)
            If *mem
              sGUID.s = PeekS(*mem,-1, #PB_Unicode)
              MediaInfoData\sGUID.s = sGUID
              CoTaskMemFree_(*mem)
            EndIf
          EndSelect
        EndIf
      EndIf  
      
      
    
      ;   Select t 
      ;     Case #WMT_TYPE_STRING
      ;       Debug PeekS(KeyName,-1,#PB_Unicode) + ": " + PeekS(DataContent, DataLen/2,#PB_Unicode)
      ;     Case #WMT_TYPE_DWORD, #WMT_TYPE_BOOL 
      ;       Debug PeekS(KeyName,-1,#PB_Unicode) + ": " + Str(PeekL(DataContent)) 
      ;     Case #WMT_TYPE_QWORD 
      ;       Debug PeekS(KeyName,-1,#PB_Unicode) + ": " + Str(PeekQ(DataContent)) 
      ;     Default 
      ;       Debug PeekS(KeyName,-1,#PB_Unicode) + " has unknown type: " + Str(t) 
      ;   EndSelect 
        
    EndIf
  EndIf
  
  If KeyName:FreeMemory(KeyName):EndIf
  If DataContent:FreeMemory(DataContent):EndIf
  ProcedureReturn iResult
EndProcedure 
Procedure.s GetSystemDirectory()
  Protected Dir, sResult.s
  sResult=Space(500)
  GetSystemDirectory_(@sResult, 500)
  ProcedureReturn Trim(sResult)
EndProcedure

Procedure ClearMetaArray()
  MediaInfoData\sTile.s = ""
  MediaInfoData\sAutor.s = ""
  MediaInfoData\sGenere.s = ""
  MediaInfoData\sAlbumTitle.s = "" 
  MediaInfoData\sComposer.s = ""
  MediaInfoData\sLyrics.s = ""
  MediaInfoData\qDuration = 0
  MediaInfoData\iBitrate.i = 0
  MediaInfoData\iFileSize.i = 0
  MediaInfoData\iTrackNumber.i = 0
  MediaInfoData\iTrack.i = 0
  MediaInfoData\iYear.i = 0
  MediaInfoData\iHasAttachedImages.i = 0
  MediaInfoData\iHasVideo.i = 0
EndProcedure

Procedure InitMetaReader()
  iMediaLibrary = OpenLibrary(#PB_Any, "WMVCore.dll")
  If iMediaLibrary
    CallFunction(iMediaLibrary, "WMCreateEditor", @medit)
  EndIf
  ProcedureReturn medit
EndProcedure
Procedure FreeMetaReader()
  If MediaInfoData\pPicture:FreeMemory(MediaInfoData\pPicture):MediaInfoData\pPicture=#Null:EndIf
  If medit
    medit\Close()
    medit\Release()
    medit = #Null
  EndIf
  If iMediaLibrary
    CloseLibrary(iMediaLibrary)
    iMediaLibrary = #Null
  EndIf
EndProcedure
Procedure LoadMetaFile(sFile.s)
  Protected iResult.i, c.i, i.i
  iResult=#False
  If sFile And iMediaLibrary And medit
    ClearMetaArray()
  
    medit\Open(sFile) 
    medit\QueryInterface(?IID_IWMHeaderInfo3, @hinfo3) 
    If hinfo3
      hinfo3\GetAttributeCountEx($FFFF, @c.i)
      If c>0 
        For I = 0 To c-1 
          GetAttribute(I) 
        Next
        iResult = #True
      EndIf
    Else
      WriteLog("Can't Query Interface!")
    EndIf
    medit\Close()
    ;medit\Release()
  EndIf
  ProcedureReturn iResult
EndProcedure


;{ Example
; 
; InitMetaReader()
; 
; LoadMetaFile("C:\Dokumente und Einstellungen\All Users\Dokumente\Eigene Musik\Beispielmusik\Beethovens Symphonie Nr. 9 (Scherzo).wma")
; LoadMetaFile("C:\Dokumente und Einstellungen\All Users\Dokumente\Eigene Musik\Beispielmusik\New Stories (Highway Blues).wma")
; Debug MediaInfoData\sTile
; FreeMetaReader()

;}




; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 173
; FirstLine = 160
; Folding = +8
; EnableXP
; UseMainFile = Player.pb
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

Structure AM_MEDIA_TYPE
   majortype.GUID
   subtype.GUID
   bFixedSizeSamples.l;CHANGED FROM BYTE TO LONG (24.06.10)
   bTemporalCompression.l;CHANGED FROM BYTE TO LONG (24.06.10)
   lSampleSize.l
   formattype.GUID
   pUnk.l
   cbFormat.l
   pbFormat.l
EndStructure  

#CLSCTX_INPROC_SERVER = 1

DataSection
   CLSID_MediaDet:
   Data.l $65BD0711
   Data.w $24D2, $4ff7
   Data.b $93, $24, $ed, $2e, $5d, $3a, $ba, $fa
   
   IID_IMediaDet:
   Data.l $65BD0710
   Data.w $24D2, $4ff7
   Data.b $93, $24, $ed, $2e, $5d, $3a, $ba, $fa
   
   MEDIATYPE_Video:
   Data.l $73646976
   Data.w $0000, $0010
   Data.b $80, $00, $00, $aa, $00, $38, $9b, $71   
   
   MEDIATYPE_Audio:
   Data.l $73647561
   Data.w $0000, $0010
   Data.b $80, $00, $00, $aa, $00, $38, $9b, $71   
EndDataSection

Structure MEDIACHECK
  bUseable.i
  dLength.d
  bVideo.i
EndStructure



;2013-04-2 Length is secounds
Procedure DShow_CheckMedia(sFile.s, *MC.MEDIACHECK)
  Protected bResult.i = #False, mt.AM_MEDIA_TYPE, iResult.i, nstreams.l, dLengthVideo.d = 0.0, dLengthAudio.d = 0.0, pMDet.IMediaDet, s.i
  If *MC
    iResult = CoCreateInstance_(?CLSID_MediaDet, #Null, #CLSCTX_INPROC_SERVER, ?IID_IMediaDet, @pMDet.IMediaDet)
    If iResult = #S_OK
      If pMDet\put_Filename(sFile) = #S_OK
        pMDet\get_OutputStreams(@nstreams)
        *MC\bUseable = #False
        *MC\bVideo = #False
        For s=0 To nstreams-1
           pMDet\put_CurrentStream(s)
           pMDet\get_StreamMediaType(@mt.AM_MEDIA_TYPE)
           If CompareMemory(mt\majortype, ?MEDIATYPE_Video, 16) ;is video
             *MC\bVideo = #True
             pMDet\get_StreamLength(@dLengthVideo)
             *MC\bUseable = #True
           EndIf  
           If CompareMemory(mt\majortype, ?MEDIATYPE_Audio, 16) ;is audio
             pMDet\get_StreamLength(@dLengthAudio)   
             *MC\bUseable = #True
           EndIf 
        Next   
        *MC\dLength = dLengthVideo
        If dLengthAudio > *MC\dLength
          *MC\dLength = dLengthAudio
        EndIf 
        bResult = #True
      EndIf
      pMDet\Release()
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure


;{ Sample

; CoInitialize_(#Null)
; 
; MC.MEDIACHECK
; CheckMedia("D:\test.mp3", @MC)
; Debug MC\bUseable
; Debug MC\dLength
; 
; CoUninitialize_()
; End    

;}




; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 51
; FirstLine = 27
; Folding = 0
; EnableXP
; EnableUser
; EnableCompileCount = 24
; EnableBuildCount = 0
; EnableExeConstant
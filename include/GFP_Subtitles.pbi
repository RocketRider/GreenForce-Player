;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

Structure Subtitle
  qStartTime.q
  qEndTime.q
  sText.s
EndStructure  
Global NewList Subtiltes.Subtitle()
Global iLastSubtitleIndex.i
Global sLastSubtitleText.s

Declare SetSubtitle(NoSubtitle.i=#False, Replace=#False)

Enumeration
  #SUBTITLE_UNKNOWN
  #SUBTITLE_SUB_1
  #SUBTITLE_SUB_2
  #SUBTITLE_SRT_1
  #SUBTITLE_SRT_2
  #SUBTITLE_SRT_3
EndEnumeration

#SUBTITLE_TIME=8000
#SUBTITLE_FILE_EXTENSIONS="sub;srt;txt;idx;aqt;jss;ttxt;pjs;psb;rt;smi;ssf;gsub;ssa;ass;usf;"

#SUBTITLE_FONNT_NAME = "Calibri";"Arial"
#SUBTITLE_FONNT_SIZE = 40
#SUBTITLE_FONNT_STYLE = #PB_Font_HighQuality;|#PB_Font_Bold


;00:00:05.61;FORMAT=0
;00:00:45,548;FORMAT=1
Procedure.q ParseTime(sTime.s)
  Protected format.i=0, sec.q, pos.i
  If sTime
    pos=FindString(sTime, ".", 1)
    If pos<1
      pos=FindString(sTime, ",", 1)
      format=1
    EndIf
    If pos>0
      sec.q=ParseDate("%hh:%ii:%ss", Mid(sTime,1, pos))
      sec=sec*1000
      If format=0
        sec=sec+Val(Mid(sTime,pos+1))*10
      Else 
        sec=sec+Val(Mid(sTime,pos+1))
      EndIf  
    EndIf  
  EndIf  
  ProcedureReturn sec
EndProcedure


Procedure FreeSubtitles()
  If iSubtitlesLoaded
    iLastSubtitleIndex=0
    SetSubtitle(#True)
    ClearList(Subtiltes())
    iSubtitlesLoaded=#False
  EndIf
EndProcedure  
Procedure AddSubtitleElement(qStartTime.q, qEndTime.q, sText.s)
  Protected sStyles.s, i.i
  If qStartTime>0 And qEndTime>0 And sText<>""
    sText=ReplaceString(sText, "[br]", "[BR]", #PB_String_NoCase)
    sText=ReplaceString(sText, "|", "[BR]", #PB_String_NoCase)
    sText=ReplaceString(sText, "<br>", "[BR]", #PB_String_NoCase)
    sText=ReplaceString(sText, "</br>", "[BR]", #PB_String_NoCase)
    
    sText=ReplaceString(sText, "<i>", "", #PB_String_NoCase)
    sText=ReplaceString(sText, "</i>", "", #PB_String_NoCase)
    sText=ReplaceString(sText, "<b>", "", #PB_String_NoCase)
    sText=ReplaceString(sText, "</b>", "", #PB_String_NoCase)
    sText=ReplaceString(sText, "<u>", "", #PB_String_NoCase)
    sText=ReplaceString(sText, "</u>", "", #PB_String_NoCase)
    
    sStyles=FindStringInBuffer(@sText, Len(sText), "{", "}")
    If CountString(sStyles, "|")>0
      For i=1 To CountString(sStyles, "|")+1
        sText=ReplaceString(sText, "{"+StringField(sStyles, i, "|")+"}", "", #PB_String_NoCase)
      Next  
    Else
      sText=ReplaceString(sText, "{"+sStyles+"}", "", #PB_String_NoCase)
    EndIf  
    
    
    AddElement(Subtiltes())
    Subtiltes()\qStartTime = qStartTime
    Subtiltes()\qEndTime = qEndTime
    Subtiltes()\sText = sText
  EndIf
EndProcedure  

;-> Unicode, UTF8 Unterstützen (PeekS)
Procedure ReadSubtitle_SUB_1(*mem, qlen.q, dFrames.d)
  Protected sText.s, iCount.i, sLine.s, i.i, sTime.s
  Protected   qStartTime.q, qEndTime.q, sSubtitle.s, pos.i, i2, oldpos.i
  If *mem And qlen
    sText.s=ReplaceString(ReplaceString(PeekS(*mem, qlen, #PB_Ascii),Chr(13), Chr(10)),Chr(10)+Chr(10), Chr(10))
    iCount=CountString(sText, Chr(10))
    For i=1 To iCount
      sLine.s=Trim(StringField(sText, i, Chr(10)))
      If sLine
        sTime=FindStringInBuffer(@sLine, Len(sLine), "[", "]")
        If CountString(sTime, "|")>0
          qStartTime=Val(StringField(sTime, 1, "|"))
          qEndTime=Val(StringField(sTime, 2, "|"))
          If qStartTime<qEndTime
            Repeat
               Oldpos=pos
               pos=FindString(sLine, "]", Oldpos+1)
            Until pos=0
            sSubtitle=Mid(sLine, Oldpos+1)
            
            qStartTime=qStartTime*100
            qEndTime=qEndTime*100
            AddSubtitleElement(qStartTime, qEndTime, sSubtitle)
          EndIf  
        EndIf  
      EndIf
    Next
  EndIf  
EndProcedure
Procedure ReadSubtitle_SUB_2(*mem, qlen.q, dFrames.d)
  Protected sText.s, iCount.i, sLine.s, i.i, sTime.s
  Protected   qStartTime.q, qEndTime.q, sSubtitle.s, pos.i, i2, oldpos.i
  If *mem And qlen
    sText.s=ReplaceString(ReplaceString(PeekS(*mem, qlen, #PB_Ascii),Chr(13), Chr(10)),Chr(10)+Chr(10), Chr(10))
    iCount=CountString(sText, Chr(10))
    For i=1 To iCount
      sLine.s=Trim(StringField(sText, i, Chr(10)))
      If sLine
        sTime=FindStringInBuffer(@sLine, Len(sLine), "{", "}")
        If CountString(sTime, "|")>0
          qStartTime=Val(StringField(sTime, 1, "|"))
          qEndTime=Val(StringField(sTime, 2, "|"))
          If qStartTime<qEndTime
            Repeat
               Oldpos=pos
               pos=FindString(sLine, "}", Oldpos+1)
            Until pos=0
            sSubtitle=Mid(sLine, Oldpos+1)
            
            qStartTime=((qStartTime*1000)/dFrames)
            qEndTime=((qEndTime*1000)/dFrames)
            AddSubtitleElement(qStartTime, qEndTime, sSubtitle)
          EndIf  
        EndIf  
      EndIf
    Next
  EndIf  
EndProcedure

Procedure ReadSubtitle_SRT_1(*mem, qlen.q, dFrames.d)
  Protected sText.s, iCount.i, sLine.s, i.i, sTime.s, foundnext.i
  Protected   qStartTime.q, qEndTime.q, sSubtitle.s, pos.i, i2, oldpos.i
  If *mem And qlen
    sText.s=ReplaceString(ReplaceString(PeekS(*mem, qlen, #PB_Ascii),Chr(13), Chr(10)),Chr(10)+Chr(10), Chr(10))
    iCount=CountString(sText, Chr(10))
    For i=1 To iCount
      sLine.s=Trim(StringField(sText, i, Chr(10)))
      If sLine
        If FindString(sLine, " ", 1) Or FindString(sLine, ":", 1)
          pos=FindString(sLine, "-->", 1)
          If pos
            ;Debug sLine
            qStartTime=ParseTime(Trim(Mid(sLine, 1, pos)))
            qEndTime=ParseTime(Trim(Mid(sLine, pos+Len("-->")+1)))
            sSubtitle=""
            Repeat
              i+1
              sLine.s=Trim(StringField(sText, i, Chr(10)))
              If Trim(sLine)<>"" And FindString(sLine, "-->", 1)<1 And sLine <> Str(Val(sLine))
                sSubtitle+sLine+"[BR]"
                foundnext=0
              Else
                foundnext=#True
                i-1
              EndIf  
            Until foundnext=#True
            AddSubtitleElement(qStartTime, qEndTime, sSubtitle)
          EndIf
        EndIf
      EndIf
    Next
  EndIf
EndProcedure
Procedure ReadSubtitle_SRT_2(*mem, qlen.q, dFrames.d)
  Protected sText.s, iCount.i, sLine.s, i.i, sTime.s, foundnext.i
  Protected   qStartTime.q, qEndTime.q, sSubtitle.s, pos.i, i2, oldpos.i
  If *mem And qlen
    sText.s=ReplaceString(ReplaceString(PeekS(*mem, qlen, #PB_Ascii),Chr(13), Chr(10)),Chr(10)+Chr(10), Chr(10))
    iCount=CountString(sText, Chr(10))
    For i=1 To iCount
      sLine.s=Trim(StringField(sText, i, Chr(10)))
      If sLine
        If FindString(sLine, " ", 1) Or FindString(sLine, ":", 1)
          pos=FindString(sLine, ",", 1)
          If pos
            ;Debug sLine
            qStartTime=ParseTime(Trim(Mid(sLine, 1, pos)))
            qEndTime=ParseTime(Trim(Mid(sLine, pos+Len(",")+1)))
            sSubtitle=""
            Repeat
              i+1
              sLine.s=Trim(StringField(sText, i, Chr(10)))
              If Trim(sLine)<>"" And FindString(sLine, ",", 1)<1 And sLine <> Str(Val(sLine))
                sSubtitle+sLine+"[BR]"
                foundnext=0
              Else
                foundnext=#True
                i-1
              EndIf  
            Until foundnext=#True
            AddSubtitleElement(qStartTime, qEndTime, sSubtitle)
          EndIf
        EndIf
      EndIf
    Next
  EndIf
EndProcedure
Procedure ReadSubtitle_SRT_3(*mem, qlen.q, dFrames.d)
  Protected sText.s, iCount.i, sLine.s, i.i, sTime.s, foundnext.i, pos1, pos2, pos3
  Protected   qStartTime.q, qEndTime.q, sSubtitle.s, pos.i, i2, oldpos.i
  If *mem And qlen
    sText.s=ReplaceString(ReplaceString(PeekS(*mem, qlen, #PB_Ascii),Chr(13), Chr(10)),Chr(10)+Chr(10), Chr(10))
    iCount=CountString(sText, Chr(10))
    For i=1 To iCount
      sLine.s=Trim(StringField(sText, i, Chr(10)))
      If sLine
        pos1.i=FindString(sLine, ":", 1)
        If pos1
          pos2.i=FindString(sLine, ":", pos1+1)
          If pos2
            pos3.i=FindString(sLine, ":", pos2+1)
            If pos3
              qStartTime=ParseDate("%hh:%ii:%ss", Mid(sLine, 1, pos3-1))*1000
              qEndTime=qStartTime+#SUBTITLE_TIME
              sSubtitle = Mid(sLine, pos3+1)
              AddSubtitleElement(qStartTime, qEndTime, sSubtitle)
            EndIf  
          EndIf  
        EndIf  
      EndIf
    Next
  EndIf
EndProcedure


Procedure GetSubtitleFormat(*mem, qlen.q)
  Protected Result=#SUBTITLE_UNKNOWN, searchlen.i, sText.s, iCount.i, i.i, ErrorCount.i, sLine.s, searchString.s
  Protected FoundCount.i, FoundType.i
  If *mem And qlen
    searchlen=qlen
    If searchlen>1024*10:searchlen=1024*10:EndIf
    searchString.s = PeekS(*mem, searchlen, #PB_Ascii)
    searchlen=Len(searchString)
    
    
    If Result=#SUBTITLE_UNKNOWN
      sText.s=FindStringInBuffer(@searchString, searchlen, "[", "]")
      iCount=CountString(sText, "|")
      If iCount
        If iCount>15
          ErrorCount=0
          For i=1 To iCount+1
            If Val(StringField(sText, i, "|"))=0:ErrorCount+1:EndIf
          Next
          If ErrorCount<iCount/5
            Result=#SUBTITLE_SUB_1
            WriteLog("SUBTITLE_SUB_1", #LOGLEVEL_DEBUG)
          EndIf  
        EndIf
      EndIf  
    EndIf
    
    
    If Result=#SUBTITLE_UNKNOWN
      sText.s=FindStringInBuffer(@searchString, searchlen, "{", "}")
      iCount=CountString(sText, "|")
      If iCount
        If iCount>15
          ErrorCount=0
          For i=1 To iCount+1
            If Val(StringField(sText, i, "|"))=0:ErrorCount+1:EndIf
          Next
          If ErrorCount<iCount/5
            Result=#SUBTITLE_SUB_2
            WriteLog("SUBTITLE_SUB_2", #LOGLEVEL_DEBUG)
          EndIf  
        EndIf
      EndIf  
    EndIf
    
    
    If Result=#SUBTITLE_UNKNOWN
      sText.s=ReplaceString(ReplaceString(searchString,Chr(13), Chr(10)),Chr(10)+Chr(10), Chr(10))
      iCount=CountString(sText, Chr(10))
      If iCount
        FoundCount=0
        For i=1 To iCount
          sLine=StringField(sText, i, Chr(10))
          ;sLine=ReplaceString(sLine," ","")
          ;sLine=ReplaceString(sLine,Chr(9),"")
          If Val(sLine)=0 And sLine<>"";keine einfache zahl und auch nicht leer
            If CountString(sLine, ":")=4
              If CountString(sLine, ",")=2 And CountString(sLine, ".")=0 And CountString(sLine, "-->")=1
                FoundCount+1
                FoundType=#SUBTITLE_SRT_1
                ;Break
              EndIf  
              If CountString(sLine, ",")=1 And CountString(sLine, ".")=2 And CountString(sLine, "-->")=0
                FoundCount+1
                FoundType=#SUBTITLE_SRT_2
                ;Break
              EndIf 
            EndIf  
          EndIf  
        Next
        If FoundCount>2
          Result=FoundType
          If Result=#SUBTITLE_SRT_1
            WriteLog("SUBTITLE_SRT_1", #LOGLEVEL_DEBUG)
          Else
            WriteLog("SUBTITLE_SRT_2", #LOGLEVEL_DEBUG)
          EndIf  
        EndIf  
      EndIf
    EndIf
    
    If Result=#SUBTITLE_UNKNOWN
      sText.s=ReplaceString(ReplaceString(searchString,Chr(13), Chr(10)),Chr(10)+Chr(10), Chr(10))
      iCount=CountString(sText, Chr(10))
      If iCount
        FoundCount=0
        For i=1 To iCount
          sLine=StringField(sText, i, Chr(10))
          If FindString(sLine, ":", 1)>=3
            FoundCount+1
          EndIf  
        Next  
        If FoundCount>10
          Result=#SUBTITLE_SRT_3
          WriteLog("SUBTITLE_SRT_3", #LOGLEVEL_DEBUG)
        EndIf  
      EndIf
    EndIf  
    
  EndIf  
  ProcedureReturn Result
EndProcedure
Procedure LoadSubtileFromMem(*mem, qlen.q, dFrames.d)
  Protected Format
  If *mem And qlen
    FreeSubtitles()
    Format=GetSubtitleFormat(*mem, qlen.q)
    
    If Format=#SUBTITLE_UNKNOWN
      WriteLog("Unknown Subtitle format")
      ProcedureReturn #False
    EndIf
    WriteLog("Subtitle format "+Str(Format), #LOGLEVEL_DEBUG)
    
    
    Select Format
    Case #SUBTITLE_SUB_1
      ReadSubtitle_SUB_1(*mem, qlen.q, dFrames.d)
      
    Case #SUBTITLE_SUB_2
      ReadSubtitle_SUB_2(*mem, qlen.q, dFrames.d)
      
    Case #SUBTITLE_SRT_1
      ReadSubtitle_SRT_1(*mem, qlen.q, dFrames.d)
      
    Case #SUBTITLE_SRT_2
      ReadSubtitle_SRT_2(*mem, qlen.q, dFrames.d)
      
    Case #SUBTITLE_SRT_3
      ReadSubtitle_SRT_3(*mem, qlen.q, dFrames.d)
      
    EndSelect
    
    If ListSize(Subtiltes())>0
      iSubtitlesLoaded=#True
    EndIf  
    
    SortStructuredList(Subtiltes(), #PB_Sort_Ascending, OffsetOf(Subtitle\qStartTime), #PB_Quad)
  EndIf
EndProcedure
Procedure LoadSubtileFile(sFile.s, dFrames.d)
  Protected iFile.i, qlen.q, *mem, iResult.i=#False
  If sFile
    If FileSize(sFile)<1024*1024*50
      iFile=ReadFile(#PB_Any, sFile)
      If iFile
        qlen=Lof(iFile)
        If qlen>0
          *Mem = AllocateMemory(qlen)
          If *Mem
            If ReadData(iFile, *Mem, qlen)>0
              iResult=#True
            EndIf  
          Else
            WriteLog("out of memory")
          EndIf  
        EndIf  
        CloseFile(iFile)
      EndIf
    Else
      WriteLog("Subtitle file is bigger than 50MB!")
    EndIf
  EndIf
  If iResult And *Mem And qlen
    iResult = LoadSubtileFromMem(*mem, qlen.q, dFrames.d)
    FreeMemory(*Mem)
  EndIf  
  ProcedureReturn iResult
EndProcedure

Procedure.s FindSubtileFile(sMediaFile.s)
  Protected sFileWithoutExtension.s, sExt.s, i.i, sProtokoll.s
  If sMediaFile
    sFileWithoutExtension=Mid(sMediaFile, 1, Len(sMediaFile)-Len(GetExtensionPart(sMediaFile)))
    sProtokoll=URL_GetProtocol(sMediaFile)
    If sProtokoll<>"http" And sProtokoll<>"https"
      For i=1 To CountString(#SUBTITLE_FILE_EXTENSIONS, ";")
        sExt.s=StringField(#SUBTITLE_FILE_EXTENSIONS, i, ";")
        If FileSize(sFileWithoutExtension+sExt)>0
          ProcedureReturn sFileWithoutExtension+sExt
        EndIf 
      Next 
    EndIf
  EndIf  
  ProcedureReturn ""
EndProcedure  


Global SubtitleTextHeight

Procedure GetTextWithLen(sText.s, iLen)
  Protected w
  w = TextWidth(sText)
  While w>iLen
    sText=Mid(sText, 1, Len(sText)-1)
    w = TextWidth(sText)
  Wend
  ProcedureReturn Len(sText)
EndProcedure  
Procedure CreateSubtitleimage(sText.s)
  Protected iImage.i, w, y, x, pos, oldpos, sNewText.s, BRPos
  If IsFont(#FONT_SUBTITLE)
    iImage=CreateImage(#PB_Any, 1024, 1024, 32|#PB_Image_Transparent );32
    If iImage
      StartDrawing(ImageOutput(iImage))
      ;DrawingMode(#PB_2DDrawing_AlphaChannel)
      ;Box(0, 0, 512, 512, $00000000)
      BackColor($00000000)
      DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
      DrawingFont(FontID(#FONT_SUBTITLE))
      ;w = TextWidth(sText)
      
      y=0
      Repeat
        oldpos=pos
        pos=GetTextWithLen(sText, 1024)
        BRPos=FindString(sText, "[BR]", 1)
        If BRPos>0 And BRPos<pos:pos=BRPos+3:EndIf      
        sNewText=RemoveString(Mid(sText, 1, pos),"[BR]")
        
        x=(1024-TextWidth(sNewText))/2
        DrawText(x, y, sNewText, RGBA(255,255,255,255))
        y+TextHeight(sNewText)
  
        sText=Mid(sText, pos+1)
      Until Len(sText)=0
      SubtitleTextHeight=y
      
      StopDrawing()
    EndIf
  EndIf
  ProcedureReturn iImage
EndProcedure  
Procedure SetSubtitle(NoSubtitle.i=#False, Replace=#False)
  Protected Image
  If NoSubtitle
    If sLastSubtitleText<>""
      sLastSubtitleText=""
      If iMediaObject
        DShow_RemoveVMRImage(iMediaObject)
      EndIf  
      ;CreateSubtitleimage(sLastSubtitleText)
      ;BILD LÖSCHEN
    EndIf  
  Else  
    iLastSubtitleIndex=ListIndex(Subtiltes()) 
    If sLastSubtitleText<>Subtiltes()\sText Or Replace
      sLastSubtitleText=Subtiltes()\sText
      ;Debug sLastSubtitleText
      Image=CreateSubtitleimage(sLastSubtitleText)
      If image And IsImage(image)
        
        If iMediaObject
          If DShow_IsRenderlessVMR9(iMediaObject)
            ;Debug Image
            DShow_SetVMRImage(iMediaObject, Image, 0, (1024-SubtitleTextHeight)/1024-0.01, 1, 1, 0, 0, -1, -1, #False, 0, 1)
          Else
            DShow_SetVMRImage(iMediaObject, Image, 0, (1024-SubtitleTextHeight)/1024-0.01, 1, 1, 0, 0, -1, -1, #True, 0, 1)
          EndIf  
        EndIf
        FreeImage(Image)
      EndIf
      
      
      ;NEUES BILD ANZEIGEN
      ;Debug sLastSubtitleText
    EndIf  
  EndIf  
EndProcedure  
Procedure DisplaySubtitle(qTime.q, Replace=#False)
  Protected iFound.i
  If iSubtitlesLoaded
    SelectElement(Subtiltes(), iLastSubtitleIndex)
    If Subtiltes()\qStartTime<=qTime And Subtiltes()\qEndTime>=qTime
      ;Richtiger Untertitel wird bereits angezeigt.
      SetSubtitle(#False, Replace)
      
      ;Wenn aber der nächte auch schon kommt soll dieser angezeigt werden.
      SelectElement(Subtiltes(), iLastSubtitleIndex+1)
      If Subtiltes()\qStartTime<=qTime And Subtiltes()\qEndTime>=qTime
        SetSubtitle(#False, Replace)
      EndIf  
      
    Else
      SelectElement(Subtiltes(), iLastSubtitleIndex+1)
      If Subtiltes()\qStartTime<=qTime And Subtiltes()\qEndTime>=qTime
        SetSubtitle(#False, Replace)
      Else
        iFound.i=#False
        ForEach Subtiltes()
          If Subtiltes()\qStartTime<=qTime And Subtiltes()\qEndTime>=qTime
            
            SetSubtitle(#False, Replace)
            iFound.i=#True
            Break
          EndIf  
        Next
        If iFound.i=#False
          SetSubtitle(#True)
        EndIf  
      EndIf  
    EndIf  
  EndIf
EndProcedure

Procedure SetSubtitleSize(Size.i)
  UsedSubtitleSize=Size
  If IsFont(#FONT_SUBTITLE)
    FreeFont(#FONT_SUBTITLE)
  EndIf  
  
  LoadFont(#FONT_SUBTITLE, #SUBTITLE_FONNT_NAME, Size, #SUBTITLE_FONNT_STYLE)
  If IsFont(#FONT_SUBTITLE)=#Null
    LoadFont(#FONT_SUBTITLE, "Arial", Size, #SUBTITLE_FONNT_STYLE)
  EndIf
  
  DisplaySubtitle(MediaPosition(IMediaObject), #True)
EndProcedure  

;SaveImage(CreateSubtitleimage("test"), "test.bmp")



;{ Sample
;LoadSubtileFile("C:\TEST\test.srt", 24)
;FindSubtileFile("C:\TEST\tester.avi")

;}
;{ SUBTIBLE FORMATS:
;*****************
;*****************
;#SUBTITLE_UNKNOWN
;  Unknown
;
;  
;#SUBTITLE_SUB_1 ;IN ZEHNTEL SEKUNDEN []
;  [255][301]test test test test test
;  [302][319]test test test test test
;  
;  
;#SUBTITLE_SUB_2 ;IN FRAMES {}
;  {4459}{4534}test test test test test
;  {4730}{4777}test test test test test
;  
;  
;#SUBTITLE_SRT_1
;  7
;  00:00:45,548 --> 00:00:50,019
;  test test test test test
;  test test test test test
;  
;  8
;  00:00:50,148 --> 00:00:54,266
;  test test test test test
;  test test test test test
;  
;  
;#SUBTITLE_SRT_2
;  00:00:05.61,00:00:08.93
;  test...[br]test test test test test
;  
;  00:00:10.16,00:00:12.56
;  test test test test test
;
;
;#SUBTITLE_SRT_3
;  00:00:01:test test test test test|
;  00:00:34:test test test test test...
;}
; IDE Options = PureBasic 5.21 LTS Beta 1 (Windows - x86)
; CursorPosition = 389
; FirstLine = 267
; Folding = e9s-
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
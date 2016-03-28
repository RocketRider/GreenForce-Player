;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit



Enumeration
  #DATATYPE_BINARY
  #DATATYPE_TEXT_ASCII
  #DATATYPE_TEXT_UNICODE
  #DATATYPE_TEXT_UTF8
  #DATATYPE_TEXT_UNKNOWN
EndEnumeration

#MIN_UTF8_COUNT = 4
#TEMPBUFFER_SIZE = $FFFF

Structure FILEINFO
  pTempBuffer.BYTE[#TEMPBUFFER_SIZE]
EndStructure

Global g_FILEINFO.FILEINFO

Procedure.i FILEINFO_IsAlpha(iChar.i)
  iChar & $FF
  If iChar > 126
    ProcedureReturn #False
  EndIf
  
  If iChar < 32 And iChar <> 10 And iChar <> 13 And iChar <> 9
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure.i FILEINFO_IsUTF8Char(iChar.i)
  If iChar & %11100000 = %11000000 And (iChar >> 8) & %11000000 = %10000000
    ProcedureReturn #True
  EndIf
  
  If iChar & %11110000 = %11100000 And (iChar >> 8) & %11000000 = %10000000 And (iChar >> 16) & %11000000 = %10000000
    ProcedureReturn #True
  EndIf
  
  If iChar & %11111000 = %11110000 And (iChar >> 8) & %11000000 = %10000000 And (iChar >> 16) & %11000000 = %10000000  And (iChar >> 24) & %11000000 = %10000000
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure.i FILEINFO_IsUnicode(iChar.i)
  iChar & $FFFF
  If iChar > 126
    ProcedureReturn #False
  EndIf
  
  If iChar < 32 And iChar <> 10 And iChar <> 13 And iChar <> 9
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure FILEINFO_GetFileFormat(sFile.s)
Protected iAsciiCount.i, iUTF8Count.i, iUnicodeCount.i, iBinaryCount.i, iResult.i, iFile.i, iSize.i, iStringFormat.i, *pPtr.LONG, i.i, iChar.i, bFound.i
iAsciiCount.i = 0
iUTF8Count.i = 0
iUnicodeCount.i = 0
iBinaryCount.i = 0

iResult = #DATATYPE_TEXT_UNKNOWN

iFile.i = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )

If iFile
  iSize = Lof(iFile)
  If iSize > #TEMPBUFFER_SIZE: iSize = #TEMPBUFFER_SIZE:EndIf ; read only $FFFF bytes of the file

  If iSize > 0
    iStringFormat.i = ReadStringFormat(iFile)
    If iStringFormat <> #PB_Ascii
      ;BOM found
      CloseFile(iFile)
        
      Select iStringFormat
      Case #PB_UTF8
        ProcedureReturn #DATATYPE_TEXT_UTF8
      Case #PB_Unicode
        ProcedureReturn #DATATYPE_TEXT_UNICODE
      Default
        ProcedureReturn #DATATYPE_TEXT_UNKNOWN 
      EndSelect  
      
    EndIf    
      
    ReadData(iFile, g_FILEINFO\pTempBuffer, iSize)
    *pPtr.LONG = g_FILEINFO\pTempBuffer
    For i = 0 To iSize - 4
      iChar.i = *pPtr\l
      *pPtr + SizeOf(BYTE)
      bFound.i = #False
      If FILEINFO_IsAlpha(iChar):bFound = #True:iAsciiCount + 1:EndIf
      If FILEINFO_IsUTF8Char(iChar):bFound = #True:iUTF8Count + 1:EndIf
      If FILEINFO_IsUnicode(iChar):bFound = #True:iUnicodeCount + 2:EndIf
      If bFound = #False
        iBinaryCount + 1
      EndIf
      
    Next
    
  EndIf
  CloseFile(iFile)  
EndIf

If iBinaryCount > iAsciiCount And iBinaryCount > iUnicodeCount And iBinaryCount > iUTF8Count
  ProcedureReturn #DATATYPE_BINARY
EndIf

If iUnicodeCount > iAsciiCount
  ProcedureReturn #DATATYPE_TEXT_UNICODE
EndIf

If iUTF8Count >= #MIN_UTF8_COUNT
  ProcedureReturn #DATATYPE_TEXT_UTF8
EndIf

ProcedureReturn #DATATYPE_TEXT_ASCII
EndProcedure

Procedure SecureDelete(sFile.s)
  If DeleteFile(sFile) = #False
    MoveFileEx_(sFile, #Null, #MOVEFILE_DELAY_UNTIL_REBOOT)
  EndIf
EndProcedure  
  
;{ Sample
; 
; 
; Debug FILEINFO_GetFileFormat("C:\test.wmv")
; 
;}


; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 75
; FirstLine = 41
; Folding = Y-
; EnableXP
; UseMainFile = Player.pb
; EnableCompileCount = 2
; EnableBuildCount = 0
; EnableExeConstant
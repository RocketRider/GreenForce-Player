;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit


;-> Unicode, UTF8 Unterstützen (PeekS)
Procedure.s INI_Catch(*Addr, len)
  Protected sResult.s
  If *Addr And len
    sResult=PeekS(*Addr, len, #PB_Ascii)
    sResult=ReplaceString(sResult, Chr(10), Chr(13))
    sResult=ReplaceString(sResult, Chr(13)+Chr(13), Chr(13))
  EndIf  
  ProcedureReturn sResult.s
EndProcedure
Procedure.s INI_Load(sFile.s)
  Protected sResult.s, iFile, length, *MemoryID
  If sFile
    iFile=ReadFile(#PB_Any, sFile)
    If iFile
      length = Lof(iFile)
      If length
        *MemoryID = AllocateMemory(length)
        If *MemoryID
          ReadData(iFile, *MemoryID, length)
          sResult=INI_Catch(*MemoryID, length)
          FreeMemory(*MemoryID)
        EndIf  
      EndIf          
      CloseFile(iFile)
    EndIf  
  EndIf  
  ProcedureReturn sResult.s
EndProcedure
Procedure.s INI_GetGroupData(sINI.s, sGroup.s)
  Protected sResult.s, startpos, endpos
  startpos=FindString(UCase(sINI), "["+UCase(sGroup)+"]", 1)
  If startpos>0
    
    startpos+Len(sGroup)+2
    endpos=FindString(sINI, "[", startpos+1)
    If endpos<=0:endpos=Len(sINI):EndIf
    sResult=Mid(sINI, startpos, endpos-startpos)
    
  EndIf
  ProcedureReturn sResult
EndProcedure
Procedure.s INI_GetKeyData(sINI.s, sKey.s)
  Protected sResult.s, startpos, endpos
  sKey=UCase(sKey)
  startpos=FindString(UCase(sINI), sKey, 1)
  If startpos>0
    startpos=FindString(UCase(sINI), "=", startpos)
    If startpos>0
      startpos+1
      endpos=FindString(sINI, Chr(13), startpos)
      If endpos=0:endpos=Len(sINI):EndIf
      sResult=Mid(sINI, startpos, endpos-startpos)
    EndIf
    
  EndIf
  
  ProcedureReturn sResult
EndProcedure


;{ Sample
; Define Ini.s
; Ini=INI_Load("..\testINI.txt")
; Debug Ini
; Debug INI_GetGroupData(Ini, "files")
; Debug INI_GetKeyData(Ini, "B")
;}


; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = v
; EnableXP
; EnableUser
; EnableCompileCount = 14
; EnableBuildCount = 0
; EnableExeConstant
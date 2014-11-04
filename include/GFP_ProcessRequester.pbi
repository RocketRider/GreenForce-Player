;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

#PROCESSREQUESTER_FILEMAPPING_SIZE = 100000

Structure PROCESSREQUESTER_GLOBALS
  isOpenRequester.i
  isSaveRequester.i
  filemapping.s
  hFilemapping.i
  title.s
  standardFile.s
  pattern.s
  patternPos.i
  multiSelection.i
EndStructure  
  
Global g_ProcRequest.PROCESSREQUESTER_GLOBALS


Prototype __ProcessWindowEvents()


Procedure __ProcessDebug(text.s)
  ;Debug text
EndProcedure

Procedure __ProcessError(text.s)
  ;Debug text
EndProcedure

Procedure GlobalFile_Create(sName.s, iSize.i)
ProcedureReturn CreateFileMapping_(#INVALID_HANDLE_VALUE,#Null,#PAGE_READWRITE,0, iSize, sName)
EndProcedure

Procedure GlobalFile_Open(sName.s)
ProcedureReturn OpenFileMapping_(#FILE_MAP_ALL_ACCESS, #False, sName)
EndProcedure


Procedure GlobalFile_Lock(hFileMapping.i)
ProcedureReturn MapViewOfFile_(hFileMapping,#FILE_MAP_ALL_ACCESS,0,0,0)
EndProcedure

Procedure GlobalFile_UnLock(*Buffer)
ProcedureReturn UnmapViewOfFile_(*Buffer)
EndProcedure

Procedure GlobalFile_Free(hFileMapping.i)
ProcedureReturn CloseHandle_(hFileMapping)
EndProcedure

Procedure.s GetCMDLine()
  Protected *CmdLine
  *CmdLine = GetCommandLine_()
  If *CmdLine
    ProcedureReturn PeekS(*CmdLine)
  EndIf
EndProcedure

Procedure.s GetFilemappingCMD(Filemapping.s)
  Protected result.s, hFilemapping, *ptr
  hFilemapping = GlobalFile_Open(Filemapping.s)
  If hFilemapping
    *ptr = GlobalFile_Lock(hFilemapping)
    If *ptr
      result.s = PeekS(*ptr, #PROCESSREQUESTER_FILEMAPPING_SIZE)
      GlobalFile_UnLock(*ptr)
    EndIf
    GlobalFile_Free(hFilemapping)
  EndIf
  ProcedureReturn result
EndProcedure

Procedure.s GetFilemappingHandleCMD(hFilemapping)
  Protected result.s, *ptr
  If hFilemapping
    *ptr = GlobalFile_Lock(hFilemapping)
    If *ptr
      result.s = PeekS(*ptr, #PROCESSREQUESTER_FILEMAPPING_SIZE)
      GlobalFile_UnLock(*ptr)
    EndIf
  EndIf
  ProcedureReturn result
EndProcedure

Procedure.i SetFilemappingCMD(hFilemapping, text.s)
  Protected result.i = #False, *ptr
  If hFilemapping
    *ptr = GlobalFile_Lock(hFilemapping)
    If *ptr
      result = #True
      ZeroMemory_(*ptr, #PROCESSREQUESTER_FILEMAPPING_SIZE)
      PokeS(*ptr, text, #PROCESSREQUESTER_FILEMAPPING_SIZE)
      GlobalFile_UnLock(*ptr)
    EndIf
  EndIf
  ProcedureReturn result
EndProcedure

Procedure.s GetParam(str.s, iIndex.i)
Protected sResult.s = "", i.i, lch.s, ch.s, bInQuote, idx
str + " "
For i = 1 To Len(str)

  lch.s = ch.s
  ch.s = Mid(str, i, 1)
  
  If ch = Chr(34)
    bInQuote = ~bInQuote
  EndIf
  
  If ch = " " And bInQuote = #False And lch <> " "
    If iIndex = idx
      ProcedureReturn Trim(sResult)
    EndIf
    idx+1
    sResult = ""
  EndIf
  sResult + ch
Next
EndProcedure

Procedure.s QuoteString(str.s)
  ProcedureReturn Chr(34) + str + Chr(34)
EndProcedure

Procedure.s RemoveQuoteString(str.s)
  If Left(str, 1) = Chr(34) And Right(str, 1) = Chr(34)
    str = Left(str, Len(str) - 1)
    str = Right(str, Len(str) -1)  
    ProcedureReturn str
  Else
    ProcedureReturn str
  EndIf
EndProcedure


Procedure __ProcessReqester_Init()
  Protected bResult = #False, param.s, idx
  g_ProcRequest\isOpenRequester = #False
  g_ProcRequest\isSaveRequester = #False
  g_ProcRequest\title = ""
  g_ProcRequest\filemapping = ""
  g_ProcRequest\pattern = "All Files(*.*)|*.*"
  g_ProcRequest\patternPos = 0
  g_ProcRequest\standardFile = ""
  g_ProcRequest\hFilemapping = #Null
  Repeat
    param.s = GetParam(GetCMDLine(), idx)
    
    If UCase(param) = "$OPENDIALOG"
      g_ProcRequest\isOpenRequester = #True
    EndIf
    If UCase(param) = "$SAVEDIALOG"
      g_ProcRequest\isSaveRequester = #True
    EndIf    
    
     If Left(UCase(param), Len("$FILEMAPPING:")) = "$FILEMAPPING:"
      g_ProcRequest\filemapping = (Right(param, Len(param) - Len("$FILEMAPPING:")))
    EndIf        
    idx + 1
  Until param = ""
  If (g_ProcRequest\isOpenRequester Or g_ProcRequest\isSaveRequester) And g_ProcRequest\filemapping <> ""
    bResult = #True
  EndIf
  ProcedureReturn bResult
EndProcedure


Procedure __ProcessReqester_AnalyzePrams()
  Protected Cmd.s, param.s, idx.i
  Cmd.s = GetFilemappingCMD(g_ProcRequest\filemapping)
  Repeat
    param.s = RemoveQuoteString(GetParam(Cmd, idx))
    
    If Left(UCase(param), Len("TITLE:")) = "TITLE:"
      g_ProcRequest\title = Right(param, Len(param) - Len("TITLE:"))
    EndIf  
    If Left(UCase(param), Len("FILE:")) = "FILE:"
      g_ProcRequest\standardFile = Right(param, Len(param) - Len("FILE:"))
    EndIf  
    If Left(UCase(param), Len("PATTERN:")) = "PATTERN:"
      g_ProcRequest\pattern = Right(param, Len(param) - Len("PATTERN:"))
    EndIf  
    If Left(UCase(param), Len("PATTERNPOS:")) = "PATTERNPOS:"
      g_ProcRequest\patternPos = Val(Right(param, Len(param) - Len("PATTERNPOS:")))
    EndIf      
    If Left(UCase(param), Len("MULTISELECT:")) = "MULTISELECT:"
      g_ProcRequest\multiSelection = Val(Right(param, Len(param) - Len("MULTISELECT:")))
    EndIf       
    idx + 1
  Until param = ""
EndProcedure  


; will be executed in new process
Procedure ProcessRequester_Run()
  Protected result.s, nextfile.s
  If __ProcessReqester_Init()
    __ProcessReqester_AnalyzePrams()
    
    g_ProcRequest\hFilemapping = GlobalFile_Open(g_ProcRequest\filemapping)
    If g_ProcRequest\hFilemapping
      
      If g_ProcRequest\isOpenRequester
        If  g_ProcRequest\multiSelection
          result.s = OpenFileRequester( g_ProcRequest\title,  g_ProcRequest\standardFile,  g_ProcRequest\pattern,  g_ProcRequest\patternPos,  #PB_Requester_MultiSelection)
        Else
          result.s = OpenFileRequester( g_ProcRequest\title,  g_ProcRequest\standardFile,  g_ProcRequest\pattern,  g_ProcRequest\patternPos)      
        EndIf
      EndIf
    
      If g_ProcRequest\isSaveRequester
          result.s = SaveFileRequester( g_ProcRequest\title,  g_ProcRequest\standardFile,  g_ProcRequest\pattern,  g_ProcRequest\patternPos)      
      EndIf
      
      If  g_ProcRequest\multiSelection And g_ProcRequest\isOpenRequester
        If result <> ""
          Repeat
            nextfile.s = NextSelectedFileName() 
            If nextfile <> ""
              result = result + "|" + nextfile
            EndIf 
          Until nextfile = ""
        EndIf
      EndIf
      
      SetFilemappingCMD(g_ProcRequest\hFilemapping, result)
      GlobalFile_Free(g_ProcRequest\hFilemapping)
    EndIf
    End ; exit process
  EndIf
EndProcedure



Procedure.s ProcessRequester_Open(title.s, filename.s, pattern.s, patternpos.i, multiselect.i, save.i, processWndEvent.__ProcessWindowEvents)
  Protected result.s = "", filemapping.s, hFilemapping.i
  Protected text.s, program, event
  filemapping.s = "ReqesterParams_" + Hex(Random($FFFF))+ Hex(Random($FFFF))
  
  hFilemapping = GlobalFile_Create(filemapping, #PROCESSREQUESTER_FILEMAPPING_SIZE)
  
  If hFilemapping
    text.s = "$REQUESTERPARAMETERS:TRUE " ; just there to identify 
    text.s + QuoteString("TITLE:" + title) + " "
    text.s + QuoteString("FILE:" + filename) + " "  
    text.s + QuoteString("PATTERN:" + pattern) + " " 
    text.s + QuoteString("PATTERNPOS:" + Str(patternpos)) + " " 
    text.s + QuoteString("MULTISELECT:" + Str(multiselect))
    
    If SetFilemappingCMD(hFilemapping, text)
    
      If save
        program = RunProgram(ProgramFilename(), "$SAVEDIALOG $FILEMAPPING:" + filemapping, "", #PB_Program_Open)
      Else
        program = RunProgram(ProgramFilename(), "$OPENDIALOG $FILEMAPPING:" + filemapping, "", #PB_Program_Open)    
      EndIf
      
      If program
        If processWndEvent
           
          While ProgramRunning(program)
            processWndEvent()

           Wend 
        Else  
          WaitProgram(program)
        EndIf
        CloseProgram(program)
        result.s = GetFilemappingHandleCMD(hFilemapping)
        If Left(result, Len("$REQUESTERPARAMETERS:TRUE")) = "$REQUESTERPARAMETERS:TRUE"
          ; content was not overwritten, so return empty string
          result = ""
        EndIf              
      Else
        __ProcessError("Cannot open program " + ProgramFilename() )
      EndIf

    Else
      __ProcessError("Cannot write parameters into filemapping")
    EndIf
    GlobalFile_Free(hFilemapping)    
  Else
    __ProcessError("Cannot create filemapping:" + filemapping)
  EndIf
  ProcedureReturn result
EndProcedure

;{ Sample
; 
; DisableExplicit
; ProcessRequester_Run()
; 
; OpenWindow(1,0,0,200,200,"")
; 
; For T=0 To 1000
;   WindowEvent()
; Next  
; Debug ProcessRequester_Open("", "file.bat", "all files|*.*", 0, #True, #False, #True)
; 
;}


; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 32
; Folding = ----
; EnableXP
; CommandLine = $OPEN_FILE_DIALOG TEST TEST2
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
Declare __AnsiString(str.s)
Declare GetDPI()
Declare Requester_Error(sText.s)
Global sLogFileName.s = "Log.txt"
Global iLogWindow.i, iLogWindow_View.i
Global iGlobalLogFile.i

Enumeration
  #LOGLEVEL_NONE
  #LOGLEVEL_ERROR
  #LOGLEVEL_DEBUG
EndEnumeration

Procedure.s SecurePeeks(*addr, iMax.i = 1024)
  Protected Str.s, iCount =0, Byte.i, ByteRead
  If *addr
    Str.s = Space(iMax + 1)
    If @Str
      Repeat  
        ReadProcessMemory_(GetCurrentProcess_(), *addr + iCount, @Byte, 1, @ByteRead)
        If ByteRead
          PokeB(@Str+ iCount, Byte)
        EndIf
        iCount + 1   
      Until ByteRead = 0 Or Byte = 0 Or iCount >= iMax
      ProcedureReturn Str
    EndIf
  EndIf
EndProcedure

Procedure.l __GetNumFuncs(*Library.IMAGE_DOS_HEADER)
  Protected *ptr.LONG,*pEntryExport.IMAGE_EXPORT_DIRECTORY
  Protected *Img_NT_Headers.IMAGE_NT_HEADERS
  
  If *Library=#Null:ProcedureReturn 0:EndIf  
  If *Library\e_lfanew = #Null:ProcedureReturn 0:EndIf
  *Img_NT_Headers=*Library+*Library\e_lfanew
  
  If *Img_NT_Headers = #Null:ProcedureReturn 0:EndIf
  If *Img_Nt_Headers\OptionalHeader = #Null:ProcedureReturn 0:EndIf  
  If *Img_Nt_Headers\OptionalHeader\DataDirectory = #Null:ProcedureReturn 0:EndIf
  
  *ptr=*Img_Nt_Headers\OptionalHeader\DataDirectory
  If *ptr\l = #Null:ProcedureReturn 0:EndIf 
  *pEntryExport=*Library+*ptr\l

  If *pEntryExport=0:ProcedureReturn 0:EndIf
  ProcedureReturn *pEntryExport\NumberOfFunctions
EndProcedure
Procedure.s __GetFuncName(*Library.IMAGE_DOS_HEADER, lIndex.l)
  Protected *ptr.LONG,*pEntryExport.IMAGE_EXPORT_DIRECTORY
  Protected *Img_NT_Headers.IMAGE_NT_HEADERS
  
  If *Library=0:ProcedureReturn "":EndIf  
  *Img_NT_Headers=*Library+*Library\e_lfanew
  
  If *Img_NT_Headers = #Null:ProcedureReturn "":EndIf
  If *Img_NT_Headers\OptionalHeader = #Null:ProcedureReturn "":EndIf
  If *Img_NT_Headers\OptionalHeader\DataDirectory = #Null:ProcedureReturn "":EndIf
  
  *ptr=*Img_Nt_Headers\OptionalHeader\DataDirectory
  If *ptr\l = #Null:ProcedureReturn "":EndIf
  *pEntryExport=*Library+*ptr\l
 
  If *pEntryExport=0:ProcedureReturn "":EndIf
  
  If lIndex<1 Or lIndex>*pEntryExport\NumberOfFunctions Or *pEntryExport\AddressOfNames=0
    ProcedureReturn ""
  EndIf    
  
  *ptr=*Library+*pEntryExport\AddressOfNames+(lIndex-1)*4
  If *ptr\l = #Null:ProcedureReturn "":EndIf
  
  ProcedureReturn SecurePeeks(*Library+*ptr\l)
EndProcedure
Procedure.s __GetModuleOfAddress(*addr)
  Protected sName.s,sResult.s, snapshot.i, Moduleen.MODULEENTRY32, mem.MEMORY_BASIC_INFORMATION
  
  sResult = "unknown module"
  If *addr=#Null:ProcedureReturn sResult:EndIf
  VirtualQuery_(*addr,mem, SizeOf(MEMORY_BASIC_INFORMATION))
  
  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPMODULE, 0) 
  If snapshot 
  
      Moduleen.MODULEENTRY32
      Moduleen\dwSize = SizeOf(MODULEENTRY32) 
      
      If Module32First_(snapshot, @Moduleen)
        While Module32Next_(snapshot, @Moduleen)         
          If Moduleen\hModule = mem\AllocationBase And Moduleen\hModule <> #Null
            sName=Space(4096)
            GetModuleFileName_(Moduleen\hModule, @sName, 4096)
            sResult=Trim(sName)
            If sResult =""
              sResult = SecurePeeks(@Moduleen\szModule)   
            EndIf
            
          EndIf   
        Wend
      EndIf    
     
      CloseHandle_(snapshot)
    EndIf 
    If GetModuleHandle_(0) = mem\AllocationBase
      ;sResult = GetFilePart(ProgramFilename())  
      sResult = ProgramFilename()
    EndIf
ProcedureReturn sResult
EndProcedure
Procedure.s __GetModuleFunctionOfAddress(*addr)
  Protected sResult.s, snapshot.i, Moduleen.MODULEENTRY32, mem.MEMORY_BASIC_INFORMATION
  Protected qFuncAddr.q,FuncName.s, qLastFunctionPtr.q = #Null, qAddr.q, iNum.i
  
  If *addr=#Null:ProcedureReturn "":EndIf
  VirtualQuery_(*addr, mem, SizeOf(MEMORY_BASIC_INFORMATION))
  
  snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPMODULE, 0) 
  If snapshot 
  
      Moduleen.MODULEENTRY32
      Moduleen\dwSize = SizeOf(MODULEENTRY32) 
      sResult.s = "unknown function"
      
      If Module32First_(snapshot, @Moduleen)
        While Module32Next_(snapshot, Moduleen)         
          If Moduleen\hModule = mem\AllocationBase And Moduleen\hModule <> #Null
            
            ;more than 25000 seems to be wrong...
            iNum = __GetNumFuncs(Moduleen\hModule) 
            If iNum < 25000 And iNum > 0
              For iNum=1 To __GetNumFuncs(Moduleen\hModule)
                qAddr = *addr & $FFFFFFFF
                FuncName.s = __GetFuncName(Moduleen\hModule, iNum) 
                If FuncName <> ""
                  qFuncAddr = GetProcAddress_(Moduleen\hModule, FuncName)  & $FFFFFFFF
                  If qFuncAddr
                    If qFuncAddr > qLastFunctionPtr
                      If qAddr >= qFuncAddr
                        qLastFunctionPtr = qFuncAddr
                        sResult = "possible function "+ Chr(34) + FuncName + Chr(34) +" (+"+Str(qAddr- qFuncAddr)+" bytes)"
                      EndIf
                    EndIf
                  EndIf
                EndIf
              Next
            EndIf
            
          EndIf   
        Wend
      EndIf        
      CloseHandle_(snapshot)
    EndIf 
    
ProcedureReturn sResult
EndProcedure

Procedure WriteWindowsVersion(File.i)
  Protected System.s
  If File
    System.s = "Graphiccard name: " + GetGraphicCardName() + ", Processor name: " + GetCPUName() + ", Windows: " + GetWindows() + ", Programversion: "+#PLAYER_VERSION+"."+Str(#USE_OEM_VERSION)+" Bulid: " + Str(#PB_Editor_BuildCount) +", DPI: "+Str(GetDPI())
    If Lof(File)=0 
      WriteStringN(File, System)
    EndIf
    FileSeek(File, 0)
    If Trim(ReadString(File))<>Trim(System)
      FileSeek(File, 0)
      TruncateFile(File)
      WriteStringN(File, System)
    EndIf
  EndIf
EndProcedure


Procedure.s GetLastErrorString()
  Protected Err.s
  Err.s=Space(1000)
  FormatMessage_(#FORMAT_MESSAGE_FROM_SYSTEM|#FORMAT_MESSAGE_IGNORE_INSERTS,#Null,GetLastError_(),0,@Err.s,1000,#Null)
  Err.s = Trim(Err)
  Err.s = ReplaceString(Err, Chr(13), "")
  Err.s = ReplaceString(Err, Chr(10), "")
  Err.s + " (Error code: " + Str(GetLastError_()) + ")"
  ProcedureReturn Err
EndProcedure
Procedure.s GetErrorModule()
  ProcedureReturn __GetModuleOfAddress(ErrorAddress())
EndProcedure
Procedure.s GetErrorFunctionModule()
  ProcedureReturn __GetModuleFunctionOfAddress(ErrorAddress())
EndProcedure



Procedure WriteStringSecureN(file,Str.s)
 Protected written ,strbuffer
 Str.s + #CRLF$
 If FileID(file)
   FileBuffersSize(file, 0)
   strbuffer=__AnsiString(str.s)
   If strbuffer
     WriteFile_(FileID(file),strbuffer, Len(Str), @written, #Null)
     FreeMemory(strbuffer)
   EndIf  
 EndIf
EndProcedure
Procedure WriteStringSecure(file,Str.s)
 Protected written ,strbuffer
 If FileID(file)
   FileBuffersSize(file, 0)
   strbuffer=__AnsiString(str.s)
   If strbuffer
     WriteFile_(FileID(file),strbuffer, Len(Str), @written, #Null)
     FreeMemory(strbuffer)
   EndIf  
 EndIf
EndProcedure


Procedure InitLogFile()
  If iGlobalLogFile=#Null
    iGlobalLogFile = OpenFile(#PB_Any, sLogFileName.s)
    If iGlobalLogFile=#Null:iGlobalLogFile = OpenFile(#PB_Any, Hex(Random($FFFFF))+sLogFileName.s):EndIf
    If iGlobalLogFile
      FileBuffersSize(iGlobalLogFile, 0)
      WriteWindowsVersion(iGlobalLogFile)
      FileSeek(iGlobalLogFile, Lof(iGlobalLogFile))
      WriteStringN(iGlobalLogFile, "")
      WriteStringN(iGlobalLogFile, "")
      WriteStringN(iGlobalLogFile, "-----------------------------------------------------------------")
    EndIf
  EndIf
EndProcedure

Procedure FreeLogFile()
  If iGlobalLogFile
    If IsFile(iGlobalLogFile)
      CloseFile(iGlobalLogFile)
    EndIf
    iGlobalLogFile=0
  EndIf
EndProcedure





;Virtual file darf kein Text ins eigene Debug-Fenster ausgeben, da dies zu Hängern bei Openfilerequestern führen kann.
;Außerdem darf keine neue datei erstellt werden.
Macro WriteLog(sText, iLevel = #LOGLEVEL_ERROR, UselogWindow=#True)
  If iLastSettingsItem>1;Database was loaded:
    If Val(Settings(#SETTINGS_LOGLEVEL)\sValue)>#LOGLEVEL_NONE
      If iLevel = #LOGLEVEL_ERROR Or (iLevel = #LOGLEVEL_DEBUG And Val(Settings(#SETTINGS_LOGLEVEL)\sValue) = #LOGLEVEL_DEBUG)
        _WriteLog(sText + " (source:  " + GetFilePart(#PB_Compiler_File) + "\" + Str(#PB_Compiler_Line)+")", iLevel, UselogWindow)
      EndIf
    EndIf
  Else
    _WriteLog(sText + " (source: " + GetFilePart(#PB_Compiler_File) + "\" + Str(#PB_Compiler_Line)+")", iLevel, UselogWindow)
  EndIf
EndMacro
Procedure _WriteLog(sText.s, iLevel, UselogWindow)
  Protected Date.s, Time.s, File.i, OldGadgetList.i
  Date = FormatDate("%dd.%mm.%yyyy", Date())
  Time = FormatDate("%hh:%ii:%ss", Date())+":"+Str(GetTickCount_()%1000)
  File = iGlobalLogFile
  
  CompilerIf #USE_OEM_VERSION
    sText=ReplaceString(sText, "GFP", "VP")
  CompilerEndIf  
  
  If File
    WriteStringSecureN(File, Date + ", " + Time + ": " + sText)
    If Val(Settings(#SETTINGS_LOGLEVEL)\sValue) = #LOGLEVEL_DEBUG And UselogWindow
      If IsWindow(iLogWindow) And iLogWindow
        AddGadgetItem(iLogWindow_View, -1, sText)
      Else
        OldGadgetList=-1
        If IsWindow(#WINDOW_MAIN)
          OldGadgetList = UseGadgetList(WindowID(#WINDOW_MAIN))
        EndIf  
        iLogWindow = OpenWindow(#PB_Any, 0, 0, 400, 200, "Debug", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget)
        If iLogWindow
          UseGadgetList(WindowID(iLogWindow))
          iLogWindow_View=EditorGadget(#PB_Any, 0, 0, 400, 200, #PB_Editor_ReadOnly)
          AddGadgetItem(iLogWindow_View, -1, sText)
        EndIf
        If OldGadgetList<>-1
          UseGadgetList(OldGadgetList)
        EndIf  
      EndIf
    EndIf
  Else
    If UselogWindow
      InitLogFile()
      If iGlobalLogFile
        WriteStringSecureN(iGlobalLogFile, Date + ", " + Time + ": " + sText)
      EndIf
    EndIf
  EndIf
EndProcedure


Procedure ErrorHandler()
  Protected sText.s, LastErrorString.s
  LastErrorString.s=GetLastErrorString() ; ALS ALLER ERSTES!
  
  
  
  sText="Version: "+Chr(9)+#PLAYER_VERSION+"."+Str(#USE_OEM_VERSION)+" Build: "+Str(#PB_Editor_BuildCount)+#CRLF$
  sText+"OS: "+Chr(9)+GetWindows()+#CRLF$
  sText+"Graphic: "+Chr(9)+GetGraphicCardName()+#CRLF$
  sText+""+#CRLF$
  
  sText+"Source: "+Chr(9)+GetFilePart(ErrorFile())+#CRLF$
  sText+"Line: "+Chr(9)+Str(ErrorLine())+#CRLF$
  sText+"Desc: "+Chr(9)+ErrorMessage()+#CRLF$
  sText+"Code: "+Chr(9)+Str(ErrorCode())+#CRLF$
  sText+"Addr: "+Chr(9)+Str(ErrorAddress())+#CRLF$
  If ErrorCode() = #PB_OnError_InvalidMemory
    sText + "Target:  " + Chr(9) + Str(ErrorTargetAddress())+#CRLF$
  EndIf
  sText+"LastError:" + Chr(9) + LastErrorString+#CRLF$
  sText+"Module: "+Chr(9)+GetErrorModule()+#CRLF$
  sText+"Func: "+Chr(9)+GetErrorFunctionModule()+#CRLF$
  sText+"Mediafile: "+Chr(9)+GetFilePart(MediaFile\sRealFile)
    
  CompilerIf #USE_OEM_VERSION
    sText=ReplaceString(sText, "GFP", "VP")
  CompilerEndIf  
  
  _WriteLog("Fatal Error: "+#CRLF$+sText, #LOGLEVEL_ERROR, #True)
  
  
  CompilerIf #USE_OEM_VERSION
    SetClipboardText(sText)
  CompilerElse  
    SetClipboardText("Please send this to support@GFP.RRSoftware.de"+#CRLF$+sText)
  CompilerEndIf  
  Requester_Error(sText)
  End
EndProcedure
Procedure InitErrorHandler()
  If #PB_Editor_CreateExecutable
    OnErrorCall(@ErrorHandler())
  EndIf
EndProcedure




; IDE Options = PureBasic 5.21 LTS Beta 1 (Windows - x86)
; CursorPosition = 130
; FirstLine = 69
; Folding = Y---
; EnableXP
; EnableOnError
; UseMainFile = Player.pb
; Executable = GreenForce-Player.exe
; EnableCompileCount = 6
; EnableBuildCount = 2
; EnableExeConstant
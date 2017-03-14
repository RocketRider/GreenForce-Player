;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2017 RocketRider *******
;***************************************

Structure ACTCTX
  cbSize.i
  dwFlags.i
  *lpSource
  wProcessorArchitecture.w
  wLangId.i
  *lpAssemblyDirectory
  *lpResourceName
  *lpApplicationName
  *hModule
EndStructure

#LAVFILTERS_DOWNLOAD_WINDOW = 701

#LAVFILTERS_PATH = "\LAVFilters-0.69-x86"

#CLSCTX_INPROC_SERVER  = $01

Global _LAVFilters_Thread_Download_Result
Global _LAVFilters_Thread_Download_Mutex
Global _LAVFilters_cookie_video
Global _LAVFilters_cookie_audio
Global _LAVFilters_cookie_splitter
Global _LAVFilters_lib_video
Global _LAVFilters_lib_audio
Global _LAVFilters_lib_splitter
Global _LAVFilters_isRegistered
Global _LAVFilters_freshInstall = #False

Procedure.s __LAVFilters_GetSpecialFolder(ifolder.i)
  Protected *itemid.ITEMIDLIST, slocation.s
  *itemid.ITEMIDLIST = #Null
  If SHGetSpecialFolderLocation_(0, ifolder, @*itemid) = #NOERROR
    slocation.s = Space(#MAX_PATH)
    If SHGetPathFromIDList_(*itemid, @slocation)
      ProcedureReturn slocation
    EndIf
  EndIf
EndProcedure

Import "Kernel32.lib";Hotfix
  __LAVFilters_GetProcAddress_(hMod.i, Name.p-ascii) As "_GetProcAddress@8"
EndImport

Macro __LAVFilterError(sText)
  ;Debug sText
  WriteLog(sText, #LOGLEVEL_ERROR)
EndMacro

Procedure LAVFilters_IsInstalled()
  If FileSize(__LAVFilters_GetSpecialFolder(#CSIDL_APPDATA) +#LAVFILTERS_PATH+"\INSTALLED") = 0
    ProcedureReturn #True  
  Else
    ProcedureReturn #False
  EndIf  
EndProcedure

Procedure LAVFilters_IsFreshInstallation()
  ProcedureReturn _LAVFilters_freshInstall 
EndProcedure

Procedure LAVFilters_IsRegistered()
  ProcedureReturn _LAVFilters_isRegistered
EndProcedure

Procedure __Thread_Download_LAVFilters(*Parameters)
  Protected failed = #False
  Protected file
  Protected tmpFile.s = GetTemporaryDirectory() + "tmp_" + Hex(GetTickCount_())+".zip"
  
  Protected codec_dst.s = __LAVFilters_GetSpecialFolder(#CSIDL_APPDATA) + #LAVFILTERS_PATH + "\"
  ReceiveHTTPFile("https://github.com/Nevcairiel/LAVFilters/releases/download/0.69/LAVFilters-0.69-x86.zip", tmpFile.s)
  UseZipPacker()   
  If OpenPack(0, tmpFile.s,#PB_PackerPlugin_Zip) 
    CreateDirectory(codec_dst) ;Ignore result, could already exists    
    If FileSize(codec_dst) = -2
      If ExaminePack(0)
        While NextPackEntry(0)
          If Left(PackEntryName(0),Len("developer_info")) <> "developer_info"
            ;Debug "Name: " + PackEntryName(0) + ", Size: " + PackEntrySize(0)
            If UncompressPackFile(0, codec_dst.s + PackEntryName(0)) = -1
              failed = #True            
              __LAVFilterError( "failed to extract " + codec_dst.s + PackEntryName(0))
              Break
            EndIf  
          EndIf
        Wend         
        file = CreateFile(#PB_Any, codec_dst.s + "LAVAudio.sxs.manifest")
        If file
          WriteData(file, ?DATA_LAVAudio,?DATA_LAVAudio_End-?DATA_LAVAudio)
          CloseFile(file)
        Else
          failed = #True
          __LAVFilterError("failed to extract " + codec_dst.s + "LAVAudio.sxs.manifest")         
        EndIf  
        
        file = CreateFile(#PB_Any, codec_dst.s + "LAVSplitter.sxs.manifest")
        If file
          WriteData(file, ?DATA_LAVSplitter,?DATA_LAVSplitter_End-?DATA_LAVSplitter)
          CloseFile(file)
        Else
          failed = #True
          __LAVFilterError("failed to extract " + codec_dst.s + "LAVSplitter.sxs.manifest")         
        EndIf   
        
        file = CreateFile(#PB_Any, codec_dst.s + "LAVVideo.sxs.manifest")
        If file
          WriteData(file, ?DATA_LAVVideo,?DATA_LAVVideo_End-?DATA_LAVVideo)
          CloseFile(file)
        Else
          failed = #True
          __LAVFilterError("failed to extract " + codec_dst.s + "LAVVideo.sxs.manifest")       
        EndIf
      Else
        failed = #True
        __LAVFilterError("examine zip failed")
      EndIf 
    Else
      __LAVFilterError("failed to create directory " + codec_dst)
      failed = #True      
    EndIf
    ClosePack(0)
  Else
    __LAVFilterError("cannot open file " + tmpFile.s)
    failed = #True    
  EndIf
  DeleteFile_(tmpFile)
  
  If failed = #False
    file = CreateFile(#PB_Any, codec_dst.s + "INSTALLED")
    If file
      CloseFile(file)
    EndIf  
  EndIf  
  
  LockMutex(_LAVFilters_Thread_Download_Mutex)  
  If failed
    _LAVFilters_Thread_Download_Result = -1 
  Else
    _LAVFilters_Thread_Download_Result = 1    
  EndIf  
  UnlockMutex(_LAVFilters_Thread_Download_Mutex)    
EndProcedure


Procedure LAVFilters_Download(title.s, text.s)
  Protected event, res, downloadGadget,img;, font, textGadget
  UsePNGImageDecoder()
  If Not LAVFilters_IsInstalled()
    OpenWindow(#LAVFILTERS_DOWNLOAD_WINDOW,0,0,300,100, title.s, #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
    StickyWindow(#LAVFILTERS_DOWNLOAD_WINDOW, #True)
    SetWindowColor(#LAVFILTERS_DOWNLOAD_WINDOW,#White)
    ;font = LoadFont(#PB_Any, "Verdana", 50)
    ;textGadget = TextGadget(#PB_Any,5,5, 295,55, text)
    img = CatchImage(#PB_Any, ?DATA_img_downloading_codecs)
    ImageGadget(#PB_Any,5,5,295,55,ImageID(img))
    ;SetGadgetFont(textGadget, font)
    downloadGadget = ProgressBarGadget(#PB_Any, 10,60,280,20,0,100)
    ;TintGadget(downloadGadget, 10000, 10000, 10000, 0, -100, 0, 0, #False)
    SetGadgetState(downloadGadget,  #PB_ProgressBar_Unknown )
    _LAVFilters_Thread_Download_Mutex  = CreateMutex()
    _LAVFilters_Thread_Download_Result = 0
    Protected Thread = CreateThread(@__Thread_Download_LAVFilters(),0)
    Repeat
      event = WaitWindowEvent(16)
      LockMutex(_LAVFilters_Thread_Download_Mutex)
      res = _LAVFilters_Thread_Download_Result
      UnlockMutex(_LAVFilters_Thread_Download_Mutex)
      
    Until event = #PB_Event_CloseWindow Or res <> 0
    FreeMutex(_LAVFilters_Thread_Download_Mutex)
    CloseWindow(#LAVFILTERS_DOWNLOAD_WINDOW)
    If event = #PB_Event_CloseWindow
      KillThread(Thread)
    EndIf   
    If res = 1
      _LAVFilters_freshInstall = #True
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  Else
    ProcedureReturn #True
  EndIf
EndProcedure


Procedure __LAVFilters_OpenLibrary(sNameDLL.s, *lib.integer)
  Protected sPath.s = __LAVFilters_GetSpecialFolder(#CSIDL_APPDATA) + #LAVFILTERS_PATH  
  *lib\i = OpenLibrary(#PB_Any, sPath.s + "\" + sNameDLL.s)
  If *lib\i
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf  
EndProcedure

Procedure __LAVFilters_Register(sNameManifest.s, *cookie.integer)
  Protected bResult = #False
  Protected hCtx, cookie
  Protected actCtx.ACTCTX
  Protected CreateActCtxW, ActivateActCtx
  ZeroMemory_(@actCtx, SizeOf(ACTCTX))
  actCtx\cbSize = SizeOf(ACTCTX)
  Protected sPath.s = __LAVFilters_GetSpecialFolder(#CSIDL_APPDATA) + #LAVFILTERS_PATH
  Protected sManifest.s = sPath.s + "\" + sNameManifest.s
  actCtx\lpSource = @sManifest.s
  actCtx\lpAssemblyDirectory = @sPath.s
  
  CreateActCtxW = __LAVFilters_GetProcAddress_(GetModuleHandle_("Kernel32.dll"),"CreateActCtxW")
  ActivateActCtx = __LAVFilters_GetProcAddress_(GetModuleHandle_("Kernel32.dll"),"ActivateActCtx")  
  If CreateActCtxW And ActivateActCtx
    hCtx = CallFunctionFast(CreateActCtxW,@actCtx) 
    If (hCtx <> #INVALID_HANDLE_VALUE)
      If CallFunctionFast(ActivateActCtx, hCtx, @cookie)
        *cookie\i = cookie
        bResult = #True
      Else
          __LAVFilterError("ActivateActCtx failed")
      EndIf  
    Else
        __LAVFilterError("CreateActCtxW failed")
    EndIf
  Else
    __LAVFilterError("CreateActCtxW and/or ActivateActCtx not available")
  EndIf   
  ProcedureReturn bResult
EndProcedure

Procedure LAVFilters_CreateSplitter(*CLSID,*IID_IBaseFilter)
  Protected *obj.IUnknown = #Null, *obj2.IUnknown = #Null
  
  CoCreateInstance_(*CLSID, #Null, #CLSCTX_INPROC_SERVER, *IID_IBaseFilter, @*obj2) 
  If *obj2 = #Null
    ;Try hackish way...
    If _LAVFilters_lib_splitter
      CallFunction(_LAVFilters_lib_splitter,"DllGetClassObject",*CLSID,?IID_IClassFactory,@*obj.IUnknown)
      If *obj
        ;*obj\QueryInterface(*IID_IBaseFilter,@*obj2)
        CallFunctionFast(PeekL(PeekL(*obj)+12),*obj,0,*IID_IBaseFilter,@*obj2) 
        If *obj2 = #Null
            __LAVFilterError("QueryInterface failed")
        EndIf  
        *obj\Release()  
      Else
          __LAVFilterError("DllGetClassObject failed")
      EndIf
    EndIf
  EndIf
  ProcedureReturn *obj2
EndProcedure

Procedure LAVFilters_Register()
  _LAVFilters_isRegistered = 0
  _LAVFilters_isRegistered = _LAVFilters_isRegistered | __LAVFilters_Register("LAVVideo.sxs.manifest", @_LAVFilters_cookie_video)
  _LAVFilters_isRegistered = _LAVFilters_isRegistered | __LAVFilters_Register("LAVSplitter.sxs.manifest", @_LAVFilters_cookie_splitter)
  _LAVFilters_isRegistered = _LAVFilters_isRegistered | __LAVFilters_Register("LAVAudio.sxs.manifest", @_LAVFilters_cookie_audio)
  
  _LAVFilters_isRegistered = _LAVFilters_isRegistered | __LAVFilters_OpenLibrary("LAVVideo.ax", @_LAVFilters_lib_video) 
  _LAVFilters_isRegistered = _LAVFilters_isRegistered | __LAVFilters_OpenLibrary("LAVAudio.ax", @_LAVFilters_lib_audio) 
  _LAVFilters_isRegistered = _LAVFilters_isRegistered | __LAVFilters_OpenLibrary("LAVSplitter.ax", @_LAVFilters_lib_splitter)   
  ProcedureReturn _LAVFilters_isRegistered
EndProcedure

Procedure LAVFilters_DeRegister()
  Protected DeactivateActCtx = __LAVFilters_GetProcAddress_(GetModuleHandle_("Kernel32.dll"),"DeactivateActCtx")
   If DeactivateActCtx
     If _LAVFilters_cookie_video
       CallFunctionFast(DeactivateActCtx,0,_LAVFilters_cookie_video) 
       _LAVFilters_cookie_video = 0
     EndIf
     If _LAVFilters_cookie_splitter
       CallFunctionFast(DeactivateActCtx,0,_LAVFilters_cookie_splitter)
       _LAVFilters_cookie_splitter = 0
     EndIf
     If _LAVFilters_cookie_audio
       CallFunctionFast(DeactivateActCtx,0,_LAVFilters_cookie_audio)   
       _LAVFilters_cookie_audio = 0
     EndIf    
   EndIf  
  
  If _LAVFilters_lib_video
    CloseLibrary(_LAVFilters_lib_video)
    _LAVFilters_lib_video = #Null
  EndIf
  If _LAVFilters_lib_audio
    CloseLibrary(_LAVFilters_lib_audio)
    _LAVFilters_lib_audio = #Null
  EndIf
  If _LAVFilters_lib_splitter
    CloseLibrary(_LAVFilters_lib_splitter)
    _LAVFilters_lib_splitter = #Null
  EndIf  
EndProcedure


DataSection
  DATA_LAVAudio:
  IncludeBinary "..\data\manifests\LAVAudio.sxs.manifest" 
  DATA_LAVAudio_End:
  
  DATA_LAVSplitter:
  IncludeBinary "..\data\manifests\LAVSplitter.sxs.manifest" 
  DATA_LAVSplitter_End:  
  DATA_LAVVideo:
  IncludeBinary "..\data\manifests\LAVVideo.sxs.manifest" 
  DATA_LAVVideo_End:    
  
  IID_IClassFactory:
  Data.l $1
  Data.l $0
  Data.l $C0
  Data.l $46000000
  
  DATA_img_downloading_codecs:
  IncludeBinary "..\data\codec_download.png"
  
EndDataSection  


; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 145
; FirstLine = 134
; Folding = ---
; EnableXP
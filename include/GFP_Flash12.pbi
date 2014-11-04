;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************
EnableExplicit




Interface IShockwaveFlash Extends IDispatch ; Shockwave Flash
  get_ReadyState(*pVal.long)
  get_TotalFrames(*pVal.long)
  get_Playing(*pVariantBool.VARIANT)
  put_Playing(VariantBool.w)
  get_Quality(*pInt.Integer)
  put_Quality(intVal.i)
  get_ScaleMode(*pInt.Integer)
  put_ScaleMode(intVal.i)
  get_AlignMode(*pInt.Integer)
  put_AlignMode(intVal.i)
  get_BackgroundColor(*pColor.long)
  put_BackgroundColor(Color.l)
  get_Loop(*pVariantBool.VARIANT)
  put_Loop(VariantBool.w)
  get_Movie(*pBSTR.i)
  put_Movie(BSTR.p-bstr)
  get_FrameNum(*pVal.long)
  put_FrameNum(val.l)
  SetZoomRect(left.l,top.l,right.l,bottom.l)
  Zoom(factor.i)
  Pan(x.l,y.l,mode.i)
  Play()
  Stop()
  Back()
  Forward()
  Rewind()
  StopPlay()
  GotoFrame(FrameNum.l)
  CurrentFrame(*FrameNum.long)
  IsPlaying(*pVariantBool.VARIANT)
  PercentLoaded(*percent.long)
  FrameLoaded(FrameNum.l, *pVariantBool.VARIANT)
  FlashVersion(*pVal.long)
  get_WMode(*pBSTR.i)
  put_WMode(pVal.p-bstr)
  get_SAlign(*pBSTR.i)
  put_SAlign(pVal.p-bstr)
  get_Menu(*pVariantBool.VARIANT)
  put_Menu(VariantBool.w)
  get_Base(*pBSTR.i)
  put_Base(pVal.p-bstr)
  get_Scale(*pBSTR.i)
  put_Scale(pVal.p-bstr)
  get_DeviceFont(*pVariantBool.VARIANT)
  put_DeviceFont(VariantBool.w)
  get_EmbedMovie(*pVariantBool.VARIANT)
  put_EmbedMovie(VariantBool.w)
  get_BGColor(*pBSTR.i)
  put_BGColor(pVal.p-bstr)
  get_Quality2(*pBSTR.i)
  put_Quality2(pVal.p-bstr)
  LoadMovie(layer.i,url.p-bstr)
  TGotoFrame(target.p-bstr,FrameNum.l)
  TGotoLabel(target.p-bstr,label.p-bstr)
  TCurrentFrame(target.p-bstr, *pFrameNum.long)
  TCurrentLabel(target.p-bstr, *pBSTR.i)
  TPlay(target.p-bstr)
  TStopPlay(target.p-bstr)
  SetVariable(name.p-bstr,value.p-bstr)
  GetVariable(name.p-bstr, *pBSTR.i)
  
  
  TSetProperty(target.p-bstr,property.i,value.p-bstr)
  TGetProperty(target.p-bstr,property.i, *pBSTR.i)
  TCallFrame(target.p-bstr,FrameNum.l)
  TCallLabel(target.p-bstr,label.p-bstr)
  TSetPropertyNum(target.p-bstr,property.i,value.d)
  TGetPropertyNum(target.p-bstr,property.i, *pDouble.double)
  TGetPropertyAsNumber(target.p-bstr,property.i, *pDouble.double)
  get_SWRemote(*pBSTR.i)
  put_SWRemote(target.p-bstr)
  get_FlashVars(*pBSTR.i)
  put_FlashVars(target.p-bstr)
  get_AllowScriptAccess(*pBSTR.i)
  put_AllowScriptAccess(target.p-bstr)
  get_MovieData(*pBSTR.i)
  put_MovieData(target.p-bstr)
  get_InlineData(*ppIUnknown.i)
  put_InlineData(*pIUnknown.IUnknown)
  get_SeamlessTabbing(*pVariantBool.VARIANT)
  put_SeamlessTabbing(VariantBool.w)
  EnforceLocalSecurity()
  get_Profile(*pVariantBool.VARIANT)
  put_Profile(VariantBool.w)
  get_ProfileAddress(*pBSTR.i)
  put_ProfileAddress(target.p-bstr)
  get_ProfilePort(*pVal.long)
  put_ProfilePort(lValue.l)
  CallFunction(request.p-bstr, *pBSTRResponse.i)
  SetReturnValue(returnValue.p-bstr)
  DisableLocalSecurity()
  get_AllowNetworking(*pBSTR.i)
  put_AllowNetworking(pValue.p-bstr)
  get_AllowFullScreen(*pBSTR.i)
  put_AllowFullScreen(pValue.p-bstr)
EndInterface

; 
;     dispinterface _IShockwaveFlashEvents {
;         properties:
;         methods:
;             [id(0xfffffd9f)]
;             void OnReadyStateChange(long newState);
;             [id(0x000007a6)]
;             void OnProgress(long percentDone);
;             [id(0x00000096)]
;             void FSCommand(
;                             [in] BSTR command, 
;                             [in] BSTR args);
;             [id(0x000000c5)]
;             void FlashCall([in] BSTR request);
;             };
;             

; Procedure Ansi2Uni(A$)
;   *addr=AllocateMemory(10000)
;   PokeS(*addr, A$,-1, #PB_Unicode)
;   ProcedureReturn *addr
; EndProcedure


#FLASH_ReadyState_Loading = 0
#FLASH_ReadyState_Uninitialized = 1
#FLASH_ReadyState_Loaded = 2 
#FLASH_ReadyState_Interactive = 3 
#FLASH_ReadyState_Complete = 4 

#FLASH_Quality_Low = 0
#FLASH_Quality_High = 1
#FLASH_Quality_AutoLow = 2
#FLASH_Quality_AutoHigh = 3

#FLASH_ScaleMode_ShowAll = 0
#FLASH_ScaleMode_NoBorder = 1
#FLASH_ScaleMode_ExactFit = 2 


Prototype.i AtlAxWinInit()
Prototype.i AtlAxWinTerm()
Prototype.i AtlAxCreateControl(lpszName.p-unicode, hWnd, pStream, ppUnkContainer);
Prototype.i AtlAxCreateControlEx(lpszName.p-unicode, hWnd, pStream, ppUnkContainer, ppUnkControl, iidSink, punkSink)
Prototype.i AtlAxGetControl(hwnd, ppUnknown)



Structure FLASHGLOBALS
  AtlModule.i   
  AtlAxWinInit.AtlAxWinInit 
  AtlAxWinTerm.AtlAxWinTerm
  AtlAxCreateControl.AtlAxCreateControl
  AtlAxGetControl.AtlAxGetControl
  CoInit.i
EndStructure

Structure FLASHOBJ
  oCtrlFlash.IUnknown
  oFlash.IShockwaveFlash
  oContainer.IUnknown
  hFlashModule.i
EndStructure

Global g_Flash.FLASHGLOBALS

Procedure __FlashError(text.s)
;  Debug text
  WriteLog(text, #LOGLEVEL_ERROR)
EndProcedure

Procedure __FlashDebug(text.s)
 ; Debug text
  WriteLog(text, #LOGLEVEL_DEBUG)
EndProcedure

Procedure Flash_GetMajorVersion(*obj.FLASHOBJ)
  Protected version
  If *obj
    If *obj\oFlash
      *obj\oFlash\FlashVersion(@version)
    Else
      __FlashError("no ShockwaveFlash object available")
    EndIf
  Else
    __FlashError("invalid parameter: nullpointer")
  EndIf
  ProcedureReturn (version>>16)&$FFFF
EndProcedure

Procedure Flash_GetMinorVersion(*obj.FLASHOBJ)
  Protected version
  If *obj
    If *obj\oFlash
      *obj\oFlash\FlashVersion(@version)
    Else
       __FlashError("no ShockwaveFlash object available" )    
    EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")
  EndIf
  ProcedureReturn (version)&$FFFF
EndProcedure


Procedure Flash_SetFlashVars(*obj.FLASHOBJ, sVariables.s)
  If *obj
    If *obj\oFlash
      If Flash_GetMajorVersion(*obj) >= 6
        *obj\oFlash\put_FlashVars(sVariables)
      Else
        __FlashError("version " + Str(Flash_GetMajorVersion(*obj)) + "." + Str(Flash_GetMinorVersion(*obj)) + "does not support FlashVars")          
      EndIf
    Else
       __FlashError("no ShockwaveFlash object available")
    EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")
  EndIf  
EndProcedure


Procedure Flash_SetBackgroundColor(*obj.FLASHOBJ, color.i)
  Protected bResult = #False
  If *obj
    If *obj\oFlash
      *obj\oFlash\put_BackgroundColor(color)
      bResult = #True
    Else
       __FlashError("no ShockwaveFlash object available")
    EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")
  EndIf  
  ProcedureReturn bResult
EndProcedure

Procedure Flash_GetBackgroundColor(*obj.FLASHOBJ)
  Protected iResult = -1
  If *obj
    If *obj\oFlash
      *obj\oFlash\Get_BackgroundColor(@iResult)
    Else
       __FlashError("no ShockwaveFlash object available")
    EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")
  EndIf  
  ProcedureReturn iResult
EndProcedure

Procedure Flash_Play(*obj.FLASHOBJ)
  Protected bResult = #False
  If *obj
    If *obj\oFlash
      *obj\oFlash\Play()
      bResult = #True
    Else
       __FlashError("no ShockwaveFlash object available")
    EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")
  EndIf  
  ProcedureReturn bResult
EndProcedure

Procedure Flash_Stop(*obj.FLASHOBJ)
  Protected bResult = #False
  If *obj
    If *obj\oFlash
      *obj\oFlash\Stop()
      bResult = #True
    Else
       __FlashError("no ShockwaveFlash object available")
    EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")
  EndIf  
  ProcedureReturn bResult
EndProcedure

Procedure Flash_IsPlaying(*obj.FLASHOBJ)
  Protected bResult = #False
  If *obj
    If *obj\oFlash
      *obj\oFlash\IsPlaying(@bResult)
    Else
       __FlashError("no ShockwaveFlash object available")
    EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")
  EndIf  
  ProcedureReturn bResult
EndProcedure


; Procedure.l Flash_LoadMovieMem(SwfStart.l,SwfEnd.l,*FlashObject.IShockwaveFlash)
;   Protected FlashBuffer, FlashStream.IStream, FlashPSI.IPersistStreamInit, ReturnValue
;   ;FlashBuffer=AllocateMemory(SwfEnd-SwfStart+8) ; let's make room
;   
;   FlashBuffer=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT, SwfEnd-SwfStart+8)
;   If FlashBuffer
;     PokeL(FlashBuffer,$55665566) ;now write the header
;     PokeL(FlashBuffer+4,SwfEnd-SwfStart) ; and the file size
;     CopyMemory(SwfStart,FlashBuffer+8,SwfEnd-SwfStart) ; then copy the whole file.
;     If CreateStreamOnHGlobal_(FlashBuffer,#True,@FlashStream.IStream)=0 ;Create a stream.
;       *FlashObject\QueryInterface(?IID_IPersistStreamInit,@FlashPSI.IPersistStreamInit) ; Ask for IPersistStreamInit interface     
;       If FlashPSI
;         If FlashPSI\load(FlashStream)=0 ;load the stream we created
;           ReturnValue=1
;         EndIf
;         FlashPSI\Release(); self explained
;       EndIf 
;       FlashStream\Release() ; idem
;     EndIf
;     ;FreeMemory(FlashBuffer) ;idem
;     GlobalFree_(FlashBuffer) ;idem
;   EndIf
;   ProcedureReturn ReturnValue
; EndProcedure

Procedure.l __Flash_LoadMovieMem(*Flash.IShockwaveFlash, *ptrStart, *ptrEnd)
  Protected *Mem, *Buffer, SWFStream.IStream, *FlashPerStrmInit.IPersistStreamInit, bResult = #False
  
  If (*Flash) And (*ptrEnd) And (*ptrStart) And ((*ptrEnd - *ptrStart) > 0)
    *Mem = GlobalAlloc_(#GMEM_MOVEABLE|#GMEM_ZEROINIT, *ptrEnd - *ptrStart + 8)
    If *Mem
      *Buffer = GlobalLock_(*Mem)
      If *Buffer
        PokeL(*Buffer, $55665566) ;header
        PokeL(*Buffer + 4, *ptrEnd - *ptrStart) ; size
        CopyMemory(*ptrStart,*Buffer + 8, *ptrEnd - *ptrStart)
      EndIf
      GlobalUnlock_(*Mem)
      If CreateStreamOnHGlobal_(*Buffer, #True, @SWFStream.IStream) = #S_OK
        *Flash\QueryInterface(?IID_IPersistStreamInit, @*FlashPerStrmInit.IPersistStreamInit) ; query for IPersistStreamInit    
        If *FlashPerStrmInit
          If *FlashPerStrmInit\load(SWFStream) = #S_OK ;load stream
            bResult = #True
          EndIf
          *FlashPerStrmInit\Release() ;decrease ref. count
        EndIf 
        SWFStream\Release()
        ;GlobalFree_(*Mem) ;will be freeed automatically
      Else
        GlobalFree_(*Mem) ;free it if CreateStreamOnHGlobal fails
      EndIf
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure Flash_LoadMovieMem(*obj.FLASHOBJ, *ptrStart, *ptrEnd)
  Protected bResult = #False
  If *obj
    If *obj\oFlash
      If Flash_GetMajorVersion(*obj) >= 8
        *obj\oFlash\DisableLocalSecurity()
      EndIf  
      
      If __Flash_LoadMovieMem(*obj\oFlash, *ptrStart, *ptrEnd)
        bResult = #True
      Else
        __FlashError("Movie cannot be loaded from mem!")
      EndIf
    Else
       __FlashError("no ShockwaveFlash object available")
     EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")     
  EndIf  
  ProcedureReturn bResult  
EndProcedure  


;does not return whether the movie was really loaded. Just returns false if an other error happens 
Procedure Flash_LoadMovie(*obj.FLASHOBJ, sMovie.s)
  Protected bResult = #False
  If *obj
    ;Debug 10
    If *obj\oFlash
      ;Debug 11
      ;Debug sMovie
      ;Debug FileSize(sMovie)
      If FileSize(sMovie) > 0
        ;Debug 12
        If Flash_GetMajorVersion(*obj) >= 8
          *obj\oFlash\DisableLocalSecurity()
        EndIf  
        *obj\oFlash\LoadMovie(0, sMovie) ; Does not have a return value
        bResult = #True
      Else
        __FlashError("Movie file "+ Chr(34) + sMovie + Chr(34) + "cannot be found!")
      EndIf
    Else
       __FlashError("no ShockwaveFlash object available")
     EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")     
  EndIf  
  ProcedureReturn bResult
EndProcedure

Procedure Flash_GetReadyState(*obj.FLASHOBJ)
  Protected iState = #FLASH_ReadyState_Uninitialized
  If *obj
    If *obj\oFlash
      *obj\oFlash\Get_ReadyState(@iState) ; seems to return always 4...
    Else
       __FlashError("no ShockwaveFlash object available")
     EndIf  
  Else
    __FlashError("invalid parameter: nullpointer")     
  EndIf  
  ProcedureReturn iState
EndProcedure


Procedure Flash_Create(hWnd, sFlashFile.s = "")
  Protected *result.FLASHOBJ = #Null, oContainer.IUnknown, oCtrlFlash.IUnknown, oFlash.IShockwaveFlash
  Protected *obj.FLASHOBJ
  
  If sFlashFile = ""
    sFlashFile = "ShockwaveFlash.ShockwaveFlash"
  EndIf
  
  *obj.FLASHOBJ = AllocateMemory(SizeOf(FLASHOBJ))
  If *obj
    ;Debug g_Flash\AtlAxCreateControl
    g_Flash\AtlAxCreateControl(sFlashFile, hWnd, 0, @oContainer.IUnknown) ; It always create the IE control even if flash isn't found
    If oContainer
      g_Flash\AtlAxGetControl(hWnd, @oCtrlFlash)
      If oCtrlFlash
        ;oCtrlFlash = GetWindowLong_(hWnd, #GWL_USERDATA)
        
        If oCtrlFlash\QueryInterface(?IID_ShockwaveFlash, @oFlash) = #S_OK ; Be sure it's a flash object in the IE container

          *obj\oCtrlFlash = oCtrlFlash
          *obj\oFlash = oFlash
          *obj\oContainer = oContainer
          *result = *obj
          
        EndIf
      EndIf
    EndIf  
  EndIf
  If *result = #Null
    If oCtrlFlash
      oCtrlFlash\Release()
    EndIf    
    If oFlash
      oFlash\Release()
    EndIf
    If oContainer
      oContainer\Release()
    EndIf
    If *obj
      FreeMemory(*obj)
    EndIf
  EndIf
  ProcedureReturn *result
EndProcedure

; 
; Procedure CreateDirectX7()
;   Global dx7vb,*ClassObj.IClassFactor,*DX.DirectX7
;  
;  DllGetClassObject=GetProcAddress_(dx7vb,"DllGetClassObject")
;  If DllGetClassObject=0
;    FreeLibrary_(dx7vb)
;    ProcedureReturn 0
;  EndIf
; 
;  If CallFunctionFast(DllGetClassObject,?GUID1,?GUID2,@*ClassObj.IClassFactor)
;    FreeLibrary_(dx7vb)
;    ProcedureReturn 0
;  EndIf
;  *ClassObj\
;  CallFunctionFast(PeekL(PeekL(*ClassObj)+12),*ClassObj,0,?GUID3,@*DX)
;  ProcedureReturn *DX
; EndProcedure


Procedure Flash_CreateFromDLL(sFlashDLL.s, hWnd)
  Protected *result.FLASHOBJ = #Null, oContainer.IUnknown, oCtrlFlash.IUnknown, oFlash.IShockwaveFlash
  Protected hMod, *obj.FLASHOBJ
  
  hMod = LoadLibrary_(sFlashDLL)
  
  
  ;CoCreateInstance_(?IID_ShockwaveFlash, 0, $17, ?IID_IShockwaveFlash, @oFlash.IShockwaveFlash)

    ;AtlAxAttachControl(oFlash, WindowID(0), 0)  
  
  *obj.FLASHOBJ = AllocateMemory(SizeOf(FLASHOBJ))
  If *obj
    g_Flash\AtlAxCreateControl("ShockwaveFlash.ShockwaveFlash", hWnd, 0, @oContainer.IUnknown) ; It always create the IE control even if flash isn't found
    If oContainer
      g_Flash\AtlAxGetControl(hWnd, @oCtrlFlash)
      If oCtrlFlash
        If oCtrlFlash\QueryInterface(?IID_ShockwaveFlash, @oFlash) = #S_OK ; Be sure it's a flash object in the IE container
          *obj\oCtrlFlash = oCtrlFlash
          *obj\oFlash = oFlash
          *obj\oContainer = oContainer
          *result = *obj
        EndIf
      EndIf
    EndIf  
  EndIf
  If *result = #Null
    If oCtrlFlash
      oCtrlFlash\Release()
    EndIf    
    If oFlash
      oFlash\Release()
    EndIf
    If oContainer
      oContainer\Release()
    EndIf
    If *obj
      FreeMemory(*obj)
    EndIf
  EndIf
  ProcedureReturn *result
EndProcedure




Procedure Flash_Destroy(*obj.FLASHOBJ)
  Protected bResult = #False
  If *obj
    
    If *obj\oContainer
      *obj\oContainer\Release()
      *obj\oContainer = #Null
      bResult = #True
    EndIf
    
    If *obj\oCtrlFlash
      *obj\oCtrlFlash\Release()
      *obj\oCtrlFlash = #Null
      bResult = #True
    EndIf    
    
    If *obj\oFlash
      *obj\oFlash\Release()
      *obj\oFlash = #Null
      bResult = #True     
    EndIf  
    
    If *obj
      FreeMemory(*obj)
    EndIf
    
  Else
    __FlashError("invalid parameter: nullpointer")     
  EndIf  
  ProcedureReturn bResult
EndProcedure

  
Procedure Flash_Init()
  Protected iResult, bResult = #False
  iResult = CoInitialize_(0)
  ;If iResult = #S_OK Or iResult = #S_FALSE
    g_Flash\CoInit = #True
    g_Flash\AtlModule = LoadLibrary_("atl.dll")
    If g_Flash\AtlModule
      g_Flash\AtlAxWinInit = GetProcAddress_(g_Flash\AtlModule, "AtlAxWinInit")
      g_Flash\AtlAxWinTerm = GetProcAddress_(g_Flash\AtlModule, "AtlAxWinTerm")   
      g_Flash\AtlAxCreateControl = GetProcAddress_(g_Flash\AtlModule, "AtlAxCreateControl")
      g_Flash\AtlAxGetControl = GetProcAddress_(g_Flash\AtlModule, "AtlAxGetControl")
      bResult = g_Flash\AtlAxWinInit()  
    EndIf
  ;EndIf
  ProcedureReturn bResult
EndProcedure

Procedure Flash_Uninit()
  If g_Flash\AtlModule
    If g_Flash\AtlAxWinTerm
      g_Flash\AtlAxWinTerm()
    EndIf
    FreeLibrary_(g_Flash\AtlModule)
    g_Flash\AtlModule = #Null     
    g_Flash\AtlAxWinInit = #Null  
    g_Flash\AtlAxWinTerm = #Null  
    g_Flash\AtlAxCreateControl = #Null 
    g_Flash\AtlAxGetControl = #Null    
  EndIf
  If g_Flash\CoInit
    CoUninitialize_()
    g_Flash\CoInit = #False  
  EndIf
EndProcedure


; 
; Interface _IShockwaveFlashEvents ; Event interface for Shockwave Flash
;   QueryInterface(riid.l,ppvObj.l)
;   AddRef()
;   Release()
;   OnReadyStateChange(newState.l)
;   OnProgress(percentDone.l)
;   FSCommand(command.p-bstr,args.p-bstr)
;   FlashCall(request.p-bstr)
; EndInterface
; 
; Structure __IShockwaveFlashEvents
;   VTable.i
;   pQueryInterface.i
;   pAddRef.i
;   pRelease.i
;   pOnReadyStateChange.i
;   pOnProgress.i
;   pFSCommand.i
;   pFlashCall.i
;   VAL.i[7000]
; EndStructure
; 
; Global MYSINK.__IShockwaveFlashEvents
; 
; Procedure FlashEvent_QueryInterface(*obj,a,b)
;     Protected pMem
;   StringFromIID_(a,@pMem)
;   If pMem
;     Debug PeekS(pMem,-1,#PB_Unicode)
;     CoTaskMemFree_(pMem)
;   EndIf
;   
;   Debug "FlashEvent_QueryInterface"  
;   PokeL(b,*obj)
; EndProcedure
; 
; Procedure FlashEvent_AddRef(*obj)
; Debug "FlashEvent_AddRef"  
; EndProcedure
;   
; Procedure FlashEvent_Release(*obj)
; Debug "FlashEvent_Release"  
; EndProcedure
; 
; Procedure FlashEvent_OnReadyStateChange(*obj, newState.l)
; Debug "FlashEvent_OnReadyStateChange"  
; EndProcedure
; 
; Procedure FlashEvent_OnProgress(*obj, percentDone.l)
; Debug "FlashEvent_pOnProgress"  
; EndProcedure
; 
; Procedure FlashEvent_FSCommand(*obj, command, args)
; Debug "FlashEvent_FSCommand"  
; EndProcedure
; 
; Procedure FlashEvent_FlashCall(*obj, request, b, c, d,e, f, g, h)
;   
;   Debug Hex(request)
;   ;Debug PeekS(request,#PB_Unicode)
;   Debug "FlashEvent_FlashCall"  
;   ;ProcedureReturn #E_FAIL
; EndProcedure
; 
; 
; MYSINK\VTable = @MYSINK\pQueryInterface
; MYSINK\pQueryInterface = @FlashEvent_QueryInterface()
; MYSINK\pAddRef = @FlashEvent_AddRef()
; MYSINK\pRelease = @FlashEvent_Release()
; MYSINK\pOnReadyStateChange = @FlashEvent_OnReadyStateChange()
; MYSINK\pOnProgress = @FlashEvent_OnProgress()
; MYSINK\pFSCommand = @FlashEvent_FSCommand()
; MYSINK\pFlashCall = @FlashEvent_FlashCall()
; 
; 
; *OBJ\oFlash\QueryInterface(?IID_IConnectionPointContainer, @container.IConnectionPointContainer)
; container\FindConnectionPoint(?IID__IShockwaveFlashEvents, @connection.IConnectionPoint)
; 
; connection\Advise(@MYSINK,@COOKIE)
; Debug COOKIE
; 
; Debug container
; Debug connection




; 
; 
; ;{ Sample
;  DisableExplicit
; ; 
;  Movie$ = "C:\Users\Admin\Desktop\stuff2\flash\control.swf"
; ;   
; ; 
;  OpenWindow(0, 100, 100, 700, 315, "ATL test", #PB_Window_SystemMenu)
;  ContainerGadget(0,0,0,700,315)
; ; 
; Flash_Init()
; 
; 
; *OBJ.FLASHOBJ=Flash_Create(GadgetID(0),Movie$)
; Debug *OBJ
; ; 
; ; Flash_SetFlashVars(*OBJ, "videoFile=C:\Users\Admin\Desktop\stuff2\flash\abc.flv&eventFSCommand=true")
; ; 
; ; 
; ; ;SetCurrentDirectory("C:\Users\Admin\Desktop\stuff2\flash")
; ; 
; ; 
; ; Flash_LoadMovie(*OBJ,Movie$)
; ; 
; ; Debug Flash_GetReadyState(*OBJ)
; ; 
; ; 
;  Flash_Play(*OBJ)
; ; 
; ; 
; ; 
; ; ;Debug *OBJ\oFlash\AddRef()
; ; 
; ; 
;  Repeat
; ; 
;  Until WaitWindowEvent()=#WM_CLOSE
;  Flash_Destroy(*OBJ)
; ; 
; ;}
; 
; 
; 




DataSection
  IID_ShockwaveFlash:
    Data.l $D27CDB6C
    Data.w $AE6D, $11CF
    Data.b $96, $B8, $44, $45, $53, $54, $00, $00
    
IID_IPersistStreamInit:
    Data.q $101B4E077FD52380,$13C72E2B00082DAE

EndDataSection


DataSection
; GUID1:
; Data.l $E1211353
; Data.l $11D18E94
; Data.l $C0000888
; Data.l $2C6C24F
; GUID2:
; Data.l $1
; Data.l $0
; Data.l $C0
; Data.l $46000000
; GUID3:
; Data.l $0
; Data.l $0
; Data.l $C0
; Data.l $46000000

IID_IConnectionPointContainer: ; {B196B284-BAB4-101A-B69C-00AA00341D07}
  Data.l $B196B284
  Data.w $BAB4, $101A
  Data.b $B6, $9C, $00, $AA, $00, $34, $1D, $07
                             ; {D27CDB6D-AE6D-11CF-96B8-444553540000}
IID__IShockwaveFlashEvents:  ; {D27CDB6D-AE6D-11CF-96B8-444553540000}
  Data.l $D27CDB6D
  Data.w $AE6D,$11CF
  Data.b $96,$B8,$44,$45,$53,$54,$0,$0    
EndDataSection
  
  
; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 408
; FirstLine = 391
; Folding = ----
; EnableXP
; DisableDebugger
; EnableCompileCount = 11
; EnableBuildCount = 0
; EnableExeConstant
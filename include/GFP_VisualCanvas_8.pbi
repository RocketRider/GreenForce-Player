;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************



Structure D3DXMATRIX 
  _11.f 
  _12.f 
  _13.f 
  _14.f 
  _21.f 
  _22.f 
  _23.f 
  _24.f 
  _31.f 
  _32.f 
  _33.f 
  _34.f 
  _41.f 
  _42.f 
  _43.f 
  _44.f 
EndStructure 

Interface IVisualisationCanvas Extends IUnknown
  GetWidth()
  GetHeight()
  UpdateSample()
  GetSampleSize()
  GetSampleChannels()
  GetSampleBitsPerSample()
  GetSampleBitsSamplesPerSec()
  ReadSample.d(iPosition)
  GetMediaLength()
  GetMediaPosition()
  GetD3DDevice9()
  BeginScene()
  EndScene()
  GetHWND()
  CanRender()
  GetUserData()
  SetUserData(value.i)
  Clear(RGB.i)
EndInterface



Prototype.i D3DXMatrixPerspectiveLH(*Proj.D3DXMATRIX,a.f,b.f,c.f,d.f)
Prototype.i Direct3DCreate9(iVersion.i)

Prototype.i CBInit(*obj.IVisualisationCanvas)
Prototype.i CBRun(*obj.IVisualisationCanvas)
Prototype.i CBTerminate(*obj.IVisualisationCanvas)
Prototype.i CBBeforeResetDevice(*obj.IVisualisationCanvas)
Prototype.i CBAfterResetDevice(*obj.IVisualisationCanvas)

Structure SVisualisationCanvas
  VTable.i
  m_RefCount.i
  m_Width.i
  m_Height.i
  m_hwnd.i
  m_UserData.i
  
  *m_dshow.DSHOW_MEDIABASE
  D3D9DLL.i
  ;D3DX9DLL.i
  D3D.IDirect3D9
  D3DDevice.IDirect3DDevice9
  StateBlock.IDirect3DStateBlock9
  ;__D3DXMatrixPerspectiveLH.D3DXMatrixPerspectiveLH
  __Direct3DCreate9.Direct3DCreate9
  D3DWnd.D3DPresent_Parameters
  
  bDeviceUseable.i
  iLastPresentTickCount.i ; 2011-04-16
  
  hRendererModule.i
  ; Callback functions
  *cbInit.CBInit
  *cbRun.CBRun
  *cbTerminate.CBTerminate
  *cbBeforeReset.CBBeforeResetDevice
  *cbAfterReset.CBAfterResetDevice
  
  pQueryInterface.i
  pAddRef.i
  pRelease.i
  pGetWidth.i
  pGetHeight.i
  pUpdateSample.i
  pGetSampleSize.i
  pGetSampleChannels.i
  pGetSampleBitsPerSample.i
  pGetSampleBitsSamplesPerSec.i
  pReadSample.i
  pGetMediaLength.i
  pGetMediaPosition.i
  pGetD3DDevice9.i
  pBeginScene.i
  pEndScene.i
  pGetHWND.i
  pCanRender.i
  pGetUserData.i
  pSetUserData.i
  pClear.i
EndStructure




Procedure __SetD3DDeviceStates(*p.SVisualisationCanvas)
  Protected ProjMatrix.D3DXMATRIX, identity.D3DXMATRIX , stage.i
  
  ProjMatrix\_11 = Cos((#PI/4)/2)/Sin((#PI/4)/2) 
  ProjMatrix\_22 = Cos((#PI/4)/2)/Sin((#PI/4)/2) 
  ProjMatrix\_33 = 1/(1-0.001) 
  ProjMatrix\_34 =1 
  ProjMatrix\_43 = -(1/(1-0.001)) 
  
  identity\_11 = 1.0
  identity\_22 = 1.0
  identity\_33 = 1.0
  identity\_44 = 1.0
  
  *p\D3DDevice\SetTransform(#D3DTS_VIEW,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_WORLD,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_TEXTURE0,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_TEXTURE1,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_TEXTURE2,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_TEXTURE3,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_TEXTURE4,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_TEXTURE5,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_TEXTURE6,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_TEXTURE7,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_WORLD1,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_WORLD2,identity) 
  *p\D3DDevice\SetTransform(#D3DTS_WORLD3,identity) 
  
  *p\D3DDevice\SetTransform(#D3DTS_PROJECTION,@ProjMatrix) 
  *p\D3DDevice\SetPixelShader(#Null)
  *p\D3DDevice\SetVertexShader(#Null)
  *p\D3DDevice\SetFVF(#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW)
  For stage = 0 To 16
    *p\D3DDevice\SetTexture(stage, #Null)
  Next
  
  *p\D3DDevice\SetRenderState(#D3DRS_LIGHTING, #False) ; disable lighting
  
  *p\D3DDevice\SetRenderState(#D3DRS_ZENABLE, #False)
  *p\D3DDevice\SetRenderState(#D3DRS_FILLMODE, #D3DFILL_SOLID)
  *p\D3DDevice\SetRenderState(#D3DRS_SHADEMODE , #D3DSHADE_GOURAUD)
  
  *p\D3DDevice\SetRenderState(#D3DRS_LASTPIXEL, #True)
  *p\D3DDevice\SetRenderState(#D3DRS_SRCBLEND, #D3DBLEND_SRCALPHA)
  *p\D3DDevice\SetRenderState(#D3DRS_DESTBLEND, #D3DBLEND_INVSRCALPHA)
  
  *p\D3DDevice\SetRenderState(#D3DRS_CULLMODE, #D3DCULL_CCW)
  *p\D3DDevice\SetRenderState(#D3DRS_ALPHABLENDENABLE, #True)
  
  *p\D3DDevice\SetSamplerState(0,#D3DSAMP_MAGFILTER,#D3DTEXF_LINEAR)
  *p\D3DDevice\SetSamplerState(0,#D3DSAMP_MINFILTER,#D3DTEXF_LINEAR)
  
  *p\D3DDevice\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_MODULATE)
  *p\D3DDevice\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_MODULATE)
    
  *p\D3DDevice\SetRenderState(#D3DRS_CLIPPING,#True)
  
  *p\D3DDevice\SetRenderState(#D3DRS_DITHERENABLE,#True)
  *p\D3DDevice\SetRenderState(#D3DRS_SPECULARENABLE ,#False)
  *p\D3DDevice\SetRenderState(#D3DRS_FOGENABLE ,#False)
EndProcedure
    
Procedure __ResetD3DDeviceStates(*p.SVisualisationCanvas)
  __SetD3DDeviceStates(*p)
  ;If *p\StateBlock
  ;  *p\StateBlock\Apply()
  ;EndIf
EndProcedure
        

Macro __Canvas_Debug(sText)
  ;Debug "DEBUG:" + sText
  WriteLog(sText, #LOGLEVEL_DEBUG)
EndMacro

Macro __Canvas_Error(sText)
  ;Debug "ERROR:" + sText
  WriteLog(sText, #LOGLEVEL_ERROR)
EndMacro

Procedure __Canvas_AddRef(*p.SVisualisationCanvas)
  *p\m_RefCount + 1
  ProcedureReturn *p\m_RefCount 
EndProcedure

Procedure __Canvas_QueryInterface(*p.SVisualisationCanvas, a.i, b.i)
  ProcedureReturn #E_NOINTERFACE
EndProcedure

Procedure __Canvas_Release(*p.SVisualisationCanvas)
  *p\m_RefCount - 1
  ProcedureReturn *p\m_RefCount 
EndProcedure

Procedure __Canvas_GetWidth(*p.SVisualisationCanvas)
  ProcedureReturn *p\m_Width
EndProcedure

Procedure __Canvas_GetHeight(*p.SVisualisationCanvas)
  ProcedureReturn *p\m_Height
EndProcedure

Procedure __Canvas_UpdateSamples(*p.SVisualisationCanvas)
  If *p\m_dshow
    ProcedureReturn DShow_UpdateSampleGrabber(*p\m_dshow)
  Else
    ProcedureReturn #Null
  EndIf
EndProcedure

Procedure.d __Canvas_ReadSample(*p.SVisualisationCanvas, iPos.i)
  If *p\m_dshow
    ProcedureReturn DShow_ReadSample(*p\m_dshow, iPos.i)
  Else
    ProcedureReturn 0.0
  EndIf
EndProcedure

Procedure __Canvas_GetSampleSize(*p.SVisualisationCanvas)
  If *p\m_dshow
    ProcedureReturn DShow_GetSampleCount(*p\m_dshow)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure __Canvas_GetSampleChannels(*p.SVisualisationCanvas)
  If *p\m_dshow
    ProcedureReturn DShow_GetSampleGrabberChannels(*p\m_dshow)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure __Canvas_GetSampleBitsPerSample(*p.SVisualisationCanvas)
  If *p\m_dshow
    ProcedureReturn DShow_GetSampleGrabberBitsPerSample(*p\m_dshow)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure __Canvas_GetSampleBitsSamplesPerSec(*p.SVisualisationCanvas)
  If *p\m_dshow
    ProcedureReturn DShow_GetSampleGrabberBitsSamplesPerSec(*p\m_dshow)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure __Canvas_BeginScene(*p.SVisualisationCanvas)
  If *p\D3DDevice\BeginScene() = #D3D_OK
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure __Canvas_EndScene(*p.SVisualisationCanvas)
  If *p\D3DDevice\EndScene() = #D3D_OK
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure __Canvas_GetHWND(*p.SVisualisationCanvas)
  ProcedureReturn *p\m_hwnd
EndProcedure

Procedure __Canvas_CanRender(*p.SVisualisationCanvas)
  ProcedureReturn *p\bDeviceUseable
EndProcedure

Procedure __Canvas_GetUserData(*p.SVisualisationCanvas)
  ProcedureReturn *p\m_UserData
EndProcedure

Procedure __Canvas_SetUserData(*p.SVisualisationCanvas, iValue.i)
  *p\m_UserData = iValue
EndProcedure

Procedure __Canvas_GetD3DDevice(*p.SVisualisationCanvas)
  ProcedureReturn *p\D3DDevice
EndProcedure

Procedure __Canvas_Clear(*p.SVisualisationCanvas, RGB.i)
  If *p
    If *p\D3DDevice
      If *p\D3DDevice\Clear(0,0,#D3DCLEAR_TARGET|#D3DCLEAR_ZBUFFER,RGB,1.0,0) = #D3D_OK
        ProcedureReturn #True
      EndIf
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure


Procedure Canvas_Create(*p.SVisualisationCanvas, hWnd.i, iWidth.i, iHeight.i)
  Protected index.i, Proj.D3DXMATRIX, bResult = #False, pres.D3DPresent_Parameters;, Direct3DCreate9Str
  *p\m_Width = iWidth
  *p\m_Height = iHeight
  *p\D3D9DLL = LoadLibrary_("d3d9.dll") 
  
  ;For index=24 To 31
  ;  If *p\D3DX9DLL = #Null:*p\D3DX9DLL = LoadLibrary_("d3dx9_"+Str(index)+".dll"):EndIf
  ;Next
  ;If *p\D3DX9DLL=0:*p\D3DX9DLL=LoadLibrary_("d3dx9d.dll"):EndIf
  
  If *p\D3D9DLL <> #Null; And *p\D3DX9DLL <> #Null 

    
    ;Direct3DCreate9Str = __AnsiString("Direct3DCreate9") ; Wuird für Unicode benötigt (da Funktioniert GetProcAddress nicht)
    
    *p\__Direct3DCreate9 = #Null
    ;If Direct3DCreate9Str
    *p\__Direct3DCreate9 = GetProcAddress_(*p\D3D9DLL, "Direct3DCreate9")
      ;FreeMemory(Direct3DCreate9Str)  
    ;EndIf
    
    ;*p\__D3DXMatrixPerspectiveLH = GetProcAddress_(*p\D3DX9DLL, "D3DXMatrixPerspectiveLH")
    
    *p\D3D = #Null
    If *p\__Direct3DCreate9
      *p\D3D = *p\__Direct3DCreate9(#D3D_SDK_VERSION) 
    EndIf
    
    If *p\D3D
      
      *p\m_hwnd = hWnd
      *p\D3DWnd\Windowed = #True
      *p\D3DWnd\SwapEffect = #D3DSWAPEFFECT_DISCARD
      *p\D3DWnd\BackBufferWidth = iWidth 
      *p\D3DWnd\BackBufferHeight = iHeight
      *p\D3DWnd\EnableAutoDepthStencil = #True ; use a z-buffer, or it will look ugly
      *p\D3DWnd\AutoDepthStencilFormat = #D3DFMT_D16
      *p\D3DWnd\flags = #D3DPRESENTFLAG_LOCKABLE_BACKBUFFER
      *p\D3DWnd\BackBufferFormat = #D3DFMT_X8R8G8B8     
      CopyMemory(*p\D3dWnd, pres, SizeOf(D3DPresent_Parameters))
           
      *p\D3D\CreateDevice(#D3DADAPTER_DEFAULT, #D3DDEVTYPE_HAL, hWnd, #D3DCREATE_SOFTWARE_VERTEXPROCESSING | #D3DCREATE_MULTITHREADED, pres, @*p\D3DDevice) 
      If *p\D3DDevice = #Null
         *p\D3DWnd\BackBufferFormat = #D3DFMT_R5G6B5    
         CopyMemory(*p\D3dWnd, pres, SizeOf(D3DPresent_Parameters))
         *p\D3D\CreateDevice(#D3DADAPTER_DEFAULT, #D3DDEVTYPE_HAL, hWnd, #D3DCREATE_SOFTWARE_VERTEXPROCESSING | #D3DCREATE_MULTITHREADED, pres, @*p\D3DDevice)    
      EndIf
      If *p\D3DDevice = #Null
         *p\D3DWnd\BackBufferFormat = #D3DFMT_X1R5G5B5    
         CopyMemory(*p\D3dWnd, pres, SizeOf(D3DPresent_Parameters))
         *p\D3D\CreateDevice(#D3DADAPTER_DEFAULT, #D3DDEVTYPE_HAL, hWnd, #D3DCREATE_SOFTWARE_VERTEXPROCESSING | #D3DCREATE_MULTITHREADED, pres, @*p\D3DDevice)    
      EndIf      
      If *p\D3DDevice = #Null
         *p\D3DWnd\BackBufferFormat = #D3DFMT_R8G8B8   
         CopyMemory(*p\D3dWnd, pres, SizeOf(D3DPresent_Parameters))
         *p\D3D\CreateDevice(#D3DADAPTER_DEFAULT, #D3DDEVTYPE_HAL, hWnd, #D3DCREATE_SOFTWARE_VERTEXPROCESSING | #D3DCREATE_MULTITHREADED, pres, @*p\D3DDevice)    
      EndIf 
            
      
      If *p\D3DDevice <> #Null 
        ;*p\__D3DXMatrixPerspectiveLH(Proj.D3DXMATRIX,1.0,3/4.0,1.0,100.0)
        ; set projection matrix
        ;*p\D3DDevice\SetTransform(#D3DTS_PROJECTION,Proj)
        ;*p\D3DDevice\SetRenderState(#D3DRS_LIGHTING, #False) ; disable lighting
        __SetD3DDeviceStates(*p)        
        ;*p\D3DDevice\CreateStateBlock(#D3DSBT_ALL, @*p\StateBlock)   
        ;If *p\StateBlock
        ;  *p\StateBlock\Capture()
        ;EndIf
        
        *p\D3DDevice\Clear(0,0,#D3DCLEAR_TARGET|#D3DCLEAR_ZBUFFER,0,1.0,0) 
        *p\bDeviceUseable = #True
        bResult = #True
      Else
        *p\D3D\Release()
        FreeLibrary_(*p\D3D9DLL)
      EndIf      
    Else
      FreeLibrary_(*p\D3D9DLL)
    EndIf 
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure Canvas_SetDSHOWObj(*p.SVisualisationCanvas, *obj.DSHOW_MEDIABASE)
  *p\m_dshow = *obj
EndProcedure

Procedure Canvas_Resize(*p.SVisualisationCanvas, iWidth.i, iHeight.i)
  Protected pres.D3DPresent_Parameters
  If *p\D3DDevice
    If iWidth <> *p\m_Width Or iHeight <> *p\m_Height
    
      *p\m_Width = iWidth
      *p\m_Height = iHeight
      
      If *p\cbBeforeReset
        *p\cbBeforeReset(*p)
      EndIf
      
      *p\D3DWnd\BackBufferWidth = iWidth
      *p\D3DWnd\BackBufferHeight = iHeight
      CopyMemory(*p\D3dWnd, pres, SizeOf(D3DPresent_Parameters))
      
      
      If *p\D3DDevice\Reset(pres) = #D3D_OK
        *p\bDeviceUseable = #True
      Else
        *p\bDeviceUseable = #False
        ProcedureReturn #E_FAIL
      EndIf
      
      __ResetD3DDeviceStates(*p) 
      
      If *p\cbAfterReset
        *p\cbAfterReset(*p)
      EndIf
      
      
    EndIf
  EndIf
EndProcedure

Procedure __Canvas_Show(*p.SVisualisationCanvas)
  Protected result.i, TimeOut.i, pres.D3DPresent_Parameters
  
  If *p And *p\D3DDevice
    result = *p\D3DDevice\TestCooperativeLevel()
    If result=#D3DERR_DRIVERINTERNALERROR:*p\bDeviceUseable = #False:ProcedureReturn #D3DERR_DRIVERINTERNALERROR:EndIf
    
    If result=#D3DERR_DEVICELOST
      *p\bDeviceUseable = #False
      TimeOut=GetTickCount_()
      Repeat
        Sleep_(1)
        result=*p\D3DDevice\TestCooperativeLevel()
        If result=#D3DERR_DRIVERINTERNALERROR:ProcedureReturn #D3DERR_DRIVERINTERNALERROR:EndIf
      Until result=#D3DERR_DEVICENOTRESET Or result = #D3D_OK Or GetTickCount_() - TimeOut > 256
      If result=#D3DERR_DEVICELOST:ProcedureReturn #D3DERR_DEVICELOST:EndIf
    EndIf
    
    If result=#D3DERR_DEVICENOTRESET ;Restore Device
      *p\bDeviceUseable = #False
      ;----> Free all Default Pool ressources <----
  
      If *p\cbBeforeReset
        *p\cbBeforeReset(*p)
      EndIf
      
      CopyMemory(*p\D3dWnd, pres, SizeOf(D3DPresent_Parameters))
      If *p\D3DDevice\Reset(pres)
        *p\bDeviceUseable = #False
        ProcedureReturn #E_FAIL
      Else
        *p\bDeviceUseable = #True
      EndIf
      
      ;----> Recreate Default Pool ressources <----
      __ResetD3DDeviceStates(*p)    
      If *p\cbAfterReset
        *p\cbAfterReset(*p)
      EndIf
      
      ;___PrepareD3D9Device()
      ;AlphaBlendState=1:*D3DDevice9\SetRenderState(#D3DRS_ALPHABLENDENABLE,1)
      ;SrcBlendMode=#D3DBLEND_SRCALPHA:*D3DDevice9\SetRenderState(#D3DRS_SRCBLEND,#D3DBLEND_SRCALPHA)
      ;DestBlendMode=#D3DBLEND_INVSRCALPHA:*D3DDevice9\SetRenderState(#D3DRS_DESTBLEND,#D3DBLEND_INVSRCALPHA)
      ;CurrentFVF=#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW:*D3DDevice9\SetFVF(#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW)
      ;BackBufferPitch=0
      ;BeginScene=0 ;?
    EndIf
    If *p\bDeviceUseable
      If GetTickCount_() - *p\iLastPresentTickCount > 30 ; only max 30 frames per second
        *p\iLastPresentTickCount = GetTickCount_()
        ProcedureReturn *p\D3DDevice\Present(0,0,0,0) 
      Else
        ProcedureReturn #S_OK
      EndIf
      
    EndIf
  EndIf
  ProcedureReturn #E_FAIL
EndProcedure


Procedure Canvas_Show(*p.SVisualisationCanvas)
  If *p
    If *p\cbRun
      *p\cbRun(*p)
    EndIf
    If __Canvas_Show(*p.SVisualisationCanvas) = #D3D_OK
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure Canvas_Free(*p.SVisualisationCanvas)
  If *p
  
    If *p\StateBlock
      *p\StateBlock\Release()
      *p\StateBlock = #Null
    EndIf
  
    If *p\D3DDevice
      *p\D3DDevice\Release()
      *p\D3DDevice = #Null
    EndIf
    
    If *p\D3D
      *p\D3D\Release()
      *p\D3D = #Null
    EndIf
    
    If *p\D3D9DLL
      FreeLibrary_(*p\D3D9DLL)
      *p\D3D9DLL = #Null
    EndIf
  EndIf
EndProcedure

Procedure Canvas_InitObject(*p.SVisualisationCanvas)
  *p\VTable = *p + OffsetOf(SVisualisationCanvas\pQueryInterface)
  *p\pAddRef = @__Canvas_AddRef()
  *p\pQueryInterface = @__Canvas_QueryInterface()
  *p\pRelease = @__Canvas_Release()
  *p\pGetWidth = @__Canvas_GetWidth()
  *p\pGetHeight = @__Canvas_GetHeight()
  *p\pUpdateSample = @__Canvas_UpdateSamples()
  *p\pReadSample = @__Canvas_ReadSample()
  *p\pGetSampleSize = @__Canvas_GetSampleSize()
  *p\pGetSampleBitsPerSample = @__Canvas_GetSampleBitsPerSample()
  *p\pGetSampleBitsSamplesPerSec = @__Canvas_GetSampleBitsSamplesPerSec()
  *p\pGetSampleChannels = @__Canvas_GetSampleChannels()
  *p\pBeginScene = @__Canvas_BeginScene()
  *p\pEndScene = @__Canvas_EndScene()
  *p\pGetD3DDevice9 = @__Canvas_GetD3DDevice()
  *p\pGetHWND = @__Canvas_GetHWND()
  *p\pCanRender = @__Canvas_CanRender()
  *p\pGetUserData = @__Canvas_GetUserData()
  *p\pSetUserData = @__Canvas_SetUserData()
  *p\pClear = @__Canvas_Clear()
EndProcedure

Procedure Canvas_ConnectRenderer(*p.SVisualisationCanvas, *init.CBInit, *run.CBRun, *terminate.CBTerminate, *beforeReset.CBBeforeResetDevice, *afterReset.CBAfterResetDevice)
  If *p
    If *p\cbInit Or *p\cbRun Or *p\cbTerminate Or *p\cbAfterReset Or *p\cbBeforeReset
      __Canvas_Error("Cannot connect more than one renderer")
      ProcedureReturn #False
    EndIf
    
    *p\cbInit = *init
    *p\cbRun = *run
    *p\cbTerminate = *terminate
    *p\cbAfterReset = *afterReset
    *p\cbBeforeReset = *beforeReset
        
    If *p\cbInit And *p\cbRun And *p\cbTerminate And *p\cbAfterReset And *p\cbBeforeReset
      If *p\cbInit(*p)
        __Canvas_Debug("Renderer connected sucessfully")    
        ProcedureReturn #True
      Else
        __Canvas_Error("Renderer Init failed")
        *p\cbInit = #Null
        *p\cbRun = #Null
        *p\cbTerminate = #Null
        *p\cbAfterReset = #Null
        *p\cbBeforeReset = #Null
        ProcedureReturn #False    
      EndIf
      
    Else
      __Canvas_Error("Failed to connect renderer, because of missing functions")
      ProcedureReturn #False
    EndIf
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure Canvas_ConnectRendererDLL(*p.SVisualisationCanvas, sDLL.s)
  Protected hModule.i, bResult = #False
  If *p
    hModule = LoadLibrary_(sDLL.s)
    If hModule  
      If GetProcAddress_(hModule, "GetVersion") 
        If Canvas_ConnectRenderer(*p, GetProcAddress_(hModule, "Init"), GetProcAddress_(hModule, "Run"), GetProcAddress_(hModule, "Terminate"), GetProcAddress_(hModule, "BeforeReset"), GetProcAddress_(hModule, "AfterReset"))
          *p\hRendererModule = hModule
          bResult = #True
        EndIf
        __Canvas_Error("Failed to connect renderer")
      EndIf
      
      If bResult = #False
        FreeLibrary_(hModule);2010-11-04 verschoben 2010-09-14 Achtung bei Erfolg darf die DLL noch nicht freigegebn werden!!!
      EndIf  
    Else
      __Canvas_Error("Cannot load DLL "+ sDLL)
    EndIf
  EndIf
  ProcedureReturn bResult
EndProcedure

Procedure Canvas_RemoveRenderer(*p.SVisualisationCanvas)
  Protected stage
  If *p
    If *p\cbTerminate
      *p\cbTerminate(*p)
      
      
      ; 2010-09-14 hinzugefügt
      If  *p\D3DDevice
        For stage = 0 To 16
          *p\D3DDevice\SetTexture(stage, #Null)
        Next
      EndIf

      If *p\hRendererModule
        FreeLibrary_(*p\hRendererModule)
      EndIf
      *p\hRendererModule = #Null
      *p\cbInit = #Null
      *p\cbRun = #Null
      *p\cbTerminate = #Null
      *p\cbAfterReset = #Null
      *p\cbBeforeReset = #Null
    EndIf
  EndIf
EndProcedure













;{ Example 1
; #GREENFORCE_PLUGIN_VERSION = 100
; 
; Structure D3DXVECTOR2
; x.f
; y.f
; EndStructure
; 
; Prototype.i D3DXCreateLine(*device, *line)
; 
; Global D3DXModule.i, D3DXLine.ID3DXLine
; Procedure Init(*p.IVisualisationCanvas)
; Protected iIndex.i, D3DXCreateLine.D3DXCreateLine
; D3DXModule = #Null
; 
; For iIndex = 24 To 50
;   If D3DXModule = #Null
;     D3DXModule = LoadLibrary_("d3dx9_" + Str(iIndex) + ".dll")
;   EndIf
; Next
; D3DXCreateLine = GetProcAddress_(D3DXModule,"D3DXCreateLine")
; If D3DXCreateLine
;   D3DXCreateLine(*p\GetD3DDevice9(), @D3DXLine)
;   If D3DXLine
;     ProcedureReturn #True
;   EndIf
; EndIf
; 
; If D3DXModule
;   FreeLibrary_(D3DXModule)
; EndIf
; ProcedureReturn #False
; EndProcedure
; 
; ProcedureDLL Run(*p.IVisualisationCanvas)
; Protected x.i, dev.IDirect3DDevice9, iWidth, iHeight
; 
; If D3DXLine
;   Dim vert.D3DXVECTOR2(199)
;   If *p\CanRender()
;     *p\UpdateSample()
;    
;     iWidth = *p\GetWidth()
;     iHeight = *p\GetHeight()
;     For x=0 To 199
;       vert(x)\x = iWidth * x / 200
;       vert(x)\y = *p\ReadSample(x) * iHeight/2 + iHeight/2
;     Next
;   
;     *p\Clear($FF000044)    
;     If *p\BeginScene()
;       D3DXLine\SetWidth(4)
;       D3DXLine\Begin()
;       D3DXLine\Draw(@vert(),200, RGBA(128,255,255,160))
;       D3DXLine\End()
;       *p\EndScene()
;     EndIf
;   EndIf
; EndIf
; EndProcedure
; 
; ProcedureDLL BeforeReset(*p.IVisualisationCanvas)
;   If D3DXLine
;     D3DXLine\OnLostDevice()
;   EndIf
; EndProcedure
; 
; ProcedureDLL AfterReset(*p.IVisualisationCanvas)
;   If D3DXLine
;     D3DXLine\OnResetDevice()
;   EndIf
; EndProcedure
; 
; ProcedureDLL Terminate(*p.IVisualisationCanvas)
;   If D3DXLine
;     D3DXLine\Release() 
;   EndIf
;   If D3DXModule
;     FreeLibrary_(D3DXModule)
;   EndIf
;   D3DXLine = #Null
;   D3DXModule = #Null
; EndProcedure
; 
; ProcedureDLL GetVersion()
; ProcedureReturn #GREENFORCE_PLUGIN_VERSION
; EndProcedure
; 
;}
;{ Example 2
; 
; #GREENFORCE_PLUGIN_VERSION = 100
; 
; Structure D3DXVECTOR2
; x.f
; y.f
; EndStructure
; 
; Prototype.i D3DXCreateLine(*device, *line)
; 
; Global D3DXModule.i, D3DXLine.ID3DXLine
; 
; Procedure Init(*p.IVisualisationCanvas)
;   Protected iIndex.i, D3DXCreateLine.D3DXCreateLine, bUseD3DX
;   D3DXModule = #Null
;   bUseD3DX = #False
;         
;   For iIndex = 24 To 42
;     If D3DXModule = #Null
;       D3DXModule = LoadLibrary_("d3dx9_" + Str(iIndex) + ".dll")
;     EndIf
;   Next
;   
;   D3DXCreateLine = GetProcAddress_(D3DXModule,"D3DXCreateLine")
;   If D3DXCreateLine
;     D3DXCreateLine(*p\GetD3DDevice9(), @D3DXLine)
;     If D3DXLine
;       bUseD3DX = #True
;     EndIf
;   EndIf
;   
;   If bUseD3DX = #False
;     If D3DXModule
;       FreeLibrary_(D3DXModule)
;     EndIf
;   EndIf
;   ProcedureReturn #True
; EndProcedure
; 
; ProcedureDLL Run(*p.IVisualisationCanvas)
; Protected x.i, dev.IDirect3DDevice9, iWidth, iHeight, *BackBuffer.IDirect3DSurface9, DC.i, pt.POINT, hPen.i, hOldPen.i
; 
;   Dim vert.D3DXVECTOR2(199)
;   If *p\CanRender()
;     *p\UpdateSample()
;    
;     *p\Clear($FF000044)       
;     iWidth = *p\GetWidth()
;     iHeight = *p\GetHeight()    
;     
;     If D3DXLine
;   
;       For x=0 To 199
;         vert(x)\x = iWidth * x / 200
;         vert(x)\y = *p\ReadSample(x) * iHeight/2 + iHeight/2
;       Next
;       
;       If *p\BeginScene()
;         D3DXLine\SetWidth(4)
;         D3DXLine\Begin()
;         D3DXLine\Draw(@vert(),200, RGBA(128,128,128,255))
;         D3DXLine\End()
;         *p\EndScene()
;       EndIf      
;     
;     Else
;          
;       dev = *p\GetD3DDevice9()
;       If dev
;         dev\GetBackBuffer(0,0,#D3DBACKBUFFER_TYPE_MONO,@*BackBuffer)
;         If *BackBuffer
;           *BackBuffer\GetDC(@DC)
;           If DC
;             hPen = CreatePen_(#PS_SOLID,4,RGB(128,128,128))
;             hOldPen = SelectObject_(DC, hPen)
;             
;             MoveToEx_(DC,0,Int(*p\ReadSample(x) * iHeight/2 + iHeight/2), #Null)
;             For x=1 To 199
;                 LineTo_(DC,Int((iWidth * x) / 200),Int((*p\ReadSample(x) * iHeight/2 + iHeight/2)))       
;             Next           
;             SelectObject_(DC, hOldPen)
;             DeleteObject_(hPen)
;             
;             *BackBuffer\ReleaseDC(DC)
;           EndIf
;           *BackBuffer\Release()
;         EndIf
;       EndIf
;     
;   EndIf
; EndIf
; EndProcedure
; 
; ProcedureDLL BeforeReset(*p.IVisualisationCanvas)
;   If D3DXLine
;     D3DXLine\OnLostDevice()
;   EndIf
; EndProcedure
; 
; ProcedureDLL AfterReset(*p.IVisualisationCanvas)
;   If D3DXLine
;     D3DXLine\OnResetDevice()
;   EndIf
; EndProcedure
; 
; ProcedureDLL Terminate(*p.IVisualisationCanvas)
;   If D3DXLine
;     D3DXLine\Release() 
;   EndIf
;   If D3DXModule
;     FreeLibrary_(D3DXModule)
;   EndIf
;   D3DXLine = #Null
;   D3DXModule = #Null
; EndProcedure
; 
; ProcedureDLL GetVersion()
; ProcedureReturn #GREENFORCE_PLUGIN_VERSION
; EndProcedure
; 
; 
; 
; 
; Global VisualCanvas.SVisualisationCanvas, *VisualCanvas.IVisualisationCanvas
; Canvas_InitObject(VisualCanvas)
; 
; *VisualCanvas = VisualCanvas
; 
; 
; Global *dev.IDirect3DDevice9, x.ID3DXSprite, *obj
; 
; 
; 
; DShow_InitMedia()
; 
; OpenWindow(1,0,0,640,480,"test")
; OpenWindow(2,0,0,640,480,"test", #WS_SIZEBOX)
; 
; 
; *obj = DShow_LoadMedia("test.avi",WindowID(1))
; 
; Debug Canvas_Create(VisualCanvas, WindowID(2), 640,480)
; 
; DShow_PlayMedia(*obj)
; Canvas_SetDSHOWObj(VisualCanvas, *obj)
; Canvas_ConnectRenderer(VisualCanvas, @Init(), @Run(), @Terminate(), @BeforeReset(), @AfterReset())
; 
; 
; 
; ;PROC = GetProcAddress_(VisualCanvas\D3DX9DLL, "D3DXCreateSprite")
; ;CallFunctionFast(PROC, @x)
; 
; ;x\Draw()
; 
; 
; Repeat
; 
; Canvas_Resize(VisualCanvas, WindowWidth(2), WindowHeight(2))
; 
; Canvas_Show(VisualCanvas)
; 
; Until WaitWindowEvent()= #WM_CLOSE
; 
;}




; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 748
; FirstLine = 435
; Folding = BYAwlm
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
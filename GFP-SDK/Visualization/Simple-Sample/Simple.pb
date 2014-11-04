;************************************************************
;*** GreenForce Player *** Visualization Interaktiv System **
;*** http://GFP.RRSoftware.de ********************* Sample **
;*** (c) 2009 - 2010 RocketRider ****************************
;*** zlib Licence *******************************************
;************************************************************
XIncludeFile "../GFP_VIS_Include.pbi"



#GREENFORCE_PLUGIN_SIMPLE_VERSION = 100
Structure D3DXVECTOR2
  x.f
  y.f
EndStructure
Prototype.i D3DXCreateLine(*device, *line)
Global D3DXModule.i, D3DXLine.ID3DXLine



ProcedureDLL Init(*p.IVisualisationCanvas)
  Protected iIndex.i, D3DXCreateLine.D3DXCreateLine, bUseD3DX
  D3DXModule = #Null
  bUseD3DX = #False
        
  For iIndex = 24 To 42
    If D3DXModule = #Null
      D3DXModule = LoadLibrary_("d3dx9_" + Str(iIndex) + ".dll")
    EndIf
  Next
  
  D3DXCreateLine = GetProcAddress_(D3DXModule,"D3DXCreateLine")
  If D3DXCreateLine
    D3DXCreateLine(*p\GetD3DDevice9(), @D3DXLine)
    If D3DXLine
      bUseD3DX = #True
    EndIf
  EndIf
  
  If bUseD3DX = #False
    If D3DXModule
      FreeLibrary_(D3DXModule)
    EndIf
  EndIf
  ProcedureReturn #True
EndProcedure
ProcedureDLL Run(*p.IVisualisationCanvas)
Protected x.i, dev.IDirect3DDevice9, iWidth, iHeight, *BackBuffer.IDirect3DSurface9, DC.i, pt.POINT, hPen.i, hOldPen.i

  Dim vert.D3DXVECTOR2(199)
  If *p\CanRender()
    *p\UpdateSample()
   
    *p\Clear($FF000044)       
    iWidth = *p\GetWidth()
    iHeight = *p\GetHeight()    
    
    If D3DXLine
  
      For x=0 To 199
        vert(x)\x = iWidth * x / 200
        vert(x)\y = *p\ReadSample(x) * iHeight/2 + iHeight/2
      Next
      
      If *p\BeginScene()
        D3DXLine\SetWidth(4)
        D3DXLine\Begin()
        D3DXLine\Draw(@vert(),200, RGBA(255,255,255,255))
        D3DXLine\End()
        *p\EndScene()
      EndIf
    
    Else
         
      dev = *p\GetD3DDevice9()
      If dev
        dev\GetBackBuffer(0,0,#D3DBACKBUFFER_TYPE_MONO,@*BackBuffer)
        If *BackBuffer
          *BackBuffer\GetDC(@DC)
          If DC
            hPen = CreatePen_(#PS_SOLID,4,RGB(255,255,255))
            hOldPen = SelectObject_(DC, hPen)
            
            MoveToEx_(DC,0,Int(*p\ReadSample(x) * iHeight/2 + iHeight/2), #Null)
            For x=1 To 199
                LineTo_(DC,Int((iWidth * x) / 200),Int((*p\ReadSample(x) * iHeight/2 + iHeight/2)))       
            Next           
            SelectObject_(DC, hOldPen)
            DeleteObject_(hPen)
            
            *BackBuffer\ReleaseDC(DC)
          EndIf
          *BackBuffer\Release()
        EndIf
      EndIf
    
  EndIf
EndIf
EndProcedure

ProcedureDLL BeforeReset(*p.IVisualisationCanvas)
  If D3DXLine
    D3DXLine\OnLostDevice()
  EndIf
EndProcedure
ProcedureDLL AfterReset(*p.IVisualisationCanvas)
  If D3DXLine
    D3DXLine\OnResetDevice()
  EndIf
EndProcedure
ProcedureDLL Terminate(*p.IVisualisationCanvas)
  If D3DXLine
    D3DXLine\Release() 
  EndIf
  If D3DXModule
    FreeLibrary_(D3DXModule)
  EndIf
  D3DXLine = #Null
  D3DXModule = #Null
EndProcedure

ProcedureDLL GetVersion()
  ProcedureReturn #GREENFORCE_PLUGIN_SIMPLE_VERSION
EndProcedure


; IDE Options = PureBasic 4.50 Beta 2 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 20
; Folding = A-
; EnableXP
; EnableUser
; EnableOnError
; Executable = Simple-Sample.vis-dll
; EnableCompileCount = 9
; EnableBuildCount = 6
; EnableExeConstant
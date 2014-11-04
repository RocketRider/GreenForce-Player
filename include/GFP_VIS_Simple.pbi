;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************


#GREENFORCE_PLUGIN_SIMPLE_VERSION = 100

Structure D3DXVECTOR2
  x.f
  y.f
EndStructure

Prototype.i D3DXCreateLine(*device, *line)

Global VIS_Simple_D3DXModule.i, VIS_Simple_D3DXLine.ID3DXLine

ProcedureDLL VIS_Simple_Init(*p.IVisualisationCanvas)
  Protected iIndex.i, D3DXCreateLine.D3DXCreateLine, bUseD3DX
  VIS_Simple_D3DXModule = #Null
  bUseD3DX = #False
        
  For iIndex = 24 To 42
    If VIS_Simple_D3DXModule = #Null
      VIS_Simple_D3DXModule = LoadLibrary_("d3dx9_" + Str(iIndex) + ".dll")
    EndIf
  Next
  
  D3DXCreateLine = GetProcAddress_(VIS_Simple_D3DXModule,"D3DXCreateLine")
  If D3DXCreateLine
    D3DXCreateLine(*p\GetD3DDevice9(), @VIS_Simple_D3DXLine)
    If VIS_Simple_D3DXLine
      bUseD3DX = #True
    EndIf
  EndIf
  
  If bUseD3DX = #False
    If VIS_Simple_D3DXModule
      FreeLibrary_(VIS_Simple_D3DXModule)
    EndIf
  EndIf
  ProcedureReturn #True
EndProcedure


ProcedureDLL VIS_Simple_Run(*p.IVisualisationCanvas)
Protected x.i, dev.IDirect3DDevice9, iWidth, iHeight, *BackBuffer.IDirect3DSurface9, DC.i, pt.POINT, hPen.i, hOldPen.i, length.i, stepsz.d

  Dim vert.D3DXVECTOR2(199)
  
  If *p\CanRender()
    *p\UpdateSample()
    
    *p\Clear($FF000044)       
    iWidth = *p\GetWidth()
    iHeight = *p\GetHeight()    
    
    length = (*p\GetSampleSize()-1)
    stepsz = length / 200.0    
    If VIS_Simple_D3DXLine
          
      For x=0 To 199
        vert(x)\x = iWidth * x / 200
        vert(x)\y = *p\ReadSample(length - Int(stepsz * x)) * iHeight/2 + iHeight/2
      Next
      
      If *p\BeginScene()
        VIS_Simple_D3DXLine\SetWidth(4)
        VIS_Simple_D3DXLine\Begin()
        VIS_Simple_D3DXLine\Draw(@vert(),200, RGBA(128,128,128,255))
        VIS_Simple_D3DXLine\End()
        *p\EndScene()
      EndIf
    
    Else
         
      dev = *p\GetD3DDevice9()
      If dev
        dev\GetBackBuffer(0,0,#D3DBACKBUFFER_TYPE_MONO,@*BackBuffer)
        If *BackBuffer
          *BackBuffer\GetDC(@DC)
          If DC
            hPen = CreatePen_(#PS_SOLID,4,RGB(128,128,128))
            hOldPen = SelectObject_(DC, hPen)
            
            x = 0
            MoveToEx_(DC,0,Int(*p\ReadSample(length - Int(stepsz * x)) * iHeight/2 + iHeight/2), #Null)
            For x=1 To 199
                LineTo_(DC,Int((iWidth * x) / 200),Int((*p\ReadSample(length - Int(stepsz * x)) * iHeight/2 + iHeight/2)))       
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

ProcedureDLL VIS_Simple_BeforeReset(*p.IVisualisationCanvas)
  If VIS_Simple_D3DXLine
    VIS_Simple_D3DXLine\OnLostDevice()
  EndIf
EndProcedure

ProcedureDLL VIS_Simple_AfterReset(*p.IVisualisationCanvas)
  If VIS_Simple_D3DXLine
    VIS_Simple_D3DXLine\OnResetDevice()
  EndIf
EndProcedure

ProcedureDLL VIS_Simple_Terminate(*p.IVisualisationCanvas)
  If VIS_Simple_D3DXLine
    VIS_Simple_D3DXLine\Release() 
  EndIf
  If VIS_Simple_D3DXModule
    FreeLibrary_(VIS_Simple_D3DXModule)
  EndIf
  VIS_Simple_D3DXLine = #Null
  VIS_Simple_D3DXModule = #Null
EndProcedure

ProcedureDLL VIS_Simple_GetVersion()
  ProcedureReturn #GREENFORCE_PLUGIN_SIMPLE_VERSION
EndProcedure


; IDE Options = PureBasic 4.70 Beta 1 (Windows - x86)
; CursorPosition = 80
; FirstLine = 13
; Folding = S-
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2010 RocketRider *******
;***************************************
EnableExplicit


Macro ToPow2(val)
  Pow(2,Round(Log(val)/Log(2),1))
EndMacro

Structure MyColoredSpriteVertex
  x.f
  y.f
  z.f
  rhw.f
  Color.l
  tu.f
  tv.f
EndStructure 

Structure DisplaySpriteColor
  v.MyColoredSpriteVertex[4]
EndStructure

Structure MyD3DTLVERTEX
  x.f
  y.f
  z.f
  rhw.f
  Color.l
  tu.f
  tv.f
EndStructure

Structure RECTF
  left.f
  top.f
  right.f
  bottom.f
EndStructure

Structure DX9Sprite3D
  D3DDevice9.IDirect3DDevice9
  Texture.IDirect3DTexture  
  Vertice.MyD3DTLVERTEX[4] ; The 4 vertices for the rectangle sprite
  Width.i 		             ; width set with ZoomSprite3D()
  Height.i			           ; height set with ZoomSprite3D()
  RealWidth.i
  RealHeight.i
  Angle.f
  Transformed.i
  BoundingBox.RECTF
EndStructure


;Global *D3DDevice9.IDirect3DDevice9


;Global AlphaBlendState,SrcBlendMode,DestBlendMode
;Global CurrentFVF

;Global S3DSrcBlendMode,S3DDestBlendMode
;Global S3DQuality

;Global *Sprite3DIndexBuffer.l,*Sprite3DVertexBuffer.l
;Global Sprite3D_CanRender.l
;Global Sprite3D_QuadCount.l,Sprite3D_LastTex1.l,Sprite3D_SetTex1.l
;Global Sprite3D_Clipping.l

Structure DX9Sprite3DGlobals
  S3DSrcBlendMode.i
  S3DDestBlendMode.i
  S3DQuality.i
  ;CanRender.i
  QuadCount.i
  LastTex1.IDirect3DTexture9
  SetTex1.IDirect3DTexture9
  Clipping.i
  Sprite3DIndexBuffer.i
  Sprite3DVertexBuffer.i
  D3DDevice9.IDirect3DDevice9
  ScreenWidth.i
  ScreenHeight.i
  CanRender.i
EndStructure
; 
; Structure D3DSURFACE_DESC
;   Format.l
;   Type.l
;   Usage.l
;   Pool.l
;   Size.l
;   MultiSampleType.l
;   Width.l
;   Height.l
; EndStructure

Global g_S3DGlbs.DX9Sprite3DGlobals


Procedure __Sprite2D_Debug(sText.s)
  ;Debug sText
  ;WriteLog(sText, #LOGLEVEL_DEBUG)
EndProcedure

Procedure __Sprite2D_Error(sText.s)
  ;Debug sText  
  ;WriteLog(sText, #LOGLEVEL_ERROR)
EndProcedure


Procedure Sprite2D_Init(*D3DDevice9.IDirect3DDevice9, ScreenWidth.i, ScreenHeight.i)
  If *D3DDevice9 = #Null:ProcedureReturn #False:EndIf
  g_S3DGlbs\D3DDevice9 = *D3DDevice9
  g_S3DGlbs\S3DSrcBlendMode = #D3DBLEND_SRCALPHA     
  g_S3DGlbs\S3DDestBlendMode = #D3DBLEND_INVSRCALPHA
  g_S3DGlbs\ScreenWidth = ScreenWidth
  g_S3DGlbs\ScreenHeight = ScreenHeight
  ProcedureReturn #True
EndProcedure

Procedure Sprite2D_SetScreenSize(Width.i, Height.i)
  g_S3DGlbs\ScreenWidth = Width
  g_S3DGlbs\ScreenHeight = Height
EndProcedure

ProcedureDLL Sprite2D_Create(*Texture.IDirect3DTexture9)
  Protected desc.D3DSURFACE_DESC, Width.i, Height.i
  Protected *ptr.DX9Sprite3D, *D3DDevice9, *Surface.IDirect3DSurface9

  If *Texture = #Null:ProcedureReturn #Null:EndIf
  *ptr.DX9Sprite3D = AllocateMemory(SizeOf(DX9Sprite3D))
  If *ptr=0:ProcedureReturn #Null:EndIf
  
  *ptr\D3DDevice9 = *D3DDevice9
  *ptr\Texture = *Texture
  
  *Texture\AddRef()
  
  *Texture\GetSurfaceLevel(0, @*Surface.IDirect3DSurface9)
  If *Surface
    *Surface\GetDesc(desc)
    *Surface\Release()
  EndIf
  Width = desc\Width
  Height = desc\Height
  
  *ptr\Width=Width
  *ptr\Height=Height
  *ptr\RealWidth=Width
  *ptr\RealHeight=Height
  
  *ptr\Vertice[0]\x=0.0
  *ptr\Vertice[1]\x=Width
  *ptr\Vertice[2]\x=0.0
  *ptr\Vertice[3]\x=Width
  
  *ptr\Vertice[0]\y=0.0
  *ptr\Vertice[1]\y=0.0
  *ptr\Vertice[2]\y=Height
  *ptr\Vertice[3]\y=Height
  
  *ptr\Vertice[0]\z=0.0
  *ptr\Vertice[1]\z=0.0
  *ptr\Vertice[2]\z=0.0
  *ptr\Vertice[3]\z=0.0
  
  *ptr\Vertice[0]\rhw=1.0
  *ptr\Vertice[1]\rhw=1.0
  *ptr\Vertice[2]\rhw=1.0
  *ptr\Vertice[3]\rhw=1.0
  
  *ptr\Vertice[0]\Color=$FFFFFF
  *ptr\Vertice[1]\Color=$FFFFFF
  *ptr\Vertice[2]\Color=$FFFFFF
  *ptr\Vertice[3]\Color=$FFFFFF
  
  *ptr\Vertice[0]\tu=0.0
  *ptr\Vertice[0]\tv=0.0
  *ptr\Vertice[1]\tu=1.0
  *ptr\Vertice[1]\tv=0.0
  *ptr\Vertice[2]\tu=0.0
  *ptr\Vertice[2]\tv=1.0
  *ptr\Vertice[3]\tu=1.0
  *ptr\Vertice[3]\tv=1.0
  
  *ptr\BoundingBox\left=0
  *ptr\BoundingBox\top=0
  *ptr\BoundingBox\right=Width
  *ptr\BoundingBox\bottom=Height
  
  ProcedureReturn *ptr
EndProcedure  


ProcedureDLL Sprite2D_Zoom(*ptr.DX9Sprite3D,Width.i,Height.i)
  If *ptr=0:ProcedureReturn #False:EndIf
  ;*ptr\Transformed=0 
  *ptr\Width = Width
  *ptr\Height = Height
  
  *ptr\Vertice[0]\x=0.0
  *ptr\Vertice[1]\x=Width
  *ptr\Vertice[2]\x=0.0
  *ptr\Vertice[3]\x=Width
  
  *ptr\Vertice[0]\y=0.0
  *ptr\Vertice[1]\y=0.0
  *ptr\Vertice[2]\y=Height
  *ptr\Vertice[3]\y=Height
  
  *ptr\Vertice[0]\rhw=1.0
  *ptr\Vertice[1]\rhw=1.0
  *ptr\Vertice[2]\rhw=1.0
  *ptr\Vertice[3]\rhw=1.0
  
  *ptr\BoundingBox\left=0.0
  *ptr\BoundingBox\top=0.0
  *ptr\BoundingBox\right=Width
  *ptr\BoundingBox\bottom=Height
  ;*ptr\Transformed=0
  
  ProcedureReturn #True
EndProcedure
  
ProcedureDLL Sprite2D_Rotate(*ptr.DX9Sprite3D, Angle.f, Mode)
  Protected pCos.f, pSin.f, nSin.f, mx.f, my.f, XTmp.f, YTmp.f, xmin.f, xmax.f, ymin.f, ymax.f
  
  If *ptr=0:ProcedureReturn #False:EndIf
  
  ;*ptr\Transformed=0 
  If Mode = #False
    *ptr\Angle=Angle*ACos(-1)*2/360
  Else
    *ptr\Angle+Angle*ACos(-1)*2/360
  EndIf
  
  *ptr\Vertice[0]\x=0.0
  *ptr\Vertice[1]\x=*ptr\Width
  *ptr\Vertice[2]\x=0.0
  *ptr\Vertice[3]\x=*ptr\Width
  
  *ptr\Vertice[0]\y=0.0
  *ptr\Vertice[1]\y=0.0
  *ptr\Vertice[2]\y=*ptr\Height
  *ptr\Vertice[3]\y=*ptr\Height
  
  *ptr\Vertice[0]\rhw=1.0
  *ptr\Vertice[1]\rhw=1.0
  *ptr\Vertice[2]\rhw=1.0
  *ptr\Vertice[3]\rhw=1.0
  
  pCos.f=Cos(*ptr\Angle)
  pSin.f=Sin(*ptr\Angle)
  nSin.f=-Sin(*ptr\Angle)
  
  mx.f=(*ptr\Vertice[0]\x+*ptr\Vertice[1]\x+*ptr\Vertice[2]\x+*ptr\Vertice[3]\x)/4
  my.f=(*ptr\Vertice[0]\y+*ptr\Vertice[1]\y+*ptr\Vertice[2]\y+*ptr\Vertice[3]\y)/4
  
  XTmp.f=*ptr\Vertice[0]\x
  YTmp.f=*ptr\Vertice[0]\y
  *ptr\Vertice[0]\x=(XTmp-mx) * pCos + (YTmp-my) * nSin + mx
  *ptr\Vertice[0]\y=(XTmp-mx) * pSin + (YTmp-my) * pCos + my
  
  XTmp.f=*ptr\Vertice[1]\x
  YTmp.f=*ptr\Vertice[1]\y
  *ptr\Vertice[1]\x=(XTmp-mx) * pCos + (YTmp-my) * nSin + mx
  *ptr\Vertice[1]\y=(XTmp-mx) * pSin + (YTmp-my) * pCos + my
  
  XTmp.f=*ptr\Vertice[2]\x
  YTmp.f=*ptr\Vertice[2]\y
  *ptr\Vertice[2]\x=(XTmp-mx) * pCos + (YTmp-my) * nSin + mx
  *ptr\Vertice[2]\y=(XTmp-mx) * pSin + (YTmp-my) * pCos + my
  
  XTmp.f=*ptr\Vertice[3]\x
  YTmp.f=*ptr\Vertice[3]\y
  *ptr\Vertice[3]\x=(XTmp-mx) * pCos + (YTmp-my) * nSin + mx
  *ptr\Vertice[3]\y=(XTmp-mx) * pSin + (YTmp-my) * pCos + my
  
  ;x-min
  xmin.f=*ptr\Vertice[0]\x
  If *ptr\Vertice[1]\x<xmin:xmin=*ptr\Vertice[1]\x:EndIf
  If *ptr\Vertice[2]\x<xmin:xmin=*ptr\Vertice[2]\x:EndIf
  If *ptr\Vertice[3]\x<xmin:xmin=*ptr\Vertice[3]\x:EndIf
  
  ;x-max
  xmax.f=*ptr\Vertice[0]\x
  If *ptr\Vertice[1]\x>xmax:xmax=*ptr\Vertice[1]\x:EndIf
  If *ptr\Vertice[2]\x>xmax:xmax=*ptr\Vertice[2]\x:EndIf
  If *ptr\Vertice[3]\x>xmax:xmax=*ptr\Vertice[3]\x:EndIf
  
  ;y-min
  ymin.f=*ptr\Vertice[0]\y
  If *ptr\Vertice[1]\y<ymin:ymin=*ptr\Vertice[1]\y:EndIf
  If *ptr\Vertice[2]\y<ymin:ymin=*ptr\Vertice[2]\y:EndIf
  If *ptr\Vertice[3]\y<ymin:ymin=*ptr\Vertice[3]\y:EndIf
  
  ;y-max
  ymax.f=*ptr\Vertice[0]\y
  If *ptr\Vertice[1]\y>ymax:ymax=*ptr\Vertice[1]\y:EndIf
  If *ptr\Vertice[2]\y>ymax:ymax=*ptr\Vertice[2]\y:EndIf
  If *ptr\Vertice[3]\y>ymax:ymax=*ptr\Vertice[3]\y:EndIf
  
  *ptr\BoundingBox\left=xmin
  *ptr\BoundingBox\top=ymin
  *ptr\BoundingBox\right=xmax
  *ptr\BoundingBox\bottom=ymax
  
  ProcedureReturn #True
EndProcedure


ProcedureDLL Sprite2D_DisplayEx(*ptr.DX9Sprite3D,OffsetX.f,OffsetY.f,BlendAlpha.i)
  Protected *Tex1.IDirect3DTexture9, *D3DDevice9.IDirect3DDevice9, Clipping.i
  Protected *Quad.DisplaySpriteColor
  If *ptr = #Null:ProcedureReturn #False:EndIf
  If g_S3DGlbs\CanRender = 0:ProcedureReturn #False:EndIf
  If BlendAlpha = 0:ProcedureReturn #True:EndIf ; Don't draw anything if BlendAlpha is 0!
  
  *Tex1.IDirect3DTexture9=*ptr\Texture
  *D3DDevice9.IDirect3DDevice9 = g_S3DGlbs\D3DDevice9
  
  Clipping = #True  
  ;Check if everthing of the 3dsprite is visible
  If *ptr\BoundingBox\left+OffsetX>=0 And *ptr\BoundingBox\top+OffsetY>=0
    If *ptr\BoundingBox\right+OffsetX<g_S3DGlbs\ScreenWidth And *ptr\BoundingBox\bottom+OffsetY<g_S3DGlbs\ScreenHeight
      Clipping=#False
    EndIf
  EndIf 
  
  If Clipping=#True ; if a part is not visible, test weather it's completely outside of the screen
    If *ptr\BoundingBox\left+OffsetX=>g_S3DGlbs\ScreenWidth Or *ptr\BoundingBox\right+OffsetX<0 Or  *ptr\BoundingBox\top+OffsetY=>g_S3DGlbs\ScreenHeight Or *ptr\BoundingBox\bottom+OffsetY<0
      ProcedureReturn #True ; 3dsprite is completely outside of the drawing area
    EndIf
  EndIf
  
  If g_S3DGlbs\QuadCount > 0
    If *Tex1 <> g_S3DGlbs\LastTex1 Or g_S3DGlbs\QuadCount > 5000 Or g_S3DGlbs\Clipping <> Clipping
      If g_S3DGlbs\SetTex1<>g_S3DGlbs\LastTex1 
        *D3DDevice9\SetTexture(0,g_S3DGlbs\LastTex1)
        g_S3DGlbs\SetTex1=g_S3DGlbs\LastTex1 
      EndIf
      If g_S3DGlbs\QuadCount = 1 ; Improve speed if it's only 1 quad (?)
        *D3DDevice9\DrawPrimitiveUP(#D3DPT_TRIANGLESTRIP,2,g_S3DGlbs\Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
      Else
        *D3DDevice9\DrawIndexedPrimitiveUP(#D3DPT_TRIANGLELIST,0,g_S3DGlbs\QuadCount*6,g_S3DGlbs\QuadCount*2,g_S3DGlbs\Sprite3DIndexBuffer,#D3DFMT_INDEX16,g_S3DGlbs\Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
      EndIf
      g_S3DGlbs\QuadCount=0
    EndIf
  EndIf
  
  If Clipping<>g_S3DGlbs\Clipping
    g_S3DGlbs\Clipping = Clipping
    *D3DDevice9\SetRenderState(#D3DRS_CLIPPING, Clipping)
  EndIf
  
  g_S3DGlbs\LastTex1=*Tex1
  
  *Quad.DisplaySpriteColor = g_S3DGlbs\Sprite3DVertexBuffer+g_S3DGlbs\QuadCount * SizeOf(DisplaySpriteColor)
  
  *Quad\v[0]\x=*ptr\Vertice[0]\x+OffsetX
  *Quad\v[0]\y=*ptr\Vertice[0]\y+OffsetY
  *Quad\v[0]\color=*ptr\Vertice[0]\color&$FFFFFF+BlendAlpha<<24
  *Quad\v[0]\tu=*ptr\Vertice[0]\tu
  *Quad\v[0]\tv=*ptr\Vertice[0]\tv
  *Quad\v[0]\rhw=*ptr\Vertice[0]\rhw
  
  *Quad\v[1]\x=*ptr\Vertice[1]\x+OffsetX
  *Quad\v[1]\y=*ptr\Vertice[1]\y+OffsetY
  *Quad\v[1]\color=*ptr\Vertice[1]\color&$FFFFFF+BlendAlpha<<24
  *Quad\v[1]\tu=*ptr\Vertice[1]\tu
  *Quad\v[1]\tv=*ptr\Vertice[1]\tv
  *Quad\v[1]\rhw=*ptr\Vertice[1]\rhw
  
  *Quad\v[2]\x=*ptr\Vertice[2]\x+OffsetX
  *Quad\v[2]\y=*ptr\Vertice[2]\y+OffsetY
  *Quad\v[2]\color=*ptr\Vertice[2]\color&$FFFFFF+BlendAlpha<<24
  *Quad\v[2]\tu=*ptr\Vertice[2]\tu
  *Quad\v[2]\tv=*ptr\Vertice[2]\tv
  *Quad\v[2]\rhw=*ptr\Vertice[2]\rhw
  
  *Quad\v[3]\x=*ptr\Vertice[3]\x+OffsetX
  *Quad\v[3]\y=*ptr\Vertice[3]\y+OffsetY 
  *Quad\v[3]\color=*ptr\Vertice[3]\color&$FFFFFF+BlendAlpha<<24
  *Quad\v[3]\tu=*ptr\Vertice[3]\tu
  *Quad\v[3]\tv=*ptr\Vertice[3]\tv
  *Quad\v[3]\rhw=*ptr\Vertice[3]\rhw
  
  g_S3DGlbs\QuadCount+1
  
  ProcedureReturn #True
EndProcedure

ProcedureDLL Sprite2D_Display(*ptr.DX9Sprite3D,OffsetX.f,OffsetY.f)
  ProcedureReturn Sprite2D_DisplayEx(*ptr.DX9Sprite3D, OffsetX, OffsetY, 255)
EndProcedure

ProcedureDLL Sprite2D_Start() 
  Protected *D3DDevice9.IDirect3DDevice9, SrcBlendMode, DestBlendMode
  Protected *Quad.DisplaySpriteColor, c, *IndexBuffer.l, Count
  *D3DDevice9.IDirect3DDevice9 = g_S3DGlbs\D3DDevice9
  
  If *D3DDevice9\SetRenderState(#D3DRS_ALPHABLENDENABLE,1):ProcedureReturn #False:EndIf
  ;AlphaBlendState=1
  
  If *D3DDevice9\SetFVF(#D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW):ProcedureReturn #False:EndIf
  ;CurrentFVF = #D3DFVF_TEX1|#D3DFVF_DIFFUSE|#D3DFVF_XYZRHW
  
  If *D3DDevice9\SetRenderState(#D3DRS_SRCBLEND,g_S3DGlbs\S3DSrcBlendMode):ProcedureReturn #False:EndIf
  SrcBlendMode = g_S3DGlbs\S3DSrcBlendMode
  
  If *D3DDevice9\SetRenderState(#D3DRS_DESTBLEND,g_S3DGlbs\S3DDestBlendMode):ProcedureReturn #False:EndIf          
  DestBlendMode = g_S3DGlbs\S3DDestBlendMode
  
  ;*D3DDevice9\SetSoftwareVertexProcessing(#True) ; Use software vertex processing, because we don't clip the vertices For 3DSprites
  
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG1,#D3DTA_TEXTURE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_COLORARG2,#D3DTA_DIFFUSE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAARG1,#D3DTA_TEXTURE)
  ;*D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAARG2,#D3DTA_DIFFUSE)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_MODULATE)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_MODULATE)
  
  Select g_S3DGlbs\S3DQuality
    Case 0
      *D3DDevice9\SetSamplerState(0,#D3DSAMP_MAGFILTER,#D3DTEXF_POINT)
      *D3DDevice9\SetSamplerState(0,#D3DSAMP_MINFILTER,#D3DTEXF_POINT)
    Default
      *D3DDevice9\SetSamplerState(0,#D3DSAMP_MAGFILTER,#D3DTEXF_LINEAR)
      *D3DDevice9\SetSamplerState(0,#D3DSAMP_MINFILTER,#D3DTEXF_LINEAR)
  EndSelect
  
  *D3DDevice9\SetRenderState(#D3DRS_CLIPPING,#True)
  g_S3DGlbs\Clipping=#True
  
  If g_S3DGlbs\Sprite3DVertexBuffer=0
    g_S3DGlbs\Sprite3DVertexBuffer=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,($FFFF*4/6)*SizeOf(MyColoredSpriteVertex))
    
    If g_S3DGlbs\Sprite3DVertexBuffer
      *Quad.DisplaySpriteColor=g_S3DGlbs\Sprite3DVertexBuffer
      For c=0 To ($FFFF*4/6)-1
        *Quad\v[0]\z=0.0
        *Quad\v[0]\rhw=1.0
        *Quad\v[1]\z=0.0
        *Quad\v[1]\rhw=1.0
        *Quad\v[2]\z=0.0
        *Quad\v[2]\rhw=1.0
        *Quad\v[3]\z=0.0
        *Quad\v[3]\rhw=1.0
        *Quad+SizeOf(MyD3DTLVERTEX)
      Next
    EndIf
  EndIf
  
  ; Create our index buffer for faster displaying  
  If g_S3DGlbs\Sprite3DIndexBuffer=0
    g_S3DGlbs\Sprite3DIndexBuffer=GlobalAlloc_(#GMEM_FIXED|#GMEM_ZEROINIT,$FFFF*2)
    
    If g_S3DGlbs\Sprite3DIndexBuffer
      *IndexBuffer.l=g_S3DGlbs\Sprite3DIndexBuffer
      For c=0 To $FFFF-6 Step 6
        PokeW(*IndexBuffer+c*2,0+Count)
        PokeW(*IndexBuffer+c*2+2,1+Count)
        PokeW(*IndexBuffer+c*2+4,2+Count)
        PokeW(*IndexBuffer+c*2+6,1+Count)
        PokeW(*IndexBuffer+c*2+8,3+Count)
        PokeW(*IndexBuffer+c*2+10,2+Count)
        Count+4
      Next
    EndIf
  EndIf
  
  g_S3DGlbs\CanRender=#False
  If g_S3DGlbs\Sprite3DIndexBuffer And g_S3DGlbs\Sprite3DVertexBuffer And g_S3DGlbs\D3DDevice9
    g_S3DGlbs\CanRender=#True
  EndIf
  
  g_S3DGlbs\SetTex1=0:g_S3DGlbs\LastTex1=0
  g_S3DGlbs\QuadCount=0
  
  ProcedureReturn g_S3DGlbs\CanRender
EndProcedure

ProcedureDLL Sprite2D_Stop()
  Protected  *D3DDevice9.IDirect3DDevice9
  *D3DDevice9.IDirect3DDevice9 = g_S3DGlbs\D3DDevice9
  If *D3DDevice9=0:ProcedureReturn 0:EndIf  
  
  ; Force the batch to be flushed  
  If g_S3DGlbs\QuadCount>0
    *D3DDevice9\SetTexture(0,g_S3DGlbs\LastTex1)
    *D3DDevice9\DrawIndexedPrimitiveUP(#D3DPT_TRIANGLELIST,0,g_S3DGlbs\QuadCount*6,g_S3DGlbs\QuadCount*2,g_S3DGlbs\Sprite3DIndexBuffer,#D3DFMT_INDEX16,g_S3DGlbs\Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
    g_S3DGlbs\QuadCount=0
  EndIf
  
  *D3DDevice9\SetRenderState(#D3DRS_CLIPPING,#True)
  g_S3DGlbs\Clipping=#True
  
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_COLOROP,#D3DTOP_SELECTARG1)
  *D3DDevice9\SetTextureStageState(0,#D3DTSS_ALPHAOP,#D3DTOP_SELECTARG1)
  
  ;*D3DDevice9\SetSoftwareVertexProcessing(#False)
  ProcedureReturn #True
EndProcedure

ProcedureDLL Sprite2D_SetBlendingMode(SrcMode,DestMode)
  Protected *D3DDevice9.IDirect3DDevice9, SrcBlendMode, DestBlendMode
  *D3DDevice9.IDirect3DDevice9 = g_S3DGlbs\D3DDevice9
  If *D3DDevice9=0:ProcedureReturn #False:EndIf
  
  ; Force the batch to be flushed
  If g_S3DGlbs\QuadCount>0
    *D3DDevice9\SetTexture(0,g_S3DGlbs\LastTex1)
    *D3DDevice9\DrawIndexedPrimitiveUP(#D3DPT_TRIANGLELIST,0,g_S3DGlbs\QuadCount*6,g_S3DGlbs\QuadCount*2,g_S3DGlbs\Sprite3DIndexBuffer,#D3DFMT_INDEX16,g_S3DGlbs\Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
    g_S3DGlbs\QuadCount=0
  EndIf
  
  g_S3DGlbs\S3DSrcBlendMode=SrcMode
  g_S3DGlbs\S3DDestBlendMode=DestMode
  SrcBlendMode=SrcMode
  DestBlendMode=DestMode
  If *D3DDevice9\SetRenderState(#D3DRS_SRCBLEND,SrcMode):ProcedureReturn #False:EndIf
  If *D3DDevice9\SetRenderState(#D3DRS_DESTBLEND,DestMode):ProcedureReturn #False:EndIf          
  ProcedureReturn #True
EndProcedure

ProcedureDLL Sprite2D_SetQuality(Quality)
  Protected *D3DDevice9.IDirect3DDevice9
  *D3DDevice9.IDirect3DDevice9 = g_S3DGlbs\D3DDevice9
  If *D3DDevice9=0:ProcedureReturn #False:EndIf
  
  If g_S3DGlbs\S3DQuality<>Quality
    
    ; Force the batch to be flushed
    If g_S3DGlbs\QuadCount>0
      *D3DDevice9\SetTexture(0,g_S3DGlbs\LastTex1)
      *D3DDevice9\DrawIndexedPrimitiveUP(#D3DPT_TRIANGLELIST,0,g_S3DGlbs\QuadCount*6,g_S3DGlbs\QuadCount*2,g_S3DGlbs\Sprite3DIndexBuffer,#D3DFMT_INDEX16,g_S3DGlbs\Sprite3DVertexBuffer,SizeOf(MyD3DTLVERTEX))
      g_S3DGlbs\QuadCount=0
    EndIf
    
    g_S3DGlbs\S3DQuality=Quality
    
    Select g_S3DGlbs\S3DQuality
      Case 0
        *D3DDevice9\SetSamplerState(0,#D3DSAMP_MAGFILTER,#D3DTEXF_POINT)
        *D3DDevice9\SetSamplerState(0,#D3DSAMP_MINFILTER,#D3DTEXF_POINT)
      Default
        *D3DDevice9\SetSamplerState(0,#D3DSAMP_MAGFILTER,#D3DTEXF_LINEAR)
        *D3DDevice9\SetSamplerState(0,#D3DSAMP_MINFILTER,#D3DTEXF_LINEAR)
    EndSelect
    
  EndIf
  
  ProcedureReturn #True
EndProcedure

ProcedureDLL Sprite2D_TransformEx(*ptr.DX9Sprite3D,x1.f,y1.f,z1.f,x2.f,y2.f,z2.f,x3.f,y3.f,z3.f,x4.f,y4.f,z4.f)
  Protected xmin.f, xmax.f, ymin.f, ymax.f
  If *ptr=0:ProcedureReturn 0:EndIf
  
  ;*ptr\Transformed=1 
  
  *ptr\Vertice[0]\x=x1
  *ptr\Vertice[1]\x=x2
  *ptr\Vertice[2]\x=x4
  *ptr\Vertice[3]\x=x3
  
  *ptr\Vertice[0]\y=y1
  *ptr\Vertice[1]\y=y2
  *ptr\Vertice[2]\y=y4
  *ptr\Vertice[3]\y=y3
  
  *ptr\Vertice[0]\rhw=1.0/z1
  *ptr\Vertice[1]\rhw=1.0/z2
  *ptr\Vertice[2]\rhw=1.0/z4  ; 1.0 / 4.0
  *ptr\Vertice[3]\rhw=1.0/z3
  
  ;x-min
  xmin.f=*ptr\Vertice[0]\x
  If *ptr\Vertice[1]\x<xmin:xmin=*ptr\Vertice[1]\x:EndIf
  If *ptr\Vertice[2]\x<xmin:xmin=*ptr\Vertice[2]\x:EndIf
  If *ptr\Vertice[3]\x<xmin:xmin=*ptr\Vertice[3]\x:EndIf
  
  ;x-max
  xmax.f=*ptr\Vertice[0]\x
  If *ptr\Vertice[1]\x>xmax:xmax=*ptr\Vertice[1]\x:EndIf
  If *ptr\Vertice[2]\x>xmax:xmax=*ptr\Vertice[2]\x:EndIf
  If *ptr\Vertice[3]\x>xmax:xmax=*ptr\Vertice[3]\x:EndIf
  
  ;y-min
  ymin.f=*ptr\Vertice[0]\y
  If *ptr\Vertice[1]\y<ymin:ymin=*ptr\Vertice[1]\y:EndIf
  If *ptr\Vertice[2]\y<ymin:ymin=*ptr\Vertice[2]\y:EndIf
  If *ptr\Vertice[3]\y<ymin:ymin=*ptr\Vertice[3]\y:EndIf
  
  ;y-max
  ymax.f=*ptr\Vertice[0]\y
  If *ptr\Vertice[1]\y>ymax:ymax=*ptr\Vertice[1]\y:EndIf
  If *ptr\Vertice[2]\y>ymax:ymax=*ptr\Vertice[2]\y:EndIf
  If *ptr\Vertice[3]\y>ymax:ymax=*ptr\Vertice[3]\y:EndIf
  
  *ptr\BoundingBox\left=xmin
  *ptr\BoundingBox\top=ymin
  *ptr\BoundingBox\right=xmax
  *ptr\BoundingBox\bottom=ymax
  
  ProcedureReturn #True
EndProcedure

ProcedureDLL Sprite2D_Transform(*ptr.DX9Sprite3D,x1.f,y1.f,x2.f,y2.f,x3.f,y3.f,x4.f,y4.f)
  ProcedureReturn Sprite2D_TransformEx(*ptr,x1.f,y1.f,1.0,x2.f,y2.f,1.0,x3.f,y3.f,1.0,x4.f,y4.f,1.0)
EndProcedure


Procedure Sprite2D_Clip(*ptr.DX9Sprite3D,ClipX.l,ClipY.l,ClipWidth.l,ClipHeight.l)
  If *ptr=#Null:ProcedureReturn #False:EndIf
  
  If ClipX<0:ClipX=0:EndIf
  If ClipY<0:ClipY=0:EndIf
  
  If ClipWidth<0:ClipWidth=0:EndIf
  If ClipHeight<0:ClipHeight=0:EndIf
  
  If ClipX>*ptr\RealWidth:ClipX=*ptr\RealWidth:EndIf
  If ClipY>*ptr\RealHeight:ClipY=*ptr\RealHeight:EndIf
  
  If ClipX+ClipWidth>*ptr\RealWidth:ClipWidth=*ptr\RealWidth-ClipX:EndIf
  If ClipY+ClipHeight>*ptr\RealHeight:ClipHeight=*ptr\RealHeight-ClipY:EndIf
  
  *ptr\Vertice[0]\tu=ClipX/*ptr\RealWidth
  *ptr\Vertice[0]\tv=ClipY/*ptr\RealHeight 
  
  *ptr\Vertice[1]\tu=(ClipX+ClipWidth)/*ptr\RealWidth 
  *ptr\Vertice[1]\tv=ClipY/*ptr\RealHeight
  
  *ptr\Vertice[2]\tu=ClipX/*ptr\RealWidth 
  *ptr\Vertice[2]\tv=(ClipY+ClipHeight)/*ptr\RealHeight 
  
  *ptr\Vertice[3]\tu=(ClipX+ClipWidth)/*ptr\RealWidth 
  *ptr\Vertice[3]\tv=(ClipY+ClipHeight)/*ptr\RealHeight 
  
  ProcedureReturn #True
EndProcedure

Procedure Sprite2D_Color(*ptr.DX9Sprite3D,Color1.l,Color2.l,Color3.l,Color4.l)
  If *ptr=#Null:ProcedureReturn #False:EndIf
  *ptr\Vertice[0]\Color=Color1
  *ptr\Vertice[1]\Color=Color2
  *ptr\Vertice[2]\Color=Color4
  *ptr\Vertice[3]\Color=Color3
  
  ProcedureReturn #True
EndProcedure



ProcedureDLL Sprite2D_Free(*ptr.DX9Sprite3D)
  If *ptr
    If *ptr\Texture
      *ptr\Texture\Release()
    EndIf
    FreeMemory(*ptr)
  EndIf
EndProcedure

ProcedureDLL Sprite2D_Terminate()
  If g_S3DGlbs\Sprite3DVertexBuffer
    GlobalFree_(g_S3DGlbs\Sprite3DVertexBuffer)
    g_S3DGlbs\Sprite3DVertexBuffer = #Null
  EndIf
  If g_S3DGlbs\Sprite3DIndexBuffer
    GlobalFree_(g_S3DGlbs\Sprite3DIndexBuffer)
    g_S3DGlbs\Sprite3DIndexBuffer = #Null
  EndIf
  
EndProcedure


Procedure __LoadD3DTexture9FromImage(*D3DDevice.IDirect3DDevice9, Image)
Protected *Tex.IDirect3DTexture9, Depth, bOk = #False, TmpImage, lr.D3DLOCKED_RECT
Protected *ImageBuffer, ImagePitch, y
If Image And *D3DDevice
  Depth = ImageDepth(Image)
  
  If Depth = 32
    *D3DDevice\CreateTexture(ImageWidth(Image),ImageHeight(Image),1,0,#D3DFMT_A8R8G8B8,#D3DPOOL_MANAGED, @*Tex, 0)
  Else
    TmpImage = CreateImage(#PB_Any, ImageWidth(Image), ImageHeight(Image), 32)   
    If TmpImage
      StartDrawing(ImageOutput(TmpImage))
      DrawImage(ImageID(Image),0,0)
      StopDrawing()  
      FreeImage(Image)
      Image = TmpImage
      *D3DDevice\CreateTexture(ImageWidth(Image),ImageHeight(Image),1,0,#D3DFMT_X8R8G8B8,#D3DPOOL_MANAGED, @*Tex,0)
    EndIf
  EndIf
  
  If *Tex
    If *Tex\LockRect(0,lr.D3DLOCKED_RECT,0,0) = #D3D_OK  
      If StartDrawing(ImageOutput(Image))
     
        *ImageBuffer = DrawingBuffer()
        ImagePitch = DrawingBufferPitch()
        
        For y = 0 To ImageHeight(Image) - 1
          ;If Depth = 32
            CopyMemory(*ImageBuffer + ImagePitch * (Imageheight(Image)-y-1), lr\pBits + lr\Pitch * y, ImageWidth(Image) * 4)
          ;ElseIf Depth = 24
          ;  CopyMemory(*ImageBuffer + ImagePitch * y, lr\pBits + lr\Pitch * y, ImageWidth(Image) * 3)          
          ;EndIf          
        Next
        StopDrawing()
        bOk = #True
      EndIf
      *Tex\UnlockRect(0)
    Else
      __Sprite2D_Error("Lock Texture failed")
    EndIf
    ProcedureReturn *Tex
  EndIf
  FreeImage(Image)
EndIf

If bOk = #False
  If *Tex
    *Tex\Release()
  EndIf
  ProcedureReturn #Null
Else
  ProcedureReturn *Tex
EndIf
EndProcedure


Procedure LoadD3DTexture9FromImage(*D3DDevice.IDirect3DDevice9, sFile.s, bResizeToPowerOf2.i = #False, MaxSize = 512, *orgWidth.long = #Null, *orgHeight.long = #Null)
  Protected Image, NewWidth, NewHeight, *Tex.IDirect3DTexture9
  If *D3DDevice
    Image = LoadImage(#PB_Any, sFile)
    If Image <> #Null
      If *orgWidth
        *orgWidth\l = ImageWidth(Image)  
      EndIf
      If *orgHeight
        *orgHeight\l = ImageHeight(Image)  
      EndIf 
      
      If bResizeToPowerOf2
        NewWidth =  ToPow2(Imagewidth(Image))
        If NewWidth > MaxSize:NewWidth = NewWidth:EndIf
        NewHeight =  ToPow2(ImageHeight(Image))
        If NewHeight > MaxSize:NewHeight = NewHeight:EndIf        
        ResizeImage(Image, NewWidth, NewHeight, #PB_Image_Smooth)
      EndIf     
    Else 
      __Sprite2D_Error("LoadD3DTexture9FromImage: LoadImage failed")
    EndIf     
    *Tex.IDirect3DTexture9 = __LoadD3DTexture9FromImage(*D3DDevice, Image)
    If *Tex = #Null
      __Sprite2D_Error("LoadD3DTexture9FromImage: CreateTexture failed")
    EndIf
     ProcedureReturn *Tex
  EndIf
EndProcedure

Procedure CatchD3DTexture9FromImage(*D3DDevice.IDirect3DDevice9, *Addr, bResizeToPowerOf2.i = #False, MaxSize = 512, *orgWidth.long = #Null, *orgHeight.long = #Null)
  Protected Image, NewWidth, NewHeight, *Tex.IDirect3DTexture9
  If *D3DDevice
    Image = CatchImage(#PB_Any, *Addr)
    If Image <> #Null
      If *orgWidth
        *orgWidth\l = ImageWidth(Image)  
      EndIf
      If *orgHeight
        *orgHeight\l = ImageHeight(Image)
      EndIf 
      
      If bResizeToPowerOf2
        NewWidth =  ToPow2(Imagewidth(Image))
        If NewWidth > MaxSize:NewWidth = NewWidth:EndIf
        NewHeight =  ToPow2(ImageHeight(Image))
        If NewHeight > MaxSize:NewHeight = NewHeight:EndIf        
        ResizeImage(Image, NewWidth, NewHeight, #PB_Image_Smooth)
        
      EndIf
    Else 
      __Sprite2D_Error("CatchD3DTexture9FromImage: CatchImage failed")
    EndIf
    *Tex.Idirect3DTexture9 = __LoadD3DTexture9FromImage(*D3DDevice, Image)
    If *Tex = #Null
      __Sprite2D_Error("CatchD3DTexture9FromImage: CreateTexture failed")
    EndIf
    ProcedureReturn *Tex
  EndIf
EndProcedure


Procedure CreateRTTexture(*D3DDevice.IDirect3DDevice9, width.i, height.i)
  Protected *Tex
  *D3DDevice\CreateTexture(width, height, 1, #D3DUSAGE_RENDERTARGET, #D3DFMT_A8R8G8B8,#D3DPOOL_DEFAULT, @*Tex, 0)
  If *Tex = #Null
    *D3DDevice\CreateTexture(width, height, 1, #D3DUSAGE_RENDERTARGET, #D3DFMT_X8R8G8B8,#D3DPOOL_DEFAULT, @*Tex, 0)
  EndIf 
  If *Tex = #Null
      __Sprite2D_Error("CreateRTTexture: Create RT Texture failed")    
  EndIf
  ProcedureReturn *Tex
EndProcedure









;{ Example
; 
; Global VisualCanvas.SVisualisationCanvas, *VisualCanvas.IVisualisationCanvas
; Canvas_InitObject(VisualCanvas)
; 
; *VisualCanvas = VisualCanvas
; 
; 
; UsePNGImageDecoder()
; 
; OpenWindow(1,0,0,640,480,"")
; 
; 
; Canvas_Create(VisualCanvas, WindowID(1), 640,480)
; 
; ;Canvas_ConnectRenderer(VisualCanvas, @Init(), @Run(), @Terminate(), @BeforeReset(), @AfterReset())
; 
; 
; Sprite2D_Init(*VisualCanvas\GetD3DDevice9(), 640,480)
; 
; 
; *D3DDevice.IDirect3DDevice9 = *VisualCanvas\GetD3DDevice9()
; 
; *Tex = LoadD3DTexture9FromImage(*D3DDevice,"D:\1.png");CreateD3DTexture9FromImage(*D3DDevice.IDirect3DDevice9)
; 
; 
; p = Sprite2D_Create(*Tex)
; 
; Repeat
; 
; 
; Canvas_Resize(VisualCanvas, WindowWidth(1), WindowHeight(1))
; *VisualCanvas\Clear(#Red)
; 
; *VisualCanvas\BeginScene()
; Sprite2D_Start()
; 
; 
; 
; 
; Sprite2D_Zoom(p,100,100)
; Sprite2D_Color(p, #Red, #Green, #Blue,#Blue)
; Sprite2D_Transform(p, 0 , 0 , 100, 0,200,200, 0,100)
; Sprite2D_Rotate(p,1,1)
; Sprite2D_DisplayEx(p, 0,0, 255)
; Sprite2D_Display(p, 100,0)
; Sprite2D_Stop()
; *VisualCanvas\EndScene()
; 
; 
; Canvas_Show(VisualCanvas)
; 
; Until WindowEvent()= #WM_CLOSE
; 
; 
;}



; IDE Options = PureBasic 4.50 Beta 2 (Windows - x86)
; CursorPosition = 109
; FirstLine = 85
; Folding = GAAA+
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
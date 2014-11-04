;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

#GREENFORCE_PLUGIN_DCT_VERSION = 100


Global Dim VIS_DCT_K.d(255,255)
Global Dim VIS_DCT_C.d(255)
Global Dim VIS_DCT_block.f(255)
Global Dim VIS_DCT_temp.d(255)
Procedure VIS_DCT_dct_init256() 
  Protected x.i, h.i, i.i
  For x = 0 To 255
    For h = 0 To 255   
      VIS_DCT_K(x,h) = Cos((#PI * h * ((2.0 * x ) + 1.0)) / 512.0);
    Next
  Next

  VIS_DCT_C(0) = (1/Sqr(256))
  For i = 1 To 255
    VIS_DCT_C(i) = 2.0/(Sqr(512))
  Next
EndProcedure
Procedure VIS_DCT_dct_256() 
  Protected x.i, h.i, i.i
  For x=0 To 255 
    VIS_DCT_temp(x) = 0.0
  Next

  For h=0 To 255
    For x=0 To 255
      VIS_DCT_temp(h) + VIS_DCT_block(x) * VIS_DCT_K(x,h)
    Next
    VIS_DCT_temp(h) * (VIS_DCT_C(h));
  Next

  For x=0 To 255
    VIS_DCT_block(x) = VIS_DCT_temp(x);
  Next
  
EndProcedure
Procedure VIS_DCT_idct_256() 
  Protected x.i, h.i, i.i
  For x=0 To 255
    VIS_DCT_temp(x) = 0.0
  Next

    For h=0 To 255
        For x=0 To 255 
          VIS_DCT_temp(x) + VIS_DCT_C(h) * VIS_DCT_block(h) * VIS_DCT_K(x,h)
        Next
  Next

  For x=0 To 255
    VIS_DCT_block(x) = VIS_DCT_temp(x);
  Next
EndProcedure


Global *VIS_DCT_D3DDevice.IDirect3DDevice9
Global VIS_DCT_Sprite.i, VIS_DCT_BK_Sprite.i
Global *VIS_DCT_Texture.IDirect3DTexture9, *VIS_DCT_BK_Texture.IDirect3DTexture9
Global VIS_DCT_LastColor.i
Global iVIS_DCT_Width, iVIS_DCT_Height

ProcedureDLL VIS_DCT_Init(*p.IVisualisationCanvas)
  
  ;Create the Direct3D device
  *VIS_DCT_D3DDevice.IDirect3DDevice9 = *p\GetD3DDevice9()
  Sprite2D_Init(*VIS_DCT_D3DDevice, 640, 480)
  
  ;Load the Textures
  *VIS_DCT_Texture = CatchD3DTexture9FromImage(*VIS_DCT_D3DDevice, ?DS_VIS_DCT_BT)
  *VIS_DCT_BK_Texture = CatchD3DTexture9FromImage(*VIS_DCT_D3DDevice, ?DS_VIS_DCT_BK)
  
  ;Creates the 2D sprites
  VIS_DCT_Sprite = Sprite2D_Create(*VIS_DCT_Texture)
  VIS_DCT_BK_Sprite = Sprite2D_Create(*VIS_DCT_BK_Texture)
  Sprite2D_Color(VIS_DCT_BK_Sprite, RGBA(255,0,0,255), RGBA(255,0,0,255), RGBA(255,0,0,255), RGBA(255,0,0,255))  
  
  ;Initialize the DCT
  VIS_DCT_dct_init256()
  
  *p\Clear(#Black)
  ProcedureReturn #True
EndProcedure
ProcedureDLL VIS_DCT_Run(*p.IVisualisationCanvas)
  Protected t.i, x.i, i.i, iColor, iWidth, iHeight, c.f, length.i, stepsz.f
  
  ;Sets the screensize
  iWidth=*p\GetWidth()
  iHeight=*p\GetHeight()
  
  If iVIS_DCT_Width <> iWidth Or iVIS_DCT_Height <> iHeight
    *p\Clear(#Black)
  EndIf
  iVIS_DCT_Width = iWidth
  iVIS_DCT_Height = iHeight
  Sprite2D_SetScreenSize(iWidth, iHeight)
  length = (*p\GetSampleSize()-1)
  stepsz = length / 256.0   
  
  
  If *p\CanRender()
    *p\UpdateSample()
    If *p\BeginScene()=#True
      If Sprite2D_Start()
        
        ;Draw the background
        Sprite2D_Zoom(VIS_DCT_BK_Sprite, iWidth, iHeight)
        Sprite2D_DisplayEx(VIS_DCT_BK_Sprite, 0, 0, 20)
        
        ;Use the DCT
        For t=0 To 255
          VIS_DCT_block(t) =  *p\ReadSample(length - Int(stepsz * t))*2
        Next
        VIS_DCT_dct_256()
        For t=0 To 255
          If VIS_DCT_block(t) > 0
            VIS_DCT_block(t) = - VIS_DCT_block(t)
          EndIf     
        Next
        
        ;Draw the Boxes
        Sprite2D_Zoom(VIS_DCT_Sprite,iWidth/25, iHeight/70)
        For x = 0 To 25
          For i=30 To 30-((-VIS_DCT_block(x*10)*20)) Step -1
            c=Abs(i)/30*200
            iColor=RGBA(0, c,255-c, 220)
            Sprite2D_Color(VIS_DCT_Sprite, iColor, iColor, iColor, iColor)
            Sprite2D_DisplayEx(VIS_DCT_Sprite, x*iWidth/25, i*iHeight/70+iHeight*0.55, 220)
          Next
        Next
        
        Sprite2D_Stop()
      EndIf
      *p\EndScene()
    EndIf
  EndIf

EndProcedure


ProcedureDLL VIS_DCT_BeforeReset(*p.IVisualisationCanvas)

EndProcedure
ProcedureDLL VIS_DCT_AfterReset(*p.IVisualisationCanvas)

EndProcedure
ProcedureDLL VIS_DCT_Terminate(*p.IVisualisationCanvas)
  If VIS_DCT_Sprite:Sprite2D_Free(VIS_DCT_Sprite):VIS_DCT_Sprite=#Null:EndIf
  If VIS_DCT_BK_Sprite:Sprite2D_Free(VIS_DCT_BK_Sprite):VIS_DCT_BK_Sprite=#Null:EndIf
  If *VIS_DCT_Texture:*VIS_DCT_Texture\Release():*VIS_DCT_Texture=#Null:EndIf
  If *VIS_DCT_BK_Texture:*VIS_DCT_BK_Texture\Release():*VIS_DCT_BK_Texture=#Null:EndIf
  Sprite2D_Terminate()
EndProcedure

ProcedureDLL VIS_DCT_GetVersion()
  ProcedureReturn #GREENFORCE_PLUGIN_DCT_VERSION
EndProcedure


; IDE Options = PureBasic 4.70 Beta 1 (Windows - x86)
; CursorPosition = 117
; FirstLine = 10
; Folding = Q7
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
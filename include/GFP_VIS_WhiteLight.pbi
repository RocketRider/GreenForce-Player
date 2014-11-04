;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

#GREENFORCE_PLUGIN_WHITELIGHT_VERSION = 100


Global Dim VIS_WhiteLight_K.d(255,255)
Global Dim VIS_WhiteLight_C.d(255)
Global Dim VIS_WhiteLight_block.f(255)
Global Dim VIS_WhiteLight_temp.d(255)
Procedure VIS_WhiteLight_dct_init256() 
  Protected x.i, h.i, i.i
  For x = 0 To 255
    For h = 0 To 255   
      VIS_WhiteLight_K(x,h) = Cos((#PI * h * ((2.0 * x ) + 1.0)) / 512.0);
    Next
  Next

  VIS_WhiteLight_C(0) = (1/Sqr(256))
  For i = 1 To 255
    VIS_WhiteLight_C(i) = 2.0/(Sqr(512))
  Next
EndProcedure
Procedure VIS_WhiteLight_dct_256() 
  Protected x.i, h.i, i.i
  For x=0 To 255 
    VIS_WhiteLight_temp(x) = 0.0
  Next

  For h=0 To 255
    For x=0 To 255
      VIS_WhiteLight_temp(h) + VIS_WhiteLight_block(x) * VIS_WhiteLight_K(x,h)
    Next
    VIS_WhiteLight_temp(h) * (VIS_WhiteLight_C(h));
  Next

  For x=0 To 255
    VIS_WhiteLight_block(x) = VIS_WhiteLight_temp(x);
  Next
  
EndProcedure
Procedure VIS_WhiteLight_idct_256() 
  Protected x.i, h.i, i.i
  For x=0 To 255
    VIS_WhiteLight_temp(x) = 0.0
  Next

    For h=0 To 255
        For x=0 To 255 
          VIS_WhiteLight_temp(x) + VIS_WhiteLight_C(h) * VIS_WhiteLight_block(h) * VIS_WhiteLight_K(x,h)
        Next
  Next

  For x=0 To 255
    VIS_WhiteLight_block(x) = VIS_WhiteLight_temp(x);
  Next
EndProcedure


Global *VIS_WhiteLight_D3DDevice.IDirect3DDevice9
Global VIS_WhiteLight_Sprite.i, VIS_WhiteLight_BK_Sprite.i
Global *VIS_WhiteLight_Texture.IDirect3DTexture9, *VIS_WhiteLight_BK_Texture.IDirect3DTexture9
Global VIS_WhiteLight_LastColor.i
Global iVIS_WhiteLight_Width, iVIS_WhiteLight_Height
Global fGlobalRotation


ProcedureDLL VIS_WhiteLight_Init(*p.IVisualisationCanvas)
  Protected *Tex, *Tex2, iColor.i
  
  ;Create the Direct3D device
  *VIS_WhiteLight_D3DDevice.IDirect3DDevice9 = *p\GetD3DDevice9()
  Sprite2D_Init(*VIS_WhiteLight_D3DDevice, 640, 480)
  
  ;Load the Textures
  *VIS_WhiteLight_Texture = CatchD3DTexture9FromImage(*VIS_WhiteLight_D3DDevice, ?DS_VIS_WhiteLight_WL)
  *VIS_WhiteLight_BK_Texture = CatchD3DTexture9FromImage(*VIS_WhiteLight_D3DDevice, ?DS_VIS_DCT_BK)
  
  ;Creates the 2D sprites
  VIS_WhiteLight_Sprite = Sprite2D_Create(*VIS_WhiteLight_Texture)
  VIS_WhiteLight_BK_Sprite = Sprite2D_Create(*VIS_WhiteLight_BK_Texture)
  Sprite2D_Color(VIS_WhiteLight_BK_Sprite, RGBA(255,0,0,255), RGBA(255,0,0,255), RGBA(255,0,0,255), RGBA(255,0,0,255))  
  
  ;Initialize the DCT
  VIS_WhiteLight_dct_init256()
  
  *p\Clear(#Black)
  ProcedureReturn #True
EndProcedure
ProcedureDLL VIS_WhiteLight_Run(*p.IVisualisationCanvas)
  Protected t.i, x.i, i.i, iColor, iWidth, iHeight, c.f, W, H, Ampl.f, fi,length.i, stepsz.f

  ;Sets the screensize
  iWidth=*p\GetWidth()
  iHeight=*p\GetHeight()
  
  If iVIS_WhiteLight_Width <> iWidth Or iVIS_WhiteLight_Height <> iHeight
    *p\Clear(#Black)
  EndIf
  
  iVIS_WhiteLight_Width = iWidth
  iVIS_WhiteLight_Height = iHeight
  Sprite2D_SetScreenSize(iWidth, iHeight)
  
  length = (*p\GetSampleSize()-1)
  stepsz = length / 256.0    
  
  If *p\CanRender()
    *p\UpdateSample()
    If *p\BeginScene()=#True
      If Sprite2D_Start()
        
        ;Draw the background
        Sprite2D_Zoom(VIS_WhiteLight_BK_Sprite, iWidth, iHeight)
        Sprite2D_DisplayEx(VIS_WhiteLight_BK_Sprite, 0, 0, 10)
        
        ;Use the DCT
        For t=0 To 255
          VIS_WhiteLight_block(t) = *p\ReadSample(length - Int(stepsz * t))*2
        Next
        VIS_WhiteLight_dct_256()
        For t=0 To 255
          If VIS_WhiteLight_block(t) > 0
            Ampl + VIS_WhiteLight_block(t)
          EndIf     
        Next
        Ampl/256
        Ampl*4
        
        ;Draw
        For x = 5 To iWidth/2 Step 20
          For i = 0  To 63 Step 1
            W=Abs(VIS_WhiteLight_block((x+Int(fGlobalRotation/100))%255))*(iWidth*Sqr(x)/1000+Ampl*(300-x)*2)*5
            H=Abs(VIS_WhiteLight_block((x+Int(fGlobalRotation/100))%255))*(iHeight*Sqr(x)/1000+Ampl*(300-x)*2)*5
            ;W=Abs(VIS_WhiteLight_block(i*2))*500
            ;H=Abs(VIS_WhiteLight_block(i*2+100))*500
            
            
            Sprite2D_Zoom(VIS_WhiteLight_Sprite, W, H)
            Sprite2D_DisplayEx(VIS_WhiteLight_Sprite, iWidth/2+Sin(i/10+fGlobalRotation)*x-W/2, iHeight/2+Cos(i/10+fGlobalRotation+fGlobalRotation/1000)*x-H/2, Ampl*x/2+5)
          Next
        Next
        fGlobalRotation+4
  
        
        Sprite2D_Stop()
      EndIf
      *p\EndScene()
    EndIf
  EndIf

EndProcedure


ProcedureDLL VIS_WhiteLight_BeforeReset(*p.IVisualisationCanvas)

EndProcedure
ProcedureDLL VIS_WhiteLight_AfterReset(*p.IVisualisationCanvas)

EndProcedure
ProcedureDLL VIS_WhiteLight_Terminate(*p.IVisualisationCanvas)
  If VIS_WhiteLight_Sprite:Sprite2D_Free(VIS_WhiteLight_Sprite):VIS_WhiteLight_Sprite=#Null:EndIf
  If VIS_WhiteLight_BK_Sprite:Sprite2D_Free(VIS_WhiteLight_BK_Sprite):VIS_WhiteLight_BK_Sprite=#Null:EndIf;2010-04-11 Sprites zu erst freigeben
  If *VIS_WhiteLight_Texture:*VIS_WhiteLight_Texture\Release():*VIS_WhiteLight_Texture=#Null:EndIf
  If *VIS_WhiteLight_BK_Texture:*VIS_WhiteLight_BK_Texture\Release():*VIS_WhiteLight_BK_Texture=#Null:EndIf
  Sprite2D_Terminate()
EndProcedure

ProcedureDLL VIS_WhiteLight_GetVersion()
  ProcedureReturn #GREENFORCE_PLUGIN_WHITELIGHT_VERSION
EndProcedure


; IDE Options = PureBasic 4.70 Beta 1 (Windows - x86)
; CursorPosition = 130
; FirstLine = 22
; Folding = Q7
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
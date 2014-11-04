;************************************************************
;*** GreenForce Player *** Visualization Interaktiv System **
;*** http://GFP.RRSoftware.de ********************* Sample **
;*** (c) 2009 - 2010 RocketRider ****************************
;*** zlib Licence *******************************************
;************************************************************
XIncludeFile "../GFP_VIS_Include.pbi"


#GREENFORCE_PLUGIN_VERSION = 100
Global *D3DDevice.IDirect3DDevice9
Global Sprite.i, BK_Sprite.i
Global *Texture.IDirect3DTexture9, *BK_Texture.IDirect3DTexture9
Global LastColor.i
Global fGlobalRotation



Global Dim K.d(255,255)
Global Dim C.d(255)
Global Dim block.f(255)
Global Dim temp.d(255)
Procedure dct_init256() 
  Protected x.i, h.i, i.i
  For x = 0 To 255
    For h = 0 To 255   
      K(x,h) = Cos((#PI * h * ((2.0 * x ) + 1.0)) / 512.0);
    Next
  Next

  C(0) = (1/Sqr(256))
  For i = 1 To 255
    C(i) = 2.0/(Sqr(512))
  Next
EndProcedure
Procedure dct_256() 
  Protected x.i, h.i, i.i
  For x=0 To 255 
    temp(x) = 0.0
  Next

  For h=0 To 255
    For x=0 To 255
      temp(h) + block(x) * K(x,h)
    Next
    temp(h) * (C(h));
  Next

  For x=0 To 255
    block(x) = temp(x);
  Next
  
EndProcedure
Procedure idct_256() 
  Protected x.i, h.i, i.i
  For x=0 To 255
    temp(x) = 0.0
  Next

    For h=0 To 255
        For x=0 To 255 
          temp(x) + C(h) * block(h) * K(x,h)
        Next
  Next

  For x=0 To 255
    block(x) = temp(x);
  Next
EndProcedure




ProcedureDLL Init(*p.IVisualisationCanvas)
  Protected *Tex, *Tex2, iColor.i
  
  ;Create the Direct3D device
  *D3DDevice.IDirect3DDevice9 = *p\GetD3DDevice9()
  Sprite2D_Init(*D3DDevice, 640, 480)
  
  ;Load the Textures
  UsePNGImageDecoder()
  *Texture = CatchD3DTexture9FromImage(*D3DDevice, ?DS_WL)
  *BK_Texture = CatchD3DTexture9FromImage(*D3DDevice, ?DS_BK)
  
  ;Creates the 2D sprites
  Sprite = Sprite2D_Create(*Tex)
  BK_Sprite = Sprite2D_Create(*Tex2)
  Sprite2D_Color(BK_Sprite, RGBA(255,0,0,255), RGBA(255,0,0,255), RGBA(255,0,0,255), RGBA(255,0,0,255))  
  
  ;Initialize the DCT
  dct_init256()
  
  *p\Clear(#Black)
  ProcedureReturn #True
EndProcedure
ProcedureDLL Run(*p.IVisualisationCanvas)
  Protected t.i, x.i, i.i, iColor, iWidth, iHeight, c.f, W, H, Ampl.f, fi

  ;Sets the screensize
  iWidth=*p\GetWidth()
  iHeight=*p\GetHeight()
  Sprite2D_SetScreenSize(iWidth, iHeight)
  
  If *p\CanRender()
    *p\UpdateSample()
    *p\BeginScene()
      Sprite2D_Start()
      
      ;Draw the background
      Sprite2D_Zoom(BK_Sprite, iWidth, iHeight)
      Sprite2D_DisplayEx(BK_Sprite, 0, 0, 10)
      
      ;Use the DCT
      For t=0 To 255
        block(t) = *p\ReadSample(t*32)
      Next
      dct_256()
      For t=0 To 255
        If block(t) > 0
          Ampl + block(t)
        EndIf     
      Next
      Ampl/256
      
      ;Draw
      For x = 5 To iWidth/2 Step 20
        For i = 0  To 63 Step 1
          W=iWidth*Sqr(x)/1000+Ampl*(300-x)*2
          H=iHeight*Sqr(x)/1000+Ampl*(300-x)*2
          Sprite2D_Zoom(Sprite, W, H)
          Sprite2D_DisplayEx(Sprite, iWidth/2+Sin(i/10+fGlobalRotation)*x-W/2, iHeight/2+Cos(i/10+fGlobalRotation+fGlobalRotation/1000)*x-H/2, x/2)
        Next
      Next
      fGlobalRotation+4

      
      Sprite2D_Stop()
    *p\EndScene()
  EndIf

EndProcedure



ProcedureDLL BeforeReset(*p.IVisualisationCanvas)

EndProcedure
ProcedureDLL AfterReset(*p.IVisualisationCanvas)

EndProcedure
ProcedureDLL Terminate(*p.IVisualisationCanvas)
  If Sprite:Sprite2D_Free(Sprite):Sprite=#Null:EndIf
  If BK_Sprite:Sprite2D_Free(BK_Sprite):BK_Sprite=#Null:EndIf  
  If *Texture:*Texture\Release():*Texture=#Null:EndIf
  If *BK_Texture:*BK_Texture\Release():*BK_Texture=#Null:EndIf
EndProcedure
ProcedureDLL GetVersion()
  ProcedureReturn #GREENFORCE_PLUGIN_VERSION
EndProcedure



DataSection
  DS_BK: IncludeBinary "bk.png"
  DS_WL: IncludeBinary "Particle.png"
EndDataSection

; IDE Options = PureBasic 4.50 Beta 2 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 155
; Folding = A7
; EnableXP
; EnableUser
; Executable = Whitelight-Sample.vis-dll
; EnableCompileCount = 17
; EnableBuildCount = 13
; EnableExeConstant
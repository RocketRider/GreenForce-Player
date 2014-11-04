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

Global Dim DCT_K.d(255,255)
Global Dim DCT_C.d(255)
Global Dim DCT_block.f(255)
Global Dim DCT_temp.d(255)
Procedure dct_init256() 
  Protected x.i, h.i, i.i
  For x = 0 To 255
    For h = 0 To 255   
      DCT_K(x,h) = Cos((#PI * h * ((2.0 * x ) + 1.0)) / 512.0);
    Next
  Next

  DCT_C(0) = (1/Sqr(256))
  For i = 1 To 255
    DCT_C(i) = 2.0/(Sqr(512))
  Next
EndProcedure
Procedure dct_256() 
  Protected x.i, h.i, i.i
  For x=0 To 255 
    DCT_temp(x) = 0.0
  Next

  For h=0 To 255
    For x=0 To 255
      DCT_temp(h) + DCT_block(x) * DCT_K(x,h)
    Next
    DCT_temp(h) * (DCT_C(h));
  Next

  For x=0 To 255
    DCT_block(x) = DCT_temp(x);
  Next
  
EndProcedure
Procedure idct_256() 
  Protected x.i, h.i, i.i
  For x=0 To 255
    DCT_temp(x) = 0.0
  Next

    For h=0 To 255
        For x=0 To 255 
          DCT_temp(x) + DCT_C(h) * DCT_block(h) * DCT_K(x,h)
        Next
  Next

  For x=0 To 255
    DCT_block(x) = DCT_temp(x);
  Next
EndProcedure




ProcedureDLL Init(*p.IVisualisationCanvas)
  Protected *Tex, *Tex2, iColor.i
  
  ;Create the Direct3D device
  *D3DDevice.IDirect3DDevice9 = *p\GetD3DDevice9()
  Sprite2D_Init(*D3DDevice, 640, 480)
  
  ;Load the Textures
  UsePNGImageDecoder()
  *Texture = CatchD3DTexture9FromImage(*D3DDevice, ?DS_BT)
  *BK_Texture = CatchD3DTexture9FromImage(*D3DDevice, ?DS_BK)

  ;Creates the 2D sprites
  Sprite = Sprite2D_Create(*Texture)
  BK_Sprite = Sprite2D_Create(*BK_Texture)
  Sprite2D_Color(BK_Sprite, RGBA(255, 40, 40, 255), RGBA(355, 40, 40, 255), RGBA(40, 40, 200, 255), RGBA(40, 40, 200, 255))  
  
  ;Initialize the DCT
  dct_init256()
  *p\Clear(#Black)
  ProcedureReturn #True
EndProcedure
ProcedureDLL Run(*p.IVisualisationCanvas)
  Protected t.i, x.i, i.i, iColor, iWidth, iHeight, c.f
  
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
      Sprite2D_DisplayEx(BK_Sprite, 0, 0, 20)
      
      ;Use the DCT
      For t=0 To 255
        DCT_block(t) = *p\ReadSample(t*32)
      Next
      dct_256()
      For t=0 To 255
        If DCT_block(t) > 0
          DCT_block(t) = - DCT_block(t)
        EndIf     
      Next
      
      ;Draw the Boxes
      Sprite2D_Zoom(Sprite,iWidth/25, iHeight/70)
      For x = 0 To 25
        For i=30 To 30-((-DCT_block(x*10)*20)) Step -1
          c=Abs(i)/30*200
          iColor=RGBA(0, c,255-c, 220)
          Sprite2D_Color(Sprite, iColor, iColor, iColor, iColor)
          Sprite2D_DisplayEx(Sprite, x*iWidth/25, i*iHeight/70+iHeight*0.55, 220)
        Next
      Next
      
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
  DS_BT: IncludeBinary "Button.png"
EndDataSection



; IDE Options = PureBasic 4.50 Beta 2 (Windows - x86)
; ExecutableFormat = Shared Dll
; CursorPosition = 147
; FirstLine = 3
; Folding = A7
; EnableXP
; EnableUser
; Executable = DCT-Sample.vis-dll
; EnableCompileCount = 28
; EnableBuildCount = 21
; EnableExeConstant
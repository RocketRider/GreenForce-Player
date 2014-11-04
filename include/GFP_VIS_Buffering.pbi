;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

#GREENFORCE_PLUGIN_BUFFERING_VERSION = 100



Global *VIS_Buffering_D3DDevice.IDirect3DDevice9
Global VIS_Buffering_BK_Sprite.i, VIS_Buffering_Progress_Sprite.i, VIS_Buffering_Progress2_Sprite.i
Global *VIS_Buffering_BK_Texture.IDirect3DTexture9, *VIS_Buffering_Progress_Texture.IDirect3DTexture9, *VIS_Buffering_Progress2_Texture.IDirect3DTexture9
Global iVIS_Buffering_Width, iVIS_Buffering_Height
Global *VIS_Buffering_Font.Sprite2D_Font
Global VIS_Buffering_Counter.i
Global VIS_Buffering_Range.f
Global VIS_Buffering_Percent.f
Global VIS_Buffering_OldText.s
Global Dim VIS_Buffering_Alpha.f(11)

;It must be a value between 0 and 1
ProcedureDLL VIS_Buffering_SetPercent(Percent.f)
  VIS_Buffering_Percent=Percent
EndProcedure  

ProcedureDLL VIS_Buffering_Init(*p.IVisualisationCanvas)
  DisableGadget(#GADGET_TRACKBAR, #True)
  ;Create the Direct3D device
  *VIS_Buffering_D3DDevice.IDirect3DDevice9 = *p\GetD3DDevice9()
  Sprite2D_Init(*VIS_Buffering_D3DDevice, 640, 480)
  
  ;Load the Textures
  *VIS_Buffering_BK_Texture = CatchD3DTexture9FromImage(*VIS_Buffering_D3DDevice, ?DS_VIS_DCT_BK)
  *VIS_Buffering_Progress_Texture = CatchD3DTexture9FromImage(*VIS_Buffering_D3DDevice, ?DS_VIS_B_Progress)
  *VIS_Buffering_Progress2_Texture = CatchD3DTexture9FromImage(*VIS_Buffering_D3DDevice, ?DS_VIS_B_Progress_2)

  
  ;Creates the 2D sprites
  VIS_Buffering_BK_Sprite = Sprite2D_Create(*VIS_Buffering_BK_Texture)
  Sprite2D_Color(VIS_Buffering_BK_Sprite, RGBA(155,50,50,255), RGBA(155,50,50,255), RGBA(155,50,50,255), RGBA(155,50,50,255))  
  VIS_Buffering_Progress_Sprite = Sprite2D_Create(*VIS_Buffering_Progress_Texture)
  VIS_Buffering_Progress2_Sprite = Sprite2D_Create(*VIS_Buffering_Progress2_Texture)
  
  *VIS_Buffering_Font = Sprite2D_CatchFont(*VIS_Buffering_D3DDevice, ?DS_Sprite2D_Font)
  
  VIS_Buffering_Range=150
  VIS_Buffering_Counter=0
  VIS_Buffering_Percent=0
  VIS_Buffering_OldText=""
  *p\Clear(#Black)
  ProcedureReturn #True
EndProcedure
ProcedureDLL VIS_Buffering_Run(*p.IVisualisationCanvas)
  Protected t.i, x.i, i.i, iColor, iWidth, iHeight, c.f, angle.f, alpha.f, Img.i, sText.s, Orgtext.s, scale.f
  
  
  
  ;Sets the screensize
  iWidth=*p\GetWidth()
  iHeight=*p\GetHeight()
  
  ;If iVIS_Buffering_Width <> iWidth Or iVIS_Buffering_Height <> iHeight
    *p\Clear(RGBA(128,128,128,255))
  ;EndIf
  iVIS_Buffering_Width = iWidth
  iVIS_Buffering_Height = iHeight
  Sprite2D_SetScreenSize(iWidth, iHeight)
  scale=iHeight/480
  If scale>1.2:scale=1.2:EndIf
  
  If *p\CanRender()
    ;*p\UpdateSample()
    If *p\BeginScene()=#True
      If Sprite2D_Start()
        VIS_Buffering_Counter+1
        ;Draw Background:
        Sprite2D_Zoom(VIS_Buffering_BK_Sprite, iWidth, iHeight)
        Sprite2D_DisplayEx(VIS_Buffering_BK_Sprite, 0, 0, 150+Sin(VIS_Buffering_Counter/100)*50)
        
        
        For i=0 To 10
          VIS_Buffering_Range+Sin(VIS_Buffering_Counter/10+i)/10
          angle.f=i
          angle/11
          ;alpha.f=150+Pow(Sin(VIS_Buffering_Counter/10+i),11)*100
          t=VIS_Buffering_Counter/30
          If i=t%11
            VIS_Buffering_Alpha(i)=VIS_Buffering_Alpha(i)+4
          Else
            VIS_Buffering_Alpha(i)=VIS_Buffering_Alpha(i)-1
          EndIf
          If VIS_Buffering_Alpha(i)<100:VIS_Buffering_Alpha(i)=100:EndIf
          If VIS_Buffering_Alpha(i)>255:VIS_Buffering_Alpha(i)=255:EndIf
          If VIS_Buffering_Percent*11>i
            Img=VIS_Buffering_Progress2_Sprite
          Else
            Img=VIS_Buffering_Progress_Sprite
          EndIf  
          Sprite2D_Zoom(Img, 128*scale, 128*scale)
          Sprite2D_Rotate(Img, -angle*360+180, #False)
          Sprite2D_DisplayEx(Img, iWidth/2+Sin(angle*2*#PI)*VIS_Buffering_Range*scale-64*scale, iHeight/2+Cos(angle*2*#PI)*VIS_Buffering_Range*scale-64*scale, VIS_Buffering_Alpha(i))
        Next  
        sText=Language(#L_DATA_BUFFERING)
        Orgtext=sText
        t=VIS_Buffering_Counter/50
        t=t%4
        For i=1 To t
          sText+"."
        Next  
        If scale<0.3:scale=0.3:EndIf
        Sprite2D_DrawFont(*VIS_Buffering_Font, (iWidth-Sprite2D_TextLenght(*VIS_Buffering_Font, Orgtext,10*scale))/2, iHeight-50*scale, sText, RGBA(255,255,255,255), 10*scale)
        
        If VIS_Buffering_OldText<>sText
          StatusBarText(#STATUSBAR_MAIN, 0, sText)
          VIS_Buffering_OldText=sText
        EndIf  
        
        Sprite2D_Stop()
      EndIf
      *p\EndScene()
    EndIf
  EndIf

EndProcedure


ProcedureDLL VIS_Buffering_BeforeReset(*p.IVisualisationCanvas)

EndProcedure
ProcedureDLL VIS_Buffering_AfterReset(*p.IVisualisationCanvas)

EndProcedure
ProcedureDLL VIS_Buffering_Terminate(*p.IVisualisationCanvas)
  Sprite2D_FreeFont(*VIS_Buffering_Font)
  
  If VIS_Buffering_Progress_Sprite:Sprite2D_Free(VIS_Buffering_Progress_Sprite):VIS_Buffering_Progress_Sprite=#Null:EndIf
  If VIS_Buffering_Progress2_Sprite:Sprite2D_Free(VIS_Buffering_Progress2_Sprite):VIS_Buffering_Progress2_Sprite=#Null:EndIf
  If VIS_Buffering_BK_Sprite:Sprite2D_Free(VIS_Buffering_BK_Sprite):VIS_Buffering_BK_Sprite=#Null:EndIf
  
  If *VIS_Buffering_Progress_Texture:*VIS_Buffering_Progress_Texture\Release():*VIS_Buffering_Progress_Texture=#Null:EndIf
  If *VIS_Buffering_Progress2_Texture:*VIS_Buffering_Progress2_Texture\Release():*VIS_Buffering_Progress2_Texture=#Null:EndIf
  If *VIS_Buffering_BK_Texture:*VIS_Buffering_BK_Texture\Release():*VIS_Buffering_BK_Texture=#Null:EndIf
  Sprite2D_Terminate()
EndProcedure

ProcedureDLL VIS_Buffering_GetVersion()
  ProcedureReturn #GREENFORCE_PLUGIN_BUFFERING_VERSION
EndProcedure


; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = G+
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
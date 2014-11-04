;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit


Structure Sprite2D_Font
  *Texture.IDirect3DTexture9
  Sprite.i
  X.i
  Y.i
  BWidth.i
  BHeight.i
  DWidth.i
EndStructure


Procedure Sprite2D_CatchFont(*D3DDevice.IDirect3DDevice9, Memory)
  Protected *Sprite2D_Font.Sprite2D_Font, Result
  If *D3DDevice And Memory
    *Sprite2D_Font=AllocateMemory(SizeOf(Sprite2D_Font))
    If *Sprite2D_Font
      *Sprite2D_Font\X = 20
      *Sprite2D_Font\Y = 20
      *Sprite2D_Font\BWidth = 60
      *Sprite2D_Font\BHeight = 62
      *Sprite2D_Font\DWidth = 40
      
      *Sprite2D_Font\Texture = CatchD3DTexture9FromImage(*D3DDevice, Memory)
      If *Sprite2D_Font\Texture
        *Sprite2D_Font\Sprite = Sprite2D_Create(*Sprite2D_Font\Texture)
        If *Sprite2D_Font\Sprite
          Result=#True
        EndIf
      EndIf
      
      If Result
        ProcedureReturn *Sprite2D_Font
      Else
        FreeMemory(*Sprite2D_Font)
        *Sprite2D_Font=#Null
      EndIf 
    EndIf
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure Sprite2D_FreeFont(*Sprite2D_Font.Sprite2D_Font)
  If *Sprite2D_Font
    If *Sprite2D_Font\Sprite:Sprite2D_Free(*Sprite2D_Font\Sprite):*Sprite2D_Font\Sprite=#Null:EndIf
    If *Sprite2D_Font\Texture:*Sprite2D_Font\Texture\Release():*Sprite2D_Font\Texture=#Null:EndIf
    FreeMemory(*Sprite2D_Font)
    *Sprite2D_Font=#Null
  EndIf
EndProcedure

Procedure Sprite2D_DrawFont(*Sprite2D_Font.Sprite2D_Font, x, y, Text.s, Color, Size.f=20)
  Protected i.i, Asc.i
  If *Sprite2D_Font And Text
    For i=1 To Len(Text)
      Asc=Asc(Mid(Text, i, 1))
      Sprite2D_Clip(*Sprite2D_Font\Sprite, *Sprite2D_Font\X+(Asc%17 * *Sprite2D_Font\BWidth), *Sprite2D_Font\Y+Int(Asc/17) * *Sprite2D_Font\BHeight, *Sprite2D_Font\BWidth-3, *Sprite2D_Font\BHeight-3)
      Sprite2D_Zoom(*Sprite2D_Font\Sprite, *Sprite2D_Font\BWidth*Size/20, *Sprite2D_Font\BHeight*Size/20)
      Sprite2D_Color(*Sprite2D_Font\Sprite, Color, Color, Color, Color)  
      
      Sprite2D_DisplayEx(*Sprite2D_Font\Sprite, x+i* *Sprite2D_Font\DWidth*Size/20, y, Alpha(Color))
    Next
  EndIf
EndProcedure

Procedure.f Sprite2D_TextLenght(*Sprite2D_Font.Sprite2D_Font, Text.s, Size.f=20)
  If *Sprite2D_Font And Text
    ProcedureReturn (Len(Text)+2)* *Sprite2D_Font\DWidth*Size/20
  EndIf
EndProcedure


ProcedureDLL Sprite2DHelper_TransformHorizontal(*ptr.DX9Sprite3D,x1.f,y1.f,x2.f,y2.f,x3.f,y3.f,x4.f,y4.f)
 Protected r1.f = 1.0, r2.f = 1.0, r3.f = 1.0, r4.f = 1.0, ymin.f,ymax.f,height.f
 
  ymin.f = y1
  If y2 < ymin
    ymin = y2  
  EndIf
  
  ymax.f = y3
  If y4 > ymax
    ymax = y4  
  EndIf
  
  height.f = ymax-ymin
  
  If height <> 0
    r1.f =  1.0/((1.0-(y1-ymin)*2/height))
    r2.f =  1.0/((1.0-(y2-ymin)*2/height))
    r3.f =  1.0/((1.0-(ymax-y3)*2/height))
    r4.f =  1.0/((1.0-(ymax-y4)*2/height))
  EndIf
  
  If r1 = 0
    r1 = 1.0
  EndIf
  If r2 = 0
    r2 = 1.0
  EndIf  
  If r3 = 0
    r3 = 1.0
  EndIf    
  If r4 = 0
    r4 = 1.0
  EndIf
  
 ProcedureReturn Sprite2D_TransformEx(*ptr,x1.f,y1.f,r1,  x2.f,y2.f,r2,    x3.f,y3.f,r3, x4.f,y4.f,r4)
EndProcedure


; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = v
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
Global VOLUME_IMAGE_BK = #SPRITE_VOLUME_BK
Global VOLUME_IMAGE_FORE = #SPRITE_VOLUME_FORCE
Global VOLUME_FONT=-1
#VOLUME_USE_FONT = #True

; Procedure __LoadVolumeImages()
;   VOLUME_IMAGE_BK   = LoadImage(#PB_Any,"volume2.png")
;   VOLUME_IMAGE_FORE = LoadImage(#PB_Any,"volume4.png")
; EndProcedure  

Procedure __CreateClippedVolumeImage(src_img, start_x, width, bkColor) 
  Protected dest_img
  If width > 0 And start_x >= 0
    dest_img = CreateImage(#PB_Any, width, ImageHeight(VOLUME_IMAGE_BK))
    If IsImage(dest_img) And IsImage(src_img)
      If StartDrawing(ImageOutput(dest_img))
        DrawingMode(#PB_2DDrawing_Default)
        Box(0,0,width, ImageHeight(VOLUME_IMAGE_BK), bkColor)  
        DrawAlphaImage(ImageID(src_img), - start_x, 0)
        StopDrawing()
      EndIf
    EndIf
  EndIf
  ProcedureReturn dest_img
EndProcedure  

Procedure CreateVolumeGadget(ID, x,y)
;   If Not IsImage(VOLUME_IMAGE_BK)
;     __LoadVolumeImages()
;   EndIf  
If #VOLUME_USE_FONT And VOLUME_FONT=-1 And IsFont(VOLUME_FONT)=0
  VOLUME_FONT=LoadFont(#PB_Any, "Arial", 7)
EndIf  


  ProcedureReturn CanvasGadget(ID, x, y, ImageWidth(VOLUME_IMAGE_BK), ImageHeight(VOLUME_IMAGE_BK))
EndProcedure  

Procedure UpdateVolumeGadget(ID, bkColor, pos.f)
  Protected tmpLeft,tmpRight
  If pos < 0:pos = 0:EndIf
  If pos > ImageWidth(VOLUME_IMAGE_BK):pos = ImageWidth(VOLUME_IMAGE_BK):EndIf
  tmpLeft = __CreateClippedVolumeImage(VOLUME_IMAGE_FORE, 0, pos, bkColor) 
  tmpRight = __CreateClippedVolumeImage(VOLUME_IMAGE_BK, pos, ImageWidth(VOLUME_IMAGE_BK) - pos, bkColor) 
    
  If StartDrawing(CanvasOutput(ID))

    If IsImage(tmpLeft):DrawImage(ImageID(tmpLeft),0,0) :EndIf   
    If IsImage(tmpRight):DrawImage(ImageID(tmpRight),pos,0):EndIf 
    If #VOLUME_USE_FONT And VOLUME_FONT<>-1 And IsFont(VOLUME_FONT)
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawingFont(FontID(VOLUME_FONT)) 
      DrawText(41, 13,Str(pos*10/7)+"%",RGB(0,0,0))
    EndIf
    StopDrawing()
  EndIf
  If IsImage(tmpLeft):FreeImage(tmpLeft):EndIf   
  If IsImage(tmpRight):FreeImage(tmpRight):EndIf     
EndProcedure  

Procedure FreeVolumeGadgetRessources()
  If IsImage(VOLUME_IMAGE_FORE):FreeImage(VOLUME_IMAGE_FORE):VOLUME_IMAGE_FORE = -1:EndIf
  If IsImage(VOLUME_IMAGE_BK):FreeImage(VOLUME_IMAGE_BK):VOLUME_IMAGE_BK = -1:EndIf
EndProcedure  


; 
; UsePNGImageDecoder()
; If OpenWindow(0, 100, 100, 500, 300, "PureBasic - Image")
; 
;   SetWindowColor(0,RGB(255,255,255))
;   CreateVolumeGadget(0, 55,55)
;   UpdateVolumeGadget(0, RGBA(255,255,255,255), 50)
 
;   Repeat
;   Event = WaitWindowEvent() 
;   If Event = #PB_Event_Gadget And EventGadget() = 0 
;     If EventType() = #PB_EventType_LeftButtonDown Or (EventType() = #PB_EventType_MouseMove And GetGadgetAttribute(0, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
;        UpdateVolumeGadget(0, RGBA(255,255,255,255), GetGadgetAttribute(0, #PB_Canvas_MouseX))
;     EndIf
;    EndIf    
;       
;    Until Event = #PB_Event_CloseWindow
;  EndIf


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 73
; FirstLine = 32
; Folding = -
; EnableXP
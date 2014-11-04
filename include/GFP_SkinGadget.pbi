;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
;****************************
;***   Advanced Gadgets   ***
;***    Licence:  Zlib    ***
;****************************
;*** (c) 2011 RocketRider ***
;***    RocketRider.eu    ***
;****************************
;***    PureBasic 4.51    ***
;***      03.03.2011      ***
;****************************
;Copyright (c) 2009 RocketRider
;This software is provided 'as-is', without any express Or implied warranty. In no event will the authors be held liable For any damages arising from the use of this software.
;Permission is granted To anyone To use this software For any purpose, including commercial applications, And To alter it And redistribute it freely, subject To the following restrictions:
;The origin of this software must Not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
;Altered source versions must be plainly marked As such, And must Not be misrepresented As being the original software.
;This notice may Not be removed Or altered from any source distribution.
EnableExplicit

Procedure RenderhWndGammaCorrection(hWnd, RedGamma, GreenGamma, BlueGamma, Colorfullness, Tint, Brightness, Contrast, Invert)
  Protected lResult = #False, DC, re.rect, MemDC, hBmp, lastBmp, C.COLORADJUSTMENT
  If RedGamma < 2500:RedGamma = 2500:EndIf
  If RedGamma > 65000:RedGamma = 65000:EndIf
  
  If GreenGamma < 2500:GreenGamma = 2500:EndIf
  If GreenGamma > 65000:GreenGamma = 65000:EndIf
  
  If BlueGamma < 2500:BlueGamma = 2500:EndIf
  If BlueGamma > 65000:BlueGamma = 65000:EndIf
  
  If Colorfullness < -100:Colorfullness = -100:EndIf
  If Colorfullness >  100:Colorfullness =  100:EndIf
  
  If Brightness < -100:Brightness = -100:EndIf
  If Brightness >  100:Brightness =  100:EndIf
  
  If Contrast < -100:Contrast = -100:EndIf
  If Contrast >  100:Contrast =  100:EndIf
  
  If Tint < -100:Tint = -100:EndIf
  If Tint >  100:Tint =  100:EndIf    
  
  If IsWindow_(hWnd)
    DC = GetWindowDC_(hWnd) 
    If DC
      GetWindowRect_(hWnd, re.rect)   
      MemDC = CreateCompatibleDC_(DC)
      If MemDC
        hBmp = CreateCompatibleBitmap_(DC, re\right - re\left,re\bottom - re\top)
        If hBmp
          lastBmp = SelectObject_(MemDC, hBmp)
          SendMessage_(hWnd, #WM_PRINTCLIENT, MemDC, #PRF_OWNED)                
          SetStretchBltMode_(DC, #HALFTONE)
          GetColorAdjustment_(DC, C.COLORADJUSTMENT)
          C\caRedGamma   = RedGamma
          C\caGreenGamma = GreenGamma
          C\caBlueGamma  = BlueGamma
          
          C\caColorfulness = Colorfullness
          C\caBrightness   = Brightness
          C\caContrast     = Contrast
          C\caRedGreenTint = Tint
          If Invert
            c\caFlags = #CA_NEGATIVE
          EndIf
          SetColorAdjustment_(DC, C.COLORADJUSTMENT)
          
          StretchBlt_(DC, 0, 0, re\right - re\left, re\bottom - re\top, MemDC, 0, 0, re\right - re\left, re\bottom - re\top, #SRCCOPY)
          SelectObject_(MemDC, lastBmp)
          lResult = #True
        EndIf  
      EndIf
      ReleaseDC_(hWnd, DC)
    EndIf
    
    If MemDC
      DeleteDC_(MemDC)
    EndIf
    If hBmp
      DeleteObject_(hBmp)   
    EndIf     
  EndIf
  ProcedureReturn lResult   
EndProcedure

Procedure AdvGadgetCB(hWnd, Msg, w, l) 
  Protected CB.l, Result
  CB.l = GetProp_(hWnd, "ADVGADGET_CALLBACK")
  If CB
    If Msg = #WM_DESTROY
      SetProp_(hWnd, "ADVGADGET_CALLBACK", #Null)
      RemoveProp_(hWnd, "ADVGADGET_CALLBACK")
      RemoveProp_(hWnd, "ADVGADGET_GAMMARED")
      RemoveProp_(hWnd, "ADVGADGET_GAMMAGREEN")
      RemoveProp_(hWnd, "ADVGADGET_GAMMABLUE")
      RemoveProp_(hWnd, "ADVGADGET_COLOR")
      RemoveProp_(hWnd, "ADVGADGET_BRIGHTNESS")
      RemoveProp_(hWnd, "ADVGADGET_CONTRAST")
      RemoveProp_(hWnd, "ADVGADGET_TINT")       
      RemoveProp_(hWnd, "ADVGADGET_INVERT")            
    EndIf 
    
    If Msg<>#WM_PAINT
      Result = CallFunctionFast(CB, hWnd, Msg, w, l)       
    Else       
      Result = DefWindowProc_(hWnd, Msg, w, l)  
    EndIf 
    
    If Msg = #WM_PAINT Or Msg = #WM_LBUTTONDOWN Or Msg = #WM_LBUTTONUP Or Msg = #WM_LBUTTONDBLCLK
      RenderhWndGammaCorrection(hWnd, GetProp_(hWnd, "ADVGADGET_GAMMARED"), GetProp_(hWnd, "ADVGADGET_GAMMAGREEN"), GetProp_(hWnd, "ADVGADGET_GAMMABLUE"), GetProp_(hWnd, "ADVGADGET_COLOR"), GetProp_(hWnd, "ADVGADGET_TINT"), GetProp_(hWnd, "ADVGADGET_BRIGHTNESS"), GetProp_(hWnd, "ADVGADGET_CONTRAST"), GetProp_(hWnd, "ADVGADGET_INVERT"))
    EndIf      
  Else  
    Result = DefWindowProc_(hWnd, Msg, w, l)
  EndIf 
  ProcedureReturn Result
EndProcedure

Procedure TintGadget(Gadget, RedGamma = 10000, GreenGamma = 10000, BlueGamma = 10000, Colorfullness = 0, Tint = 0, Brightness = 0, Contrast = 0, Invert=#False)
  Protected hWnd
  If IsGadget(Gadget)
    hWnd = GadgetID(Gadget)
    If GetProp_(hWnd, "ADVGADGET_CALLBACK") = #Null
      SetProp_(hWnd, "ADVGADGET_CALLBACK", SetWindowLong_(hWnd, #GWL_WNDPROC, @AdvGadgetCB()))
    EndIf  
    SetProp_(hWnd, "ADVGADGET_GAMMARED", RedGamma)
    SetProp_(hWnd, "ADVGADGET_GAMMAGREEN", GreenGamma)
    SetProp_(hWnd, "ADVGADGET_GAMMABLUE", BlueGamma)
    SetProp_(hWnd, "ADVGADGET_COLOR", Colorfullness)
    SetProp_(hWnd, "ADVGADGET_BRIGHTNESS", Brightness)
    SetProp_(hWnd, "ADVGADGET_CONTRAST", Contrast)
    SetProp_(hWnd, "ADVGADGET_TINT", Tint)      
    SetProp_(hWnd, "ADVGADGET_INVERT", Invert)            
    RedrawWindow_(hWnd,0,0,#RDW_INVALIDATE) 
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

;{ Sample
; ;Exable XP Skin support!
; If OpenWindow(0, 0, 0, 500, 500, "AdvGadgets", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
;   
;   ;blue button
;   ButtonGadget(1, 10, 40, 100, 22, "Next", #PB_Button_Default|#BS_DEFPUSHBUTTON )
;   
;   ;red button
;   ButtonGadget(2, 110, 40, 100, 22, "Prev", #PB_Button_Default)
;   
;   ;another silver button
;   ButtonGadget(4, 10, 100, 100, 22, "Silver Button", #PB_Button_Default)
;   
;   ;green button
;   ButtonGadget(3, 10, 130, 100, 22, "green Button", #PB_Button_Default)
;   
;   ProgressBarGadget(5, 30,200, 440, 5, 0, 100)
;   
;   ProgressBarGadget(6, 250, 40, 200, 20, 0, 100,0)
;   SetGadgetState(6, 44)
;   ComboBoxGadget  (77,  10, 342, 250,  20 )
;   
;   AddGadgetItem(77, -1, "ComboBox editable...")
;   SetWindowColor(0,RGB(33,33,33))
;   
;   TintGadget(1,2000,2000,60000,-100,0,-80,0)
;   TintGadget(2,2000,2000,60000,-100,0,-80,0)
;   TintGadget(3,2000,2000,60000,-100,0,-80,0)
;   TintGadget(4,2000,2000,60000,-100,0,-80,0)
;   TintGadget(5,2000,2000,60000,-100,0,-80,0)
;   
;   TintGadget(1,10000,10000,10000,-100,0,0,0, #True)
;   TintGadget(2,10000,10000,10000,-100,0,0,0, #True)
;   TintGadget(3,10000,10000,10000,0,-100,0,0, #True)
;   TintGadget(4,10000,10000,10000,-100,0,0,0, #True)
;   TintGadget(5,10000,10000,10000,-100,0,0,0, #True)
;   
;   
;   TintGadget(1,2000,60000,2000,0,-100,0,0, #True)
;   TintGadget(2,10000,10000,2000,-100,0,0,0, #False)
;   TintGadget(3,10000,10000,2000,0,-100,0,0, #False)
;   TintGadget(4,10000,10000,2000,-100,0,0,0, #False)
;   TintGadget(5,10000,10000,2000,-100,0,0,0, #False)
;   
;   
;   StringGadget(550, 228, 228, 206, 103,"", #PB_String_BorderLess| #ES_MULTILINE)
;   HyperLinkGadget(88,9,300,100,25,"HELLO WORLD",#Red) 
;   
;   SetGadgetColor(88,  #PB_Gadget_FrontColor,RGB(223,223,223))
;   SetGadgetColor(88,  #PB_Gadget_BackColor,RGB(33,33,33)) 
;   
;   SetGadgetColor(550,  #PB_Gadget_FrontColor,RGB(223,223,223))
;   SetGadgetColor(550,  #PB_Gadget_BackColor,RGB(53,53,53))
;     
;   TintGadget(88,10000,10000,10000,-100,0,0,0)     
;   
;   TintGadget(550,10000,10000,10000,-100,0,0,0)     
;   
;   
;   TintGadget(6,10000,10000,10000,0,-100,-100,0)
;   SendMessage_(GadgetID(6), $400 + 16, $0002, 1)
;   TintGadget(6,10000,10000,10000,0,-100,0,0, #False)
;   
;   TintGadget(77,10000,10000,10000,-100,0,0,0, #True) 
;   
;   TintGadget(6,2000,60000,2000,0,-100,0,0, #True)
;   
;   TintGadget(77,2000,60000,2000,0,-100,0,0, #True)
;   
;   
;   TintGadget(77,10000,10000,10000,0,0,-100,0)
;   TintGadget(77,2000,2000,60000,-100,100,-80,0)
;   
;   Repeat    
;   Until WaitWindowEvent() = #PB_Event_CloseWindow
; EndIf
;}
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 143
; FirstLine = 127
; Folding = 8
; EnableXP
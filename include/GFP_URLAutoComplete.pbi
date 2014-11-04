;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************


#SHACF_URLHISTORY = $00000002
#SHACF_URLMRU     = $00000004
#SHACF_URLALL     = (#SHACF_URLHISTORY | #SHACF_URLMRU)

Procedure.s URLCOMPLETE_NormalizeURL(URL.s)
  URL = Trim(URL)
  If Right(URL,1) = "/"
    URL = Left(URL, Len(URL) - 1)
  EndIf  
  If LCase(Left(URL,4)) = "www."
    URL = "http://"+ URL
  EndIf  
  URL = ReplaceString(URL, "http://www.", "http://www.", #PB_String_NoCase)
  URL = ReplaceString(URL, "http://", "http://", #PB_String_NoCase)
  If GetURLPart(URL, #PB_URL_Site) <> ""
    URL = ReplaceString(URL, GetURLPart(URL, #PB_URL_Site), LCase(GetURLPart(URL, #PB_URL_Site)))    
  EndIf  
  ProcedureReturn URL
EndProcedure  

Procedure URLCOMPLETE_AddCacheEntry(URL.s)
  Protected lResult.l, length.i, name.s, content.s, content_length.i, URLNorm.s, found.i, idx.i, maxUrl.i, hKey.i
  lResult = #False 
  length = 32767
  name.s = Space(32767+1) 
  content.s = Space(32767+1)
  content_length.i = 32767
  URLNorm.s = URLCOMPLETE_NormalizeURL(URL)
  found.i = #False
  idx = 0 
  maxUrl = 0
  RegOpenKeyEx_(#HKEY_CURRENT_USER, @"Software\Microsoft\Internet Explorer\TypedURLs" , 0, #KEY_READ | #KEY_QUERY_VALUE| #KEY_SET_VALUE, @hKey) 
  If hKey    
    While RegEnumValue_(hKey, idx, @name, @length, #Null, #Null, @content, @content_length) = #ERROR_SUCCESS 
      name = Trim(LCase(name))
      
      If URLCOMPLETE_NormalizeURL(content) = URLNorm
        ;Debug "found"
        found = #True
        Break
      EndIf   
      If Left(name, 3) = "url"
        maxUrl = Val(Right(name, Len(name) - 3))
      EndIf  
      idx + 1 
      length = 32767
      content_length = 32767
    Wend 
    maxUrl + 1 ; Fängt bei 1 an
    name = "url" + Str(maxUrl) 
       
    If found = #False
      If RegSetValueEx_(hKey, @name, 0, #REG_SZ, URL, StringByteLength(URL)) = #ERROR_SUCCESS
        lResult = #True
      EndIf  
    Else
      lResult = #True ;SChlüssel gibt es bereits 
    EndIf
    RegCloseKey_(hKey)
  EndIf
  ProcedureReturn lResult
EndProcedure

Procedure URLCOMPLETE_AddGadget(gadget)
  If IsGadget(gadget)
    If SHAutoComplete_(GadgetID(gadget),#SHACF_URLALL) = #S_OK
      ProcedureReturn #True
    EndIf  
  EndIf  
  ProcedureReturn #True
EndProcedure  




; 
;   If OpenWindow(0, 0, 0, 322, 205, "StringGadget Flags", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
;     StringGadget(0, 8,  10, 306, 20, "Normal StringGadget...")
;     URLCOMPLETE_AddGadget(0)
;     ButtonGadget(1,0,99,99,22,"ok")
;     
;     Repeat
;       
;       ev=WindowEvent()
;       If ev = #PB_Event_Gadget And EventGadget()=1
;         URLCOMPLETE_AddCacheEntry(GetGadgetText(0))
;         EndIf
;     Until ev = #PB_Event_CloseWindow
;     
;   EndIf
; 
; 

; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 96
; FirstLine = 42
; Folding = -
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
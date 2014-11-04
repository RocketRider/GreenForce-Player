;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit





Procedure.s __URL_Complete(URL.s)
  If Left(LCase(URL), 4) = "www."
    URL = "http://"+ URL
  EndIf
  ProcedureReturn URL
EndProcedure  

Procedure.s URL_GetProtocol(URL.s)
  Protected prot.s, drive.i
  URL = __URL_Complete(URL)    
  prot.s = LCase(GetURLPart(URL, #PB_URL_Protocol))
  If prot = ""
      
    If Left(Trim(URL),1)="\" ; UNC ; relativer pfad..
      prot = "file"
    EndIf      
    
;     If Left(Trim(URL),2)="\\" ; UNC
;       prot = "file"
;     EndIf  
;     
;     If Left(Trim(URL),4)="\\?\"
;       prot = "file"
;     EndIf    
;     If Left(Trim(URL),4)="\\.\"
;       prot = "file"
;     EndIf          
    
    For drive = 'a'To 'z'
      If Left(LCase(Trim(URL)),2) = Chr(drive)+":" 
        prot = "file"
        Break
      EndIf
    Next   
    
    If prot = ""
      prot = "http"
    EndIf  
    
  EndIf  
  ProcedureReturn prot.s
EndProcedure 

Procedure.s URL_GetSite(URL.s)
  Protected site.s, coumputerName.s, computerNameSize.i
  URL = __URL_Complete(URL)
  site.s = LCase(GetURLPart(URL, #PB_URL_Site))
  
  If site = "" And URL_GetProtocol(URL) = "file"
    coumputerName = Space(#MAX_PATH+1)
    computerNameSize = #MAX_PATH
    GetComputerName_(coumputerName,@computerNameSize)  
    site = Trim(coumputerName)
  EndIf  
  ProcedureReturn site.s
EndProcedure 

Procedure URL_GetPort(URL.s)
  Protected port.s
  URL = __URL_Complete(URL)
  port.s = GetURLPart(URL, #PB_URL_Port) 
  If port = ""
    If URL_GetProtocol(URL) = "http"
      port = "80"
    EndIf  
  EndIf
  If port <> ""
    ProcedureReturn Val(port)
  Else
    ProcedureReturn -1
  EndIf  
EndProcedure 

Procedure.s URL_GetParameterName(URL.s, idx.i)
  Protected params.s , param.s
  URL = __URL_Complete(URL)
  params.s = GetURLPart(URL, #PB_URL_Parameters)
  param = StringField(params, idx, "&")
  If FindString(param,"=",1)
    param = Left(param, FindString(param, "=", 1) - 1)
  EndIf 
  ProcedureReturn param
EndProcedure 

Procedure URL_GetParameterCount(URL.s)
  Protected params.s
  URL = __URL_Complete(URL)
  params.s = Trim(GetURLPart(URL, #PB_URL_Parameters))
  Repeat
    If Right(params,1) = "&":params = Left(params, Len(params) - 1):EndIf
  Until Right(params,1) <> "&"
  
  If Trim(params) <> ""
    ProcedureReturn CountString(params, "&") + 1
  Else
    ProcedureReturn 0
  EndIf  
EndProcedure

Procedure.s URL_GetParameterContent(URL.s, idx.i)
  Protected param.s, name.s
  URL = __URL_Complete(URL)
  param.s = GetURLPart(URL, URL_GetParameterName(URL, idx))
  ;name.s = StringField(param, idx, "&")
;   If name <> ""
;     ProcedureReturn GetURLPart(URL, name)
;   EndIf  
  ProcedureReturn param
EndProcedure 

Procedure URL_IsParameter(URL.s, name.s) 
  Protected idx.i, count.i, param.s
  URL = __URL_Complete(URL)
  name = Trim(LCase(name))
  If name <> ""
    count = URL_GetParameterCount(URL)
    For idx = 1 To count
      
      param.s = LCase(URL_GetParameterName(URL, idx))
      If FindString(param,"=",1)
        param = Left(param, FindString(param,"=",1) - 1)
      EndIf  
      If param = name 
        ProcedureReturn #True
      EndIf  
    Next  
  EndIf  
  ProcedureReturn #False
EndProcedure 

Procedure.s URL_GetPath(URL.s)
  Protected path.s    
  URL = __URL_Complete(URL)
  If URL_GetProtocol(URL) = "file"
    URL = Trim(LCase(URL)); Unter Windows ist der Dateipfad nicht case sensitiv!    
    If Left(URL, 7) = "file://"
      URL = URLDecoder(URL)
      URL = Right(URL, Len(URL) - 7)
      URL = ReplaceString(URL, "/", "\")
      If FindString(URL, "?", 1)
        URL = Left(URL, FindString(URL, "?", 1) - 1)
      EndIf  
    EndIf      
    path = Space(32767)
    GetFullPathName_(URL, 32767, path, 0)
    path = LCase(path)
  Else
    path.s = GetURLPart(URL, #PB_URL_Path) ; Achtung: Kein LCASE, Pfad ist case sensitiv! 
  EndIf
  ProcedureReturn path
EndProcedure  

Procedure.s URL_GetUser(URL.s)
  Protected user.s  
  URL = __URL_Complete(URL)
  user.s = GetURLPart(URL, #PB_URL_User) ; Achtung: Kein LCASE
  ProcedureReturn user
EndProcedure  

Procedure.s URL_GetPassword(URL.s)
  Protected password.s
  URL = __URL_Complete(URL)
  password.s = GetURLPart(URL, #PB_URL_Password) ; Achtung: Kein LCASE
  ProcedureReturn password
EndProcedure  

Procedure.s URL_GetUniqueID(URL.s)
  Protected id.s, count.i, idx.i
  URL = __URL_Complete(URL)
  id.s = "Protocol: "+ URL_GetProtocol(URL) + " " 
  id + "Site: "+URL_GetSite(URL) + " " 
  id + "User: " +URL_GetUser(URL) + " "
  id + "Password: " + URL_GetPassword(URL) + " "
  id + "Path: " +URL_GetPath(URL) + " "
  id + "Port: " + Str(URL_GetPort(URL)) + " "
  count = URL_GetParameterCount(URL.s)
  For idx = 1 To count
    id + URL_GetParameterName(URL, idx) + " = " + URL_GetParameterContent(URL, idx)
  Next  
  ;Debug id
  ProcedureReturn MD5Fingerprint(@id, StringByteLength(id))
EndProcedure  


Procedure.s URL_GetTempFilename(URL.s)
ProcedureReturn GetTemporaryDirectory() + URL_GetUniqueID(URL)
EndProcedure  










;   URL$ = "www.test1.com:70";"http://user:pass@www.Purebasic.com/tes123/abc/index.php3?ok=9"
;   
;   Debug URL_GetTempFilename(URL$)
;   
;   URL$ = "https://user:pass@www.PurebaSic.coM:80/tes123/abc/index.php3?ok=9"
;   URL$ = "\\test.test"
;   Debug URL_GetProtocol(URL$)

  
;   Debug URL_GetUniqueID(URL$)
;   
; ;   Debug HTTP_GetParameterCountFromURL(URL$)
; ;   Debug HTTP_IsParameterFromURL(URL$, "ok")

  
  
  
; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 208
; FirstLine = 166
; Folding = ---
; EnableXP
; EnableCompileCount = 17
; EnableBuildCount = 0
; EnableExeConstant
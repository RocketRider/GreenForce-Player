;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************
EnableExplicit
Define UPDATE_FILE.s = GetTemporaryDirectory()+"GFP-update.data"
Define sUpdateExe.s = "GreenForce-Player.exe"
Define iFile.i, Str.s, param.s, iResult.i, i.i
Define Error=#False

param.s=ProgramParameter()
If param:sUpdateExe=param:EndIf

Delay(500)
If FileSize(GetPathPart(ProgramFilename())+"GFP-update.data")>0:UPDATE_FILE=GetPathPart(ProgramFilename())+"GFP-update.data":EndIf

If FileSize(UPDATE_FILE.s)>0
  For i=0 To 20
    iResult=CopyFile(UPDATE_FILE.s, sUpdateExe)
    If iResult:Break:EndIf
    Delay(200)
  Next
  

  If iResult = #False
    MessageRequester("Error", "Error can't update program!"+#CRLF$+"Please do it manual!"+#CRLF$+ "Errorcode: 1", #MB_ICONERROR)
  EndIf
  DeleteFile(UPDATE_FILE.s)
Else
  MessageRequester("Error", "Error can't update program!"+#CRLF$+"Please do it manual!"+#CRLF$+ "Errorcode: 2", #MB_ICONERROR)
EndIf


If FileSize(sUpdateExe)>0
  If RunProgram(sUpdateExe)=#Null
    MessageRequester("Error", "Error can't start the program!"+#CRLF$+"Please do it manual!"+#CRLF$+ "Errorcode: 3", #MB_ICONERROR)
  EndIf  
Else
  MessageRequester("Error", "Error can't update program!"+#CRLF$+"Please do it manual!"+#CRLF$+ "Errorcode: 4", #MB_ICONERROR)
EndIf


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 23
; EnableXP
; EnableAdmin
; UseIcon = data\Icons\Icons-32x32\download2.ico
; Executable = data\update.exe
; EnableCompileCount = 31
; EnableBuildCount = 25
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 0,1,2,0
; VersionField1 = 0,1,2,0
; VersionField2 = RRSoftware
; VersionField3 = GF-Player Updater
; VersionField4 = 0.12
; VersionField5 = 0.12
; VersionField6 = GF-Player Updater
; VersionField7 = GF-Player Updater
; VersionField8 = GF-Player Updater
; VersionField9 = (c) 2009 - 2010 RocketRider
; VersionField13 = support@gfp.rrsoftware.de
; VersionField14 = http://GFP.RRSoftware.de
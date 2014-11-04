;*************************************** 
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
CompilerIf #USE_OEM_VERSION
  
  Global FLVPlayerSWFFile.s;="C:\test\player.swf"
  Global FLVPlayerSWFVars.s="videoFile=%FLVFILE%&eventFSCommand=true"
  
  Procedure UseFLVPlayer(sFile.s)
    Protected iResult.i=#False
    If LCase(GetExtensionPart(sFile))="flv"
      iResult=#True
    EndIf  
    If LCase(Mid(sFile,Len(sFile)-Len(".flv.mpvideo")+1))=".flv.mpvideo"
      iResult=#True
    EndIf  
    ProcedureReturn iResult
  EndProcedure  
  
  
  Procedure LoadFLVFile(sFile.s)
    Protected *p, Player.s
    If FLVPlayerSWFFile
      WriteLog("Loaded with FLV player "+FLVPlayerSWFFile+" With "+FLVPlayerSWFVars, #LOGLEVEL_DEBUG)
      ;FLVPlayerSWFFile, muss immer vollen Pfad haben!
      CompilerIf  #PB_editor_createexecutable
        Player.s=GetMediaPath(ProgramFilename(), FLVPlayerSWFFile)
      CompilerElse
        Player.s=GetMediaPath(GetCurrentDirectory(), FLVPlayerSWFFile)
      CompilerEndIf  
      *p=LoadSWFFile(Player, ReplaceString(FLVPlayerSWFVars,"%FLVFILE%", sFile, #PB_String_NoCase));"videoFile="+sFile+"&eventFSCommand=true"
    Else
      WriteLog("Loaded with FLV player from mem", #LOGLEVEL_DEBUG)
      *p=LoadSWFFile("", "videoFile="+sFile+"&eventFSCommand=true&allowBigPlayButton=false&autoLoad=true&autoPlay=true&smoothVideo=true&maintainAspectRatio=true", ?FLVPlayerStart, ?FLVPlayerEnd)
      ;&skinAutoHide=true
      
      
      ;Debug *p
      ;skinAutoHide=true&
    EndIf  
    ProcedureReturn *p
  EndProcedure  
  
  
;   Procedure FreeFLVFile(*obj.FLASHOBJ)
;     If *obj
;       Flash_Destroy(*obj)
;     EndIf
;   EndProcedure
  

  
  DataSection
    FLVPlayerStart:
      IncludeBinary "oem-data\player.swf"
    FLVPlayerEnd:
  EndDataSection  
  

CompilerEndIf




; IDE Options = PureBasic 5.11 (Windows - x86)
; Folding = -
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
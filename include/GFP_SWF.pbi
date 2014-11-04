;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

;Global *FLASHObject.FLASHOBJ

#FLASH_WIDTH = 640
#FLASH_HEIGHT = 480

#FLASH_EXTRACTSWF = #False;#True;

Global SavedFlashVersion.i


Procedure DisableMediaMenu(state.i)
  If IsMenu(#MENU_MAIN)
    DisableMenuItem(#MENU_MAIN, #MENU_ASPECTATION_16_10, state)
    DisableMenuItem(#MENU_MAIN, #MENU_ASPECTATION_16_9, state)
    DisableMenuItem(#MENU_MAIN, #MENU_ASPECTATION_1_1, state)
    DisableMenuItem(#MENU_MAIN, #MENU_ASPECTATION_21_9, state)
    DisableMenuItem(#MENU_MAIN, #MENU_ASPECTATION_4_3, state)
    DisableMenuItem(#MENU_MAIN, #MENU_ASPECTATION_5_4, state)
    DisableMenuItem(#MENU_MAIN, #MENU_ASPECTATION_AUTO, state)
    DisableMenuItem(#MENU_MAIN, #MENU_PLAY, state)
    DisableMenuItem(#MENU_MAIN, #MENU_SAVE_MEDIAPOS, state)
    DisableMenuItem(#MENU_MAIN, #MENU_STOP, state)
  EndIf
EndProcedure


Procedure RecreateVideoContainer()
  Protected OldGadgetList, X, Y, W, H
  If IsWindow(#WINDOW_MAIN)
    X=GadgetX(#GADGET_VIDEO_CONTAINER)
    Y=GadgetY(#GADGET_VIDEO_CONTAINER)
    W=GadgetWidth(#GADGET_VIDEO_CONTAINER)
    H=GadgetHeight(#GADGET_VIDEO_CONTAINER)
    FreeGadget(#GADGET_VIDEO_CONTAINER)
    
    OldGadgetList=UseGadgetList(WindowID(#WINDOW_MAIN))
    ContainerGadget(#GADGET_VIDEO_CONTAINER, X, Y, W, H)
    SetGadgetColor(#GADGET_VIDEO_CONTAINER, #PB_Gadget_BackColor, Val(Settings(#SETTINGS_BKCOLOR)\sValue))
    
    CloseGadgetList()
    UseGadgetList(OldGadgetList)
  EndIf    
  
EndProcedure  

Procedure FreeSWFFile(*p)
  Protected OldGadgetList, X, Y, W, H
  DisableMediaMenu(#False)
  If *p
    ;Debug *p
    Flash_Stop(*p)
    Flash_Destroy(*p)
    *p=#Null
    
    If IsWindow(#WINDOW_MAIN)
;       X=GadgetX(#GADGET_VIDEO_CONTAINER)
;       Y=GadgetY(#GADGET_VIDEO_CONTAINER)
;       W=GadgetWidth(#GADGET_VIDEO_CONTAINER)
;       H=GadgetHeight(#GADGET_VIDEO_CONTAINER)
;       FreeGadget(#GADGET_VIDEO_CONTAINER)
;       
;       OldGadgetList=UseGadgetList(WindowID(#WINDOW_MAIN))
;       ContainerGadget(#GADGET_VIDEO_CONTAINER, X, Y, W, H)
;       SetGadgetColor(#GADGET_VIDEO_CONTAINER, #PB_Gadget_BackColor, Val(Settings(#SETTINGS_BKCOLOR)\sValue))
;       
;       CloseGadgetList()
;       UseGadgetList(OldGadgetList)

      RecreateVideoContainer()
      HideGadget(#GADGET_CONTAINER, #False)
      UseNoPlayerControl=#False
      If Settings(#SETTINGS_USE_STATUSBAR)\sValue="1"
        If UseNoPlayerControl=#False:ShowWindow_(StatusBarID(#STATUSBAR_MAIN), #SW_SHOWDEFAULT):EndIf
      EndIf  
    EndIf
  EndIf  
  ProcedureReturn *p
EndProcedure
Procedure LoadSWFFile(sFile.s, sVars.s, SwfStart.l=#Null, SwfEnd.l=#Null)
  Protected Timer, *FLASHObject.FLASHOBJ, LoadResult, FullscreenControlHeight, ReadyState, iFile.i
  RecreateVideoContainer()
  
  *FLASHObject=Flash_Create(GadgetID(#GADGET_VIDEO_CONTAINER))
  
  ;Debug *FLASHObject
  ;WebGadget(3443, 0,0, 100, 100,"")
  If *FLASHObject
    
    If SavedFlashVersion=#False
      WriteLog("FlashVersion: "+Str(Flash_GetMajorVersion(*FLASHObject))+"."+Str(Flash_GetMinorVersion(*FLASHObject)), #LOGLEVEL_DEBUG)
      SavedFlashVersion=#True
    EndIf  
    
    Flash_SetFlashVars(*FLASHObject, sVars)
    If sFile
      
      LoadResult=Flash_LoadMovie(*FLASHObject, sFile)
    Else
      CompilerIf #FLASH_EXTRACTSWF
        sFile=GetTemporaryDirectory()+"VideoPlayer-FLFPlayer_F23TD1.swf"
        iFile=CreateFile(#PB_Any, sFile)
        If iFile
          WriteData(iFile, SwfStart, SwfEnd-SwfStart)
          CloseFile(iFile)
          LoadResult=Flash_LoadMovie(*FLASHObject, sFile)
        Else
          WriteLog("Cant create swf file!")
        EndIf

      CompilerElse  
        LoadResult=Flash_LoadMovieMem(*FLASHObject,SwfStart, SwfEnd)
      CompilerEndIf  
    EndIf  
    
    If LoadResult
      WriteLog("Flash Movie loaded", #LOGLEVEL_DEBUG)
      DisableMediaMenu(#True)
      
      Timer=ElapsedMilliseconds()
      Repeat
        Delay(100)
        ReadyState=Flash_GetReadyState(*FLASHObject)
      Until ReadyState=#FLASH_ReadyState_Complete Or ReadyState = #FLASH_ReadyState_Interactive Or ElapsedMilliseconds()-Timer>1000
      If ReadyState<>#FLASH_ReadyState_Complete And ReadyState<>#FLASH_ReadyState_Interactive And ReadyState<>#FLASH_ReadyState_Loaded
        WriteLog("Flash is not ready, state is: "+Str(Flash_GetReadyState(*FLASHObject)))
        ;Flash_Destroy(*FLASHObject)
        FreeSWFFile(*FLASHObject)
        *FLASHObject=#Null
      Else
        Flash_Play(*FLASHObject)
        HideGadget(#GADGET_CONTAINER, #True)
        
        ShowWindow_(StatusBarID(#STATUSBAR_MAIN), #SW_HIDE)
        UseNoPlayerControl=#True
        ;ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        WriteLog("Flash Movie Plays", #LOGLEVEL_DEBUG)
      EndIf
      
    Else
      WriteLog("Flash Movie loading failed!", #LOGLEVEL_DEBUG)
      Flash_Destroy(*FLASHObject)
      *FLASHObject=#Null
    EndIf
  EndIf
  ProcedureReturn *FLASHObject
EndProcedure










; IDE Options = PureBasic 5.00 Beta 7 (Windows - x86)
; CursorPosition = 107
; FirstLine = 96
; Folding = -
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
;Visualization Interaktiv System


Global iIsVISUsed.i
Global  *VisualCanvas.SVisualisationCanvas;,VisualCanvas.SVisualisationCanvas

Global VIS_ItemCount.i
Global Dim VISFiles.s(300)

Declare VIS_SetVIS(iVIS.i)


;VIS_SIMPLE
Declare VIS_Simple_Init(*p.IVisualisationCanvas)
Declare VIS_Simple_Run(*p.IVisualisationCanvas)
Declare VIS_Simple_Terminate(*p.IVisualisationCanvas)
Declare VIS_Simple_BeforeReset(*p.IVisualisationCanvas)
Declare VIS_Simple_AfterReset(*p.IVisualisationCanvas)

;DCT_SIMPLE
Declare VIS_DCT_Init(*p.IVisualisationCanvas)
Declare VIS_DCT_Run(*p.IVisualisationCanvas)
Declare VIS_DCT_Terminate(*p.IVisualisationCanvas)
Declare VIS_DCT_BeforeReset(*p.IVisualisationCanvas)
Declare VIS_DCT_AfterReset(*p.IVisualisationCanvas)

;VIS_WHITELIGHT
Declare VIS_WhiteLight_Init(*p.IVisualisationCanvas)
Declare VIS_WhiteLight_Run(*p.IVisualisationCanvas)
Declare VIS_WhiteLight_Terminate(*p.IVisualisationCanvas)
Declare VIS_WhiteLight_BeforeReset(*p.IVisualisationCanvas)
Declare VIS_WhiteLight_AfterReset(*p.IVisualisationCanvas)

;VIS_COVERFLOW
Declare VIS_Coverflow_Init(*p.IVisualisationCanvas)
Declare VIS_Coverflow_Run(*p.IVisualisationCanvas)
Declare VIS_Coverflow_Terminate(*p.IVisualisationCanvas)
Declare VIS_Coverflow_BeforeReset(*p.IVisualisationCanvas)
Declare VIS_Coverflow_AfterReset(*p.IVisualisationCanvas)

;VIS_BUFFERING
Declare VIS_Buffering_Init(*p.IVisualisationCanvas)
Declare VIS_Buffering_Run(*p.IVisualisationCanvas)
Declare VIS_Buffering_Terminate(*p.IVisualisationCanvas)
Declare VIS_Buffering_BeforeReset(*p.IVisualisationCanvas)
Declare VIS_Buffering_AfterReset(*p.IVisualisationCanvas)



Procedure VIS_Free()
  If *VisualCanvas
    VIS_SetVIS(#False)
    
    Canvas_Free(*VisualCanvas)
    FreeMemory(*VisualCanvas)
    *VisualCanvas=#Null
  EndIf
EndProcedure
Procedure VIS_Init()
  ContainerGadget(#GADGET_VIS_CONTAINER, 0, 0, 0, 0)
  CloseGadgetList()
;   *VisualCanvas=AllocateMemory(SizeOf(SVisualisationCanvas))
;   If *VisualCanvas
;     Canvas_InitObject(*VisualCanvas)
;     ;*VisualCanvas=VisualCanvas
;     
;     If Canvas_Create(*VisualCanvas, GadgetID(#GADGET_VIS_CONTAINER), 640,480)=#False
;       WriteLog("Can't create canvas!", #LOGLEVEL_ERROR)
;       FreeMemory(*VisualCanvas)
;       *VisualCanvas=#Null
;     EndIf
;   EndIf
EndProcedure
Procedure VIS_SetDSHOWObj(iObj.i)
  If *VisualCanvas
    If UsedOutputMediaLibrary = #MEDIALIBRARY_DSHOW
      Canvas_SetDSHOWObj(*VisualCanvas, iObj)
    Else
      Canvas_SetDSHOWObj(*VisualCanvas, #Null)
    EndIf  
  EndIf
EndProcedure
Procedure VIS_Connect_Proc(*Init, *Run, *Terminate, *BeforeReset, *AfterReset)
  If Canvas_ConnectRenderer(*VisualCanvas, *Init, *Run, *Terminate, *BeforeReset, *AfterReset)=#False
    WriteLog("Can't connect renderer!", #LOGLEVEL_ERROR)
  EndIf
EndProcedure
Procedure VIS_Connect_DLL(sDLL.s)
  If Canvas_ConnectRendererDLL(*VisualCanvas, sDLL.s)=#False
    WriteLog("Can't connect renderer!", #LOGLEVEL_ERROR)
  EndIf
EndProcedure
Procedure VIS_RemoveRenderer()
  If *VisualCanvas
    Canvas_RemoveRenderer(*VisualCanvas)
  EndIf
EndProcedure
Procedure VIS_SetVIS(iVIS.i)
  Protected i.i
      
  If *VisualCanvas
    VIS_RemoveRenderer()
    ;Canvas_Free(*VisualCanvas)
    ;FreeMemory(*VisualCanvas)
    ;*VisualCanvas=#Null
    
  EndIf
  
  If *VisualCanvas=#Null
    *VisualCanvas=AllocateMemory(SizeOf(SVisualisationCanvas))
    If *VisualCanvas
      Canvas_InitObject(*VisualCanvas)
      
      If Canvas_Create(*VisualCanvas, GadgetID(#GADGET_VIS_CONTAINER), 640, 480)=#False
        WriteLog("Can't create canvas!", #LOGLEVEL_ERROR)
        FreeMemory(*VisualCanvas)
        *VisualCanvas=#Null
      EndIf
    EndIf
  EndIf
  
  
  If *VisualCanvas
    iIsVISUsed = iVIS
    SetMediaSizeToVIS()
    If IsMenu(#MENU_MAIN)
      For i=#MENU_VIS_OFF To #MENU_VIS_300
        SetMenuItemState(#MENU_MAIN, i, #False)
      Next
      SetMenuItemState(#MENU_MAIN, #MENU_VIS_OFF+iVIS, #True)
    EndIf
    
    ;VIS_RemoveRenderer()
    VIS_SetDSHOWObj(IMediaObject)
    If iVIS=#False
      SetMediaAspectRation()
    Else 
      Select iVIS
      Case #VIS_SIMPLE
        VIS_Connect_Proc(@VIS_Simple_Init(), @VIS_Simple_Run(), @VIS_Simple_Terminate(), @VIS_Simple_BeforeReset(), @VIS_Simple_AfterReset())
      Case #VIS_DCT
        VIS_Connect_Proc(@VIS_DCT_Init(), @VIS_DCT_Run(), @VIS_DCT_Terminate(), @VIS_DCT_BeforeReset(), @VIS_DCT_AfterReset())
      Case #VIS_WHITELIGHT
        VIS_Connect_Proc(@VIS_WhiteLight_Init(), @VIS_WhiteLight_Run(), @VIS_WhiteLight_Terminate(), @VIS_WhiteLight_BeforeReset(), @VIS_WhiteLight_AfterReset())
      Case #VIS_COVERFLOW
        VIS_Connect_Proc(@VIS_Coverflow_Init(), @VIS_Coverflow_Run(), @VIS_Coverflow_Terminate(), @VIS_Coverflow_BeforeReset(), @VIS_Coverflow_AfterReset())
      Case #VIS_BUFFERING
        VIS_Connect_Proc(@VIS_Buffering_Init(), @VIS_Buffering_Run(), @VIS_Buffering_Terminate(), @VIS_Buffering_BeforeReset(), @VIS_Buffering_AfterReset())
      EndSelect
      If iVIS>=#VIS_1 And iVIS<=#VIS_300
        VIS_Connect_DLL(GetSpecialFolder(#CSIDL_APPDATA)+"\GF-Player\Visualization-DLLs\"+VISFiles(iVIS-#VIS_1))
      EndIf
    EndIf
  EndIf
EndProcedure
Procedure VIS_Activate(iWidth.i=640, iHeight.i=480)
  Protected MenuHeight
  If *VisualCanvas
    If IsMenu(#MENU_MAIN)
      MenuHeight=MenuHeight() 
    Else
      MenuHeight=0
    EndIf 
    
    If iWidth = 0 : iWidth = #PB_Ignore :EndIf
    If iHeight = 0 : iHeight = #PB_Ignore :EndIf
    If iWidth <> #PB_Ignore And iHeight <> #PB_Ignore
      WindowBounds(#WINDOW_MAIN, 350, 85+StatusBarHeight(0), #PB_Ignore, $FFF)
      ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, iWidth, iHeight+_StatusBarHeight(0)+MenuHeight+Design_Container_Size)
    Else
      WindowBounds(#WINDOW_MAIN, 350, 85+StatusBarHeight(0), #PB_Ignore, 85+_StatusBarHeight(0))
      ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, #PB_Ignore, 85+_StatusBarHeight(0))
    EndIf
  EndIf
EndProcedure
Procedure VIS_Resize()
  If iIsVISUsed And *VisualCanvas
    Canvas_Resize(*VisualCanvas, GadgetWidth(#GADGET_VIS_CONTAINER), GadgetHeight(#GADGET_VIS_CONTAINER))
  EndIf
EndProcedure
Procedure VIS_Update()
  Protected x.i, t.i, i.i, y.i
  If iIsVISUsed And *VisualCanvas
    If Canvas_Show(*VisualCanvas)=#False
      WriteLog("Can't show canvas!", #LOGLEVEL_ERROR)
    EndIf
  EndIf
EndProcedure

Procedure VIS_FindExternVIS(sDirectory.s = "")
  Protected iDirectory.i, sName.s
  If sDirectory.s=""
    sDirectory.s = GetSpecialFolder(#CSIDL_APPDATA)+"\GF-Player\Visualization-DLLs\"
  EndIf
  iDirectory = ExamineDirectory(#PB_Any, sDirectory, "*.*")
  If iDirectory
    While NextDirectoryEntry(iDirectory)
      sName.s = DirectoryEntryName(iDirectory)
      If sName <> "." And sName <> ".." And sName <> "..."
        If DirectoryEntryType(iDirectory) = #PB_DirectoryEntry_File
          If UCase(GetExtensionPart(sName))="VIS-DLL"
            MenuItem(#MENU_VIS_1+VIS_ItemCount, Mid(sName, 1, FindString(sName, ".", 1)-1))
            VISFiles(VIS_ItemCount)=sName
            VIS_ItemCount+1
          EndIf
        Else
          OpenSubMenu(sName)
            VIS_FindExternVIS(sDirectory.s + "\" + sName)
          CloseSubMenu()
        EndIf
      EndIf
    Wend
    FinishDirectory(iDirectory)
  EndIf
EndProcedure
Procedure VIS_IsVISFile(sFile.s)
  If UCase(GetExtensionPart(sFile))="VIS-DLL"
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure
Procedure VIS_ImportVIS(sFile.s)
  If FileSize(sFile)>0
    If MessageRequester(Language(#L_VISUALIZATION), Language(#L_ADD_VIS), #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes
      CreateDirectory(GetSpecialFolder(#CSIDL_APPDATA)+"\GF-Player\Visualization-DLLs\")
      If CopyFile(sFile, GetSpecialFolder(#CSIDL_APPDATA)+"\GF-Player\Visualization-DLLs\"+GetFilePart(sFile))
        If MessageRequester(Language(#L_OPTIONS), Language(#L_CHANGES_NEEDS_RESTART) + #CRLF$ + Language(#L_WANTTORESTART), #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes
          RestartPlayer()
        EndIf
      Else
        MessageRequester(Language(#L_ERROR), Language(#L_CANT_INSTALL), #MB_ICONERROR)
      EndIf
    EndIf
  EndIf
EndProcedure



; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 161
; FirstLine = 77
; Folding = ED+
; EnableXP
; EnableUser
; UseMainFile = Player.pb
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
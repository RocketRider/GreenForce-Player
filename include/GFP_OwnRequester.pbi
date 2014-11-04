;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************
EnableExplicit

;To fix redraw Problem
Procedure ProcessVIS()
  Protected isMainWindowActive.i
  Delay(1)
  If IsWindow(#WINDOW_MAIN)
    If IsWindowVisible_(WindowID(#WINDOW_MAIN)) And GetWindowState(#WINDOW_MAIN)<>#PB_Window_Minimize
      isMainWindowActive = #True
    Else
      isMainWindowActive = #False
    EndIf
    
    If isMainWindowActive
      VIS_Update();Updates the visual effects
    EndIf
  
    
  EndIf  
  
EndProcedure  


Procedure BalloonTip(WindowID, Gadget, Text$ , Title$, Icon)
  Protected ToolTip.i, Balloon.TOOLINFO
  ToolTip=CreateWindowEx_(0, "ToolTips_Class32", "", #WS_POPUP | #TTS_NOPREFIX | #TTS_BALLOON, 0, 0, 0, 0, WindowID, 0, GetModuleHandle_(0), 0)
  SendMessage_(ToolTip, #TTM_SETTIPTEXTCOLOR, GetSysColor_(#COLOR_INFOTEXT), 0)
  SendMessage_(ToolTip, #TTM_SETTIPBKCOLOR, GetSysColor_(#COLOR_INFOBK), 0)
  SendMessage_(ToolTip, #TTM_SETMAXTIPWIDTH,0,180)
  Balloon.TOOLINFO\cbSize = SizeOf(TOOLINFO)
  Balloon\uFlags = #TTF_IDISHWND | #TTF_SUBCLASS
  Balloon\hWnd = GadgetID(Gadget)
  Balloon\uId = GadgetID(Gadget)
  Balloon\lpszText = @Text$
  SendMessage_(ToolTip, #TTM_ADDTOOL, 0, Balloon)
  If Title$ > ""
    SendMessage_(ToolTip, #TTM_SETTITLE, Icon, @Title$)
  EndIf
EndProcedure



Procedure OpenSendReportRequester()
  Protected Report_Window.i, Event.i, Quit.i
  Report_Window=OpenWindow(#PB_Any, 0, 0, 300, 400, "Send a bug report!", #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
  If IsWindow(Report_Window)
    Repeat
      Event = WaitWindowEvent(100)
      If EventWindow() = Report_Window
        If Event=#PB_Event_Gadget
          Select EventGadget()
              
          EndSelect
        EndIf
        If Event = #PB_Event_CloseWindow
          Quit = 1
        EndIf
      EndIf
    Until Quit = 1
    CloseWindow(Report_Window)
  EndIf
  
EndProcedure







Procedure OpenRequester(sTitle.s, sText.s, Icon.i, sButton1.s, *Button1Proc, sButton2.s, *Button2Proc, sButton3.s="", *Button3Proc=#Null)
  Protected Req_Window.i, RequesterQuit.i, Event, iButton1, iButton2, iButton3
  Req_Window = OpenWindow(#PB_Any, 0 ,0, 500, 200, sTitle, #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
  If Req_Window
    If Icon
      If IsImage(Icon)
        ResizeImage(Icon, 60, 60, #PB_Image_Smooth)
        ImageGadget(#PB_Any, 5, 5, 60, 60, ImageID(Icon))
      EndIf
    EndIf  
    ;SetGadgetText(EditorGadget(#PB_Any, 70, 10, 200, 130, #PB_Editor_ReadOnly), sText)
    StringGadget(#PB_Any, 70, 10, 300, 180, sText, #PB_String_ReadOnly|#ES_MULTILINE|#WS_VSCROLL)
    
    
    If sButton1:iButton1 = ButtonGadget(#PB_Any, 380, 10, 110, 24, sButton1):EndIf
    If sButton2:iButton2 = ButtonGadget(#PB_Any, 380, 40, 110, 24, sButton2):EndIf
    If sButton3:iButton3 = ButtonGadget(#PB_Any, 380, 70, 110, 24, sButton3):EndIf
    
    Repeat
      ProcessVIS()
      Event = WaitWindowEvent(100)
      If EventWindow() = Req_Window
        If Event=#PB_Event_Gadget
          Select EventGadget()
            Case iButton1:RequesterQuit = 1:CallFunctionFast(*Button1Proc)
            Case iButton2:RequesterQuit = 1:CallFunctionFast(*Button2Proc)
            Case iButton3:RequesterQuit = 1:CallFunctionFast(*Button3Proc)
          EndSelect
        EndIf
        If Event = #PB_Event_CloseWindow
          RequesterQuit = 1
        EndIf
      EndIf
    Until RequesterQuit = 1
    If IsWindow(Req_Window):CloseWindow(Req_Window):EndIf

  EndIf
EndProcedure



Procedure Requester_Cant_Update_B1();Exit
  End
EndProcedure
Procedure Requester_Cant_Update_B2();Restore
  RestoreDatabase(#True, #False)
EndProcedure
Procedure Requester_Cant_Update_B3();Run without update
  WriteLog("Run without update database!")
EndProcedure
Procedure Requester_Cant_Update()
  OpenRequester("Error", "Can't update database!"+#CRLF$+#CRLF$+"Please download the newest version"+#CRLF$+"or restore the database!"+#CRLF$+"A restore will delete all your settings."+#CRLF$+"A run without updating the database can influence"+#CRLF$+"many problems!", #SPRITE_ERROR, "Exit", @Requester_Cant_Update_B1(), "Restore DB", @Requester_Cant_Update_B2(), "Run without update",@Requester_Cant_Update_B3())
  GetWindowKeyState(#VK_RBUTTON);Wird benötigt da der status später sonst noch aktiv ist.
EndProcedure  


Global sRequester_Error_Text.s
Procedure Requester_Error_B1();Exit
  ;EndPlayer()
  End
EndProcedure
Procedure Requester_Error_B2();Restart
  RestartPlayer()
EndProcedure
Procedure Requester_Error_B3();Bug report
  ;OpenSendReportRequester()
  Protected MailTo.s, logText.s, length.i, *MemoryID
  If iGlobalLogFile
    FileSeek(iGlobalLogFile, 0)
    length = Lof(iGlobalLogFile)   
    *MemoryID = AllocateMemory(length)   
    If *MemoryID
      ReadData(iGlobalLogFile, *MemoryID, length) 
      logText=#CRLF$+"Log-File:"+#CRLF$
      logText=logText+PeekS(*MemoryID)+#CRLF$
      FreeMemory(*MemoryID)
    EndIf
  EndIf
  MailTo=URLEncoder("mailto: support@GFP.RRSoftware.de?subject=Fatal error GFP&body="+sRequester_Error_Text)
  If ShellExecute_(#Null, #Null, MailTo, #Null, #Null, #SW_SHOWNORMAL)>32
    
  Else  
    If RunProgram("firefox.exe" ,Chr(34) + MailTo + Chr(34),"")=#False
      MessageRequester("Error", "Can't start mail program, you find the error details in your clipboard!", #MB_ICONERROR)
    EndIf
  EndIf
EndProcedure
Procedure Requester_Error(sText.s)
  sRequester_Error_Text = sText
  CompilerIf #USE_OEM_VERSION
    OpenRequester("Fatal Error!", sText, #SPRITE_ERROR, "Exit", @Requester_Error_B1(), "Restart", @Requester_Error_B2())
  CompilerElse
    OpenRequester("Fatal Error!", sText, #SPRITE_ERROR, "Exit", @Requester_Error_B1(), "Restart", @Requester_Error_B2(), "Send bug report", @Requester_Error_B3())
  CompilerEndIf
EndProcedure  


Global iRequester_Codec.i
Procedure Requester_Install_Codec_B1()
  iRequester_Codec=#True
EndProcedure
Procedure Requester_Install_Codec_B2()
  iRequester_Codec=#False
EndProcedure
Procedure Requester_Install_Codec(sText.s, Deinstall=#False)
  If Deinstall
    OpenRequester(Language(#L_DEINSTALL_CODEC), Language(#L_DO_YOU_WANT_DEINSTALL_CODEC)+#CRLF$+sText, #SPRITE_INFO, Language(#L_DEINSTALL), @Requester_Install_Codec_B1(), Language(#L_CANCEL), @Requester_Install_Codec_B2())
  Else  
    OpenRequester(Language(#L_INSTALL_CODEC), Language(#L_DO_YOU_WANT_INSTALL_CODEC)+#CRLF$+sText, #SPRITE_INFO, Language(#L_INSTALL), @Requester_Install_Codec_B1(), Language(#L_CANCEL), @Requester_Install_Codec_B2())
  EndIf
  GetWindowKeyState(#VK_RBUTTON);Wird benötigt da der status später sonst noch aktiv ist.
  ProcedureReturn iRequester_Codec
EndProcedure







Procedure.s OwnPathRequester(psTitle.s,psMessage.s,psInitialPath.s)
  Protected iWH.i, sText.s
  Protected iTH.i
  Protected iEH.i
  Protected iB1.i
  Protected iB2.i
  Protected iB3.i
  Protected iEvent.i, sPath.s
  
  iWH = OpenWindow(#PB_Any, #PB_Ignore, #PB_Ignore, 315, 348, psTitle, #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)
  If iWH
    iTH = TextGadget(#PB_Any,15,10,277,22,psMessage)
    iEH = ExplorerTreeGadget(#PB_Any,15,30,285,240,psInitialPath, #PB_Explorer_NoLines | #PB_Explorer_NoFiles | #PB_Explorer_AutoSort|#PB_Explorer_NoMyDocuments)
    iB1 = ButtonGadget(#PB_Any,10,312,125,23,Language(#L_CREATE_NEW_FOLDER))
    iB2 = ButtonGadget(#PB_Any,138,312,80,23,Language(#L_LOAD),#PB_Button_Default)
    iB3 = ButtonGadget(#PB_Any,223,312,80,23,Language(#L_CANCEL))
  EndIf
  
  WindowBounds(iWH, 315, 275, #PB_Ignore, #PB_Ignore)
  
  Repeat
    iEvent = WaitWindowEvent()
    ProcessVIS()
    If EventWindow()=iWH
      Select iEvent
        
        Case #PB_Event_Gadget
          Select EventGadget()
          
            Case iB1
              sPath=GetGadgetText(iEH)+"Neuer Ordner"
              sPath=InputRequester(Language(#L_NAME_OF_THE_FOLDER), Language(#L_NAME_OF_THE_FOLDER), Language(#L_NEW_FOLDER))
              If sPath
                CreateDirectory(sPath.s)
                SetGadgetText(iEH, sPath)
              EndIf  
              
            Case iB2
              sText=GetGadgetText(iEH)
              CloseWindow(iWH)
              GetWindowKeyState(#VK_RBUTTON);Wird benötigt da der status später sonst noch aktiv ist.
              ProcedureReturn sText
              
            Case iB3
              CloseWindow(iWH)
              GetWindowKeyState(#VK_RBUTTON);Wird benötigt da der status später sonst noch aktiv ist.
              ProcedureReturn ""
          
          EndSelect
          
        Case #PB_Event_SizeWindow
          ResizeGadget(iTH,#PB_Ignore,#PB_Ignore,WindowWidth(iWH)-30,#PB_Ignore)
          ResizeGadget(iEH,#PB_Ignore,#PB_Ignore,WindowWidth(iWH)-30,WindowHeight(iWH)-12-GadgetHeight(iB1)-12-GadgetY(iEH))
          ResizeGadget(iB1,#PB_Ignore,WindowHeight(iWH)-12-GadgetHeight(iB1),#PB_Ignore,#PB_Ignore)
          ResizeGadget(iB2,#PB_Ignore,WindowHeight(iWH)-12-GadgetHeight(iB2),#PB_Ignore,#PB_Ignore)
          ResizeGadget(iB3,#PB_Ignore,WindowHeight(iWH)-12-GadgetHeight(iB3),#PB_Ignore,#PB_Ignore)
      EndSelect
    EndIf
  Until iEvent = #PB_Event_CloseWindow And EventWindow()=iWH
  CloseWindow(iWH)
  GetWindowKeyState(#VK_RBUTTON);Wird benötigt da der status später sonst noch aktiv ist.
EndProcedure


;Multiselct files seperated with "|"
Procedure.s OwnFileRequester(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i, Flags.i=0, SaveFileRequester.i=0)
  Protected iWH.i, iSplitter.i, iFileNameText.i
  Protected iTH.i, iAddresse.i
  Protected iEH.i, sFile.s
  Protected iEH2.i, iPattern.i
  Protected iB1.i, i.i
  Protected iB2.i
  Protected iB3.i
  Protected iEvent.i
  
  CompilerIf #USE_OEM_VERSION
    If StandardDatei=""
      StandardDatei=GetCurrentDirectory()
    EndIf
  CompilerEndIf
  
  
  iWH = OpenWindow(#PB_Any,#PB_Ignore,#PB_Ignore,500,350,Titel,#PB_Window_MinimizeGadget|#PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)
  If iWH=#Null
    ProcedureReturn ""
  EndIf

  iEH = ExplorerTreeGadget(#PB_Any,0,0,0,0,StandardDatei,#PB_Explorer_NoLines | #PB_Explorer_NoFiles | #PB_Explorer_AutoSort|#PB_Explorer_NoButtons)
  iEH2 = ExplorerListGadget(#PB_Any,0,0,0,0,GetPathPart(StandardDatei)+StringField(Pattern, PatternPosition*2+2,"|"),#PB_Explorer_AlwaysShowSelection|#PB_Explorer_NoLines  | #PB_Explorer_AutoSort|Flags|#PB_Explorer_NoParentFolder)
  iSplitter=SplitterGadget(#PB_Any, 5, 5, 300, 300, iEH, iEH2,#PB_Splitter_Vertical )
  SetGadgetState(iSplitter, 100)
  iFileNameText=TextGadget(#PB_Any,5, 0, 70, 20, Language(#L_FILE))
  iAddresse=StringGadget(#PB_Any, 75, 0, 0, 20, "")
  
  iPattern = ComboBoxGadget(#PB_Any, 0, 0, 120, 20)
  
  For i=1 To CountString(Pattern, "|") Step 2
    AddGadgetItem(iPattern, -1, StringField(Pattern, i, "|"))
  Next  
  SetGadgetState(iPattern, PatternPosition)
  
  iB1 = ComboBoxGadget(#PB_Any, 5, 0, 110, 23);ButtonGadget(#PB_Any,10,312,80,23,"Ansicht")
  AddGadgetItem(iB1, -1, Language(#L_LARGE_ICON))
  AddGadgetItem(iB1, -1, Language(#L_SMALL_ICON))
  AddGadgetItem(iB1, -1, Language(#L_LIST))
  AddGadgetItem(iB1, -1, Language(#L_REPORT))
  SetGadgetState(iB1, 3)
  If SaveFileRequester  
    iB2 = ButtonGadget(#PB_Any,138,312,80,23,Language(#L_SAVE),#PB_Button_Default)
  Else
    iB2 = ButtonGadget(#PB_Any,138,312,80,23,Language(#L_LOAD),#PB_Button_Default)
  EndIf  
  iB3 = ButtonGadget(#PB_Any,223,312,80,23,Language(#L_CANCEL))
  
  WindowBounds(iWH,315,275,#PB_Ignore,#PB_Ignore)
  
  Repeat
    iEvent = WaitWindowEvent()
    ProcessVIS()
    If EventWindow()=iWH
      Select iEvent
        
        Case #PB_Event_Gadget
          Select EventGadget()
            Case iEH  
              If EventType()=#PB_EventType_LeftDoubleClick
                SetGadgetText(iEH2, GetGadgetText(iEH)+StringField(Pattern, PatternPosition*2+2,"|"))
              EndIf
              
            Case iEH2  
              If EventType()=#PB_EventType_LeftClick
                If GetGadgetState(iEH2)>-1
                  If Flags=#PB_Explorer_MultiSelect
                    sFile=""
                    For i=0 To CountGadgetItems(iEH2)
                      If GetGadgetItemState(iEH2, i)=#PB_Explorer_File|#PB_Explorer_Selected Or GetGadgetItemState(iEH2, i)=#PB_Explorer_Directory|#PB_Explorer_Selected 
                        If sFile=""
                          sFile=GetGadgetText(iEH2)+GetGadgetItemText(iEH2, i)
                        Else
                          sFile=sFile+"|"+GetGadgetText(iEH2)+GetGadgetItemText(iEH2, i)
                        EndIf  
                      EndIf
                    Next
                    SetGadgetText(iAddresse, sFile)
                    
                  Else
                    sFile=GetGadgetText(iEH2)+GetGadgetItemText(iEH2, GetGadgetState(iEH2))
                    SetGadgetText(iAddresse, sFile)
                  EndIf
                  SetGadgetText(iEH, GetPathPart(GetGadgetText(iEH2)))
                EndIf
              EndIf
              If EventType()=#PB_EventType_LeftDoubleClick
                sFile=GetGadgetText(iAddresse)
                CloseWindow(iWH)
                ProcedureReturn sFile
              EndIf
              
            Case iPattern
              If EventType()=#PB_EventType_TitleChange
                PatternPosition=GetGadgetState(iPattern)
                SetGadgetText(iEH2, GetGadgetText(iEH2)+StringField(Pattern, PatternPosition*2+2,"|"))
              EndIf
              
            Case iB1
              If EventType()=#PB_EventType_TitleChange
                SetGadgetAttribute(iEH2, #PB_Explorer_DisplayMode, GetGadgetState(iB1))
              EndIf  
              
            Case iB2
              If GetGadgetText(iAddresse)<>""
                sFile=GetGadgetText(iAddresse)
                CloseWindow(iWH)
                ProcedureReturn sFile
              EndIf  
              
            Case iB3
              CloseWindow(iWH)
              ProcedureReturn ""
          
          EndSelect
          
        Case #PB_Event_SizeWindow
          ResizeGadget(iSplitter,#PB_Ignore,#PB_Ignore,WindowWidth(iWH)-10,WindowHeight(iWH)-42-GadgetHeight(iB1)-12-GadgetY(iEH))
          ResizeGadget(iB1,#PB_Ignore,WindowHeight(iWH)-12-GadgetHeight(iB1),#PB_Ignore,#PB_Ignore)
          ResizeGadget(iB2,WindowWidth(iWH)-170,WindowHeight(iWH)-12-GadgetHeight(iB2),#PB_Ignore,#PB_Ignore)
          ResizeGadget(iB3,WindowWidth(iWH)-90,WindowHeight(iWH)-12-GadgetHeight(iB3),#PB_Ignore,#PB_Ignore)
          ResizeGadget(iFileNameText,#PB_Ignore,WindowHeight(iWH)-60,#PB_Ignore,#PB_Ignore)
          ResizeGadget(iAddresse,#PB_Ignore,WindowHeight(iWH)-62,WindowWidth(iWH)-210,#PB_Ignore)
          ResizeGadget(iPattern,WindowWidth(iWH)-130,WindowHeight(iWH)-62,#PB_Ignore,#PB_Ignore)
          
      EndSelect
    EndIf
    
  Until iEvent = #PB_Event_CloseWindow And EventWindow()=iWH
  CloseWindow(iWH)
  GetWindowKeyState(#VK_RBUTTON);Wird benötigt da der status später sonst noch aktiv ist.
EndProcedure



Procedure.s PasswordRequester(sTitle.s, sText.s, sString.s = "", iWidth.i = 400, iPassword = #True, sFile.s="")
  Protected iHeight.i, iParent.i, iWindow.i,iContainer.i, iText.i, iFlag.i, iString.i, iButton.i, Event.i, Quit.i, sResult.s, iButton_Cancel.i, iEventGadget.i, iStorePW.i
  DisableWindows(#True)
  
  iHeight.i = 100
  If IsWindow(#WINDOW_MAIN)
    iParent=WindowID(#WINDOW_MAIN)
  Else
    iParent=0
  EndIf  
  iWindow.i = OpenWindow(#PB_Any, 0, 0, iWidth, iHeight, sTitle, #PB_Window_ScreenCentered|#PB_Window_SystemMenu, iParent)
  
  iText.i = TextGadget(#PB_Any, 80, 7, iWidth-90, 20, sText)
  iFlag = #False
  If iPassword = #True:iFlag = #PB_String_Password:EndIf

  
  iString = StringGadget(#PB_Any, 80, 30, iWidth-85, 20, sString, iFlag)
  iContainer = ContainerGadget(#PB_Any,0,60,iWidth, iHeight-60,#PB_Container_BorderLess )
  SetGadgetColor(iContainer,  #PB_Gadget_BackColor, #White)
 
 
  iStorePW = CheckBoxGadget(#PB_Any, 5, 15, iWidth-160, 20, Language(#L_STOREPW))  
  ;SetGadgetColor(iStorePW,  #PB_Gadget_BackColor, #White);WIRD ÜBER PROPERTY GEMACHT
  SetProp_(GadgetID(iStorePW), "passwordCheckBox", #True)
  
  
  ; Achtung der Cancel button darf nicht der letzte sein, da scheinbar aus irgendwelchen grund ein klickereignis ausgelöst wird, wenn dei Entertaste gedrückt wird
  iButton_Cancel = ButtonGadget(#PB_Any, iWidth-75, 10, 70, 24, Language(#L_CANCEL)  )  
  iButton = ButtonGadget(#PB_Any, iWidth-150, 10, 70, 24, "Ok")
  
  CloseGadgetList()
  ImageGadget(#PB_Any, 4, 4, 64, 64, ImageID(#SPRITE_TRESOR))
   
  SetFocus_(GadgetID(iString))
  Repeat
    Event = WaitWindowEvent()
    ProcessVIS()
    If EventWindow() <> iWindow:Event=#False:EndIf
    If Event = #PB_Event_Gadget 
      iEventGadget=EventGadget()
      If iEventGadget = iButton And GetGadgetText(iString) <> ""
        Quit = 1
        sResult.s = GetGadgetText(iString)
      EndIf
      If iEventGadget = iButton_Cancel
        Quit = 1
        sResult.s=""
      EndIf
      
    EndIf
     If Event = #WM_CHAR
       If EventwParam()=#VK_RETURN And GetGadgetText(iString)<>""
         ;Debug "return"
         Quit = 1
         sResult.s=GetGadgetText(iString)
       EndIf
     EndIf
    If Event = #PB_Event_CloseWindow
      Quit = 1
      sResult.s = ""
    EndIf
  Until Quit = 1
  
  If sResult And GetGadgetState(iStorePW)
    StorePassword(sDataBaseFile ,sResult, sFile.s)
  EndIf
  CloseWindow(iWindow)
  
  DisableWindows(#False)
  ProcedureReturn sResult
EndProcedure




Prototype.i SHMessageBoxCheckW(hWnd.i, text.p-unicode, title.p-unicode, style.i, defaultResult.i, keyName.p-unicode)
Procedure MessageBoxCheck(title.s, text.s, iconStyle.i, uniqueKey.s)
  Protected ParentWindow, pid, shlwapi, SHMessageBoxCheckW.SHMessageBoxCheckW
  shlwapi = LoadLibrary_("shlwapi.dll")
  If shlwapi
    SHMessageBoxCheckW.SHMessageBoxCheckW = GetProcAddress_(shlwapi, "SHMessageBoxCheckW")
  EndIf   
  
  If SHMessageBoxCheckW
    
    ParentWindow = GetForegroundWindow_()
    
    GetWindowThreadProcessId_(ParentWindow,@pid)
    If pid <> GetCurrentProcessId_()
      ParentWindow = #Null ; Keine 100% Lösung!
    EndIf

    SHMessageBoxCheckW(ParentWindow, text, title, #MB_OK | iconStyle, #IDOK, uniqueKey)
  Else
    MessageRequester(title,text, #PB_MessageRequester_Ok | iconStyle)
  EndIf
  If shlwapi
    FreeLibrary_(shlwapi)
  EndIf   
EndProcedure  


;MessageBoxCheck("TITEL","HALLO"+Chr(13)+"WELT!!",#MB_ICONWARNING, "MEINTKEY2")





Procedure SetChronicAutocompleteList(*DB)
  If IsMenu(#MENU_MAIN)
    Protected iRow, i.i, loadDB.i
    If *DB=#Null
      If *PLAYLISTDB:*DB=*PLAYLISTDB:EndIf
      If *DB=#Null
        *DB=DB_Open(sDataBaseFile)
        loadDB=#True
      EndIf
    EndIf  
  
    If *DB
      DB_Query(*DB,"SELECT * FROM CHRONIC ORDER BY id DESC LIMIT 25")
      iRow = 0
      While DB_SelectRow(*DB, iRow)
        SetMenuItemText(#MENU_MAIN, #MENU_CHRONIC_1+iRow, GetFilePart(DB_GetAsString(*DB, 1)))
        DisableMenuItem(#MENU_MAIN, #MENU_CHRONIC_1+iRow, #False)
        iRow+1
      Wend  
      DB_EndQuery(*DB)
  
      If loadDB=#True
        If *DB
          DB_Close(*DB)
        EndIf
      EndIf  
    EndIf  
  EndIf
EndProcedure  

Procedure SaveProxySettings(Proxy.s, Port.s, bypass.i, UseIESettings.i, NoRedirect.i)
  Protected *DB
  *DB=DB_Open(sDataBaseFile)
  If *DB
    Settings(#SETTINGS_PROXY)\sValue=Proxy
    SetSettingFast(*DB, #SETTINGS_PROXY, Settings(#SETTINGS_PROXY)\sValue)
    
    Settings(#SETTINGS_PROXY_PORT)\sValue=Port
    SetSettingFast(*DB, #SETTINGS_PROXY_PORT, Settings(#SETTINGS_PROXY_PORT)\sValue)
    
    Settings(#SETTINGS_PROXY_BYPASS_LOCAL)\sValue=Str(bypass)
    SetSettingFast(*DB, #SETTINGS_PROXY_BYPASS_LOCAL, Settings(#SETTINGS_PROXY_BYPASS_LOCAL)\sValue)
    
    Settings(#SETTINGS_PROXY_USE_IE_SETTINGS)\sValue=Str(UseIESettings)
    SetSettingFast(*DB, #SETTINGS_PROXY_USE_IE_SETTINGS, Settings(#SETTINGS_PROXY_USE_IE_SETTINGS)\sValue)
    
    Settings(#SETTINGS_PROXY_NoRedirect)\sValue=Str(NoRedirect)
    SetSettingFast(*DB, #SETTINGS_PROXY_NoRedirect, Settings(#SETTINGS_PROXY_NoRedirect)\sValue)
    
    DB_Close(*DB)
  EndIf
EndProcedure
Procedure.s URLRequester(title.s, bigText.s, smallText.s, sampleText.s, sample.s, stream.s, okbutton.s, cancelButton.s)
  Protected result.s="", requester.i, Event.i, SampleWidth.i
  Protected bigTextGadget.i, smallTextGadget.i, sampleGadget.i, urlGadget.i, okButtonGadget.i, cancelButtonGadget.i
  Protected fontBig.i, fontSmall.i, RedirectGadget.i
  Protected proxyFrame.i, ProxyLink.i, extendedWindow.i, IPTextGadget.i, IPGadget.i, PortGadget.i, PortTextGadget.i, BypassLocalGadget.i, UseIESettingsGadget.i
  fontBig=LoadFont(#PB_Any, "Segoe UI",12)
  fontSmall=LoadFont(#PB_Any, "Segoe UI",10)
  
  
  
  
  requester=OpenWindow(#PB_Any, 0, 0, 500, 140, title, #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)
  If requester
    WindowBounds(requester, 500, 140, #PB_Ignore, 140) 
    
    
    bigTextGadget = TextGadget(#PB_Any, 10, 10, 380, 40, bigText)
    smallTextGadget = TextGadget(#PB_Any, 10, 45, 200, 30, smallText)
    sampleGadget = HyperLinkGadget(#PB_Any, 290, 55, 200, 22, sampleText, RGB(50,50,255))
    
    urlGadget = StringGadget(#PB_Any, 10,80, 270, 22, stream)
    okButtonGadget = ButtonGadget(#PB_Any, 300, 80, 90, 25, okbutton)
    cancelButtonGadget = ButtonGadget(#PB_Any, 400, 80, 90, 25, cancelButton)
    
    
    proxyFrame = FrameGadget(#PB_Any, 5, 110, 490, 145, "") 
    ProxyLink = HyperLinkGadget(#PB_Any, 20, 122, 300, 22, Language(#L_CHANGE_PROXY_SETTINGS), RGB(50,50,255))
    
    IPTextGadget = TextGadget(#PB_Any, 15, 157, 25, 20,Language(#L_IP))
    IPGadget = StringGadget(#PB_Any, 35, 155, 200, 20, "")
    PortTextGadget = TextGadget(#PB_Any, 240, 157, 30, 20,Language(#L_PORT))
    PortGadget = StringGadget(#PB_Any, 280, 155, 100, 20, "", #PB_String_Numeric)
    
    BypassLocalGadget = CheckBoxGadget(#PB_Any, 15, 190, 200, 20, Language(#L_BYPASS_LOCAL))
    UseIESettingsGadget = CheckBoxGadget(#PB_Any, 15, 220, 200, 20, Language(#L_USE_IE_SETTINGS))
    
    RedirectGadget = CheckBoxGadget(#PB_Any, 240, 190, 250, 40, Language(#L_NO_AUTOMATIC_REDIRECT))
    
    If IPTextGadget And proxyFrame And ProxyLink And IPGadget And PortTextGadget And PortGadget And BypassLocalGadget And UseIESettingsGadget
    If bigTextGadget And smallTextGadget And sampleGadget And urlGadget And okButtonGadget And cancelButtonGadget
      SetGadgetColor(sampleGadget, #PB_Gadget_FrontColor, RGB(0,0,150))
      SetGadgetColor(ProxyLink, #PB_Gadget_FrontColor, RGB(0,0,150))
      ;SetGadgetState(BypassLocalGadget, #True)
      BalloonTip(WindowID(requester), sampleGadget, sample , sampleText, #TOOLTIP_INFO_ICON)
      URLCOMPLETE_AddGadget(urlGadget)
      
      If fontBig And fontSmall
        SetGadgetFont(bigTextGadget, FontID(fontBig))
        SetGadgetFont(smallTextGadget, FontID(fontSmall))
        SetGadgetFont(sampleGadget, FontID(fontSmall))
      EndIf
      
      
      SetGadgetText(IPGadget, Settings(#SETTINGS_PROXY)\sValue)
      SetGadgetText(PortGadget, Settings(#SETTINGS_PROXY_PORT)\sValue)
      SetGadgetState(BypassLocalGadget,Val(Settings(#SETTINGS_PROXY_BYPASS_LOCAL)\sValue))
      SetGadgetState(UseIESettingsGadget,Val(Settings(#SETTINGS_PROXY_USE_IE_SETTINGS)\sValue))
      SetGadgetState(RedirectGadget,Val(Settings(#SETTINGS_PROXY_NoRedirect)\sValue))
      
      SetActiveGadget(urlGadget)
      
      Repeat
        Event=WaitWindowEvent()
        ProcessVIS()
        If Event=#WM_CHAR
          If EventwParam() = #VK_RETURN
              result=GetGadgetText(urlGadget)
              If result
                Event=#PB_Event_CloseWindow
                SaveProxySettings(GetGadgetText(IPGadget), GetGadgetText(PortGadget), GetGadgetState(BypassLocalGadget), GetGadgetState(UseIESettingsGadget), GetGadgetState(RedirectGadget))
                
                URLCOMPLETE_AddCacheEntry(result)
                result=URLCOMPLETE_NormalizeURL(result)
              EndIf
          EndIf  
        EndIf  
        If EventWindow()<>requester
          Event=0
        EndIf  
        If Event=#PB_Event_Gadget
          Select EventGadget()
            Case cancelButtonGadget
              Event=#PB_Event_CloseWindow  
              
            Case okButtonGadget
              Event=#PB_Event_CloseWindow
              result=GetGadgetText(urlGadget)
              If result
                SaveProxySettings(GetGadgetText(IPGadget), GetGadgetText(PortGadget), GetGadgetState(BypassLocalGadget), GetGadgetState(UseIESettingsGadget), GetGadgetState(RedirectGadget))
                
                URLCOMPLETE_AddCacheEntry(result)
                result=URLCOMPLETE_NormalizeURL(result)
              EndIf
              
            Case ProxyLink
              If extendedWindow
                extendedWindow=#False
                WindowBounds(requester, #PB_Ignore, 140, #PB_Ignore, 140) 
                ResizeWindow(requester, #PB_Ignore, #PB_Ignore, #PB_Ignore, 140)
              Else  
                extendedWindow=#True
                WindowBounds(requester, #PB_Ignore, 260, #PB_Ignore, 260) 
                ResizeWindow(requester, #PB_Ignore, #PB_Ignore, #PB_Ignore, 260)
              EndIf
              
          EndSelect      
        EndIf  
        If event=#PB_Event_SizeWindow
          ResizeGadget(urlGadget,#PB_Ignore, #PB_Ignore, WindowWidth(requester)-230, #PB_Ignore)
          ResizeGadget(okButtonGadget,WindowWidth(requester)-200, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizeGadget(cancelButtonGadget,WindowWidth(requester)-100, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizeGadget(sampleGadget,WindowWidth(requester)-200, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizeGadget(proxyFrame, #PB_Ignore, #PB_Ignore, WindowWidth(requester)-10, #PB_Ignore)
    
        EndIf  
        
        
      Until Event=#PB_Event_CloseWindow  
        
    EndIf
    EndIf
    CloseWindow(requester)
  EndIf
  ProcedureReturn result
EndProcedure  


Procedure ConnectionFailedRequester(InetCheck=#True)
  Protected result.i=#False, requester.i, Event.i, SampleWidth.i
  Protected bigTextGadget.i, smallTextGadget.i, sampleGadget.i, urlGadget.i, okButtonGadget.i, cancelButtonGadget.i
  Protected fontBig.i, fontSmall.i, RedirectGadget.i
  Protected proxyFrame.i, ProxyLink.i, extendedWindow.i, IPTextGadget.i, IPGadget.i, PortGadget.i, PortTextGadget.i, BypassLocalGadget.i, UseIESettingsGadget.i
  
  If InetCheck
    If GetAllServerTime()>0;CHECK IS REALLY NO INTERNET USEABLE
      WriteLog("Internet is available but something is wrong!")
      ProcedureReturn #False
    Else
      WriteLog("Internet is not available!")
      ProcedureReturn #False      
    EndIf 
  EndIf
  
  fontBig=LoadFont(#PB_Any, "Segoe UI",12)
  fontSmall=LoadFont(#PB_Any, "Segoe UI",10)
  
 
  
  
  requester=OpenWindow(#PB_Any, 0, 0, 500, 140, Language(#L_CANT_CONNECT_TO_SERVER), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)
  If requester
    WindowBounds(requester, 500, 140, 500, 140) 
    
    
    bigTextGadget = TextGadget(#PB_Any, 10, 10, 480, 30, Language(#L_CHECK_FIRWALL_AND_PROXY_SETTINGS))
    ;smallTextGadget = TextGadget(#PB_Any, 10, 45, 200, 30, smallText)
    ;sampleGadget = HyperLinkGadget(#PB_Any, 290, 55, 200, 22, sampleText, RGB(50,50,255))
    
    ;urlGadget = StringGadget(#PB_Any, 10,80, 270, 22, stream)
    okButtonGadget = ButtonGadget(#PB_Any, 300, 80, 90, 25, Language(#L_RETRY))
    cancelButtonGadget = ButtonGadget(#PB_Any, 400, 80, 90, 25, Language(#L_CANCEL))
    
    ImageGadget(#SPRITE_NO_CONNECTION, 20, 40, 64, 70, ImageID(#SPRITE_NO_CONNECTION))
    
    proxyFrame = FrameGadget(#PB_Any, 5, 110, 490, 145, "") 
    ProxyLink = HyperLinkGadget(#PB_Any, 20, 122, 300, 22, Language(#L_CHANGE_PROXY_SETTINGS), RGB(50,50,255))
    
    IPTextGadget = TextGadget(#PB_Any, 15, 157, 25, 20,Language(#L_IP))
    IPGadget = StringGadget(#PB_Any, 35, 155, 200, 20, "")
    PortTextGadget = TextGadget(#PB_Any, 240, 157, 30, 20,Language(#L_PORT))
    PortGadget = StringGadget(#PB_Any, 280, 155, 100, 20, "", #PB_String_Numeric)
    
    BypassLocalGadget = CheckBoxGadget(#PB_Any, 15, 190, 200, 20, Language(#L_BYPASS_LOCAL))
    UseIESettingsGadget = CheckBoxGadget(#PB_Any, 15, 220, 200, 20, Language(#L_USE_IE_SETTINGS))
    
    RedirectGadget = CheckBoxGadget(#PB_Any, 240, 190, 250, 20, Language(#L_NO_AUTOMATIC_REDIRECT))

      SetGadgetColor(ProxyLink, #PB_Gadget_FrontColor, RGB(0,0,150))
      ;SetGadgetState(BypassLocalGadget, #True)

      URLCOMPLETE_AddGadget(urlGadget)
      
      If fontBig And fontSmall
        SetGadgetFont(bigTextGadget, FontID(fontBig))
        SetGadgetFont(smallTextGadget, FontID(fontSmall))
        SetGadgetFont(sampleGadget, FontID(fontSmall))
      EndIf
      
      
      SetGadgetText(IPGadget, Settings(#SETTINGS_PROXY)\sValue)
      SetGadgetText(PortGadget, Settings(#SETTINGS_PROXY_PORT)\sValue)
      SetGadgetState(BypassLocalGadget,Val(Settings(#SETTINGS_PROXY_BYPASS_LOCAL)\sValue))
      SetGadgetState(UseIESettingsGadget,Val(Settings(#SETTINGS_PROXY_USE_IE_SETTINGS)\sValue))
      SetGadgetState(RedirectGadget,Val(Settings(#SETTINGS_PROXY_NOREDIRECT)\sValue))  
      
      Repeat
        Event=WaitWindowEvent()
        ProcessVIS()
        If EventWindow()<>requester
          Event=0
        EndIf  
        If Event=#PB_Event_Gadget
          Select EventGadget()
            Case cancelButtonGadget
              Event=#PB_Event_CloseWindow  
              result=#False
              
            Case okButtonGadget
              Event=#PB_Event_CloseWindow
              result=#True
              If result
                SaveProxySettings(GetGadgetText(IPGadget), GetGadgetText(PortGadget), GetGadgetState(BypassLocalGadget), GetGadgetState(UseIESettingsGadget), GetGadgetState(RedirectGadget))
              EndIf
              
            Case ProxyLink
              If extendedWindow
                extendedWindow=#False
                WindowBounds(requester, #PB_Ignore, 140, #PB_Ignore, 140) 
                ResizeWindow(requester, #PB_Ignore, #PB_Ignore, #PB_Ignore, 140)
              Else  
                extendedWindow=#True
                WindowBounds(requester, #PB_Ignore, 260, #PB_Ignore, 260) 
                ResizeWindow(requester, #PB_Ignore, #PB_Ignore, #PB_Ignore, 260)
              EndIf
              
          EndSelect      
        EndIf  
        If event=#PB_Event_SizeWindow
          ResizeGadget(okButtonGadget,WindowWidth(requester)-200, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizeGadget(cancelButtonGadget,WindowWidth(requester)-100, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizeGadget(proxyFrame, #PB_Ignore, #PB_Ignore, WindowWidth(requester)-10, #PB_Ignore)
    
        EndIf  
        
        
      Until Event=#PB_Event_CloseWindow  
        
    CloseWindow(requester)
  EndIf
  ProcedureReturn result
EndProcedure


Procedure MissingCodecRequester(Codecname.s, Codeclink.s)
  Protected Window.i, RequesterQuit.i, Event, iButton1, iButton2, iButton3, sText.s, link
  Window = OpenWindow(#PB_Any, 0 ,0, 550, 105, Language(#L_ERROR_CANT_LOAD_MEDIA), #PB_Window_ScreenCentered|#PB_Window_SystemMenu)
  If Window
    If IsImage(#SPRITE_ERROR)
      ResizeImage(#SPRITE_ERROR, 60, 60, #PB_Image_Smooth)
      ImageGadget(#PB_Any, 5, 5, 60, 60, ImageID(#SPRITE_ERROR))
    EndIf
    sText.s=Language(#L_CODEC_IS_MISSING_PLS_DOWNLOAD)
    sText=ReplaceString(sText,"%CODECNAME%", Codecname)
    sText=ReplaceString(sText,"  ", " ")
    
    TextGadget(#PB_Any, 75, 10, 295, 70, sText)
    link=HyperLinkGadget(#PB_Any, 5, 80, 300, 20, Codeclink, #Blue)
    
    
    iButton1 = ButtonGadget(#PB_Any, 390, 10, 150, 24, Language(#L_DOWNLOADCODECS))
    iButton2 = ButtonGadget(#PB_Any, 390, 40, 150, 24, Language(#L_CANCEL))
    
    Repeat
      ProcessVIS()
      Event = WaitWindowEvent(100)
      If EventWindow() = Window
        If Event=#PB_Event_Gadget
          Select EventGadget()
            Case iButton1
              RunProgram(Codeclink)
              RequesterQuit = 1
            Case iButton2
              RequesterQuit = 1
            Case link
              RunProgram(Codeclink)
          EndSelect
        EndIf
        If Event = #PB_Event_CloseWindow
          RequesterQuit = 1
        EndIf
      EndIf
    Until RequesterQuit = 1
    If IsWindow(Window):CloseWindow(Window):EndIf

  EndIf
EndProcedure


; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 729
; FirstLine = 539
; Folding = hyw0-
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
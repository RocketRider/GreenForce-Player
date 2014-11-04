;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************
#PLAYER_VERSION = "1.00"
#USE_OEM_VERSION = #False
#WINDOW_MAIN = 0
#GFP_LANGUAGE_PLAYER = #False

Structure MediaFile
  sFile.s
  Memory.i
  sRealFile.s
  iPlaying.i
  qOffset.q
  *StreamingFile
EndStructure
Global MediaFile.MediaFile
 

Procedure Requester_Cant_Update()
  
EndProcedure  

XIncludeFile "include\GFP_MachineID.pbi"
XIncludeFile "include\GFP_Settings.pbi"
XIncludeFile "include\GFP_Language.pbi"
XIncludeFile "include\GFP_SpecialFolder.pbi"
EnableExplicit
Define sDatabaseFile.s, i.i, event.i, Quit.i, sFile.s, sLine.s
Procedure __AnsiString(str.s)
  Protected *ptr
  *ptr = AllocateMemory(Len(str)+1)
  If *ptr
    PokeS(*ptr, str, -1,#PB_Ascii)
  EndIf
  ProcedureReturn *ptr
EndProcedure
Procedure GetDPI()
EndProcedure 
Procedure Requester_Error(sText.s)
  MessageRequester("Error", sText, #MB_ICONERROR)
EndProcedure  

sDatabaseFile.s = "data.sqlite";GetSpecialFolder(#CSIDL_APPDATA)+"\GF-Player\data.sqlite"
If FileSize(sDatabaseFile)<1
  sDatabaseFile="data.sqlite"
  If FileSize(sDatabaseFile)<1
    sDatabaseFile.s = OpenFileRequester("Select Database", sDatabaseFile, "*.*", 0)
  EndIf  
EndIf
If sDatabaseFile=""
  End
EndIf
InitLanguage(sDatabaseFile, #LANGUAGE_EN)


OpenWindow(0, 0, 0, 400, 430, "GFP - Add language", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)

ScrollAreaGadget(0, 0, 0, 400, 400, 350, iLastLanguageItem*30+100)
  TextGadget(#PB_Any, 5, 5, 150, 20, "Language name: (EN)", #PB_Text_Center)
  StringGadget(5, 165, 5, 200, 20, "")
  
  TextGadget(#PB_Any, 5, 50, 150, 20, "English text", #PB_Text_Center)
  TextGadget(#PB_Any, 165, 50, 200, 20, "Your text", #PB_Text_Center)
  
  Dim GadgetList.i(iLastLanguageItem)
  For i=0 To iLastLanguageItem-1
    StringGadget(#PB_Any, 5, 70 + i*30, 150, 20, Language(i), #PB_String_ReadOnly)
    GadgetList(i) = StringGadget(#PB_Any, 165, 70 + i*30, 200, 20, ""); Language(i)
  Next
CloseGadgetList()


ButtonGadget(1, 5, 405, 70, 20, "Load")
ButtonGadget(2, 80, 405, 70, 20, "Save")
ButtonGadget(3, 155, 405, 90, 20, "Insert into DB")
ButtonGadget(4, 325, 405, 70, 20, "Close")




Repeat
  Event = WaitWindowEvent()

  If Event = #PB_Event_CloseWindow  ; If the user has pressed on the close button
    Quit = #True
  EndIf
  If event = #PB_Event_Gadget
    Select EventGadget()
    Case 1 
      sFile.s = OpenFileRequester("Choose Language file","","All Files (*.*)|*.*",0)
      If sFile
        If ReadFile(1, sFile)
          sLine.s = ReadString(1, #PB_Unicode)
          SetGadgetText(5, sLine)
          While Eof(1)=0
            sLine.s = ReadString(1, #PB_Unicode)
            If Trim(sLine)
              SetGadgetText(GadgetList(Val(StringField(sLine, 1, ":"))), StringField(sLine, 2, ":"))
            EndIf
          Wend
        EndIf
        CloseFile(1)
      EndIf
      
    Case 2
      sFile.s = SaveFileRequester("Save Language file","","All Files (*.*)|*.*",0)
      If sFile
        If CreateFile(1, sFile)
          WriteStringN(1, GetGadgetText(5), #PB_Unicode)
          For i=0 To iLastLanguageItem-1
            WriteStringN(1, Str(i)+":"+GetGadgetText(GadgetList(i)), #PB_Unicode)
            
          Next
        EndIf
        CloseFile(1)
      EndIf
    Case 3
      sFile.s = OpenFileRequester("Choose Language file","","All Files (*.*)|*.*",0)
      If sFile
        If AddNewLanguage(sDatabaseFile, sFile)
          MessageRequester("Succsessfull updated", "Succsessfull updated!", #MB_ICONINFORMATION)
        Else
          MessageRequester("Error", "Can't update Databese.", #MB_ICONERROR)
        EndIf
      EndIf
      
    Case 4
      Quit = #True
    EndSelect
  EndIf
  
  
Until Quit = #True



; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 25
; Folding = y
; EnableUnicode
; EnableXP
; EnableUser
; EnableOnError
; UseIcon = data\Language.ico
; Executable = GFP-SDK\Language\GFP-LanguageTool.exe
; EnableCompileCount = 181
; EnableBuildCount = 52
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 0,1,1,0
; VersionField1 = 0,1,1,0
; VersionField2 = RRSoftware
; VersionField3 = GreenForce-Player Languagetool
; VersionField4 = 0.11
; VersionField5 = 0.11
; VersionField6 = GreenForce-Player Languagetool
; VersionField7 = Languagetool
; VersionField8 = GreenForce-Player Languagetool
; VersionField9 = (c) 2009 - 2010 RocketRider
; VersionField14 = http://www.RRSoftware.de
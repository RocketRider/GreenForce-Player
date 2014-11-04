;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2013 RocketRider *******
;***************************************



Procedure __MenuItem(MenuItemID.i, Text.s, ImageID=#Null)
  Protected Result
  If MenuItemID>=0 And MenuItemID<#MENU_LAST_ITEM+1
    If MenuLimitations(MenuItemID)=#False
      Result=MenuItem(MenuItemID.i, Text.s, ImageID)
    Else
      Result=#False
    EndIf
  Else
    Result=MenuItem(MenuItemID.i, Text.s, ImageID)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure __AddKeyboardShortcut(Window.i, Shortcut.i, MenuItemiD.i)
  Protected Result
  If MenuItemID>=0 And MenuItemID<#MENU_LAST_ITEM+1
    If MenuLimitations(MenuItemID)=#False
      Result=AddKeyboardShortcut(Window.i, Shortcut.i, MenuItemiD.i)
    Else
      Result=#False
    EndIf
  Else
    Result=AddKeyboardShortcut(Window.i, Shortcut.i, MenuItemiD.i)
  EndIf
  ProcedureReturn Result
EndProcedure


;-> Unicode, UTF8 Unterstützen (PeekS)
Procedure LoadLimitations(sFile.s)
  Protected iFile.i, MenuID.i
  iFile = ReadFile(#PB_Any, sFile)
  If iFile
    While Eof(iFile) = 0
      MenuID=Val(ReadString(iFile, #PB_Ascii))
      If MenuID>=0 And MenuID<#MENU_LAST_ITEM+1
        MenuLimitations(MenuID)=#True
      EndIf
    Wend
    CloseFile(iFile)
    ProcedureReturn #True
  Else
    CompilerIf #USE_OEM_VERSION
      OEM_MenuLimitation()
    CompilerEndIf
  EndIf
  ProcedureReturn #False
EndProcedure


; IDE Options = PureBasic 5.11 (Windows - x86)
; CursorPosition = 5
; Folding = 0
; EnableXP
; EnableUser
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
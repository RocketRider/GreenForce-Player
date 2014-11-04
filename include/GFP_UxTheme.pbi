;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit

Global g_UxThemeModule
Prototype.i SetWindowTheme(hWnd, pszSubAppName.p-unicode, pszSubIdList)

Procedure UxTheme_Init()
  g_UxThemeModule = LoadLibrary_("uxtheme.dll")
EndProcedure  

Procedure UxTheme_Free()
  If g_UxThemeModule
    FreeLibrary_(g_UxThemeModule)
    g_UxThemeModule = #Null
  EndIf  
EndProcedure

Procedure SetExplorerTheme(hWnd)
  Protected SetWindowTheme.SetWindowTheme
  If g_UxThemeModule
    SetWindowTheme.SetWindowTheme = GetProcAddress_(g_UxThemeModule, "SetWindowTheme")
    If SetWindowTheme
      SetWindowTheme(hWnd, "Explorer", #Null)
    EndIf
  EndIf
EndProcedure

; IDE Options = PureBasic 4.61 Beta 1 (Windows - x86)
; CursorPosition = 3
; Folding = -
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0
; EnableExeConstant
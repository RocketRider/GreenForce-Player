;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************


Enumeration
  #SETTINGS_LANGUAGE
  #SETTINGS_VOLUME
  #SETTINGS_REPEAT
  #SETTINGS_RANDOM
  #SETTINGS_VIDEORENDERER
  #SETTINGS_AUDIORENDERER
  #SETTINGS_SYSTRAY
  #SETTINGS_AUTOMATIC_UPDATE
  #SETTINGS_RAM_SIZE
  #SETTINGS_PHOTO_PATH
  #SETTINGS_BORDER_COLOR
  #SETTINGS_PLAYER_VERSION
  #SETTINGS_PLAYER_BUILD
  #SETTINGS_LOGLEVEL
  #SETTINGS_BKCOLOR
  #SETTINGS_PHOTO_FORMAT
  #SETTINGS_ICONSET
  #SETTINGS_USE_STATUSBAR
  #SETTINGS_EMPTY_2
  #SETTINGS_EMPTY_3
  #SETTINGS_PROXY
  #SETTINGS_PROXY_BYPASS_LOCAL
  #SETTINGS_PROXY_USE_IE_SETTINGS
  #SETTINGS_PROXY_PORT
  #SETTINGS_PROXY_NOREDIRECT
  #SETTINGS_EMPTY_10
  #SETTINGS_EMPTY_11
  #SETTINGS_EMPTY_12
  #SETTINGS_EMPTY_13
  #SETTINGS_EMPTY_14
  #SETTINGS_EMPTY_15
  #SETTINGS_EMPTY_16
  #SETTINGS_EMPTY_17
  #SETTINGS_EMPTY_18
  #SETTINGS_EMPTY_19
  #SETTINGS_EMPTY_20
  #SETTINGS_EMPTY_21
  #SETTINGS_EMPTY_22
  #SETTINGS_EMPTY_23
  #SETTINGS_EMPTY_24
  #SETTINGS_EMPTY_25
  #SETTINGS_EMPTY_26
  #SETTINGS_EMPTY_27
  #SETTINGS_EMPTY_28
  #SETTINGS_EMPTY_29
  #SETTINGS_RAM_SIZE_PER_FILE
  #SETTINGS_WINDOW_X
  #SETTINGS_WINDOW_Y
  #SETTINGS_WINDOW_WIDTH
  #SETTINGS_WINDOW_HEIGHT
  #SETTINGS_SNAPSHOT_NUM
  #SETTINGS_SINGLE_INSTANCE
  
  #SETTINGS_LAST
EndEnumeration

Structure Settings
  sKey.s
  sValue.s
  iID.i
EndStructure

Global Dim Settings.Settings(#SETTINGS_LAST)
Global iLastSettingsItem.i
Settings(#SETTINGS_LOGLEVEL)\sValue = "1"

XIncludeFile "include\GFP_LogFile.pbi"
XIncludeFile "include\GFP_Database.pbi"
EnableExplicit



Procedure.i LoadSettings(sDBFile.s)
  Protected *DB, iRow.i
  *DB = DB_Open(sDBFile)
  If *DB
    DB_Query(*DB, "SELECT * FROM SETTINGS ORDER BY ID")
    
    ;iRow = 0 ;Count Query Rows, for the Array size
    ;While DB_SelectRow(*DB, iRow):iRow + 1:Wend
    ;Global Dim Settings.Settings(iRow)
    ;iLastSettingsItem.i = iRow
    iLastSettingsItem.i = #SETTINGS_LAST

    iRow = 0
    While DB_SelectRow(*DB, iRow)
      Settings(iRow)\iID = DB_GetAsLong(*DB, 0)
      Settings(iRow)\sKey = DB_GetAsString(*DB, 1)
      Settings(iRow)\sValue = DB_GetAsString(*DB, 2)
      iRow + 1
    Wend
    
    DB_EndQuery(*DB)
    DB_Close(*DB)
    ;Debug DB_GetLastErrorString()
  Else
    WriteLog("Can't load Database!")
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure
Procedure SetSetting(sDBFile.s, iID.i, sValue.s)
  Protected *DB
  *DB = DB_Open(sDBFile)
  If *DB
    If DB_Query(*DB, "UPDATE SETTINGS SET Value = ? WHERE ID = "+Str(iID))
      DB_StoreAsString(*DB, 0, sValue)
      DB_StoreRow(*DB)
      DB_EndQuery(*DB)
      LoadSettings(sDBFile.s)
    EndIf
    DB_Close(*DB)
  Else
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure
Procedure SetSettingFast(*DB, iID.i, sValue.s)
  If *DB
    If DB_Query(*DB, "UPDATE SETTINGS SET Value = ? WHERE ID = "+Str(iID))
      DB_StoreAsString(*DB, 0, sValue)
      DB_StoreRow(*DB)
      DB_EndQuery(*DB)
    EndIf
  Else
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure

;{ Example

; 
; LoadSettings("data\data.sqlite")
; Debug Settings(#SETTINGS_LANGUAGE)\sValue
; Debug Settings(#SETTINGS_LANGUAGE)\sKey
; Debug Settings(#SETTINGS_LANGUAGE)\iID
; 
; SetSetting("data\data.sqlite", #SETTINGS_LANGUAGE, "1")
; 
; 
; Debug Settings(#SETTINGS_LANGUAGE)\sValue
; Debug Settings(#SETTINGS_LANGUAGE)\sKey
; Debug Settings(#SETTINGS_LANGUAGE)\iID


;}


; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 25
; Folding = z
; EnableThread
; EnableXP
; EnableOnError
; UseMainFile = Player.pb
; EnableCompileCount = 19
; EnableBuildCount = 0
; EnableExeConstant
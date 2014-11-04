;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************

;Create the Language table:
;CREATE TABLE LANGUAGE (id INT UNIQUE, DE VARCHAR(500), EN VARCHAR(500), FR VARCHAR(500))
XIncludeFile "include\GFP_Database.pbi"
;XIncludeFile "include\GFP_LogFile.pbi"
EnableExplicit

Enumeration
  #L_ENGLISH
  #L_EN
  #L_LANGUAGE
  #L_FILE
  #L_LOAD
  #L_QUIT
  #L_ABOUT
  #L_PLAYLIST
  #L_TITLE
  #L_LENGTH
  #L_NAMEOFPLAYLIST
  #L_NAMEEXISTS
  #L_HOMEPAGE
  #L_OPENFILEFROMCLIPBOARD
  #L_OPTIONS
  #L_GENERAL
  #L_MEDIA
  #L_VIDEORENDERER
  #L_AUDIORENDERER
  #L_WAVEOUTRENDERER
  #L_VMR9_Windowed
  #L_VMR9_Windowless 
  #L_VMR7_Windowed
  #L_VMR7_Windowless
  #L_OldVideoRenderer     
  #L_OverlayMixer  
  #L_AUTOUPDATE
  #L_USESYSTRAY
  #L_RAMUSAGE
  #L_CHECKFORUPDATE
  #L_CANCEL
  #L_SAVE
  #L_PICTUREPATH
  #L_INTERPRET
  #L_ALBUM
  #L_CHANGES_NEEDS_RESTART
  #L_WANTTORESTART
  #L_PLEASEWAIT
  #L_NEWVERSIONAVAILABLE
  #L_DOYOUWANTTOUPDATE
  #L_DOWNLOADCODECS
  #L_PLAY
  #L_STOP
  #L_NEXT
  #L_PREVIOUS
  #L_ASPECTRATION
  #L_AUTOMATIC
  #L_FORWARD
  #L_BACKWARD
  #L_SNAPSHOT
  #L_REPEAT
  #L_RANDOM
  #L_VOLUME
  #L_BREAK
  #L_SHOW
  #L_DIRECTSOUNDRENDERER
  #L_DEFAULT
  #L_LOGLEVEL
  #L_NONE
  #L_ERROR
  #L_DEBUG
  #L_BKCOLOR
  #L_FULLSCREEN
  #L_PICTUREFORMAT
  #L_FILEEXTENSION
  #L_EXPORTDATABASE
  #L_IMPORTDATABASE
  #L_DEFAULTDATABASE
  #L_DRM
  #L_PROTECTVIDEO
  #L_UNPROTECTVIDEO
  #L_PASSWORD
  #L_TIP
  #L_DISALLOWSNAPSHOT
  #L_ACTIVE
  #L_INACTIVE
  #L_EXTENDED
  #L_ALLOWUNPROTECT
  #L_TAGS
  #L_ERROR_CANT_LOAD_MEDIA
  #L_INPUT_INCORRECT
  #L_LOADURL
  #L_COMMENT
  #L_ERROR_CANT_ENCRYPT_FILE
  #L_ERASEPASSWORDS
  #L_THIS_FILE_ISNT_PROTECTED
  #L_IT_IS_NOT_ALLOWED_TO_REMOVE_DRM
  #L_STOREPW
  #L_PASSWORD_INPUT
  #L_DISABLEMIRRORTREIBER
  #L_VMR9
  #L_VMR7
  #L_EJECT
  #L_PLAYAUDIOCD
  #L_RAMUSAGEPERFILE
  #L_DSHOWDEFAULT
  #L_PLAYVIDEODVD
  #L_PLAYMEDIA
  #L_DRIVE
  #L_MENU
  #L_SPEED
  #L_MENU_TITLE
  #L_MENU_ROOT
  #L_MENU_SUBPICTURE
  #L_MENU_AUDIO
  #L_MENU_ANGLE
  #L_MENU_CHAPTER
  #L_CHAPTER
  #L_LOAD_FROM_DIRECTORY
  #L_NOUPDATEAVAIBLE
  #L_MINIMALMODE
  #L_STAYONTOP
  #L_CANT_UPDATE
  #L_VISUALIZATION
  #L_SELECT_ALL
  #L_DESELECT_ALL
  #L_SELECT_A_SAVE_FILE
  #L_SELECT_A_LOAD_FILE
  #L_SELECT_A_PW
  #L_PASSWORD_MUST_BE_THE_SAME
  #L_DRAWING
  #L_OFF
  #L_SINGLE_INSTANCE
  #L_PLS_DOWNLOAD_NEW_VERSION
  #L_ADD_VIS
  #L_CANT_INSTALL
  #L_CACHEPLAYLIST
  #L_THIS_NEEDS
  #L_DELETE
  #L_HIDE
  #L_COVERFLOW
  #L_NO_COVERS
  #L_ICONSET
  #L_DOYOUWANTTOREPLACETHEDB
  #L_CANT_REPLACE_DB
  #L_CANT_COPY_DB
  #L_HOW_TO_CREATE_COVERFLOW
  #L_CHOSE_MEDIA_FILE
  #L_OTHER
  #L_COVER
  #L_COVER_FILE
  #L_SELECT_A_DIFFERENT_FILE_FOR_OUTPUT
  #L_MOST_RECENT_LIST
  #L_CLEAR_CHRONIC
  #L_OWN_RENDERER
  #L_PASSWORD_VERIFY
  #L_DONATE
  #L_DOCUMENTATION
  #L_INSTALL_CODEC
  #L_INSTALL
  #L_DO_YOU_WANT_INSTALL_CODEC
  #L_ERROR_CANT_INSTALL_CODEC
  #L_CANT_DEINSTALL_THE_CODEC
  #L_DEINSTALL_CODEC
  #L_DO_YOU_WANT_DEINSTALL_CODEC
  #L_DEINSTALL
  #L_WARNING
  #L_YOU_NEED_A_CODEC_TO_PLAY_THIS_FILE
  #L_CREATE_NEW_FOLDER
  #L_LARGE_ICON
  #L_SMALL_ICON
  #L_LIST
  #L_REPORT
  #L_IT_IS_NOT_ALLOWED_TO_CAPTURE_THIS_VIDEO
  #L_LOAD_SUBTITLES
  #L_DISABLE_SUBTITLES
  #L_SAVE_MEDIAPOS
  #L_SUBTITLE_SIZE
  #L_ADDPLAYERTOVIDEO
  #L_NAME_OF_THE_FOLDER
  #L_NEW_FOLDER
  #L_ADD_PLAYLIST
  #L_REMOVE_PLAYLIST
  #L_IMPORT_PLAYLIST
  #L_EXPORT_PLAYLIST
  #L_ADD_TRACK
  #L_ADD_FOLDER
  #L_ADD_URL
  #L_REMOVE_TRACK
  #L_RENAME
  #L_THEME
  #L_URL_STREAMING
  #L_STREAM_MEDIA_FROM_URL
  #L_URL_TO_MEDIAFILE
  #L_SHOW_SAMPLE
  #L_EXPIRE_DATE
  #L_IP
  #L_PORT
  #L_CHANGE_PROXY_SETTINGS
  #L_BYPASS_LOCAL
  #L_FORCE_PROXY
  #L_DATA_BUFFERING
  #L_CANT_CONNECT_TO_SERVER
  #L_CHECK_FIRWALL_AND_PROXY_SETTINGS
  #L_RETRY
  #L_NO_AUTOMATIC_REDIRECT
  #L_IT_IS_NOT_ALLOWED_TO_PLAY_IN_VM
  #L_RESET_DISPLAY
  #L_YOU_CANT_ENCRYPT_THIS_FILE
  #L_USE_IE_SETTINGS
  #L_REALLY_DELETE_PLAYLIST
  #L_VIDEO_PROTECTION
  #L_THIS_MEDIA_NEEDS_OVERLAY
  #L_CLOSE_ALL_OTHER_PLAYER
  #L_CANT_PLAY_UNDER_2000
  #L_NOT_FORCE_SCREENSHOT_PROTECTION
  #L_NOT_RECOMMENDED
  #L_USED_CODEC
  #L_CODEC_DOWNLOAD_LINK
  #L_CODEC_IS_MISSING_PLS_DOWNLOAD
  #L_ENCRYPT ;*
  #L_ADD_ONLY_LOADABLE_FILES
  #L_ENCRYPTION_KEY
  #L_OUTPUT_FOLDER
  #L_SNAPSHOTPROTECTION
  #L_INCLUDE_ALL_FILES_IN_ONE_PLAYER
  #L_ALLOW_VIRTUAL_MACHINES
  #L_ICON
  #L_INFO
  #L_SELECT_AN_OUTPUT_FOLDER
  #L_ENCRYPTION_FINISHED
  #L_A_VIDEO_HAS_TO_BE_SELECTED
  #L_USE_COPY_PROTECTION
  #L_PROTECTION
  #L_YOU_MUST_USE_A_NEW_PLAYER_VERSION
  #L_ZOOM
  #L_CROP
  #L_AUDIO_TRACK
  #L_VIDEO_TRACK
  #L_ALWAYS_ON_TOP
  #L_AUDIO_DEVICE
  #L_AUDIO_CHANNELS
  #L_MACHINE_ID
  #L_GENERATE_MACHINE_ID
  #L_PARAMENTER
  
  
  #L_LAST
EndEnumeration

#LANGUAGE_DE = 1 ;Database Column
#LANGUAGE_EN = 2 ;Database Column
#LANGUAGE_FR = 3 ;Database Column
#LANGUAGE_TR = 4 ;Database Column
#LANGUAGE_NL = 5 ;Database Column
#LANGUAGE_ES = 6 ;Database Column
#LANGUAGE_EL = 7 ;Database Column
#LANGUAGE_PT = 8 ;Database Column
#LANGUAGE_IT = 9 ;Database Column
#LANGUAGE_SV = 10 ;Database Column
#LANGUAGE_BG = 11 ;Database Column
#LANGUAGE_RU = 12 ;Database Column
#LANGUAGE_SR = 13 ;Database Column
Global Dim Language.s(#L_LAST)
Global iLastLanguageItem.i
Global iUsedLanguage.i;=#LANGUAGE_EN
Procedure.i InitLanguage(sDBFile.s, iLanguage.i)
  Protected *LngDB, iRow.i
  iUsedLanguage.i=iLanguage
  *LngDB = DB_Open(sDBFile)
  If *LngDB
    DB_Query(*LngDB, "SELECT * FROM LANGUAGE ORDER BY ID")
    
    ;iRow = 0 ;Count Query Rows, for the Array size
    ;While DB_SelectRow(*LngDB, iRow):iRow + 1:Wend
    ;Global Dim Language.s(iRow)
    ;iLastLanguageItem.i = iRow
    iLastLanguageItem.i = #L_LAST
    
    iRow = 0
    While DB_SelectRow(*LngDB, iRow)
      If iRow>#L_LAST
        CompilerIf #GFP_LANGUAGE_PLAYER
          Requester_Cant_Update()
        CompilerElse  
          MessageRequester("Error","Language database is incorrect!")
          End
        CompilerEndIf
      EndIf  
      Language(iRow) = DB_GetAsString(*LngDB, iLanguage)
      Language(iRow) = RemoveString(Language(iRow),"[GG]", #PB_String_NoCase)
      iRow + 1
    Wend
    
    DB_EndQuery(*LngDB)
    DB_Close(*LngDB)
    ;Debug DB_GetLastErrorString()
  Else
    WriteLog("Can't load Database!")
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure
Procedure.s GetAllLanguages(sDBFile.s)
  Protected *LngDB, sResult.s, iColumns.i, iColumn.i
  *LngDB = DB_Open(sDBFile)
  If *LngDB
    
    
    DB_Query(*LngDB, "SELECT * FROM LANGUAGE ORDER BY ID")
    DB_SelectRow(*LngDB, 0)
    iColumns.i = DB_GetNumColumns(*LngDB)
    DB_GetColumnName(*LngDB, iColumn.i)
    
    For iColumn=1 To iColumns-1
      DB_SelectRow(*LngDB, 1)
      sResult.s + DB_GetAsString(*LngDB, iColumn);DB_GetColumnName(*LngDB, iColumn)
      DB_SelectRow(*LngDB, 0)
      sResult+" ("+DB_GetAsString(*LngDB, iColumn)+")"+Chr(10)
    Next
    
    DB_EndQuery(*LngDB)
    DB_Close(*LngDB)
  Else
    WriteLog("Can't load Database!")
    ProcedureReturn ""
  EndIf
  ProcedureReturn sResult
EndProcedure
Procedure GetOSLanguage()
  Protected iLanguage.i
  Select GetSystemDefaultLangID_()&%111111111 ; anstelle von GetUserDefaultLangID_() (Gebietsschema)
  Case #LANG_GERMAN
    iLanguage=#LANGUAGE_DE
  Case #LANG_FRENCH
    iLanguage=#LANGUAGE_FR
  Case #LANG_TURKISH
    iLanguage=#LANGUAGE_TR
  Case #LANG_DUTCH
    iLanguage=#LANGUAGE_NL
  Case #LANG_SPANISH
    iLanguage=#LANGUAGE_ES
  Case #LANG_GREEK
    iLanguage=#LANGUAGE_EL
  Case #LANG_PORTUGUESE
    iLanguage=#LANGUAGE_PT
  Case #LANG_ITALIAN
    iLanguage=#LANGUAGE_IT
  Case #LANG_SWEDISH
    iLanguage=#LANGUAGE_SV
  Case #LANG_BULGARIAN
    iLanguage=#LANGUAGE_BG
  Case #LANG_RUSSIAN
    iLanguage=#LANGUAGE_RU
  Case #LANG_SERBIAN
    iLanguage=#LANGUAGE_SR
  Default
    iLanguage=#LANGUAGE_EN
  EndSelect
  ProcedureReturn iLanguage
EndProcedure

Procedure AddNewLanguage(sDBFile.s, sNewLanguageFile.s)
  Protected *LngDB, iRow.i, iNewLng.i, sLine.s, iColumn.i, sColumn.s, iID.i, update=#False, i.i
  *LngDB = DB_Open(sDBFile)
  If *LngDB
    iNewLng.i = ReadFile(#PB_Any, sNewLanguageFile.s)
    If iNewLng
      sLine.s = Trim(ReadString(iNewLng, #PB_Unicode))
      
      DB_Query(*LngDB, "SELECT * FROM LANGUAGE")
      DB_SelectRow(*LngDB, 0)
      iColumn.i = DB_GetNumColumns(*LngDB)-1
      For i=0 To iColumn
        If sColumn.s = DB_GetColumnName(*LngDB, iColumn)
          update=#True
        EndIf  
      Next  
      DB_EndQuery(*LngDB)
      sColumn = sLine
      If update=#False
        DB_UpdateSync(*LngDB, "ALTER TABLE LANGUAGE ADD COLUMN "+sLine+" VARCHAR(500)")
      EndIf  

      
;       DB_Query(*LngDB, "SELECT * FROM LANGUAGE")
;       DB_SelectRow(*LngDB, 0)
;       iColumn.i = DB_GetNumColumns(*LngDB)-1
;       sColumn.s = DB_GetColumnName(*LngDB, iColumn)
;       DB_EndQuery(*LngDB)
      
      While Eof(iNewLng) = #False 
        sLine.s = ReadString(iNewLng, #PB_Unicode)
        If Trim(sLine)
          iID.i = Val(StringField(sLine, 1, ":"))
          If DB_Query(*LngDB, "UPDATE LANGUAGE SET "+sColumn.s+" = ? WHERE ID = "+Str(iID))
            DB_StoreAsString(*LngDB, 0, Trim(StringField(sLine, 2, ":")))
            DB_StoreRow(*LngDB)
          EndIf
          DB_EndQuery(*LngDB)
        EndIf
      Wend
      CloseFile(iNewLng.i); 2010-04-11 Verschoben
    Else
      WriteLog("Can't load language File!")
      DB_Close(*LngDB)
      ProcedureReturn #False
    EndIf
    
    DB_Close(*LngDB)
  Else
    WriteLog("Can't load Database!")
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure


Procedure ChangeLanguage(sDBFile.s, sNewLanguageFile.s)
  Protected *LngDB, iRow.i, iNewLng.i, sLine.s, iColumn.i, sColumn.s, iID.i
  *LngDB = DB_Open(sDBFile)
  If *LngDB
    iNewLng.i = ReadFile(#PB_Any, sNewLanguageFile.s)
    If iNewLng
      sLine.s = ReadString(iNewLng)
      ;DB_UpdateSync(*LngDB, "ALTER TABLE LANGUAGE ADD COLUMN "+sLine+" VARCHAR(500)")
      
      DB_Query(*LngDB, "SELECT * FROM LANGUAGE ORDER BY ID")
      DB_SelectRow(*LngDB, 0)
      iColumn.i = DB_GetNumColumns(*LngDB)-1
      sColumn.s = DB_GetColumnName(*LngDB, iColumn)
      DB_EndQuery(*LngDB)
      
      While Eof(iNewLng) = #False 
        sLine.s = ReadString(iNewLng)
        If Trim(sLine)
          iID.i = Val(StringField(sLine, 1, ":"))
          If DB_Query(*LngDB, "UPDATE LANGUAGE SET "+sColumn.s+" = ? WHERE ID = "+Str(iID))
            DB_StoreAsString(*LngDB, 0, Trim(StringField(sLine, 2, ":")))
            DB_StoreRow(*LngDB)
          EndIf
          DB_EndQuery(*LngDB)
        EndIf
      Wend
      CloseFile(iNewLng.i); 2010-04-11 Verschoben
    Else
      WriteLog("Can't load language File!")
      DB_Close(*LngDB)
      ProcedureReturn #False
    EndIf
    
    
    DB_Close(*LngDB)
  Else
    WriteLog("Can't load Database!")
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure





;{ Example
; InitLanguage("data\data.sqlite",2)
; Debug Language(#L_ENGLISH)
;}

; IDE Options = PureBasic 4.70 Beta 1 (Windows - x86)
; CursorPosition = 463
; FirstLine = 213
; Folding = A-
; EnableXP
; EnableUser
; EnableOnError
; EnableCompileCount = 74
; EnableBuildCount = 0
; EnableExeConstant
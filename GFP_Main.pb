;*************************************** Version: 2.0
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2017 RocketRider *******
;***************************************
EnableExplicit
#USE_VIRTUAL_FILE = #True;#False;
#USE_VIRTUALFILE_SECURE_MEMORY = #True ; Achtung wenn true, dann langsamer...
#USE_BUGGY_VIRTUALFILE_LOGGING = #False;#True;

#USE_APPDATA_FOLDER = #True
#USE_IMAGEPLUGIN_LIB = #False
#USE_DEBUGLEVEL = #False;#True;
#USE_DRM = #True
#USE_GFP = #True;#False;
#USE_PB_OGG = #True
#USE_SUBTITLES = #True;#False;
#USE_SWF_SUPPORT = #True;#False;
#USE_EXTENDED_DRM = #True;#False;
#USE_PROTECTWINDOW_BLACKLIST = #True;#False;
#USE_PROTECTWINDOW_CLIPBOARD = #True
#USE_FULLPATH_WITH_VIRTUAL_FILES = #True
#USE_DATABASE = #True
#USE_DIRTY_MP4_FIX = #True;#False; ;Second try loading with orginal file! (now used for codec installation)
#USE_OEM_FLVPLAYER = #True
#USE_ONLY_ABOUT_MENU = #False;#True;
#USE_OVERWRITE_SKIN = -1     ;3
#USE_ONLY_SYSTEM_FOR_EXPIRE_DATE = #False ;(false=internet ; true = no internet)
#USE_ANTI_DEBUGGER = #True
#USE_THROTTLE = #False
#USE_OPENLOG_AFTER_CLOSE = #False;#True
#USE_NEED_SECURE_ENVIRONMENT = #False
#USE_SC_HONEYPOT = #False
#USE_ENABLE_LAVFILTERS_DOWNLOAD = #True
#USE_HIDE_UNPROTECT_CHECKBOX = #True

CompilerIf #PB_editor_createexecutable
  #USE_LEAK_DEBUG = #False
CompilerElse
  #USE_LEAK_DEBUG = #True
CompilerEndIf

UseCRC32Fingerprint()

Import "Kernel32.lib";Hotfix
  GetProcAddress_(hMod.i, Name.p-ascii) As "_GetProcAddress@8"
EndImport



;{ SetDllDirectory
;FIX Für problematisschen DLL-Loadverhalten (wenn die bei LoadLibrary angegebene DLL nicht vorhanden ist)
CompilerIf #PB_Compiler_Unicode
  Prototype.i SetDllDirectory(Path.p-Unicode);(Path.p-ascii)
  Define hModuleHandle, SetDllDirectory.SetDllDirectory
  hModuleHandle=GetModuleHandle_("Kernel32.dll")
  If hModuleHandle
    SetDllDirectory.SetDllDirectory = GetProcAddress_(hModuleHandle, "SetDllDirectoryW")
    If SetDllDirectory
      SetDllDirectory("")
    EndIf  
  EndIf
CompilerElse
  Prototype.i SetDllDirectory(Path.p-ascii)
  Define hModuleHandle, SetDllDirectory.SetDllDirectory
  hModuleHandle=GetModuleHandle_("Kernel32.dll")
  If hModuleHandle
    SetDllDirectory.SetDllDirectory = GetProcAddress_(hModuleHandle, "SetDllDirectoryA")
    If SetDllDirectory
      SetDllDirectory("")
    EndIf  
  EndIf
CompilerEndIf  
;}
;{ DPIAware
Define hUser
hUser = GetModuleHandle_("User32.dll")
If hUser
  If GetProcAddress_(hUser, "SetProcessDPIAware")
    CallFunctionFast(GetProcAddress_(hUser, "SetProcessDPIAware"))
  EndIf
EndIf
;}

;{ Check Settings
CompilerIf #PB_editor_createexecutable And #USE_LEAK_DEBUG
  CompilerError "Leak Debug is on!"
CompilerEndIf

CompilerIf #USE_BUGGY_VIRTUALFILE_LOGGING And #PB_editor_createexecutable
  CompilerError "Virtualfile logging is on!"
CompilerEndIf  

;}
;{ Konstanten
#ICON_SMALL = 0
#ICON_BIG = 1

Enumeration
  #WINDOW_MAIN 
  #WINDOW_ABOUT
  #WINDOW_LIST
  #WINDOW_OPTIONS
  #WINDOW_UPDATE
  #WINDOW_VIDEOPROTECT
  #WINDOW_WAIT_PROTECTVIDEO
  #WINDOW_RUNONEWINDOW
EndEnumeration

Enumeration
  #TOOLBAR_PLAYLIST
EndEnumeration

Enumeration
  #TOOLBAR_BUTTON_ADDLIST
  #TOOLBAR_BUTTON_DELETELIST
  #TOOLBAR_BUTTON_ADDTRACK
  #TOOLBAR_BUTTON_DELETETRACK
  #TOOLBAR_BUTTON_ADDFOLDERTRACKS
  #TOOLBAR_BUTTON_ADDURL
  #TOOLBAR_BUTTON_EXPORTPLAYLIST
  #TOOLBAR_BUTTON_IMPORTPLAYLIST
  #TOOLBAR_BUTTON_PLAYPLAYLIST
EndEnumeration

Enumeration
  #MENU_MAIN
  ;#MENU_SYSTRAY
  #MENU_VDVD_DRIVES
  #MENU_VDVD_MENU
  #MENU_LIST_PLAYLISTS
EndEnumeration

Enumeration
  #STATUSBAR_MAIN
EndEnumeration

Enumeration
  #SYSTRAY_MAIN
EndEnumeration

CompilerIf #USE_OEM_VERSION
  #TRACKBAR_SIZE = 190
CompilerElse
  #TRACKBAR_SIZE = 70    
CompilerEndIf 
#PANEL_HEIGHT_FLV_PLAYER = 82

#PLAYER_VERSION = "2.0"


CompilerIf #USE_OEM_VERSION = #False
  #PLAYER_COPYRIGHT = "� 2009 - 2017 RocketRider"
  
  #PLAYER_GLOBAL_MUTEX = "GreenForce-Player"
  #GFP_PATTERN_PROTECTED_MEDIA = "GreenForce-Player (*.gfp)|*.gfp;|All Files (*.*)|*.*"
  #GFP_PROTECTED_FILE_EXTENTION = ".gfp"
  #GFP_CODEC_EXTENSION = "gfp-codec"
  #GFP_STREAMING_AGENT = ""
  #GFP_PATTERN_MEDIA = "Multimedia(*.gfp;*.gfp-codec;*.ogg;*.flac;*.m4a;*.aud;*.svx;*.voc;*.mka;*.3g2;*.3gp;*.asf;*.asx;*.avi;*.flv;*.mov;*.mp4;*.mpg;*.mpeg;*.rm;*.qt;*.swf;*.divx;*.vob;*.ts;*.ogm;*.m2ts;*.ogv;*.rmvb;*.tsp;*.ram;*.wmv;*.aac;*.aif;*.aiff;*.iff;*.m3u;*.mid;*.midi;*.mp1;*.mp2;*.mp3;*.mpa;*.ra;*.wav;*.wma;*.pls;*.xspf;*.mkv;*.m2v;*.m4v)|*.gfp;*.gfp-codec;*.ogg;*.flac;*.m4a;*.aud;*.svx;*.voc;*.mka;*.3g2;*.3gp;*.asf;*.asx;*.avi;*.flv;*.mov;*.mp4;*.mpg;*.mpeg;*.rm;*.qt;*.swf;*.divx;*.vob;*.ts;*.ogm;*.m2ts;*.ogv;*.rmvb;*.tsp;*.ram;*.wmv;*.aac;*.aif;*.aiff;*.iff;*.m3u;*.mid;*.midi;*.mp1;*.mp2;*.mp3;*.mpa;*.ra;*.wav;*.wma;*.pls;*.xspf;*.mkv;*.m2v;*.m4v;*.webm|All Files (*.*)|*.*"
  
  #GFP_GUID = "{46AF8ADF-E3F8-4E47-A31E-98B7CD1D5BF0}"
  
  #PLAYER_NAME = "GreenForce-Player"
  #UPDATE_VERSION_URL = "http://GFP.RRSoftware.de/update/update.txt"
  #UPDATE_FILE_URL = "http://GFP.RRSoftware.de/update/update.data"
  
  #UPDATE_AGENT = "GF-PLAYER_UPDATE "+#PLAYER_VERSION
  
  #USE_DISABLEMENU = #False;#True;
  #USE_DISABLECONTEXTMENU = #False;#True;
CompilerEndIf




#GFP_PATTERN_PLAYLIST_EXPORT = "M3U (*.m3u)|*.m3u;|All Files (*.*)|*.*"
#GFP_PATTERN_PLAYLIST_IMPORT = "Playlist(*.m3u;*.asx;*.pls;*.xspf)|*.m3u;*.asx;*.pls;*.xspf|All Files (*.*)|*.*"
#GFP_PATTERN_IMAGE = "Image files(*.jpg;*.jpeg;*.png;*.bmp;*.dib;*.tga;*.tiff;*.tif;*.jpf;*.jpx;*.jp2;*.j2c;*.j2k;*.jpc;*.gif)|*.jpg;*.jpeg;*.png;*.bmp;*.dib;*.tga;*.tiff;*.tif;*.jpf;*.jpx;*.jp2;*.j2c;*.j2k;*.jpc;*.gif|All Files (*.*)|*.*"
#GFP_PATTERN_SUBTILTES = "Subtitles(*.sub;*.srt;*.txt;*.idx;*.aqt;*.jss;*.ttxt;*.pjs;*.psb;*.rt;*.smi;*.ssf;*.gsub;*.ssa;*.ass;*.usf)|*.sub;*.srt;*.txt;*.idx;*.aqt;*.jss;*.ttxt;*.pjs;*.psb;*.rt;*.smi;*.ssf;*.gsub;*.ssa;*.ass;*.usf|All Files (*.*)|*.*"
#GFP_PATTERN_PROTECTED_MEDIA_EXE = "Executable (*.exe)|*.exe;|All Files (*.*)|*.*"

#GFP_FORMAT_MEDIA = ";vis-dll;gfp;mpvideo;ogg;flac;3g2;2gp;asf;avi;aud;acx;voc;flv;mka;mov;mp4;m4a;mpg;rm;swf;vob;wmv;aac;aif;aiff;iff;midi;mid;mp3;mpa;ra;wav;wma;mpeg;mp1;mp2;qt;divx;ts;tsp;ram;rmvb;ogm;ogv;m2ts;mkv;m2v;m4v;webm"
#GFP_FORMAT_PLAYLIST = ";asx;m3u;pls;xspf;txt;"

#GFP_LANGUAGE_PLAYER = #True


#VIRTUALFILE_BLACKLIST = "[guard32.dll][OAwatch.dll][uxtheme.dll]"

#GFP_DRM_SCREENCAPTURE_UNKNOWN = -1
#GFP_DRM_SCREENCAPTURE_DISALLOW = 0
#GFP_DRM_SCREENCAPTURE_ALLOW = 1
#GFP_DRM_SCREENCAPTURE_PROTECTION_FORCE = 2


;Bei änderung auch hier CheckForScreenCapture() aktualisieren!!!
#PROTECTWINDOW_BLACKLIST = "|FRAPS general|FRAPS fps|FRAPS movies|FRAPS screenshots|Audiorecorder|Audacity|WinVNC Tray Icon|WinVNC|RealVNC.vncserver-ui (service).TrayIcon|vnc::ClipboardWindow|RealVNC.vncserver.SuspendNotifier|RealVNC.vncserver.WMMonitor|smartision ScreenCopy|FRAPS|Start Fraps minimized|Fraps window always on top|Run Fraps when Windows starts|WeGame|Back to WeGame|PlayClaw|This is unregistered trial version of PlayClaw|E.M. Free Game Capture|Starte Bandicam beim Computerstart|Starte Bandicam minimiert|Bandicam (Nicht Registriert)|Bandicam|Bandicam64|Taksi - |Taksi Config|Hot Keys are pressed to activate Taksi from inside other applications|Game Cam|If you have any questions or if you have any good ideas on FastCapPro, please feel free to contact us.|FastCapProp window always on top|FastcapPro|"
#PROTECTHOOCK_BLACKLIST = "|FRAPS32.DLL|bdcap32.dll|playclawhook.dll|TaksiCommon.dll|TaksiDll.dll|bdcap32.dll|bdcam.dll|d3d8cap.dll|d3d9cap.dll|oglcap.dll|ddrawcap.dll|echelon_45.dll|echelon_46.dll|echelon_47.dll|echelon_48.dll|echelon_49.dll|echelon_50.dll|VideoStreamCapture.dll|"


Enumeration
  #MENU_LOAD
  #MENU_LOADCLIPBOARD
  #MENU_LOADURL
  #MENU_COPYTOCLIPBOARD
  #MENU_QUIT
  #MENU_ABOUT
  #MENU_PLAYLIST
  #MENU_HOMEPAGE
  #MENU_OPTIONS
  #MENU_CHECKUPDATES
  #MENU_DOWNLOADCODECS
  #MENU_PLAY
  #MENU_STOP
  #MENU_FORWARD
  #MENU_BACKWARD
  #MENU_ASPECTATION_AUTO
  #MENU_ASPECTATION_1_1
  #MENU_ASPECTATION_4_3
  #MENU_ASPECTATION_5_4
  #MENU_ASPECTATION_16_9
  #MENU_ASPECTATION_16_10
  #MENU_ASPECTATION_21_9
  #MENU_ASPECTATION_1_2
  #MENU_ASPECTATION_2_1
  #MENU_FULLSCREEN
  #MENU_SHOW
  #MENU_PROTECTVIDEO
  #MENU_UNPROTECTVIDEO
  #MENU_ERASEPASSWORDS
  #MENU_AUDIOCD
  #MENU_VIDEODVD
  #MENU_PLAYMEDIA
  #MENU_MINIMALMODE
  #MENU_STAYONTOP
  #MENU_VIS_OFF
  #MENU_VIS_SIMPLE
  #MENU_VIS_DCT
  #MENU_VIS_WHITELIGHT
  #MENU_VIS_COVERFLOW
  #MENU_VIS_1
  #MENU_VIS_300 = #MENU_VIS_1+300
  #MENU_VDVD_FROM_DICTIONARY
  #MENU_VDVD_DRIVES_1
  #MENU_VDVD_DRIVES_2
  #MENU_VDVD_DRIVES_3
  #MENU_VDVD_DRIVES_4
  #MENU_VDVD_DRIVES_5
  #MENU_VDVD_DRIVES_6
  #MENU_VDVD_DRIVES_7
  #MENU_VDVD_DRIVES_8
  #MENU_VDVD_DRIVES_9
  #MENU_VDVD_DRIVES_10
  #MENU_VDVD_DRIVES_11
  #MENU_VDVD_DRIVES_12
  #MENU_VDVD_DRIVES_13
  #MENU_VDVD_DRIVES_14
  #MENU_VDVD_DRIVES_15
  #MENU_VDVD_DRIVES_16
  #MENU_VDVD_DRIVES_17
  #MENU_VDVD_DRIVES_18
  #MENU_VDVD_DRIVES_19
  #MENU_VDVD_DRIVES_20
  #MENU_VDVD_DRIVES_21
  #MENU_VDVD_DRIVES_22
  #MENU_VDVD_DRIVES_23
  #MENU_VDVD_DRIVES_24
  #MENU_VDVD_MENU_Title  
  #MENU_VDVD_MENU_Root
  #MENU_VDVD_MENU_Subpicture
  #MENU_VDVD_MENU_Audio
  #MENU_VDVD_MENU_Angle
  #MENU_VDVD_MENU_Chapter
  #MENU_VDVD_SPEED_N8P0
  #MENU_VDVD_SPEED_N4P0
  #MENU_VDVD_SPEED_N2P0
  #MENU_VDVD_SPEED_N1P5
  #MENU_VDVD_SPEED_N1P0
  #MENU_VDVD_SPEED_N0P5
  #MENU_VDVD_SPEED_0P5
  #MENU_VDVD_SPEED_1P0
  #MENU_VDVD_SPEED_1P5
  #MENU_VDVD_SPEED_2P0
  #MENU_VDVD_SPEED_4P0
  #MENU_VDVD_SPEED_8P0
  #MENU_VDVD_LANGUAGE_1
  #MENU_VDVD_LANGUAGE_2
  #MENU_VDVD_LANGUAGE_3
  #MENU_VDVD_LANGUAGE_4
  #MENU_VDVD_LANGUAGE_5
  #MENU_VDVD_LANGUAGE_6
  #MENU_VDVD_LANGUAGE_7
  #MENU_VDVD_LANGUAGE_8
  #MENU_VDVD_CHAPTER_1
  #MENU_VDVD_CHAPTER_100 = #MENU_VDVD_CHAPTER_1+100
  #MENU_VDVD_PLAYLIST_1
  #MENU_VDVD_PLAYLIST_500 = #MENU_VDVD_PLAYLIST_1+500
  #MENU_LIST_CACHELIST
  #MENU_LIST_PLAY
  #MENU_LIST_DELETE
  #MENU_CHRONIC_CLEAR
  #MENU_CHRONIC_1
  #MENU_CHRONIC_2
  #MENU_CHRONIC_3
  #MENU_CHRONIC_4
  #MENU_CHRONIC_5
  #MENU_CHRONIC_6
  #MENU_CHRONIC_7
  #MENU_CHRONIC_8
  #MENU_CHRONIC_9
  #MENU_CHRONIC_10
  #MENU_DONATE
  #MENU_DOCUMENTATION
  #MENU_LOAD_SUBTITLES
  #MENU_DISABLE_SUBTITLES
  #MENU_SAVE_MEDIAPOS
  #MENU_SUBTITLE_SIZE_20
  #MENU_SUBTITLE_SIZE_30
  #MENU_SUBTITLE_SIZE_40
  #MENU_SUBTITLE_SIZE_50
  #MENU_SUBTITLE_SIZE_60
  #MENU_LIST_RENAME
  #MENU_SNAPSHOT
  
  #MENU_LAST_ITEM
EndEnumeration

Enumeration
  #GADGET_DUMY
  #GADGET_CONTAINER
  #GADGET_AUDIOCD_CONTAINER
  #GADGET_VIDEODVD_CONTAINER
  #GADGET_VIDEO_CONTAINER
  #GADGET_VIS_CONTAINER
  
  #GADGET_TRACKBAR;6
  #GADGET_BUTTON_BACKWARD
  #GADGET_BUTTON_FORWARD
  #GADGET_BUTTON_PREVIOUS
  #GADGET_BUTTON_NEXT
  #GADGET_BUTTON_STOP;11
  #GADGET_BUTTON_PLAY
  #GADGET_BUTTON_SNAPSHOT
  #GADGET_BUTTON_REPEAT
  #GADGET_BUTTON_RANDOM
  #GADGET_BUTTON_MUTE
  #GADGET_BUTTON_FULLSCREEN
  #GADGET_VOLUME ;NOT USED, ONLY TO SAVE THE POSTION OF THE CONTROL
  
  #GADGET_ACD_BUTTON_PREVIOUS;19
  #GADGET_ACD_BUTTON_NEXT
  #GADGET_ACD_BUTTON_STOP
  #GADGET_ACD_BUTTON_PLAY
  #GADGET_ACD_BUTTON_EJECT
  #GADGET_ACD_COMBOBOX_DEVICE
  #GADGET_ACD_COMBOBOX_TRACKS
  
  #GADGET_VDVD_BUTTON_EJECT;26
  #GADGET_VDVD_BUTTON_PLAY
  #GADGET_VDVD_BUTTON_STOP
  #GADGET_VDVD_BUTTON_NEXT
  #GADGET_VDVD_BUTTON_PREVIOUS
  #GADGET_VDVD_BUTTON_BACKWARD
  #GADGET_VDVD_BUTTON_FORWARD
  #GADGET_VDVD_BUTTON_SNAPSHOT;33
  #GADGET_VDVD_BUTTON_LAUFWERK
  #GADGET_VDVD_TRACKBAR;35
  #GADGET_VDVD_BUTTON_MUTE
  #GADGET_VDVD_VOLUME ;NOT USED, ONLY TO SAVE THE POSTION OF THE CONTROL
  
  #GADGET_ABOUT_IMAGE
  #GADGET_ABOUT_TEXT
  
  #GADGET_LIST_PLAYLIST
  #GADGET_LIST_TRACKLIST
  #GADGET_LIST_SPLITTER
  #GADGET_LIST_CONTAINER
  #GADGET_LIST_IMAGE
  
  #GADGET_OPTIONS_PANEL
  #GADGET_OPTIONS_ITEM_LANGUAGE
  #GADGET_OPTIONS_ITEM_VIDEORENDERER
  #GADGET_OPTIONS_ITEM_AUDIORENDERER
  #GADGET_OPTIONS_ITEM_AUTOUPDATES
  #GADGET_OPTIONS_ITEM_SYSTRAY
  #GADGET_OPTIONS_ITEM_RAMUSAGE
  #GADGET_OPTIONS_ITEM_MAXRAMFILESIZE
  #GADGET_OPTIONS_ITEM_PICTURE_PATH
  #GADGET_OPTIONS_ITEM_PICTURE_FORMAT
  #GADGET_OPTIONS_ITEM_LOGLEVEL
  #GADGET_OPTIONS_ITEM_BKCOLOR
  #GADGET_OPTIONS_ITEM_FILE_EXTENSIONS
  #GADGET_OPTIONS_ITEM_FILE_EXTENSIONS_SELECT_ALL
  #GADGET_OPTIONS_ITEM_FILE_EXTENSIONS_DESELECT_ALL
  #GADGET_OPTIONS_ITEM_SINGLE_INSTANCE
  #GADGET_OPTIONS_ITEM_ICONSET
  #GADGET_OPTIONS_EXPORT_DB
  #GADGET_OPTIONS_IMPORT_DB
  #GADGET_OPTIONS_DEFAULT_DB
  #GADGET_OPTIONS_CANCEL
  #GADGET_OPTIONS_SAVE
  
  #GADGET_PV_PANEL
  #GADGET_PV_CANCEL
  #GADGET_PV_SAVE
  #GADGET_PV_LOAD_BUTTON
  #GADGET_PV_LOAD_STRING
  #GADGET_PV_LOAD_TEXT
  #GADGET_PV_SAVE_BUTTON
  #GADGET_PV_SAVE_STRING
  #GADGET_PV_SAVE_TEXT
  #GADGET_PV_PW_TEXT
  #GADGET_PV_PW_STRING
  #GADGET_PV_PW2_STRING
  #GADGET_PV_PW2_TEXT
  #GADGET_PV_PW_TIP_TEXT
  #GADGET_PV_PW_TIP_STRING
  #GADGET_PV_SNAPSHOT_TEXT
  #GADGET_PV_SNAPSHOT_COMBOBOX
  #GADGET_PV_ALLOWUNPROTECT
  #GADGET_PV_TAG_TITLE
  #GADGET_PV_TAG_ALBUM
  #GADGET_PV_TAG_INTERPRET
  #GADGET_PV_TAG_COMMENT
  #GADGET_PV_COVER_TEXT
  #GADGET_PV_COVER_TEXT2
  #GADGET_PV_COVER_IMG
  #GADGET_PV_COVER_BUTTON
  #GADGET_PV_COVER_STRING
  #GADGET_PV_PROCCESS_PROGRESSBAR
  #GADGET_PV_PROCCESS_CANCEL
  #GADGET_PV_WARNING
  #GADGET_PV_ADDPLAYER
  #GADGET_PV_EXPIRE_DATE
  #GADGET_PV_EXPIRE_DATE_TEXT
  #GADGET_TB_PREVIOUS
  #GADGET_TB_PLAY
  #GADGET_TB_NEXT
  #GADGET_PV_NOT_FORCE_SCREENSHOT_PROTECTION
  #GADGET_PV_CODECNAME_STRING
  #GADGET_PV_CODECNAME_TEXT
  #GADGET_PV_CODECLINK_STRING
  #GADGET_PV_CODECLINK_TEXT
  #GADGET_PV_COPY_PROTECTION
  #GADGET_PV_MACHINEID_STRING
  #GADGET_PV_MACHINEID_TEXT
  #GADGET_PV_MACHINEID_GENERATE
  #GADGET_PV_ICON_BUTTON
  #GADGET_PV_ICON_STRING
  #GADGET_PV_ICON_TEXT
  #GADGET_PV_COMMAND_BUTTON
  #GADGET_PV_COMMAND_STRING
  #GADGET_PV_COMMAND_TEXT
  
  #GADGET_ABOUT_BIGTEXT
  #GADGET_LAST
EndEnumeration

Enumeration
  #SPRITE_NOP
  #SPRITE_SNAPSHOT_BLUE
  
  #SPRITE_PLAY_TOOLBAR
  #SPRITE_ERROR
  #SPRITE_INFO
  
  #SPRITE_PLAY
  #SPRITE_BREAK
  #SPRITE_FORWARD
  #SPRITE_BACKWARD
  #SPRITE_PREVIOUS
  #SPRITE_NEXT
  #SPRITE_STOP
  #SPRITE_SNAPSHOT
  #SPRITE_SNAPSHOT_DISABLED
  #SPRITE_REPEAT
  #SPRITE_RANDOM
  #SPRITE_EJECT
  #SPRITE_CDDRIVE_BLUE
  #SPRITE_FULLSCREEN
  
  #SPRITE_PLAY_HOVER
  #SPRITE_BREAK_HOVER
  #SPRITE_FORWARD_HOVER
  #SPRITE_BACKWARD_HOVER
  #SPRITE_PREVIOUS_HOVER
  #SPRITE_NEXT_HOVER
  #SPRITE_STOP_HOVER
  #SPRITE_SNAPSHOT_HOVER
  #SPRITE_REPEAT_HOVER
  #SPRITE_RANDOM_HOVER
  #SPRITE_EJECT_HOVER
  #SPRITE_CDDRIVE_BLUE_HOVER
  #SPRITE_FULLSCREEN_HOVER
  
  #SPRITE_PLAY_CLICK
  #SPRITE_BREAK_CLICK
  #SPRITE_FORWARD_CLICK
  #SPRITE_BACKWARD_CLICK
  #SPRITE_PREVIOUS_CLICK
  #SPRITE_NEXT_CLICK
  #SPRITE_STOP_CLICK
  #SPRITE_SNAPSHOT_CLICK
  #SPRITE_REPEAT_CLICK
  #SPRITE_RANDOM_CLICK
  #SPRITE_EJECT_CLICK
  #SPRITE_CDDRIVE_BLUE_CLICK
  #SPRITE_FULLSCREEN_CLICK
  
  #SPRITE_REPEAT_CLICK_HOVER
  #SPRITE_RANDOM_CLICK_HOVER
  
  #SPRITE_TRACKBAR_LEFT
  #SPRITE_TRACKBAR_MIDDLE
  #SPRITE_TRACKBAR_RIGHT
  #SPRITE_TRACKBAR_THUMB
  #SPRITE_TRACKBAR_THUMB_DISABLED
  #SPRITE_TRACKBAR_THUMB_SELECTED
  
  
  #SPRITE_ABOUT
  #SPRITE_ADDLIST
  #SPRITE_DELETELIST
  #SPRITE_ADDTRACK
  #SPRITE_DELETETRACK
  #SPRITE_ADDFOLDERTRACKS
  #SPRITE_NOIMAGE
  #SPRITE_PLAYLIST
  #SPRITE_PLAYTRACK
  #SPRITE_SYSTRAY
  #SPRITE_RENDERER
  #SPRITE_AUDIORENDERER
  #SPRITE_LANGUAGE
  #SPRITE_PROJEKTOR
  #SPRITE_UPDATE
  #SPRITE_CDDRIVE
  #SPRITE_BKCOLOR
  #SPRITE_LIGHT
  #SPRITE_KEY
  #SPRITE_BIGKEY
  #SPRITE_TRESOR
  #SPRITE_NOPHOTO
  #SPRITE_EXPORTPLAYLIST
  #SPRITE_IMPORTPLAYLIST
  #SPRITE_ADDURL
  #SPRITE_MENU_PLAYLIST
  #SPRITE_MENU_LOAD
  #SPRITE_MENU_END
  #SPRITE_MENU_HOMEPAGE
  #SPRITE_MENU_ABOUT
  #SPRITE_MENU_LANGUAGE
  #SPRITE_MENU_OPTIONS
  #SPRITE_MENU_UPDATE
  #SPRITE_MENU_CLIPBOARD
  #SPRITE_MENU_LANGUAGE_GERMANY
  #SPRITE_MENU_LANGUAGE_ENGLISH
  #SPRITE_MENU_LANGUAGE_FRENCH
  #SPRITE_MENU_LANGUAGE_TURKISH
  #SPRITE_MENU_PLAY
  #SPRITE_MENU_STOP
  #SPRITE_MENU_FORWARD
  #SPRITE_MENU_BACKWARD
  #SPRITE_MENU_ACTION
  #SPRITE_MENU_TRESOR
  #SPRITE_MENU_KEY
  #SPRITE_MENU_EARTH
  #SPRITE_MENU_BULLDOZER
  #SPRITE_MENU_AUDIOCD
  #SPRITE_MENU_PROJEKTOR
  #SPRITE_MENU_MUTE
  #SPRITE_MENU_SOUND
  #SPRITE_MENU_MONITOR
  #SPRITE_MENU_GIVEMONEY
  #SPRITE_ABOUT_BK
  #SPRITE_PV_COVER
  #SPRITE_MENU_LANGUAGE_NETHERLANDS
  #SPRITE_MENU_LANGUAGE_SPAIN
  #SPRITE_BUG
  #SPRITE_SYSTRAY_32x32
  #SPRITE_ONE_INSTANCE
  #SPRITE_PHOTO_32x32
  #SPRITE_RAM
  #SPRITE_RAM_FILE
  #SPRITE_MENU_DOWNLOAD
  #SPRITE_MENU_HELP
  #SPRITE_PHOTO_FILE_32x32
  #SPRITE_THEME
  #SPRITE_MENU_SAVE
  #SPRITE_MENU_MINIMALMODE
  #SPRITE_MENU_COVERFLOW
  #SPRITE_MENU_PLAYMEDIA
  #SPRITE_MENU_PLAYAUDIOCD
  #SPRITE_MENU_PLAYDVD
  #SPRITE_MENU_BREAK
  #SPRITE_NO_CONNECTION
  #SPRITE_MENU_RAM
  #SPRITE_MENU_RENAME
  #SPRITE_PLAYPLAYLIST
  #SPRITE_MENU_BRUSH
  #SPRITE_ENCTRACK
  #SPRITE_EARTHFILE
  #SPRITE_MENU_SNAPSHOT
  #SPRITE_VOLUME_BK
  #SPRITE_VOLUME_FORCE
  #SPRITE_MENU_LANGUAGE_GREEK
  #SPRITE_MENU_LANGUAGE_PORTUGAL
  #SPRITE_MENU_LANGUAGE_ITALIAN
  #SPRITE_MENU_LANGUAGE_SWEDEN
  #SPRITE_MENU_LANGUAGE_RUSSIA
  #SPRITE_MENU_LANGUAGE_BULGARIA
  #SPRITE_MENU_LANGUAGE_SERBIA
  #SPRITE_MENU_LANGUAGE_PERSIAN
  #SPRITE_MENU_PLAYFILE
  #SPRITE_EXE    
EndEnumeration


Enumeration
  #OPTIONS_COMBOBOX; Use chr(10) for more Items
  #OPTIONS_COMBOBOX_EDITABLE; Use chr(10) for more Items
  #OPTIONS_CHECKBOX
  #OPTIONS_STRING
  #OPTIONS_COLOR
  #OPTIONS_PATH
EndEnumeration


Enumeration
  #COMMAND_PLAY
  #COMMAND_PAUSE
  #COMMAND_STOP
  #COMMAND_ASPECT
  #COMMAND_VOLUME
  #COMMAND_NEXTTRACK
  #COMMAND_PREVIOUSTRACK
  #COMMAND_LOAD
  #COMMAND_LOADFILE
  #COMMAND_SNAPSHOT
  #COMMAND_PLAYLIST
  #COMMAND_OPTIONS
  #COMMAND_FULLSCREEN
  #COMMAND_PROTECTVIDEO
  #COMMAND_UNPROTECTVIDEO
  #COMMAND_CLAERPASSWORDS
  #COMMAND_ACD_EJECT
  #COMMAND_ACD_UPDATEDTRACKS
  #COMMAND_DVD_EJECT
  #COMMAND_FORWARD
  #COMMAND_BACKWARD
  #COMMAND_MUTE
  #COMMAND_COPY
  #COMMAND_PASTE
  #COMMAND_HELP
EndEnumeration

Enumeration
  #FONT_ABOUT
  #FONT_ABOUT_2
  #FONT_SUBTITLE
  #FONT_OPTIONS
EndEnumeration

Enumeration
  #VIS_OFF
  #VIS_SIMPLE
  #VIS_DCT
  #VIS_WHITELIGHT
  #VIS_COVERFLOW
  #VIS_BUFFERING
  #VIS_1
  #VIS_300 = #VIS_1+300
EndEnumeration



;}
;{ Declaration


Structure VolumeGadget
  imageid.l 
  imagecolor.l 
  font.l 
  state.l 
  trackbar.l
EndStructure
Structure MediaFile
  sFile.s
  Memory.i
  sRealFile.s
  iPlaying.i
  qOffset.q
  *StreamingFile
EndStructure
Structure Playlist
  iID.i
  iTempID.i
  iCurrentMedia.i
  iItemCount.i
EndStructure
Structure OptionsGadgetsStructure
  iButton.i
  iShowGadget.i
  iType.i
EndStructure
Structure PlayListItem
  sFile.s
  sTitle.s
  qOffset.q
EndStructure

Structure StartParams
  iAspect.i
  bFullscreen.i
  bHelp.i
  bHelp2.i
  iVolume.i
  iDisableLAVFilters.i 
  iJustDownloadCodecs.i
  iHiddenCodecsDownload.i
  sPassword.s
  bHidden.i
  sFile.s
  sImportPlaylist.s
  iloglevel.i
  iUsedVideoRenderer.i
  iUsedAudioRenderer.i
  iRestoreDatabase.i
  iAlternativeHooking.i
  iDisableMenu.i
  iSaveStreamingCache.i
  sProxyIP.s
  sProxyPort.s
  iUseIESettings.i
  iProxyBypassLocal.i
  iNoRedirect.i
  sPasswordFile.s
  sInstallDesign.s
  iUseSkin.i
  qStartPosition.q
  iHideDRM.i
  
EndStructure

Structure THUMBBUTTON
  dwMask.l
  iId.l
  iBitmap.l
  hIcon.i
  szTip.u[260]
  dwFlags.l
EndStructure

Interface ITaskbarList3 Extends ITaskbarList2
  SetProgressValue(hWnd, Completed.q, Total.q)
  SetProgressState(hWnd, Flags.l)
  RegisterTab(hWndTab, hWndMDI)
  UnregisterTab(hWndTab)
  SetTabOrder(hWndTab, hwndInsertBefore)
  SetTabActive(hWndTab, hWndMDI, dwReserved.l)
  ThumbBarAddButtons(hWnd, cButtons, *pButtons)
  ThumbBarUpdateButtons(hWnd, cButtons, *pButtons)
  ThumbBarSetImageList(hWnd, himl)
  SetOverlayIcon(hWnd, hIcon, pszDescription.s)
  SetThumbnailTooltip(hWnd, pszTip.s)
  SetThumbnailClip(hWnd, *prcClip.RECT)
EndInterface


;Global *GFP_DRM_HEADER
Global *GFP_DRM_HEADER_V2
Global Dim OptionsGadgets.OptionsGadgetsStructure(100)
Global iOptionsGadgetItems.i
Global Playlist.Playlist
Global Dim PlayListItems.PlayListItem(1)
Global iQuit.i
Global iMediaObject.i, MediaFile.MediaFile, iVolumeGadget.i, iWMouseX.i, iWMouseY.i, iWMouseOldX.i, iWMouseOldY.i, iMouseInActive.i
Global fMediaAspectRation.f, iMediaMainObject.i
Global iVideoRenderer.i, iAudioRenderer.i, sDataBaseFile.s, iOwnVideoRenderer.i=#False
Global iOldFullScreenWidth.i, iOldFullScreenHeight.i, iOldFullScreenX.i, iOldFullScreenY.i, iOldFullScreenSkin.i
Global iLanguageMenuItems.i = 1
Global Dim LanguageMenu(iLanguageMenuItems)
Global *PLAYLISTDB
Global iOptionsOptionCount.i
Global iShowMainWindowCursor.i = #True
Global iDownloadThread.i
Global iDoubleClickTime.q
Global iScreenSaverActive.i
Global PressedLeftMouseButton.i
Global sMediaTimeStringBefore.s
Global sGlobalPassword.s
Global IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_ALLOW
Global iVDVD_VolumeGadget.i
Global iStayMainWndOnTop.i = #False
Global iIsSoundMuted.i
Global iIsMinimalMode.i
Global iPLS_CoverTrackID.i, iPLS_CoverImage.i, iPLS_CoverID.i
Global iVolumeGadgetFocused.i
Global hMutexAppRunning, hPipeAppRunning
Global isMainWindowActive.i
Global IsFullscreenControlUsed.i
Global sGetFolderFiles.s
Global iUseDRMMenu.i=#True
Global FoundCaptureWindowTime.q
Global CheckForScreenCaptureTimer.q
Global StartParams.StartParams
Global iAlternativeHookingActive.i
Global iLastPasswordRequester.i
Global iSubtitlesLoaded.i
Global UseNoPlayerControl.i
Global UsedSubtitleSize.i
Global IsVirtualFileUsed.i=#True
Global UsedDPI.i
Global IsSnapshotAllowedSetting = #GFP_DRM_SCREENCAPTURE_ALLOW
Global ExeHasAttachedFiles.i
Global OldForegroundWindow.i
Global BufferingMedia.s, BufferingMediaTitle.s, BufferingMediaEncryption.i, BufferingMediaOffset.q
Global DisallowURLFiles.i=#False
Global sGlobalMachineIDMasterKey.s
Global sGlobalMachineIDXOrKey.s
Global bCloseAfterPlayback.i = #False
Global isAlreadyLoading=#False
Global TryedHoneyPot=#False
Global TestedIsParentTrusted=#False

Global g_TrackBarBkColorBrush.i
Global TreeWindowID, TreeGadgetProcedure, TreehDC, TreemDC, Treem2DC, Treewidth, Treeheight, TreePainting, TreemOldObject, TreehmBitmap, Treem2OldObject

Global LoadMediaMutex = CreateMutex()

Global *thumbButtons.ITaskbarList3
Global Dim ThumbButtons.THUMBBUTTON(3)

Global Dim MenuLimitations.i(#MENU_LAST_ITEM+1)
Global sLimitationsFile.s
Global sTmpRegisteredDLL.s = ""

Define iEvent.i, iWidth.i, iHeight.i, sFile.s, iCount.i, i.i
Define iImage.i, sLoadFile.s, iDBFile.i, iFile.i
Define sParam.s, sMediaTimeString.s
Define handle.i, sName.s, recv, cb
Define EventCounter.i
Define sPath.s
Global MediaState.i, MediaPosition.i, MediaLength.i
Define sParamOrg.s
Define *DBDesign
Define *DB
Define ElapsedMillisecondsFails=0
Define sMsgTitle.s, sMsgText.s
Define sImUser.s, sImPwd.s, hToken   


Declare CreateListWindow()
Declare CreateOptionsWindow()
Declare SetFullScreen(iWithoutSizing.i=#False, iReset.i=#False)
Declare CreateProtectVideoWindow()
Declare ProtectVideo_UpdateWindow(iImage.i=#SPRITE_BIGKEY, sTitle.s="", iCancel.i=#True)
Declare ProtectVideo_CB(p.q,s.q)
Declare _EndPlayer()
Declare RunCommand(iCommand.i, fParam.f=0, sParam.s="")
Declare SetMediaSizeTo0()
Declare SetMediaSizeToOrginal()
Declare FreeMediaFile()
Declare SetMediaAspectRation()
Declare VDVD_LoadDVD(sVolume.s)
Declare VolumeGadget(x, y, font, state)
Declare GetWindowKeyState(iEvent.i, iWindow.i=#WINDOW_MAIN)
Declare SetMediaSizeToDVD()
Declare GetVolumeGadgetState(iGadget)
Declare SetVolumeGadgetState(iGadget, state, iRedraw=#False)
Declare isFileEncrypted(sFile.s)
Declare.s ConvertStringDBCompartible(sText.s, iConvert.i)
Declare.s Time2String(time.q)
Declare ProcessAllEvents()
Declare Event_AppCommand(command.i, device.i, state.i)
Declare SetMediaSizeToVIS()
Declare LoadMediaFile(sFile.s, iAddPrevious.i = #True, sMediaTitle.s = "", qOffset.q=0)
Declare RestartPlayer()
Declare SetLoopGadgetImages()
Declare.s OpenFileRequesterEx(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i, Flags.i=0)
Declare.s SaveFileRequesterEx(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i)
Declare LoadFiles(sFile.s, iRequester.i=#False)
Declare RestoreDatabase(Restart = #True, ask=#True)
Declare Requester_Error(sText.s)
Declare GetDPI()
Declare Requester_Cant_Update()
Declare _LoadMediaFile_LoadPlay(sFile.s, sMediaTitle.s, IsEncrypted.i, qOffset.q, *Stream)
Declare LoadAttachedMedia(sFile.s, sMediaTitle.s="", qOffset.q=0)
Declare ResizeWindow_(Window, x, y, Width, Height)
Declare ResizeMainWindow()
Declare HoverGadgetImages()
Declare __AnsiString(str.s)
Declare.s GetMediaPath(sPlaylist.s, sPlaytrack.s)
Declare DisableWindows(state.i) 
Declare TestDecryptPW(sFile.s="", qOffset.q=0, *Stream=#Null)
Declare MessageBoxCheck(title.s, text.s, iconStyle.i, uniqueKey.s)
Declare ConnectionFailedRequester(InetCheck=#True)
Declare.q GetAllServerTime()
Declare IsMutexAlreadyUsed(sMutex.s)
Declare _StatusBarHeight(ID.i)
Declare.s GetSpecialFolder(i) 

Macro EndPlayer()
  WriteLog("BEGIN PLAYER-END", #LOGLEVEL_DEBUG)
  _EndPlayer()
EndMacro


;}
;{ Include

XIncludeFile "include\GFP_PBCompatibility.pbi"

CompilerIf #USE_LEAK_DEBUG
  XIncludeFile "include\GFP_LEAK_DEBUG.pbi"
CompilerEndIf  

CompilerIf #USE_THROTTLE And #PB_editor_createexecutable = #False
  XIncludeFile "include\GFP_CPU-Throttle.pbi"
CompilerEndIf  

CompilerIf #USE_OEM_VERSION
  XIncludeFile "GFP_OEM.pbi"
CompilerEndIf

XIncludeFile "include\GFP_MachineID.pbi"
XIncludeFile "include\GFP_UxTheme.pbi"
XIncludeFile "include\GFP_TIMER_FUNCS.pbi"
XIncludeFile "include\GFP_API_File2.pbi"
XIncludeFile "include\GFP_Settings.pbi"
XIncludeFile "include\GFP_LogFile.pbi"
XIncludeFile "include\GFP_SkinGadget.pbi"  
XIncludeFile "include\GFP_LAVFilters.pbi"    
XIncludeFile "include\GFP_Database.pbi"
XIncludeFile "include\GFP_Design.pbi"
XIncludeFile "include\GFP_VolumeGadget.pbi"
XIncludeFile "include\GFP_StringCommands_3.pbi"
XIncludeFile "include\GFP_Cryption4_Unicode.pbi"
XIncludeFile "include\GFP_DRMHeaderV2_52_Unicode.pbi"
XIncludeFile "include\GFP_Simple_URL.pbi"
XIncludeFile "include\GFP_VMDetect.pbi"
XIncludeFile "include\GFP_StreamingManager.pbi"
CompilerIf #USE_VIRTUAL_FILE
  XIncludeFile "include\GFP_VirtualFile_80_Unicode_OwnString_WIN8.pbi"
CompilerEndIf
XIncludeFile "include\GFP_DShow_140.pbi"
CompilerIf #USE_IMAGEPLUGIN_LIB
  XIncludeFile "include\GFP_ImagePlugin.pbi"
CompilerEndIf
XIncludeFile "include\GFP_ProcessRequester.pbi"
XIncludeFile "include\GFP_WINHTTP55.pbi"
;XIncludeFile "include\GFP_ResMod37.pbi"
XIncludeFile "include\GFP_exe-attachment4.pbi"
XIncludeFile "include\GFP_Limitations.pbi"
XIncludeFile "include\GFP_Covers.pbi"
XIncludeFile "include\GFP_MediaTags.pbi"
XIncludeFile "include\GFP_SoundEx.pbi"
XIncludeFile "include\GFP_Mediadet.pbi"
XIncludeFile "include\GFP_Flash12.pbi"
XIncludeFile "include\GFP_SWF.pbi"
CompilerIf #USE_OEM_VERSION
  XIncludeFile "include\GFP_FLVPlayer.pbi"
CompilerEndIf  
XIncludeFile "include\GFP_MediaLib.pbi"
XIncludeFile "include\GFP_Language.pbi"
XIncludeFile "include\GFP_CacheSystem.pbi"
XIncludeFile "include\GFP_TrackBar_2.pbi"
XIncludeFile "include\GFP_SpecialFolder.pbi"
XIncludeFile "include\GFP_WndProtection3.pbi"
XIncludeFile "include\GFP_PasswordLib.pbi"
XIncludeFile "include\GFP_D3D.pbi"
XIncludeFile "include\GFP_VisualCanvas_8.pbi"
XIncludeFile "include\GFP_Visualization.pbi"
XIncludeFile "include\GFP_AudioCD.pbi"
XIncludeFile "include\GFP_VideoDVD.pbi"
XIncludeFile "include\GFP_filetype.pbi"
XIncludeFile "include\GFP_Playlist.pbi"
XIncludeFile "include\GFP_Appcommand.pbi"
XIncludeFile "include\GFP_Sprite2D.pbi"
XIncludeFile "include\GFP_Sprite2D_Framework.pbi"
XIncludeFile "include\GFP_VIS_Simple.pbi"
XIncludeFile "include\GFP_VIS_DCT.pbi"
XIncludeFile "include\GFP_VIS_WhiteLight.pbi"
XIncludeFile "include\GFP_VIS_Coverflow.pbi"
XIncludeFile "include\GFP_VIS_Buffering.pbi"
XIncludeFile "include\GFP_CheckRunning.pbi"
XIncludeFile "include\GFP_URLAutoComplete.pbi"
XIncludeFile "include\GFP_OwnRequester.pbi"
XIncludeFile "include\GFP_DLLRegister.pbi"
XIncludeFile "include\GFP_INIReader.pbi"
XIncludeFile "include\GFP_CodecInstaller.pbi"
XIncludeFile "include\GFP_ThumbButton.pbi"
XIncludeFile "include\GFP_RSA_Crypt.pbi"
XIncludeFile "include\GFP_ANTI_HOOK_3.pbi"
CompilerIf #USE_SUBTITLES
  XIncludeFile "include\GFP_Subtitles.pbi"
CompilerEndIf  
XIncludeFile "include\GFP_AntiDebug.pbi"
XIncludeFile "include\GFP_ResMod37.pbi"
XIncludeFile "include\GFP_ParentTrusted.pbi"
XIncludeFile "include\GFP_Standby.pbi"

EnableExplicit
;}










;{ Functions

Procedure Mod_ResizeGadget(gadget,x,y,w,h)
  Protected min_y = 0
  ;fix for horizontal bar in fullscreen mode
  If gadget = #GADGET_VIDEO_CONTAINER Or gadget = #GADGET_VIDEODVD_CONTAINER
    If GetGadgetData(#GADGET_CONTAINER) ;Fullscreen
      min_y = -2
    EndIf  
  EndIf  
  If y < min_y And y <> #PB_Ignore
    y = min_y
  EndIf
  ProcedureReturn ResizeGadget(gadget,x,y,w,h)
EndProcedure

Procedure Mod_WindowBounds(wnd,min_w,min_h,max_w,max_h)
  If min_h <> #PB_Ignore And max_h <> #PB_Ignore
    If GetMenu_(WindowID(wnd))
      min_h + MenuHeight()
    EndIf   
    If min_h > max_h
      max_h = min_h
    EndIf  
  EndIf
  
  ProcedureReturn WindowBounds(wnd,min_w,min_h,max_w,max_h)
EndProcedure


Macro ResizeGadget
  Mod_ResizeGadget
EndMacro

Macro WindowBounds
  Mod_WindowBounds
EndMacro

#OWNER_SECURITY_INFORMATION    =   $00000001
#GROUP_SECURITY_INFORMATION    =   $00000002
#DACL_SECURITY_INFORMATION     =   $00000004
#SACL_SECURITY_INFORMATION     =   $00000008
#LABEL_SECURITY_INFORMATION    =   $00000010

#PROTECTED_DACL_SECURITY_INFORMATION   =  $80000000
#PROTECTED_SACL_SECURITY_INFORMATION   =  $40000000
#UNPROTECTED_DACL_SECURITY_INFORMATION =  $20000000
#UNPROTECTED_SACL_SECURITY_INFORMATION =  $10000000


Procedure ProtectProcess()
  Protected *pACL.ACL
  Protected cbACL = 1024;
  
  ; Initialize a security descriptor.
  Protected *pSD.SECURITY_DESCRIPTOR = AllocateMemory(#SECURITY_DESCRIPTOR_MIN_LENGTH)
  InitializeSecurityDescriptor_(*pSD, #SECURITY_DESCRIPTOR_REVISION)
  *pACL = AllocateMemory(cbACL);
  InitializeAcl_(*pACL, cbACL, #ACL_REVISION2)
  SetSecurityDescriptorDacl_(*pSD, #True, *pACL, #False)
  
  ;SetFileSecurity_("C:\TEST.TXT",#DACL_SECURITY_INFORMATION, *pSD) ; <-- remove all rights from a certain file
  SetKernelObjectSecurity_(GetCurrentProcess_(), #DACL_SECURITY_INFORMATION, *pSD) ; <-- now you cannot close the process with the task manager
EndProcedure

Global DRMV2_Cached_File.s, DRMV2_Cached_Password.s, DRMV2_Cached_Offset.q, *DRMV2_Cached_headerObj.DRMV2_HEADER_READ_OBJECT
Procedure __DRMV2_ReadHeaderFromStreamingFile(*StreamingFile, password.s, qOffset.q = 0, *result.integer = #Null)
  Protected iResult.i = #DRM_ERROR_FAIL  
  Protected headerSize.i = 0
  Protected *header = #Null
  Protected genHeader.DRM_HEADER_GENERIC, file, *memory
  
  
  
  If ReadBytes(*StreamingFile, @genHeader, qOffset, SizeOf(DRM_HEADER_GENERIC), #Null)
    iResult = __DRMV2_AnalyzeGenericHeader(@genHeader, @headerSize)    
    
    If iResult = #DRM_OK
      *memory = AllocateMemory(headerSize)
      If *memory
        ;FileSeek(file, qOffset)   
        
        If ReadBytes(*StreamingFile, *memory, qOffset, headerSize, #Null)         
          *header =  _DRMV2_ReadHeader(*memory, password.s, @iResult)
        Else
          __DRMError(Chr(34) + Str(*StreamingFile) + Chr(34) + " cannot be read!")
          iResult = #DRM_ERROR_FAIL              
        EndIf  
        FreeMemory(*memory)
        *memory=#Null
      Else
        iResult = #DRM_ERROR_OUTOFMEMORY
        __DRMError("out of memory while reading " + Chr(34) + Str(*StreamingFile) + Chr(34) + "!")          
      EndIf
    Else
      __DRMError(Chr(34) + Str(*StreamingFile) + Chr(34) + " cannot be analyzed (" + __DRMErrorString(iResult)+")")        
    EndIf 
    
  Else
    __DRMError(Chr(34) + Str(*StreamingFile) + Chr(34) + " cannot be read!")
    iResult = #DRM_ERROR_FAIL      
  EndIf
  
  
  
  If *result
    *result\i = iResult
  EndIf  
  ProcedureReturn *header
EndProcedure

Procedure DRMV2Read_ReadFromStreamingFile(*StreamingFile, sPassword.s, qOffset.q = 0)
  Protected bFail = #False, *headerObj.DRMV2_HEADER_READ_OBJECT = __DRMV2Read_CreateHeaderObject()
  If *headerObj
    *headerObj\header = __DRMV2_ReadHeaderFromStreamingFile(*StreamingFile, sPassword, qOffset, @*headerObj\readResult)
    If *headerObj\header
      *headerObj\password = sPassword
      If *headerObj\readResult = #DRM_OK And *headerObj\header
        *headerObj\cryptionBuffer = _DRMV2_AllocateCryptionBuffer(*headerObj\header, sPassword, #False)
        *headerObj\cryptionBufferHeader = _DRMV2_AllocateCryptionBuffer(*headerObj\header, sPassword, #True) 
        If *headerObj\cryptionBuffer = #Null Or *headerObj\cryptionBufferHeader = #Null
          bFail = #True
        EndIf  
      EndIf 
    Else
      bFail = #True      
    EndIf
  Else
    __DRMError("DRMV2Read_ReadFromFile out of memory")
  EndIf
  
  If bFail
    If *headerObj      
      If *headerObj\header
        FreeMemory(*headerObj\header)
      EndIf  
      If *headerObj\cryptionBuffer
        FreeMemory(*headerObj\cryptionBuffer)
      EndIf
      If *headerObj\cryptionBufferHeader
        FreeMemory(*headerObj\cryptionBufferHeader)
      EndIf        
      FreeMemory(*headerObj)
      *headerObj = #Null
    EndIf  
    __DRMError("DRMV2Read_ReadFromFile failed")    
  EndIf  
  
  ProcedureReturn *headerObj
EndProcedure  



Procedure DRMV2Read_Copy(*headerObj.DRMV2_HEADER_READ_OBJECT)
  Protected *headerObj_Copy.DRMV2_HEADER_READ_OBJECT
  If *headerObj
    *headerObj_Copy = AllocateMemory(SizeOf(DRMV2_HEADER_READ_OBJECT))
    If *headerObj_Copy
      CopyMemory(*headerObj, *headerObj_Copy, SizeOf(DRMV2_HEADER_READ_OBJECT))
      
      If *headerObj
        If *headerObj\header
          *headerObj_Copy\header = AllocateMemory(MemorySize(*headerObj\header))
          CopyMemory(*headerObj\header, *headerObj_Copy\header, MemorySize(*headerObj\header))
        EndIf
        If *headerObj\cryptionBuffer
          *headerObj_Copy\cryptionBuffer = AllocateMemory(MemorySize(*headerObj\cryptionBuffer))
          CopyMemory(*headerObj\cryptionBuffer, *headerObj_Copy\cryptionBuffer, MemorySize(*headerObj\cryptionBuffer))
        EndIf    
        If *headerObj\cryptionBufferHeader
          *headerObj_Copy\cryptionBufferHeader = AllocateMemory(MemorySize(*headerObj\cryptionBufferHeader))
          CopyMemory(*headerObj\cryptionBufferHeader, *headerObj_Copy\cryptionBufferHeader, MemorySize(*headerObj\cryptionBufferHeader))
        EndIf
      EndIf
      ProcedureReturn *headerObj_Copy
    EndIf
  EndIf
EndProcedure  


Procedure DRMV2Read_ReadFromFile_Cached(sFile.s, sPassword.s, qOffset.q = 0)
  Protected *headerObj.DRMV2_HEADER_READ_OBJECT
  If sFile=DRMV2_Cached_File And sPassword=DRMV2_Cached_Password And qOffset=DRMV2_Cached_Offset And *DRMV2_Cached_headerObj<>#Null
    *headerObj = DRMV2Read_Copy(*DRMV2_Cached_headerObj)
  Else  
    *headerObj = DRMV2Read_ReadFromFile(sFile.s, sPassword.s, qOffset.q)
    If *DRMV2_Cached_headerObj<>#Null:DRMV2Read_Free(*DRMV2_Cached_headerObj):*DRMV2_Cached_headerObj=#Null:EndIf
    *DRMV2_Cached_headerObj = DRMV2Read_Copy(*headerObj)
    DRMV2_Cached_File = sFile
    DRMV2_Cached_Password = sPassword
    DRMV2_Cached_Offset = qOffset
  EndIf
  ProcedureReturn *headerObj
EndProcedure  


Procedure ResizeWindow_(Window, x, y, Width, Height)
  ResizeWindow(Window, x, y, Width, Height)
  If Window=#WINDOW_MAIN
    ResizeMainWindow()
  EndIf  
EndProcedure

Procedure.s OpenFileRequesterEx_Win(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i, Flags.i=0)
  Protected Result.s, sFileTemp.s
  If IsHookdisabled=#False
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed
        WriteLog("DeactivateHook Export", #LOGLEVEL_DEBUG)
        VirtualFile_DeactivateHook(#False, #True)
      EndIf
    CompilerEndIf  
  EndIf
  Result = OpenFileRequester(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i, Flags)
  If Flags=#PB_Requester_MultiSelection
    sFileTemp = Result
    While sFileTemp
      sFileTemp = NextSelectedFileName()
      If sFileTemp: Result=Result+Chr(10)+sFileTemp:EndIf
    Wend
  EndIf  
  If IsHookdisabled=#False
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed
        VirtualFile_ReactivateHook(#False, #True)
        WriteLog("ReactivateHook Export", #LOGLEVEL_DEBUG)
      EndIf
    CompilerEndIf  
  EndIf
  GetWindowKeyState(#VK_RBUTTON);Wird benötigt da der status später sonst noch aktiv ist.
  ProcedureReturn Result
EndProcedure
Procedure.s SaveFileRequesterEx_Win(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i)
  Protected Result.s
  If IsHookdisabled=#False
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed
        WriteLog("DeactivateHook Export", #LOGLEVEL_DEBUG)
        VirtualFile_DeactivateHook(#False, #True)
      EndIf
    CompilerEndIf  
  EndIf
  Result = SaveFileRequester(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i)
  If IsHookdisabled=#False
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed
        VirtualFile_ReactivateHook(#False, #True)
        WriteLog("ReactivateHook Export", #LOGLEVEL_DEBUG)
      EndIf
    CompilerEndIf  
  EndIf
  GetWindowKeyState(#VK_RBUTTON);Wird benötigt da der status später sonst noch aktiv ist.
  ProcedureReturn Result
EndProcedure
Procedure.s PathRequesterEx_Win(Titel.s, Path.s)
  Protected Result.s
  If IsHookdisabled=#False
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed
        WriteLog("DeactivateHook Export", #LOGLEVEL_DEBUG)
        VirtualFile_DeactivateHook(#False, #True)
      EndIf
    CompilerEndIf  
  EndIf
  Result = PathRequester(Titel.s, Path.s)
  If IsHookdisabled=#False
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed
        VirtualFile_ReactivateHook(#False, #True)
        WriteLog("ReactivateHook Export", #LOGLEVEL_DEBUG)
      EndIf
    CompilerEndIf  
  EndIf
  GetWindowKeyState(#VK_RBUTTON);Wird benötigt da der status später sonst noch aktiv ist.
  ProcedureReturn Result
EndProcedure


Procedure DisableWindows(state.i) 
  
  ;   If state=#True
  ;     OldForegroundWindow=GetForegroundWindow_()
  ;   EndIf    
  ;   If IsWindow(#WINDOW_ABOUT):DisableWindow(#WINDOW_ABOUT, state):EndIf
  ;   If IsWindow(#WINDOW_LIST):DisableWindow(#WINDOW_LIST, state):EndIf
  ;   If IsWindow(#WINDOW_OPTIONS):DisableWindow(#WINDOW_OPTIONS, state):EndIf
  ;   If IsWindow(#WINDOW_VIDEOPROTECT):DisableWindow(#WINDOW_VIDEOPROTECT, state):EndIf
  ;   If IsWindow(#WINDOW_MAIN):DisableWindow(#WINDOW_MAIN, state):EndIf
  ; ; If state=#True
  ; ;   EnableWindow_(WindowID(#WINDOW_MAIN), #False)
  ; ; Else
  ; ;   EnableWindow_(WindowID(#WINDOW_MAIN), #True)
  ; ; EndIf  
  ; ; 
  ; ;   Repeat
  ; ;   Until WindowEvent()=0
  ; ;   
  ;   If state=#False
  ;     SetForegroundWindow_(OldForegroundWindow)
  ;     ;BringWindowToTop_(OldForegroundWindow)
  ;     ;SetActiveWindow_(OldForegroundWindow)
  ;     ;SetFocus_(OldForegroundWindow)
  ;     ShowWindow_(OldForegroundWindow, #SW_MINIMIZE)
  ;     ShowWindow_(OldForegroundWindow, #SW_SHOWDEFAULT)
  ;     ;OpenLibrary(1,"user32.dll")
  ;     ;CallFunction(1,"SwitchToThisWindow", OldForegroundWindow, #True)
  ;   EndIf 
EndProcedure  

Procedure ProcessRequesterEvents()
  Protected event
  event = WaitWindowEvent(16)
  If (event = #WM_LBUTTONDOWN Or event = #PB_Event_Gadget Or event = #PB_Event_Menu) 
    Select EventWindow() 
      Case #WINDOW_MAIN
        FlashWindow_(WindowID(#WINDOW_MAIN), #True)
      Case #WINDOW_VIDEOPROTECT
        FlashWindow_(WindowID(#WINDOW_VIDEOPROTECT), #True)
      Case #WINDOW_OPTIONS
        FlashWindow_(WindowID(#WINDOW_OPTIONS), #True)
      Case #WINDOW_LIST
        FlashWindow_(WindowID(#WINDOW_LIST), #True)
      Case #WINDOW_ABOUT
        FlashWindow_(WindowID(#WINDOW_ABOUT), #True)
    EndSelect  
    MessageBeep_(#MB_ICONHAND)
  EndIf
EndProcedure  
Procedure.s OpenFileRequesterEx(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i, Flags.i=0)
  Protected Result.s, multiselect
  ;If Flags=#PB_Requester_MultiSelection:Flags=#PB_Explorer_MultiSelect:EndIf
  ;Result = OwnFileRequester(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i, Flags)
  
  DisableWindows(#True)
  If Flags=#PB_Requester_MultiSelection:multiselect=#True:EndIf
  Result = ProcessRequester_Open(Titel, StandardDatei, Pattern, PatternPosition, multiselect, #False, @ProcessRequesterEvents())
  DisableWindows(#False)
  
  ProcedureReturn ReplaceString(Result, "|", Chr(10))
EndProcedure
Procedure.s SaveFileRequesterEx(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i)
  Protected Result.s
  ;Result = OwnFileRequester(Titel.s, StandardDatei.s, Pattern.s, PatternPosition.i, 0,#True)
  DisableWindows(#True)
  Result = ProcessRequester_Open(Titel, StandardDatei, Pattern, PatternPosition, #False, #True, @ProcessRequesterEvents())
  DisableWindows(#False)
  ProcedureReturn Result
EndProcedure
Procedure.s PathRequesterEx(Titel.s, Path.s)
  Protected Result.s
  Result = OwnPathRequester(Titel.s, Titel, Path.s)
  ProcedureReturn Result
EndProcedure

Procedure SetWindowIcon(Window, Iconfile.s)
  Protected icon
  If Iconfile
    If FileSize(Iconfile)>0
      icon=LoadImage(#PB_Any, Iconfile)
      If icon
        SendMessage_(WindowID(Window), #WM_SETICON, #ICON_SMALL, ImageID(Icon))
        SendMessage_(WindowID(Window), #WM_SETICON, #ICON_BIG, ImageID(Icon))
      EndIf
    EndIf
  EndIf
EndProcedure

Global Dim PressedWindowKey(1000)
Procedure GetWindowKeyState(iEvent.i, iWindow.i=#WINDOW_MAIN)
  Protected result.i
  result=GetAsyncKeyState_(iEvent)
  If result<>0 And result<>1
    If GetActiveWindow() = iWindow Or iWindow=-1
      If PressedWindowKey(iEvent)=#False
        PressedWindowKey(iEvent)=#True
        ProcedureReturn #True
      EndIf
    EndIf
  Else
    PressedWindowKey(iEvent)=#False
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure RestartPlayer()
  Protected Password.s
  ;iQuit = #True
  If hMutexAppRunning
    CloseHandle_(hMutexAppRunning)
    hMutexAppRunning=#Null
  EndIf
  FreeLogFile()
  ;   If sGlobalPassword<>""
  ;     Password=" /password "+Chr(34)+sGlobalPassword+Chr(34)
  ;   EndIf  
  ;StickyWindow(#WINDOW_MAIN, #False)
  ;HideWindow(#WINDOW_MAIN, #True)
  RunProgram(ProgramFilename(), Chr(34)+MediaFile\sRealFile+Chr(34)+Password, GetCurrentDirectory())
  EndPlayer()
  End
EndProcedure

Procedure _StatusBarHeight(ID.i)
  If IsWindowVisible_(StatusBarID(ID))
    ProcedureReturn StatusBarHeight(ID)
  EndIf  
  ProcedureReturn 0
EndProcedure  

Procedure MonitorWidth()
  Protected DC.i, iResult.i
  DC = GetDC_(GetDesktopWindow_())
  iResult = GetDeviceCaps_(DC, #HORZRES)
  ReleaseDC_(GetDesktopWindow_(), DC)
  ProcedureReturn iResult
EndProcedure
Procedure MonitorHeight()
  Protected DC.i, iResult.i
  DC = GetDC_(GetDesktopWindow_())
  iResult = GetDeviceCaps_(DC, #VERTRES)
  ReleaseDC_(GetDesktopWindow_(), DC)
  ProcedureReturn iResult
EndProcedure
Procedure GetUsedDesktop(iWindow.i)
  Protected iNbDesktops.i, WRect.rect, DRect.rect, iDesktop.i, i.i, tmpRect.rect
  iNbDesktops = ExamineDesktops()
  WRect\top=WindowY(iWindow)
  WRect\left=WindowX(iWindow)
  WRect\right=WindowX(iWindow)+WindowWidth(iWindow)
  WRect\bottom=WindowY(iWindow)+WindowHeight(iWindow)
  
  iDesktop=-1
  For i=0 To iNbDesktops-1
    DRect\top=DesktopY(i)
    DRect\left=DesktopX(i)
    DRect\right=DesktopX(i)+DesktopWidth(i)
    DRect\bottom=DesktopY(i)+DesktopHeight(i)       
    If IntersectRect_(tmpRect, DRect, WRect)
      iDesktop=i
      Break
    EndIf
  Next
  If iDesktop=-1:iDesktop=0:EndIf
  ProcedureReturn iDesktop 
EndProcedure
Procedure GetUsedDesktopXYWH(iX.i, iY.i, iWidth.i, iHeight.i)
  Protected iNbDesktops.i, WRect.rect, DRect.rect, iDesktop.i, i.i, tmpRect.rect
  iNbDesktops = ExamineDesktops()
  WRect\top=iY
  WRect\left=iX
  WRect\right=iX+iWidth
  WRect\bottom=iY+iHeight
  
  iDesktop=-1
  For i=0 To iNbDesktops-1
    DRect\top=DesktopY(i)
    DRect\left=DesktopX(i)
    DRect\right=DesktopX(i)+DesktopWidth(i)
    DRect\bottom=DesktopY(i)+DesktopHeight(i)       
    If IntersectRect_(tmpRect, DRect, WRect)
      iDesktop=i
      Break
    EndIf
  Next
  ;If iDesktop=-1:iDesktop=0:EndIf
  ProcedureReturn iDesktop 
EndProcedure
Procedure GetTaskBarHeight()
  Protected *APPBD.APPBARDATA, Height.i=0
  *APPBD=AllocateMemory(SizeOf(APPBARDATA))
  If *APPBD
    SHAppBarMessage_(#ABM_GETTASKBARPOS, *APPBD)
    If *APPBD\uEdge = #ABE_BOTTOM
      Height = *APPBD\rc\bottom - *APPBD\rc\top
    EndIf  
    FreeMemory(*APPBD)
  EndIf
  ProcedureReturn Height
EndProcedure
Procedure GetFontHeight(FontID, Str.s, MaxWidth, MaxHeight) 
  Protected height.i, DC.i, MemDC.i, re.rect
  height = -1
  DC = CreateDC_("display",0,0,0)
  If DC
    MemDC = CreateCompatibleDC_(DC)
    If MemDC
      re.rect
      re\left= 0
      re\top = 0  
      re\right = MaxWidth
      re\bottom = MaxHeight
      
      SelectObject_(MemDC, FontID)
      height = DrawText_(MemDC, @Str, Len(Str), re.rect,#DT_LEFT| #DT_TOP|#DT_WORDBREAK)
      SelectObject_(MemDC, GetStockObject_(#SYSTEM_FONT))
      
      DeleteDC_(MemDC)
    EndIf
    DeleteDC_(DC)
  EndIf
  If height = -1:height = MaxHeight:EndIf
  ProcedureReturn height
EndProcedure



Procedure SetMediaSizeToVIS()
  Protected iWidth.i, iHeight.i, iDesktop.i, iTaskBarHeight.i, MenuHeight.i
  If IsMenu(#MENU_MAIN)
    MenuHeight=MenuHeight() 
  Else
    MenuHeight=0
  EndIf 
  
  If iIsVISUsed
    If GadgetHeight(#GADGET_VIS_CONTAINER)=0
      If GadgetHeight(#GADGET_VIDEO_CONTAINER)=0
        iWidth = 640
        iHeight = 480
        iDesktop=GetUsedDesktop(#WINDOW_MAIN)
        iTaskBarHeight=GetTaskBarHeight()
        If iWidth+WindowX(#WINDOW_MAIN)+15>DesktopWidth(iDesktop)
          iWidth=DesktopWidth(iDesktop)-WindowX(#WINDOW_MAIN)-15
        EndIf
        If (iHeight+WindowY(#WINDOW_MAIN)+Design_Container_Size+40+_StatusBarHeight(#STATUSBAR_MAIN)+iTaskBarHeight+MenuHeight)>DesktopHeight(iDesktop)
          iHeight=DesktopHeight(iDesktop)-WindowY(#WINDOW_MAIN)-Design_Container_Size-_StatusBarHeight(#STATUSBAR_MAIN)-iTaskBarHeight-MenuHeight-40
        EndIf
        
        VIS_Activate(iWidth, iHeight)
      Else
        VIS_Activate(GadgetWidth(#GADGET_VIDEO_CONTAINER), GadgetHeight(#GADGET_VIDEO_CONTAINER)+3)
      EndIf
    EndIf
  Else
    If GadgetHeight(#GADGET_VIS_CONTAINER)=0
      iWidth = MediaWidth(iMediaObject)
      iHeight = MediaHeight(iMediaObject)
    Else
      If MediaWidth(iMediaObject)
        iWidth = GadgetWidth(#GADGET_VIS_CONTAINER)
        iHeight = GadgetHeight(#GADGET_VIS_CONTAINER)+3
      EndIf
    EndIf
    If iWidth = 0 : iWidth = #PB_Ignore :EndIf
    If iHeight = 0 : iHeight = #PB_Ignore :EndIf
    If iWidth <> #PB_Ignore And iHeight <> #PB_Ignore
      iDesktop=GetUsedDesktop(#WINDOW_MAIN)
      iTaskBarHeight=GetTaskBarHeight()
      If iWidth+WindowX(#WINDOW_MAIN)+15>DesktopWidth(iDesktop)
        iWidth=DesktopWidth(iDesktop)-WindowX(#WINDOW_MAIN)-15
      EndIf
      If (iHeight+WindowY(#WINDOW_MAIN)+Design_Container_Size+40+_StatusBarHeight(#STATUSBAR_MAIN)+iTaskBarHeight+MenuHeight())>DesktopHeight(iDesktop)
        iHeight=DesktopHeight(iDesktop)-WindowY(#WINDOW_MAIN)-Design_Container_Size-_StatusBarHeight(#STATUSBAR_MAIN)-iTaskBarHeight-MenuHeight-40
      EndIf
      If GetGadgetData(#GADGET_CONTAINER)=#False;Kein Fullscreen
        If UsedOutputMediaLibrary = #MEDIALIBRARY_FLASH
          WindowBounds(#WINDOW_MAIN, 460, #PANEL_HEIGHT_FLV_PLAYER+3+_StatusBarHeight(0), #PB_Ignore, $FFF)
        Else
          WindowBounds(#WINDOW_MAIN, 460, Design_Container_Size+3+_StatusBarHeight(0), #PB_Ignore, $FFF)
        EndIf  
        
        If UseNoPlayerControl
          ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, iWidth, iHeight+MenuHeight)
        Else
          ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, iWidth, iHeight+_StatusBarHeight(0)+MenuHeight+Design_Container_Size)
        EndIf  
      EndIf
    Else
      WindowBounds(#WINDOW_MAIN, 460, Design_Container_Size+3+_StatusBarHeight(0), #PB_Ignore, Design_Container_Size+3+_StatusBarHeight(0))
      ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, #PB_Ignore, Design_Container_Size+3+_StatusBarHeight(0))
    EndIf
  EndIf
  
  If iIsVISUsed
    If GetGadgetData(#GADGET_CONTAINER) ;Fullscreen
      ResizeGadget(#GADGET_VIS_CONTAINER,  0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN))
    Else
      If UseNoPlayerControl
        ResizeGadget(#GADGET_VIS_CONTAINER, 0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN)-MenuHeight)
      Else
        ResizeGadget(#GADGET_VIS_CONTAINER, 0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN)-Design_Container_Size-3-_StatusBarHeight(0)-MenuHeight)
      EndIf
    EndIf
    
    ResizeGadget(#GADGET_VIDEO_CONTAINER, 0, 0, 0, 0)
    VIS_Resize()
  Else
    If GetGadgetData(#GADGET_CONTAINER) ;Fullscreen
      ResizeGadget(#GADGET_VIDEO_CONTAINER, -2, -2, WindowWidth(#WINDOW_MAIN)+4, WindowHeight(#WINDOW_MAIN)+4)
    Else
      If UseNoPlayerControl
        ResizeGadget(#GADGET_VIDEO_CONTAINER, 0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN)-MenuHeight)
      Else
        ResizeGadget(#GADGET_VIDEO_CONTAINER, 0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN)-Design_Container_Size-3-_StatusBarHeight(0)-MenuHeight)
      EndIf
    EndIf
    ResizeGadget(#GADGET_VIS_CONTAINER, 0, 0, 0, 0)
  EndIf
EndProcedure
Procedure SetMediaSizeToOrginal()
  Protected iWidth.i, iHeight.i, iDesktop.i, iTaskBarHeight.i, MenuHeight.i
  If IsMenu(#MENU_MAIN)
    MenuHeight=MenuHeight() 
  Else
    MenuHeight=0
  EndIf 
  
  If iIsVISUsed
    If GadgetHeight(#GADGET_VIS_CONTAINER)=0
      VIS_Activate()
    EndIf
  Else
    iWidth = MediaWidth(iMediaObject)
    iHeight = MediaHeight(iMediaObject)
    WriteLog("orginal video size: "+Str(iWidth)+":"+Str(iHeight), #LOGLEVEL_DEBUG)
    
    If iWidth = 0 : iWidth = #PB_Ignore :EndIf
    If iHeight = 0 : iHeight = #PB_Ignore :EndIf
    If iWidth <> #PB_Ignore And iHeight <> #PB_Ignore
      iDesktop=GetUsedDesktop(#WINDOW_MAIN)
      iTaskBarHeight=GetTaskBarHeight()
      WriteLog("Desktop: "+Str(iDesktop)+" "+Str(DesktopWidth(iDesktop))+":"+Str(DesktopHeight(iDesktop))+" Taskbar "+Str(iTaskBarHeight), #LOGLEVEL_DEBUG)
      If iTaskBarHeight<0 Or iTaskBarHeight>100:iTaskBarHeight=0:WriteLog("Wrong Tasbar height! "+Str(GetTaskBarHeight())):EndIf
      If DesktopWidth(iDesktop)>0 And DesktopHeight(iDesktop)>0
        If iWidth+WindowX(#WINDOW_MAIN)+15>DesktopWidth(iDesktop):iWidth=DesktopWidth(iDesktop)-WindowX(#WINDOW_MAIN)-15:EndIf
        If (iHeight+WindowY(#WINDOW_MAIN)+Design_Container_Size+40+_StatusBarHeight(#STATUSBAR_MAIN)+iTaskBarHeight+MenuHeight)>DesktopHeight(iDesktop):iHeight=DesktopHeight(iDesktop)-WindowY(#WINDOW_MAIN)-Design_Container_Size-_StatusBarHeight(#STATUSBAR_MAIN)-iTaskBarHeight-MenuHeight-40:EndIf
      EndIf
      If GetGadgetData(#GADGET_CONTAINER)=#False;Kein Fullscreen
        If iHeight<200:iHeight=200:EndIf
        WriteLog("Set Window size to orginal video size: "+Str(iWidth)+":"+Str(iHeight), #LOGLEVEL_DEBUG)
        
        If UsedOutputMediaLibrary = #MEDIALIBRARY_FLASH
          WindowBounds(#WINDOW_MAIN, 460, #PANEL_HEIGHT_FLV_PLAYER+3+_StatusBarHeight(0), #PB_Ignore, $FFF)
        Else
          WindowBounds(#WINDOW_MAIN, 460, Design_Container_Size+3+_StatusBarHeight(0), #PB_Ignore, $FFF)
        EndIf  
        
        If UseNoPlayerControl
          ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, iWidth, iHeight+MenuHeight)
        Else
          ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, iWidth, iHeight+_StatusBarHeight(#STATUSBAR_MAIN)+MenuHeight+Design_Container_Size)
        EndIf  
        
      EndIf
    Else
      If GetGadgetData(#GADGET_CONTAINER)
        SetFullScreen(#False, #True)
      EndIf
      WindowBounds(#WINDOW_MAIN, 460, Design_Container_Size+3+_StatusBarHeight(0), #PB_Ignore, Design_Container_Size+3+_StatusBarHeight(0))
      ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, #PB_Ignore, Design_Container_Size+5+_StatusBarHeight(#STATUSBAR_MAIN))
    EndIf
  EndIf
EndProcedure
Procedure SetMediaSizeToDVD()
  Protected iWidth.i, iHeight.i, iDesktop.i, iTaskBarHeight.i, MenuHeight.i
  If iIsVISUsed = #False
    If IsMenu(#MENU_MAIN)
      MenuHeight=MenuHeight() 
    Else
      MenuHeight=0
    EndIf 
    iWidth = MediaWidth(iMediaObject)
    iHeight = MediaHeight(iMediaObject)
    If iWidth = 0 : iWidth = 800 :EndIf
    If iHeight = 0 : iHeight = 600 :EndIf
    If iWidth <> #PB_Ignore And iHeight <> #PB_Ignore
      iDesktop=GetUsedDesktop(#WINDOW_MAIN)
      iTaskBarHeight=GetTaskBarHeight()
      If iWidth+WindowX(#WINDOW_MAIN)+15>DesktopWidth(iDesktop):iWidth=DesktopWidth(iDesktop)-WindowX(#WINDOW_MAIN)-15:EndIf
      If (iHeight+WindowY(#WINDOW_MAIN)+Design_Container_Size+40+_StatusBarHeight(#STATUSBAR_MAIN)+iTaskBarHeight+MenuHeight)>DesktopHeight(iDesktop):iHeight=DesktopHeight(iDesktop)-WindowY(#WINDOW_MAIN)-Design_Container_Size-_StatusBarHeight(#STATUSBAR_MAIN)-iTaskBarHeight-MenuHeight-40:EndIf
      
      WindowBounds(#WINDOW_MAIN, 460, Design_Container_Size+3+_StatusBarHeight(0), #PB_Ignore, $FFF)
      ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, iWidth, iHeight+_StatusBarHeight(0)+MenuHeight+Design_Container_Size)
    Else
      WindowBounds(#WINDOW_MAIN, 460, Design_Container_Size+3+_StatusBarHeight(0), #PB_Ignore, Design_Container_Size+3+_StatusBarHeight(0))
      ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, #PB_Ignore, Design_Container_Size+3+_StatusBarHeight(0))
    EndIf
  Else
    If GadgetHeight(#GADGET_VIS_CONTAINER)=0
      VIS_Activate()
    EndIf
  EndIf
EndProcedure
Procedure SetMediaSizeTo0()
  MediaFile\iPlaying = #False
  StatusBarText(0, 0, "")
  StatusBarText(0, 1, "")
  SetWindowTitle(#WINDOW_MAIN, #PLAYER_NAME)
  If iIsVISUsed = #False
    WindowBounds(#WINDOW_MAIN, 460, Design_Container_Size+3+_StatusBarHeight(#STATUSBAR_MAIN), #PB_Ignore, Design_Container_Size+3+_StatusBarHeight(#STATUSBAR_MAIN))
    ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, 0, Design_Container_Size+3+_StatusBarHeight(#STATUSBAR_MAIN))
  Else
    If GadgetHeight(#GADGET_VIS_CONTAINER)=0
      VIS_Activate()
    EndIf
  EndIf
EndProcedure
Procedure isFileEncrypted(sFile.s)
  Protected iFile, iResult.i
  iResult=#False
  iFile = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
  If iFile
    If ReadLong(iFile)=1145392472;'DEMX'
      iResult = #True
    EndIf
    CloseFile(iFile)
  EndIf
  ProcedureReturn iResult
EndProcedure

Procedure ChangeSelectedAspectRation(iID.i)
  Protected i.i
  If IsMenu(#MENU_MAIN)
    For i=#MENU_ASPECTATION_AUTO To #MENU_ASPECTATION_2_1
      SetMenuItemState(#MENU_MAIN, i, 0) 
    Next
    SetMenuItemState(#MENU_MAIN, iID, 1) 
  EndIf
EndProcedure
Procedure SetMediaAspectRation()
  Protected faspect.f, fwidth.f, fheight.f, fwidth2.f, fheight2.f, fwidth3.f, fheight3.f, fx.f, fy.f
  If IsWindow(#WINDOW_MAIN)
    If iIsVISUsed = #False
      If fMediaAspectRation>0
        faspect = fMediaAspectRation
      Else
        faspect.f = MediaGetAspectRatio(iMediaObject)
      EndIf
      ;Debug faspect
      fwidth.f = GadgetWidth(#GADGET_VIDEO_CONTAINER)
      fheight.f = GadgetHeight(#GADGET_VIDEO_CONTAINER)
      If fwidth>0 And fheight>0
        fwidth2.f = fheight * faspect
        fwidth3.f = fwidth
        If fwidth2 < fwidth3 :fwidth3 = fwidth2:EndIf
        fheight2.f = fwidth3 / faspect
        fx = (fwidth-fwidth3)/2
        fy = (fheight-fheight2)/2 
        
        If DShow_IsWindowlessRenderer(iMediaObject); Or iIsMediaObjectVideoDVD=#False
          MediaSetDestWidth(iMediaObject, fwidth3)
          MediaSetDestHeight(iMediaObject, fheight2)      
          MediaSetDestX(iMediaObject, fx)
          MediaSetDestY(iMediaObject, fy)       
        Else
          MediaSetDestWidth(iMediaObject, fwidth3)
          MediaSetDestHeight(iMediaObject, fheight2)
          MediaSetWindowWidth(iMediaObject, fwidth3)
          MediaSetWindowHeight(iMediaObject, fheight2)    
          MediaSetDestX(iMediaObject, 0)
          MediaSetDestY(iMediaObject, 0)   
          MediaSetWindowX(iMediaObject, fx)
          MediaSetWindowY(iMediaObject, fy) 
          ;       MediaSetDestWidth(iMediaObject, fwidth3)
          ;       MediaSetDestHeight(iMediaObject, fheight2)
          ;       MediaSetWindowWidth(iMediaObject, fwidth)
          ;       MediaSetWindowHeight(iMediaObject, fheight)    
          ;       MediaSetDestX(iMediaObject, fx)
          ;       MediaSetDestY(iMediaObject, fy)   
          ;       MediaSetWindowX(iMediaObject, 0)
          ;       MediaSetWindowY(iMediaObject, 0) 
        EndIf 
        If IsGadget(#GADGET_VIDEO_CONTAINER)
          InvalidateRect_(GadgetID(#GADGET_VIDEO_CONTAINER), #Null, #True)
          UpdateWindow_(GadgetID(#GADGET_VIDEO_CONTAINER))
        EndIf
      EndIf
    EndIf
  EndIf
EndProcedure
Procedure FreeMediaFile()
  MediaFile\iPlaying = #False
  If iMediaObject
    VIS_SetDSHOWObj(#Null)
    FreeMedia(iMediaObject)
    iMediaObject = #Null
  EndIf
  
  If MediaFile\Memory
    ;FreeMemory(MediaFile\Memory)
    MediaFile\Memory = #Null
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed
        VirtualFile_RemoveFile(MediaFile\sFile)
      EndIf  
    CompilerEndIf
  EndIf
  
  If MediaFile\StreamingFile
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed
        VirtualFile_RemoveFile(MediaFile\sFile)
      EndIf  
    CompilerEndIf
    FreeStreamingFile(MediaFile\StreamingFile, StartParams\iSaveStreamingCache)
    MediaFile\StreamingFile=#Null
  EndIf    
  
  MediaFile\sFile = ""
  MediaFile\sRealFile = ""
  fMediaAspectRation = 0
  
  MediaState=#False
  MediaPosition=0
  MediaLength=0
  
  BufferingMedia.s=""
  BufferingMediaTitle.s=""
  BufferingMediaEncryption.i=#False
  BufferingMediaOffset.q=0
  
  If IsGadget(#GADGET_TRACKBAR)
    SetGadgetState(#GADGET_TRACKBAR, 0)
  EndIf  
  If IsGadget(#GADGET_VDVD_TRACKBAR)
    SetGadgetState(#GADGET_VDVD_TRACKBAR, 0)
  EndIf
  If IsMenu(#MENU_MAIN)
    ChangeSelectedAspectRation(#MENU_ASPECTATION_AUTO)
  EndIf  
  CompilerIf #USE_SUBTITLES
    FreeSubtitles()
  CompilerEndIf  
EndProcedure
Procedure.s GetMediaFileTitle(sFile.s, IsEncrypted=#False, *Stream=#Null, qOffset.q=0);50KB Pro Title
  Protected sTitle.s, *Header, sInterpret.s, res.i
  sTitle = GetFilePart(sFile)
  If IsEncrypted
    ;     If ReadDRMHeader(sFile, *GFP_DRM_HEADER, sGlobalPassword)=#DRM_OK
    ;       If GetDRMHeaderTitle(*GFP_DRM_HEADER)
    ;         sTitle = GetDRMHeaderTitle(*GFP_DRM_HEADER)
    ;       EndIf
    ;       If GetDRMHeaderInterpreter(*GFP_DRM_HEADER)
    ;         sTitle = GetDRMHeaderInterpreter(*GFP_DRM_HEADER) + " - " + sTitle
    ;       EndIf
    ;     EndIf
    If *Stream=#Null
      *Header = DRMV2Read_ReadFromFile_Cached(sFile, sGlobalPassword, qOffset)
    Else
      *Header = DRMV2Read_ReadFromStreamingFile(*Stream, sGlobalPassword, qOffset)
    EndIf
    
    If *Header
      sTitle = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_TITLE)
      sInterpret = DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_INTERPRETER)
      If sInterpret
        sTitle = sInterpret + " - " + sTitle
      EndIf  
      
      DRMV2Read_Free(*Header)
      *Header=#Null
    EndIf  
    
  Else
    If LoadMetaFile(sFile)
      If MediaInfoData\sTile
        sTitle = MediaInfoData\sTile
      EndIf
      If MediaInfoData\sAutor
        sTitle = MediaInfoData\sComposer + " - " + sTitle
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn sTitle.s
EndProcedure


Procedure ReCheckMachineID()
  sGlobalMachineIDMasterKey=Right(sGlobalPassword, 32)
  If sGlobalMachineIDMasterKey<>"" And sGlobalMachineIDXOrKey<>""
    If sGlobalMachineIDMasterKey = GetXorKey(sGlobalMachineIDXOrKey, MachineID(0))
      ProcedureReturn #True
    EndIf  
  EndIf  
  ProcedureReturn #False
EndProcedure  

Procedure.s TestMachineIDPW(password.s, xorkeys.s)
  Protected masterKey.s="", res.i,testpw.s, i.i
  Protected xorKeyCount.i=Len(xorkeys)/32;32=MD5 len
  
  For i=0 To xorKeyCount-1
    sGlobalMachineIDXOrKey.s=Mid(xorkeys,(i*32)+1,32);32=MD5 len
    If password=""
      testpw=GetXorKey(sGlobalMachineIDXOrKey, MachineID(0))
      ;sGlobalMachineIDMasterKey = testpw
    Else
      testpw=password+"|"+GetXorKey(sGlobalMachineIDXOrKey, MachineID(0))
    EndIf  
    
    res = DRMV2Read_CheckPassword(*GFP_DRM_HEADER_V2, testpw.s)
    If res=#DRM_OK
      masterKey=testpw
      Break
    EndIf  
  Next
  
  ProcedureReturn masterKey
EndProcedure  

Procedure TestDecryptPW(sFile.s="", qOffset.q=0, *Stream=#Null)
  Protected iResult, sPWTip.s, i.i, iFile, res.i, *Header,  qSize.q, ProcRes=#False, sPW.s, sXorKeys.s, resKey.s
  sGlobalMachineIDMasterKey=""
  sGlobalMachineIDXOrKey=""
  
  res=#DRM_ERROR_INVALIDPASSWORD
  If sFile Or *Stream
    If *GFP_DRM_HEADER_V2
      DRMV2Read_Free(*GFP_DRM_HEADER_V2)
      *GFP_DRM_HEADER_V2=#Null
    EndIf  
    
    If *Stream
      *GFP_DRM_HEADER_V2 = DRMV2Read_ReadFromStreamingFile(*Stream, sGlobalPassword, qOffset)
    Else
      *GFP_DRM_HEADER_V2 = DRMV2Read_ReadFromFile_Cached(sFile, sGlobalPassword, qOffset)
    EndIf  
    
    
    If *GFP_DRM_HEADER_V2
      res=DRMV2Read_GetLastReadResult(*GFP_DRM_HEADER_V2)   
      ;Debug res
    EndIf  
  EndIf  
  
  
  If res <> #DRM_OK
    
    If *GFP_DRM_HEADER_V2
      sPWTip = DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_PASSWORDTIP)
      If sPWTip<>""
        sPWTip = " ("+sPWTip+")"
      EndIf
      sXorKeys.s = DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_MACHINEID);Muss zur überprüfung immer geladen werden, auch wenn das PW schon gefunden wurde!
      
      
      For i=0 To iLastPasswordMgrItem;Password from password mgr
        If PasswordMgr(i)<>""
          res = DRMV2Read_CheckPassword(*GFP_DRM_HEADER_V2, PasswordMgr(i))
          
          If res=#DRM_OK
            sGlobalPassword=PasswordMgr(i)
            WriteLog("Password was saved!", #LOGLEVEL_DEBUG) 
            Break
          EndIf
          
          
          If res=#DRM_ERROR_INVALIDPASSWORD;Check with Machine ID and password
            If sXorKeys<>""
              resKey = TestMachineIDPW(PasswordMgr(i), sXorKeys)
              If resKey<>""
                res=#DRM_OK
                sGlobalPassword=resKey
                WriteLog("Password was saved, Machine ID and PW!", #LOGLEVEL_DEBUG) 
                Break
              EndIf  
            EndIf
          EndIf
          
        EndIf
      Next
      
      
      
      If res=#DRM_ERROR_INVALIDPASSWORD;Password from machine ID
        If sXorKeys<>""
          resKey = TestMachineIDPW("", sXorKeys)
          If resKey<>""
            res=#DRM_OK
            sGlobalPassword=resKey
            WriteLog("Password was Machine ID!", #LOGLEVEL_DEBUG) 
          EndIf  
        EndIf
      EndIf 
      
      
      
      If sFile<>"" And res=#DRM_ERROR_INVALIDPASSWORD
        sPW.s = GetDriveSerialFromFile(sFile);+GetGraphicCardName()+GetCPUName()
        res = DRMV2Read_CheckPassword(*GFP_DRM_HEADER_V2, sPW)
        If res=#DRM_OK
          sGlobalPassword=sPW
          WriteLog("Password was Hardware ID!", #LOGLEVEL_DEBUG) 
        EndIf   
        
      EndIf  
      
      Repeat
        If sGlobalPassword<>""
          iResult = DRMV2Read_CheckPassword(*GFP_DRM_HEADER_V2, sGlobalPassword)
          
          If iResult=#DRM_ERROR_INVALIDPASSWORD;Check with Machine ID and password
            If sXorKeys<>""
              resKey = TestMachineIDPW(sGlobalPassword, sXorKeys)
              If resKey<>""
                iResult=#DRM_OK
                sGlobalPassword=resKey
                WriteLog("Password was Machine ID with PW!", #LOGLEVEL_DEBUG) 
              EndIf  
            EndIf
          EndIf
          
        Else
          iResult=#DRM_ERROR_INVALIDPASSWORD
        EndIf
        If iResult=#DRM_ERROR_INVALIDPASSWORD
          If Abs(ElapsedMilliseconds()-iLastPasswordRequester)<2000
            Delay(2000)
          EndIf  
          iLastPasswordRequester=ElapsedMilliseconds()
          
          sGlobalPassword = PasswordRequester(Language(#L_PASSWORD_INPUT), Language(#L_PASSWORD_INPUT)+sPWTip, "", 300, #True, sFile)
        EndIf
      Until iResult<>#DRM_ERROR_INVALIDPASSWORD Or sGlobalPassword=""
      If sXorKeys<>""
        If ReCheckMachineID()=#False ;Machine ID wurde von hand eingegeben!
          iResult=#DRM_ERROR_INVALIDPASSWORD
          sGlobalPassword=""
          WriteLog("Ilegal use of machine ID", #LOGLEVEL_DEBUG)
        EndIf
      EndIf       
      If iResult=#DRM_OK
        ProcRes=#True
      EndIf
      
    EndIf
    
    
  Else
    ProcRes=#True
  EndIf
  
  
  If *GFP_DRM_HEADER_V2;Header wurde nicht mit korrektem Password geladen!
    DRMV2Read_Free(*GFP_DRM_HEADER_V2)
    *GFP_DRM_HEADER_V2=#Null
  EndIf  
  
  
  ProcedureReturn ProcRes
EndProcedure


Procedure.q GetServerTime(URL.s)
  Protected date.q, *Connection, loop=#False, Proxy.s, bypassLocal.i, useIESettings.i, noRedirect.i, retStatusCode.i
  WriteLog("Check Datum of "+URL, #LOGLEVEL_DEBUG)
  Repeat
    
    If Settings(#SETTINGS_PROXY)\sValue<>"" And Settings(#SETTINGS_PROXY_PORT)\sValue<>""
      Proxy=Settings(#SETTINGS_PROXY)\sValue+":"+Settings(#SETTINGS_PROXY_PORT)\sValue
    Else  
      Proxy.s=""
    EndIf  
    bypassLocal=Val(Settings(#SETTINGS_PROXY_BYPASS_LOCAL)\sValue)
    useIESettings=Val(Settings(#SETTINGS_PROXY_USE_IE_SETTINGS)\sValue)
    noRedirect=Val(Settings(#SETTINGS_PROXY_NoRedirect)\sValue)
    
    date=-1
    *Connection = HTTPCONTEXT_OpenURL(URL, #GFP_STREAMING_AGENT, #True, proxy, bypassLocal, #False, useIESettings, noRedirect)
    If *Connection
      date = HTTPCONTEXT_QueryDateTime(*Connection, @retStatusCode)  
      WriteLog("Datum is "+Str(date), #LOGLEVEL_DEBUG)
      If date = 0 And (retStatusCode = 200 Or retStatusCode = 206  Or retStatusCode = 204)
        date=-1
      EndIf  
      
      HTTPCONTEXT_Close(*Connection)
      *Connection=#Null
    EndIf
    
    If date<>0
      If date<0
        date=0
      EndIf  
      loop=#True
      
    Else  
      If ConnectionFailedRequester(#False)=#False
        date = -1
        loop = #True
      EndIf
    EndIf  
    
  Until loop
  
  ;Debug date
  ProcedureReturn date.q
EndProcedure 

Global CheckDateSave.q=#USE_ONLY_SYSTEM_FOR_EXPIRE_DATE

Procedure.q GetAllServerTime()
  Protected qServerTime.q
  qServerTime=GetServerTime("http://www.google.com")
  If qServerTime=0:qServerTime=GetServerTime("http://www.heise.de"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.wikipedia.org"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.microsoft.com"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.apple.com"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.zeit.de"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.amazon.com"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.leo.org"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.facebook.com"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.youtube.com"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.yahoo.com"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.blogspot.com"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.live.com"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.twitter.com"):EndIf
  If qServerTime=0:qServerTime=GetServerTime("http://www.msn.com"):EndIf
  ProcedureReturn qServerTime
EndProcedure      

Procedure CheckDate(Date.q)
  Protected result.i=#False, qServerTime.q
  WriteLog("Allowed date is: "+Str(Date), #LOGLEVEL_DEBUG)
  If Date()<Date
    If CheckDateSave=0
      qServerTime=GetAllServerTime()
      ;CheckDateSave=qServerTime
    Else
      ;qServerTime=CheckDateSave
      result.i=#True
      ProcedureReturn result
    EndIf
    
    If qServerTime>0
      If qServerTime<Date
        result.i=#True
      Else
        result=#False
      EndIf
    Else
      result=#False
    EndIf  
  Else
    result=#False
  EndIf 
  ;Debug result
  ProcedureReturn result
EndProcedure

Procedure IsAllowedToPlay(sFile.s)
  Protected iResult.i=#True, date.q=0, SecData.DRM_SECURITY_DATA, sPartition_ID.s, sPlayerVersion.s
  If *GFP_DRM_HEADER_V2
    
    If DRMV2Read_GetBlockData(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_SECURITYDATA, @SecData)
      date = SecData\qExpireDate
    EndIf  
    If date>0
      iResult = CheckDate(date)
      If iResult=#False
        MessageRequester(Language(#L_EXPIRE_DATE),Language(#L_ERROR_CANT_LOAD_MEDIA))
      EndIf  
    EndIf  
    
    sPartition_ID = DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_PARTITION_ID)
    If sPartition_ID<>""
      If sPartition_ID<>GetDriveSerialFromFile(sFile);+GetGraphicCardName()+GetCPUName()
        iResult = #False
        MessageRequester(Language(#L_PROTECTION),Language(#L_ERROR_CANT_LOAD_MEDIA))
      EndIf  
    EndIf 
    
    sPlayerVersion = DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_PLAYERVERSION)
    If sPlayerVersion<>""
      If Val(sPlayerVersion)>#PB_Editor_BuildCount
        MessageRequester(Language(#L_CHECKFORUPDATE),Language(#L_YOU_MUST_USE_A_NEW_PLAYER_VERSION))
        iResult = #False
      EndIf  
    EndIf 
    
    
    
  EndIf  
  ProcedureReturn iResult
EndProcedure  

Procedure ProtectWindow_Ende()
  WriteLog("Close because screencapture program!")
  FreeMediaFile()
  SetMediaSizeTo0()
  ProcessAllEvents()
  ;CloseWindow(#WINDOW_MAIN)
  ;MessageRequester(Language(#L_ERROR), Language(#L_DISABLEMIRRORTREIBER),#MB_ICONERROR)
  If IsWindow(#WINDOW_MAIN)
    CloseWindow(#WINDOW_MAIN)
  EndIf  
  Requester_Error(Language(#L_IT_IS_NOT_ALLOWED_TO_CAPTURE_THIS_VIDEO))
  EndPlayer()
EndProcedure
Procedure SetSnapshotAllowed(TakeOff.i=#False)
  Protected Result=#True
  CheckDebuggerActive()
  If IsSnapshotAllowedSetting<>IsSnapshotAllowed
    If IsGadget(#GADGET_BUTTON_SNAPSHOT)
      If IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_ALLOW
        DisableGadget(#GADGET_BUTTON_SNAPSHOT, #False)
        DisableMenuItem(#MENU_MAIN,#MENU_SNAPSHOT, #False)
      Else
        DisableGadget(#GADGET_BUTTON_SNAPSHOT, #True)
        DisableMenuItem(#MENU_MAIN,#MENU_SNAPSHOT, #True)
      EndIf
    EndIf
    
    UnProtectWindow(WindowID(#WINDOW_MAIN))
    
    
    If IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_DISALLOW
      If OSVersion()<#PB_OS_Windows_Vista;XP, 2000
        WriteLog("Use DISABLEPRINTHOTKEYS", #LOGLEVEL_DEBUG)
        ProtectWindow(WindowID(#WINDOW_MAIN), #PROTECT_DISABLEPRINTHOTKEYS, #Null)
      Else;Vista, Win7
        WriteLog("Use DISABLEPRINTHOTKEYS FORCELAYEREDWINDOW ENABLECONTENTPROTECTION", #LOGLEVEL_DEBUG)
        ProtectWindow(WindowID(#WINDOW_MAIN), #PROTECT_DISABLEPRINTHOTKEYS|#PROTECT_FORCELAYEREDWINDOW|#PROTECT_ENABLECONTENTPROTECTION, #Null)
      EndIf
    EndIf
    
    If IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_PROTECTION_FORCE
      ;Kein Layered Window für Windows XP, da dies mit Overlay flackert!
      If OSVersion()<#PB_OS_Windows_Vista;XP, 2000
        WriteLog("Use DETECTMIRRORDRIVERS and DISABLEPRINTHOTKEYS", #LOGLEVEL_DEBUG)
        ProtectWindow(WindowID(#WINDOW_MAIN), #PROTECT_DETECTMIRRORDRIVERS|#PROTECT_DISABLEPRINTHOTKEYS, @ProtectWindow_Ende())
      Else;Vista, Win7
        WriteLog("Use DISABLEPRINTHOTKEYS FORCELAYEREDWINDOW ENABLECONTENTPROTECTION DETECTMIRRORDRIVERS", #LOGLEVEL_DEBUG)
        ProtectWindow(WindowID(#WINDOW_MAIN), #PROTECT_DISABLEPRINTHOTKEYS|#PROTECT_FORCELAYEREDWINDOW|#PROTECT_ENABLECONTENTPROTECTION|#PROTECT_DETECTMIRRORDRIVERS, @ProtectWindow_Ende())
      EndIf
      
      
    EndIf
    IsSnapshotAllowedSetting = IsSnapshotAllowed
    HoverGadgetImages()
  EndIf
  
  CompilerIf #USE_OEM_VERSION = #False
    If IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_PROTECTION_FORCE And VMDetect_IsVirtual() 
      MessageRequester(Language(#L_WARNING), Language(#L_IT_IS_NOT_ALLOWED_TO_PLAY_IN_VM), #MB_ICONERROR)
      Result=#False
    EndIf 
  CompilerEndIf
  
  If Result=#True And TakeOff=#False
    Result = IsAllowedToPlay(MediaFile\sRealFile)
  EndIf
  ProcedureReturn Result
EndProcedure


; Procedure FindBadDLL()
;   Protected Windir.s, snapshot,modulehandle.MODULEENTRY32, result=#False
;   Windir.s=LCase(GetEnvironmentVariable("WinDir"))
;   snapshot = CreateToolhelp32Snapshot_(#TH32CS_SNAPMODULE, 0) 
;   If snapshot 
;     
;     modulehandle.MODULEENTRY32
;     modulehandle\dwSize = SizeOf(MODULEENTRY32) 
;     
;     If Module32First_(snapshot, @modulehandle)
;       While Module32Next_(snapshot, @modulehandle)         
;         If modulehandle\hModule
;           If Not LCase(Left(__GetModuleFullPath(PeekS(@modulehandle\szModule)),Len(Windir)))=Windir
;             MessageRequester("",__GetModuleFullPath(PeekS(@modulehandle\szModule)))
;             result = #True
;           EndIf   
;         EndIf
;       Wend
;     EndIf
;     CloseHandle_(snapshot)
;   EndIf
;   ProcedureReturn result
; EndProcedure  


Procedure HoneyPot()
  Protected sFile.s=Hex(Random($FFFFFF))+".png"
  Protected media, result=#False, size=0
  If Random(100)<50
    VirtualFile_CreateFromMemory(sFile, ?DS_error, ?DS_error_end-?DS_error, #False)
    size=60
  Else
    VirtualFile_CreateFromMemory(sFile, ?DS_noConnection, ?DS_noConnection_end-?DS_noConnection, #False)
    size=64
  EndIf  
  
  media = DShow_LoadMediaEx(sFile,#Null, #RENDERER_VMR9, #True,  #RENDERER_DSOUND, #False, #False, #True, #False)
  If DShow_GetMediaWidth(media)<>size
    result=#True
  EndIf
  DShow_FreeMedia(media)
  VirtualFile_RemoveFile(sFile)
  ProcedureReturn result 
EndProcedure  

Procedure IsFRAPSLoadedToProcess()
  Protected result, hModule
  result = #False
  hModule = GetModuleHandle_("FRAPS32.DLL")
  If hModule
    If GetProcAddress_(hModule, "FrapsCount"):result = #True:EndIf
    If GetProcAddress_(hModule, "FrapsFunc"):result = #True:EndIf
    If GetProcAddress_(hModule, "FrapsKey"):result = #True:EndIf
    If GetProcAddress_(hModule, "FrapsProcCALLWND"):result = #True:EndIf
    If GetProcAddress_(hModule, "FrapsProcCBT"):result = #True:EndIf
    If GetProcAddress_(hModule, "FrapsSetup"):result = #True:EndIf
    If GetProcAddress_(hModule, "FrapsSharedData"):result = #True:EndIf
    If GetProcAddress_(hModule, "FrapsVersion"):result = #True:EndIf  
  EndIf 
  ProcedureReturn result
EndProcedure  
Procedure CheckForScreenCapture()
  
  CompilerIf #USE_PROTECTWINDOW_CLIPBOARD
    OpenClipboard_(#Null)
    If IsClipboardFormatAvailable_(2)
      WriteLog("Found image in clipboard", #LOGLEVEL_DEBUG)
      EmptyClipboard_()
    EndIf
    CloseClipboard_()
  CompilerEndIf
  
  
  CompilerIf #USE_PROTECTWINDOW_BLACKLIST
    Protected sTitle.s, hWnd.i, Window, i.i, FoundCaptureWindow=#False, device.f, device$, String.s, sdll.s, hModule, D3D9.i
    
    
    ;SECURE THE BLACKLIST WAS NOT MANIPULATED!!!
    UseSHA3Fingerprint()
    Define tmp.s = #PROTECTWINDOW_BLACKLIST
    If Fingerprint(@tmp, MemoryStringLength(@tmp), #PB_Cipher_SHA3) <> "c4e80b5149a2d48e686d71894c0b63f735651c203ef8946d71f72b81815a6263"
      WriteLog("Found: Blacklist manipulation!", #LOGLEVEL_DEBUG)
      ProtectWindow_Ende()
      End
    EndIf
    
    tmp.s = #PROTECTHOOCK_BLACKLIST
    If Fingerprint(@tmp, MemoryStringLength(@tmp), #PB_Cipher_SHA3) <> "9d5a8c72abe917b922e42bbd169ecd6c9d2a020c359d8fa7e285e07a7cf9b181"
      WriteLog("Found: Blacklist Hook manipulation!", #LOGLEVEL_DEBUG)
      ProtectWindow_Ende()
      End    
    EndIf  
    
    
    
    For i=1 To CountString(#PROTECTWINDOW_BLACKLIST, "|")
      sTitle.s=StringField(#PROTECTWINDOW_BLACKLIST, i, "|")
      If sTitle<>""
        If sTitle="Taksi - ":sTitle=sTitle+LCase(GetFilePart(ProgramFilename())):EndIf
        
        hWnd=FindWindow_(#Null,@sTitle)
        If hWnd
          WriteLog("Found: "+sTitle, #LOGLEVEL_DEBUG)
          ProtectWindow_Ende()
          End
        EndIf
      EndIf
    Next  
    
    CompilerIf #USE_NEED_SECURE_ENVIRONMENT
      CompilerIf #PB_Editor_CreateExecutable 
        If Not TestedIsParentTrusted
          TestedIsParentTrusted=#True
          If isParentProcessTrusted()=#False
            WriteLog("Not trusted", #LOGLEVEL_DEBUG)
            ProtectWindow_Ende()
            End
          EndIf  
        EndIf  
      CompilerEndIf
    CompilerEndIf
    
    
    
    
    
    ;     If FindBadDLL()
    ;       WriteLog("Found: Bad dll", #LOGLEVEL_DEBUG)
    ;       ProtectWindow_Ende()
    ;       End
    ;     EndIf  
    
    If IsFRAPSLoadedToProcess()
      WriteLog("Found: FRAPS", #LOGLEVEL_DEBUG)
      ProtectWindow_Ende()
      End
    EndIf  
    
    If iMediaObject
      If UsedOutputMediaLibrary=#MEDIALIBRARY_DSHOW
        D3D9=DShow_GetOwnVMR9Direct3DDevice9(iMediaObject)
        If D3D9
          If IsDirect3DDevice9Hooked(D3D9)
            WriteLog("Found: Direct3DDevice9 hooked", #LOGLEVEL_DEBUG)
            ProtectWindow_Ende()
            End
          EndIf 
        EndIf
      EndIf
    EndIf
    
    For i=1 To CountString(#PROTECTHOOCK_BLACKLIST, "|")
      sdll.s=StringField(#PROTECTHOOCK_BLACKLIST, i, "|")
      If sdll<>""
        hModule = GetModuleHandle_(sdll)
        If hModule
          WriteLog("Found: "+sdll, #LOGLEVEL_DEBUG)
          ProtectWindow_Ende()
          End
        EndIf
      EndIf
    Next  
    
  CompilerEndIf
  
  
  CompilerIf #USE_SC_HONEYPOT
    If Not TryedHoneyPot
      TryedHoneyPot=#True
      If HoneyPot()
        WriteLog("Honeypot", #LOGLEVEL_DEBUG)
        ProtectWindow_Ende()
        End
      EndIf
    EndIf
  CompilerEndIf
  
  If OSVersion()=#PB_OS_Windows_8 
    If DWM_IsEnabled()=#False
      WriteLog("Windows 8 without DWM! ", #LOGLEVEL_DEBUG)
      ProtectWindow_Ende()
      End
    EndIf  
  EndIf  
  
EndProcedure


Procedure.s _GetFolderFiles(sFolder.s)
  Protected iFolder.i, sName.s
  iFolder.i = ExamineDirectory(#PB_Any, sFolder, "*.*") 
  If iFolder
    While NextDirectoryEntry(iFolder)
      sName.s=DirectoryEntryName(iFolder)
      If sName<>"." And sName<>".." And sName<>"..."
        If DirectoryEntryType(iFolder) = #PB_DirectoryEntry_File
          sGetFolderFiles+sFolder.s+"\"+sName+Chr(10)
        Else
          _GetFolderFiles(sFolder.s+"\"+sName)
        EndIf
      EndIf
    Wend
    FinishDirectory(iFolder)
  EndIf
EndProcedure
Procedure.s GetFolderFiles(sFolder.s)
  sGetFolderFiles.s=""
  _GetFolderFiles(sFolder.s)
  ProcedureReturn sGetFolderFiles
EndProcedure
Procedure.s GetExtensionPartEx(Path.s)
  Protected Ext.s, Ext2.s
  Ext=GetExtensionPart(Path.s)
  If Ext
    Ext2=GetExtensionPart(Mid(Path.s, 1, Len(Path)-Len(Ext)-1))
    If Ext2
      Ext=Ext2+"."+Ext
    EndIf  
  EndIf  
  ProcedureReturn Ext
EndProcedure

Procedure FindIndexOfOffset(qOffset.q)
  Protected iIndex.i, FileStruc.EXE_ATTACHMENT_FILEENTRY, Num.i, i.i
  Num.i=GetNumEXEAttachments()
  If Num>0
    For i=0 To Num
      If ReadEXEAttachment(i, FileStruc)
        If FileStruc\absoluteOffset = qOffset
          ProcedureReturn i
        EndIf  
      EndIf  
    Next
  EndIf    
  ProcedureReturn 0
EndProcedure  





Procedure CheckBufferingToLoadMedia()
  Protected isReady.i, count.i
  If BufferingMedia And MediaFile\StreamingFile
    count=GetDownloadedBlockCount(MediaFile\StreamingFile)
    VIS_Buffering_SetPercent(count/#STREAMING_BUFFERING_COUNT)
    
    If count>=#STREAMING_BUFFERING_COUNT Or count>=GetMaxDownloadedBlocks(MediaFile\StreamingFile)
      ;VIS_SetVIS(#False);wird schon im _LoadMediaFile_LoadPlay gemacht, wenn es ein Video ist
      _LoadMediaFile_LoadPlay(BufferingMedia, BufferingMediaTitle, BufferingMediaEncryption, BufferingMediaOffset, MediaFile\StreamingFile)
      BufferingMedia.s=""
      BufferingMediaTitle.s=""
      BufferingMediaEncryption.i=#False
      BufferingMediaOffset.q=0
      VIS_SetVIS(#False);Falls kein video, noch deaktivieren!
    EndIf
  EndIf
EndProcedure 
Procedure StartBufferingToLoadMedia(sFile.s, sMediaTitle.s, IsEncrypted.i, Offset.q)
  If sFile
    BufferingMedia.s=sFile
    BufferingMediaTitle.s=sMediaTitle
    BufferingMediaEncryption.i=IsEncrypted
    BufferingMediaOffset = Offset
    VIS_SetVIS(#VIS_BUFFERING)
  EndIf
EndProcedure 

Procedure LoadAttachedMedia(sFile.s, sMediaTitle.s="", qOffset.q=0);ADD DRM V2
  Protected Num.i, FileStruc.EXE_ATTACHMENT_FILEENTRY, iIndex=0, CodecName.s, CodecLink.s
  Protected iFile.i, IsEncrypted.i, sSubtitleFile.s, CantLoad.i, res.i, iHeaderSize.i, SecData.DRM_SECURITY_DATA
  WriteLog("LoadAttachedMedia "+sFile+" Title: "+sMediaTitle, #LOGLEVEL_DEBUG)
  
  If OpenEXEAttachements(sFile)
    Num.i=GetNumEXEAttachments()
    If Num>0
      If Num=1 Or qOffset Or (Num=2 And ReadEXEAttachmentByName("*COMMANDS*", FileStruc)); One file in exe
        If qOffset
          iIndex = FindIndexOfOffset(qOffset.q)
        Else
          iIndex=0
        EndIf
        
        If ReadEXEAttachment(iIndex, FileStruc)
          qOffset = FileStruc\absoluteOffset
          
          iFile=ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
          If iFile
            
            ;If qOffset:FileStruc\absoluteOffset=qOffset:EndIf
            
            FileSeek(iFile, FileStruc\absoluteOffset)
            If ReadLong(iFile) = 1145392472;'DEMX'
              IsEncrypted=#True
            EndIf 
            CloseFile(iFile)
            
            If IsEncrypted
              ;ReadDRMHeader(sFile, *GFP_DRM_HEADER, "RR is Testing", FileStruc\absoluteOffset);Gets the header of the file
              ;IsSnapshotAllowed = GetDRMHeaderSnapshotProtection(*GFP_DRM_HEADER)
              IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_UNKNOWN
              TestDecryptPW(sFile, FileStruc\absoluteOffset)
              If sGlobalPassword
                
                If *GFP_DRM_HEADER_V2
                  DRMV2Read_Free(*GFP_DRM_HEADER_V2)
                  *GFP_DRM_HEADER_V2=#Null
                EndIf  
                
                *GFP_DRM_HEADER_V2 = DRMV2Read_ReadFromFile_Cached(sFile, sGlobalPassword, FileStruc\absoluteOffset);Password ist nicht egal!       
                If *GFP_DRM_HEADER_V2
                  iHeaderSize.i=DRMV2Read_GetOrginalHeaderSize(*GFP_DRM_HEADER_V2)
                  
                  CodecLink = DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_CODECLINK)
                  CodecName = DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_CODECNAME)
                  
                  If DRMV2Read_GetBlockData(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_SECURITYDATA, @SecData)
                    IsSnapshotAllowed = SecData\lSnapshotProtection
                  EndIf  
                EndIf
              EndIf       
              If IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_UNKNOWN
                IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_ALLOW
                SetSnapshotAllowed(#True)
                SetMediaSizeTo0()
                ;StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA))    
                ProcedureReturn #False
              EndIf      
            Else
              IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_ALLOW
            EndIf  
            If SetSnapshotAllowed()
              
              MediaFile\Memory = 1; Bedeutet das die Virtuelle Datei wieder Freigegeben wird
              MediaFile\sRealFile = sFile
              MediaFile\sFile = GetPathPart(sFile)+Hex(Random($FFFFFF))+"."+GetExtensionPart(sFile)
              MediaFile\qOffset = qOffset
              
              Playlist\iID = #False
              Playlist\iTempID = #False
              
              
              CompilerIf #USE_VIRTUAL_FILE
                If IsEncrypted
                  ;VirtualFile_AddEncryptedFile(MediaFile\sFile, MediaFile\sRealFile, GenerateCryptionBuffer(sGlobalPassword), FileStruc\absoluteOffset+SizeOf(DRM_HEADER), FileStruc\size-SizeOf(DRM_HEADER))
                  
                  VirtualFile_AddEncryptedFile(MediaFile\sFile, MediaFile\sRealFile, DRMV2Read_CreateCryptionBufferCopy(*GFP_DRM_HEADER_V2), FileStruc\absoluteOffset+iHeaderSize, FileStruc\size-iHeaderSize)
                  
                Else
                  WriteLog("Load non protected media from attachment", #LOGLEVEL_DEBUG)
                  VirtualFile_AddEncryptedFile(MediaFile\sFile, MediaFile\sRealFile, #Null, FileStruc\absoluteOffset, FileStruc\size)
                EndIf
              CompilerEndIf
              
              _LoadMediaFile_LoadPlay(MediaFile\sFile, sMediaTitle.s, IsEncrypted, qOffset, #Null)
              
              CompilerIf #USE_SUBTITLES
                sSubtitleFile=FindSubtileFile(MediaFile\sRealFile)
                If sSubtitleFile
                  WriteLog("Found subtitles: "+sSubtitleFile, #LOGLEVEL_DEBUG)
                  LoadSubtileFile(sSubtitleFile, MediaFPS(iMediaObject))
                EndIf  
              CompilerEndIf
              
            Else
              CantLoad=#True
            EndIf
            
          EndIf
        EndIf  
        
        If MediaState(iMediaObject)=#False
          CantLoad=#True
        EndIf
        
      Else;Many files in exe
        LoadCoverFlowFormAttachment(sFile.s)
        
      EndIf
    Else
      CantLoad=#True
    EndIf
  Else
    CantLoad=#True
  EndIf
  
  If CantLoad
    IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_ALLOW
    SetSnapshotAllowed(#True)
    SetMediaSizeTo0()
    
    StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA))    
    
    ;NICHT ANZEIGEN WIRD SCHON ZUVOR GEMACHT!!!
    ;ENCRYPTED WITH CODEC INFO SHOW MSG!
    ;If CodecName<>"" And CodecLink<>""
    ;  MissingCodecRequester(CodecName, CodecLink)
    ;EndIf  
  EndIf  
  
EndProcedure
Procedure.s _LoadMediaFile_RAM(sFile.s, qSize.q, IsEncrypted.i, iFile.i)
  Protected sFileExt.s
  WriteLog("LoadMedia_RAM "+sFile+" File:"+Str(iFile)+" Size: "+Str(qSize)+" Enc:"+Str(IsEncrypted), #LOGLEVEL_DEBUG)
  ;Check the Media Cache:
  
  MediaFile\Memory = CheckMediaCache(sFile)
  If MediaFile\Memory = #False
    FreeMediaCache(qSize, Val(Settings(#SETTINGS_RAM_SIZE)\sValue)*1024*1024)
    If IsEncrypted
      TestDecryptPW(sFile.s)
      If sGlobalPassword
        
        MediaFile\Memory = DecryptDRMV2FileToMemory(sFile, sGlobalPassword)
      EndIf
      
      If MediaFile\Memory=#False
        WriteLog("Decrypt file faild!", #LOGLEVEL_DEBUG)
        ProcedureReturn ""
      EndIf
    Else
      MediaFile\Memory = AllocateMemory(Lof(iFile))
      ReadData(iFile, MediaFile\Memory, Lof(iFile))
    EndIf
    AddMediaCache(sFile.s, MediaFile\Memory, qSize)
  Else
    WriteLog("Media already Loaded", #LOGLEVEL_DEBUG)
  EndIf
  
  If iFile:CloseFile(iFile):iFile=#Null:EndIf
  
  
  
  
  
  If IsEncrypted
    If *GFP_DRM_HEADER_V2
      DRMV2Read_Free(*GFP_DRM_HEADER_V2)
      *GFP_DRM_HEADER_V2=#Null
    EndIf  
    *GFP_DRM_HEADER_V2 = DRMV2Read_ReadFromFile_Cached(sFile, sGlobalPassword, 0)       
    
    sFileExt=GetExtensionPart(DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_ORGINALNAME))
  Else  
    sFileExt=GetExtensionPart(sFile)
  EndIf
  
  CompilerIf #USE_VIRTUAL_FILE
    If IsVirtualFileUsed
      ;The extension mp4 seems to have a problem with vitual files!
      CompilerIf #USE_FULLPATH_WITH_VIRTUAL_FILES
        sFile.s = GetPathPart(sFile)+Hex(Random($FFFFFF))+"."+sFileExt
      CompilerElse
        sFile.s = Hex(Random($FFFFFF))+"."+sFileExt
      CompilerEndIf
      
      VirtualFile_CreateFromMemory(sFile, MediaFile\Memory, qSize, #False)
    EndIf
  CompilerEndIf
  WriteLog("Load from RAM "+GetFilePart(MediaFile\sRealFile), #LOGLEVEL_DEBUG)
  ProcedureReturn sFile
EndProcedure
Procedure.s _LoadMediaFile_Harddisk(sFile.s, iFile, qSize.q, IsEncrypted.i, iHeaderSize.i)
  Protected sExistingFile.s
  WriteLog("LoadMedia_HDD "+sFile+" File:"+Str(iFile)+" Size: "+Str(qSize)+" Enc:"+Str(IsEncrypted), #LOGLEVEL_DEBUG)
  WriteLog("Load from Harddisk "+GetFilePart(MediaFile\sRealFile), #LOGLEVEL_DEBUG)
  If iFile And IsFile(iFile):CloseFile(iFile):EndIf
  If IsEncrypted
    sExistingFile = sFile
    TestDecryptPW(sFile.s)
    If sGlobalPassword
      CompilerIf #USE_VIRTUAL_FILE
        If IsVirtualFileUsed
          
          If *GFP_DRM_HEADER_V2
            DRMV2Read_Free(*GFP_DRM_HEADER_V2)
            *GFP_DRM_HEADER_V2=#Null
          EndIf  
          *GFP_DRM_HEADER_V2 = DRMV2Read_ReadFromFile_Cached(sExistingFile, sGlobalPassword, 0)  
          
          CompilerIf #USE_FULLPATH_WITH_VIRTUAL_FILES
            sFile.s = GetPathPart(sFile)+Hex(Random($FFFFFF))+"."+GetExtensionPart(DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_ORGINALNAME));USES NOW THE ORG FILEEXT FOR PROTECTED FILES 27.07.10, must be tested
          CompilerElse
            sFile.s = Hex(Random($FFFFFF))+"."+GetExtensionPart(DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_ORGINALNAME));GetExtensionPart(sFile)
          CompilerEndIf
          
          
          
          VirtualFile_AddEncryptedFile(sFile, sExistingFile, DRMV2Read_CreateCryptionBufferCopy(*GFP_DRM_HEADER_V2), iHeaderSize, qSize)
          
          MediaFile\Memory = 1
        EndIf
      CompilerEndIf
    Else
      sFile=""
    EndIf
  EndIf
  ProcedureReturn sFile
EndProcedure
Procedure   _LoadMediaFile_URL(sFile.s, iAddPrevious.i)
  Protected iPlay.i, UseWindowless.i, iVideoRendererReal.i
  
  
  WriteLog("LoadMedia_URL "+sFile+" Prev:"+Str(iAddPrevious))
  If FindString(LCase(sFile), "http://", 1) Or FindString(LCase(sFile), "https://", 1)
    If Playlist\iID;isPlaylist
      If iAddPrevious:AddPreviousFile(sFile.s, Playlist\iCurrentMedia):EndIf
    Else
      If iAddPrevious:AddPreviousFile(sFile.s, -1):EndIf
    EndIf  
    
    UseWindowless=#True
    iVideoRendererReal=iVideoRenderer
    If iVideoRendererReal=6:iVideoRendererReal=#RENDERER_VMR9:UseWindowless=#False:EndIf
    If iVideoRendererReal=7:iVideoRendererReal=#RENDERER_VMR7:UseWindowless=#False:EndIf
    
    iMediaObject = DShow_LoadMediaURLEx(sFile, GadgetID(#GADGET_VIDEO_CONTAINER), iVideoRenderer, UseWindowless,  iAudioRenderer, #False, #True, iOwnVideoRenderer)
    
    WriteLog("Load from Internet "+GetFilePart(MediaFile\sRealFile), #LOGLEVEL_DEBUG)
    StatusBarText(0, 0, GetFilePart(MediaFile\sRealFile))
    SetWindowTitle(#WINDOW_MAIN, #PLAYER_NAME+" - "+GetFilePart(MediaFile\sRealFile))
    SetMediaSizeToOrginal()
    iPlay=PlayMedia(iMediaObject)
    If iPlay
      MediaFile\iPlaying = #True
      SetMediaAspectRation()
    Else
      MediaFile\iPlaying=#False
      StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA))
    EndIf
  Else
    StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA))
    SetMediaSizeTo0()
  EndIf
  ProcedureReturn MediaFile\iPlaying
EndProcedure


Procedure _LoadMediaFile_LoadPlay(sFile.s, sMediaTitle.s, IsEncrypted.i, qOffset.q, *Stream)
  Protected iPlay.i, UseWindowless.i, iVideoRendererReal.i, installCodec.i, sCodecFile.s, CodecName.s, CodecLink.s, iProtectionFailed.i=#False
  If sFile
    WriteLog("LoadMedia_Play "+sFile+" Enc:"+Str(IsEncrypted)+" Title: "+sMediaTitle, #LOGLEVEL_DEBUG)
    
    MediaFile\sFile = sFile
    
    If IsEncrypted
      If *GFP_DRM_HEADER_V2
        CodecLink = DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_CODECLINK)
        CodecName = DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_CODECNAME)
      EndIf
    EndIf
    
    If IsSnapshotAllowed<>#GFP_DRM_SCREENCAPTURE_ALLOW ;Screenshot protection
      
      
      If IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_PROTECTION_FORCE;Advanced Protection
        CheckForScreenCapture()
        ;iMediaObject = LoadMedia(sFile, GadgetID(#GADGET_VIDEO_CONTAINER), #RENDERER_VMR7,  iAudioRenderer, #False, #True)
        If OSVersion()<#PB_OS_Windows_XP
          MessageRequester(Language(#L_VIDEO_PROTECTION), Language(#L_CANT_PLAY_UNDER_2000), #MB_ICONINFORMATION)
          WriteLog(Language(#L_CANT_PLAY_UNDER_2000), #LOGLEVEL_DEBUG)
        Else
          If OSVersion()<#PB_OS_Windows_Vista;XP, 2000
                                             ;Muss Overlay sein! 
            iMediaObject = LoadMedia(sFile, GadgetID(#GADGET_VIDEO_CONTAINER), #RENDERER_VMR7,  iAudioRenderer, #False, #True, #False, #False, #True)
            If iMediaObject=#Null And DShow_VMR7OverlayChckFailed()
              iProtectionFailed=#True
              ;Funktioniert doch nicht, erstellt auch overlay renderer ohne overlay!
              ;2011-07-28 Use Overlay mixer if VMR7 failes!
              ;WriteLog("VMR7 Overlay failed!", #LOGLEVEL_DEBUG)
              ;DShow_Ugly_EnableRendererTest(#True)
              ;iMediaObject = LoadMedia(sFile, GadgetID(#GADGET_VIDEO_CONTAINER), #RENDERER_OVERLAYMIXER,  iAudioRenderer, #False, #False, #False, #False, #False)
              ;DShow_Ugly_EnableRendererTest(#False)
              ;If iMediaObject = #Null
              MessageRequester(Language(#L_VIDEO_PROTECTION), Language(#L_THIS_MEDIA_NEEDS_OVERLAY)+#CRLF$+Language(#L_CLOSE_ALL_OTHER_PLAYER), #MB_ICONINFORMATION)
              WriteLog(Language(#L_THIS_MEDIA_NEEDS_OVERLAY), #LOGLEVEL_DEBUG)  
              ;EndIf
              
            EndIf  
          Else
            iMediaObject = LoadMedia(sFile, GadgetID(#GADGET_VIDEO_CONTAINER), #RENDERER_VMR9,  iAudioRenderer, #False, #False, #True)
          EndIf
        EndIf
        
      Else;Not enforce protection
        
        If OSVersion()<#PB_OS_Windows_Vista;XP, 2000
                                           ;Overlay wenn vorhanden! 
          iMediaObject = LoadMedia(sFile, GadgetID(#GADGET_VIDEO_CONTAINER), #RENDERER_VMR7,  iAudioRenderer, #False, #True, #False, #False, #False)
        Else
          iMediaObject = LoadMedia(sFile, GadgetID(#GADGET_VIDEO_CONTAINER), #RENDERER_VMR9,  iAudioRenderer, #False, #False, #True)
        EndIf
      EndIf
      
      If UsedOutputMediaLibrary=#MEDIALIBRARY_DSHOW
        If DShow_IsRenderlessVMR9(iMediaObject)
          DShow_EnableRenderlessVMR9Border(iMediaObject, #True, Val(Settings(#SETTINGS_BKCOLOR)\sValue))
          DShow_EnableEraseBackground(iMediaObject, #True);Nur aktivieren wenn es wirklich VMR9 Renderless ist.
          WriteLog("Enable erase background", #LOGLEVEL_DEBUG)
        EndIf
      EndIf
      
      
      If iMediaObject=#Null And iProtectionFailed=#False;Second try with orginal file!
        sCodecFile=Mid(sFile, 1, Len(MediaFile\sRealFile)-Len(GetExtensionPart(MediaFile\sRealFile)))+#GFP_CODEC_EXTENSION
        If IsCodecFile(sCodecFile)
          InstallCodec_Requester(sCodecFile)
          installCodec=#True
        EndIf
        
        If IsEncrypted
          If installCodec
            WriteLog("Loading faild, second try! (new codec)", #LOGLEVEL_DEBUG)
            iMediaObject = LoadMedia(sFile, GadgetID(#GADGET_VIDEO_CONTAINER), #RENDERER_VMR9,  iAudioRenderer, #False, #False, #True)
            If UsedOutputMediaLibrary=#MEDIALIBRARY_DSHOW
              If DShow_IsRenderlessVMR9(iMediaObject)
                DShow_EnableRenderlessVMR9Border(iMediaObject, #True, Val(Settings(#SETTINGS_BORDER_COLOR)\sValue))
              EndIf  
            EndIf  
          EndIf
        Else  
          WriteLog("Loading faild, second try! (Realfile)", #LOGLEVEL_DEBUG)
          FreeMediaFile()
          iMediaObject = LoadMedia(MediaFile\sRealFile, GadgetID(#GADGET_VIDEO_CONTAINER), #RENDERER_VMR9,  iAudioRenderer, #False, #False, #True)
          If UsedOutputMediaLibrary=#MEDIALIBRARY_DSHOW
            If DShow_IsRenderlessVMR9(iMediaObject)
              DShow_EnableRenderlessVMR9Border(iMediaObject, #True, Val(Settings(#SETTINGS_BORDER_COLOR)\sValue))
            EndIf
          EndIf  
        EndIf
      EndIf  
    Else
      UseWindowless=#True
      iVideoRendererReal=iVideoRenderer
      If iVideoRendererReal=6:iVideoRendererReal=#RENDERER_VMR9:UseWindowless=#False:EndIf
      If iVideoRendererReal=7:iVideoRendererReal=#RENDERER_VMR7:UseWindowless=#False:EndIf
      If iOwnVideoRenderer=#True:UseWindowless=#False:EndIf
      
      iMediaObject = LoadMedia(sFile, GadgetID(#GADGET_VIDEO_CONTAINER), iVideoRendererReal,  iAudioRenderer, #False, UseWindowless, iOwnVideoRenderer)
      
      
      
      If iMediaObject=#Null;Second try with orginal file!
        If IsCodecFile(sCodecFile)
          InstallCodec_Requester(sCodecFile)
        EndIf
        WriteLog("Loading faild, second try!", #LOGLEVEL_DEBUG)
        FreeMediaFile()
        iMediaObject = LoadMedia(MediaFile\sRealFile, GadgetID(#GADGET_VIDEO_CONTAINER), iVideoRendererReal,  iAudioRenderer, #False, UseWindowless, iOwnVideoRenderer)
      EndIf
      
      If UsedOutputMediaLibrary=#MEDIALIBRARY_DSHOW
        If DShow_IsRenderlessVMR9(iMediaObject)
          DShow_EnableRenderlessVMR9Border(iMediaObject, #True, Val(Settings(#SETTINGS_BKCOLOR)\sValue))
          DShow_EnableEraseBackground(iMediaObject, #True);Nur aktivieren wenn es wirklich VMR9 Renderless ist.
          WriteLog("Enable erase background", #LOGLEVEL_DEBUG)
        EndIf
      EndIf
    EndIf
    
    iIsMediaObjectVideoDVD = #False
    If iMediaObject
      If sMediaTitle = ""
        sMediaTitle.s = GetMediaFileTitle(MediaFile\sRealFile, IsEncrypted, *Stream, MediaFile\qOffset)
      EndIf
      If sMediaTitle=""
        sMediaTitle=GetFilePart(MediaFile\sRealFile)
      EndIf  
      
      StatusBarText(0, 0, sMediaTitle)
      SetWindowTitle(#WINDOW_MAIN, #PLAYER_NAME +" - "+sMediaTitle)
      If MediaWidth(iMediaObject)>0
        VIS_SetVIS(#False)
      EndIf
      SetMediaSizeToOrginal()
      iPlay=PlayMedia(iMediaObject)
      
      
      If MediaState(iMediaObject)
        MediaFile\iPlaying = #True
        SetMediaAspectRation()
      Else
        IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_ALLOW
        SetSnapshotAllowed(#True)
        FreeMediaFile()
        iMediaObject=0
        SetMediaSizeTo0()
        StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA))
        
        ;CODEC INFO SHOW MSG!
        If iProtectionFailed=#False
          If CodecName<>"" And CodecLink<>""
            MissingCodecRequester(CodecName, CodecLink)
          Else
            ;If FindString(#GFP_FORMAT_MEDIA,LCase(GetExtensionPart(sFile)))
            MissingCodecRequester("", "http://www.codecguide.com") 
            ;EndIf  
          EndIf  
        EndIf
      EndIf
      
      If iMediaObject
        MediaPutVolume(iMediaObject, -100+GetVolumeGadgetState(iVolumeGadget))
        LoadMediaPos(iMediaObject, MediaFile\sRealFile, qOffset)
      EndIf
      
      ;ProcedureReturn #True
    Else
      
      SetMediaSizeTo0()
      
      StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA))
      
      ;CODEC INFO SHOW MSG!
      If iProtectionFailed=#False
        If CodecName<>"" And CodecLink<>""
          MissingCodecRequester(CodecName, CodecLink)
        Else
          ;If FindString(#GFP_FORMAT_MEDIA,LCase(GetExtensionPart(sFile)))
          MissingCodecRequester("", "http://www.codecguide.com") 
          ;EndIf  
        EndIf  
      EndIf
      
    EndIf
  Else
    SetMediaSizeTo0()
  EndIf
  VIS_SetDSHOWObj(iMediaObject)
EndProcedure
Procedure _LoadMediaFile(sFile.s, iAddPrevious.i = #True, sMediaTitle.s = "", qOffset.q=0)
  Protected iWidth.i, iHeight.i, iFile.i, *BufferPtr, qSize.q, iPlay.i, IsEncrypted.i, iFileFormat.i, Ext.s
  Protected sCodecFile.s, sSubtitleFile.s, sDRMOrgFileName.s, sProtokoll.s, sURL.s, sProxy.s, ibypassLocal.i, iforceProxy.i, *SteamingFile.StreamingFile, DRM.i, isULR.i
  Protected iNoRedirect.i, res.i, SecData.DRM_SECURITY_DATA, iHeaderSize.i, iWantedToLoad.i=#False
  sFile=ReplaceString(sFile,"gfp://","http://", #PB_String_NoCase)
  
  CheckDebuggerActive();No loading with attached debugger
  If DebuggerActive
    End
  EndIf  
  
  sProtokoll=URL_GetProtocol(sFile)
  If sProtokoll="http"
    If LCase(Mid(sFile,1,7))<>"http://"
      sProtokoll=""
    EndIf  
  EndIf  
  
  
  qSize=FileSize(sFile)
  If qSize=-1 And FileSize(GetPathPart(ProgramFilename())+sFile)>0:sFile=GetPathPart(ProgramFilename())+sFile:qSize=FileSize(sFile):EndIf
  
  If sFile And LCase(sFile)<>"http://" And LCase(sFile)<>"https://" And (qSize>0 Or sProtokoll="http" Or sProtokoll="https" Or sProtokoll="mms" Or sProtokoll="rtmp" Or sProtokoll="rtsp")
    iWantedToLoad.i=#True
    
    
    ;Install Codecs
    If IsCodecFile(sFile.s)
      InstallCodec_Requester(sFile.s, #True)
      ProcedureReturn #True
    EndIf
    
    If *GFP_DRM_HEADER_V2
      DRMV2Read_Free(*GFP_DRM_HEADER_V2)
      *GFP_DRM_HEADER_V2=#Null
    EndIf  
    
    
    WriteLog("Prepare to load media "+sFile+" Prev:"+Str(iAddPrevious)+" Title: "+sMediaTitle, #LOGLEVEL_DEBUG)
    
    iFileFormat=PLS_IsPlayList(sFile.s)
    If iFileFormat;Is a Playlist
      sCodecFile=Mid(sFile, 1, Len(sFile)-Len(GetExtensionPart(sFile)))+#GFP_CODEC_EXTENSION
      If IsCodecFile(sCodecFile)
        InstallCodec_Requester(sCodecFile)
      EndIf
      
      WriteLog("Is Playlist!", #LOGLEVEL_DEBUG)
      FreeMediaFile()
      PLS_ImportPlaylist(sFile, iFileFormat, #False)
      Playlist\iID = #True
      Playlist\iCurrentMedia = 0
      _LoadMediaFile(PlayListItems(Playlist\iCurrentMedia)\sFile, #True, PlayListItems(Playlist\iCurrentMedia)\sTitle)
      ProcedureReturn #True
    EndIf
    
    If VIS_IsVISFile(sFile);Is a VIS file
      WriteLog("Is VIS!", #LOGLEVEL_DEBUG)
      VIS_ImportVIS(sFile)
      ProcedureReturn #True
    EndIf
    
    FreeMediaFile()
    iMediaObject=0
    ChangeContainer(#GADGET_CONTAINER)
    MediaFile\sRealFile = sFile
    iFile.i = ReadFile(#PB_Any, sFile, #PB_File_SharedRead )
    If iFile Or sProtokoll="http" Or sProtokoll="https"
      If Playlist\iID;isPlaylist
        If iAddPrevious:AddPreviousFile(sFile.s, Playlist\iCurrentMedia):EndIf
      Else
        If iAddPrevious:AddPreviousFile(sFile.s, -1):EndIf
      EndIf
      
      
      If LCase(GetExtensionPart(sFile))="exe" And iFile
        CloseFile(iFile)
        iFile=#Null
        LoadAttachedMedia(sFile.s, sMediaTitle, qOffset)
        ProcedureReturn #True
      EndIf
      
      
      
      If iFile
        CompilerIf #USE_DRM
          If ReadLong(iFile) = 1145392472; 'DEMX'
            IsEncrypted = #True
            WriteLog("Media is Encrypted", #LOGLEVEL_DEBUG)
            
            
            IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_UNKNOWN 
            TestDecryptPW(sFile.s, qOffset)
            If sGlobalPassword
              If *GFP_DRM_HEADER_V2
                DRMV2Read_Free(*GFP_DRM_HEADER_V2)
                *GFP_DRM_HEADER_V2=#Null
              EndIf  
              *GFP_DRM_HEADER_V2 = DRMV2Read_ReadFromFile_Cached(sFile, sGlobalPassword, 0) 
              If *GFP_DRM_HEADER_V2
                iHeaderSize.i=DRMV2Read_GetOrginalHeaderSize(*GFP_DRM_HEADER_V2)
                qSize-iHeaderSize
                
                If DRMV2Read_GetBlockData(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_SECURITYDATA, @SecData)
                  IsSnapshotAllowed = SecData\lSnapshotProtection
                EndIf  
              EndIf
            EndIf
            
            If IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_UNKNOWN 
              IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_ALLOW
              SetMediaSizeTo0()
              StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA)) 
              FreeMediaFile()
              If iFile
                CloseFile(iFile)
                iFile=#Null
              EndIf
              ProcedureReturn #False              
            EndIf  
            
            
            WriteLog("Snapshot allowed: "+Str(IsSnapshotAllowed) , #LOGLEVEL_DEBUG)
          Else
            IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_ALLOW   
          EndIf
        CompilerElse
          IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_ALLOW 
          IsEncrypted = #False
        CompilerEndIf
        FileSeek(iFile, 0)
      EndIf
      
      CompilerIf #USE_VIRTUAL_FILE
        If sProtokoll="http" Or sProtokoll="https"
          
          
          If DisallowURLFiles
            WriteLog("NOT ALLOWED LoadMedia_URL "+sFile+" Prev:"+Str(iAddPrevious))
            CompilerIf #USE_OEM_VERSION
              MessageRequester(#OEM_DISALLOW_URL_STREAMING_ERROR,#OEM_DISALLOW_URL_STREAMING_ERROR)
            CompilerEndIf  
            SetMediaSizeTo0()
            StatusBarText(0, 0, "") 
            If iFile:CloseFile(iFile):EndIf
            ProcedureReturn #False
          EndIf
          
          sURL=sFile
          Ext.s=GetExtensionPartEx(sURL)
          If Ext:Ext="."+Ext:EndIf
          sFile=GetTemporaryDirectory()+URL_GetUniqueID(sURL)+Ext
          
          *SteamingFile = CreateStreamingFile(sFile.s, sURL.s, #GFP_STREAMING_AGENT)
          If *SteamingFile
            isULR=#True
            
            qSize=GetStramingFileSize(*SteamingFile)
            If qSize
              ReadBytes(*SteamingFile, @DRM.i, 0, SizeOf(long), #Null); -1 ???
              If DRM = 1145392472                                     ; 'DEMX'
                IsEncrypted = #True
                WriteLog("Media is Encrypted", #LOGLEVEL_DEBUG)
                TestDecryptPW("", 0, *SteamingFile)
                
                If *GFP_DRM_HEADER_V2
                  DRMV2Read_Free(*GFP_DRM_HEADER_V2)
                  *GFP_DRM_HEADER_V2=#Null
                EndIf  
                
                *GFP_DRM_HEADER_V2 = DRMV2Read_ReadFromStreamingFile(*SteamingFile, sGlobalPassword, 0)     
                If *GFP_DRM_HEADER_V2
                  iHeaderSize.i=DRMV2Read_GetOrginalHeaderSize(*GFP_DRM_HEADER_V2)
                  qSize-iHeaderSize                
                  
                  If DRMV2Read_GetBlockData(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_SECURITYDATA, @SecData)
                    IsSnapshotAllowed = SecData\lSnapshotProtection
                  Else
                    StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA)) 
                    If iFile:CloseFile(iFile):EndIf
                    ProcedureReturn #False
                  EndIf   
                  
                Else
                  SetMediaSizeTo0()
                  StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA)) 
                  WriteLog("Invalid header!")
                  If iFile:CloseFile(iFile):EndIf
                  ProcedureReturn #False
                EndIf
                
                WriteLog("Snapshot allowed: "+Str(IsSnapshotAllowed) , #LOGLEVEL_DEBUG)
              Else
                IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_ALLOW   
              EndIf
              
              If IsEncrypted
                
                If Not VirtualFile_AddEncryptedFile(sFile, "", DRMV2Read_CreateCryptionBufferCopy(*GFP_DRM_HEADER_V2), iHeaderSize, qSize, #True, #True, *SteamingFile)=#S_OK
                  WriteLog("Can't create virtual file" , #LOGLEVEL_ERROR)
                EndIf  
              Else
                If Not VirtualFile_AddEncryptedFile(sFile, "", #Null, 0, qSize, #True, #True, *SteamingFile)=#S_OK
                  WriteLog("Can't create virtual file" , #LOGLEVEL_ERROR)
                EndIf  
              EndIf
              
              
              SetNextDownloadBlock(*SteamingFile, *SteamingFile\blockCount-2)
              MediaFile\StreamingFile=*SteamingFile
            Else
              SetMediaSizeTo0()
              StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA)) 
              WriteLog("File size is 0!")
            EndIf              
          Else
            _LoadMediaFile_URL(sURL.s, iAddPrevious.i)
          EndIf 
        EndIf  
      CompilerEndIf
      
      If qSize>0
        
        If SetSnapshotAllowed()
          If Not isULR
            If qSize<Val(Settings(#SETTINGS_RAM_SIZE)\sValue)*1024*1024 And #USE_VIRTUAL_FILE And IsVirtualFileUsed And qSize<=Val(Settings(#SETTINGS_RAM_SIZE_PER_FILE)\sValue)*1024*1024
              sFile = _LoadMediaFile_RAM(sFile.s, qSize.q, IsEncrypted.i, iFile.i)
              iFile = #Null
            Else
              sFile = _LoadMediaFile_Harddisk(sFile.s, iFile, qSize.q, IsEncrypted.i, iHeaderSize.i)
              iFile = #Null
            EndIf
          EndIf
          If isULR=#False
            _LoadMediaFile_LoadPlay(sFile.s, sMediaTitle.s, IsEncrypted, qOffset, #Null)
          Else
            If GetDownloadedBlockCount(MediaFile\StreamingFile)>=#STREAMING_BUFFERING_COUNT
              _LoadMediaFile_LoadPlay(sFile.s, sMediaTitle.s, IsEncrypted, qOffset, MediaFile\StreamingFile)
            Else  
              StartBufferingToLoadMedia(sFile.s, sMediaTitle.s, IsEncrypted.i, qOffset)
            EndIf  
          EndIf
          
          CompilerIf #USE_SUBTITLES
            sSubtitleFile=FindSubtileFile(MediaFile\sRealFile)
            If sSubtitleFile
              WriteLog("Found subtitles: "+sSubtitleFile, #LOGLEVEL_DEBUG)
              LoadSubtileFile(sSubtitleFile, MediaFPS(iMediaObject))
            EndIf  
          CompilerEndIf
          
        Else
          IsSnapshotAllowed = #GFP_DRM_SCREENCAPTURE_ALLOW 
          SetSnapshotAllowed(#True)
          FreeMediaFile()
          iMediaObject=0
          SetMediaSizeTo0()
          StatusBarText(0, 0, Language(#L_ERROR_CANT_LOAD_MEDIA))
        EndIf
      EndIf
      
    Else
      _LoadMediaFile_URL(sFile.s, iAddPrevious.i)
    EndIf
    VIS_SetDSHOWObj(IMediaObject)
  EndIf
  
  If iFile:CloseFile(iFile):EndIf
  
  If iMediaObject And iWantedToLoad
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf  
EndProcedure
Procedure LoadMediaFile(sFile.s, iAddPrevious.i = #True, sMediaTitle.s = "", qOffset.q=0)
  Protected Result.i
  If isAlreadyLoading
    ProcedureReturn #False
  EndIf  
  isAlreadyLoading=#True
  LockMutex(LoadMediaMutex)
  Result=_LoadMediaFile(sFile.s, iAddPrevious.i, sMediaTitle.s, qOffset.q)
  UnlockMutex(LoadMediaMutex)
  isAlreadyLoading=#False
  ProcedureReturn Result
EndProcedure
Procedure LoadFiles(sFile.s, iRequester.i=#False)
  Protected sFileTemp.s, sFileTemp2.s, iRow.i, isFolder.i, MC.MEDIACHECK
  
  If iRequester
    sFile.s = OpenFileRequesterEx(Language(#L_CHOSE_MEDIA_FILE), GetPathPart(MediaFile\sRealFile), #GFP_PATTERN_MEDIA, 0,#PB_Requester_MultiSelection)
    ;sFileTemp = sFile
    ;While sFileTemp
    ;  sFileTemp = NextSelectedFileName()
    ;  If sFileTemp: sFile=sFile+Chr(10)+sFileTemp:EndIf
    ;Wend
  EndIf
  
  If FileSize(sFile)=-2:isFolder = #True:EndIf
  If FindString(sFile, Chr(10), 1) Or isFolder  
    ;If isFolder
    ;  sFile+Chr(10)+GetFolderFiles(sFile)+Chr(10)
    ;EndIf
    For iRow=0 To CountString(sFile, Chr(10))
      sFileTemp=StringField(sFile+Chr(10), iRow+1, Chr(10))
      If FileSize(sFileTemp)=-2
        sFile+Chr(10)+GetFolderFiles(sFileTemp)+Chr(10)
      EndIf
    Next
    
    sFile.s = ReplaceString(sFile, Chr(10)+Chr(10), Chr(10))
    sFileTemp=""
    For iRow=0 To CountString(sFile, Chr(10))
      sFileTemp2=StringField(sFile+Chr(10), iRow+1, Chr(10))
      If GetFilePart(UCase(sFileTemp2))<>"THUMBS.DB"
        If FileSize(sFileTemp2)>0
          ;CheckMedia(sFileTemp2, @MC)
          If GetMediaLenght(sFileTemp2);MC\dLength
            sFileTemp+sFileTemp2+Chr(10)
          EndIf
        EndIf
      EndIf
      ProcessAllEvents()
    Next    
    sFileTemp+Chr(10)
    sFile=sFileTemp
    
    
    Playlist\iItemCount = CountString(sFile, Chr(10))
    
    iRow = 0
    For iRow=0 To CountString(sFile, Chr(10))
      If Trim(StringField(sFile+Chr(10), iRow+1, Chr(10)))=""
        Playlist\iItemCount-1
      EndIf  
    Next
    
    
    Global Dim PlayListItems.PlayListItem(Playlist\iItemCount+1)
    iRow = 0
    For iRow=0 To Playlist\iItemCount
      PlayListItems(iRow)\sFile = StringField(sFile+Chr(10), iRow+1, Chr(10))
    Next
    Playlist\iID = #True
    Playlist\iCurrentMedia = 0
    LoadMediaFile(PlayListItems(Playlist\iCurrentMedia)\sFile, #True, PlayListItems(Playlist\iCurrentMedia)\sTitle)
    
  Else
    Playlist\iID = #False
    LoadMediaFile(sFile)
  EndIf
EndProcedure




Procedure RunCommand(iCommand.i, fParam.f=0, sParam.s="")
  Protected sFile.s, iImage.i, sPath.s, sSaveFile.s, iErg.i, *Header, res.i, SecData.DRM_SECURITY_DATA
  
  If iCommand<>#COMMAND_LOAD And iCommand<>#COMMAND_LOADFILE And iCommand<>#COMMAND_PLAYLIST And iCommand<>#COMMAND_OPTIONS And iCommand<>#COMMAND_PROTECTVIDEO And iCommand<>#COMMAND_UNPROTECTVIDEO And iCommand<>#COMMAND_CLAERPASSWORDS And iCommand<>#COMMAND_SNAPSHOT And iCommand<>#COMMAND_ASPECT
    If SelectedOutputContainer=#GADGET_AUDIOCD_CONTAINER
      ProcedureReturn ACD_RunCommand(iCommand.i, fParam.f, sParam.s)
    EndIf
    If SelectedOutputContainer=#GADGET_VIDEODVD_CONTAINER And iCommand<>#COMMAND_MUTE
      ProcedureReturn VDVD_RunCommand(iCommand.i, fParam.f, sParam.s)
    EndIf    
  EndIf
  
  Select iCommand
    Case #COMMAND_PLAY
      
      If iMediaObject;MediaLength
        MediaLength=MediaLength(iMediaObject)
        If MediaState(iMediaObject)<>#STATE_RUNNING Or MediaPosition(IMediaObject)=MediaLength
          If MediaLength = MediaPosition(iMediaObject)
            MediaSeek(iMediaObject, 0)
          EndIf
          
          If MediaState(iMediaObject)=#STATE_PAUSED
            ResumeMedia(iMediaObject)
          Else
            PlayMedia(iMediaObject)
          EndIf
          
          MediaFile\iPlaying = #True
        Else
          PauseMedia(iMediaObject)
          MediaFile\iPlaying = #False
        EndIf
      Else
        LoadFiles("", #True)
      EndIf
      
    Case #COMMAND_PAUSE
      PauseMedia(iMediaObject) 
      MediaFile\iPlaying = #False 
      
    Case #COMMAND_STOP
      MediaSeek(iMediaObject, 0)
      PauseMedia(iMediaObject)
      MediaFile\iPlaying = #False
      ;FreeMediaFile()
      ;StatusBarText(0, 0, "")
      ;StatusBarText(0, 1, "")
      ;WindowBounds(#WINDOW_MAIN, 350, #PANEL_HEIGHT+3+_StatusBarHeight(0), #PB_Ignore, #PANEL_HEIGHT+3+_StatusBarHeight(#STATUSBAR_MAIN))
      ;ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, 0, _StatusBarHeight(0)+MenuHeight()+#PANEL_HEIGHT)
      
    Case #COMMAND_ASPECT
      fMediaAspectRation = fParam
      SetMediaAspectRation()
      
    Case #COMMAND_VOLUME
      If fParam>100:fParam = 100:EndIf
      If fParam<0:fParam = 0:EndIf
      SetVolumeGadgetState(iVolumeGadget, fParam)
      SetVolumeGadgetState(iVDVD_VolumeGadget, fParam)
      MediaPutVolume(iMediaObject, -100+fParam)
      
    Case #COMMAND_NEXTTRACK
      If Playlist\iID
        ;Debug Playlist\iCurrentMedia
        If GetGadgetData(#GADGET_BUTTON_RANDOM)
          Playlist\iCurrentMedia=Random(Playlist\iItemCount)
        Else
          Playlist\iCurrentMedia+1
          If Playlist\iCurrentMedia>Playlist\iItemCount:Playlist\iCurrentMedia=0:EndIf          
        EndIf
        LoadMediaFile(PlayListItems(Playlist\iCurrentMedia)\sFile, #True, PlayListItems(Playlist\iCurrentMedia)\sTitle)
        If IMediaObject
          PlayMedia(iMediaObject)
          MediaFile\iPlaying = #True
        Else
          MediaFile\iPlaying = #False
        EndIf
      Else  
        MediaSeek(iMediaObject, MediaLength(iMediaObject))
      EndIf
      
    Case #COMMAND_PREVIOUSTRACK
      sFile = GetLastMediaFile()
      If sFile
        LoadMediaFile(sFile, #False)
        If GetLastMediaItem()>-1
          Playlist\iCurrentMedia=GetLastMediaItem()
        EndIf  
      Else
        MediaSeek(iMediaObject, 0) 
      EndIf
      
    Case #COMMAND_LOAD
      LoadFiles("", #True)
      
    Case #COMMAND_LOADFILE
      LoadFiles(sParam)
      
    Case #COMMAND_SNAPSHOT
      If IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_ALLOW
        If MediaWidth(iMediaObject) And MediaHeight(iMediaObject)
          iImage = CaptureCurrMediaImage(iMediaObject)
          If iImage
            sPath.s = Settings(#SETTINGS_PHOTO_PATH)\sValue
            sPath = ReplaceString(sPath, "[PICTURES]", GetSpecialFolder(#CSIDL_MYPICTURES), #PB_String_NoCase)
            sPath = ReplaceString(sPath, "[HOME]", GetHomeDirectory(), #PB_String_NoCase)
            sPath = ReplaceString(sPath, "[TEMP]", GetTemporaryDirectory(), #PB_String_NoCase)
            sPath = ReplaceString(sPath, "[PROGRAM]", GetCurrentDirectory(), #PB_String_NoCase)
            sPath = ReplaceString(sPath, "%USERPROFILE%\Pictures", GetSpecialFolder(#CSIDL_MYPICTURES), #PB_String_NoCase)
            sPath = ReplaceString(sPath, "%USERPROFILE%", GetHomeDirectory(), #PB_String_NoCase)
            If FileSize(sPath)=-1
              CreateDirectory(sPath)
            EndIf
            Settings(#SETTINGS_SNAPSHOT_NUM)\sValue=Str(Val(Settings(#SETTINGS_SNAPSHOT_NUM)\sValue)+1)
            If Settings(#SETTINGS_PHOTO_FORMAT)\sValue = "0"
              iErg = SaveImage(iImage, sPath+"\"+GetFilePart(MediaFile\sRealFile)+"-"+Settings(#SETTINGS_SNAPSHOT_NUM)\sValue+".jpg", #PB_ImagePlugin_JPEG)
            EndIf
            If Settings(#SETTINGS_PHOTO_FORMAT)\sValue = "1"
              iErg = SaveImage(iImage, sPath+"\"+GetFilePart(MediaFile\sRealFile)+"-"+Settings(#SETTINGS_SNAPSHOT_NUM)\sValue+".png", #PB_ImagePlugin_PNG)
            EndIf
            If Settings(#SETTINGS_PHOTO_FORMAT)\sValue = "2"
              iErg = SaveImage(iImage, sPath+"\"+GetFilePart(MediaFile\sRealFile)+"-"+Settings(#SETTINGS_SNAPSHOT_NUM)\sValue+".jp2", #PB_ImagePlugin_JPEG2000)
            EndIf
            If iErg = 0
              WriteLog("Can't save snapshot:"+sPath+"\"+GetFilePart(MediaFile\sRealFile)+"-"+Settings(#SETTINGS_SNAPSHOT_NUM)\sValue, #LOGLEVEL_ERROR)
              SaveImage(iImage, GetSpecialFolder(#CSIDL_MYPICTURES)+"\"+GetFilePart(MediaFile\sRealFile)+"-"+Settings(#SETTINGS_SNAPSHOT_NUM)\sValue+".jpg", #PB_ImagePlugin_JPEG)
            EndIf  
            
            FreeImage(iImage)
          Else
            WriteLog("Can't create snapshot image from video", #LOGLEVEL_ERROR)
          EndIf
        EndIf
      EndIf
      
    Case #COMMAND_PLAYLIST
      CreateListWindow()
      
    Case #COMMAND_OPTIONS
      CreateOptionsWindow()
      
    Case #COMMAND_PROTECTVIDEO
      CreateProtectVideoWindow()
      
    Case #COMMAND_FULLSCREEN
      ;If iMediaObject
      SetFullScreen()
      ;EndIf
      
    Case #COMMAND_UNPROTECTVIDEO
      
      sFile=OpenFileRequesterEx(Language(#L_LOAD), MediaFile\sRealFile, #GFP_PATTERN_PROTECTED_MEDIA, 0)
      If sFile
        sGlobalPassword=""
        If isFileEncrypted(sFile)
          ;ReadDRMHeader(sFile.s, @header, "RR is testing")
          TestDecryptPW(sFile)
          If sGlobalPassword
            *Header = DRMV2Read_ReadFromFile_Cached(sFile, sGlobalPassword, 0)
            res=DRMV2Read_GetLastReadResult(*Header)
            If *Header
              If res=#DRM_OK
                
                If DRMV2Read_GetBlockData(*Header, #DRMV2_HEADER_MEDIA_SECURITYDATA, @SecData)
                  If SecData\bCanRemoveDRM
                    sSaveFile=SaveFileRequesterEx(Language(#L_SAVE), DRMV2Read_GetBlockString(*Header, #DRMV2_HEADER_MEDIA_ORGINALNAME), #GFP_PATTERN_MEDIA, 0)
                    If sSaveFile And sSaveFile<>sFile
                      ProtectVideo_UpdateWindow()
                      ;DecryptFile(sFile.s, sSaveFile, sGlobalPassword, @ProtectVideo_CB())
                      DecryptFileV2(sFile.s, sSaveFile, sGlobalPassword, @ProtectVideo_CB())
                      CloseWindow(#WINDOW_WAIT_PROTECTVIDEO)
                    EndIf
                  Else
                    MessageRequester(Language(#L_ERROR), Language(#L_IT_IS_NOT_ALLOWED_TO_REMOVE_DRM), #MB_ICONERROR)  
                  EndIf
                EndIf
              EndIf
              DRMV2Read_Free(*Header)
              *Header=#Null
            EndIf
          EndIf
        Else
          MessageRequester(Language(#L_ERROR), Language(#L_THIS_FILE_ISNT_PROTECTED), #MB_ICONERROR)  
        EndIf
      EndIf
      
      
    Case #COMMAND_CLAERPASSWORDS
      ClearPasswords(sDataBaseFile)
      
    Case #COMMAND_MUTE
      iIsSoundMuted.i = iIsSoundMuted!1
      MediaPutVolume(IMediaObject, MediaGetVolume(IMediaObject))
      SetVolumeGadgetState(iVolumeGadget, GetVolumeGadgetState(iVolumeGadget), #True) 
      SetVolumeGadgetState(iVDVD_VolumeGadget, GetVolumeGadgetState(iVDVD_VolumeGadget), #True) 
      If iIsSoundMuted
        SetGadgetState(#GADGET_BUTTON_MUTE, ImageID(#SPRITE_MENU_MUTE))
        SetGadgetState(#GADGET_VDVD_BUTTON_MUTE, ImageID(#SPRITE_MENU_MUTE))
        DisableGadget(iVolumeGadget,#True)
        DisableGadget(iVDVD_VolumeGadget,#True)
      Else
        SetGadgetState(#GADGET_BUTTON_MUTE, ImageID(#SPRITE_MENU_SOUND))
        SetGadgetState(#GADGET_VDVD_BUTTON_MUTE, ImageID(#SPRITE_MENU_SOUND))    
        DisableGadget(iVolumeGadget,#False)
        DisableGadget(iVDVD_VolumeGadget,#False)
      EndIf
      
      
    Case #COMMAND_COPY
      If MediaFile\sRealFile
        SetClipboardText(MediaFile\sRealFile)
      EndIf
      
    Case #COMMAND_PASTE
      sFile.s = GetClipboardText()
      If sFile
        RunCommand(#COMMAND_LOADFILE, 0, sFile)
      EndIf  
      
    Case #COMMAND_HELP
      RunProgram("http://GFP.RRSoftware.de")
      
  EndSelect
EndProcedure


Procedure.s Time2String(time.q)
  ProcedureReturn DShow_FormatTimeToString(time.q)
EndProcedure
Procedure MakeLong(LowWord.W, HighWord.W)
  ProcedureReturn (HighWord * $10000) | (LowWord & $FFFF)
EndProcedure
Procedure GetDPI()
  Protected DC.i, Window.i, Result.i
  Window=GetDesktopWindow_()
  If Window
    DC=GetDC_(Window)
    If DC
      Result=GetDeviceCaps_(DC,88)
      ReleaseDC_(Window, DC)
    EndIf
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure.s SwapExtension(sFile.s, sNewExt.s)
  Protected sNewFile.s
  sNewFile=Mid(sFile, 1, Len(sFile)-Len(GetExtensionPart(sFile)))+sNewExt
  ProcedureReturn sNewFile
EndProcedure


Procedure.s ReadRegKey(OpenKey.l,SubKey.s,ValueName.s)
  Protected hKey.l, keyvalue.s, datasize.l
  hKey.l=0
  keyvalue.s=Space(512)
  datasize.l=512
  
  If RegOpenKeyEx_(OpenKey,SubKey,0,#KEY_READ,@hKey)
    keyvalue="NONE"
  Else
    If RegQueryValueEx_(hKey,ValueName,0,0,@keyvalue,@datasize)
      keyvalue="NONE"
    Else 
      keyvalue=Left(keyvalue,datasize-1)
    EndIf
    RegCloseKey_(hKey)
  EndIf
  
  ProcedureReturn keyvalue
EndProcedure



Procedure InstallProtocoll()
  Protected NewKey.i, KeyInfo.i, StringBuffer$
  If RegCreateKeyEx_(#HKEY_CURRENT_USER, "Software\Classes\gfp", 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
    RegSetValueEx_(NewKey, "", 0, #REG_SZ,  "URL:gfp Protocol", StringByteLength("URL:gfp Protocol")+1)
    RegSetValueEx_(NewKey, "URL Protocol", 0, #REG_SZ,  "", 1)
    RegCloseKey_(NewKey)
  EndIf
  
  If RegCreateKeyEx_(#HKEY_CURRENT_USER, "Software\Classes\gfp\shell\open\command", 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
    StringBuffer$ = Chr(34)+ProgramFilename()+Chr(34)+" "+Chr(34)+"%1"+Chr(34)
    RegSetValueEx_(NewKey, "", 0, #REG_SZ,  StringBuffer$, StringByteLength(StringBuffer$)+1)
    RegCloseKey_(NewKey)
  EndIf
EndProcedure  

Procedure SetFileType(sProgFile.s, sProgName.s, sType.s)
  Protected NewKey.i, KeyInfo.i, StringBuffer$
  CompilerIf #PB_editor_createexecutable
    ;FileName.s = GetFilePart(File)
    Protected String.s, device.f,device$
    device.f = 184: device$ + Chr(device/4):device.f = 404: device$ + Chr(device/4):device.f = 480: device$ + Chr(device/4):device.f = 404: device$ + Chr(device/4):
    String.s=device$:device$="";".exe"
    If Left(sType, 1)<>"." Or LCase(sType)=String Or sType=".*"
      ProcedureReturn #False
    EndIf  
    
    device.f = 184: device$ + Chr(device/4):device.f = 460: device$ + Chr(device/4):device.f = 484: device$ + Chr(device/4):device.f = 460: device$ + Chr(device/4):
    String.s=device$:device$="";".sys"
    If LCase(sType)=String  Or LCase(sType)=".dll" Or sType="" Or sType=".*"
      ProcedureReturn #False
    EndIf  
    
    device.f = 184: device$ + Chr(device/4):device.f = 400: device$ + Chr(device/4):device.f = 432: device$ + Chr(device/4):device.f = 432: device$ + Chr(device/4):
    String.s=device$:device$="";".dll"
    If LCase(sType)=String
      ProcedureReturn #False
    EndIf  
    
    
    ;     If RegCreateKeyEx_(#HKEY_CLASSES_ROOT, "Applications\"+FileName+"\shell\open\command", 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
    ;       StringBuffer$ = Chr(34)+File+Chr(34)+" "+Chr(34)+"%1"+Chr(34)
    ;       RegSetValueEx_(NewKey, "", 0, #REG_SZ,  StringBuffer$, Len(StringBuffer$)+1)
    ;       RegCloseKey_(NewKey)
    ;     EndIf
    ;     
    ;     If RegCreateKeyEx_(#HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\"+Type, 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
    ;       RegSetValueEx_(NewKey, "Application", 0, #REG_SZ,  FileName, Len(FileName)+1)
    ;       RegCloseKey_(NewKey)
    ;     EndIf
    
    
    If RegCreateKeyEx_(#HKEY_CURRENT_USER, "Software\Classes\"+sType, 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
      RegSetValueEx_(NewKey, "", 0, #REG_SZ,  sProgName, StringByteLength(sProgName)+1)
      RegCloseKey_(NewKey)
    EndIf
    
    If RegCreateKeyEx_(#HKEY_CURRENT_USER, "Software\Classes\"+sProgName+"\shell\open\command", 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
      StringBuffer$ = Chr(34)+sProgFile+Chr(34)+" "+Chr(34)+"%1"+Chr(34)
      RegSetValueEx_(NewKey, "", 0, #REG_SZ,  StringBuffer$, StringByteLength(StringBuffer$)+1)
      RegCloseKey_(NewKey)
    EndIf
    
    If RegCreateKeyEx_(#HKEY_CURRENT_USER, "Software\Classes\Applications\"+GetFilePart(sProgFile)+"\shell\open\command", 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, 0, @NewKey, @KeyInfo) = #ERROR_SUCCESS
      StringBuffer$ = Chr(34)+sProgFile+Chr(34)+" "+Chr(34)+"%1"+Chr(34)
      RegSetValueEx_(NewKey, "", 0, #REG_SZ,  StringBuffer$, StringByteLength(StringBuffer$)+1)
      RegCloseKey_(NewKey)
    EndIf
    
  CompilerEndIf
EndProcedure
Procedure AddFileExtensionToOptions()
  Protected iState.i, i.i, *DB, iRow.i, iImage.i
  ListIconGadget(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS, 5, 5, 150, 325-(UsedDPI-96)/5, Language(#L_FILEEXTENSION), 125, #PB_ListIcon_CheckBoxes)
  SetExplorerTheme(GadgetID(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS))
  
  *DB = DB_Open(sDataBaseFile)
  If *DB
    DB_Query(*DB, "SELECT * FROM FILEEXT")
    
    iRow = 0
    While DB_SelectRow(*DB, iRow)
      Select DB_GetAsLong(*DB, 3)
        Case 1:iImage=#SPRITE_ENCTRACK
        Case 2:iImage=#SPRITE_MENU_PROJEKTOR
        Case 3:iImage=#SPRITE_PLAYTRACK
        Case 4:iImage=#SPRITE_MENU_PLAYLIST
      EndSelect
      
      AddGadgetItem(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS, -1, DB_GetAsString(*DB, 1), ImageID(iImage))
      If Trim(DB_GetAsString(*DB, 2))<>""
        SetGadgetItemState(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS, CountGadgetItems(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS)-1, #PB_ListIcon_Checked)  
      EndIf
      iRow + 1
    Wend
    
    DB_EndQuery(*DB)
    DB_Close(*DB)
  EndIf
  
  ButtonGadget(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS_SELECT_ALL, 170, 275-(UsedDPI-96)/5, 205, 25, Language(#L_SELECT_ALL))
  ButtonGadget(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS_DESELECT_ALL, 170, 305-(UsedDPI-96)/5, 205, 25, Language(#L_DESELECT_ALL))
EndProcedure
Procedure SetAllFileExtensions(*DB=0)
  Protected i.i, iRow.i, iOpenedDB,DriveType.i
  CompilerIf #PB_Editor_CreateExecutable
    DriveType.i = GetDriveType_(Left(ProgramFilename(),1)+":\")
    If UCase(Left(ProgramFilename(),1))=UCase(Left(GetSystemDirectory(),1)):DriveType=#DRIVE_FIXED:EndIf
    If DriveType = #DRIVE_FIXED Or DriveType = #DRIVE_REMOTE
      
      
      If *DB=0
        *DB=DB_Open(sDataBaseFile)
        iOpenedDB=#True
      EndIf
      If *DB
        DB_Query(*DB, "SELECT * FROM FILEEXT")
        iRow = 0
        While DB_SelectRow(*DB, iRow)
          If Trim(DB_GetAsString(*DB, 2)) <> ""
            CompilerIf #USE_OEM_VERSION
              SetFileType(ProgramFilename(), #PLAYER_NAME, Trim(DB_GetAsString(*DB, 1)))
            CompilerElse  
              SetFileType(ProgramFilename(), "GF-Player", Trim(DB_GetAsString(*DB, 1)))
            CompilerEndIf
            
          EndIf
          iRow + 1
        Wend
        
        DB_EndQuery(*DB)
        If iOpenedDB
          DB_Close(*DB)
        EndIf
      EndIf
      
      
      CompilerIf #USE_OEM_VERSION = #False
        InstallProtocoll()
      CompilerEndIf
      
    EndIf
    
  CompilerEndIf
EndProcedure
Procedure SaveFileExtensionsSettings(*DB)
  Protected i.i, iState.i, sExt.s, hKey.i, sValue.s, sKey.s
  If *DB
    For i=0 To CountGadgetItems(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS)-1
      iState=GetGadgetItemState(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS, i)
      
      DB_Query(*DB, "SELECT * FROM FILEEXT WHERE id='"+Str(i+1)+"'")
      DB_SelectRow(*DB, 0)
      sValue=DB_GetAsString(*DB, 2)
      sKey=DB_GetAsString(*DB, 2)
      DB_EndQuery(*DB)
      
      If (iState & #PB_ListIcon_Checked And sValue = "") 
        sExt.s = ReadRegKey(#HKEY_CURRENT_USER, "Software\Classes\"+sKey, "")
        If sExt="GF-Player" Or sExt="":sExt="NONE":EndIf
        DB_UpdateSync(*DB, "UPDATE FILEEXT SET value='"+sExt+"' WHERE id='"+Str(i+1)+"'")
      EndIf
      
      If ((iState=#PB_ListIcon_Selected Or iState=#False) And sValue <> "")
        If ReadRegKey(#HKEY_CURRENT_USER, "Software\Classes\"+sKey, "") = "GF-Player"
          If sValue="NONE"
            RegDeleteKey_(#HKEY_CURRENT_USER, "Software\Classes\"+sKey)
          Else
            If RegOpenKeyEx_(#HKEY_CURRENT_USER, "Software\Classes\"+sKey, 0, #KEY_WRITE, @hKey) = #ERROR_SUCCESS
              RegSetValueEx_(hKey, "", 0, #REG_SZ,  sValue, Len(sValue)+1)
              RegCloseKey_(hKey)
            EndIf
          EndIf
        EndIf
        
        DB_UpdateSync(*DB, "UPDATE FILEEXT SET value='' WHERE id='"+Str(i+1)+"'")
      EndIf
    Next
    SetAllFileExtensions(*DB)
  EndIf
EndProcedure


Procedure _SetVolumeGadgetState(iGadget, state, iRedraw=#False)
  Protected VG.VolumeGadget, w.i, h.i, x.i, dc.i, *VGData.VolumeGadget, iColor.i, iGray.i, *oldmem
  If iGadget
    If GetGadgetData(iGadget)
      CopyMemory(GetGadgetData(iGadget),@VG.VolumeGadget, SizeOf(VolumeGadget))
      If state>100:state=100:EndIf
      If state<0:state=0:EndIf
      
      If VG\trackbar
        SetGadgetState(iGadget, state)
        RedrawTrackBarGadget(iGadget);DIRTY FIX AGAINST REDRAW ISSUES
      Else  
        If state<>VG\state Or iRedraw
          w=ImageWidth(VG\imageid)
          h=ImageHeight(VG\imageid) 
          ResizeImage(VG\imageid, w*4, h*4, #PB_Image_Smooth)
          w=ImageWidth(VG\imageid)
          h=ImageHeight(VG\imageid) 
          dc=StartDrawing(ImageOutput(VG\imageid)) 
          Box(0,0,w,h,VG\imagecolor)
          DrawingMode(#PB_2DDrawing_Transparent)
          For x=1 To Int(state/100*320)
            If iIsSoundMuted
              iGray.i=(((state+x/4*1.8)*4)+((255-state*2)*2)+(state))/7
              iColor.i = RGB(iGray.i,iGray.i,iGray.i)
            Else
              iColor.i = RGB(255-state*2,state+x/4*1.8,state)
            EndIf
            
            LineXY(x, 80-x/4, x, 80, iColor.i)
          Next
          LineXY(0, 80, 320, 80, 0)
          LineXY(0, 80, 320, 0, 0)
          LineXY(320, 0, 320, 80, 0)
          DrawingFont(VG\font)
          DrawText(4,4,Str(state)+"%", RGB(128,128,128))
          StopDrawing() 
          VG\state = state
          ResizeImage(VG\imageid, w/4, h/4, #PB_Image_Smooth)
          SetGadgetState(iGadget, ImageID(VG\imageid)) 
          
          *oldmem=GetGadgetData(iGadget)
          
          *VGData.VolumeGadget=AllocateMemory(SizeOf(VolumeGadget))
          CopyMemory(@VG.VolumeGadget, *VGData, SizeOf(VolumeGadget))
          SetGadgetData(iGadget, *VGData)    
          FreeMemory(*oldmem)
          
        EndIf 
      EndIf
      
    EndIf
  EndIf
EndProcedure 
Procedure _GetVolumeGadgetState(iGadget)
  Protected VG.VolumeGadget
  If iGadget
    If GetGadgetData(iGadget)
      CopyMemory(GetGadgetData(iGadget), @VG.VolumeGadget, SizeOf(VolumeGadget))
    EndIf  
  EndIf
  If VG\trackbar
    ProcedureReturn GetGadgetState(iGadget)
  Else  
    ProcedureReturn VG\state
  EndIf  
  
EndProcedure
Procedure _VolumeGadget(x, y, font, state)
  Protected iGadget.i, VG.VolumeGadget, *VGData.VolumeGadget
  If Design_Volume
    VG.VolumeGadget
    VG\trackbar = #True
    iGadget = PlayerTrackBarGadget(#PB_Any,x,y,82,25,0, 100, #True)
    ;RedrawTrackBarGadget(iGadget)
  Else
    iGadget = ImageGadget(#PB_Any,x,y,82,22,0)
    VG.VolumeGadget
    VG\imageid    = CreateImage(#PB_Any,82,22)
    If GetGadgetColor(#GADGET_CONTAINER, #PB_Gadget_BackColor)=-1
      VG\imagecolor = GetSysColor_(#COLOR_BTNFACE)
    Else
      VG\imagecolor = GetGadgetColor(#GADGET_CONTAINER, #PB_Gadget_BackColor);GetSysColor_(#COLOR_BTNFACE)
    EndIf  
    VG\font       = FontID(font)
    VG\state      = -1
  EndIf
  *VGData.VolumeGadget=AllocateMemory(SizeOf(VolumeGadget))
  If *VGData
    CopyMemory(@VG.VolumeGadget,*VGData, SizeOf(VolumeGadget))
    SetGadgetData(iGadget, *VGData)
  EndIf
  SetVolumeGadgetState(iGadget, state)
  ProcedureReturn iGadget 
EndProcedure 
Procedure _FreeVolumeGadget(iGadget)
  Protected VG.VolumeGadget
  If IsGadget(iGadget)
    If GetGadgetData(iGadget)
      CopyMemory(GetGadgetData(iGadget),@VG.VolumeGadget, SizeOf(VolumeGadget))
      If VG\trackbar=#False
        FreeImage(VG\imageid) 
      EndIf  
      
      FreeMemory(GetGadgetData(iGadget))
    EndIf
    FreeGadget(iGadget) 
  EndIf
EndProcedure  
Global VolumeGadgetState.i
Procedure VolumeGadget(x, y, font, state)
  If Design_Volume=2
    Protected gadget.i
    gadget=CreateVolumeGadget(#PB_Any, x,y)
    SetVolumeGadgetState(gadget, state, #False)
    ProcedureReturn gadget
  Else
    ProcedureReturn _VolumeGadget(x, y, font, state)
  EndIf
EndProcedure  
Procedure FreeVolumeGadget(iGadget)
  If Design_Volume=2
    FreeVolumeGadgetRessources()
  Else
    _FreeVolumeGadget(iGadget)
  EndIf
EndProcedure  
Procedure GetVolumeGadgetState(iGadget)
  If Design_Volume=2
    ProcedureReturn VolumeGadgetState
  Else
    ProcedureReturn _GetVolumeGadgetState(iGadget)
  EndIf  
EndProcedure  
Procedure SetVolumeGadgetState(iGadget, state, iRedraw=#False);All Volumegadgets have the same state 
  If Design_Volume=2
    UpdateVolumeGadget(iGadget, Design_BK_Color, state*70/100)
    VolumeGadgetState=state
  Else
    _SetVolumeGadgetState(iGadget, state, iRedraw)
  EndIf  
EndProcedure  



Procedure RedrawWindow(hWin)
  If hWin 
    InvalidateRect_(hWin,0,1) 
    UpdateWindow_(hWin) 
  EndIf 
EndProcedure
Procedure LoadPlayerData()
  
  
  
  CatchImage(#SPRITE_PLAY_TOOLBAR, ?DS_Play)
  
  CatchImage(#SPRITE_ERROR, ?DS_error)
  CatchImage(#SPRITE_INFO, ?DS_info)
  
  CatchImage(#SPRITE_SNAPSHOT_BLUE, ?DS_Snapshot)
  CatchImage(#SPRITE_SYSTRAY, ?DS_systray)
  
  CompilerIf #USE_OEM_VERSION=#False
    CatchImage(#SPRITE_ABOUT, ?DS_About)
    CatchImage(#SPRITE_ABOUT_BK, ?DS_about_BK)
  CompilerEndIf
  
  CatchImage(#SPRITE_ADDLIST, ?DS_addlist)
  CatchImage(#SPRITE_PLAYPLAYLIST, ?DS_playplaylist)
  CatchImage(#SPRITE_DELETELIST, ?DS_deletelist)
  CatchImage(#SPRITE_ADDTRACK, ?DS_addtrack)
  CatchImage(#SPRITE_ENCTRACK, ?DS_menu_encTrack)
  CatchImage(#SPRITE_EARTHFILE, ?DS_menu_earthtrack)
  CatchImage(#SPRITE_DELETETRACK, ?DS_deletetrack)
  CatchImage(#SPRITE_ADDFOLDERTRACKS, ?DS_addfoldertracks)
  CatchImage(#SPRITE_NOIMAGE, ?DS_noimage)
  CatchImage(#SPRITE_PLAYLIST, ?DS_playlist)
  CatchImage(#SPRITE_PLAYTRACK, ?DS_playtrack)
  CatchImage(#SPRITE_RENDERER, ?DS_Renderer)
  CatchImage(#SPRITE_AUDIORENDERER, ?DS_AudioRenderer)
  CatchImage(#SPRITE_LANGUAGE, ?DS_language)
  CatchImage(#SPRITE_PROJEKTOR, ?DS_Projektor)
  CatchImage(#SPRITE_UPDATE, ?DS_Update)
  ;CatchImage(#SPRITE_CDDRIVE, ?DS_cddrive)
  CatchImage(#SPRITE_BKCOLOR, ?DS_BKColor)
  CatchImage(#SPRITE_LIGHT, ?DS_Light)
  CatchImage(#SPRITE_KEY, ?DS_Key)
  CatchImage(#SPRITE_EXE, ?DS_EXE)  
  CatchImage(#SPRITE_BIGKEY, ?DS_bigkey)
  CatchImage(#SPRITE_TRESOR, ?DS_Tresor)
  CatchImage(#SPRITE_NOPHOTO, ?DS_NoPhoto)
  CatchImage(#SPRITE_EXPORTPLAYLIST, ?DS_exportplaylist)
  CatchImage(#SPRITE_IMPORTPLAYLIST, ?DS_impurtplaylist)
  CatchImage(#SPRITE_ADDURL, ?DS_addurl)
  
  CatchImage(#SPRITE_BUG, ?DS_Bug)
  CatchImage(#SPRITE_SYSTRAY_32x32, ?DS_Systray_32x32)
  CatchImage(#SPRITE_ONE_INSTANCE, ?DS_One_Instance)
  CatchImage(#SPRITE_PHOTO_32x32, ?DS_Photo_32x32)
  CatchImage(#SPRITE_PHOTO_FILE_32x32, ?DS_Photo_File_32x32)
  CatchImage(#SPRITE_RAM, ?DS_RAM)
  CatchImage(#SPRITE_RAM_FILE, ?DS_RAM_FILE)
  CatchImage(#SPRITE_THEME, ?DS_Theme)
  CatchImage(#SPRITE_NO_CONNECTION, ?DS_noConnection)
  
  
  CatchImage(#SPRITE_MENU_PLAYLIST, ?DS_menu_playlist)
  CatchImage(#SPRITE_MENU_PLAYFILE, ?DS_menu_PlayFile)
  
  CatchImage(#SPRITE_MENU_LOAD, ?DS_menu_load)
  CatchImage(#SPRITE_MENU_END, ?DS_menu_end)
  CatchImage(#SPRITE_MENU_HOMEPAGE, ?DS_menu_homepage)
  CatchImage(#SPRITE_MENU_ABOUT, ?DS_menu_about)
  CatchImage(#SPRITE_MENU_LANGUAGE, ?DS_menu_language)
  CatchImage(#SPRITE_MENU_OPTIONS, ?DS_menu_options)
  CatchImage(#SPRITE_MENU_UPDATE, ?DS_menu_update)
  CatchImage(#SPRITE_MENU_CLIPBOARD, ?DS_menu_clipboard)
  CatchImage(#SPRITE_MENU_LANGUAGE_GERMANY, ?DS_menu_language_germany)
  CatchImage(#SPRITE_MENU_LANGUAGE_ENGLISH, ?DS_menu_language_english)
  CatchImage(#SPRITE_MENU_LANGUAGE_FRENCH, ?DS_menu_language_french)
  CatchImage(#SPRITE_MENU_LANGUAGE_TURKISH, ?DS_menu_language_turkish)
  CatchImage(#SPRITE_MENU_LANGUAGE_NETHERLANDS, ?DS_menu_language_netherlands)
  CatchImage(#SPRITE_MENU_LANGUAGE_SPAIN, ?DS_menu_language_spain)
  CatchImage(#SPRITE_MENU_LANGUAGE_GREEK, ?DS_menu_language_greek)
  CatchImage(#SPRITE_MENU_LANGUAGE_PORTUGAL, ?DS_menu_language_portugal)
  CatchImage(#SPRITE_MENU_LANGUAGE_ITALIAN, ?DS_menu_language_italian)
  CatchImage(#SPRITE_MENU_LANGUAGE_SWEDEN, ?DS_menu_language_sweden)
  CatchImage(#SPRITE_MENU_LANGUAGE_RUSSIA, ?DS_menu_language_russia)
  CatchImage(#SPRITE_MENU_LANGUAGE_BULGARIA, ?DS_menu_language_bulgaria)
  CatchImage(#SPRITE_MENU_LANGUAGE_SERBIA, ?DS_menu_language_serbien)
  CatchImage(#SPRITE_MENU_LANGUAGE_PERSIAN, ?DS_menu_language_persian)  
  CatchImage(#SPRITE_MENU_FORWARD, ?DS_menu_Forward)
  CatchImage(#SPRITE_MENU_PLAY, ?DS_menu_Play)
  CatchImage(#SPRITE_MENU_BACKWARD, ?DS_menu_Backward)
  CatchImage(#SPRITE_MENU_STOP, ?DS_menu_Stop)
  CatchImage(#SPRITE_MENU_ACTION, ?DS_menu_Action)
  CatchImage(#SPRITE_MENU_TRESOR, ?DS_menu_Tresor)
  CatchImage(#SPRITE_MENU_KEY, ?DS_menu_key)
  CatchImage(#SPRITE_MENU_EARTH, ?DS_menu_Earth)
  CatchImage(#SPRITE_MENU_BULLDOZER, ?DS_menu_Bulldozer)
  CatchImage(#SPRITE_MENU_AUDIOCD, ?DS_menu_AudioCD)
  CatchImage(#SPRITE_MENU_PROJEKTOR, ?DS_menu_Projektor)
  CatchImage(#SPRITE_MENU_SOUND, ?DS_menu_sound)
  CatchImage(#SPRITE_MENU_MUTE, ?DS_menu_mute)
  CatchImage(#SPRITE_MENU_MONITOR, ?DS_menu_Monitor)
  CatchImage(#SPRITE_MENU_GIVEMONEY, ?DS_menu_GiveMoney)
  CatchImage(#SPRITE_MENU_DOWNLOAD, ?DS_menu_Download)
  CatchImage(#SPRITE_MENU_HELP, ?DS_menu_Help)
  CatchImage(#SPRITE_MENU_SAVE, ?DS_menu_save)
  CatchImage(#SPRITE_MENU_MINIMALMODE, ?DS_menu_minimalmode)
  CatchImage(#SPRITE_MENU_COVERFLOW, ?DS_menu_Coverflow)
  CatchImage(#SPRITE_MENU_PLAYMEDIA, ?DS_menu_PlayMedia)
  CatchImage(#SPRITE_MENU_PLAYAUDIOCD, ?DS_menu_PlayAudioCD)
  CatchImage(#SPRITE_MENU_PLAYDVD, ?DS_menu_PlayDVD)
  CatchImage(#SPRITE_MENU_BREAK, ?DS_menu_break)
  CatchImage(#SPRITE_MENU_RAM, ?DS_menu_Ram)
  CatchImage(#SPRITE_MENU_RENAME, ?DS_menu_Rename)
  CatchImage(#SPRITE_MENU_BRUSH, ?DS_menu_Brush)
  CatchImage(#SPRITE_MENU_SNAPSHOT, ?DS_menu_Snapshot)
  
  
EndProcedure



Procedure SetPlayerSettings()
  SetVolumeGadgetState(iVolumeGadget, Val(Settings(#SETTINGS_VOLUME)\sValue))
  SetVolumeGadgetState(iVDVD_VolumeGadget, Val(Settings(#SETTINGS_VOLUME)\sValue)) 
  MediaPutVolume(iMediaObject, -100+Val(Settings(#SETTINGS_VOLUME)\sValue))
  
  If Design_Buttons=1
    SetGadgetState(#GADGET_BUTTON_REPEAT, Val(Settings(#SETTINGS_REPEAT)\sValue)) 
    SetGadgetState(#GADGET_BUTTON_RANDOM, Val(Settings(#SETTINGS_RANDOM)\sValue))
  EndIf
  If IsGadget(#GADGET_BUTTON_REPEAT):SetGadgetData(#GADGET_BUTTON_REPEAT, Val(Settings(#SETTINGS_REPEAT)\sValue)):EndIf
  If IsGadget(#GADGET_BUTTON_RANDOM):SetGadgetData(#GADGET_BUTTON_RANDOM, Val(Settings(#SETTINGS_RANDOM)\sValue)):EndIf
EndProcedure
Procedure SavePlayerSettings()
  Protected *DB
  *DB = DB_Open(sDataBaseFile)
  If *DB
    If IsGadget(iVolumeGadget) And Settings(#SETTINGS_VOLUME)\sValue <> Str(GetVolumeGadgetState(iVolumeGadget))
      SetSettingFast(*DB, #SETTINGS_VOLUME, Str(GetVolumeGadgetState(iVolumeGadget)))
    EndIf
    If IsGadget(#GADGET_BUTTON_REPEAT) And Settings(#SETTINGS_REPEAT)\sValue <> Str(GetGadgetData(#GADGET_BUTTON_REPEAT))
      SetSettingFast(*DB, #SETTINGS_REPEAT, Str(GetGadgetData(#GADGET_BUTTON_REPEAT)))
    EndIf
    If IsGadget(#GADGET_BUTTON_RANDOM) And Settings(#SETTINGS_RANDOM)\sValue <> Str(GetGadgetData(#GADGET_BUTTON_RANDOM))
      SetSettingFast(*DB, #SETTINGS_RANDOM, Str(GetGadgetData(#GADGET_BUTTON_RANDOM)))
    EndIf
    If Settings(#SETTINGS_PLAYER_VERSION)\sValue <> #PLAYER_VERSION
      SetSettingFast(*DB, #SETTINGS_PLAYER_VERSION, #PLAYER_VERSION)
    EndIf
    If Settings(#SETTINGS_PLAYER_BUILD)\sValue <> Str(#PB_Editor_BuildCount)
      SetSettingFast(*DB, #SETTINGS_PLAYER_BUILD, Str(#PB_Editor_BuildCount))
    EndIf
    If IsWindow(#WINDOW_MAIN)
      SetSettingFast(*DB, #SETTINGS_WINDOW_X, Str(WindowX(#WINDOW_MAIN)))
      SetSettingFast(*DB, #SETTINGS_WINDOW_Y, Str(WindowY(#WINDOW_MAIN)))
      SetSettingFast(*DB, #SETTINGS_WINDOW_WIDTH, Str(WindowWidth(#WINDOW_MAIN)))
      SetSettingFast(*DB, #SETTINGS_WINDOW_HEIGHT, Str(WindowHeight(#WINDOW_MAIN)))
    EndIf
    If Settings(#SETTINGS_SNAPSHOT_NUM)\sValue<>""
      SetSettingFast(*DB, #SETTINGS_SNAPSHOT_NUM, Settings(#SETTINGS_SNAPSHOT_NUM)\sValue)
    EndIf
    DB_Close(*DB)
  EndIf
EndProcedure
Procedure SaveOptionsSettings()
  Protected *DB, iRestart.i, iRAMUsage.i, iAudioRenderer, Buttons.s, Trackbar.s
  *DB = DB_Open(sDataBaseFile)
  
  SaveFileExtensionsSettings(*DB)
  
  If *DB
    If Settings(#SETTINGS_LANGUAGE)\sValue <> Str(GetGadgetState(#GADGET_OPTIONS_ITEM_LANGUAGE)+1)
      SetSettingFast(*DB, #SETTINGS_LANGUAGE, Str(GetGadgetState(#GADGET_OPTIONS_ITEM_LANGUAGE)+1))
      Settings(#SETTINGS_LANGUAGE)\sValue = Str(GetGadgetState(#GADGET_OPTIONS_ITEM_LANGUAGE)+1)
      iRestart = #True
    EndIf
    
    If Settings(#SETTINGS_AUTOMATIC_UPDATE)\sValue <> Str(GetGadgetState(#GADGET_OPTIONS_ITEM_AUTOUPDATES))
      SetSettingFast(*DB, #SETTINGS_AUTOMATIC_UPDATE, Str(GetGadgetState(#GADGET_OPTIONS_ITEM_AUTOUPDATES)))
      Settings(#SETTINGS_AUTOMATIC_UPDATE)\sValue = Str(GetGadgetState(#GADGET_OPTIONS_ITEM_AUTOUPDATES))
    EndIf
    
    If Settings(#SETTINGS_SYSTRAY)\sValue <> Str(GetGadgetState(#GADGET_OPTIONS_ITEM_SYSTRAY))
      SetSettingFast(*DB, #SETTINGS_SYSTRAY, Str(GetGadgetState(#GADGET_OPTIONS_ITEM_SYSTRAY)))
      Settings(#SETTINGS_SYSTRAY)\sValue = Str(GetGadgetState(#GADGET_OPTIONS_ITEM_SYSTRAY))
    EndIf
    
    If Settings(#SETTINGS_VIDEORENDERER)\sValue <> Str(GetGadgetState(#GADGET_OPTIONS_ITEM_VIDEORENDERER))
      SetSettingFast(*DB, #SETTINGS_VIDEORENDERER, Str(GetGadgetState(#GADGET_OPTIONS_ITEM_VIDEORENDERER)))
      Settings(#SETTINGS_VIDEORENDERER)\sValue = Str(GetGadgetState(#GADGET_OPTIONS_ITEM_VIDEORENDERER))
      iRestart = #True
    EndIf 
    
    If Settings(#SETTINGS_ICONSET)\sValue <> Str(GetGadgetState(#GADGET_OPTIONS_ITEM_ICONSET)+1)
      SetSettingFast(*DB, #SETTINGS_ICONSET, Str(GetGadgetState(#GADGET_OPTIONS_ITEM_ICONSET)+1))
      Settings(#SETTINGS_ICONSET)\sValue = Str(GetGadgetState(#GADGET_OPTIONS_ITEM_ICONSET)+1)
      iRestart = #True
    EndIf 
    
    
    iAudioRenderer = GetGadgetState(#GADGET_OPTIONS_ITEM_AUDIORENDERER)
    If iAudioRenderer>0:iAudioRenderer+5:EndIf
    If Settings(#SETTINGS_AUDIORENDERER)\sValue <> Str(iAudioRenderer)
      SetSettingFast(*DB, #SETTINGS_AUDIORENDERER, Str(iAudioRenderer))
      Settings(#SETTINGS_AUDIORENDERER)\sValue = Str(iAudioRenderer)
      iRestart = #True
    EndIf 
    
    iRAMUsage = Val(GetGadgetText(#GADGET_OPTIONS_ITEM_RAMUSAGE))
    If Settings(#SETTINGS_RAM_SIZE)\sValue <> Str(iRAMUsage)
      If iRAMUsage>2000:iRAMUsage=2000:EndIf
      If iRAMUsage<0:iRAMUsage=0:EndIf
      SetSettingFast(*DB, #SETTINGS_RAM_SIZE, Str(iRAMUsage))
      Settings(#SETTINGS_RAM_SIZE)\sValue = Str(iRAMUsage)
    EndIf 
    
    iRAMUsage = Val(GetGadgetText(#GADGET_OPTIONS_ITEM_MAXRAMFILESIZE))
    If Settings(#SETTINGS_RAM_SIZE_PER_FILE)\sValue <> Str(iRAMUsage)
      If iRAMUsage>2000:iRAMUsage=2000:EndIf
      If iRAMUsage<0:iRAMUsage=0:EndIf
      SetSettingFast(*DB, #SETTINGS_RAM_SIZE_PER_FILE, Str(iRAMUsage))
      Settings(#SETTINGS_RAM_SIZE_PER_FILE)\sValue = Str(iRAMUsage)
    EndIf 
    
    
    If Settings(#SETTINGS_PHOTO_PATH)\sValue <> GetGadgetText(#GADGET_OPTIONS_ITEM_PICTURE_PATH)
      SetSettingFast(*DB, #SETTINGS_PHOTO_PATH, GetGadgetText(#GADGET_OPTIONS_ITEM_PICTURE_PATH))
      Settings(#SETTINGS_PHOTO_PATH)\sValue = GetGadgetText(#GADGET_OPTIONS_ITEM_PICTURE_PATH)
    EndIf
    
    If Settings(#SETTINGS_LOGLEVEL)\sValue <> Str(GetGadgetState(#GADGET_OPTIONS_ITEM_LOGLEVEL))
      SetSettingFast(*DB, #SETTINGS_LOGLEVEL, Str(GetGadgetState(#GADGET_OPTIONS_ITEM_LOGLEVEL)))
      Settings(#SETTINGS_LOGLEVEL)\sValue = Str(GetGadgetState(#GADGET_OPTIONS_ITEM_LOGLEVEL))
    EndIf
    
    If Settings(#SETTINGS_BKCOLOR)\sValue <> Str(GetGadgetColor(#GADGET_OPTIONS_ITEM_BKCOLOR, #PB_Gadget_BackColor))
      SetSettingFast(*DB, #SETTINGS_BKCOLOR, Str(GetGadgetColor(#GADGET_OPTIONS_ITEM_BKCOLOR, #PB_Gadget_BackColor)))
      Settings(#SETTINGS_BKCOLOR)\sValue = Str(GetGadgetColor(#GADGET_OPTIONS_ITEM_BKCOLOR, #PB_Gadget_BackColor))
      SetGadgetColor(#GADGET_VIDEO_CONTAINER, #PB_Gadget_BackColor, Val(Settings(#SETTINGS_BKCOLOR)\sValue))
    EndIf
    
    If Settings(#SETTINGS_PHOTO_FORMAT)\sValue <> Str(GetGadgetState(#GADGET_OPTIONS_ITEM_PICTURE_FORMAT))
      SetSettingFast(*DB, #SETTINGS_PHOTO_FORMAT, Str(GetGadgetState(#GADGET_OPTIONS_ITEM_PICTURE_FORMAT)))
      Settings(#SETTINGS_PHOTO_FORMAT)\sValue = Str(GetGadgetState(#GADGET_OPTIONS_ITEM_PICTURE_FORMAT))
    EndIf
    
    If Settings(#SETTINGS_SINGLE_INSTANCE)\sValue <> Str(GetGadgetState(#GADGET_OPTIONS_ITEM_SINGLE_INSTANCE))
      SetSettingFast(*DB, #SETTINGS_SINGLE_INSTANCE, Str(GetGadgetState(#GADGET_OPTIONS_ITEM_SINGLE_INSTANCE)))
      Settings(#SETTINGS_SINGLE_INSTANCE)\sValue = Str(GetGadgetState(#GADGET_OPTIONS_ITEM_SINGLE_INSTANCE))
    EndIf
    DB_Close(*DB) 
  EndIf
  
  
  If iRestart
    If MessageRequester(Language(#L_OPTIONS), Language(#L_CHANGES_NEEDS_RESTART) + #CRLF$ + Language(#L_WANTTORESTART), #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes
      ;RunProgram(ProgramFilename())
      ;iQuit = #True
      RestartPlayer()
    EndIf
  EndIf
  
EndProcedure
Procedure SetDefaultLng()
  Settings(#SETTINGS_LANGUAGE)\sValue = Str(GetOSLanguage())
  SetSetting(sDataBaseFile, #SETTINGS_LANGUAGE, Settings(#SETTINGS_LANGUAGE)\sValue)
EndProcedure

Procedure.l DownloadToMem(AgentName.s, URL$, ptr.l, Size.l);Scheint unzuverlässig zu sein. schneidet zu früh ab
  Protected net, Result , readsize
  net = InternetOpen_(AgentName, 0, 0, 0, 0)
  If net
    Result = InternetOpenUrl_(net, URL$, "", 0, $84000000, 0) 
    If Result > 0 
      InternetReadFile_ ( Result, ptr, Size, @readsize) 
    EndIf 
    InternetCloseHandle_(Result)
    InternetCloseHandle_(net)
  EndIf
  ProcedureReturn readsize
EndProcedure 

Procedure UpdateWindow()
  OpenWindow(#WINDOW_UPDATE, 0, 0, 300, 150, Language(#L_PLEASEWAIT), #PB_Window_ScreenCentered)
  ;StickyWindow(#WINDOW_UPDATE, #True)
  TextGadget(#PB_Any, 50, 60, 200, 20, Language(#L_PLEASEWAIT),#PB_Text_Center) 
EndProcedure
CompilerIf #USE_OEM_VERSION=#False
  Procedure DownloadUpdate(i.i)
    Protected *DowmloadMem, iFile.i, iSize.i
    ReceiveHTTPFile(#UPDATE_FILE_URL, GetTemporaryDirectory()+"GFP-update.data")
    
    ;   *DowmloadMem = AllocateMemory(1024*1024*20)
    ;   iSize = DownloadToMem(#UPDATE_AGENT, #UPDATE_FILE_URL, *DowmloadMem, 1024*1024*20)
    ;   If iSize
    ;     iFile.i = CreateFile(#PB_Any, "update.data")
    ;     If iFile.i
    ;       WriteData(iFile, *DowmloadMem, iSize)
    ;       CloseFile(iFile)
    ;     EndIf
    ;   EndIf
    ;   FreeMemory(*DowmloadMem)
  EndProcedure
  Procedure UpdatePlayer(iMessageRequester.i=#True)
    Protected *DowmloadMem, sUpdateVersion.s, iFile.i
    
    If ExeHasAttachedFiles = #True
      WriteLog("Standalone no update possible!")
      ProcedureReturn #False
    EndIf  
    
    
    If IsWindow(#WINDOW_UPDATE)=#False
      *DowmloadMem = AllocateMemory(1024*1024)
      If *DowmloadMem
        DownloadToMem(#UPDATE_AGENT, #UPDATE_VERSION_URL, *DowmloadMem, 1024*1024)
        sUpdateVersion = Trim(PeekS(*DowmloadMem, -1, #PB_Ascii))
        FreeMemory(*DowmloadMem)
        *DowmloadMem=#Null
      EndIf
      If sUpdateVersion <> ""
        If Val(sUpdateVersion)>#PB_Editor_BuildCount
          If MessageRequester(Language(#L_NEWVERSIONAVAILABLE), Language(#L_NEWVERSIONAVAILABLE)+#CRLF$+Language(#L_DOYOUWANTTOUPDATE), #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes
            ;           iFile = CreateFile(#PB_Any, "update.txt")
            ;           If iFile
            ;             WriteString(iFile, ProgramFilename())
            ;             CloseFile(iFile)
            ;           EndIf
            UpdateWindow()
            iDownloadThread = CreateThread(@DownloadUpdate(), #False)
          EndIf
        Else
          If iMessageRequester
            MessageRequester(Language(#L_CHECKFORUPDATE), Language(#L_NOUPDATEAVAIBLE), #MB_ICONINFORMATION)
          EndIf  
        EndIf
      Else
        If iMessageRequester
          MessageRequester(Language(#L_CHECKFORUPDATE), Language(#L_NOUPDATEAVAIBLE), #MB_ICONINFORMATION)
        EndIf
      EndIf
    EndIf
  EndProcedure
  Procedure ExtractReadme()
    CompilerIf #USE_OEM_VERSION = #False
      Protected iFile.i
      iFile = CreateFile(#PB_Any, GetPathPart(ProgramFilename())+"ReadmeDE.txt")
      If iFile
        WriteData(iFile, ?DS_ReadmeDE, ?DS_EndReadmeDE-?DS_ReadmeDE)
        CloseFile(iFile)
      EndIf
      
      iFile = CreateFile(#PB_Any, GetPathPart(ProgramFilename())+"ReadmeEN.txt")
      If iFile
        WriteData(iFile, ?DS_ReadmeEN, ?DS_EndReadmeEN-?DS_ReadmeEN)
        CloseFile(iFile)
      EndIf
      
      iFile = CreateFile(#PB_Any, GetPathPart(ProgramFilename())+"ChangeLog.txt")
      If iFile
        WriteData(iFile, ?DS_ChangeLog, ?DS_EndChangeLog-?DS_ChangeLog)
        CloseFile(iFile)
      EndIf
    CompilerEndIf
  EndProcedure
CompilerEndIf



Procedure _EndPlayer()
  If IsWindow(#WINDOW_MAIN)
    HideWindow(#WINDOW_MAIN, #True)
  EndIf
  
  CompilerIf #USE_VIRTUAL_FILE
    If IsVirtualFileUsed
      If IsHookdisabled
        VirtualFile_ReactivateHook(#False, #True)
        WriteLog("Reactivate Hook", #LOGLEVEL_DEBUG)
        IsHookdisabled = #False
      EndIf
    EndIf
  CompilerEndIf
  
  
  ;LAVFilters_DeRegister() ;causes crash
  If sTmpRegisteredDLL.s <> ""
    SafeRegister(sTmpRegisteredDLL.s,#False, #True)
  EndIf
  
  SavePlayerSettings()
  FreeVolumeGadget(iVolumeGadget)
  FreeVolumeGadget(iVDVD_VolumeGadget)
  iVolumeGadget=#Null
  iVDVD_VolumeGadget=#Null
  
  If *PLAYLISTDB
    DB_Flush(*PLAYLISTDB)
    DB_Close(*PLAYLISTDB)
    *PLAYLISTDB=#Null
  EndIf
  
  If *DRMV2_Cached_headerObj<>#Null:DRMV2Read_Free(*DRMV2_Cached_headerObj):*DRMV2_Cached_headerObj=#Null:EndIf
  
  TB_Free(*thumbButtons)
  VIS_Free()
  UxTheme_Free()
  FreeMediaFile()
  FreeAllCoverCacheData()
  If StreamingThreadsNotEnd=#False
    HTTPCONTEXT_UnInitialize()
  EndIf
  
  DShow_FreeMedia(iMediaMainObject);Muss als letzes freigeben werden.
  iMediaMainObject=#Null
  FreeMetaReader()
  EndMedia()
  FreeAllMediaCacheFiles()
  
  If *GFP_DRM_HEADER_V2
    DRMV2Read_Free(*GFP_DRM_HEADER_V2)
    *GFP_DRM_HEADER_V2=#Null
  EndIf  
  
  If IsSysTrayIcon(#SYSTRAY_MAIN)
    RemoveSysTrayIcon(#SYSTRAY_MAIN)
  Else
    WriteLog("No Systray loaded", #LOGLEVEL_DEBUG)
  EndIf
  
  ;FREE VIRTUAL FILE
  CompilerIf #USE_VIRTUAL_FILE
    If IsVirtualFileUsed
      VirtualFile_Free()
    EndIf  
  CompilerEndIf
  
  ;Hier logfile freigeben, führte zu Crash mit Virtual file und Kompartibilität.
  If IsWindow(#WINDOW_MAIN)
    RemoveAppCmdCallback(WindowID(#WINDOW_MAIN))
    CloseWindow(#WINDOW_MAIN)
  EndIf
  FreeWindowProtector()
  
  CompilerIf #USE_SWF_SUPPORT Or #USE_OEM_VERSION
    Flash_Uninit();MUST BE AFTER CLOSE WINDOW
  CompilerEndIf  
  
  
  If hMutexAppRunning
    CloseHandle_(hMutexAppRunning)
    hMutexAppRunning=#Null
  EndIf
  
  
  ;Dirty bugfix for madflac codec, hangs after the end of the program. (with .sami and .flac files)
  If #USE_VIRTUAL_FILE And IsVirtualFileUsed And iAlternativeHookingActive=#False
    If GetModuleHandle_("madFlac.ax")
      WriteLog("kick out madFlac.ax to prevent hanging application", #LOGLEVEL_ERROR)
      FreeLibrary_(GetModuleHandle_("madFlac.ax"))
    EndIf
  EndIf
  
  TIMER_Free()
  
  WriteLog("PLAYER-END", #LOGLEVEL_DEBUG)
  FreeLogFile()
  
  CompilerIf #USE_LEAK_DEBUG
    DEBUG_ShowLeaks()
  CompilerEndIf
  CompilerIf #USE_OPENLOG_AFTER_CLOSE
    RunProgram(sLogFileName)
  CompilerEndIf  
  
  ;Dirty fix for crash after end
  If OSVersion()=#PB_OS_Windows_Server_2008_R2
    ExitProcess_(0)
  EndIf  
  
  End
EndProcedure

Procedure ActivateFullscreenControl(Activate.i)
  Protected FullscreenControlHeight
  If UseNoPlayerControl=#False
    If IsFullscreenControlUsed<>Activate
      IsFullscreenControlUsed=Activate
      If Activate
        If SelectedOutputContainer = #GADGET_CONTAINER
          HideGadget(#GADGET_CONTAINER, #False)
        EndIf
        If SelectedOutputContainer = #GADGET_VIDEODVD_CONTAINER
          HideGadget(#GADGET_VIDEODVD_CONTAINER, #False)
        EndIf
      Else
        If SelectedOutputContainer = #GADGET_CONTAINER
          HideGadget(#GADGET_CONTAINER, #True)
        EndIf
        If SelectedOutputContainer = #GADGET_VIDEODVD_CONTAINER
          HideGadget(#GADGET_VIDEODVD_CONTAINER, #True)
        EndIf
      EndIf
      
      If IsFullscreenControlUsed
        FullscreenControlHeight=Design_Container_Size+3;+_StatusBarHeight(0)+MenuHeight()
      Else
        FullscreenControlHeight=0
      EndIf
      
      If IsFullscreenControlUsed
        If SelectedOutputContainer = #GADGET_CONTAINER
          ResizeGadget(#GADGET_CONTAINER, 1, WindowHeight(#WINDOW_MAIN)-Design_Container_Size, WindowWidth(#WINDOW_MAIN)-2, #PB_Ignore)
        EndIf  
        If SelectedOutputContainer = #GADGET_VIDEODVD_CONTAINER
          ResizeGadget(#GADGET_VIDEODVD_CONTAINER, 1, WindowHeight(#WINDOW_MAIN)-Design_Container_Size, WindowWidth(#WINDOW_MAIN)-2, #PB_Ignore)
        EndIf
      Else
        If SelectedOutputContainer = #GADGET_CONTAINER
          ResizeGadget(#GADGET_CONTAINER, 1, WindowHeight(#WINDOW_MAIN)-Design_Container_Size-_StatusBarHeight(0)-MenuHeight(), WindowWidth(#WINDOW_MAIN)-2, #PB_Ignore)
        EndIf  
        If SelectedOutputContainer = #GADGET_VIDEODVD_CONTAINER
          ResizeGadget(#GADGET_VIDEODVD_CONTAINER, 1, WindowHeight(#WINDOW_MAIN)-Design_Container_Size-_StatusBarHeight(0)-MenuHeight(), WindowWidth(#WINDOW_MAIN)-2, #PB_Ignore)
        EndIf
      EndIf
      If iIsVISUsed
        ResizeGadget(#GADGET_VIS_CONTAINER,  0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN)-FullscreenControlHeight)
        VIS_Resize()
      Else
        ResizeGadget(#GADGET_VIDEO_CONTAINER, -2, -2, WindowWidth(#WINDOW_MAIN)+4, WindowHeight(#WINDOW_MAIN)+4-FullscreenControlHeight)
      EndIf
    EndIf
  EndIf
EndProcedure
Procedure SetFullScreen(iWithoutSizing.i=#False, iReset.i=#False)
  Protected iNbDesktops.i, iWindowPointX.i, iWindowPointY.i, i.i, DRect.rect, WRect.rect
  Protected iDesktop.i, tmpRect.RECT
  If GetGadgetData(#GADGET_CONTAINER);Fullscreen is set
    If MediaWidth(iMediaObject)>0 Or iIsVISUsed Or iReset
      WriteLog("Set Window mode", #LOGLEVEL_DEBUG)
      ActivateFullscreenControl(#False)
      
      If iIsMediaObjectVideoDVD
        HideGadget(#GADGET_VIDEODVD_CONTAINER, #False)
      Else
        If UseNoPlayerControl=#False:HideGadget(#GADGET_CONTAINER, #False):EndIf
      EndIf
      
      HideMenu(0, #False)
      
      SetWindowLong_(WindowID(#WINDOW_MAIN),#GWL_STYLE, iOldFullScreenSkin)
      If Settings(#SETTINGS_USE_STATUSBAR)\sValue="1"
        If UseNoPlayerControl=#False:ShowWindow_(StatusBarID(#STATUSBAR_MAIN), #SW_SHOWDEFAULT):EndIf
      EndIf  
      
      If iIsMinimalMode.i=#False
        ResizeWindow_(#WINDOW_MAIN, iOldFullScreenX, iOldFullScreenY, iOldFullScreenWidth, iOldFullScreenHeight)
      EndIf
      
      SetGadgetData(#GADGET_CONTAINER, 0)
      ;ShowCursor_(1)
      
      ;SCREENSAVER CODE
      If iScreenSaverActive = #True 
        SystemParametersInfo_(#SPI_SETSCREENSAVEACTIVE, iScreenSaverActive, 0, 0)
        iScreenSaverActive = #False
      EndIf
      DisAllowStandby(#False)
      
      iIsMinimalMode.i=#False
      ;SendMessage_(WindowID(#WINDOW_MAIN), #PB_Event_SizeWindow,0,0)
      
      
      ;****  Dirty bugfix
      ; StickyWindow(#WINDOW_MAIN, iStayMainWndOnTop)
      ; Chaged to:
      StickyWindow(#WINDOW_MAIN, #False)
      ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      StickyWindow(#WINDOW_MAIN, iStayMainWndOnTop)
      ; Wenn Sticky an ist und Minimal mode, wird es nicht richtig resizt.
      ;****
      
      
    EndIf
  Else
    If MediaWidth(iMediaObject)>0 Or iIsVISUsed
      WriteLog("Set Fullscreen", #LOGLEVEL_DEBUG)
      
      IsFullscreenControlUsed = #False
      ;ShowCursor_(0)
      iOldFullScreenSkin = GetWindowLong_(WindowID(#WINDOW_MAIN),#GWL_STYLE)
      iOldFullScreenWidth = WindowWidth(#WINDOW_MAIN)
      iOldFullScreenHeight = WindowHeight(#WINDOW_MAIN)
      iOldFullScreenX = WindowX(#WINDOW_MAIN)
      iOldFullScreenY = WindowY(#WINDOW_MAIN)
      SetWindowLong_(WindowID(#WINDOW_MAIN),#GWL_STYLE, #WS_POPUP|#WS_VISIBLE)
      
      StickyWindow(#WINDOW_MAIN, #True)
      If iIsMediaObjectVideoDVD
        HideGadget(#GADGET_VIDEODVD_CONTAINER, #True)
      Else
        HideGadget(#GADGET_CONTAINER, #True)
      EndIf
      HideMenu(0, #True)
      If Settings(#SETTINGS_USE_STATUSBAR)\sValue="1"
        ShowWindow_(StatusBarID(#STATUSBAR_MAIN), #SW_HIDE)
      EndIf  
      
      iDesktop=GetUsedDesktop(#WINDOW_MAIN)
      If iWithoutSizing=#False
        ResizeWindow_(#WINDOW_MAIN, DesktopX(iDesktop), DesktopY(iDesktop), DesktopWidth(iDesktop), DesktopHeight(iDesktop))
      Else
        iIsMinimalMode.i=#True
      EndIf
      SetGadgetData(#GADGET_CONTAINER, 1)
      
      
      ;SCREENSAVER CODE
      SystemParametersInfo_(#SPI_GETSCREENSAVEACTIVE, 0, @iScreenSaverActive.i, 0) 
      If iScreenSaverActive = #True 
        SystemParametersInfo_(#SPI_SETSCREENSAVEACTIVE, #False, 0, 0) 
      EndIf
      DisAllowStandby(#True)
      
    EndIf
  EndIf
EndProcedure



Procedure.w MouseWheelDelta()
  Protected x.w
  x.w = ((EventwParam()>>16)&$FFFF) 
  ProcedureReturn -(x / 120) 
EndProcedure 
Procedure ProcessAllEvents()
  Protected iEvent
  Repeat
    iEvent = WindowEvent()
  Until iEvent = #False
EndProcedure

Procedure.s ConvertStringDBCompartible(sText.s, iConvert.i)
  If iConvert
    sText = ReplaceString(sText, "'", "[*S1*]")
  Else
    sText = ReplaceString(sText, "[*S1*]", "'")
  EndIf
  ProcedureReturn sText
EndProcedure

Procedure AddOptionsOption(iID.i, sText.s, sContent.s, iType.i, iSelected.i = 0, iIcon.i = 0)
  Protected sItem.s, i.i, iAddTextGadget = #False, iSecondGadget.i, iExtrasize.i=#False, TextGadget.i, UsedTextHeight.i
  
  If iType=#OPTIONS_CHECKBOX
    UsedTextHeight=100
    If IsFont(#FONT_OPTIONS)
      UsedTextHeight=GetFontHeight(FontID(#FONT_OPTIONS), sText, 300, 100)
    EndIf   
    If UsedTextHeight=100
      UsedTextHeight=25
    EndIf
  Else
    UsedTextHeight=100
    If IsFont(#FONT_OPTIONS)
      UsedTextHeight=GetFontHeight(FontID(#FONT_OPTIONS), sText, 130, 100)
    EndIf     
    If UsedTextHeight=100
      If Len(sText)>34:iExtrasize=#True:EndIf
      If Len(sText)<18
        UsedTextHeight=27
      Else
        UsedTextHeight=40+iExtrasize*20
      EndIf
    EndIf
  EndIf
  
  
  
  Select iType
    Case #OPTIONS_COMBOBOX
      ComboBoxGadget(iID, 175, 7 + iOptionsOptionCount, 200, 22)
      For i=1 To CountString(sContent, Chr(10))
        sItem.s = StringField(sContent, i, Chr(10))
        AddGadgetItem(iID, -1, sItem.s)
      Next
      SetGadgetState(iID, iSelected)
      iAddTextGadget = #True
      
    Case #OPTIONS_COMBOBOX_EDITABLE
      ComboBoxGadget(iID, 175, 7 + iOptionsOptionCount, 200, 22, #PB_ComboBox_Editable)
      For i=1 To CountString(sContent, Chr(10))
        sItem.s = StringField(sContent, i, Chr(10))
        AddGadgetItem(iID, -1, sItem.s)
      Next
      SetGadgetText(iID, Str(iSelected))
      iAddTextGadget = #True
      
    Case #OPTIONS_CHECKBOX
      CheckBoxGadget(iID, 40, 7 + iOptionsOptionCount, 330, UsedTextHeight, sText)
      SetGadgetState(iID, iSelected)
      If IsFont(#FONT_OPTIONS)
        If iID And IsGadget(iID)
          SetGadgetFont(iID, FontID(#FONT_OPTIONS))
        EndIf
      EndIf  
      
      
    Case #OPTIONS_STRING
      StringGadget(iID, 175, 7 + iOptionsOptionCount, 200, 22, sContent)
      iAddTextGadget = #True
      
    Case #OPTIONS_PATH
      StringGadget(iID, 175, 7 + iOptionsOptionCount, 170, 22, sContent)
      iSecondGadget = ButtonGadget(#PB_Any, 345, 7 + iOptionsOptionCount, 30, 22, "...")
      iAddTextGadget = #True
      OptionsGadgets(iOptionsGadgetItems)\iButton = iSecondGadget
      OptionsGadgets(iOptionsGadgetItems)\iShowGadget = iID
      OptionsGadgets(iOptionsGadgetItems)\iType = #OPTIONS_PATH
      iOptionsGadgetItems+1
      
    Case #OPTIONS_COLOR
      TextGadget(iID, 175, 7 + iOptionsOptionCount, 20, 20, "")
      SetGadgetColor(iID, #PB_Gadget_BackColor, iSelected)
      iSecondGadget = ButtonGadget(#PB_Any, 200, 6 + iOptionsOptionCount, 40, 22, "...")
      iAddTextGadget = #True
      OptionsGadgets(iOptionsGadgetItems)\iButton = iSecondGadget
      OptionsGadgets(iOptionsGadgetItems)\iShowGadget = iID
      OptionsGadgets(iOptionsGadgetItems)\iType = #OPTIONS_COLOR
      iOptionsGadgetItems+1
      
    Default
      ProcedureReturn #False
  EndSelect
  
  
  
  
  If iAddTextGadget
    TextGadget = TextGadget(#PB_Any, 40, 7 + iOptionsOptionCount, 130, UsedTextHeight, sText)
  EndIf
  If iIcon
    If IsImage(iIcon)
      ImageGadget(#PB_Any, 2, 2 + iOptionsOptionCount, 32, 32, ImageID(iIcon))
    EndIf  
  EndIf
  
  If IsFont(#FONT_OPTIONS)
    If TextGadget And IsGadget(TextGadget)
      SetGadgetFont(TextGadget, FontID(#FONT_OPTIONS))
    EndIf
  EndIf  
  
  If UsedTextHeight<40
    iOptionsOptionCount + 40
  Else
    iOptionsOptionCount + UsedTextHeight
  EndIf  
  
  ProcedureReturn #True
EndProcedure


Procedure ChangeIcon(iconFileName.s, exeFileName.s) 
  ResMod_RemoveIconGrp(exeFileName, "1")
  ResMod_AddIconGrp(exeFileName, iconFileName, "MAINICON")
EndProcedure




Procedure ProtectVideo_UpdateWindow(iImage.i=#SPRITE_BIGKEY, sTitle.s="", iCancel.i=#True)
  If sTitle.s="":sTitle.s=Language(#L_PLEASEWAIT):EndIf
  OpenWindow(#WINDOW_WAIT_PROTECTVIDEO, 0, 0, 300, 150, sTitle, #PB_Window_ScreenCentered)
  StickyWindow(#WINDOW_WAIT_PROTECTVIDEO, #True)
  TextGadget(#PB_Any, 50, 50, 200, 20, sTitle,#PB_Text_Center) 
  If iImage
    ImageGadget(#PB_Any, 5, 5, 24, 24, ImageID(iImage))
  EndIf
  ProgressBarGadget(#GADGET_PV_PROCCESS_PROGRESSBAR, 10, 70, 280, 22, 0, 100, #PB_ProgressBar_Smooth)
  ;TintGadget(#GADGET_PV_PROCCESS_PROGRESSBAR, 10000, 10000, 10000, 0, -100, 0, 0, #False)
  SetGadgetState(#GADGET_PV_PROCCESS_PROGRESSBAR, 0)
  If iCancel
    ButtonGadget(#GADGET_PV_PROCCESS_CANCEL, 220, 125, 70, 20, Language(#L_CANCEL))
  EndIf
EndProcedure
Procedure ProtectVideo_CB(p.q,s.q)
  Protected iEvent.i, iResult.i
  ;Debug StrD(p*100/s)
  Delay(1)
  iResult.i=0
  Repeat
    iEvent = WindowEvent()
    If iEvent=#PB_Event_Gadget
      If EventGadget()=#GADGET_PV_PROCCESS_CANCEL
        iResult.i=1
      EndIf
    EndIf
  Until iEvent = #False
  SetGadgetState(#GADGET_PV_PROCCESS_PROGRESSBAR, p*100/s)
  ProcedureReturn iResult.i
EndProcedure  
Procedure ProtectVideo(sSourceVideo.s, sOutputVideo.s, sPassword.s, sPasswordTip.s="", sTitle.s="", sAlbum.s="", sInterpret.s="", qLength.q=0, sComment.s="", fAspect.f=0, lCreationDate.l=0, bCanRemoveDRM.i=0, lSnapshotProtection.l=0, sCoverImage.s="", bAddPlayer.i=#False, qExpireDate.q=0, Codecname.s="", Codeclink.s="", CopyProtection.i=#False, sMachineIDXorKey.s="", sIcoFile.s="", Commands.s="")
  Protected image.i, sTempFile.s, EncryptFileFaild.i, Result.i, *Header, stdData.DRM_STANDARD_DATA, secData.DRM_SECURITY_DATA
  If FileSize(sSourceVideo)>0
    ProtectVideo_UpdateWindow()
    
    
    If CopyProtection
      If sPassword=""
        sPassword=GetDriveSerialFromFile(sOutputVideo);+GetGraphicCardName()+GetCPUName()
        sPasswordTip=""
      EndIf
    EndIf  
    
    If sPassword=""
      sPassword="default"
    EndIf  
    
    
    ;     InitDRMHeader(*GFP_DRM_HEADER, sSourceVideo)
    ;     SetDRMHeaderTitle(*GFP_DRM_HEADER, sTitle)
    ;     SetDRMHeaderAlbum(*GFP_DRM_HEADER, sAlbum)
    ;     SetDRMHeaderInterpreter(*GFP_DRM_HEADER, sInterpret)
    ;     SetDRMHeaderMediaLength(*GFP_DRM_HEADER, qLength)
    ;     SetDRMHeaderComment(*GFP_DRM_HEADER, sComment)
    ;     SetDRMHeaderPasswordTip(*GFP_DRM_HEADER, sPasswordTip)
    ;     If sCoverImage
    ;       image = LoadImage(#PB_Any, sCoverImage)
    ;       If IsImage(image)
    ;         SetDRMHeaderCover(*GFP_DRM_HEADER, image)
    ;         FreeImage(image)
    ;       EndIf
    ;     EndIf
    ;     
    ;     SetDRMHeaderAspect(*GFP_DRM_HEADER, fAspect)
    ;     SetDRMHeaderCreationDate(*GFP_DRM_HEADER, lCreationDate)
    ;     SetDRMHeaderCanRemoveDRM(*GFP_DRM_HEADER, bCanRemoveDRM)
    ;     SetDRMHeaderSnapshotProtection(*GFP_DRM_HEADER, lSnapshotProtection)
    ;     FinalizeDRMHeader(*GFP_DRM_HEADER, sPassword)
    
    ;MessageRequester(sMachineIDXorKey,sPassword)
    *Header = DRMV2Write_Create(sPassword)
    If *Header
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_TITLE, sTitle, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_ALBUM, sAlbum, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_INTERPRETER, sInterpret, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_PASSWORDTIP, sPasswordTip, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_COMMENT, sComment, #DRMV2_BLOCK_COMMENTSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_ORGINALNAME, GetFilePart(sSourceVideo), #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_CODECLINK, Codeclink, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_CODECNAME, Codecname, #DRMV2_BLOCK_STRINGSIZE)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_PLAYERVERSION, Str(#PB_Editor_BuildCount), #DRMV2_BLOCK_STRINGSIZE, #True)
      DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_MACHINEID, sMachineIDXorKey, Len(sMachineIDXorKey), #False)
      
      If CopyProtection
        DRMV2Write_AttachString(*Header, #DRMV2_HEADER_MEDIA_PARTITION_ID, GetDriveSerialFromFile(sOutputVideo), #DRMV2_BLOCK_STRINGSIZE, #True);+GetGraphicCardName()+GetCPUName()
      EndIf  
      SecData\bCanRemoveDRM = bCanRemoveDRM
      SecData\lSnapshotProtection = lSnapshotProtection
      SecData\qExpireDate = qExpireDate
      
      stdData\fAspect = fAspect
      stdData\qLength = qLength
      DRMV2Write_AttachStandardData(*Header,  stdData.DRM_STANDARD_DATA)
      
      DRMV2Write_AttachBlock(*Header, #DRMV2_HEADER_MEDIA_SECURITYDATA, @secData, SizeOf(DRM_SECURITY_DATA), #True)
      
      If sCoverImage
        image = LoadImage(#PB_Any, sCoverImage)
        If IsImage(image)
          DRMV2Write_AttachCoverImage(*Header, image)
          FreeImage(image)
        EndIf
      EndIf  
      
      If bAddPlayer
        sTempFile=GetTemporaryDirectory()+"GFP_CRYPTFILE_"+Hex(Random($FFFF))+"."+GetExtensionPart(sSourceVideo)
        Result=EncryptFileV2(sSourceVideo, sTempFile, sPassword, *Header, @ProtectVideo_CB())
        If Result=#S_OK
          If CopyFile(ProgramFilename(), sOutputVideo)
            If sIcoFile<>"";FIRST CHANGE ICON AND THAN ADD MEDIA FILE!!!!
              ChangeIcon(sIcoFile,sOutputVideo)
            EndIf              
            If BeginWriteEXEAttachments(sOutputVideo)
              AttachBigFileToEXEFile(sTempFile)
              ;FIRST ADD FILE THAN THE COMMANDLINE!!!
              If Commands.s<>""
                AttachMemoryToEXEFile("*COMMANDS*", @Commands, StringByteLength(Commands)+SizeOf(Character), #True)
              EndIf  
              EndWriteEXEAttachments()
            Else
              EncryptFileFaild=2
            EndIf
            
          Else
            EncryptFileFaild=1
          EndIf
          
          If EncryptFileFaild>0
            DeleteFile(sTempFile)
            WriteLog("ERROR: EncryptFile '" + sSourceVideo +  "' to '" + sOutputVideo + "' in ProtectVideo failed! ("+Str(EncryptFileFaild)+")")
            MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)  
          EndIf  
        Else  
          WriteLog("ERROR: EncryptFile '" + sSourceVideo +  "' to '" + sOutputVideo + "' in ProtectVideo failed!")
          MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)        
        EndIf
        ;If Result = #E_ABORT
        If FileSize(sTempFile)>0
          If Not DeleteFile(sTempFile)
            WriteLog("Can't delete temp file", #LOGLEVEL_DEBUG)
          EndIf  
        EndIf
        ;EndIf  
        CloseWindow(#WINDOW_WAIT_PROTECTVIDEO)
        
      Else  
        Result = EncryptFileV2(sSourceVideo, sOutputVideo, sPassword, *Header, @ProtectVideo_CB())
        If Result = #E_FAIL
          WriteLog("ERROR: EncryptFile '" + sSourceVideo +  "' to '" + sOutputVideo + "' in ProtectVideo failed!")
          MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)
        EndIf
        If Result = #E_ABORT
          If FileSize(sOutputVideo)>0
            DeleteFile(sOutputVideo)
          EndIf
        EndIf  
        CloseWindow(#WINDOW_WAIT_PROTECTVIDEO)
      EndIf
      DRMV2Write_Free(*Header)
    EndIf
    
    ProcedureReturn #True
  Else
    WriteLog("ERROR: File size of '" + sSourceVideo + "' is "+Str(FileSize(sSourceVideo)))
    MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_ENCRYPT_FILE), #MB_ICONERROR)
    ProcedureReturn #False
  EndIf
EndProcedure


Procedure ReplaceLanguageTable(*DB, *TempDB)
  Protected iDBFile.i, sTempDBFile.s, iRow.i, iColumns.i, iColumn.i, sCoumns.s, sCoumns2.s, sCoumns3.s, iMaxRow.i
  DB_UpdateSync(*DB, "DROP TABLE LANGUAGE")
  
  DB_Query(*TempDB, "SELECT * FROM LANGUAGE ORDER BY ID")
  DB_SelectRow(*TempDB, 0)
  iColumns.i = DB_GetNumColumns(*TempDB)
  sCoumns.s="CREATE TABLE LANGUAGE (id INT UNIQUE,"
  sCoumns2.s="INSERT INTO LANGUAGE ( "
  For iColumn=0 To iColumns-1
    If iColumn>0
      sCoumns.s + " "+DB_GetColumnName(*TempDB, iColumn)+" VARCHAR(500),"
    EndIf
    
    sCoumns2.s + " "+DB_GetColumnName(*TempDB, iColumn)+","
    sCoumns3.s + "?,"
  Next
  sCoumns.s=Left(sCoumns.s, Len(sCoumns.s)-1)+")"
  sCoumns2.s=Left(sCoumns2.s, Len(sCoumns2.s)-1)+")"+" VALUES ("+Left(sCoumns3.s, Len(sCoumns3.s)-1)+")"
  DB_Update(*DB, sCoumns)
  
  iMaxRow = 0
  While DB_SelectRow(*TempDB, iMaxRow)
    iMaxRow + 1
  Wend
  
  iRow = 0
  While DB_SelectRow(*TempDB, iRow)
    ProtectVideo_CB(iRow, iMaxRow)
    If DB_Query(*DB, sCoumns2)
      For iColumn=0 To iColumns-1
        DB_StoreAsString(*DB, iColumn, DB_GetAsString(*TempDB, iColumn))
      Next
      DB_StoreRow(*DB)
    EndIf
    DB_EndQuery(*DB)
    iRow + 1
  Wend
  DB_EndQuery(*TempDB)
  
EndProcedure  
Procedure UpdateDatabase_Langauge(*DB, *TempDB, iOldVersion)
  Protected iColumns.i, iColumnsTemp.i, sStatement.s, sColumns.s, i.i, iRow.i, sValues.s
  If DB_Query(*TempDB, "SELECT * FROM LANGUAGE")
    DB_SelectRow(*TempDB, 0)
    iColumnsTemp.i = DB_GetNumColumns(*TempDB)
    sColumns=""
    For i=0 To iColumnsTemp-1
      sColumns=sColumns+"'"+DB_GetColumnName(*TempDB, i)+"',"
    Next  
  EndIf
  DB_EndQuery(*TempDB)
  
  If DB_Query(*DB, "SELECT * FROM LANGUAGE")
    DB_SelectRow(*DB, 0)
    iColumns.i = DB_GetNumColumns(*DB)
  EndIf
  DB_EndQuery(*DB)
  
  If iColumnsTemp<>iColumns Or iOldVersion<1345;Wenn neue Spalten(Sprachen) dazu gekommen sind
    ReplaceLanguageTable(*DB, *TempDB)
  Else
    sColumns=Mid(sColumns, 1, Len(sColumns)-1)
    If DB_Query(*TempDB, "SELECT * FROM LANGUAGE ORDER BY ID")
      While DB_SelectRow(*TempDB, iRow)
        sStatement="INSERT OR REPLACE INTO LANGUAGE ("+sColumns+") VALUES "
        sValues.s="( "
        For i=0 To iColumns-1
          sValues=sValues+"'"+ReplaceString(DB_GetAsString(*TempDB, i),"'","''")+"',"
        Next
        
        sValues.s=Mid(sValues, 1, Len(sValues)-1)+" )"
        ;Debug sStatement+sValues
        DB_Update(*DB, sStatement+sValues)
        iRow + 1
      Wend
    EndIf  
    DB_EndQuery(*TempDB)
  EndIf  
EndProcedure
Procedure UpdateDatabase_Settings(*DB, *TempDB)
  Protected iRow, iAddItem.i
  If DB_Query(*TempDB, "SELECT * FROM SETTINGS ORDER BY ID")
    iRow = 0
    While DB_SelectRow(*TempDB, iRow)
      iAddItem.i=#False
      If DB_Query(*DB, "SELECT * FROM SETTINGS WHERE id = '"+DB_GetAsString(*TempDB, 0)+"'")
        DB_SelectRow(*DB, 0)
        If DB_GetAsString(*DB, 0)=""
          iAddItem.i=#True
        EndIf
      EndIf
      DB_EndQuery(*DB)
      If iAddItem
        ProtectVideo_CB(99, 100)
        ;If DB_Query(*DB, "INSERT INTO SETTINGS (id, Key, Value) VALUES (?,?,?)")
        ;  DB_StoreAsString(*DB, 0, DB_GetAsString(*TempDB, 0))
        ;  DB_StoreAsString(*DB, 1, DB_GetAsString(*TempDB, 1))
        ;  DB_StoreAsString(*DB, 2, DB_GetAsString(*TempDB, 2))
        ;  WriteLog("Setting Added: "+DB_GetAsString(*TempDB, 1))
        ;EndIf
        ;DB_EndQuery(*DB)
        DB_Update(*DB, "INSERT INTO SETTINGS (id, Key, Value) VALUES ('"+DB_GetAsString(*TempDB, 0)+"','"+DB_GetAsString(*TempDB, 1)+"','"+DB_GetAsString(*TempDB, 2)+"')")
        WriteLog("Setting Added: "+DB_GetAsString(*TempDB, 1))
        
      EndIf
      iRow + 1
    Wend
  EndIf
  DB_EndQuery(*TempDB)
  SetSettingFast(*DB, #SETTINGS_PLAYER_VERSION, #PLAYER_VERSION)
  SetSettingFast(*DB, #SETTINGS_PLAYER_BUILD, Str(#PB_Editor_BuildCount))
EndProcedure
Procedure UpdateDatabase(sDBFile.s)
  Protected iDBFile.i, sTempDBFile.s, *DB, *TempDB, iRow.i, iColumns.i, iColumn.i, sCoumns.s, sCoumns2.s, sCoumns3.s, iOldPlayerVersion.i
  sTempDBFile.s=GetTemporaryDirectory()+"\GF-Player-TempDB_"+Hex(Random($FFFF))+".db"
  iDBFile = CreateFile(#PB_Any, sTempDBFile.s)
  If iDBFile
    ProtectVideo_UpdateWindow(0, "Please wait! Updating database...", #False)
    WriteLog("Update Database", #LOGLEVEL_DEBUG)
    WriteData(iDBFile, ?DS_SQLDataBase, ?DS_EndSQLDataBase-?DS_SQLDataBase)
    CloseFile(iDBFile)
    *DB=DB_Open(sDBFile.s)
    *TempDB=DB_Open(sTempDBFile)
    If *DB And *TempDB
      
      ;Get Old Player Version:
      If DB_Query(*DB, "SELECT * FROM SETTINGS WHERE Key='player build'")
        DB_SelectRow(*DB, 0)
        iOldPlayerVersion=Val(Trim(DB_GetAsString(*DB, 2)))
        
        Debug iOldPlayerVersion
      EndIf
      DB_EndQuery(*DB)
      
      ;Update to B667:
      If iOldPlayerVersion<667
        DB_Update(*DB, "ALTER TABLE PLAYTRACKS ADD COLUMN cover INTEGER")
        DB_Update(*DB,"CREATE TABLE COVER (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, interpret VARCHAR(200), album VARCHAR(200), md5 VARCHAR(100) UNIQUE, data BLOB)")
        WriteLog("Added cover column to Playtracks!", #LOGLEVEL_DEBUG)
      EndIf
      
      
      ;Update Language and Settings:    
      UpdateDatabase_Langauge(*DB, *TempDB, iOldPlayerVersion)
      UpdateDatabase_Settings(*DB, *TempDB)
      
      ;Update to B690:
      If iOldPlayerVersion<690
        DB_Update(*DB, "UPDATE SETTINGS SET Key = '.mpc', Value = '' WHERE id = '41' ")
      EndIf
      
      If iOldPlayerVersion<764
        DB_Update(*DB, "UPDATE SETTINGS SET Key = '.vis-dll', Value = 'NONE' WHERE id = '44' ")
      EndIf
      
      If iOldPlayerVersion<860
        DB_Update(*DB,"CREATE TABLE FILEEXT (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, key VARCHAR(16), value VARCHAR(256), type INTEGER)")
        ;GFP
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.gfp','','1')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.vis-dll','','1')")
        
        ;VIDEO
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.3g2','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.3gp','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.asf','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.avi','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.flv','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.mov','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.mp4','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.mpg','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.rm','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.swf','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.vob','','2')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.wmv','','2')")
        
        ;AUDIO
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.aac','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.aif','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.iff','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.mid','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.midi','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.mp3','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.mpa','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.ra','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.wav','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.wma','','3')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.mpc','','3')")
        
        ;PLAYLIST
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.pls','','4')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.xspf','','4')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.asx','','4')")
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.m3u','','4')")  
      EndIf
      
      If iOldPlayerVersion<1029
        DB_Update(*DB, "UPDATE SETTINGS SET Key = 'window bk color', Value = '-1' WHERE id = '18' ")
        DB_Update(*DB, "CREATE TABLE CHRONIC (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, file VARCHAR(500), date INT)")
      EndIf
      
      If iOldPlayerVersion<1164
        CompilerIf #USE_OEM_VERSION=#False
          DB_Update(*DB, "UPDATE SETTINGS SET Value = '1' WHERE id = '19' ")
          DB_Update(*DB, "UPDATE SETTINGS SET Value = '3' WHERE id = '16' ")
        CompilerEndIf
      EndIf
      
      If iOldPlayerVersion<1178
        DB_Update(*DB, "CREATE TABLE CODECS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(500), file VARCHAR(500), description VARCHAR(500), FOURCC VARCHAR(500), extensions VARCHAR(500), version INT, allusers INT)")
      EndIf
      
      If iOldPlayerVersion<1361
        DB_UpdateSync(*DB,"CREATE TABLE MEDIAPOS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, file VARCHAR(800) UNIQUE, pos BIGINT)")  
      EndIf
      
      If iOldPlayerVersion<1446
        DB_UpdateSync(*DB,"DROP TABLE MEDIAPOS") 
        DB_UpdateSync(*DB,"CREATE TABLE MEDIAPOS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, file VARCHAR(800), pos BIGINT, offset BIGINT, UNIQUE (file, offset))") 
      EndIf  
      
      If iOldPlayerVersion<1999;DESIGNS
        DB_Update(*DB,"CREATE TABLE DESIGN (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Name VARCHAR(500), Buttons INTEGER, Buttonstates INTEGER, BK_Color INTEGER, Trackbar INTEGER, Volume INTEGER, Container_Border INTEGER, Container_Size INTEGER, Unique_ID VARCHAR(500) UNIQUE, Image BLOB)") 
        DB_Update(*DB,"CREATE TABLE DESIGN_DATA (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Design_id INTEGER, Name VARCHAR(500), Image INTEGER, Data BLOB)") 
        DB_Update(*DB,"CREATE TABLE DESIGN_CONTROLS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Design_id INTEGER, Control INTEGER, x INTEGER, y INTEGER, Width INTEGER, Height INTEGER, Aligment INTEGER)") 
        DB_Update(*DB, "UPDATE SETTINGS SET Value = '1' WHERE id = '16' ");SET DESIGN = DEFAULT  
      EndIf  
      InstallDesigns(*DB, *TempDB)
      
      If iOldPlayerVersion<2184
        DB_Update(*DB, "UPDATE SETTINGS SET Value = '0' WHERE id = '17' ");DISABLE STATUSBAR
      EndIf  
      
      If iOldPlayerVersion<2500
        DB_Update(*DB, "INSERT INTO FILEEXT (Key, Value, type) VALUES ('.webm','','2')")         
      EndIf 
      
    EndIf
    DB_Close(*DB)
    DB_Close(*TempDB)
    WriteLog("End Update DB", #LOGLEVEL_DEBUG)
    CloseWindow(#WINDOW_WAIT_PROTECTVIDEO)
    DeleteFile(sTempDBFile)
  Else
    WriteLog("Can't create Temp Database!")
  EndIf
EndProcedure
Procedure CheckDatabase(sDBFile.s)
  Protected iDBFile.i, sTempDBFile.s, *DB, iUpdateDataBase.i=#False
  If FileSize(sDBFile.s)<1
    CreateDirectory(GetPathPart(sDBFile.s))
    iDBFile = CreateFile(#PB_Any, sDBFile.s)
    If iDBFile
      WriteData(iDBFile, ?DS_SQLDataBase, ?DS_EndSQLDataBase-?DS_SQLDataBase)
      CloseFile(iDBFile)
      SetDefaultLng()
      WriteLog("Created new Database!")
      *DB=DB_Open(sDBFile)
      If *DB
        DB_Query(*DB, "UPDATE SETTINGS SET value='0' WHERE id='51'")
        DB_EndQuery(*DB)
        DB_Close(*DB)       
      EndIf
    Else
      WriteLog("Can't create new Database!")
      Requester_Error("Can't create new Database!")
      End
    EndIf
  Else
    
    *DB=DB_Open(sDBFile)
    If *DB
      If DB_Query(*DB, "SELECT * FROM SETTINGS WHERE id='"+Str(#SETTINGS_PLAYER_BUILD)+"'")
        DB_SelectRow(*DB, 0)
        If Val(DB_GetAsString(*DB, 2))<>#PB_Editor_BuildCount
          If Val(DB_GetAsString(*DB, 2))>#PB_Editor_BuildCount
            ;MessageRequester("Error", "Can't update database!"+#CRLF$+"Please download the newest version!")
            ;End
            
            iUpdateDataBase.i=2
          Else
            iUpdateDataBase.i=#True
          EndIf
        EndIf
        DB_EndQuery(*DB)
        DB_Close(*DB)        
      EndIf
      If iUpdateDataBase=#True
        UpdateDatabase(sDBFile.s)
      EndIf
      If iUpdateDataBase=2
        Requester_Cant_Update()
      EndIf
    EndIf
  EndIf
EndProcedure


Procedure TreeGadgetProcedure(TreehWnd, TreeuMsg, TreewParam, TreelParam)
  Protected erg.i, ps.PAINTSTRUCT
  erg = 0
  Select TreeuMsg
    Case #WM_PAINT
      If TreePainting = 0
        TreePainting = 1
        If TreeGadgetProcedure
          erg = CallWindowProc_(TreeGadgetProcedure, TreehWnd, TreeuMsg, Treem2DC, 0)
        Else
          erg = DefWindowProc_(TreehWnd, TreeuMsg, Treem2DC, 0)
        EndIf
        If Treem2DC And TreehWnd
          BeginPaint_(TreehWnd, ps.PAINTSTRUCT)
          BitBlt_(Treem2DC, ps\rcPaint\left, ps\rcPaint\top, ps\rcPaint\right-ps\rcPaint\left, ps\rcPaint\bottom-ps\rcPaint\top, TreemDC, ps\rcPaint\left, ps\rcPaint\top, #SRCAND)
          BitBlt_(Treem2DC, 0, 0, Treewidth, Treeheight, TreemDC, 0, 0, #SRCAND)
          TreehDC = GetDC_(TreehWnd)
          If TreehDC
            BitBlt_(TreehDC, ps\rcPaint\left, ps\rcPaint\top, ps\rcPaint\right-ps\rcPaint\left, ps\rcPaint\bottom-ps\rcPaint\top, Treem2DC, ps\rcPaint\left, ps\rcPaint\top, #SRCCOPY)
            BitBlt_(TreehDC, 0, 0, Treewidth, Treeheight, Treem2DC, 0, 0, #SRCCOPY)
            ReleaseDC_(TreehWnd, TreehDC)
          EndIf
          EndPaint_(TreehWnd, ps)
        EndIf
        TreePainting = 0
      EndIf
    Case #WM_ERASEBKGND
      erg = 0;1
    Default
      If TreeGadgetProcedure
        erg = CallWindowProc_(TreeGadgetProcedure, TreehWnd, TreeuMsg, TreewParam, TreelParam)
      Else
        erg = DefWindowProc_(TreehWnd, TreeuMsg, TreewParam, TreelParam)
      EndIf
  EndSelect
  ProcedureReturn erg
EndProcedure
Procedure SetTreeGadgetBkImage(GadGet,WindowID.l,Image)
  Protected TreemOldObject, TreehmBitmap, Treem2OldObject
  If GadGet And WindowID
    Treewidth=ImageWidth(Image)
    Treeheight=ImageHeight(Image)
    TreeWindowID = WindowID
    
    TreehDC = GetDC_(TreeWindowID)
    If TreehDC
      TreemDC = CreateCompatibleDC_(TreehDC)
      If TreehDC
        TreemOldObject = SelectObject_(TreemDC, ImageID(Image))
        Treem2DC = CreateCompatibleDC_(TreehDC)
        TreehmBitmap = CreateCompatibleBitmap_(TreehDC,Treewidth , Treeheight)
        If Treem2DC
          Treem2OldObject = SelectObject_(Treem2DC, TreehmBitmap)
        EndIf
        ReleaseDC_(TreeWindowID, TreehDC)
        TreeGadgetProcedure = SetWindowLong_(GadGet, #GWL_WNDPROC, @TreeGadgetProcedure())
      Else
        WriteLog("Can't create compatible DC!")
      EndIf
    Else
      WriteLog("Can't get DC!")
    EndIf
    
  EndIf
EndProcedure
Procedure FreeTreeGadgetBkImage()
  If TreemDC
    SelectObject_(TreemDC, TreemOldObject)
    DeleteDC_(TreemDC)
  EndIf
  If Treem2DC
    SelectObject_(Treem2DC, Treem2OldObject)
    DeleteObject_(TreehmBitmap)
    DeleteDC_(Treem2DC)    
  EndIf  
EndProcedure


Procedure HoverGadgetImage(Gadget, Image, HoveredImage, ClickImage, MouseX, MouseY, MousePressed, HoveredClickImage=#Null)
  Protected UseImage
  If IsGadget(Gadget)
    UseImage=Image
    
    If Sqr(Pow(GadgetX(Gadget)+16-MouseX,2)+Pow(GadgetY(Gadget)+16-MouseY,2))<15
      UseImage=HoveredImage
      If MousePressed
        UseImage=ClickImage
      EndIf
    EndIf    
    
    
    If Gadget=#GADGET_BUTTON_REPEAT And GetGadgetData(#GADGET_BUTTON_REPEAT)
      If HoveredClickImage And Sqr(Pow(GadgetX(Gadget)+16-MouseX,2)+Pow(GadgetY(Gadget)+16-MouseY,2))<15
        UseImage=HoveredClickImage
      Else
        UseImage=ClickImage
      EndIf
    EndIf
    If Gadget=#GADGET_BUTTON_RANDOM And GetGadgetData(#GADGET_BUTTON_RANDOM)
      If HoveredClickImage And Sqr(Pow(GadgetX(Gadget)+16-MouseX,2)+Pow(GadgetY(Gadget)+16-MouseY,2))<15
        UseImage=HoveredClickImage
      Else
        UseImage=ClickImage
      EndIf
    EndIf
    
    If IsImage(UseImage)
      If GetGadgetState(Gadget)<>ImageID(UseImage)
        SetGadgetState(Gadget, ImageID(UseImage))
      EndIf
    EndIf
  EndIf
EndProcedure
Procedure HoverGadgetImages()
  Protected MouseX.i, MouseY.i, MousePressed.i
  If Design_Buttons=0
    ;If GetActiveWindow() = #WINDOW_MAIN
    
    MousePressed = GetAsyncKeyState_(#VK_LBUTTON)
    
    If SelectedOutputContainer = #GADGET_CONTAINER
      MouseX=WindowMouseX(#WINDOW_MAIN)-GadgetX(#GADGET_CONTAINER)
      MouseY=WindowMouseY(#WINDOW_MAIN)-GadgetY(#GADGET_CONTAINER)
      
      CompilerIf #USE_OEM_VERSION
        HoverGadgetImage(#GADGET_BUTTON_FULLSCREEN, #SPRITE_FULLSCREEN, #SPRITE_FULLSCREEN_HOVER, #SPRITE_FULLSCREEN_CLICK, MouseX, MouseY, MousePressed)
      CompilerEndIf  
      
      HoverGadgetImage(#GADGET_BUTTON_BACKWARD, #SPRITE_BACKWARD, #SPRITE_BACKWARD_HOVER, #SPRITE_BACKWARD_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_BUTTON_FORWARD, #SPRITE_FORWARD, #SPRITE_FORWARD_HOVER, #SPRITE_FORWARD_CLICK, MouseX, MouseY, MousePressed)
      If MediaState=2 And MediaPosition<>MediaLength
        HoverGadgetImage(#GADGET_BUTTON_PLAY, #SPRITE_BREAK, #SPRITE_BREAK_HOVER, #SPRITE_BREAK_CLICK, MouseX, MouseY, MousePressed)
      Else
        HoverGadgetImage(#GADGET_BUTTON_PLAY, #SPRITE_PLAY, #SPRITE_PLAY_HOVER, #SPRITE_PLAY_CLICK, MouseX, MouseY, MousePressed)
      EndIf  
      HoverGadgetImage(#GADGET_BUTTON_PREVIOUS, #SPRITE_PREVIOUS, #SPRITE_PREVIOUS_HOVER, #SPRITE_PREVIOUS_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_BUTTON_STOP, #SPRITE_STOP, #SPRITE_STOP_HOVER, #SPRITE_STOP_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_BUTTON_NEXT, #SPRITE_NEXT, #SPRITE_NEXT_HOVER, #SPRITE_NEXT_CLICK, MouseX, MouseY, MousePressed)
      
      If IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_ALLOW 
        HoverGadgetImage(#GADGET_BUTTON_SNAPSHOT, #SPRITE_SNAPSHOT, #SPRITE_SNAPSHOT_HOVER, #SPRITE_SNAPSHOT_CLICK, MouseX, MouseY, MousePressed)
      Else
        HoverGadgetImage(#GADGET_BUTTON_SNAPSHOT, #SPRITE_SNAPSHOT_DISABLED, #SPRITE_SNAPSHOT_DISABLED, #SPRITE_SNAPSHOT_DISABLED, MouseX, MouseY, MousePressed)
      EndIf
      
      If Design_Buttonstates=3
        HoverGadgetImage(#GADGET_BUTTON_REPEAT, #SPRITE_REPEAT, #SPRITE_REPEAT_HOVER, #SPRITE_REPEAT_CLICK, MouseX, MouseY, MousePressed, #SPRITE_REPEAT_CLICK_HOVER)
        HoverGadgetImage(#GADGET_BUTTON_RANDOM, #SPRITE_RANDOM, #SPRITE_RANDOM_HOVER, #SPRITE_RANDOM_CLICK, MouseX, MouseY, MousePressed, #SPRITE_RANDOM_CLICK_HOVER)
      Else  
        HoverGadgetImage(#GADGET_BUTTON_REPEAT, #SPRITE_REPEAT, #SPRITE_REPEAT_HOVER, #SPRITE_REPEAT_CLICK, MouseX, MouseY, MousePressed)
        HoverGadgetImage(#GADGET_BUTTON_RANDOM, #SPRITE_RANDOM, #SPRITE_RANDOM_HOVER, #SPRITE_RANDOM_CLICK, MouseX, MouseY, MousePressed)
      EndIf
      
    EndIf
    
    If SelectedOutputContainer = #GADGET_VIDEODVD_CONTAINER
      MouseX=WindowMouseX(#WINDOW_MAIN)-GadgetX(#GADGET_VIDEODVD_CONTAINER)
      MouseY=WindowMouseY(#WINDOW_MAIN)-GadgetY(#GADGET_VIDEODVD_CONTAINER)
      If MediaState(iMediaObject)=2 
        HoverGadgetImage(#GADGET_VDVD_BUTTON_PLAY, #SPRITE_BREAK, #SPRITE_BREAK_HOVER, #SPRITE_BREAK_CLICK, MouseX, MouseY, MousePressed)
      Else
        HoverGadgetImage(#GADGET_VDVD_BUTTON_PLAY, #SPRITE_PLAY, #SPRITE_PLAY_HOVER, #SPRITE_PLAY_CLICK, MouseX, MouseY, MousePressed)
      EndIf  
      
      HoverGadgetImage(#GADGET_VDVD_BUTTON_PREVIOUS, #SPRITE_PREVIOUS, #SPRITE_PREVIOUS_HOVER, #SPRITE_PREVIOUS_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_VDVD_BUTTON_STOP, #SPRITE_STOP, #SPRITE_STOP_HOVER, #SPRITE_STOP_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_VDVD_BUTTON_NEXT, #SPRITE_NEXT, #SPRITE_NEXT_HOVER, #SPRITE_NEXT_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_VDVD_BUTTON_EJECT, #SPRITE_EJECT, #SPRITE_EJECT_HOVER, #SPRITE_EJECT_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_VDVD_BUTTON_LAUFWERK, #SPRITE_CDDRIVE_BLUE, #SPRITE_CDDRIVE_BLUE_HOVER, #SPRITE_CDDRIVE_BLUE_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_VDVD_BUTTON_SNAPSHOT, #SPRITE_SNAPSHOT, #SPRITE_SNAPSHOT_HOVER, #SPRITE_SNAPSHOT_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_VDVD_BUTTON_BACKWARD, #SPRITE_BACKWARD, #SPRITE_BACKWARD_HOVER, #SPRITE_BACKWARD_CLICK, MouseX, MouseY, MousePressed)
      HoverGadgetImage(#GADGET_VDVD_BUTTON_FORWARD, #SPRITE_FORWARD, #SPRITE_FORWARD_HOVER, #SPRITE_FORWARD_CLICK, MouseX, MouseY, MousePressed)   
    EndIf
    
    If SelectedOutputContainer = #GADGET_AUDIOCD_CONTAINER
      MouseX=WindowMouseX(#WINDOW_MAIN)-GadgetX(#GADGET_AUDIOCD_CONTAINER)
      MouseY=WindowMouseY(#WINDOW_MAIN)-GadgetY(#GADGET_AUDIOCD_CONTAINER)
      
      HoverGadgetImage(#GADGET_ACD_BUTTON_PLAY, #SPRITE_PLAY, #SPRITE_PLAY_HOVER, #SPRITE_PLAY_CLICK, MouseX, MouseY, MousePressed)   
      HoverGadgetImage(#GADGET_ACD_BUTTON_PREVIOUS, #SPRITE_PREVIOUS, #SPRITE_PREVIOUS_HOVER, #SPRITE_PREVIOUS_CLICK, MouseX, MouseY, MousePressed)   
      HoverGadgetImage(#GADGET_ACD_BUTTON_STOP, #SPRITE_STOP, #SPRITE_STOP_HOVER, #SPRITE_STOP_CLICK, MouseX, MouseY, MousePressed)   
      HoverGadgetImage(#GADGET_ACD_BUTTON_NEXT, #SPRITE_NEXT, #SPRITE_NEXT_HOVER, #SPRITE_NEXT_CLICK, MouseX, MouseY, MousePressed)   
      HoverGadgetImage(#GADGET_ACD_BUTTON_EJECT, #SPRITE_EJECT, #SPRITE_EJECT_HOVER, #SPRITE_EJECT_CLICK, MouseX, MouseY, MousePressed)   
    EndIf
    ;EndIf
  EndIf
EndProcedure
Procedure SetPlayTumbButtonImage(Image.i)
  If *thumbButtons
    If ThumbButtons(1)\hIcon <> ImageID(Image)
      ThumbButtons(1)\hIcon = ImageID(Image)
      TB_UpdateButtons(*thumbButtons, WindowID(#WINDOW_MAIN), 3, @ThumbButtons())
    EndIf
  EndIf
EndProcedure  

Procedure SetProtectVideoCover(sFile.s,  pPicture=#Null, pSize=0)
  Protected Width, Height
  If sFile Or pPicture
    If IsImage(#SPRITE_PV_COVER):FreeImage(#SPRITE_PV_COVER):EndIf
    If pPicture:CatchImage(#SPRITE_PV_COVER, pPicture, pSize):EndIf
    If sFile:LoadImage(#SPRITE_PV_COVER, sFile):EndIf
    If IsImage(#SPRITE_PV_COVER)
      Width = ImageWidth(#SPRITE_PV_COVER)
      Height = ImageHeight(#SPRITE_PV_COVER)
      If Width=Height
        Width = 100
        Height = 100
      Else
        If Width>Height
          Height = 100 * Height/Width
          Width = 100
        Else
          Width = 100 * Width/Height
          Height = 100
        EndIf
      EndIf
      ResizeImage(#SPRITE_PV_COVER, Width, Height)
      SetGadgetText(#GADGET_PV_COVER_STRING, sFile)
      SetGadgetState(#GADGET_PV_COVER_IMG, ImageID(#SPRITE_PV_COVER))
    Else
      SetGadgetState(#GADGET_PV_COVER_IMG, ImageID(#SPRITE_NOIMAGE))
      SetGadgetText(#GADGET_PV_COVER_STRING, "")
    EndIf
  EndIf
EndProcedure
Procedure SetProtectVideo(sFile.s)
  Protected sGUID.s, sCoverFile.s, sOutputFile.s, ext.s, isEnc.i
  If sFile
    If FileSize(sFile)>0
      SetGadgetText(#GADGET_PV_LOAD_STRING, sFile)
      ext.s=LCase(GetExtensionPart(sFile))
      If ext="gfp" Or ext="mp-video"
        isEnc=#True
      EndIf  
      If isEnc=#False  
        LoadMetaFile(sFile)
        SetGadgetText(#GADGET_PV_TAG_TITLE, MediaInfoData\sTile)
        SetGadgetText(#GADGET_PV_TAG_ALBUM, MediaInfoData\sAlbumTitle)
        SetGadgetText(#GADGET_PV_TAG_INTERPRET, MediaInfoData\sAutor)
        SetGadgetText(#GADGET_PV_TAG_COMMENT, MediaInfoData\sGenere)
        
        sGUID.s=MediaInfoData\sGUID
        If sGUID
          sCoverFile.s=GetPathPart(sFile)+"\"+"AlbumArt_"+sGUID+"_Large.jpg"
          If FileSize(sCoverFile)>0
            SetProtectVideoCover(sCoverFile)
          Else
            sCoverFile.s=GetPathPart(sFile)+"\"+"AlbumArt_"+sGUID+"_Large.png"
            If FileSize(sCoverFile)>0
              SetProtectVideoCover(sCoverFile)
            EndIf
          EndIf
        EndIf
      EndIf
      ;If GetGadgetText(#GADGET_PV_SAVE_STRING)=""
      CompilerIf #USE_OEM_VERSION
        sOutputFile=sFile+#GFP_PROTECTED_FILE_EXTENTION
      CompilerElse  
        sOutputFile=Mid(sFile, 1, Len(sFile)-Len(GetExtensionPart(sFile))-1)+#GFP_PROTECTED_FILE_EXTENTION
      CompilerEndIf
      If GetGadgetState(#GADGET_PV_ADDPLAYER) = #PB_Checkbox_Checked:sOutputFile=SwapExtension(sOutputFile, "exe"):EndIf
      SetGadgetText(#GADGET_PV_SAVE_STRING, sOutputFile)
      ;EndIf
      If isEnc
        SetGadgetText(#GADGET_PV_WARNING, Language(#L_ERROR)+":"+#CRLF$+Language(#L_YOU_CANT_ENCRYPT_THIS_FILE))
      Else  
        If GetMediaLenght(sFile)<=0
          SetGadgetText(#GADGET_PV_WARNING, Language(#L_ERROR_CANT_LOAD_MEDIA)+#CRLF$+Language(#L_YOU_NEED_A_CODEC_TO_PLAY_THIS_FILE))
        Else  
          SetGadgetText(#GADGET_PV_WARNING, "")
        EndIf
      EndIf
      
    EndIf
  EndIf
EndProcedure


Procedure CBMainWindow(WindowID, Message, wParam, lParam)
  Protected result
  Protected *pnmhdr.NMHDR, *tbcd.NMCUSTOMDRAW,chRc.RECT
  Protected width, height, midX, midY, offset, re.rect,pt.point, bHighlight = #False
  Result = #PB_ProcessPureBasicEvents
  
  ;EDIT:
  If Message = #WM_SIZING 
    
    If WindowID = WindowID(#WINDOW_MAIN)
      ResizeMainWindow()
      ProcedureReturn #True
    EndIf
    If WindowID = WindowID(#WINDOW_LIST)
      ResizeGadget(#GADGET_LIST_SPLITTER, 0, ToolBarHeight(#TOOLBAR_PLAYLIST), WindowWidth(#WINDOW_LIST), WindowHeight(#WINDOW_LIST)-ToolBarHeight(#TOOLBAR_PLAYLIST))
      ResizeGadget(#GADGET_LIST_PLAYLIST, 0, 0, GadgetWidth(#GADGET_LIST_CONTAINER), GadgetHeight(#GADGET_LIST_CONTAINER)-100)
      ResizeGadget(#GADGET_LIST_IMAGE, (GadgetWidth(#GADGET_LIST_CONTAINER)-100)/2, GadgetHeight(#GADGET_LIST_CONTAINER)-100, #PB_Ignore, #PB_Ignore)
      ProcedureReturn #True
    EndIf  
  EndIf  
  
  
  
  If Message = #WM_CTLCOLORSTATIC 
    If GetProp_(lParam, "player")
      If Design_BK_Color <> -1
        SetBkMode_(wParam, #TRANSPARENT)
        
        If g_TrackBarBkColorBrush = #Null
          g_TrackBarBkColorBrush = CreateSolidBrush_(Design_BK_Color)  ; ACHTUNG!, wird bisher nicht wieder freigegeben!
        EndIf
        ProcedureReturn g_TrackBarBkColorBrush          
      EndIf        
    EndIf   
    
    If GetProp_(lParam, "passwordCheckBox")
      SetBkMode_(wParam, #TRANSPARENT)
      ProcedureReturn GetStockObject_(#WHITE_BRUSH)              
    EndIf       
  EndIf   
  
  If Message = #WM_NOTIFY
    *pnmhdr.NMHDR = lParam      
    If *pnmhdr
      If *pnmhdr\code = #NM_CUSTOMDRAW And *pnmhdr\hwndFrom And GetProp_(*pnmhdr\hwndFrom, "tbskinned")
        
        *tbcd.NMCUSTOMDRAW = lParam
        
        result = #CDRF_DODEFAULT
        Select *tbcd\dwDrawStage
          Case #CDDS_PREPAINT
            result = #CDRF_NOTIFYITEMDRAW
          Case #CDDS_ITEMPREPAINT
            If IsImage(#SPRITE_TRACKBAR_LEFT) And IsImage(#SPRITE_TRACKBAR_RIGHT) And IsImage(#SPRITE_TRACKBAR_MIDDLE) And IsImage(#SPRITE_TRACKBAR_THUMB_DISABLED) And IsImage(#SPRITE_TRACKBAR_THUMB_SELECTED) And IsImage(#SPRITE_TRACKBAR_THUMB)
              If *tbcd\dwItemSpec = #TBCD_CHANNEL
                ;DrawEdge_(*tbcd\hDC, *tbcd\rc, #EDGE_SUNKEN, #BF_RECT)
                chRc.RECT
                chRc\Left = *tbcd\rc\Left
                chRc\top = *tbcd\rc\top - 3;+ 3
                chRc\Right = *tbcd\rc\Right
                chRc\bottom = *tbcd\rc\bottom + 3 ; - 3
                
                offset = chRc\bottom - chRc\top
                
                DrawIconEx_(*tbcd\hDC, chRc\Left,chRc\Top , ImageID(#SPRITE_TRACKBAR_LEFT), offset, chRc\bottom-chRc\top, #False,#Null, #DI_NORMAL)
                DrawIconEx_(*tbcd\hDC, chRc\Right - offset,chRc\Top , ImageID(#SPRITE_TRACKBAR_RIGHT), offset, chRc\bottom-chRc\top, #False,#Null, #DI_NORMAL)                             
                DrawIconEx_(*tbcd\hDC, chRc\Left + offset,chRc\Top, ImageID(#SPRITE_TRACKBAR_MIDDLE), chRc\right-chRc\Left- offset* 2, chRc\bottom-chRc\top,#False,#Null, #DI_NORMAL)
                
                result = #CDRF_SKIPDEFAULT
              EndIf
              
              If *tbcd\dwItemSpec = #TBCD_THUMB
                
                width = *tbcd\rc\bottom - *tbcd\rc\Top
                height = *tbcd\rc\right - *tbcd\rc\left
                
                If height < width
                  width = height
                EndIf
                
                midX = (*tbcd\rc\right + *tbcd\rc\left)/2
                midY = (*tbcd\rc\bottom + *tbcd\rc\top)/2                                 
                
                
                If *pnmhdr\hwndFrom And IsWindowEnabled_(*pnmhdr\hwndFrom) = #False ;*tbcd\uItemState & #CDIS_DEFAULT does not work
                  DrawIconEx_(*tbcd\hDC, midX - width/2 ,midY - width/2, ImageID(#SPRITE_TRACKBAR_THUMB_DISABLED), width, width,#False,#Null, #DI_NORMAL)                 
                Else                 
                  If *tbcd\uItemState & #CDIS_SELECTED
                    DrawIconEx_(*tbcd\hDC, midX - width/2 ,midY - width/2, ImageID(#SPRITE_TRACKBAR_THUMB_SELECTED), width, width,#False,#Null, #DI_NORMAL)
                  Else
                    DrawIconEx_(*tbcd\hDC, midX - width/2 ,midY - width/2, ImageID(#SPRITE_TRACKBAR_THUMB), width, width,#False,#Null, #DI_NORMAL) 
                  EndIf              
                EndIf
                
                result = #CDRF_SKIPDEFAULT
              EndIf
            EndIf
            
            If *tbcd\dwItemSpec = #TBCD_TICS
              result = #CDRF_DODEFAULT
            EndIf
        EndSelect
      EndIf 
    EndIf
  EndIf  
  
  ;Close Main window in callback because of a PB bug in EventWindow()!
  If Message = #WM_CLOSE
    If IsWindow(#WINDOW_MAIN)
      If WindowID=WindowID(#WINDOW_MAIN)
        WriteLog("exit application though #WM_CLOSE in Callback", #LOGLEVEL_DEBUG)
        iQuit=#True
      EndIf
    EndIf
  EndIf
  
  ;ThumbButtons können nicht mit PB Events abgefragt werden.
  If Message = #WM_COMMAND
    Select wParam&$FFFF
      Case #GADGET_TB_PREVIOUS
        RunCommand(#COMMAND_PREVIOUSTRACK)
      Case #GADGET_TB_NEXT
        RunCommand(#COMMAND_NEXTTRACK)
      Case #GADGET_TB_PLAY
        RunCommand(#COMMAND_PLAY)
    EndSelect 
  EndIf  
  
  ProcedureReturn result
EndProcedure

Procedure RestoreDatabase(Restart = #True, ask=#True)
  Protected sTempFile.s, iDBFile
  CreateDirectory(GetPathPart(sDataBaseFile))
  sTempFile.s = sDataBaseFile+".temp_"+Hex(Random($FFFF))
  iDBFile = CreateFile(#PB_Any, sTempFile)
  If IsFile(iDBFile)
    WriteData(iDBFile, ?DS_SQLDataBase, ?DS_EndSQLDataBase-?DS_SQLDataBase)
    CloseFile(iDBFile)
    DeleteFile(sDataBaseFile)
    If CopyFile(sTempFile, sDataBaseFile)
      SetDefaultLng()
      WriteLog("Created new Database!")
      If Restart
        If ask=#False Or MessageRequester(Language(#L_OPTIONS), Language(#L_CHANGES_NEEDS_RESTART) + #CRLF$ + Language(#L_WANTTORESTART), #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes
          DeleteFile(sTempFile)
          RestartPlayer()
        EndIf
      EndIf
    Else
      If Language(#L_OPTIONS)<>""
        MessageRequester(Language(#L_OPTIONS), Language(#L_CANT_REPLACE_DB), #MB_ICONERROR)
      Else
        MessageRequester("Error", "Can not replace the database!", #MB_ICONERROR)
      EndIf  
      WriteLog("Can't create new Database!")           
    EndIf
    DeleteFile(sTempFile)
  Else
    If Language(#L_OPTIONS)<>""
      MessageRequester(Language(#L_OPTIONS), Language(#L_CANT_REPLACE_DB), #MB_ICONERROR)
    Else
      MessageRequester("Error", "Can not replace the database!", #MB_ICONERROR)
    EndIf  
    WriteLog("Can't create new Database!")
  EndIf
  
EndProcedure

Procedure IsMutexAlreadyUsed(sMutex.s)
  Protected hMutex
  hMutex = CreateMutex_(#Null, #Null, sMutex) 
  If (hMutex <> #Null) And (GetLastError_() = #ERROR_ALREADY_EXISTS)
    CloseHandle_(hMutex)
    hMutex = #Null
  EndIf
  
  If hMutex
    CloseHandle_(hMutex)
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
EndProcedure    


Procedure ShowText(title.s,text.s, column1.s, column2.s)
  Protected wnd, ev, editor, count, i, oldlen
  wnd=OpenWindow(#PB_Any, 0, 0, 620, 400, title, #PB_Window_SystemMenu | #PB_Window_MaximizeGadget| #PB_Window_ScreenCentered| #PB_Window_SizeGadget)
  If wnd
    StickyWindow(wnd,#True)
    If GetModuleHandle_("UxTheme.dll")
      If GetProcAddress_(GetModuleHandle_("uxtheme.dll"), "SetWindowTheme")
        CallFunctionFast(GetProcAddress_(GetModuleHandle_("UxTheme.dll"), "SetWindowTheme"),WindowID(wnd), @" ", @" ")
      EndIf
    EndIf
    SetWindowColor(wnd, RGB(0,0,196))
    editor=ListIconGadget(#PB_Any, 4, 4, 680-8, 880-8,column1,200, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection);EditorGadget(#PB_Any, 4, 4, 680-8, 880-8,#PB_Editor_ReadOnly)
    SetGadgetColor(editor,   #PB_Gadget_BackColor , RGB(210,210,210))
    SetGadgetColor(editor,  #PB_Gadget_FrontColor, RGB(0,0,128))
    
    AddGadgetColumn(editor, 1, column2, 1024)
    SetGadgetFont(editor, GetStockObject_(#SYSTEM_FIXED_FONT))
    
    text = ReplaceString(text, #LF$, #CR$)
    Repeat
      oldlen = Len(text)
      text = ReplaceString(text, Chr(9)+Chr(9), Chr(9))
    Until oldlen = Len(text)
    text = ReplaceString(text, Chr(9), Chr(10))    
    
    count = CountString(text, #CR$)
    For i=1 To count+1
      AddGadgetItem(editor, -1, StringField(text, i, #CR$))
    Next
    
    Repeat   
      ev = WaitWindowEvent(16)
      ;         If ev = #PB_Event_SizeWindow ;Does not work perfectly!!!
      ;           If EventWindow() = wnd
      ;             ResizeGadget(editor,5,5,WindowWidth(wnd)-10, WindowHeight(wnd)-10)
      ;           EndIf  
      ;         EndIf 
      
      
      If ev =  #PB_Event_Gadget
        If EventType() = #PB_EventType_LeftDoubleClick
          If EventGadget() = editor
            If Trim(GetGadgetItemText(editor, GetGadgetState(editor))) <> ""
              SetClipboardText(Trim(GetGadgetItemText(editor, GetGadgetState(editor))))
              MessageRequester(#PLAYER_NAME,"The following was copied to the clipboard: " + Chr(#LF)+ Chr(34) + Trim(GetGadgetItemText(editor, GetGadgetState(editor))) + Chr(34), #MB_ICONINFORMATION)
            EndIf  
          EndIf  
        EndIf
      EndIf  
      If (GadgetWidth(editor) <> WindowWidth(wnd)-8) Or (GadgetHeight(editor) <> WindowHeight(wnd)-8)
        ResizeGadget(editor,4,4,WindowWidth(wnd)-8, WindowHeight(wnd)-8)
      EndIf  
    Until ev = #PB_Event_CloseWindow
  EndIf
EndProcedure

Procedure.s GetCommandHelp()
  Protected sText.s
  sText.s = #PLAYER_NAME + Chr(9) + "- Version: " + #PLAYER_VERSION + " Build:" + Str(#PB_Editor_Buildcount)+ #LF$
  
  CompilerIf #USE_OEM_VERSION = #False
    sText.s + Chr(9) + #PLAYER_COPYRIGHT + #LF$
  CompilerEndIf
  
  sText + ReplaceString(Space(32)," ", "=") + #LF$ 
  sText + "Possible parameters:" + #LF$
  sText + #LF$
  sText + "/? /help /h "   + Chr(9) + Chr(9) + "shows this help" + #LF$
  sText + "/aspect     "   + Chr(9) + Chr(9) + Chr(9) + "predefines aspect ratio (16:9, 21:9, ...)" + #LF$ 
  sText + "/fullscreen "   + Chr(9) + Chr(9) + "starts in fullscreen" + #LF$     
  sText + "/volume     "   + Chr(9) + Chr(9) + "predefines volume (0 - 100)" + #LF$ 
  sText + "/password   "   + Chr(9) + Chr(9) + "predefines password" + #LF$ 
  sText +        Chr(9)    + Chr(9) + Chr(9) +  "use " + Chr(34) + " if it contains spaces" + #LF$ 
  sText + "/hidden     "   + Chr(9) + Chr(9) + "starts player invisible (or /invisible)" + #LF$     
  sText + "/database   "   + Chr(9) + Chr(9) + "use alternative database file" + #LF$    
  sText +        Chr(9)    + Chr(9) + Chr(9) +  " use [APPDATA],[DESKTOP]," + #LF$   
  sText +        Chr(9)    + Chr(9) + Chr(9) +  "[DOCUMENTS],[HOME],[TEMP]," + #LF$  
  sText +        Chr(9)    + Chr(9) + Chr(9) +  "and [PROGRAM] for predefined paths" + #LF$    
  sText + "/importlist "   + Chr(9) + Chr(9) +  "imports a playlist permanently" + #LF$       
  sText + "/loglevel   "   + Chr(9) + Chr(9) + Chr(9) +  "predefine loglevel" + #LF$     
  sText +        Chr(9)    + Chr(9) + Chr(9) +  "use 0(None), 1(Error) and 2(Debug)" + #LF$        
  sText + "/restoredatabase"   + Chr(9) + Chr(9) +  "restore default database" + #LF$ 
  
  sText + "/videorenderer"   + Chr(9) + Chr(9) +  "predefines video renderer" + #LF$
  sText +        Chr(9)    + Chr(9) + Chr(9) +  "0(Def.), 1(VMR9), 2(VMR7), 3(Old-Rend.)," + #LF$  
  sText +        Chr(9)    + Chr(9) + Chr(9) +  "4(Overlay),5(DShow Def.), 6(VMR9-Wnd)," + #LF$  
  sText +        Chr(9)    + Chr(9) + Chr(9) +  "7(VMR7-Wnd), 8(Own Rend.)" + #LF$  
  
  sText + "/audiorenderer" + Chr(9) + Chr(9) + "predefines audio renderer" + #LF$
  sText +  Chr(9) + Chr(9)    + Chr(9) +  "0(Def.), 1(Waveout), 2(DSound)" + #LF$      
  
  sText + "/closeafterplayback"  + Chr(9)  + Chr(9) +  "close player after playback of the first media file" + #LF$    
  sText + "/usedesign"   + Chr(9) + Chr(9) +  "sets the used design" + #LF$    
  sText + "/installdesign"   + Chr(9) + Chr(9) +  "installs a new design" + #LF$  
  sText + "/ahook"  + Chr(9)  + Chr(9) + Chr(9) +  "uses alternative hooking" + #LF$  
  sText + "/disablehook"   + Chr(9) + Chr(9) +  "disables hooking" + #LF$  
  sText + "/disablemenu"    + Chr(9)+ Chr(9) +  "hides the menu" + #LF$  
  sText + "/deletestreamingcache"   + Chr(9) +  "delets the streaming cache" + #LF$  
  sText + "/proxyip"   + Chr(9) + Chr(9) + Chr(9) +  "sets the proxy ip" + #LF$  
  sText + "/proxyport"   + Chr(9) + Chr(9) +  "sets the proxy port" + #LF$  
  sText + "/useiesettings"   + Chr(9) + Chr(9) +  "uses the ie settings for proxy" + #LF$  
  sText + "/proxybypasslocal"   + Chr(9) + Chr(9) +  "proxy bypass local" + #LF$  
  sText + "/noredirect"   + Chr(9) + Chr(9) +  "no redirect" + #LF$  
  sText + "/passwordfile"    + Chr(9)+ Chr(9) +  "reads the password out of an file" + #LF$  
  sText + "/disablestreaming"  + Chr(9)  + Chr(9) +  "disables the streaming" + #LF$  
  sText + "/passwordpipe"    + Chr(9)+ Chr(9) +  "reads the password out of an rsa encrypted pipe" + #LF$  
  sText + "/position"  + Chr(9) + Chr(9)  + Chr(9) +  "set the start position of the video" + #LF$  
  sText + "/morehelp"  + Chr(9) + Chr(9)  +  "shows more command line option" + #LF$      
  ProcedureReturn sText
EndProcedure  

Procedure ShowCommandHelp()      
  MessageRequester(#PLAYER_NAME, GetCommandHelp(), #MB_ICONINFORMATION)
EndProcedure  

Procedure ShowCommandHelp2()      
  Protected text.s = GetCommandHelp()
  text = ReplaceString(text, "shows this help", "shows a simple help dialog")
  text = text +  "/encryption" +Chr(9) + "same as /password"+#LF$
  text = text +  "/invisible" +Chr(9) + "same as /hidden"+#LF$
  text = text +  "/showmsgcheck" +Chr(9) + "shows a message dialog at startup with the possibility check 'do not show this again'. /showmsgcheck title text"+#LF$
  text = text +  "/showmsgbox" +Chr(9) + "shows a message dialog at startup. /showmsgbox title text"+#LF$
  text = text +  "/terminatenow" +Chr(9) + "terminates the player as soon as this parameter is read"+#LF$  
  text = text +  "/disablelavfilters" +Chr(9) + "disables download and usage of lav filters (codecs)"+#LF$   
  text = text +  "/codecdownload" +Chr(9) + "just download and install codecs."+#LF$
  text = text +  "/invisiblecodecdownload" +Chr(9) + "do not show a window when downloading codecs"+#LF$
  text = text +  "/deletelavfilters" +Chr(9) + "removes installed lav filters (codecs)"+#LF$
  text = text +  "/protectprocess" +Chr(9) + "protects the process from other processes"+#LF$
  text = text +  "/dlltmpregister" +Chr(9) + "registers a dll at startup (for current user only) and unregisters it when closing the application. Note: only one dll is supported"+#LF$
  text = text +  "/dllregister" +Chr(9) + "registers a dll at startup (for current user only)"+#LF$
  text = text +  "/dllunregister" +Chr(9) + "unregisters a dll at startup (for current user only)"+#LF$
  text = text +  "/delaystart" +Chr(9) + "wait the declared amount of milli seconds before the player starts"+#LF$
  text = text +  "/hidedrm" +Chr(9) + "hides the DRM menu entry"            
  
  ShowText(#PLAYER_NAME, text, "Parameter", "Description")
EndProcedure  


Global exeAttachCommands.s=""
Procedure.s _ProgramParameter()
  Protected FileStruc.EXE_ATTACHMENT_FILEENTRY, *mem, i.i, c.s, InQuote=#False, seperate=#False
  Protected result.s = ProgramParameter()
  
  If result=""
    If exeAttachCommands="*END*"
      ProcedureReturn ""
    EndIf  
    If exeAttachCommands=""
      If OpenEXEAttachements(ProgramFilename())
        If ReadEXEAttachmentByName("*COMMANDS*", FileStruc)
          *mem = ExtractEXEAttachmentToMem("*COMMANDS*")
          If *mem
            exeAttachCommands = Trim(PeekS(*mem))
          EndIf  
        EndIf
      EndIf
    EndIf  
    If exeAttachCommands<>""
      i.i=1
      Repeat
        c.s=Mid(exeAttachCommands,i,1)
        If c.s=Chr(34) And InQuote=#True
          seperate=#True
        EndIf          
        If c.s=Chr(34) And InQuote=#False
          InQuote=#True
        EndIf  
        If c.s=" " And InQuote=#False
          seperate=#True
        EndIf  
        If i=Len(exeAttachCommands)
          i=i
          seperate=#True
        EndIf  
        If seperate=#True
          result=Trim(RemoveString(Mid(exeAttachCommands,1,i),Chr(34)))
          exeAttachCommands=Trim(Mid(exeAttachCommands,i+1))
          If exeAttachCommands=""
            exeAttachCommands="*END*"
          EndIf  
        EndIf  
        i=i+1
      Until seperate=#True
    EndIf
  EndIf  
  ProcedureReturn result
EndProcedure  



;Die compiler option "Request User mode for Windows Vista (no virtualisation)" sollte angehakt werden, da unter vista ansonsten ffdshow.ax bei zumindest einem video crasht! (vista-crash-ffdshow-ax-without-user-mode.avi)
#MENU_MODERNLOOK_COLOR = $909090
Global _g_menu_imp__GetSysColor= #Null , _g_menu_new_imp_GetSysColor= #Null, _g_menu_real_GetSysColor = #Null
Procedure __MyGetSysColor(idx)
  If idx = 13
    ProcedureReturn #MENU_MODERNLOOK_COLOR
  EndIf
  If _g_menu_real_GetSysColor
    ProcedureReturn CallFunctionFast(_g_menu_real_GetSysColor,idx)
  EndIf 
  ProcedureReturn (idx + 1)&1 * $FFFFFF ; Schwarzweiss notlösung
EndProcedure  





;}
;{ Windows
Procedure CreateMainWindow()
  Protected ifont1.i, sLanguages.s, i.i
  Protected WinX.i, WinY.i, WinW.i, WinH.i
  
  WinX = Val(Settings(#SETTINGS_WINDOW_X)\sValue)
  WinY = Val(Settings(#SETTINGS_WINDOW_Y)\sValue)
  WinW = 360;Val(Settings(#SETTINGS_WINDOW_WIDTH)\sValue)
  WinH = 105;Val(Settings(#SETTINGS_WINDOW_HEIGHT)\sValue)
  
  ;EDIT:
  If StartParams\iDisableMenu=#False
    WinH + MenuHeight()
  EndIf
  
  If GetUsedDesktopXYWH(WinX, WinY, WinW, WinH)=-1
    WinX = 0
    WinY = 0
  EndIf
  
  
  
  OpenWindow(#WINDOW_MAIN, WinX, WinY, WinW, WinH, #PLAYER_NAME, #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget)   
  ;SetWindowColor(#WINDOW_MAIN, Val(Settings(#SETTINGS_WINDOW_BK_COLOR)\sValue))
  SmartWindowRefresh(#WINDOW_MAIN, #True) 
  EnableWindowDrop(#WINDOW_MAIN, #PB_Drop_Files, #PB_Drag_Copy)
  ;SetForegroundWindow_(WindowID(#WINDOW_MAIN))
  
  AddSysTrayIcon(#SYSTRAY_MAIN, WindowID(#WINDOW_MAIN), ImageID(#SPRITE_SYSTRAY))
  SysTrayIconToolTip(#SYSTRAY_MAIN, #PLAYER_NAME)
  ;     If CreatePopupImageMenu(#MENU_SYSTRAY, #PB_Menu_ModernLook)
  ;       __MenuItem(#MENU_PLAY, Language(#L_PLAY)+"/"+Language(#L_BREAK), ImageID(#SPRITE_MENU_PLAY))
  ;       __MenuItem(#MENU_STOP, Language(#L_STOP), ImageID(#SPRITE_MENU_STOP))
  ;       __MenuItem(#MENU_FORWARD, Language(#L_NEXT), ImageID(#SPRITE_MENU_FORWARD))
  ;       __MenuItem(#MENU_BACKWARD, Language(#L_PREVIOUS), ImageID(#SPRITE_MENU_BACKWARD))
  ;       MenuBar()
  ;       __MenuItem(#MENU_SHOW, Language(#L_SHOW)+"/"+Language(#L_HIDE), ImageID(#SPRITE_MENU_ABOUT))
  ;       __MenuItem(#MENU_QUIT, Language(#L_QUIT), ImageID(#SPRITE_MENU_END))
  ;     EndIf
  
  
  
  *thumbButtons=TB_Create()
  If *thumbButtons
    TB_SetProgressState(*thumbButtons, WindowID(#WINDOW_MAIN), #tbpf_noprogress)
    
    
    ThumbButtons(0)\iId=#GADGET_TB_PREVIOUS
    ThumbButtons(0)\dwMask = #THB_ICON
    ThumbButtons(0)\hIcon = ImageID(#SPRITE_MENU_BACKWARD);LoadIcon_(0,101)
    
    ThumbButtons(1)\iId=#GADGET_TB_PLAY
    ThumbButtons(1)\dwMask = #THB_ICON
    ThumbButtons(1)\hIcon = ImageID(#SPRITE_MENU_PLAY)
    
    ThumbButtons(2)\iId=#GADGET_TB_NEXT
    ThumbButtons(2)\dwMask = #THB_ICON
    ThumbButtons(2)\hIcon = ImageID(#SPRITE_MENU_FORWARD)
    
    TB_AddButtons(*thumbButtons, WindowID(#WINDOW_MAIN), 3, @ThumbButtons())
  EndIf
  
  
  
  If StartParams\iDisableMenu=#False
    CompilerIf #USE_OEM_VERSION;2010-04-16
      If CreateMenu(#MENU_MAIN, WindowID(#WINDOW_MAIN))
        ;If CreateImageMenu(#MENU_MAIN, WindowID(#WINDOW_MAIN))
      CompilerElse
        If CreateImageMenu(#MENU_MAIN, WindowID(#WINDOW_MAIN), #PB_Menu_ModernLook)
        CompilerEndIf
        CompilerIf #USE_ONLY_ABOUT_MENU=#False  
          MenuTitle(Language(#L_FILE))
          __MenuItem(#MENU_LOAD, Language(#L_LOAD)+Chr(9)+"Ctrl+O", ImageID(#SPRITE_MENU_LOAD))
          __MenuItem(#MENU_LOADCLIPBOARD, Language(#L_OPENFILEFROMCLIPBOARD)+Chr(9)+"Ctrl+V", ImageID(#SPRITE_MENU_CLIPBOARD))
          
          __MenuItem(#MENU_LOADURL, Language(#L_LOADURL), ImageID(#SPRITE_MENU_EARTH))
          __MenuItem(#MENU_PLAYLIST, Language(#L_PLAYLIST)+Chr(9)+"Ctrl+P", ImageID(#SPRITE_MENU_PLAYLIST))
          
          OpenSubMenu(Language(#L_MOST_RECENT_LIST))
          __MenuItem(#MENU_CHRONIC_CLEAR, Language(#L_CLEAR_CHRONIC), ImageID(#SPRITE_MENU_BRUSH))
          MenuBar()
          For i=0 To 9
            __MenuItem(#MENU_CHRONIC_1+i, "-", ImageID(#SPRITE_MENU_PLAYFILE ))
          Next
          CloseSubMenu()
          CompilerIf #USE_OEM_VERSION=#False   
            MenuBar()
          CompilerEndIf  
          
          
          __MenuItem(#MENU_PLAYMEDIA, Language(#L_PLAYMEDIA), ImageID(#SPRITE_MENU_PLAYMEDIA))
          __MenuItem(#MENU_AUDIOCD, Language(#L_PLAYAUDIOCD), ImageID(#SPRITE_MENU_PLAYAUDIOCD))
          __MenuItem(#MENU_VIDEODVD, Language(#L_PLAYVIDEODVD), ImageID(#SPRITE_MENU_PLAYDVD))
          CompilerIf #USE_OEM_VERSION=#False   
            MenuBar()
          CompilerEndIf  
          __MenuItem(#MENU_OPTIONS, Language(#L_OPTIONS), ImageID(#SPRITE_MENU_OPTIONS))
          MenuBar()
          __MenuItem(#MENU_QUIT, Language(#L_QUIT)+Chr(9)+"Ctrl+Q", ImageID(#SPRITE_MENU_END))
          
          MenuTitle(Language(#L_MEDIA))
          ;__MenuItem(#MENU_LOAD, Language(#L_LOAD)+Chr(9)+"Ctrl+O", ImageID(#SPRITE_MENU_LOAD))
          __MenuItem(#MENU_PLAYLIST, Language(#L_PLAYLIST)+Chr(9)+"Ctrl+P", ImageID(#SPRITE_MENU_PLAYLIST))
          __MenuItem(#MENU_VIS_COVERFLOW, Language(#L_COVERFLOW), ImageID(#SPRITE_MENU_COVERFLOW))
          MenuBar()
          OpenSubMenu(Language(#L_ASPECTRATION))
          __MenuItem(#MENU_ASPECTATION_AUTO, Language(#L_AUTOMATIC));, ImageID(#SPRITE_MENU_ACTION))
          __MenuItem(#MENU_ASPECTATION_1_2, "1:2")                  ;, ImageID(#SPRITE_MENU_ACTION))
          __MenuItem(#MENU_ASPECTATION_1_1, "1:1")                  ;, ImageID(#SPRITE_MENU_ACTION))
          __MenuItem(#MENU_ASPECTATION_5_4, "5:4")                  ;, ImageID(#SPRITE_MENU_ACTION))
          __MenuItem(#MENU_ASPECTATION_4_3, "4:3")                  ;, ImageID(#SPRITE_MENU_ACTION))
          __MenuItem(#MENU_ASPECTATION_16_10, "16:10")              ;, ImageID(#SPRITE_MENU_ACTION))
          __MenuItem(#MENU_ASPECTATION_16_9, "16:9")                ;, ImageID(#SPRITE_MENU_ACTION))
          __MenuItem(#MENU_ASPECTATION_2_1, "2:1")                  ;, ImageID(#SPRITE_MENU_ACTION))
          __MenuItem(#MENU_ASPECTATION_21_9, "21:9")                ;, ImageID(#SPRITE_MENU_ACTION))
          
          
          SetMenuItemState(#MENU_MAIN, #MENU_ASPECTATION_AUTO, GetMenuItemState(#MENU_MAIN, #MENU_ASPECTATION_AUTO)!1)   
          CloseSubMenu()
          MenuBar()
          __MenuItem(#MENU_PLAY, Language(#L_PLAY)+"/"+Language(#L_BREAK)+Chr(9)+"Alt+P", ImageID(#SPRITE_MENU_PLAY))
          __MenuItem(#MENU_STOP, Language(#L_STOP)+Chr(9)+"Alt+S", ImageID(#SPRITE_MENU_STOP))
          __MenuItem(#MENU_FORWARD, Language(#L_NEXT)+Chr(9)+"Alt+N", ImageID(#SPRITE_MENU_FORWARD))
          __MenuItem(#MENU_BACKWARD, Language(#L_PREVIOUS)+Chr(9)+"Alt+V", ImageID(#SPRITE_MENU_BACKWARD))
          MenuBar()
          __MenuItem(#MENU_SAVE_MEDIAPOS, Language(#L_SAVE_MEDIAPOS), ImageID(#SPRITE_MENU_SAVE))
          __MenuItem(#MENU_SNAPSHOT, Language(#L_SNAPSHOT)+Chr(9)+"Ctrl+S", ImageID(#SPRITE_MENU_SNAPSHOT))
          
          
          MenuTitle(Language(#L_DRAWING))
          ;__MenuItem(#MENU_VIS, Language(#L_VISUALIZATION))
          OpenSubMenu(Language(#L_VISUALIZATION))
          __MenuItem(#MENU_VIS_OFF, Language(#L_OFF))
          __MenuItem(#MENU_VIS_SIMPLE, "Waveform")
          __MenuItem(#MENU_VIS_DCT, "frequency")
          __MenuItem(#MENU_VIS_WHITELIGHT, "Whitelight")
          SetMenuItemState(#MENU_MAIN, #MENU_VIS_OFF, #True) 
          VIS_FindExternVIS()
          CloseSubMenu()
          MenuBar()
          __MenuItem(#MENU_MINIMALMODE, Language(#L_MINIMALMODE)+Chr(9)+"H", ImageID(#SPRITE_MENU_MINIMALMODE))
          __MenuItem(#MENU_FULLSCREEN, Language(#L_FULLSCREEN)+Chr(9)+"Ctrl+F", ImageID(#SPRITE_MENU_MONITOR))
          MenuBar()
          __MenuItem(#MENU_STAYONTOP, Language(#L_STAYONTOP))
          
          CompilerIf #USE_DRM 
            If iUseDRMMenu  
              CompilerIf #USE_OEM_VERSION=#False  
                MenuTitle(Language(#L_DRM))
                __MenuItem(#MENU_PROTECTVIDEO, Language(#L_PROTECTVIDEO), ImageID(#SPRITE_MENU_TRESOR))
                ;                __MenuItem(#MENU_UNPROTECTVIDEO, Language(#L_UNPROTECTVIDEO), ImageID(#SPRITE_MENU_KEY))
                MenuBar()
                __MenuItem(#MENU_ERASEPASSWORDS, Language(#L_ERASEPASSWORDS), ImageID(#SPRITE_MENU_BRUSH))
              CompilerEndIf
            EndIf
          CompilerEndIf
        CompilerEndIf
        
        MenuTitle("?")
        CompilerIf #USE_OEM_VERSION=#False   
          __MenuItem(#MENU_DOCUMENTATION, Language(#L_DOCUMENTATION)+Chr(9)+"F1", ImageID(#SPRITE_MENU_HELP))
          MenuBar()
        CompilerEndIf  
        
        ;MenuTitle(Language(#L_LANGUAGE))
        OpenSubMenu(Language(#L_LANGUAGE)) 
        sLanguages.s = GetAllLanguages(sDataBaseFile)
        iLanguageMenuItems.i = CountString(sLanguages, Chr(10))
        Global Dim LanguageMenu(iLanguageMenuItems)
        
        For i=1 To iLanguageMenuItems
          Select Mid(StringField(sLanguages, i, Chr(10)),1,2)
            Case "DE"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_GERMANY))
              
            Case "EN"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_ENGLISH))
              
            Case "FR"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_FRENCH))
              
            Case "TR"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_TURKISH))
              
            Case "NL"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_NETHERLANDS))
              
            Case "ES"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_SPAIN)) 
              
            Case "EL"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_GREEK))  
              
            Case "PT"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_PORTUGAL))  
              
            Case "IT"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_ITALIAN)) 
              
            Case "SV"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_SWEDEN))  
              
            Case "RU"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_RUSSIA))  
              
            Case "SR"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_SERBIA))  
              
            Case "BG"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_BULGARIA))  
              
            Case "FA"
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE_PERSIAN))                  
            Default
              __MenuItem(2000+i, StringField(sLanguages, i, Chr(10)), ImageID(#SPRITE_MENU_LANGUAGE))
              
          EndSelect
          LanguageMenu(i) = 2000+i
        Next
        CloseSubMenu()
        CompilerIf #USE_OEM_VERSION=#False   
          MenuBar()
        CompilerEndIf 
        
        CompilerIf #USE_OEM_VERSION=#False
          CompilerIf #USE_ONLY_ABOUT_MENU=#False  
            __MenuItem(#MENU_CHECKUPDATES, Language(#L_CHECKFORUPDATE), ImageID(#SPRITE_MENU_UPDATE))
            If ExeHasAttachedFiles 
              DisableMenuItem(#MENU_MAIN,#MENU_CHECKUPDATES,#True)
            EndIf  
          CompilerEndIf
          __MenuItem(#MENU_DOWNLOADCODECS, Language(#L_DOWNLOADCODECS), ImageID(#SPRITE_MENU_DOWNLOAD))
          __MenuItem(#MENU_HOMEPAGE, Language(#L_HOMEPAGE), ImageID(#SPRITE_MENU_HOMEPAGE))
          __MenuItem(#MENU_DONATE, Language(#L_DONATE), ImageID(#SPRITE_MENU_GIVEMONEY))
          MenuBar()
          
          
          
          __MenuItem(#MENU_ABOUT, Language(#L_ABOUT)+Chr(9)+"Shift+F1", ImageID(#SPRITE_MENU_ABOUT))
        CompilerEndIf
        
        
        CompilerIf #USE_OEM_VERSION=#False  
          __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Shift|#PB_Shortcut_F1, #MENU_ABOUT) 
          __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_F1, #MENU_DOCUMENTATION)
        CompilerEndIf
        
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control|#PB_Shortcut_O, #MENU_LOAD)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control|#PB_Shortcut_V, #MENU_LOADCLIPBOARD)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control|#PB_Shortcut_C, #MENU_COPYTOCLIPBOARD)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control|#PB_Shortcut_Q, #MENU_QUIT)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control|#PB_Shortcut_P, #MENU_PLAYLIST)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control|#PB_Shortcut_F, #MENU_FULLSCREEN)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Control|#PB_Shortcut_S, #MENU_SNAPSHOT)
        
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Alt|#PB_Shortcut_P, #MENU_PLAY)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Alt|#PB_Shortcut_S, #MENU_STOP)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Alt|#PB_Shortcut_N, #MENU_FORWARD)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Alt|#PB_Shortcut_V, #MENU_BACKWARD)
        
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_Space, #MENU_PLAY)
        __AddKeyboardShortcut(#WINDOW_MAIN, #PB_Shortcut_H, #MENU_MINIMALMODE)
        
      EndIf
    EndIf
    If CreateStatusBar(#STATUSBAR_MAIN, WindowID(#WINDOW_MAIN))
      ;SendMessage_(StatusBarID(#STATUSBAR_MAIN), #CCM_SETBKCOLOR, 0, 0) geht nur ohne XP skin 
      AddStatusBarField(250)
      AddStatusBarField(150)
      ;AddStatusBarField(50)
    EndIf
    If Settings(#SETTINGS_USE_STATUSBAR)\sValue="0"
      ShowWindow_(StatusBarID(#STATUSBAR_MAIN), #SW_HIDE)
    EndIf  
    
    
    
    
    WindowBounds(#WINDOW_MAIN, 460, Design_Container_Size+3+_StatusBarHeight(#STATUSBAR_MAIN), #PB_Ignore, Design_Container_Size+3+_StatusBarHeight(#STATUSBAR_MAIN)) ;$FFF
    ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, 0, 0)
    
    VIS_Init();Creates the Screen and the Container
    
    If Design_Container_Border=0
      ContainerGadget(#GADGET_CONTAINER, 0, 0, 350, Design_Container_Size, #PB_Container_BorderLess);#PB_Container_Single);#PB_Container_BorderLess
    Else
      ContainerGadget(#GADGET_CONTAINER, 0, 0, 350, Design_Container_Size, #PB_Container_Single);#PB_Container_BorderLess
    EndIf  
    
    If Design_BK_Color<>-1
      SetGadgetColor(#GADGET_CONTAINER, #PB_Gadget_BackColor, Design_BK_Color)
    EndIf  
    
    If UsedDPI>0
      ifont1 = LoadFont(#PB_Any, "Times New Roman", 32*96/UsedDPI) 
    Else
      ifont1 = LoadFont(#PB_Any, "Times New Roman", 32) 
    EndIf
    
    
    
    
    
    PlayerTrackBarGadget(#GADGET_TRACKBAR , DControlX(#GADGET_TRACKBAR), DControlY(#GADGET_TRACKBAR), DControlW(#GADGET_TRACKBAR), DControlH(#GADGET_TRACKBAR), 0, 10000, Design_Trackbar)
    iVolumeGadget = VolumeGadget(DControlX(#GADGET_VOLUME), DControlY(#GADGET_VOLUME), ifont1, 50)
    
    If Design_Buttons=0
      ImageGadget(#GADGET_BUTTON_BACKWARD   , DControlX(#GADGET_BUTTON_BACKWARD), DControlY(#GADGET_BUTTON_BACKWARD), DControlW(#GADGET_BUTTON_BACKWARD), DControlH(#GADGET_BUTTON_BACKWARD), ImageID(#SPRITE_BACKWARD))
      ImageGadget(#GADGET_BUTTON_FORWARD    , DControlX(#GADGET_BUTTON_FORWARD), DControlY(#GADGET_BUTTON_FORWARD), DControlW(#GADGET_BUTTON_FORWARD), DControlH(#GADGET_BUTTON_FORWARD), ImageID(#SPRITE_FORWARD))
      ImageGadget(#GADGET_BUTTON_PLAY       , DControlX(#GADGET_BUTTON_PLAY), DControlY(#GADGET_BUTTON_PLAY), DControlW(#GADGET_BUTTON_PLAY), DControlH(#GADGET_BUTTON_PLAY), ImageID(#SPRITE_PLAY))
      ImageGadget(#GADGET_BUTTON_PREVIOUS   , DControlX(#GADGET_BUTTON_PREVIOUS), DControlY(#GADGET_BUTTON_PREVIOUS), DControlW(#GADGET_BUTTON_PREVIOUS), DControlH(#GADGET_BUTTON_PREVIOUS), ImageID(#SPRITE_PREVIOUS))
      ImageGadget(#GADGET_BUTTON_STOP       , DControlX(#GADGET_BUTTON_STOP), DControlY(#GADGET_BUTTON_STOP), DControlW(#GADGET_BUTTON_STOP), DControlH(#GADGET_BUTTON_STOP), ImageID(#SPRITE_STOP))
      ImageGadget(#GADGET_BUTTON_NEXT       , DControlX(#GADGET_BUTTON_NEXT), DControlY(#GADGET_BUTTON_NEXT), DControlW(#GADGET_BUTTON_NEXT), DControlH(#GADGET_BUTTON_NEXT), ImageID(#SPRITE_NEXT))
      ImageGadget(#GADGET_BUTTON_SNAPSHOT   , DControlX(#GADGET_BUTTON_SNAPSHOT), DControlY(#GADGET_BUTTON_SNAPSHOT), DControlW(#GADGET_BUTTON_SNAPSHOT), DControlH(#GADGET_BUTTON_SNAPSHOT), ImageID(#SPRITE_SNAPSHOT))
      ImageGadget(#GADGET_BUTTON_REPEAT     , DControlX(#GADGET_BUTTON_REPEAT), DControlY(#GADGET_BUTTON_REPEAT), DControlW(#GADGET_BUTTON_REPEAT), DControlH(#GADGET_BUTTON_REPEAT), ImageID(#SPRITE_REPEAT))
      ImageGadget(#GADGET_BUTTON_RANDOM     , DControlX(#GADGET_BUTTON_RANDOM), DControlY(#GADGET_BUTTON_RANDOM), DControlW(#GADGET_BUTTON_RANDOM), DControlH(#GADGET_BUTTON_RANDOM), ImageID(#SPRITE_RANDOM))
      ImageGadget(#GADGET_BUTTON_FULLSCREEN , DControlX(#GADGET_BUTTON_FULLSCREEN), DControlY(#GADGET_BUTTON_FULLSCREEN), DControlW(#GADGET_BUTTON_FULLSCREEN), DControlH(#GADGET_BUTTON_FULLSCREEN), ImageID(#SPRITE_FULLSCREEN))
    EndIf
    
    If Design_Buttons=1;Blue iconset
      ButtonImageGadget(#GADGET_BUTTON_BACKWARD   , DControlX(#GADGET_BUTTON_BACKWARD), DControlY(#GADGET_BUTTON_BACKWARD), DControlW(#GADGET_BUTTON_BACKWARD), DControlH(#GADGET_BUTTON_BACKWARD), ImageID(#SPRITE_BACKWARD))
      ButtonImageGadget(#GADGET_BUTTON_FORWARD    , DControlX(#GADGET_BUTTON_FORWARD), DControlY(#GADGET_BUTTON_FORWARD), DControlW(#GADGET_BUTTON_FORWARD), DControlH(#GADGET_BUTTON_FORWARD), ImageID(#SPRITE_FORWARD))
      ButtonImageGadget(#GADGET_BUTTON_PLAY       , DControlX(#GADGET_BUTTON_PLAY), DControlY(#GADGET_BUTTON_PLAY), DControlW(#GADGET_BUTTON_PLAY), DControlH(#GADGET_BUTTON_PLAY), ImageID(#SPRITE_PLAY))
      ButtonImageGadget(#GADGET_BUTTON_PREVIOUS   , DControlX(#GADGET_BUTTON_PREVIOUS), DControlY(#GADGET_BUTTON_PREVIOUS), DControlW(#GADGET_BUTTON_PREVIOUS), DControlH(#GADGET_BUTTON_PREVIOUS), ImageID(#SPRITE_PREVIOUS))
      ButtonImageGadget(#GADGET_BUTTON_STOP       , DControlX(#GADGET_BUTTON_STOP), DControlY(#GADGET_BUTTON_STOP), DControlW(#GADGET_BUTTON_STOP), DControlH(#GADGET_BUTTON_STOP), ImageID(#SPRITE_STOP))
      ButtonImageGadget(#GADGET_BUTTON_NEXT       , DControlX(#GADGET_BUTTON_NEXT), DControlY(#GADGET_BUTTON_NEXT), DControlW(#GADGET_BUTTON_NEXT), DControlH(#GADGET_BUTTON_NEXT), ImageID(#SPRITE_NEXT))
      ButtonImageGadget(#GADGET_BUTTON_SNAPSHOT   , DControlX(#GADGET_BUTTON_SNAPSHOT), DControlY(#GADGET_BUTTON_SNAPSHOT), DControlW(#GADGET_BUTTON_SNAPSHOT), DControlH(#GADGET_BUTTON_SNAPSHOT), ImageID(#SPRITE_SNAPSHOT))
      ButtonImageGadget(#GADGET_BUTTON_REPEAT     , DControlX(#GADGET_BUTTON_REPEAT), DControlY(#GADGET_BUTTON_REPEAT), DControlW(#GADGET_BUTTON_REPEAT), DControlH(#GADGET_BUTTON_REPEAT), ImageID(#SPRITE_REPEAT), #PB_Button_Toggle)
      ButtonImageGadget(#GADGET_BUTTON_RANDOM     , DControlX(#GADGET_BUTTON_RANDOM), DControlY(#GADGET_BUTTON_RANDOM), DControlW(#GADGET_BUTTON_RANDOM), DControlH(#GADGET_BUTTON_RANDOM), ImageID(#SPRITE_RANDOM), #PB_Button_Toggle)
      ButtonImageGadget(#GADGET_BUTTON_FULLSCREEN , DControlX(#GADGET_BUTTON_FULLSCREEN), DControlY(#GADGET_BUTTON_FULLSCREEN), DControlW(#GADGET_BUTTON_FULLSCREEN), DControlH(#GADGET_BUTTON_FULLSCREEN), ImageID(#SPRITE_FULLSCREEN))
    EndIf
    ImageGadget(#GADGET_BUTTON_MUTE       , DControlX(#GADGET_BUTTON_MUTE), DControlY(#GADGET_BUTTON_MUTE), DControlW(#GADGET_BUTTON_MUTE), DControlH(#GADGET_BUTTON_MUTE), ImageID(#SPRITE_MENU_SOUND))
    
    If DControlHide(#GADGET_TRACKBAR):HideGadget(#GADGET_TRACKBAR, #True):EndIf
    If DControlHide(#GADGET_BUTTON_BACKWARD):HideGadget(#GADGET_BUTTON_BACKWARD, #True):EndIf
    If DControlHide(#GADGET_BUTTON_FORWARD):HideGadget(#GADGET_BUTTON_FORWARD, #True):EndIf
    If DControlHide(#GADGET_BUTTON_PLAY):HideGadget(#GADGET_BUTTON_PLAY, #True):EndIf
    If DControlHide(#GADGET_BUTTON_PREVIOUS):HideGadget(#GADGET_BUTTON_PREVIOUS, #True):EndIf
    If DControlHide(#GADGET_BUTTON_STOP):HideGadget(#GADGET_BUTTON_STOP, #True):EndIf
    If DControlHide(#GADGET_BUTTON_NEXT):HideGadget(#GADGET_BUTTON_NEXT, #True):EndIf
    If DControlHide(#GADGET_BUTTON_SNAPSHOT):HideGadget(#GADGET_BUTTON_SNAPSHOT, #True):EndIf
    If DControlHide(#GADGET_BUTTON_REPEAT):HideGadget(#GADGET_BUTTON_REPEAT, #True):EndIf
    If DControlHide(#GADGET_BUTTON_RANDOM):HideGadget(#GADGET_BUTTON_RANDOM, #True):EndIf
    If DControlHide(#GADGET_BUTTON_MUTE):HideGadget(#GADGET_BUTTON_MUTE, #True):EndIf
    If DControlHide(#GADGET_BUTTON_FULLSCREEN):HideGadget(#GADGET_BUTTON_FULLSCREEN, #True):EndIf
    If DControlHide(#GADGET_VOLUME):HideGadget(iVolumeGadget, #True):EndIf
    
    
    If IsGadget(#GADGET_BUTTON_BACKWARD):GadgetToolTip(#GADGET_BUTTON_BACKWARD, Language(#L_BACKWARD)):EndIf
    If IsGadget(#GADGET_BUTTON_FORWARD):GadgetToolTip(#GADGET_BUTTON_FORWARD, Language(#L_FORWARD)):EndIf
    If IsGadget(#GADGET_BUTTON_PLAY):GadgetToolTip(#GADGET_BUTTON_PLAY, Language(#L_PLAY)):EndIf
    If IsGadget(#GADGET_BUTTON_PREVIOUS):GadgetToolTip(#GADGET_BUTTON_PREVIOUS, Language(#L_PREVIOUS)):EndIf
    If IsGadget(#GADGET_BUTTON_STOP):GadgetToolTip(#GADGET_BUTTON_STOP, Language(#L_STOP)):EndIf
    If IsGadget(#GADGET_BUTTON_NEXT):GadgetToolTip(#GADGET_BUTTON_NEXT, Language(#L_NEXT)):EndIf
    If IsGadget(#GADGET_BUTTON_SNAPSHOT):GadgetToolTip(#GADGET_BUTTON_SNAPSHOT, Language(#L_SNAPSHOT)):EndIf
    If IsGadget(#GADGET_BUTTON_REPEAT):GadgetToolTip(#GADGET_BUTTON_REPEAT, Language(#L_REPEAT)):EndIf
    If IsGadget(#GADGET_BUTTON_RANDOM):GadgetToolTip(#GADGET_BUTTON_RANDOM, Language(#L_RANDOM)):EndIf
    If IsGadget(#GADGET_BUTTON_FULLSCREEN):GadgetToolTip(#GADGET_BUTTON_FULLSCREEN, Language(#L_FULLSCREEN)):EndIf
    
    
    GadgetToolTip(iVolumeGadget, Language(#L_VOLUME))
    
    
    CloseGadgetList()
    
    ACD_CreateContainer()
    VDVD_CreateContainer()
    
    If Design_BK_Color<>-1
      SetGadgetColor(#GADGET_VIDEODVD_CONTAINER, #PB_Gadget_BackColor, Design_BK_Color)
      SetGadgetColor(#GADGET_AUDIOCD_CONTAINER, #PB_Gadget_BackColor, Design_BK_Color)
    EndIf  
    
    If Design_Container_Border=0
      ContainerGadget(#GADGET_VIDEO_CONTAINER, 0, 0, 350, 5, #PB_Container_BorderLess);#PB_Container_Double)
    Else
      ContainerGadget(#GADGET_VIDEO_CONTAINER, 0, 0, 350, 5, #PB_Container_Double)
    EndIf  
    
    SetGadgetColor(#GADGET_VIDEO_CONTAINER, #PB_Gadget_BackColor, Val(Settings(#SETTINGS_BKCOLOR)\sValue))
    ;HideGadget(#GADGET_VIDEO_CONTAINER, #True)
    ;SetWindowColor(#WINDOW_MAIN, Val(Settings(#SETTINGS_BKCOLOR)\sValue))
    CloseGadgetList()
    
    
    
    ;2010-08-10 NEW CALLBACK POS
    SetWindowCallback(@CBMainWindow())
    
    ResizeWindow_(#WINDOW_MAIN, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    ProcessAllEvents()   
    
    
  EndProcedure
  Procedure CreateAboutWindow()
    If IsWindow(#WINDOW_ABOUT) = #False
      If IsImage(#SPRITE_ABOUT) And IsImage(#SPRITE_ABOUT_BK)
        WriteLog("Open About window", #LOGLEVEL_DEBUG)
        If OpenWindow(#WINDOW_ABOUT, 0, 0, 380, 422, #PLAYER_NAME+" "+#PLAYER_VERSION, #PB_Window_ScreenCentered|#PB_Window_SystemMenu)   
          SetWindowColor(#WINDOW_ABOUT, #White)
          
          StickyWindow(#WINDOW_ABOUT, #True)
          SmartWindowRefresh(#WINDOW_ABOUT, #True)
          ImageGadget(#GADGET_ABOUT_IMAGE, 30, 0, 320, 220, ImageID(#SPRITE_ABOUT))
          
          TreeGadget(#GADGET_ABOUT_BIGTEXT, 2, 220, 376, 200, #PB_Tree_NoButtons|#PB_Tree_NoLines) 
          SetExplorerTheme(GadgetID(#GADGET_ABOUT_BIGTEXT))
          SetTreeGadgetBkImage(GadgetID(#GADGET_ABOUT_BIGTEXT), WindowID(#WINDOW_ABOUT), #SPRITE_ABOUT_BK)
          
          If IsFont(#FONT_ABOUT_2)=#False:LoadFont(#FONT_ABOUT_2,"Segoe UI",12):EndIf
          If IsFont(#FONT_ABOUT_2)=#False:LoadFont(#FONT_ABOUT_2,"Tahoma",9,#PB_Font_Bold):EndIf
          If IsFont(#FONT_ABOUT_2)=#False:LoadFont(#FONT_ABOUT_2,"Comic Sans MS",9,#PB_Font_Bold):EndIf
          If IsFont(#FONT_ABOUT_2):SetGadgetFont(#GADGET_ABOUT_BIGTEXT,FontID(#FONT_ABOUT_2)):EndIf
          
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "GreenForce Player V"+#PLAYER_VERSION+" Build "+Str(#PB_Editor_BuildCount) + " "+FormatDate("%mm/%dd/%yyyy", #PB_Compiler_Date))
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "Feel the green force!")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "Team members:")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-RocketRider (Michael M�bius)")     
          
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "Thanks to:")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-Warkering (French language)")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-Saner Apaydin (Turkish language)")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-Carl Peeraer (Nederlands language)")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-Mauricio Cant�n Caamal (Spanish language)")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-Surena Karimpour (Persian language)")          
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-Jacobus (Green iconset)")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-Xiph.org Foundation (Ogg and flac decoder)")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-Independent JPEG Group(this software is based in part on the work of the Independent JPEG Group)")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-OpenJPEG(for the JPEG2000 codec)")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "-LAV Filters(for multimedia codecs)")          
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "Special thanks to all users and beta-testers!")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "http://GFP.RRSoftware.de")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "Support@GFP.RRSoftware.de")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "")
          
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "Source code:")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "https://github.com/RocketRider/GreenForce-Player")     
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "")           
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "Copyright (c) 2009-2017 RocketRider")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "This software is provided 'as-is',")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "without any express or implied warranty.")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "In no event will the authors be held")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "liable for any damages arising")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "from the use of this software.")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "OpenJPEG")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "Copyright (c) 2002-2012, Communications and Remote Sensing Laboratory, Universite catholique de Louvain (UCL), Belgium Copyright (c) 2002-2012, Professor Benoit Macq Copyright (c) 2003-2012, Antonin Descampe Copyright (c) 2003-2009, Francois-Olivier Devaux Copyright (c) 2005, Herve Drolon, FreeImage Team Copyright (c) 2002-2003, Yannick Verschueren Copyright (c) 2001-2003, David Janssens All rights reserved. ")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.")
          AddGadgetItem(#GADGET_ABOUT_BIGTEXT, -1, "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS `AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.")
          
        Else
          WriteLog("Can't open about window!")
        EndIf
      EndIf
    Else
      ShowWindow_(WindowID(#WINDOW_ABOUT), #SW_SHOWNORMAL)
      SetActiveWindow(#WINDOW_ABOUT)
    EndIf
  EndProcedure
  Procedure CreateListWindow()
    Protected hTB, hOldIList, hNewIList
    If IsWindow(#WINDOW_LIST) = #False
      OpenWindow(#WINDOW_LIST, 0, 0, 400-1, 300-1, #PLAYER_NAME+" - " + Language(#L_PLAYLIST),#PB_Window_ScreenCentered|#PB_Window_SizeGadget|#PB_Window_SystemMenu|#PB_Window_MinimizeGadget)
      WriteLog("Open Playlist window", #LOGLEVEL_DEBUG)
      
      CompilerIf #USE_OEM_VERSION
        SetWindowIcon(#WINDOW_LIST, "icon.ico")
      CompilerEndIf
      
      WindowBounds(#WINDOW_LIST, 300, 180, #PB_Ignore, #PB_Ignore)
      
      CreateToolBar(#TOOLBAR_PLAYLIST, WindowID(#WINDOW_LIST))
      
      hTB = ToolBarID(#TOOLBAR_PLAYLIST)
      If hTB
        hOldIList = SendMessage_(hTB, #TB_GETIMAGELIST, 0, 0); 
        hNewIList = ImageList_Duplicate_(hOldIList) 
        ImageList_Destroy_(hOldIList)
        ImageList_SetIconSize_(hNewIList, 24, 24)
        SendMessage_(hTB, #TB_SETIMAGELIST, 0, hNewIList)
        SendMessage_(hTB, #TB_SETBITMAPSIZE, 0, MakeLong(24,24))
        SendMessage_(hTB, #TB_SETBUTTONSIZE, 0, MakeLong(26,26))
        SendMessage_(hTB, #TB_AUTOSIZE, 0, 0) 
      EndIf
      
      ToolBarImageButton(#TOOLBAR_BUTTON_ADDLIST, ImageID(#SPRITE_ADDLIST));ImageID(LoadImage(#PB_Any, "data\laptop.ico")))
      ToolBarImageButton(#TOOLBAR_BUTTON_DELETELIST, ImageID(#SPRITE_DELETELIST))
      ToolBarSeparator()
      ToolBarImageButton(#TOOLBAR_BUTTON_IMPORTPLAYLIST, ImageID(#SPRITE_IMPORTPLAYLIST))
      ToolBarImageButton(#TOOLBAR_BUTTON_EXPORTPLAYLIST, ImageID(#SPRITE_EXPORTPLAYLIST))
      ToolBarSeparator()
      ToolBarImageButton(#TOOLBAR_BUTTON_PLAYPLAYLIST, ImageID(#SPRITE_PLAYPLAYLIST))
      ToolBarSeparator()
      ToolBarImageButton(#TOOLBAR_BUTTON_ADDTRACK, ImageID(#SPRITE_ADDTRACK))
      ToolBarImageButton(#TOOLBAR_BUTTON_ADDFOLDERTRACKS, ImageID(#SPRITE_ADDFOLDERTRACKS))
      ToolBarImageButton(#TOOLBAR_BUTTON_ADDURL, ImageID(#SPRITE_ADDURL))
      ToolBarImageButton(#TOOLBAR_BUTTON_DELETETRACK, ImageID(#SPRITE_DELETETRACK))
      
      
      ToolBarToolTip(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_ADDLIST, Language(#L_ADD_PLAYLIST)) 
      ToolBarToolTip(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_DELETELIST, Language(#L_REMOVE_PLAYLIST)) 
      ToolBarToolTip(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_IMPORTPLAYLIST, Language(#L_IMPORT_PLAYLIST)) 
      ToolBarToolTip(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_EXPORTPLAYLIST, Language(#L_EXPORT_PLAYLIST)) 
      ToolBarToolTip(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_PLAYPLAYLIST, Language(#L_PLAY)) 
      ToolBarToolTip(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_ADDTRACK, Language(#L_ADD_TRACK)) 
      ToolBarToolTip(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_ADDFOLDERTRACKS, Language(#L_ADD_FOLDER)) 
      ToolBarToolTip(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_ADDURL, Language(#L_ADD_URL)) 
      ToolBarToolTip(#TOOLBAR_PLAYLIST, #TOOLBAR_BUTTON_DELETETRACK, Language(#L_REMOVE_TRACK))  
      
      ContainerGadget(#GADGET_LIST_CONTAINER, 0, 0, 0, 0)
      ListIconGadget(#GADGET_LIST_PLAYLIST, 0, 0, 0, 0, Language(#L_PLAYLIST), 100, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection )
      SetExplorerTheme(GadgetID(#GADGET_LIST_PLAYLIST))
      ImageGadget(#GADGET_LIST_IMAGE, 0, 0, 100, 100, ImageID(#SPRITE_NOIMAGE))
      EnableGadgetDrop(#GADGET_LIST_IMAGE, #PB_Drop_Files, #PB_Drag_Link)
      CloseGadgetList()
      
      
      ListIconGadget(#GADGET_LIST_TRACKLIST, 0, 0, 0, 0, Language(#L_TITLE), 100, #PB_ListIcon_MultiSelect|#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection)
      AddGadgetColumn(#GADGET_LIST_TRACKLIST, 1, Language(#L_LENGTH), 60)
      AddGadgetColumn(#GADGET_LIST_TRACKLIST, 2, Language(#L_INTERPRET), 75)
      AddGadgetColumn(#GADGET_LIST_TRACKLIST, 3, Language(#L_ALBUM), 60)
      EnableGadgetDrop(#GADGET_LIST_TRACKLIST, #PB_Drop_Files, #PB_Drag_Link)
      DisableAddTracks(#True)
      SetExplorerTheme(GadgetID(#GADGET_LIST_TRACKLIST))
      
      SplitterGadget(#GADGET_LIST_SPLITTER, 0, 0, WindowWidth(#WINDOW_LIST), WindowHeight(#WINDOW_LIST), #GADGET_LIST_CONTAINER, #GADGET_LIST_TRACKLIST, #PB_Splitter_Vertical)
      SetGadgetState(#GADGET_LIST_SPLITTER, 105)
      SetGadgetAttribute(#GADGET_LIST_SPLITTER, #PB_Splitter_FirstMinimumSize, 105)
      SetGadgetAttribute(#GADGET_LIST_SPLITTER, #PB_Splitter_SecondMinimumSize, 105)
      
      *PLAYLISTDB = DB_Open(sDataBaseFile)
      ;DB_UpdateSync(*PLAYLISTDB,"DROP TABLE PLAYLISTS")
      ;DB_UpdateSync(*PLAYLISTDB,"DROP TABLE PLAYTRACKS")
      ;DB_UpdateSync(*PLAYLISTDB,"CREATE TABLE PLAYLISTS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name VARCHAR(500))")
      ;DB_UpdateSync(*PLAYLISTDB,"CREATE TABLE PLAYTRACKS (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, playlist INT, filename VARCHAR(500), lenght INT, type INT, title VARCHAR(500), description VARCHAR(500),  interpret VARCHAR(500),  album VARCHAR(500))")
      
      LoadPlayList()
      
      
      If IsMenu(#MENU_LIST_PLAYLISTS)
        FreeMenu(#MENU_LIST_PLAYLISTS)
      EndIf
      CreatePopupImageMenu(#MENU_LIST_PLAYLISTS, #PB_Menu_ModernLook)
      __MenuItem(#MENU_LIST_PLAY, Language(#L_PLAY), ImageID(#SPRITE_MENU_PLAY))
      __MenuItem(#MENU_LIST_DELETE, Language(#L_DELETE), ImageID(#SPRITE_MENU_BULLDOZER))
      __MenuItem(#MENU_LIST_RENAME, Language(#L_RENAME), ImageID(#SPRITE_MENU_RENAME))
      MenuBar()
      __MenuItem(#MENU_LIST_CACHELIST, Language(#L_CACHEPLAYLIST), ImageID(#SPRITE_MENU_RAM))
      
    Else
      ShowWindow_(WindowID(#WINDOW_LIST),#SW_SHOWNORMAL)
      SetActiveWindow(#WINDOW_LIST)  
      
    EndIf
    
    ;Prevent display errors...
    ResizeWindow(#WINDOW_LIST,#PB_Ignore,#PB_Ignore,WindowWidth(#WINDOW_LIST)+1,WindowHeight(#WINDOW_LIST)+1)  
    ;Repeat
    ;Until WindowEvent() = 0
  EndProcedure
  Procedure CreateOptionsWindow()
    Protected sVideoRender.s, iAudioRenderer.i, DriveType.i
    If IsWindow(#WINDOW_OPTIONS) = #False
      If IsFont(#FONT_OPTIONS)=#False
        If OSVersion()<#PB_OS_Windows_Vista
          LoadFont(#FONT_OPTIONS,"Tahoma",10-(UsedDPI-96)/10)
        Else
          LoadFont(#FONT_OPTIONS,"Segoe UI",10-(UsedDPI-96)/10)
        EndIf
      EndIf
      
      iOptionsGadgetItems = #False
      OpenWindow(#WINDOW_OPTIONS, 0, 0, 400, 400, #PLAYER_NAME + " - " + Language(#L_OPTIONS),#PB_Window_ScreenCentered|#PB_Window_SystemMenu)
      WriteLog("Open Options window", #LOGLEVEL_DEBUG)
      
      CompilerIf #USE_OEM_VERSION
        SetWindowIcon(#WINDOW_OPTIONS, "icon.ico")
      CompilerEndIf
      
      ButtonGadget(#GADGET_OPTIONS_CANCEL, 305, 371, 90, 25, Language(#L_CANCEL))
      ButtonGadget(#GADGET_OPTIONS_SAVE, 210, 371, 90, 25, Language(#L_SAVE))
      
      PanelGadget(#GADGET_OPTIONS_PANEL, 2, 2, 396, 366)
      
      AddGadgetItem(#GADGET_OPTIONS_PANEL, -1, Language(#L_GENERAL), ImageID(#SPRITE_MENU_OPTIONS)):iOptionsOptionCount = #Null
      AddOptionsOption(#GADGET_OPTIONS_ITEM_LANGUAGE, Language(#L_LANGUAGE), GetAllLanguages(sDataBaseFile), #OPTIONS_COMBOBOX, Val(Settings(#SETTINGS_LANGUAGE)\sValue)-1, #SPRITE_LANGUAGE)
      AddOptionsOption(#GADGET_OPTIONS_ITEM_LOGLEVEL, Language(#L_LOGLEVEL), Language(#L_NONE)+Chr(10)+Language(#L_ERROR)+Chr(10)+Language(#L_DEBUG)+Chr(10), #OPTIONS_COMBOBOX, Val(Settings(#SETTINGS_LOGLEVEL)\sValue), #SPRITE_BUG)
      AddOptionsOption(#GADGET_OPTIONS_ITEM_SYSTRAY, Language(#L_USESYSTRAY), "", #OPTIONS_CHECKBOX, Val(Settings(#SETTINGS_SYSTRAY)\sValue), #SPRITE_SYSTRAY_32x32)
      AddOptionsOption(#GADGET_OPTIONS_ITEM_AUTOUPDATES, Language(#L_AUTOUPDATE), "", #OPTIONS_CHECKBOX, Val(Settings(#SETTINGS_AUTOMATIC_UPDATE)\sValue), #SPRITE_UPDATE)
      AddOptionsOption(#GADGET_OPTIONS_ITEM_SINGLE_INSTANCE, Language(#L_SINGLE_INSTANCE), "", #OPTIONS_CHECKBOX, Val(Settings(#SETTINGS_SINGLE_INSTANCE)\sValue), #SPRITE_ONE_INSTANCE)
      ;Hotkeys
      
      ButtonGadget(#GADGET_OPTIONS_EXPORT_DB, 3, 305-(UsedDPI-96)/10, 185, 25, Language(#L_EXPORTDATABASE)) 
      ButtonGadget(#GADGET_OPTIONS_IMPORT_DB, 198, 305-(UsedDPI-96)/10, 185, 25, Language(#L_IMPORTDATABASE)) 
      ButtonGadget(#GADGET_OPTIONS_DEFAULT_DB, 3, 275-(UsedDPI-96)/10, 380, 25, Language(#L_DEFAULTDATABASE))  
      
      
      AddGadgetItem(#GADGET_OPTIONS_PANEL, -1, Language(#L_MEDIA), ImageID(#SPRITE_MENU_PROJEKTOR)):iOptionsOptionCount = #Null
      sVideoRender.s = Language(#L_DEFAULT)+Chr(10)+Language(#L_VMR9_Windowless)+Chr(10)+Language(#L_VMR7_Windowless)+Chr(10)+Language(#L_OldVideoRenderer)+Chr(10)+Language(#L_OverlayMixer)+Chr(10)+Language(#L_DSHOWDEFAULT)+Chr(10)+Language(#L_VMR9_Windowed)+Chr(10)+Language(#L_VMR7_Windowed)+Chr(10)+Language(#L_OWN_RENDERER)+Chr(10)
      AddOptionsOption(#GADGET_OPTIONS_ITEM_VIDEORENDERER, Language(#L_VIDEORENDERER), sVideoRender, #OPTIONS_COMBOBOX, Val(Settings(#SETTINGS_VIDEORENDERER)\sValue), #SPRITE_RENDERER)
      
      iAudioRenderer = Val(Settings(#SETTINGS_AUDIORENDERER)\sValue)
      If iAudioRenderer>0:iAudioRenderer-5:EndIf
      AddOptionsOption(#GADGET_OPTIONS_ITEM_AUDIORENDERER, Language(#L_AUDIORENDERER), Language(#L_DEFAULT)+Chr(10)+Language(#L_WAVEOUTRENDERER)+Chr(10)+Language(#L_DIRECTSOUNDRENDERER)+Chr(10), #OPTIONS_COMBOBOX, iAudioRenderer, #SPRITE_AUDIORENDERER)
      
      AddOptionsOption(#GADGET_OPTIONS_ITEM_RAMUSAGE, Language(#L_RAMUSAGE), "0"+Chr(10)+"25"+Chr(10)+"50"+Chr(10)+"100"+Chr(10)+"250"+Chr(10)+"500"+Chr(10), #OPTIONS_COMBOBOX_EDITABLE, Val(Settings(#SETTINGS_RAM_SIZE)\sValue), #SPRITE_RAM)
      AddOptionsOption(#GADGET_OPTIONS_ITEM_MAXRAMFILESIZE, Language(#L_RAMUSAGEPERFILE), "0"+Chr(10)+"5"+Chr(10)+"10"+Chr(10)+"20"+Chr(10)+"30"+Chr(10)+"50"+Chr(10), #OPTIONS_COMBOBOX_EDITABLE, Val(Settings(#SETTINGS_RAM_SIZE_PER_FILE)\sValue), #SPRITE_RAM_FILE)
      
      AddOptionsOption(#GADGET_OPTIONS_ITEM_PICTURE_PATH, Language(#L_PICTUREPATH), Settings(#SETTINGS_PHOTO_PATH)\sValue, #OPTIONS_PATH, #False, #SPRITE_PHOTO_32x32)
      AddOptionsOption(#GADGET_OPTIONS_ITEM_PICTURE_FORMAT, Language(#L_PICTUREFORMAT), "JPG"+Chr(10)+"PNG"+Chr(10)+"JPEG 2000"+Chr(10), #OPTIONS_COMBOBOX, Val(Settings(#SETTINGS_PHOTO_FORMAT)\sValue), #SPRITE_PHOTO_FILE_32x32)
      AddOptionsOption(#GADGET_OPTIONS_ITEM_BKCOLOR, Language(#L_BKCOLOR), "", #OPTIONS_COLOR, Val(Settings(#SETTINGS_BKCOLOR)\sValue), #SPRITE_BKCOLOR)
      AddOptionsOption(#GADGET_OPTIONS_ITEM_ICONSET, Language(#L_THEME), GetPlayerDesigns(sDataBaseFile), #OPTIONS_COMBOBOX, Val(Settings(#SETTINGS_ICONSET)\sValue)-1, #SPRITE_THEME)
      
      ;Rahmen Farbe einstellen (Schwarze Balken)
      ;Verknüpfte datein. altes merken
      DriveType.i = GetDriveType_(Left(ProgramFilename(),1)+":\")
      If UCase(Left(ProgramFilename(),1))=UCase(Left(GetSystemDirectory(),1)):DriveType=#DRIVE_FIXED:EndIf
      If DriveType = #DRIVE_FIXED Or DriveType = #DRIVE_REMOTE 
        AddGadgetItem(#GADGET_OPTIONS_PANEL, -1, Language(#L_FILEEXTENSION), ImageID(#SPRITE_MENU_LOAD)):iOptionsOptionCount = #Null
        AddFileExtensionToOptions()
      EndIf        
      
      CloseGadgetList()
      
      
      
      
      
      
    Else
      ShowWindow_(WindowID(#WINDOW_OPTIONS), #SW_SHOWNORMAL)
      SetActiveWindow(#WINDOW_OPTIONS)  
    EndIf
  EndProcedure
  Procedure CreateProtectVideoWindow()
    Protected GadgetY.i = 5, sFile.s, mask.s
    If IsWindow(#WINDOW_VIDEOPROTECT) = #False
      OpenWindow(#WINDOW_VIDEOPROTECT, 0, 0, 400, 400, #PLAYER_NAME + " - " + Language(#L_PROTECTVIDEO),#PB_Window_ScreenCentered|#PB_Window_SystemMenu)
      WriteLog("Open Protect window", #LOGLEVEL_DEBUG)
      
      CompilerIf #USE_OEM_VERSION
        SetWindowIcon(#WINDOW_VIDEOPROTECT, "icon.ico")
      CompilerEndIf
      
      
      ButtonGadget(#GADGET_PV_CANCEL, 305, 371, 90, 25, Language(#L_CANCEL))
      ButtonGadget(#GADGET_PV_SAVE, 210, 371, 90, 25, Language(#L_SAVE))
      
      PanelGadget(#GADGET_PV_PANEL, 2, 2, 396, 366)
      AddGadgetItem(#GADGET_PV_PANEL, -1, Language(#L_GENERAL), ImageID(#SPRITE_MENU_PLAYMEDIA))
      ImageGadget(#PB_Any, 2, GadgetY, 32, 32, ImageID(#SPRITE_PROJEKTOR))
      ButtonGadget(#GADGET_PV_LOAD_BUTTON, 358, GadgetY, 30, 20, "...")
      StringGadget(#GADGET_PV_LOAD_STRING, 115, GadgetY, 240, 20, "", #PB_String_ReadOnly)
      TextGadget(#GADGET_PV_LOAD_TEXT, 40, GadgetY+3, 70, 20, Language(#L_MEDIA)+":*")
      
      GadgetY+26
      ;ImageGadget(#PB_Any, 2, GadgetY, 24, 24, ImageID(#SPRITE_MENU_LOAD))
      ButtonGadget(#GADGET_PV_SAVE_BUTTON, 358, GadgetY, 30, 20, "...")
      StringGadget(#GADGET_PV_SAVE_STRING, 115, GadgetY, 240, 20, "", #PB_String_ReadOnly)
      TextGadget(#GADGET_PV_SAVE_TEXT, 40, GadgetY+3, 70, 20, Language(#L_SAVE)+":*")
      
      GadgetY+46
      ImageGadget(#PB_Any, 2, GadgetY, 32, 32, ImageID(#SPRITE_KEY))
      If Len(Language(#L_PASSWORD))>10
        TextGadget(#GADGET_PV_PW_TEXT, 40, GadgetY-5, 70, 40, Language(#L_PASSWORD)+":")
      Else
        TextGadget(#GADGET_PV_PW_TEXT, 40, GadgetY+3, 70, 40, Language(#L_PASSWORD)+":")
      EndIf  
      StringGadget(#GADGET_PV_PW_STRING, 115, GadgetY, 270, 20, "", #PB_String_Password)
      
      GadgetY+26
      StringGadget(#GADGET_PV_PW2_STRING, 115, GadgetY, 270, 20, "", #PB_String_Password)
      TextGadget(#GADGET_PV_PW2_TEXT, 40, GadgetY-3, 70, 40, Language(#L_PASSWORD_VERIFY)+":")
      
      GadgetY+34
      ImageGadget(#PB_Any, 2, GadgetY, 32, 32, ImageID(#SPRITE_LIGHT))
      TextGadget(#GADGET_PV_PW_TIP_TEXT, 40, GadgetY+3, 70, 20, Language(#L_TIP)+":")
      StringGadget(#GADGET_PV_PW_TIP_STRING, 115, GadgetY, 270, 20, "")
      
      GadgetY+45
      
      
      CompilerIf Not #USE_OEM_VERSION
        ImageGadget(#PB_Any, 2, GadgetY, 32, 32, ImageID(#SPRITE_EXE))
      CompilerEndIf  
      
      CheckBoxGadget(#GADGET_PV_ADDPLAYER, 115, GadgetY+5, 390-115, 20, Language(#L_ADDPLAYERTOVIDEO))
      CompilerIf #USE_OEM_VERSION
        HideGadget(#GADGET_PV_ADDPLAYER, #True)
      CompilerEndIf
      GadgetY+45
      
      
      CheckBoxGadget(#GADGET_PV_ALLOWUNPROTECT, 5, GadgetY, 340, 20, Language(#L_ALLOWUNPROTECT))
      CompilerIf #USE_HIDE_UNPROTECT_CHECKBOX        
        HideGadget(#GADGET_PV_ALLOWUNPROTECT, #True)
      CompilerElse
        GadgetY+25
      CompilerEndIf
      
      
      ButtonGadget(#GADGET_PV_ICON_BUTTON, 358, GadgetY, 30, 20, "...")
      StringGadget(#GADGET_PV_ICON_STRING, 115, GadgetY, 240, 20, "")
      TextGadget(#GADGET_PV_ICON_TEXT, 5, GadgetY+3, 100, 20, Language(#L_ICON)+":")
      DisableGadget(#GADGET_PV_ICON_BUTTON, #True)
      DisableGadget(#GADGET_PV_ICON_STRING, #True)
      GadgetY+25
      ButtonGadget(#GADGET_PV_COMMAND_BUTTON, 358, GadgetY, 30, 20, "?")
      StringGadget(#GADGET_PV_COMMAND_STRING, 115, GadgetY, 240, 20, "")
      TextGadget(#GADGET_PV_COMMAND_TEXT, 5, GadgetY+3, 100, 20, Language(#L_PARAMENTER)+":")
      DisableGadget(#GADGET_PV_COMMAND_BUTTON, #True)
      DisableGadget(#GADGET_PV_COMMAND_STRING, #True)
      
      
      
      
      TextGadget(#GADGET_PV_WARNING, 5, 305, 370, 32, "", #PB_Text_Center)
      SetGadgetColor(#GADGET_PV_WARNING, #PB_Gadget_FrontColor, RGB(255,0,0))
      
      
      
      
      
      ;AddGadgetItem(#GADGET_PV_PANEL, -1, Language(#L_EXTENDED), ImageID(#SPRITE_MENU_OPTIONS))
      
      
      AddGadgetItem(#GADGET_PV_PANEL, -1, Language(#L_TAGS), ImageID(#SPRITE_MENU_PLAYLIST))  
      GadgetY=5
      TextGadget(#PB_Any, 5, GadgetY+3, 110, 20, Language(#L_TITLE)+":")
      StringGadget(#GADGET_PV_TAG_TITLE, 115, GadgetY, 270 , 20, "")
      GadgetY+30
      TextGadget(#PB_Any, 5, GadgetY+3, 110, 20, Language(#L_ALBUM)+":")
      StringGadget(#GADGET_PV_TAG_ALBUM, 115, GadgetY, 270, 20, "")              
      GadgetY+30
      TextGadget(#PB_Any, 5, GadgetY+3, 110, 20, Language(#L_INTERPRET)+":")
      StringGadget(#GADGET_PV_TAG_INTERPRET, 115, GadgetY, 270, 20, "")     
      GadgetY=220-(UsedDPI-96)/5
      TextGadget(#PB_Any, 5, GadgetY+3, 110, 20, Language(#L_COMMENT)+":") 
      GadgetY+25
      EditorGadget(#GADGET_PV_TAG_COMMENT, 5, GadgetY, 380, 90)
      
      
      AddGadgetItem(#GADGET_PV_PANEL, -1, Language(#L_OTHER), ImageID(#SPRITE_MENU_COVERFLOW))  
      GadgetY=5
      TextGadget(#GADGET_PV_COVER_TEXT, 5, GadgetY, 60, 20, Language(#L_COVER)+":")
      GadgetY+25
      ImageGadget(#GADGET_PV_COVER_IMG, 5, GadgetY, 100, 100, ImageID(#SPRITE_NOIMAGE), #PB_Image_Border)
      EnableGadgetDrop(#GADGET_PV_COVER_IMG, #PB_Drop_Files, #PB_Drag_Link)
      TextGadget(#GADGET_PV_COVER_TEXT2, 120, GadgetY, 160, 20, Language(#L_COVER_FILE)+":")
      GadgetY+25
      ButtonGadget(#GADGET_PV_COVER_BUTTON, 340, GadgetY, 35, 20, "...")
      StringGadget(#GADGET_PV_COVER_STRING, 120, GadgetY, 215, 20, "", #PB_String_ReadOnly)
      GadgetY=150
      
      StringGadget(#GADGET_PV_CODECNAME_STRING, 115, GadgetY, 270, 20, "")
      TextGadget(#GADGET_PV_CODECNAME_TEXT, 5, GadgetY+3, 105, 40, Language(#L_USED_CODEC)+":")
      GadgetY+30
      StringGadget(#GADGET_PV_CODECLINK_STRING, 115, GadgetY, 270, 20, "")
      TextGadget(#GADGET_PV_CODECLINK_TEXT, 5, GadgetY-3, 105, 40, Language(#L_CODEC_DOWNLOAD_LINK)+":")        
      
      GadgetY+30
      
      
      
      
      AddGadgetItem(#GADGET_PV_PANEL, -1, Language(#L_PROTECTION), ImageID(#SPRITE_MENU_TRESOR))    
      GadgetY=5
      ImageGadget(#PB_Any, 2, GadgetY, 32, 32, ImageID(#SPRITE_NOPHOTO))
      TextGadget(#GADGET_PV_SNAPSHOT_TEXT, 40, GadgetY, 200, 20, Language(#L_DISALLOWSNAPSHOT)+":")
      
      GadgetY+20
      ComboBoxGadget(#GADGET_PV_SNAPSHOT_COMBOBOX, 40, GadgetY, 170, 20)
      AddGadgetItem(#GADGET_PV_SNAPSHOT_COMBOBOX, -1, Language(#L_ACTIVE))
      AddGadgetItem(#GADGET_PV_SNAPSHOT_COMBOBOX, -1, Language(#L_INACTIVE))
      ;AddGadgetItem(#GADGET_PV_SNAPSHOT_COMBOBOX, -1, Language(#L_EXTENDED))
      SetGadgetState(#GADGET_PV_SNAPSHOT_COMBOBOX, 0)
      
      GadgetY+30
      CheckBoxGadget(#GADGET_PV_NOT_FORCE_SCREENSHOT_PROTECTION, 40, GadgetY, 340, 20, Language(#L_NOT_FORCE_SCREENSHOT_PROTECTION));+" ("+Language(#L_NOT_RECOMMENDED)+")")
                                                                                                                                    ;DisableGadget(#GADGET_PV_NOT_FORCE_SCREENSHOT_PROTECTION, #True)
      SetGadgetState(#GADGET_PV_NOT_FORCE_SCREENSHOT_PROTECTION, #True)
      GadgetY+30
      
      
      
      CheckBoxGadget(#GADGET_PV_EXPIRE_DATE_TEXT, 5, GadgetY, 260, 20, Language(#L_EXPIRE_DATE))
      GadgetY+22
      mask.s="%mm/%dd/%yyyy"
      If iUsedLanguage.i=#LANGUAGE_DE
        mask.s="%dd.%mm.%yyyy"
      EndIf
      DateGadget(#GADGET_PV_EXPIRE_DATE, 5, GadgetY, 180, 25, mask)
      DisableGadget(#GADGET_PV_EXPIRE_DATE, #True)
      ;HideGadget(#GADGET_PV_EXPIRE_DATE_TEXT, #True)
      ;HideGadget(#GADGET_PV_EXPIRE_DATE, #True)
      GadgetY+40
      
      
      CheckBoxGadget(#GADGET_PV_COPY_PROTECTION, 5, GadgetY, 260, 20, Language(#L_USE_COPY_PROTECTION))
      GadgetY+35
      StringGadget(#GADGET_PV_MACHINEID_STRING, 115, GadgetY, 270, 20, "")
      TextGadget(#GADGET_PV_MACHINEID_TEXT, 5, GadgetY+3, 105, 20, Language(#L_MACHINE_ID)+":")  
      GadgetY+23
      HyperLinkGadget(#GADGET_PV_MACHINEID_GENERATE, 5, GadgetY,200,20,Language(#L_GENERATE_MACHINE_ID),#Blue, #PB_HyperLink_Underline)
      
      CompilerIf #USE_OEM_VERSION
        HideGadget(#GADGET_PV_COPY_PROTECTION, #True)
        HideGadget(#GADGET_PV_EXPIRE_DATE, #True)
        HideGadget(#GADGET_PV_EXPIRE_DATE_TEXT, #True)
      CompilerEndIf
      
      CompilerIf #USE_EXTENDED_DRM=#False
        HideGadget(#GADGET_PV_COPY_PROTECTION, #True)
        HideGadget(#GADGET_PV_MACHINEID_STRING, #True)
        HideGadget(#GADGET_PV_MACHINEID_TEXT, #True)
      CompilerEndIf  
      
      sFile.s = MediaFile\sRealFile
      If sFile
        SetProtectVideo(sFile.s)
      EndIf
      
    Else
      ShowWindow_(WindowID(#WINDOW_VIDEOPROTECT),#SW_SHOWNORMAL)
      SetActiveWindow(#WINDOW_VIDEOPROTECT)
    EndIf
  EndProcedure
  ;}
  ;{ Event Management
  Procedure ResizeMainWindow()
    Protected sFile.s, iState.i, iImage.i, iEventMenu.i, i.i, qNewPos.q, sPath.s, iEventGadget.i, key.i, sURL.s
    Protected FullscreenControlHeight.i, sSubtitleFile.s, iMenuHeight=0
    If IsGadget(#GADGET_CONTAINER) And IsGadget(#GADGET_VIS_CONTAINER) And IsGadget(#GADGET_VIDEO_CONTAINER) And IsGadget(#GADGET_AUDIOCD_CONTAINER)
      If IsMenu(#MENU_MAIN)
        iMenuHeight=MenuHeight()
      EndIf  
      
      ;Debug "RESIZE"+Str(Random(100))
      Dim Statusbar_Widths.l(1)
      Statusbar_Widths(0) = WindowWidth(#WINDOW_MAIN)-150
      Statusbar_Widths(1) = WindowWidth(#WINDOW_MAIN)
      SendMessage_(StatusBarID(#STATUSBAR_MAIN),#SB_SETPARTS,2,@Statusbar_Widths(0))
      
      If IsGadget(#GADGET_CONTAINER)
        If IsFullscreenControlUsed
          ResizeGadget(#GADGET_CONTAINER, 0, WindowHeight(#WINDOW_MAIN)-Design_Container_Size, WindowWidth(#WINDOW_MAIN), #PB_Ignore)
        Else
          ResizeGadget(#GADGET_CONTAINER, 0, WindowHeight(#WINDOW_MAIN)-Design_Container_Size-3-_StatusBarHeight(0)-iMenuHeight, WindowWidth(#WINDOW_MAIN), #PB_Ignore)
        EndIf
      EndIf
      
      If IsGadget(#GADGET_AUDIOCD_CONTAINER)
        ResizeGadget(#GADGET_AUDIOCD_CONTAINER, 1, WindowHeight(#WINDOW_MAIN)-Design_Container_Size-_StatusBarHeight(0)-iMenuHeight, WindowWidth(#WINDOW_MAIN)-2, #PB_Ignore)
      EndIf
      If IsGadget(#GADGET_VIDEODVD_CONTAINER)
        ResizeGadget(#GADGET_VIDEODVD_CONTAINER, 1, WindowHeight(#WINDOW_MAIN)-Design_Container_Size-_StatusBarHeight(0)-iMenuHeight, WindowWidth(#WINDOW_MAIN)-2, #PB_Ignore)
      EndIf
      
      
      If IsFullscreenControlUsed
        FullscreenControlHeight=Design_Container_Size-3-_StatusBarHeight(0)-iMenuHeight
      Else
        FullscreenControlHeight=0
      EndIf
      
      If iIsVISUsed
        If GetGadgetData(#GADGET_CONTAINER) ;Fullscreen
          ResizeGadget(#GADGET_VIS_CONTAINER,  0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN)-FullscreenControlHeight)
        Else
          If UseNoPlayerControl
            ResizeGadget(#GADGET_VIS_CONTAINER, 0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN)-iMenuHeight)
          Else
            ResizeGadget(#GADGET_VIS_CONTAINER, 0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN)-Design_Container_Size-3-_StatusBarHeight(0)-iMenuHeight)
          EndIf
        EndIf
        
        ResizeGadget(#GADGET_VIDEO_CONTAINER, 0, 0, 0, 0)
        VIS_Resize()
      Else
        If GetGadgetData(#GADGET_CONTAINER) Or UseNoPlayerControl;Fullscreen
          If UseNoPlayerControl And GetGadgetData(#GADGET_CONTAINER)=#False;Flash With menu
            ResizeGadget(#GADGET_VIDEO_CONTAINER, -2, -2, WindowWidth(#WINDOW_MAIN)+4, WindowHeight(#WINDOW_MAIN)+4-FullscreenControlHeight-iMenuHeight)
          Else;Fullscreen
            ResizeGadget(#GADGET_VIDEO_CONTAINER, -2, -2, WindowWidth(#WINDOW_MAIN)+4, WindowHeight(#WINDOW_MAIN)+4-FullscreenControlHeight)
          EndIf  
        Else
          ResizeGadget(#GADGET_VIDEO_CONTAINER, 0, 0, WindowWidth(#WINDOW_MAIN), WindowHeight(#WINDOW_MAIN)-Design_Container_Size-3-_StatusBarHeight(0)-iMenuHeight)
        EndIf
        ResizeGadget(#GADGET_VIS_CONTAINER, 0, 0, 0, 0)
      EndIf
      
      
      
      ;Media
      ResizeGadget(#GADGET_TRACKBAR          , DControlX(#GADGET_TRACKBAR), DControlY(#GADGET_TRACKBAR), DControlW(#GADGET_TRACKBAR), DControlH(#GADGET_TRACKBAR))
      ResizeGadget(#GADGET_BUTTON_BACKWARD   , DControlX(#GADGET_BUTTON_BACKWARD), DControlY(#GADGET_BUTTON_BACKWARD), DControlW(#GADGET_BUTTON_BACKWARD), DControlH(#GADGET_BUTTON_BACKWARD))
      ResizeGadget(#GADGET_BUTTON_FORWARD    , DControlX(#GADGET_BUTTON_FORWARD), DControlY(#GADGET_BUTTON_FORWARD), DControlW(#GADGET_BUTTON_FORWARD), DControlH(#GADGET_BUTTON_FORWARD))
      ResizeGadget(#GADGET_BUTTON_PLAY       , DControlX(#GADGET_BUTTON_PLAY), DControlY(#GADGET_BUTTON_PLAY), DControlW(#GADGET_BUTTON_PLAY), DControlH(#GADGET_BUTTON_PLAY))
      ResizeGadget(#GADGET_BUTTON_PREVIOUS   , DControlX(#GADGET_BUTTON_PREVIOUS), DControlY(#GADGET_BUTTON_PREVIOUS), DControlW(#GADGET_BUTTON_PREVIOUS), DControlH(#GADGET_BUTTON_PREVIOUS))
      ResizeGadget(#GADGET_BUTTON_STOP       , DControlX(#GADGET_BUTTON_STOP), DControlY(#GADGET_BUTTON_STOP), DControlW(#GADGET_BUTTON_STOP), DControlH(#GADGET_BUTTON_STOP))
      ResizeGadget(#GADGET_BUTTON_NEXT       , DControlX(#GADGET_BUTTON_NEXT), DControlY(#GADGET_BUTTON_NEXT), DControlW(#GADGET_BUTTON_NEXT), DControlH(#GADGET_BUTTON_NEXT))
      ResizeGadget(#GADGET_BUTTON_SNAPSHOT   , DControlX(#GADGET_BUTTON_SNAPSHOT), DControlY(#GADGET_BUTTON_SNAPSHOT), DControlW(#GADGET_BUTTON_SNAPSHOT), DControlH(#GADGET_BUTTON_SNAPSHOT))
      ResizeGadget(#GADGET_BUTTON_REPEAT     , DControlX(#GADGET_BUTTON_REPEAT), DControlY(#GADGET_BUTTON_REPEAT), DControlW(#GADGET_BUTTON_REPEAT), DControlH(#GADGET_BUTTON_REPEAT))
      ResizeGadget(#GADGET_BUTTON_RANDOM     , DControlX(#GADGET_BUTTON_RANDOM), DControlY(#GADGET_BUTTON_RANDOM), DControlW(#GADGET_BUTTON_RANDOM), DControlH(#GADGET_BUTTON_RANDOM))
      ResizeGadget(#GADGET_BUTTON_MUTE       , DControlX(#GADGET_BUTTON_MUTE), DControlY(#GADGET_BUTTON_MUTE), DControlW(#GADGET_BUTTON_MUTE), DControlH(#GADGET_BUTTON_MUTE))
      ResizeGadget(#GADGET_BUTTON_FULLSCREEN , DControlX(#GADGET_BUTTON_FULLSCREEN), DControlY(#GADGET_BUTTON_FULLSCREEN), DControlW(#GADGET_BUTTON_FULLSCREEN), DControlH(#GADGET_BUTTON_FULLSCREEN))
      If iVolumeGadget<>0:ResizeGadget(iVolumeGadget, DControlX(#GADGET_VOLUME), DControlY(#GADGET_VOLUME), #PB_Ignore, #PB_Ignore):EndIf  
      
      
      ;AudioCD
      ResizeGadget(#GADGET_ACD_BUTTON_PLAY, DControlX(#GADGET_ACD_BUTTON_PLAY), DControlY(#GADGET_ACD_BUTTON_PLAY), DControlW(#GADGET_ACD_BUTTON_PLAY), DControlH(#GADGET_ACD_BUTTON_PLAY))
      ResizeGadget(#GADGET_ACD_BUTTON_PREVIOUS, DControlX(#GADGET_ACD_BUTTON_PREVIOUS), DControlY(#GADGET_ACD_BUTTON_PREVIOUS), DControlW(#GADGET_ACD_BUTTON_PREVIOUS), DControlH(#GADGET_ACD_BUTTON_PREVIOUS))
      ResizeGadget(#GADGET_ACD_BUTTON_STOP, DControlX(#GADGET_ACD_BUTTON_STOP), DControlY(#GADGET_ACD_BUTTON_STOP), DControlW(#GADGET_ACD_BUTTON_STOP), DControlH(#GADGET_ACD_BUTTON_STOP))
      ResizeGadget(#GADGET_ACD_BUTTON_NEXT, DControlX(#GADGET_ACD_BUTTON_NEXT), DControlY(#GADGET_ACD_BUTTON_NEXT), DControlW(#GADGET_ACD_BUTTON_NEXT), DControlH(#GADGET_ACD_BUTTON_NEXT))
      ResizeGadget(#GADGET_ACD_BUTTON_EJECT, DControlX(#GADGET_ACD_BUTTON_EJECT), DControlY(#GADGET_ACD_BUTTON_EJECT), DControlW(#GADGET_ACD_BUTTON_EJECT), DControlH(#GADGET_ACD_BUTTON_EJECT))  
      ResizeGadget(#GADGET_ACD_COMBOBOX_DEVICE, DControlX(#GADGET_ACD_COMBOBOX_DEVICE), DControlY(#GADGET_ACD_COMBOBOX_DEVICE), DControlW(#GADGET_ACD_COMBOBOX_DEVICE), DControlH(#GADGET_ACD_COMBOBOX_DEVICE))
      ResizeGadget(#GADGET_ACD_COMBOBOX_TRACKS, DControlX(#GADGET_ACD_COMBOBOX_TRACKS), DControlY(#GADGET_ACD_COMBOBOX_TRACKS), DControlW(#GADGET_ACD_COMBOBOX_TRACKS), DControlH(#GADGET_ACD_COMBOBOX_TRACKS))
      
      ;DVD
      ResizeGadget(#GADGET_VDVD_BUTTON_PLAY, DControlX(#GADGET_VDVD_BUTTON_PLAY), DControlY(#GADGET_VDVD_BUTTON_PLAY), DControlW(#GADGET_VDVD_BUTTON_PLAY), DControlH(#GADGET_VDVD_BUTTON_PLAY))
      ResizeGadget(#GADGET_VDVD_BUTTON_BACKWARD, DControlX(#GADGET_VDVD_BUTTON_BACKWARD), DControlY(#GADGET_VDVD_BUTTON_BACKWARD), DControlW(#GADGET_VDVD_BUTTON_BACKWARD), DControlH(#GADGET_VDVD_BUTTON_BACKWARD))
      ResizeGadget(#GADGET_VDVD_BUTTON_PREVIOUS, DControlX(#GADGET_VDVD_BUTTON_PREVIOUS), DControlY(#GADGET_VDVD_BUTTON_PREVIOUS), DControlW(#GADGET_VDVD_BUTTON_PREVIOUS), DControlH(#GADGET_VDVD_BUTTON_PREVIOUS))
      ResizeGadget(#GADGET_VDVD_BUTTON_STOP, DControlX(#GADGET_VDVD_BUTTON_STOP), DControlY(#GADGET_VDVD_BUTTON_STOP), DControlW(#GADGET_VDVD_BUTTON_STOP), DControlH(#GADGET_VDVD_BUTTON_STOP))
      ResizeGadget(#GADGET_VDVD_BUTTON_NEXT, DControlX(#GADGET_VDVD_BUTTON_NEXT), DControlY(#GADGET_VDVD_BUTTON_NEXT), DControlW(#GADGET_VDVD_BUTTON_NEXT), DControlH(#GADGET_VDVD_BUTTON_NEXT))
      ResizeGadget(#GADGET_VDVD_BUTTON_EJECT, DControlX(#GADGET_VDVD_BUTTON_EJECT), DControlY(#GADGET_VDVD_BUTTON_EJECT), DControlW(#GADGET_VDVD_BUTTON_EJECT), DControlH(#GADGET_VDVD_BUTTON_EJECT))
      ResizeGadget(#GADGET_VDVD_BUTTON_LAUFWERK, DControlX(#GADGET_VDVD_BUTTON_LAUFWERK), DControlY(#GADGET_VDVD_BUTTON_LAUFWERK), DControlW(#GADGET_VDVD_BUTTON_LAUFWERK), DControlH(#GADGET_VDVD_BUTTON_LAUFWERK))
      ResizeGadget(#GADGET_VDVD_BUTTON_SNAPSHOT, DControlX(#GADGET_VDVD_BUTTON_SNAPSHOT), DControlY(#GADGET_VDVD_BUTTON_SNAPSHOT), DControlW(#GADGET_VDVD_BUTTON_SNAPSHOT), DControlH(#GADGET_VDVD_BUTTON_SNAPSHOT))
      ResizeGadget(#GADGET_VDVD_BUTTON_FORWARD, DControlX(#GADGET_VDVD_BUTTON_FORWARD), DControlY(#GADGET_VDVD_BUTTON_FORWARD), DControlW(#GADGET_VDVD_BUTTON_FORWARD), DControlH(#GADGET_VDVD_BUTTON_FORWARD))  
      ResizeGadget(#GADGET_VDVD_BUTTON_MUTE, DControlX(#GADGET_VDVD_BUTTON_MUTE), DControlY(#GADGET_VDVD_BUTTON_MUTE), DControlW(#GADGET_VDVD_BUTTON_MUTE), DControlH(#GADGET_VDVD_BUTTON_MUTE))
      ResizeGadget(#GADGET_VDVD_TRACKBAR, DControlX(#GADGET_VDVD_TRACKBAR), DControlY(#GADGET_VDVD_TRACKBAR), DControlW(#GADGET_VDVD_TRACKBAR), DControlH(#GADGET_VDVD_TRACKBAR))
      If iVDVD_VolumeGadget<>0:ResizeGadget(iVDVD_VolumeGadget, DControlX(#GADGET_VDVD_VOLUME), DControlY(#GADGET_VDVD_VOLUME), #PB_Ignore, #PB_Ignore):EndIf
      
      
      If iMediaObject
        If iIsMediaObjectVideoDVD
          If DShow_DVDGetLength(iMediaObject) And DShow_DVDGetPosition(iMediaObject)
            SetGadgetState(#GADGET_VDVD_TRACKBAR, IntQ((DShow_DVDGetPosition(iMediaObject)/DShow_DVDGetLength(iMediaObject))*10000))
          EndIf
        Else
          If MediaLength(iMediaObject) And MediaPosition(iMediaObject)
            SetGadgetState(#GADGET_TRACKBAR, IntQ((MediaPosition(iMediaObject)/MediaLength(iMediaObject))*10000))
          EndIf
        EndIf
      EndIf
      
      SetMediaAspectRation()
      RedrawWindow(WindowID(#WINDOW_MAIN)) 
    EndIf
  EndProcedure
  Procedure EventMainWindow(iEvent.i)
    Protected sFile.s, iState.i, iImage.i, iEventMenu.i, i.i, qNewPos.q, sPath.s, iEventGadget.i, key.i, sURL.s
    Protected FullscreenControlHeight.i, sSubtitleFile.s
    
    If iEvent = #WM_LBUTTONDOWN
      If iIsMinimalMode.i
        If WindowMouseY(#WINDOW_MAIN)<40
          SendMessage_(WindowID(#WINDOW_MAIN), #WM_NCLBUTTONDOWN, #HTCAPTION, 0)
        EndIf
      EndIf
    EndIf
    
    If iEvent = #WM_MOUSEWHEEL 
      iState=0
      If WindowMouseX(#WINDOW_MAIN)>GadgetX(#GADGET_TRACKBAR)+GadgetX(#GADGET_CONTAINER) And WindowMouseX(#WINDOW_MAIN)<GadgetX(#GADGET_TRACKBAR)+GadgetWidth(#GADGET_TRACKBAR)+GadgetX(#GADGET_CONTAINER)
        If WindowMouseY(#WINDOW_MAIN)>GadgetY(#GADGET_TRACKBAR)+GadgetY(#GADGET_CONTAINER) And WindowMouseY(#WINDOW_MAIN)<GadgetY(#GADGET_TRACKBAR)+GadgetHeight(#GADGET_TRACKBAR)+GadgetY(#GADGET_CONTAINER)
          If iMediaObject
            iState = GetGadgetState(#GADGET_TRACKBAR)-(MouseWheelDelta()*20)
            SetGadgetState(#GADGET_TRACKBAR, iState)
            If GetGadgetState(#GADGET_TRACKBAR)<>IntQ((MediaPosition(iMediaObject)/MediaLength(iMediaObject))*10000)
              MediaSeek(iMediaObject, IntQ(MediaLength(iMediaObject)/10000*GetGadgetState(#GADGET_TRACKBAR)))
            EndIf
          EndIf  
        EndIf
      EndIf 
      If iState=0 And GetFocus_()<>GadgetID(#GADGET_TRACKBAR) And GetFocus_()<>GadgetID(#GADGET_VDVD_TRACKBAR)
        If GetActiveWindow()=#WINDOW_MAIN
          iState = GetVolumeGadgetState(iVolumeGadget)-(MouseWheelDelta()*4)
          RunCommand(#COMMAND_VOLUME, iState)
        EndIf
      EndIf
      
    EndIf
    
    If iEvent = #PB_Event_SysTray
      If EventType() = #PB_EventType_LeftDoubleClick
        If IsWindowVisible_(WindowID(#WINDOW_MAIN))
          HideWindow(#WINDOW_MAIN, #True)
        Else
          HideWindow(#WINDOW_MAIN, #False)
          SetWindowState(#WINDOW_MAIN, #PB_Window_Normal) 
          SetActiveWindow(#WINDOW_MAIN)
        EndIf
      EndIf
      If EventType() = #PB_EventType_RightClick
        VDVD_CreatePopUpMenu(#True)
        DisplayPopupMenu(#MENU_VDVD_MENU, WindowID(#WINDOW_MAIN))
      EndIf
    EndIf
    
    If Val(Settings(#SETTINGS_SYSTRAY)\sValue) = #True
      If IsIconic_(WindowID(#WINDOW_MAIN))
        HideWindow(#WINDOW_MAIN, #True)
      EndIf
    EndIf
    
    If iEvent = #PB_Event_Menu
      iEventMenu = EventMenu()
      VDVD_MenuEvents(iEventMenu)
      Select iEventMenu
        Case #MENU_LOAD
          RunCommand(#COMMAND_LOAD)
          
        Case #MENU_LOADCLIPBOARD
          RunCommand(#COMMAND_PASTE)
          
        Case #MENU_LOADURL
          ;sURL.s=InputRequester(Language(#L_LOAD), Language(#L_LOADURL), "http://")
          ;URLRequester("von URL streamen", "Mediendatei von URL streamen", "Adresse zur Mediendatei:", "Beispiel anzeigen", "http://test.de/myvideo.gfp"+Chr(13)+"file://c:/myvideo.gfp", "test", "Abspielen", "Abbrechen")
          sURL.s = URLRequester(Language(#L_URL_STREAMING), Language(#L_STREAM_MEDIA_FROM_URL), Language(#L_URL_TO_MEDIAFILE)+":", Language(#L_SHOW_SAMPLE), "http://test.de/myvideo.gfp"+Chr(13)+"https://test.de/myvideo.mp4", "", Language(#L_PLAY), Language(#L_CANCEL))
          If sURL.s
            ;LoadMediaFile(sURL.s)
            RunCommand(#COMMAND_LOADFILE, 0, sURL)
          EndIf
          
        Case #MENU_COPYTOCLIPBOARD
          RunCommand(#COMMAND_COPY)
          
        Case #MENU_QUIT
          WriteLog("exit application though #MENU_QUIT", #LOGLEVEL_DEBUG)
          ;iQuit = 1
          EndPlayer()
          
        Case #MENU_VIS_OFF
          VIS_SetVIS(#False)
          
        Case #MENU_VIS_SIMPLE
          VIS_SetVIS(#VIS_SIMPLE)    
          
        Case #MENU_VIS_DCT
          VIS_SetVIS(#VIS_DCT)
          
        Case #MENU_VIS_WHITELIGHT
          VIS_SetVIS(#VIS_WHITELIGHT)
          
        Case #MENU_VIS_COVERFLOW
          If iIsVISUsed<>#VIS_COVERFLOW
            ;VIS_SetVIS(#VIS_COVERFLOW)
            LoadCoverFlow()
          Else
            VIS_SetVIS(#False)
          EndIf
          
        Case #MENU_ABOUT
          CreateAboutWindow()
          
        Case #MENU_PLAYLIST
          RunCommand(#COMMAND_PLAYLIST)
          
        Case #MENU_HOMEPAGE
          RunProgram("http://GFP.RRSoftware.de")
          
        Case #MENU_DOCUMENTATION
          If FileSize(GetPathPart(ProgramFilename())+"Help\GFP-Documentation.html")>0
            ;Define a$
            ;a$=GetPathPart(ProgramFilename())+"Help\GFP-Documentation.html"
            RunProgram(GetPathPart(ProgramFilename())+"Help\GFP-Documentation.html");a$)
          Else
            RunProgram("http://gfp.rrsoftware.de/index.php?option=com_content&view=category&id=37&Itemid=62")
          EndIf  
          
        Case #MENU_OPTIONS
          RunCommand(#COMMAND_OPTIONS)
          
        Case #MENU_CHECKUPDATES
          CompilerIf #USE_OEM_VERSION = #False
            UpdatePlayer()
          CompilerEndIf  
          
        Case #MENU_DOWNLOADCODECS
          RunProgram("http://www.codecguide.com")
          
        Case #MENU_PLAY
          RunCommand(#COMMAND_PLAY)
          
        Case #MENU_FULLSCREEN
          RunCommand(#COMMAND_FULLSCREEN)
          
        Case #MENU_STOP
          RunCommand(#COMMAND_STOP)
          
        Case #MENU_FORWARD
          RunCommand(#COMMAND_NEXTTRACK)
          
        Case #MENU_BACKWARD
          RunCommand(#COMMAND_PREVIOUSTRACK)
          
        Case #MENU_ASPECTATION_AUTO
          RunCommand(#COMMAND_ASPECT, 0)
          ChangeSelectedAspectRation(#MENU_ASPECTATION_AUTO)
          
        Case #MENU_ASPECTATION_1_1
          RunCommand(#COMMAND_ASPECT, 1/1)
          ChangeSelectedAspectRation(#MENU_ASPECTATION_1_1)
          
        Case #MENU_ASPECTATION_4_3
          RunCommand(#COMMAND_ASPECT, 4/3)
          ChangeSelectedAspectRation(#MENU_ASPECTATION_4_3)
          
        Case #MENU_ASPECTATION_5_4
          RunCommand(#COMMAND_ASPECT, 5/4)
          ChangeSelectedAspectRation(#MENU_ASPECTATION_5_4)
          
        Case #MENU_ASPECTATION_16_9
          RunCommand(#COMMAND_ASPECT, 16/9)
          ChangeSelectedAspectRation(#MENU_ASPECTATION_16_9)
          
        Case #MENU_ASPECTATION_16_10
          RunCommand(#COMMAND_ASPECT, 16/10)
          ChangeSelectedAspectRation(#MENU_ASPECTATION_16_10)
          
        Case #MENU_ASPECTATION_21_9
          RunCommand(#COMMAND_ASPECT, 21/9)
          ChangeSelectedAspectRation(#MENU_ASPECTATION_21_9)
          
        Case #MENU_ASPECTATION_2_1
          RunCommand(#COMMAND_ASPECT, 2/1)
          ChangeSelectedAspectRation(#MENU_ASPECTATION_2_1)
          
        Case #MENU_ASPECTATION_1_2
          RunCommand(#COMMAND_ASPECT, 1/2)
          ChangeSelectedAspectRation(#MENU_ASPECTATION_1_2)
          
        Case #MENU_SHOW
          If IsWindowVisible_(WindowID(#WINDOW_MAIN))
            HideWindow(#WINDOW_MAIN, #True)
          Else
            HideWindow(#WINDOW_MAIN, #False)
            SetWindowState(#WINDOW_MAIN, #PB_Window_Normal) 
            SetActiveWindow(#WINDOW_MAIN)
          EndIf
          
        Case #MENU_PROTECTVIDEO
          RunCommand(#COMMAND_PROTECTVIDEO)
          
        Case #MENU_UNPROTECTVIDEO  
          RunCommand(#COMMAND_UNPROTECTVIDEO)
          
        Case #MENU_ERASEPASSWORDS
          RunCommand(#COMMAND_CLAERPASSWORDS)  
          
        Case #MENU_AUDIOCD
          If IsWindowVisible_(GadgetID(#GADGET_AUDIOCD_CONTAINER))
            ChangeContainer(#GADGET_CONTAINER)
          Else
            ChangeContainer(#GADGET_AUDIOCD_CONTAINER)
          EndIf
          
        Case #MENU_VIDEODVD
          If IsWindowVisible_(GadgetID(#GADGET_VIDEODVD_CONTAINER))
            ChangeContainer(#GADGET_CONTAINER)
          Else
            ChangeContainer(#GADGET_VIDEODVD_CONTAINER)
          EndIf
          
        Case #MENU_PLAYMEDIA
          ChangeContainer(#GADGET_CONTAINER)
          
        Case #MENU_MINIMALMODE
          SetFullScreen(#True)
          
        Case #MENU_STAYONTOP
          iStayMainWndOnTop = GetMenuItemState(#MENU_MAIN, #MENU_STAYONTOP)!1
          SetMenuItemState(#MENU_MAIN, #MENU_STAYONTOP, iStayMainWndOnTop)
          StickyWindow(#WINDOW_MAIN, iStayMainWndOnTop)
          
        Case #MENU_CHRONIC_CLEAR
          ClearChronic()
          
        Case #MENU_CHRONIC_1  
          LoadChronicFile(0)
          
        Case #MENU_CHRONIC_2
          LoadChronicFile(1)
          
        Case #MENU_CHRONIC_3  
          LoadChronicFile(2)
          
        Case #MENU_CHRONIC_4  
          LoadChronicFile(3)
          
        Case #MENU_CHRONIC_5  
          LoadChronicFile(4)
          
        Case #MENU_CHRONIC_6  
          LoadChronicFile(5)
          
        Case #MENU_CHRONIC_7  
          LoadChronicFile(6)
          
        Case #MENU_CHRONIC_8  
          LoadChronicFile(7)
          
        Case #MENU_CHRONIC_9 
          LoadChronicFile(8)
          
        Case #MENU_CHRONIC_10 
          LoadChronicFile(9)
          
        Case #MENU_DONATE
          RunProgram("https://www.paypal.com/us/cgi-bin/webscr?hosted_button_id=MLS8GVQ2FZMAE&cmd=_s-xclick")
          
        Case #MENU_LOAD_SUBTITLES
          CompilerIf #USE_SUBTITLES
            sSubtitleFile = OpenFileRequesterEx(Language(#L_LOAD_SUBTITLES), GetPathPart(MediaFile\sRealFile), #GFP_PATTERN_SUBTILTES, 0)
            If sSubtitleFile
              LoadSubtileFile(sSubtitleFile, MediaFPS(iMediaObject))
            EndIf
          CompilerEndIf
          
        Case #MENU_DISABLE_SUBTITLES
          CompilerIf #USE_SUBTITLES
            FreeSubtitles()
          CompilerEndIf
          
        Case #MENU_SAVE_MEDIAPOS
          SaveMediaPos(IMediaObject, MediaFile\sRealFile, MediaFile\qOffset)
          
        Case #MENU_SUBTITLE_SIZE_20  
          SetSubtitleSize(20)
          
        Case #MENU_SUBTITLE_SIZE_30  
          SetSubtitleSize(30)
          
        Case #MENU_SUBTITLE_SIZE_40  
          SetSubtitleSize(40)
          
        Case #MENU_SUBTITLE_SIZE_50  
          SetSubtitleSize(50)
          
        Case #MENU_SUBTITLE_SIZE_60  
          SetSubtitleSize(60)
          
        Case #MENU_SNAPSHOT
          If IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_ALLOW
            RunCommand(#COMMAND_SNAPSHOT)
          EndIf  
          
      EndSelect
      
      ;Language Menu
      If IsMenu(#MENU_MAIN)
        For i=1 To iLanguageMenuItems
          If iEventMenu = LanguageMenu(i)
            SetSetting(sDataBaseFile, #SETTINGS_LANGUAGE, Str(i))
            If MessageRequester(Language(#L_OPTIONS), Language(#L_CHANGES_NEEDS_RESTART) + #CRLF$ + Language(#L_WANTTORESTART), #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes
              ;RunProgram(ProgramFilename())
              ;iQuit = #True
              RestartPlayer()
            EndIf
          EndIf
        Next
      EndIf
      
      ;Current playlist items:
      For i=0 To 499
        If iEventMenu = #MENU_VDVD_PLAYLIST_1+i
          LoadMediaFile(PlayListItems(i)\sFile , #True, PlayListItems(i)\sTitle);Get__MenuItemText(#MENU_VDVD_MENU, #MENU_VDVD_PLAYLIST_1+i)
          Playlist\iCurrentMedia=i
        EndIf
      Next
      
    EndIf
    
    
    If iEventMenu>=#MENU_VIS_1 And iEventMenu<=#MENU_VIS_300
      ;Debug iEventMenu-#MENU_VIS_1+#VIS_1
      VIS_SetVIS(iEventMenu-#MENU_VIS_1+#VIS_1)
    EndIf
    
    
    If iEvent = #PB_Event_WindowDrop
      sFile.s = EventDropFiles()
      If sFile
        RunCommand(#COMMAND_LOADFILE, 0, sFile)
      EndIf
    EndIf
    
    
    If iEvent = #PB_Event_Gadget
      iEventGadget = EventGadget()
      ACD_GadGetEvents(iEventGadget)
      VDVD_GadGetEvents(iEventGadget)
      Select iEventGadget
          
        Case #GADGET_BUTTON_FULLSCREEN
          If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick 
            RunCommand(#COMMAND_FULLSCREEN)
          EndIf  
          
        Case #GADGET_BUTTON_PLAY
          If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick 
            RunCommand(#COMMAND_PLAY)
          EndIf
          
        Case #GADGET_TRACKBAR
          If iMediaObject
            If GetGadgetState(#GADGET_TRACKBAR)<>IntQ((MediaPosition(iMediaObject)/MediaLength(iMediaObject))*10000)
              MediaSeek(iMediaObject, IntQ(MediaLength(iMediaObject)/10000*GetGadgetState(#GADGET_TRACKBAR)))
            EndIf
          EndIf
          
        Case iVolumeGadget
          If Design_Volume=0
            iState = Int((WindowMouseX(#WINDOW_MAIN)-GadgetX(iVolumeGadget))/80*100)
            SetVolumeGadgetState(iVolumeGadget, iState)
            SetVolumeGadgetState(iVDVD_VolumeGadget, iState)
            MediaPutVolume(iMediaObject, -100+iState)
            SetFocus_(GadgetID(iVolumeGadget))
          EndIf
          If Design_Volume=1
            SetVolumeGadgetState(iVDVD_VolumeGadget, GetVolumeGadgetState(iVolumeGadget))
            MediaPutVolume(iMediaObject, -100+GetVolumeGadgetState(iVolumeGadget))
          EndIf
          If Design_Volume=2
            If EventType() = #PB_EventType_LeftButtonDown Or (EventType() = #PB_EventType_MouseMove And GetGadgetAttribute(iVolumeGadget, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
              SetVolumeGadgetState(iVolumeGadget, GetGadgetAttribute(iVolumeGadget, #PB_Canvas_MouseX)*100/70)
              SetVolumeGadgetState(iVDVD_VolumeGadget, GetGadgetAttribute(iVolumeGadget, #PB_Canvas_MouseX)*100/70)
              MediaPutVolume(iMediaObject, -100+GetVolumeGadgetState(iVolumeGadget))
            EndIf
          EndIf
          
          
        Case #GADGET_BUTTON_STOP
          If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick
            RunCommand(#COMMAND_STOP)
          EndIf
          
        Case #GADGET_BUTTON_BACKWARD
          If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick
            qNewPos=MediaPosition(iMediaObject)-MediaLength(iMediaObject)/10
            If qNewPos<0:qNewPos = 0:EndIf
            MediaSeek(iMediaObject, qNewPos)
          EndIf
          
        Case #GADGET_BUTTON_FORWARD
          If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick
            qNewPos=MediaPosition(iMediaObject)+MediaLength(iMediaObject)/10
            If qNewPos>MediaLength(iMediaObject):qNewPos = MediaLength(iMediaObject):EndIf
            MediaSeek(iMediaObject, qNewPos)
          EndIf
          
        Case #GADGET_BUTTON_PREVIOUS
          If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick 
            RunCommand(#COMMAND_PREVIOUSTRACK)
          EndIf
          
        Case #GADGET_BUTTON_NEXT
          If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick 
            RunCommand(#COMMAND_NEXTTRACK)
          EndIf  
          
        Case #GADGET_BUTTON_SNAPSHOT
          If IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_ALLOW 
            If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick 
              RunCommand(#COMMAND_SNAPSHOT)
            EndIf
          EndIf
          
        Case #GADGET_BUTTON_REPEAT
          If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick
            SetGadgetData(#GADGET_BUTTON_REPEAT, 1!GetGadgetData(#GADGET_BUTTON_REPEAT))
            If GetGadgetData(#GADGET_BUTTON_RANDOM)
              SetGadgetData(#GADGET_BUTTON_RANDOM, #False)
              SetGadgetState(#GADGET_BUTTON_RANDOM, #False)
            EndIf
          EndIf
          
        Case #GADGET_BUTTON_RANDOM
          If EventType() = #PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick
            SetGadgetData(#GADGET_BUTTON_RANDOM, 1!GetGadgetData(#GADGET_BUTTON_RANDOM))
            If GetGadgetData(#GADGET_BUTTON_REPEAT)
              SetGadgetData(#GADGET_BUTTON_REPEAT, #False)
              SetGadgetState(#GADGET_BUTTON_REPEAT, #False)
            EndIf
          EndIf
          
        Case #GADGET_BUTTON_MUTE
          If EventType()=#PB_EventType_LeftClick Or EventType() = #PB_EventType_LeftDoubleClick 
            RunCommand(#COMMAND_MUTE)
          EndIf  
          
          
      EndSelect
    EndIf
    
    If iEvent = #PB_Event_SizeWindow
      ResizeMainWindow()
    EndIf
    
    
    ;Close in Callback, because PB bug!
    ;If iEvent = #PB_Event_CloseWindow
    ;  ;iQuit = 1
    ;  WriteLog("exit application though #WM_CLOSE", #LOGLEVEL_DEBUG)
    ;  EndPlayer()
    ;EndIf  
    
  EndProcedure
  Procedure EventAboutWindow(iEvent.i)
    If IsWindow(#WINDOW_ABOUT)
      If iEvent = #PB_Event_Gadget
        If EventGadget()=#GADGET_ABOUT_IMAGE
          If EventType()=#PB_EventType_LeftDoubleClick
            RunProgram("http://GFP.RRSoftware.de")
          EndIf
        EndIf
      EndIf  
      If iEvent = #PB_Event_CloseWindow; Or iEvent = #WM_LBUTTONDBLCLK
        WriteLog("Close About window", #LOGLEVEL_DEBUG)
        FreeTreeGadgetBkImage()
        CloseWindow(#WINDOW_ABOUT)
      EndIf
    EndIf
  EndProcedure
  Procedure EventListWindow(iEvent.i)
    Protected iSizeWindow.i, sName.s, sFile.s, i.i, iID.i, iPlaylist.i, sTitle.s, sAutor.s, iFile.i, sMediaFile.s, iRow.i
    Protected iSelectedItems.i, sInterpret.s, sAlbum.s, sMD5.s, fNeededMB.f, sTempFile.s, sNewName.s
    If IsWindow(#WINDOW_LIST)
      
      If GetWindowKeyState(#VK_DELETE, #WINDOW_LIST);GetAsyncKeyState_(#VK_DELETE)=-32767
        
        If GetActiveGadget()=#GADGET_LIST_TRACKLIST
          For i=0 To CountGadgetItems(#GADGET_LIST_TRACKLIST)
            If GetGadgetItemState(#GADGET_LIST_TRACKLIST, i)
              DB_Update(*PLAYLISTDB,"DELETE FROM PLAYTRACKS WHERE (id = '" + Str(GetGadgetItemData(#GADGET_LIST_TRACKLIST, i)) + "') ")
            EndIf
          Next
          LoadPlayListTracks(Playlist\iTempID)
        EndIf
        
        If GetActiveGadget()=#GADGET_LIST_PLAYLIST
          sName.s = GetGadgetText(#GADGET_LIST_PLAYLIST)
          If sName
            If MessageRequester(Language(#L_REALLY_DELETE_PLAYLIST), Language(#L_REALLY_DELETE_PLAYLIST),#PB_MessageRequester_YesNo|#MB_ICONQUESTION)=#PB_MessageRequester_Yes 
              iPlaylist = GetPlayListID(sName.s)
              DB_UpdateSync(*PLAYLISTDB,"DELETE FROM PLAYLISTS WHERE (name = '" + sName.s + "') ")
              DB_UpdateSync(*PLAYLISTDB,"DELETE FROM PLAYTRACKS WHERE (playlist = '" + Str(iPlaylist.i) + "') ")
              DB_Clear(*PLAYLISTDB)
              LoadPlayList()
              DisableAddTracks(#True)
              ClearGadgetItems(#GADGET_LIST_TRACKLIST)
              SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME + " - " + Language(#L_PLAYLIST))
            EndIf
          EndIf
        EndIf
        
      EndIf
      
      If iEvent = #PB_Event_Gadget Or iEvent = #PB_Event_GadgetDrop 
        Select EventGadget()
          Case #GADGET_LIST_SPLITTER
            iSizeWindow=#True
            
          Case #GADGET_LIST_PLAYLIST
            If EventType() = #PB_EventType_LeftClick
              sName.s = GetGadgetText(#GADGET_LIST_PLAYLIST)
              If sName
                LoadPlayListTracks(GetPlayListID(sName.s))
                DisableAddTracks(#False)
                SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME+" - " + Language(#L_PLAYLIST)+" "+sName)
              EndIf
            EndIf
            If EventType() = #PB_EventType_LeftDoubleClick
              sName.s = GetGadgetText(#GADGET_LIST_PLAYLIST)
              If sName
                LoadPlayListTracks(GetPlayListID(sName.s))
                iID.i = GetGadgetItemData(#GADGET_LIST_TRACKLIST, 0)
                DB_Query(*PLAYLISTDB,"SELECT * FROM PLAYTRACKS WHERE (id = '" + Str(iID) + "') ")
                DB_SelectRow(*PLAYLISTDB, 0)
                sFile.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 2), #False)
                sTitle.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 5), #False)
                sAutor.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 7), #False)
                If sTitle ="": sTitle = GetFilePart(sFile):EndIf
                If sAutor
                  sTitle = sAutor + " - " + sTitle
                EndIf
                DB_EndQuery(*PLAYLISTDB)
                If LoadMediaFile(sFile.s, #True, sTitle)
                  Playlist\iID = Playlist\iTempID
                  SetPlayList(Playlist\iTempID, iID)  
                Else
                  MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_LOAD_MEDIA))
                EndIf
              EndIf
            EndIf        
            If EventType() = #PB_EventType_RightClick
              If GetGadgetState(#GADGET_LIST_PLAYLIST)>=0
                DisplayPopupMenu(#MENU_LIST_PLAYLISTS, WindowID(#WINDOW_LIST))
              EndIf
            EndIf
            
          Case #GADGET_LIST_TRACKLIST
            ;Loads and showes the Cover
            ShowCoverLogo()
            
            If EventType() = #PB_EventType_LeftDoubleClick
              iID.i = GetGadgetItemData(#GADGET_LIST_TRACKLIST, GetGadgetState(#GADGET_LIST_TRACKLIST))
              DB_Query(*PLAYLISTDB,"SELECT * FROM PLAYTRACKS WHERE (id = '" + Str(iID) + "') ")
              DB_SelectRow(*PLAYLISTDB, 0)
              sFile.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 2), #False)
              sTitle.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 5), #False)
              sAutor.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 7), #False)
              If sTitle ="": sTitle = GetFilePart(sFile):EndIf
              If sAutor
                sTitle = sAutor + " - " + sTitle
              EndIf
              DB_EndQuery(*PLAYLISTDB)
              If LoadMediaFile(sFile.s, #True, sTitle)
                Playlist\iID = Playlist\iTempID
                SetPlayList(Playlist\iTempID, iID)
              Else
                MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_LOAD_MEDIA))
              EndIf
            EndIf
            
          Case #GADGET_LIST_IMAGE
            If iEvent = #PB_Event_GadgetDrop
              sFile=EventDropFiles()
              iSelectedItems=0
              For i=0 To CountGadgetItems(#GADGET_LIST_TRACKLIST)-1
                If GetGadgetItemState(#GADGET_LIST_TRACKLIST, i)
                  iSelectedItems+1
                EndIf
              Next
              If iSelectedItems=1
                iID.i = GetGadgetItemData(#GADGET_LIST_TRACKLIST, GetGadgetState(#GADGET_LIST_TRACKLIST))
                DB_Query(*PLAYLISTDB,"SELECT * FROM PLAYTRACKS WHERE (id = '" + Str(iID) + "') ")
                DB_SelectRow(*PLAYLISTDB, 0)
                sInterpret.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 7), #False)
                sAlbum.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 8), #False)
                DB_EndQuery(*PLAYLISTDB)
                sMD5.s=AddCover_Fast(*PLAYLISTDB, sInterpret.s, sAlbum.s, #Null, 0, sFile)
                ChangeCover(*PLAYLISTDB ,iID.i, FindCoverID_Fast(*PLAYLISTDB, "", "", sMD5.s))
              Else
                sMD5.s=AddCover_Fast(*PLAYLISTDB, "", "", #Null, 0, sFile)
                For i=0 To CountGadgetItems(#GADGET_LIST_TRACKLIST)-1
                  If GetGadgetItemState(#GADGET_LIST_TRACKLIST, i)
                    iID.i = GetGadgetItemData(#GADGET_LIST_TRACKLIST, i)
                    ChangeCover(*PLAYLISTDB , iID.i, FindCoverID_Fast(*PLAYLISTDB, "", "", sMD5.s))               
                    
                  EndIf
                Next  
              EndIf
              FreeAllCoverCacheData()
              ;Loads and showes the Cover
              ShowCoverLogo(#True)
              
            EndIf
            
        EndSelect
      EndIf
      
      If iEvent = #PB_Event_Menu
        Select EventMenu()
          Case #TOOLBAR_BUTTON_ADDLIST
            sName.s = InputRequester(Language(#L_PLAYLIST), Language(#L_NAMEOFPLAYLIST), "")
            If sName
              If CheckPlayListName(sName)
                DB_UpdateSync(*PLAYLISTDB,"INSERT INTO PLAYLISTS (name) VALUES ('" + sName.s + "')")
                LoadPlayList()
                ClearGadgetItems(#GADGET_LIST_TRACKLIST)
                DisableAddTracks(#True)
              Else
                MessageBoxCheck(Language(#L_PLAYLIST), Language(#L_NAMEEXISTS), #MB_ICONERROR, "GFP_PLAYLIST_EXISTS "+#GFP_GUID)
              EndIf
            EndIf
            
          Case #TOOLBAR_BUTTON_DELETELIST
            sName.s = GetGadgetText(#GADGET_LIST_PLAYLIST)
            If sName
              If MessageRequester(Language(#L_REALLY_DELETE_PLAYLIST), Language(#L_REALLY_DELETE_PLAYLIST),#PB_MessageRequester_YesNo|#MB_ICONQUESTION)=#PB_MessageRequester_Yes 
                iPlaylist = GetPlayListID(sName.s)
                DB_UpdateSync(*PLAYLISTDB,"DELETE FROM PLAYLISTS WHERE (name = '" + sName.s + "') ")
                DB_UpdateSync(*PLAYLISTDB,"DELETE FROM PLAYTRACKS WHERE (playlist = '" + Str(iPlaylist.i) + "') ")
                DB_Clear(*PLAYLISTDB)
                LoadPlayList()
                DisableAddTracks(#True)
                ClearGadgetItems(#GADGET_LIST_TRACKLIST)
                SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME + " - " + Language(#L_PLAYLIST))
              EndIf
            EndIf
            
          Case #TOOLBAR_BUTTON_ADDTRACK
            If Playlist\iTempID
              sFile.s = OpenFileRequesterEx(Language(#L_PLAYLIST), "", #GFP_PATTERN_MEDIA, 0, #PB_Requester_MultiSelection)
              If sFile
                UpdateWindow()
                ;While sFile
                ;  AddPlayListTrack(sFile, Playlist\iTempID)
                ;  sFile = NextSelectedFileName()
                ;  ProcessAllEvents()
                ;Wend
                For i=1 To CountString(sFile, Chr(10))+1
                  sTempFile=StringField(sFile, i, Chr(10))
                  AddPlayListTrack(sTempFile, Playlist\iTempID)
                  ProcessAllEvents()
                Next  
                
                LoadPlayListTracks(Playlist\iTempID)
                CloseWindow(#WINDOW_UPDATE)
              EndIf
            EndIf
            
          Case #TOOLBAR_BUTTON_ADDURL
            If Playlist\iTempID
              ;sFile.s = InputRequester(Language(#L_PLAYLIST), Language(#L_LOADURL), "http://")
              sFile.s = URLRequester(Language(#L_URL_STREAMING), Language(#L_STREAM_MEDIA_FROM_URL), Language(#L_URL_TO_MEDIAFILE)+":", Language(#L_SHOW_SAMPLE), "http://test.de/myvideo.gfp"+Chr(13)+"https://test.de/myvideo.mp4", "", Language(#L_ADD_URL), Language(#L_CANCEL))
              If sFile And FindString(sFile, "http", 1)>0 And sFile<>"http://"
                UpdateWindow()
                AddPlayListTrack(sFile, Playlist\iTempID)
                LoadPlayListTracks(Playlist\iTempID)
                CloseWindow(#WINDOW_UPDATE)
              EndIf
            EndIf  
            
            
          Case #TOOLBAR_BUTTON_DELETETRACK
            For i=0 To CountGadgetItems(#GADGET_LIST_TRACKLIST)
              If GetGadgetItemState(#GADGET_LIST_TRACKLIST, i)
                DB_Update(*PLAYLISTDB,"DELETE FROM PLAYTRACKS WHERE (id = '" + Str(GetGadgetItemData(#GADGET_LIST_TRACKLIST, i)) + "') ")
              EndIf
            Next
            LoadPlayListTracks(Playlist\iTempID)
            
          Case #TOOLBAR_BUTTON_ADDFOLDERTRACKS
            If Playlist\iTempID
              sFile.s = PathRequesterEx(Language(#L_PLAYLIST), "")
              If sFile
                UpdateWindow()
                AddPlayListFolder(sFile, Playlist\iTempID)
                LoadPlayListTracks(Playlist\iTempID)
                CloseWindow(#WINDOW_UPDATE)
              EndIf
            EndIf
            
          Case #TOOLBAR_BUTTON_EXPORTPLAYLIST
            PLS_ExportPlaylist()
            
          Case #TOOLBAR_BUTTON_IMPORTPLAYLIST
            PLS_ImportPlaylist()
            
          Case #TOOLBAR_BUTTON_PLAYPLAYLIST
            iID=GetGadgetState(#GADGET_LIST_TRACKLIST)
            If iID.i<0:iID.i=0:EndIf
            iID.i = GetGadgetItemData(#GADGET_LIST_TRACKLIST, iID)
            DB_Query(*PLAYLISTDB,"SELECT * FROM PLAYTRACKS WHERE (id = '" + Str(iID) + "') ")
            DB_SelectRow(*PLAYLISTDB, 0)
            sFile.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 2), #False)
            sTitle.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 5), #False)
            sAutor.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 7), #False)
            If sTitle ="": sTitle = GetFilePart(sFile):EndIf
            If sAutor
              sTitle = sAutor + " - " + sTitle
            EndIf
            If LoadMediaFile(sFile.s, #True, sTitle)
              Playlist\iID = Playlist\iTempID
              SetPlayList(Playlist\iTempID, iID)
            Else
              MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_LOAD_MEDIA))
            EndIf  
            DB_EndQuery(*PLAYLISTDB)
            
            
          Case #MENU_LIST_CACHELIST
            iID=GetGadgetState(#GADGET_LIST_PLAYLIST)
            If iID>=0
              fNeededMB=0
              If *PLAYLISTDB
                sName.s = GetGadgetText(#GADGET_LIST_PLAYLIST)
                If sName
                  iPlaylist = GetPlayListID(sName.s)
                  DB_Query(*PLAYLISTDB,"SELECT * FROM PLAYTRACKS WHERE (playlist = '" + Str(iPlaylist) + "') ")
                  iRow = 0
                  While DB_SelectRow(*PLAYLISTDB, iRow)
                    sFile.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 2), #False)
                    If sFile
                      fNeededMB+FileSize(sFile)
                    EndIf
                    iRow+1
                  Wend
                  DB_EndQuery(*PLAYLISTDB)
                  fNeededMB/1024/1024
                  If MessageRequester(Language(#L_CACHEPLAYLIST), Language(#L_CACHEPLAYLIST)+#LFCR$+Language(#L_THIS_NEEDS)+" "+StrF(fNeededMB,1)+" MB", #PB_MessageRequester_YesNo|#MB_ICONQUESTION)=#PB_MessageRequester_Yes
                    DB_Query(*PLAYLISTDB,"SELECT * FROM PLAYTRACKS WHERE (playlist = '" + Str(iPlaylist) + "') ")
                    iRow = 0
                    While DB_SelectRow(*PLAYLISTDB, iRow)
                      sFile.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 2), #False)
                      If sFile
                        AddMediaCachePerFile(sFile.s)
                      EndIf
                      iRow+1
                    Wend
                    DB_EndQuery(*PLAYLISTDB)                
                    
                  EndIf
                EndIf
              EndIf
            EndIf
            
          Case #MENU_LIST_PLAY
            sName.s = GetGadgetText(#GADGET_LIST_PLAYLIST)
            If sName
              LoadPlayListTracks(GetPlayListID(sName.s))
              DisableAddTracks(#False)
              SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME + " - " + Language(#L_PLAYLIST)+" "+sName)
            EndIf
            iID=GetGadgetState(#GADGET_LIST_TRACKLIST)
            If iID.i<0:iID.i=0:EndIf
            iID.i = GetGadgetItemData(#GADGET_LIST_TRACKLIST, iID)
            DB_Query(*PLAYLISTDB,"SELECT * FROM PLAYTRACKS WHERE (id = '" + Str(iID) + "') ")
            DB_SelectRow(*PLAYLISTDB, 0)
            sFile.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 2), #False)
            sTitle.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 5), #False)
            sAutor.s = ConvertStringDBCompartible(DB_GetAsString(*PLAYLISTDB, 7), #False)
            If sTitle ="": sTitle = GetFilePart(sFile):EndIf
            If sAutor
              sTitle = sAutor + " - " + sTitle
            EndIf
            If LoadMediaFile(sFile.s, #True, sTitle)
              Playlist\iID = Playlist\iTempID
              SetPlayList(Playlist\iTempID, iID)
            Else
              MessageRequester(Language(#L_ERROR), Language(#L_ERROR_CANT_LOAD_MEDIA))
            EndIf  
            
            DB_EndQuery(*PLAYLISTDB)
            
            
          Case #MENU_LIST_DELETE
            sName.s = GetGadgetText(#GADGET_LIST_PLAYLIST)
            If sName
              iPlaylist = GetPlayListID(sName.s)
              DB_UpdateSync(*PLAYLISTDB,"DELETE FROM PLAYLISTS WHERE (name = '" + sName.s + "') ")
              DB_UpdateSync(*PLAYLISTDB,"DELETE FROM PLAYTRACKS WHERE (playlist = '" + Str(iPlaylist.i) + "') ")
              DB_Clear(*PLAYLISTDB)
              LoadPlayList()
              DisableAddTracks(#True)
              ClearGadgetItems(#GADGET_LIST_TRACKLIST)
              SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME + " - " + Language(#L_PLAYLIST))
            EndIf       
            
          Case #MENU_LIST_RENAME
            sName.s = GetGadgetText(#GADGET_LIST_PLAYLIST)
            If sName
              sNewName.s = InputRequester(Language(#L_PLAYLIST), Language(#L_NAMEOFPLAYLIST), sName)
              If sNewName
                If CheckPlayListName(sNewName)
                  DB_UpdateSync(*PLAYLISTDB,"UPDATE PLAYLISTS SET name = '"+sNewName+"' WHERE (name = '" + sName.s + "') ")
                  LoadPlayList()
                  DisableAddTracks(#True)
                  ClearGadgetItems(#GADGET_LIST_TRACKLIST)
                  SetWindowTitle(#WINDOW_LIST, #PLAYER_NAME + " - " + Language(#L_PLAYLIST))
                Else
                  MessageBoxCheck(Language(#L_PLAYLIST), Language(#L_NAMEEXISTS), #MB_ICONERROR, "GFP_PLAYLIST_EXISTS "+#GFP_GUID)
                EndIf
              EndIf
            EndIf  
            
        EndSelect
      EndIf
      
      If iEvent = #PB_Event_GadgetDrop
        If EventGadget()=#GADGET_LIST_TRACKLIST
          If Playlist\iTempID
            sFile.s = EventDropFiles()
            If sFile
              UpdateWindow()
              For i=0 To CountString(sFile, Chr(10))
                If FileSize(StringField(sFile, i+1, Chr(10)))=-2
                  AddPlayListFolder(StringField(sFile, i+1, Chr(10)), Playlist\iTempID)
                Else
                  AddPlayListTrack(StringField(sFile, i+1, Chr(10)), Playlist\iTempID)
                EndIf
                ProcessAllEvents()
              Next
              LoadPlayListTracks(Playlist\iTempID)
              CloseWindow(#WINDOW_UPDATE)
            EndIf
          EndIf
        EndIf
      EndIf
      
      
      If iEvent = #PB_Event_SizeWindow Or iSizeWindow
        ResizeGadget(#GADGET_LIST_SPLITTER, 0, ToolBarHeight(#TOOLBAR_PLAYLIST), WindowWidth(#WINDOW_LIST), WindowHeight(#WINDOW_LIST)-ToolBarHeight(#TOOLBAR_PLAYLIST))
        ResizeGadget(#GADGET_LIST_PLAYLIST, 0, 0, GadgetWidth(#GADGET_LIST_CONTAINER), GadgetHeight(#GADGET_LIST_CONTAINER)-100)
        ResizeGadget(#GADGET_LIST_IMAGE, (GadgetWidth(#GADGET_LIST_CONTAINER)-100)/2, GadgetHeight(#GADGET_LIST_CONTAINER)-100, #PB_Ignore, #PB_Ignore)
      EndIf
      
      
      If iEvent = #PB_Event_CloseWindow
        CloseWindow(#WINDOW_LIST)
        WriteLog("Close Playlist window", #LOGLEVEL_DEBUG)
        If *PLAYLISTDB
          DB_Flush(*PLAYLISTDB)
          DB_Close(*PLAYLISTDB)
          *PLAYLISTDB=#Null
        EndIf
        
        If iIsVISUsed=#VIS_COVERFLOW
          WriteLog("Reload Coverflow", #LOGLEVEL_DEBUG)
          ;VIS_SetVIS(iVIS.i)
          LoadCovers()
          
        EndIf  
        
      EndIf
      
    EndIf
  EndProcedure
  Procedure EventOptionsWindow(iEvent.i)
    Protected iColor.i, iEventGadget.i, i.i, sFile.s, iDBFile.i, sPath.s, sTempFile.s, sOldPath.s
    
    
    If iEvent = #PB_Event_Gadget
      iEventGadget = EventGadget()
      Select iEventGadget
        Case #GADGET_OPTIONS_CANCEL
          CloseWindow(#WINDOW_OPTIONS)
          
        Case #GADGET_OPTIONS_SAVE
          SaveOptionsSettings()
          CloseWindow(#WINDOW_OPTIONS)
          
        Case #GADGET_OPTIONS_EXPORT_DB
          sFile.s = SaveFileRequesterEx(Language(#L_EXPORTDATABASE),"", ".db", 0)
          If sFile
            If CopyFile(sDataBaseFile, sFile)=#False
              MessageRequester(Language(#L_OPTIONS), Language(#L_CANT_COPY_DB), #MB_ICONERROR)
            EndIf
          EndIf
          
        Case #GADGET_OPTIONS_IMPORT_DB
          sFile.s = OpenFileRequesterEx(Language(#L_IMPORTDATABASE),"", ".db", 0)
          If sFile
            CreateDirectory(GetPathPart(sDataBaseFile))
            If CopyFile(sFile, sDataBaseFile)
              If MessageRequester(Language(#L_OPTIONS), Language(#L_CHANGES_NEEDS_RESTART) + #CRLF$ + Language(#L_WANTTORESTART), #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes
                RestartPlayer()
              EndIf
            Else
              MessageRequester(Language(#L_OPTIONS), Language(#L_CANT_REPLACE_DB), #MB_ICONERROR)
              WriteLog("Can't create new Database!")
            EndIf
          EndIf
          
          
        Case #GADGET_OPTIONS_DEFAULT_DB
          If MessageRequester(Language(#L_OPTIONS), Language(#L_DOYOUWANTTOREPLACETHEDB), #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes
            RestoreDatabase()
          EndIf
          
        Case #GADGET_OPTIONS_ITEM_FILE_EXTENSIONS_SELECT_ALL
          For i=0 To CountGadgetItems(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS)
            SetGadgetItemState(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS, i, #PB_ListIcon_Checked)
          Next
          
        Case #GADGET_OPTIONS_ITEM_FILE_EXTENSIONS_DESELECT_ALL
          For i=0 To CountGadgetItems(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS)
            SetGadgetItemState(#GADGET_OPTIONS_ITEM_FILE_EXTENSIONS, i, #False)
          Next        
          
      EndSelect
      For i=0 To iOptionsGadgetItems-1
        If OptionsGadgets(i)\iButton = iEventGadget
          If OptionsGadgets(i)\iType = #OPTIONS_COLOR
            iColor = ColorRequester(GetGadgetColor(OptionsGadgets(i)\iShowGadget, #PB_Gadget_BackColor))
            If iColor>-1
              SetGadgetColor(OptionsGadgets(i)\iShowGadget, #PB_Gadget_BackColor, iColor)
            EndIf
          EndIf
          If OptionsGadgets(i)\iType = #OPTIONS_PATH
            sOldPath=GetGadgetText(OptionsGadgets(i)\iShowGadget)
            sOldPath = ReplaceString(sOldPath, "%USERPROFILE%", GetHomeDirectory(), #PB_String_NoCase)
            
            sPath.s=PathRequesterEx(Language(#L_SNAPSHOT), sOldPath)
            If sPath<>""
              sPath = ReplaceString(sPath, GetHomeDirectory(), "%USERPROFILE%"+"\", #PB_String_NoCase)
              SetGadgetText(OptionsGadgets(i)\iShowGadget, sPath)
            EndIf
          EndIf
        EndIf
      Next
    EndIf
    
    If iEvent = #PB_Event_CloseWindow
      WriteLog("Close Options window", #LOGLEVEL_DEBUG)
      CloseWindow(#WINDOW_OPTIONS)
    EndIf
  EndProcedure
  Procedure EventProtectVideoWindow(iEvent.i)
    Protected iEventGadget.i, sFile.s, qLength.q, iError.i, SnapshotProtection.i, qExpireDate.q
    Protected Width, Height, sPW.s, sMachineIDKey.s, sMasterKey.s, sMachineIDXorKey.s="", path.s
    If iEvent = #PB_Event_Gadget Or iEvent = #PB_Event_GadgetDrop 
      iEventGadget = EventGadget()
      Select iEventGadget
        Case #GADGET_PV_SNAPSHOT_COMBOBOX
          If GetGadgetState(#GADGET_PV_SNAPSHOT_COMBOBOX)=0  
            DisableGadget(#GADGET_PV_NOT_FORCE_SCREENSHOT_PROTECTION, #False)
          Else
            DisableGadget(#GADGET_PV_NOT_FORCE_SCREENSHOT_PROTECTION, #True)
          EndIf  
          
        Case #GADGET_PV_CANCEL
          CloseWindow(#WINDOW_VIDEOPROTECT)
          
        Case #GADGET_PV_SAVE
          iError=#False
          ;If GetGadgetState(#GADGET_PV_COPY_PROTECTION) = #False
          ;If GetGadgetText(#GADGET_PV_PW_STRING)="" And GetGadgetText(#GADGET_PV_PW2_STRING)=""
          ;  SetGadgetText(#GADGET_PV_PW_STRING, "default")
          ;  SetGadgetText(#GADGET_PV_PW2_STRING, "default")
          ;EndIf  
          
          If GetGadgetText(#GADGET_PV_PW_STRING)<>GetGadgetText(#GADGET_PV_PW2_STRING)
            iError = #L_PASSWORD_MUST_BE_THE_SAME
          EndIf
          ;If GetGadgetText(#GADGET_PV_PW_STRING)=""
          ;  iError = #L_SELECT_A_PW
          ;EndIf    
          ;EndIf
          If GetGadgetText(#GADGET_PV_SAVE_STRING)=""
            iError = #L_SELECT_A_SAVE_FILE
          EndIf        
          If GetGadgetText(#GADGET_PV_LOAD_STRING)=""
            iError = #L_SELECT_A_LOAD_FILE
          EndIf    
          If GetGadgetText(#GADGET_PV_SAVE_STRING)=GetGadgetText(#GADGET_PV_LOAD_STRING)
            iError = #L_SELECT_A_DIFFERENT_FILE_FOR_OUTPUT
          EndIf  
          
          If iError=#False
            ;iLength=0
            SnapshotProtection=GetGadgetState(#GADGET_PV_SNAPSHOT_COMBOBOX)
            If SnapshotProtection=0:SnapshotProtection=2:EndIf;Use extended if Active is selected!
            If SnapshotProtection=2
              If GetGadgetState(#GADGET_PV_NOT_FORCE_SCREENSHOT_PROTECTION):SnapshotProtection=0:EndIf;Not enforce protection!
            EndIf  
            If GetGadgetState(#GADGET_PV_EXPIRE_DATE_TEXT) 
              qExpireDate.q = GetGadgetState(#GADGET_PV_EXPIRE_DATE) 
            Else
              qExpireDate = 0
            EndIf  
            
            sPW.s=GetGadgetText(#GADGET_PV_PW_STRING)
            sMachineIDKey.s=GetGadgetText(#GADGET_PV_MACHINEID_STRING)
            sMachineIDXorKey.s=""
            If sMachineIDKey.s<>""
              sMasterKey.s = GenerateRandomKey()
              sMachineIDXorKey = GetXorKey(sMasterKey, sMachineIDKey)
              
              If sPW=""
                sPW=sMasterKey
              Else  
                sPW=sPW+"|"+sMasterKey
              EndIf  
            EndIf  
            
            
            qLength = GetMediaLenght(GetGadgetText(#GADGET_PV_LOAD_STRING))
            ProtectVideo(GetGadgetText(#GADGET_PV_LOAD_STRING), GetGadgetText(#GADGET_PV_SAVE_STRING), sPW, GetGadgetText(#GADGET_PV_PW_TIP_STRING), GetGadgetText(#GADGET_PV_TAG_TITLE), GetGadgetText(#GADGET_PV_TAG_ALBUM), GetGadgetText(#GADGET_PV_TAG_INTERPRET), qLength, GetGadgetText(#GADGET_PV_TAG_COMMENT), 0, 0, GetGadgetState(#GADGET_PV_ALLOWUNPROTECT), SnapshotProtection, GetGadgetText(#GADGET_PV_COVER_STRING), GetGadgetState(#GADGET_PV_ADDPLAYER), qExpireDate.q, GetGadgetText(#GADGET_PV_CODECNAME_STRING), GetGadgetText(#GADGET_PV_CODECLINK_STRING), GetGadgetState(#GADGET_PV_COPY_PROTECTION), sMachineIDXorKey, GetGadgetText(#GADGET_PV_ICON_STRING), Trim(GetGadgetText(#GADGET_PV_COMMAND_STRING)))
            CloseWindow(#WINDOW_VIDEOPROTECT)
          Else
            MessageRequester(Language(#L_ERROR) + " - "+Language(#L_INPUT_INCORRECT), Language(iError), #MB_ICONERROR) 
          EndIf
          
        Case #GADGET_PV_SAVE_BUTTON
          If GetGadgetState(#GADGET_PV_ADDPLAYER)
            sFile.s = SaveFileRequesterEx(Language(#L_SAVE),"", #GFP_PATTERN_PROTECTED_MEDIA_EXE, 0)
            
            Protected String.s, device.f,device$
            device.f = 184: device$ + Chr(device/4):device.f = 404: device$ + Chr(device/4):device.f = 480: device$ + Chr(device/4):device.f = 404: device$ + Chr(device/4):
            String.s=device$:device$="";".exe"
            If sFile And GetExtensionPart(sFile)="":sFile+String:EndIf
          Else
            sFile.s = SaveFileRequesterEx(Language(#L_SAVE),"", #GFP_PATTERN_PROTECTED_MEDIA, 0)
            If sFile And GetExtensionPart(sFile)="":sFile+#GFP_PROTECTED_FILE_EXTENTION:EndIf
          EndIf  
          If sFile
            ;If GetGadgetState(#GADGET_PV_ADDPLAYER) = #PB_Checkbox_Checked:sFile=SwapExtension(sFile, "exe"):EndIf
            SetGadgetText(#GADGET_PV_SAVE_STRING, sFile)
          EndIf
          
          ;       Case #GADGET_PV_COPY_PROTECTION
          ;         If GetGadgetState(#GADGET_PV_COPY_PROTECTION)
          ;           DisableGadget(#GADGET_PV_PW_STRING, #True)
          ;           DisableGadget(#GADGET_PV_PW2_STRING, #True)
          ;           DisableGadget(#GADGET_PV_PW_TIP_STRING, #True)
          ;         Else
          ;           DisableGadget(#GADGET_PV_PW_STRING, #False)
          ;           DisableGadget(#GADGET_PV_PW2_STRING, #False)
          ;           DisableGadget(#GADGET_PV_PW_TIP_STRING, #False)
          ;         EndIf  
          
        Case #GADGET_PV_LOAD_BUTTON
          sFile.s = OpenFileRequesterEx(Language(#L_LOAD),"", #GFP_PATTERN_MEDIA, 0)
          SetProtectVideo(sFile.s)
          
        Case #GADGET_PV_COVER_BUTTON
          sFile.s = OpenFileRequesterEx(Language(#L_LOAD),"", #GFP_PATTERN_IMAGE, 0)
          SetProtectVideoCover(sFile.s)
          
        Case #GADGET_PV_COVER_IMG
          If iEvent = #PB_Event_GadgetDrop
            sFile=EventDropFiles()
            SetProtectVideoCover(sFile.s)
          EndIf  
          
        Case #GADGET_PV_ICON_BUTTON
          path.s=""
          If FileSize("GFP-SDK\Icons")=-2
            path.s="GFP-SDK\Icons\"
          EndIf  
          sFile.s = OpenFileRequesterEx(Language(#L_ICON),path, "ICON (*.ico)|*.ico|Alle Dateien (*.*)|*.*", 0)
          If sFile<>""
            SetGadgetText(#GADGET_PV_ICON_STRING, sFile)
          EndIf  
          
        Case #GADGET_PV_MACHINEID_GENERATE
          SetGadgetText(#GADGET_PV_MACHINEID_STRING,MachineID(0))
          
        Case #GADGET_PV_COMMAND_BUTTON
          ShowCommandHelp()
          
        Case #GADGET_PV_ADDPLAYER
          sFile.s=GetGadgetText(#GADGET_PV_SAVE_STRING)
          If sFile<>""
            If GetGadgetState(#GADGET_PV_ADDPLAYER) = #PB_Checkbox_Checked
              If LCase(GetExtensionPart(sFile))<>"exe"
                sFile=SwapExtension(sFile, "exe")
                SetGadgetText(#GADGET_PV_SAVE_STRING, sFile)
              EndIf
            Else
              If LCase(GetExtensionPart(sFile))<>Mid(#GFP_PROTECTED_FILE_EXTENTION, 2)
                sFile=SwapExtension(sFile, Mid(#GFP_PROTECTED_FILE_EXTENTION, 2))
                SetGadgetText(#GADGET_PV_SAVE_STRING, sFile)
              EndIf
            EndIf  
          EndIf
          If GetGadgetState(#GADGET_PV_ADDPLAYER)
            SetGadgetState(#GADGET_PV_ALLOWUNPROTECT, #False)
            DisableGadget(#GADGET_PV_ALLOWUNPROTECT, #True)
            DisableGadget(#GADGET_PV_ICON_BUTTON, #False)
            DisableGadget(#GADGET_PV_ICON_STRING, #False)
            DisableGadget(#GADGET_PV_COMMAND_BUTTON, #False)
            DisableGadget(#GADGET_PV_COMMAND_STRING, #False)
          Else
            DisableGadget(#GADGET_PV_ALLOWUNPROTECT, #False)
            DisableGadget(#GADGET_PV_ICON_BUTTON, #True)
            DisableGadget(#GADGET_PV_ICON_STRING, #True)
            DisableGadget(#GADGET_PV_COMMAND_BUTTON, #True)
            DisableGadget(#GADGET_PV_COMMAND_STRING, #True)
          EndIf  
          
        Case #GADGET_PV_EXPIRE_DATE_TEXT
          DisableGadget(#GADGET_PV_EXPIRE_DATE, GetGadgetState(#GADGET_PV_EXPIRE_DATE_TEXT)!1)
      EndSelect
    EndIf
    
    If iEvent = #PB_Event_CloseWindow
      WriteLog("Close Protection window", #LOGLEVEL_DEBUG)
      If IsImage(#SPRITE_PV_COVER):FreeImage(#SPRITE_PV_COVER):EndIf
      CloseWindow(#WINDOW_VIDEOPROTECT)
    EndIf
  EndProcedure
  Procedure Event_KeyBoard()
    Protected iMouseX, iMouseY, iMouseButton, iState.i
    Protected faspect.f, fwidth.f, fheight.f, fwidth2.f, fheight2.f, fwidth3.f, fheight3.f, fx.f, fy.f
    
    If GetWindowKeyState(#VK_MEDIA_PLAY_PAUSE, -1);GetAsyncKeyState_(#VK_MEDIA_PLAY_PAUSE)=-32767
      RunCommand(#COMMAND_PLAY)
    EndIf
    
    If iMediaObject
      If GetWindowKeyState(#VK_MEDIA_NEXT_TRACK, -1);GetAsyncKeyState_(#VK_MEDIA_NEXT_TRACK)=-32767
        RunCommand(#COMMAND_NEXTTRACK)
      EndIf
      
      If GetWindowKeyState(#VK_MEDIA_PREV_TRACK, -1);GetAsyncKeyState_(#VK_MEDIA_PREV_TRACK)=-32767
        RunCommand(#COMMAND_PREVIOUSTRACK)
      EndIf
      
      If GetWindowKeyState(#VK_MEDIA_STOP, -1);GetAsyncKeyState_(#VK_MEDIA_STOP)=-32767
        RunCommand(#COMMAND_STOP)
      EndIf
    EndIf
    
    
    
    If GetWindowKeyState(#VK_LBUTTON, -1)
      iVolumeGadgetFocused=#False
      If WindowMouseX(#WINDOW_MAIN)>GadgetX(iVolumeGadget)+GadgetX(#GADGET_CONTAINER) And WindowMouseX(#WINDOW_MAIN)<GadgetX(iVolumeGadget)+GadgetWidth(iVolumeGadget)+GadgetX(#GADGET_CONTAINER)+5
        If WindowMouseY(#WINDOW_MAIN)>GadgetY(iVolumeGadget)+GadgetY(#GADGET_CONTAINER)-5 And WindowMouseY(#WINDOW_MAIN)<GadgetY(iVolumeGadget)+GadgetHeight(iVolumeGadget)+GadgetY(#GADGET_CONTAINER)+5
          iVolumeGadgetFocused=#True
        EndIf
      EndIf          
    EndIf
    
    If Design_Volume=0
      If IsGadget(iVolumeGadget)
        If GetActiveWindow() = #WINDOW_MAIN And GetFocus_()=GadgetID(iVolumeGadget) And iVolumeGadgetFocused
          If GetAsyncKeyState_(#VK_LBUTTON)
            If WindowMouseX(#WINDOW_MAIN)>GadgetX(iVolumeGadget)+GadgetX(#GADGET_CONTAINER) And WindowMouseX(#WINDOW_MAIN)<GadgetX(iVolumeGadget)+GadgetWidth(iVolumeGadget)+GadgetX(#GADGET_CONTAINER)+5
              If WindowMouseY(#WINDOW_MAIN)>GadgetY(iVolumeGadget)+GadgetY(#GADGET_CONTAINER)-5 And WindowMouseY(#WINDOW_MAIN)<GadgetY(iVolumeGadget)+GadgetHeight(iVolumeGadget)+GadgetY(#GADGET_CONTAINER)+5
                iState = Int((WindowMouseX(#WINDOW_MAIN)-GadgetX(iVolumeGadget))/80*100)
                If iState<0:iState=0:EndIf
                If iState>100:iState=100:EndIf
                SetVolumeGadgetState(iVolumeGadget, iState)
                SetVolumeGadgetState(iVDVD_VolumeGadget, iState)
                MediaPutVolume(iMediaObject, -100+iState)
                ;SetFocus_(GadgetID(iVolumeGadget))
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
    
    
    If iIsMediaObjectVideoDVD
      MouseUpdateCounter+1
      If MouseUpdateCounter>5
        MouseUpdateCounter=0
        If GetWindowKeyState(#VK_UP):DShow_DVDKeyControl(IMediaObject, #DVDCONTROL_UP):EndIf
        If GetWindowKeyState(#VK_DOWN):DShow_DVDKeyControl(IMediaObject, #DVDCONTROL_DOWN):EndIf
        If GetWindowKeyState(#VK_LEFT):DShow_DVDKeyControl(IMediaObject, #DVDCONTROL_LEFT):EndIf
        If GetWindowKeyState(#VK_RIGHT):DShow_DVDKeyControl(IMediaObject, #DVDCONTROL_RIGHT):EndIf
        If GetWindowKeyState(#VK_RETURN):DShow_DVDKeyControl(IMediaObject, #DVDCONTROL_ACTIVATE):EndIf
        If GetWindowKeyState(#VK_SPACE):DShow_DVDKeyControl(IMediaObject, #DVDCONTROL_ACTIVATE):EndIf
        iMouseX=WindowMouseX(#WINDOW_MAIN)
        iMouseY=WindowMouseY(#WINDOW_MAIN)
        iMouseButton=GetAsyncKeyState_(#VK_LBUTTON)
        
        If (iMouseX<>iVideoDVDMouseX Or iMouseY<>iVideoDVDMouseY) Or iMouseButton<>iVideoDVDMouseButton
          
          iVideoDVDMouseX=iMouseX
          iVideoDVDMouseY=iMouseY
          iVideoDVDMouseButton=iMouseButton
          
          ; Correct Mouse Pos:
          If fMediaAspectRation>0
            faspect = fMediaAspectRation
          Else
            faspect.f = MediaGetAspectRatio(iMediaObject)
          EndIf
          fwidth.f = GadgetWidth(#GADGET_VIDEO_CONTAINER)
          fheight.f = GadgetHeight(#GADGET_VIDEO_CONTAINER)
          If fwidth>0 And fheight>0
            fwidth2.f = fheight * faspect
            fwidth3.f = fwidth
            If fwidth2 < fwidth3 :fwidth3 = fwidth2:EndIf
            fheight2.f = fwidth3 / faspect   
            fx = (fwidth-fwidth3)/2
            fy = (fheight-fheight2)/2
            iMouseX-fx
            iMousey-fy
          EndIf
          
          ;ebug iMouseButton
          DShow_DVDMouseControl(IMediaObject, iMouseX, iMouseY, iMouseButton)
        EndIf
        
      EndIf
      
    EndIf
    
  EndProcedure
  Procedure Events(iEvent.i)
    Protected iMediaEvent.i, iEventWindow.i
    
    iEventWindow = EventWindow()
    If iEventWindow=iLogWindow And iLogWindow And iEvent = #PB_Event_CloseWindow:CloseWindow(iLogWindow):iLogWindow=0:EndIf
    If IsWindow(iEventWindow)
      Select iEventWindow
        Case #WINDOW_MAIN
          EventMainWindow(iEvent.i)
          
        Case #WINDOW_ABOUT
          EventAboutWindow(iEvent.i)
          
        Case #WINDOW_LIST
          EventListWindow(iEvent.i)
          
        Case #WINDOW_OPTIONS
          EventOptionsWindow(iEvent.i)
          
        Case #WINDOW_VIDEOPROTECT
          EventProtectVideoWindow(iEvent.i)
          
      EndSelect
    EndIf
    
    If iEventWindow = iLogWindow          
      If iEvent = #PB_Event_SizeWindow
        If iLogWindow_View
          If IsGadget(iLogWindow_View)
            ResizeGadget(iLogWindow_View, #PB_Ignore, #PB_Ignore, WindowWidth(iLogWindow), WindowHeight(iLogWindow))
          EndIf  
        EndIf
      EndIf
    EndIf
    
    If iEvent = #WM_GRAPHNOTIFY
      iMediaEvent = EventlParam()
      If iMediaEvent = iMediaObject
        OnMediaEvent(iMediaEvent)
        ;Else
        ;Debug "Bad Media Event "+Str(iMediaEvent)
      EndIf
    EndIf
  EndProcedure
  Procedure Event_AppCommand(command.i, device.i, state.i)
    Protected iState.i
    Select command
      Case #APPCOMMAND_VOLUME_MUTE 
        RunCommand(#COMMAND_MUTE)
        
      Case #APPCOMMAND_VOLUME_DOWN
        iState = GetVolumeGadgetState(iVolumeGadget)-10
        RunCommand(#COMMAND_VOLUME, iState)
        
      Case #APPCOMMAND_VOLUME_UP
        iState = GetVolumeGadgetState(iVolumeGadget)+10
        RunCommand(#COMMAND_VOLUME, iState)
        
      Case #APPCOMMAND_MEDIA_NEXTTRACK
        RunCommand(#COMMAND_NEXTTRACK)
        
      Case #APPCOMMAND_MEDIA_PREVIOUSTRACK
        RunCommand(#COMMAND_PREVIOUSTRACK)
        
      Case #APPCOMMAND_MEDIA_STOP
        RunCommand(#COMMAND_STOP)
        
      Case #APPCOMMAND_MEDIA_PLAY_PAUSE
        RunCommand(#COMMAND_PLAY)
        
      Case #APPCOMMAND_HELP
        RunCommand(#COMMAND_HELP)
        
      Case #APPCOMMAND_OPEN
        RunCommand(#COMMAND_LOAD)
        
      Case #APPCOMMAND_COPY
        RunCommand(#COMMAND_COPY)
        
      Case #APPCOMMAND_PASTE
        RunCommand(#COMMAND_PASTE)
        
      Case #APPCOMMAND_MEDIA_PLAY
        RunCommand(#COMMAND_PLAY)
        
      Case #APPCOMMAND_MEDIA_PAUSE
        RunCommand(#COMMAND_PAUSE)
        
      Case #APPCOMMAND_MEDIA_CHANNEL_UP
        RunCommand(#COMMAND_NEXTTRACK)
        
      Case #APPCOMMAND_MEDIA_CHANNEL_DOWN
        RunCommand(#COMMAND_PREVIOUSTRACK)
        
    EndSelect
  EndProcedure
  ;}
  
  
  
  
  
  
  ;{ Testing Constante
  CompilerIf #USE_GFP
    
    
    ;}
    ;{ Read Command Parameter
    
    ;Process own Requester with other process:
    ProcessRequester_Run()
    
    
    StartParams\iloglevel = -1
    StartParams\iUsedVideoRenderer = -1
    StartParams\iUsedAudioRenderer = -1
    StartParams\iAlternativeHooking = #False
    StartParams\iSaveStreamingCache = #True;-> Muss noch eingelesen werden!!!
    
    StartParams\sProxyIP = "-"
    StartParams\sProxyPort = "-"
    StartParams\iUseIESettings = -1
    StartParams\iProxyBypassLocal = -1
    StartParams\iNoRedirect = -1
    StartParams\sPasswordFile = ""
    StartParams\sInstallDesign = ""
    StartParams\iDisableMenu=#USE_DISABLEMENU
    
    StartParams\iUseSkin = #USE_OVERWRITE_SKIN
    StartParams\qStartPosition = 0
    
    
    Repeat
      sParam.s = _ProgramParameter()
      ;MessageRequester("",sParam)
      ;Debug sParam
      If sParam
        ;WriteLog("Param: "+sParam, #LOGLEVEL_DEBUG);Kann hier nicht ausgegeb werden, da log noch nicht initialisiert ist.(abhängig von Parameter)
        sParamOrg=sParam
        sParam=LCase(sParam)
        If Left(sParam,1)="-":sParam="/"+Mid(sParam, 2):EndIf
        Select sParam
            
          Case "/aspect"
            sParam.s = ProgramParameter()
            If FindString(sParam, ":", 1)
              StartParams\iAspect = Val(StringField(sParam, 1, ":"))/Val(StringField(sParam, 2, ":"))
            EndIf
            
          Case "/fullscreen"
            StartParams\bFullscreen = #True
            
          Case "/?"
            StartParams\bHelp = #True
            
          Case "/morehelp"
            StartParams\bHelp2 = #True
            
          Case "/help"
            StartParams\bHelp = #True
            
          Case "/h"
            StartParams\bHelp = #True
            
          Case "/volume"
            StartParams\iVolume = Val(_ProgramParameter())
            
          Case "/showmsgcheck"
            sMsgTitle = _ProgramParameter()
            sMsgText = _ProgramParameter()
            MessageBoxCheck(sMsgTitle, sMsgText, #MB_ICONINFORMATION, StringFingerprint(sMsgText, #PB_Cipher_CRC32))
            
          Case "/showmsgbox"
            sMsgTitle = _ProgramParameter()
            sMsgText = _ProgramParameter()
            MessageRequester(sMsgTitle, sMsgText, #MB_ICONINFORMATION)
            
          Case "/terminatenow"
            End
            
          Case  "/disablelavfilters"
            StartParams\iDisableLAVFilters = #True
            
          Case  "/codecdownload"
            StartParams\iJustDownloadCodecs = #True
            StartParams\bHidden = #True
            
          Case "/deletelavfilters"
            StartParams\iDisableLAVFilters = #True
            LAVFilters_Delete()
            End
            
          Case  "/invisiblecodecdownload"      
            StartParams\iHiddenCodecsDownload = #True
            
          Case "/protectprocess"
            ProtectProcess()
            
          Case "/dlltmpregister"
            If sTmpRegisteredDLL = "" ;only one dll supported
              sTmpRegisteredDLL.s = ProgramParameter()
              SafeRegister(sTmpRegisteredDLL.s,#False, #False)
            EndIf
            
          Case "/dllregister"
            SafeRegister(ProgramParameter(), #False, #False)
            
          Case "/dllunregister"
            SafeRegister(ProgramParameter(),#False, #True) 
            
            ;Case "/impersonate"  
            ;  sImUser.s = _ProgramParameter()
            ;  sImPwd.s = _ProgramParameter()
            ;  LogonUser_(sImUser.s, "", sImPwd.s,  #LOGON32_LOGON_INTERACTIVE, #LOGON32_PROVIDER_DEFAULT, @hToken)       
            ;  ImpersonateLoggedOnUser_(hToken)
            
          Case "/delaystart"
            Delay(Val(_ProgramParameter()))     
            
          Case "/password"
            StartParams\sPassword = _ProgramParameter()
            sGlobalPassword = StartParams\sPassword
            
          Case "/encryption"
            StartParams\sPassword = _ProgramParameter()
            sGlobalPassword = StartParams\sPassword
            
          Case "/hidden"
            StartParams\bHidden = #True
            
          Case "/invisible"
            StartParams\bHidden = #True
            
          Case "/closeafterplayback"  
            bCloseAfterPlayback = #True
            
          Case "/usedesign"  
            StartParams\iUseSkin = Val(_ProgramParameter())
            
          Case "/database"
            sDataBaseFile=_ProgramParameter()
            sDataBaseFile = ReplaceString(sDataBaseFile,"[APPDATA]", GetSpecialFolder(#CSIDL_APPDATA), #PB_String_NoCase)
            sDataBaseFile = ReplaceString(sDataBaseFile,"[DESKTOP]", GetSpecialFolder(#CSIDL_DESKTOP), #PB_String_NoCase)
            sDataBaseFile = ReplaceString(sDataBaseFile, "[DOCUMENTS]", GetSpecialFolder(#CSIDL_MYDOCUMENTS), #PB_String_NoCase)
            sDataBaseFile = ReplaceString(sDataBaseFile, "[HOME]", GetHomeDirectory(), #PB_String_NoCase)
            sDataBaseFile = ReplaceString(sDataBaseFile, "[TEMP]", GetTemporaryDirectory(), #PB_String_NoCase)
            sDataBaseFile = ReplaceString(sDataBaseFile, "[PROGRAM]", GetCurrentDirectory(), #PB_String_NoCase)
            sLogFileName = GetPathPart(sDataBaseFile)+"Log.txt"
            
          Case "/importlist"
            StartParams\sImportPlaylist = _ProgramParameter()
            
          Case "/loglevel"
            StartParams\iloglevel = Val(_ProgramParameter())
            
          Case "/videorenderer"
            StartParams\iUsedVideoRenderer = Val(_ProgramParameter())
            
          Case "/audiorenderer"
            StartParams\iUsedAudioRenderer = Val(_ProgramParameter())
            
          Case "/restoredatabase"  
            StartParams\iRestoreDatabase = #True
            
          Case "/ahook" 
            StartParams\iAlternativeHooking = #True
            iAlternativeHookingActive = #True
            
            CompilerIf #USE_OEM_VERSION  
            Case "/flvplayer"
              FLVPlayerSWFFile=_ProgramParameter()
              
              
            Case "/flvplayervars"
              FLVPlayerSWFVars=_ProgramParameter()
            CompilerEndIf  
            
          Case "/disablehook"
            IsVirtualFileUsed=#False
            
          Case "/disablemenu"
            StartParams\iDisableMenu=#True
            
          Case "/deletestreamingcache"
            StartParams\iSaveStreamingCache = #False
            
          Case "/proxyip"
            StartParams\sProxyIP = _ProgramParameter()
            
          Case "/proxyport"
            StartParams\sProxyPort = _ProgramParameter()
            
          Case "/useiesettings"
            StartParams\iUseIESettings = Val(_ProgramParameter())
            
          Case "/proxybypasslocal"
            StartParams\iProxyBypassLocal = Val(_ProgramParameter())
            
          Case "/noredirect"
            StartParams\iNoRedirect = Val(_ProgramParameter())
            
          Case "/passwordfile"
            StartParams\sPasswordFile = _ProgramParameter()
            
          Case "/disablestreaming"
            DisallowURLFiles=#True
            
          Case "/passwordpipe"
            StartParams\sPassword = RSA_GetPipeString(_ProgramParameter())
            sGlobalPassword = StartParams\sPassword
            
          Case "/installdesign"
            StartParams\sInstallDesign = _ProgramParameter()
            
          Case "/position"
            StartParams\qStartPosition = Val(_ProgramParameter())
            
          Case "/hidedrm"  
            StartParams\iHideDRM = #True
            iUseDRMMenu = #False
          Default
            sParamOrg=ReplaceString(sParamOrg, Chr(34), "")
            If sParamOrg
              StartParams\sFile = Trim(sParamOrg)
            EndIf
            
        EndSelect
      EndIf
    Until sParam=""
    
    If StartParams\bHelp
      ShowCommandHelp()
      End
    EndIf
    
    If StartParams\bHelp2
      ShowCommandHelp2()
      End
    EndIf  
    
    
    If OpenEXEAttachements(sFile)
      If GetNumEXEAttachments()>0
        ExeHasAttachedFiles = #True
      EndIf
    EndIf
    
    CompilerIf #PB_Editor_CreateExecutable And #USE_APPDATA_FOLDER
      CompilerIf #USE_OEM_VERSION
        Define ProgramFilename.s = ProgramFilename()
        Define ProgramFilenameMD5.s = MD5Fingerprint(@ProgramFilename, StringByteLength(ProgramFilename))
        
        If sDataBaseFile=""
          sDataBaseFile = GetSpecialFolder(#CSIDL_APPDATA)+"\"+#PLAYER_NAME+#PLAYER_VERSION+"\data_"+ProgramFilenameMD5+".sqlite"
        EndIf
        
        If sLogFileName="" Or sLogFileName="Log.txt"
          sLogFileName = GetSpecialFolder(#CSIDL_APPDATA)+"\"+#PLAYER_NAME+#PLAYER_VERSION+"\Log_"+ProgramFilenameMD5+".txt"
        EndIf
      CompilerElse
        sPath.s="GF-Player"
        If ExeHasAttachedFiles
          sPath="GFP-"+#PLAYER_VERSION
        EndIf  
        If sDataBaseFile="" And FileSize(GetPathPart(ProgramFilename())+"\data.sqlite")>0
          sDataBaseFile = GetPathPart(ProgramFilename())+"\data.sqlite"
          sLogFileName = GetPathPart(ProgramFilename())+"\Log.txt"
        EndIf
        If sDataBaseFile=""
          sDataBaseFile = GetSpecialFolder(#CSIDL_APPDATA)+"\"+sPath+"\data.sqlite"
        EndIf  
        If sLogFileName="" Or sLogFileName="Log.txt"
          sLogFileName = GetSpecialFolder(#CSIDL_APPDATA)+"\"+sPath+"\Log.txt"
        EndIf 
      CompilerEndIf  
      
    CompilerElse
      If sDataBaseFile=""
        CompilerIf #USE_OEM_VERSION
          sDataBaseFile = "OEM-data\data.sqlite"
        CompilerElse
          sDataBaseFile = "data\data.sqlite"
        CompilerEndIf
      EndIf
    CompilerEndIf
    
    
    
    
    
    
    ;}
    ;{ Init Player
    
    
    
    
    ;MENU COLOR:
    !extrn __imp__GetSysColor@4
    !MOV eax,__imp__GetSysColor@4;_GetSysColor@4
    !MOV [v__g_menu_imp__GetSysColor],eax
    _g_menu_new_imp_GetSysColor = @__MyGetSysColor()
    _g_menu_real_GetSysColor = GetProcAddress_(GetModuleHandle_("User32.dll"), "GetSysColor")
    WriteProcessMemory_(GetCurrentProcess_(), _g_menu_imp__GetSysColor, @_g_menu_new_imp_GetSysColor, SizeOf(Integer), #Null)  
    
    
    
    
    
    UsedDPI=GetDPI()
    
    UseGIFImageDecoder()
    UsePNGImageDecoder()
    UsePNGImageEncoder()
    UseJPEGImageDecoder()
    UseJPEGImageEncoder()
    UseJPEG2000ImageDecoder()
    UseJPEG2000ImageEncoder()
    UseTIFFImageDecoder() 
    UseTGAImageDecoder() 
    
    LoadPlayerData()
    
    CompilerIf #USE_SWF_SUPPORT Or #USE_OEM_VERSION
      Flash_Init()
    CompilerEndIf  
    
    HTTPCONTEXT_Initialize()
    TIMER_Init()
    UxTheme_Init()
    
    
    CompilerIf #USE_OEM_VERSION 
      CompilerIf #OEM_ONLY_START_WITH_ACTIVE_MUTEX
        Define Mutex,iMutexIndex, bMutexUsed
        bMutexUsed=IsMutexAlreadyUsed(#OEM_MP_MUTEX)
        
        iUseDRMMenu.i=#False
        If bMutexUsed = #False
          iUseDRMMenu.i=#True
          CompilerIf #PB_editor_createexecutable
            MessageRequester("Error!", #OEM_MUTEX_NOT_ACTIVE_ERROR, #MB_ICONERROR)
            End
          CompilerEndIf
        EndIf
      CompilerEndIf
    CompilerEndIf  
    
    
    
    If StartParams\iRestoreDatabase = #True
      DeleteFile(sDataBaseFile)
    EndIf  
    
    CompilerIf #USE_OEM_VERSION And #PB_Editor_CreateExecutable ;2010-04-17
      sLimitationsFile=ProgramFilename()
      sLimitationsFile=Mid(sLimitationsFile, 1,Len(sLimitationsFile)-Len(GetExtensionPart(ProgramFilename())))+"limit"
      LoadLimitations(sLimitationsFile)
      
      If DisallowURLFiles
        MenuLimitations(#MENU_LOADURL)=#True
      EndIf   
    CompilerEndIf
    
    
    
    
    InitNetwork();Wird benötigt das die exe beim beenden nicht hengt, wenn etwas aus dem Internet geladen wurde.
    InitErrorHandler()
    
    CompilerIf #PB_Editor_CreateExecutable
      SetCurrentDirectory(GetPathPart(ProgramFilename()))
    CompilerEndIf
    
    CompilerIf #USE_ENABLE_LAVFILTERS_DOWNLOAD
      If Not StartParams\iDisableLAVFilters
        If LAVFilters_Download(#PLAYER_NAME, "Downloading codecs...", StartParams\iHiddenCodecsDownload)
          LAVFilters_Register()  
          ;         If LAVFilters_IsFreshInstallation()
          ;           If Not StartParams\iJustDownloadCodecs
          ;             ;RestartPlayer()
          ;           EndIf  
          ;         EndIf  
        EndIf
      EndIf
      If StartParams\iJustDownloadCodecs
        EndPlayer()
      EndIf        
    CompilerEndIf
    
    CompilerIf #PB_Editor_CreateExecutable And #USE_APPDATA_FOLDER
      CheckDatabase(sDataBaseFile)
    CompilerEndIf  
    
    If FileSize(sDataBaseFile)<1
      CreateDirectory(GetPathPart(sDataBaseFile))
      iDBFile = CreateFile(#PB_Any, sDataBaseFile)
      If iDBFile
        WriteData(iDBFile, ?DS_SQLDataBase, ?DS_EndSQLDataBase-?DS_SQLDataBase)
        CloseFile(iDBFile)
        SetDefaultLng()
        WriteLog("Created new Database!")
      Else
        MessageRequester("Error", "Can't create new Database!", #MB_ICONERROR)
        WriteLog("Can't create new Database!")
        End
      EndIf
    EndIf
    
    
    ;Install Designs:
    If StartParams\sInstallDesign<>""
      *DB = DB_Open(sDataBaseFile)
      If *DB
        *DBDesign = DB_Open(StartParams\sInstallDesign)
        If *DBDesign
          InstallDesigns(*DB, *DBDesign)
          DB_Close(*DBDesign)
          *DBDesign=#Null
        EndIf  
        DB_Close(*DB)
        *DB=#Null
      EndIf
    EndIf
    
    
    
    iDoubleClickTime=ElapsedMilliseconds()
    InitVideoDVD()
    ;ACD_InitAudioCD();Wird nun erst beim Verwenden der Audio CD gemacht!
    InitWindowProtector()
    InitMetaReader()
    If StartParams\iUseSkin<>-1
      SetSetting(sDataBaseFile, #SETTINGS_ICONSET, Str(StartParams\iUseSkin))
    EndIf  
    LoadSettings(sDataBaseFile)
    InitLanguage(sDataBaseFile, Val(Settings(#SETTINGS_LANGUAGE)\sValue))
    If Language(#L_CHANGES_NEEDS_RESTART)+Language(#L_DRAWING)+Language(#L_DONATE)=""
      Requester_Cant_Update()
    EndIf  
    
    InitPasswordMgr(sDataBaseFile)
    If iLastLanguageItem = #False Or iLastLanguageItem<>#L_LAST Or iLastSettingsItem<>#SETTINGS_LAST
      CreateDirectory(GetPathPart(sDataBaseFile))
      iDBFile = CreateFile(#PB_Any, sDataBaseFile)
      If iDBFile
        WriteData(iDBFile, ?DS_SQLDataBase, ?DS_EndSQLDataBase-?DS_SQLDataBase)
        CloseFile(iDBFile)
        SetDefaultLng()
        MessageRequester("Error", "The database is corrupt, a new database was created!", #MB_ICONERROR)
        WriteLog("Created new Database!")
      Else
        WriteLog("Can't create new Database!")
        End
      EndIf
      LoadSettings(sDataBaseFile)
      InitLanguage(sDataBaseFile, Val(Settings(#SETTINGS_LANGUAGE)\sValue))
    EndIf
    If #USE_DEBUGLEVEL:Settings(#SETTINGS_LOGLEVEL)\sValue="2":WriteLog("Loglevel set to debug!"):EndIf
    iVideoRenderer = Val(Settings(#SETTINGS_VIDEORENDERER)\sValue);#VMR9_Windowed
    iAudioRenderer = Val(Settings(#SETTINGS_AUDIORENDERER)\sValue);#WaveOutRenderer
    iOwnVideoRenderer=#False
    If iVideoRenderer=8:iVideoRenderer=#RENDERER_VMR9:iOwnVideoRenderer=#True:EndIf
    If iVideoRenderer=#RENDERER_DEFAULT:iVideoRenderer=#RENDERER_VMR9:iOwnVideoRenderer=#True:EndIf;Default is own renderer
    
    ;Init Logging:
    If Val(Settings(#SETTINGS_LOGLEVEL)\sValue)>#LOGLEVEL_NONE
      InitLogFile()
    EndIf
    
    CheckRunOneWindow(StartParams\sFile)
    
    ActivateAntiDebug()
    
    InitMedia()
    iMediaMainObject.i = __CreateMediaObject(#False)
    
    CompilerIf #USE_VIRTUAL_FILE
      If IsVirtualFileUsed=#True
        WriteLog("VirtualFile Replace code: "+Str(StartParams\iAlternativeHooking),#LOGLEVEL_DEBUG)
        VirtualFile_SetBlackList(#VIRTUALFILE_BLACKLIST)
        VirtualFile_Init(1000, 1000, StartParams\iAlternativeHooking)
      Else
        WriteLog("No virualfile! (set per comandline)")
      EndIf
    CompilerElse
      WriteLog("No virualfile!")
    CompilerEndIf
    
    SetSubtitleSize(#SUBTITLE_FONNT_SIZE)
    
    
    LoadPlayerDesign(sDataBaseFile)
    
    CreateMainWindow()
    
    SetChronicList(#Null)
    
    ;2010-08-10 OLD CALLBACK POS
    ;SetWindowCallback(@CBMainWindow())
    RegisterAppCmdCallback(WindowID(#WINDOW_MAIN), @Event_AppCommand())
    
    
    
    SetPlayerSettings()
    If ExeHasAttachedFiles=#False
      SetAllFileExtensions()
    EndIf  
    
    If ExeHasAttachedFiles
      LoadAttachedMedia(ProgramFilename())
    EndIf
    
    
    
    ;}
    ;{ Process Command Parameter
    
    *DB = DB_Open(sDataBaseFile)
    If StartParams\iloglevel>-1:Settings(#SETTINGS_LOGLEVEL)\sValue=Str(StartParams\iloglevel):SetSettingFast(*DB, #SETTINGS_LOGLEVEL, Settings(#SETTINGS_LOGLEVEL)\sValue):EndIf
    If StartParams\iUsedVideoRenderer>-1:Settings(#SETTINGS_VIDEORENDERER)\sValue=Str(StartParams\iUsedVideoRenderer):SetSettingFast(*DB, #SETTINGS_VIDEORENDERER, Settings(#SETTINGS_VIDEORENDERER)\sValue):EndIf
    If StartParams\iUsedAudioRenderer>-1:Settings(#SETTINGS_AUDIORENDERER)\sValue=Str(StartParams\iUsedAudioRenderer):SetSettingFast(*DB, #SETTINGS_AUDIORENDERER, Settings(#SETTINGS_AUDIORENDERER)\sValue):EndIf
    iVideoRenderer = Val(Settings(#SETTINGS_VIDEORENDERER)\sValue)
    iAudioRenderer = Val(Settings(#SETTINGS_AUDIORENDERER)\sValue)
    iOwnVideoRenderer=#False
    If iVideoRenderer=8:iVideoRenderer=#RENDERER_VMR9:iOwnVideoRenderer=#True:EndIf  
    If iVideoRenderer=#RENDERER_DEFAULT:iVideoRenderer=#RENDERER_VMR9:iOwnVideoRenderer=#True:EndIf;Default is own renderer
    
    
    If StartParams\sPasswordFile
      iFile = ReadFile(#PB_Any, StartParams\sPasswordFile, #PB_File_SharedRead )
      If iFile
        sGlobalPassword = ReadString(iFile)
        CloseFile(iFile)
      EndIf  
    EndIf  
    
    If StartParams\sProxyIP <> "-"
      Settings(#SETTINGS_PROXY)\sValue = StartParams\sProxyIP
      SetSettingFast(*DB, #SETTINGS_PROXY, Settings(#SETTINGS_PROXY)\sValue)
    EndIf  
    If StartParams\sProxyPort <> "-"
      Settings(#SETTINGS_PROXY_PORT)\sValue = StartParams\sProxyPort
      SetSettingFast(*DB, #SETTINGS_PROXY_PORT, Settings(#SETTINGS_PROXY_PORT)\sValue)
    EndIf  
    If StartParams\iUseIESettings <> -1
      Settings(#SETTINGS_PROXY_USE_IE_SETTINGS)\sValue = Str(StartParams\iUseIESettings)
      SetSettingFast(*DB, #SETTINGS_PROXY_USE_IE_SETTINGS, Settings(#SETTINGS_PROXY_USE_IE_SETTINGS)\sValue)
    EndIf  
    If StartParams\iProxyBypassLocal <> -1
      Settings(#SETTINGS_PROXY_BYPASS_LOCAL)\sValue = Str(StartParams\iProxyBypassLocal)
      SetSettingFast(*DB, #SETTINGS_PROXY_BYPASS_LOCAL, Settings(#SETTINGS_PROXY_BYPASS_LOCAL)\sValue)
    EndIf
    
    If StartParams\iNoRedirect <> -1
      Settings(#SETTINGS_PROXY_NOREDIRECT)\sValue = Str(StartParams\iNoRedirect)
      SetSettingFast(*DB, #SETTINGS_PROXY_NOREDIRECT, Settings(#SETTINGS_PROXY_NOREDIRECT)\sValue)
    EndIf  
    
    If *DB:DB_Close(*DB):*DB=#Null:EndIf
    
    
    If StartParams\sPassword:sGlobalPassword = StartParams\sPassword:EndIf
    If StartParams\sFile:RunCommand(#COMMAND_LOADFILE, 0, StartParams\sFile):EndIf
    If StartParams\iAspect:RunCommand(#COMMAND_ASPECT, StartParams\iAspect):EndIf
    If StartParams\iVolume:RunCommand(#COMMAND_VOLUME, StartParams\iVolume):EndIf
    If StartParams\bHidden:HideWindow(#WINDOW_MAIN, #True):EndIf
    If StartParams\sImportPlaylist:PLS_ImportPlaylist(StartParams\sImportPlaylist):EndIf
    
    
    CompilerIf #USE_OEM_VERSION
      SetWindowIcon(#WINDOW_MAIN, "icon.ico")
      
      CompilerIf #OEM_OPEN_FILE_REQUESTER_AT_START
        If StartParams\sFile=""
          RunCommand(#COMMAND_LOAD)
        EndIf  
      CompilerEndIf
      
    CompilerEndIf  
    
    
    If StartParams\qStartPosition And iMediaObject:MediaSeek(iMediaObject, StartParams\qStartPosition):EndIf
    
    
    If StartParams\bFullscreen:RunCommand(#COMMAND_FULLSCREEN):EndIf 
    ;TODO: Should be integreated in the CreateMainWindow()! To avoid showing the window at the start
    
    
    ;}
    ;{ Update Player:
    CompilerIf #USE_OEM_VERSION = #False
      If Val(Settings(#SETTINGS_AUTOMATIC_UPDATE)\sValue) = #True
        UpdatePlayer(#False)
      EndIf
      If FileSize("update.exe")>0
        DeleteFile("update.exe")
        If FileSize("update.data")>0:DeleteFile("update.data"):EndIf
        If FileSize("update.txt")>0:DeleteFile("update.txt"):EndIf
        ExtractReadme()
      EndIf
    CompilerEndIf  
    ;}
    
    
    
    WriteLog("PLAYER-STARTS", #LOGLEVEL_DEBUG)
    
    
    Repeat
      
      
      ;{ Events
      LoadMediaIfReadyToLoad()
      If BufferingMedia And MediaFile\StreamingFile
        CheckBufferingToLoadMedia()
      EndIf  
      
      If IsWindowVisible_(WindowID(#WINDOW_MAIN)) And GetWindowState(#WINDOW_MAIN)<>#PB_Window_Minimize
        isMainWindowActive = #True
      Else
        isMainWindowActive = #False
      EndIf
      
      
      If isMainWindowActive ;GetActiveWindow()=#WINDOW_MAIN
        Delay(10)
      Else
        Delay(40)
      EndIf
      
      EventCounter=0
      Repeat
        EventCounter+1
        iEvent = WindowEvent()
        Events(iEvent)
      Until iEvent = #WM_NULL Or EventCounter>100;EventCounter damit er in derschleife nicht hängt
      Event_KeyBoard()
      HoverGadgetImages()
      
      
      
      If (iMediaObject Or iIsVISUsed) And iIsVISUsed<>#VIS_COVERFLOW And UsedOutputMediaLibrary<>#MEDIALIBRARY_FLASH
        If GetActiveWindow()=#WINDOW_MAIN
          If GetAsyncKeyState_(#VK_LBUTTON)<>0
            If PressedLeftMouseButton=#False
              If GetDoubleClickTime_()<ElapsedMilliseconds()-iDoubleClickTime
                iDoubleClickTime=ElapsedMilliseconds()
              Else
                If MediaWidth(iMediaObject)>0  And MediaHeight(iMediaObject)>0
                  If WindowMouseX(#WINDOW_MAIN)>GadgetX(#GADGET_VIDEO_CONTAINER)
                    If WindowMouseY(#WINDOW_MAIN)>GadgetY(#GADGET_VIDEO_CONTAINER)
                      If WindowMouseX(#WINDOW_MAIN)<GadgetX(#GADGET_VIDEO_CONTAINER)+GadgetWidth(#GADGET_VIDEO_CONTAINER)
                        If WindowMouseY(#WINDOW_MAIN)<GadgetY(#GADGET_VIDEO_CONTAINER)+GadgetHeight(#GADGET_VIDEO_CONTAINER)
                          SetFullScreen()
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                EndIf
                
                If WindowMouseX(#WINDOW_MAIN)>GadgetX(#GADGET_VIS_CONTAINER)
                  If WindowMouseY(#WINDOW_MAIN)>GadgetY(#GADGET_VIS_CONTAINER)
                    If WindowMouseX(#WINDOW_MAIN)<GadgetX(#GADGET_VIS_CONTAINER)+GadgetWidth(#GADGET_VIS_CONTAINER)
                      If WindowMouseY(#WINDOW_MAIN)<GadgetY(#GADGET_VIS_CONTAINER)+GadgetHeight(#GADGET_VIS_CONTAINER)
                        SetFullScreen()
                      EndIf
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
            PressedLeftMouseButton=#True
          Else
            PressedLeftMouseButton=#False
          EndIf
        EndIf
      EndIf
      
      If UseNoPlayerControl=#False And #USE_DISABLECONTEXTMENU=#False
        If GetWindowKeyState(#VK_RBUTTON)
          VDVD_CreatePopUpMenu()
          DisplayPopupMenu(#MENU_VDVD_MENU, WindowID(#WINDOW_MAIN))
        EndIf
      EndIf 
      
      ;}
      ;{ Update Player
      CompilerIf #USE_OEM_VERSION=#False
        If IsWindow(#WINDOW_UPDATE)
          If IsThread(iDownloadThread)
            
          Else
            sFile.s="update.exe"
            iFile = CreateFile(#PB_Any, sFile)
            If iFile = #Null: sFile=GetTemporaryDirectory()+"GFP-update.exe":iFile = CreateFile(#PB_Any, sFile):EndIf
            If iFile
              WriteData(iFile, ?DS_UpdateProgram, ?DS_EndUpdateProgram-?DS_UpdateProgram)
              CloseFile(iFile)
              CloseWindow(#WINDOW_UPDATE)
              ;iQuit = #True
              If hMutexAppRunning
                CloseHandle_(hMutexAppRunning)
                hMutexAppRunning=#Null
              EndIf
              RunProgram(sFile, Chr(34)+ProgramFilename()+Chr(34), GetPathPart(ProgramFilename()))
              ;ShellExecute_(#Null,@"open", @"update.exe", #Null, #Null, #SW_SHOWDEFAULT)
              EndPlayer()
              End
            Else
              CloseWindow(#WINDOW_UPDATE)
              MessageRequester(Language(#L_ERROR), Language(#L_CANT_UPDATE), #MB_ICONERROR)
              WriteLog("Can't update player, can't create file!")
            EndIf
          EndIf
        EndIf
      CompilerEndIf
      ;}
      ;{ Fullscreen
      
      
      
      
      If GetGadgetData(#GADGET_CONTAINER);Fullscreen
        
        iMouseInActive + 1
        iWMouseOldX = iWMouseX
        iWMouseOldY = iWMouseY
        iWMouseX = WindowMouseX(#WINDOW_MAIN)
        iWMouseY = WindowMouseY(#WINDOW_MAIN)
        If iWMouseX<>iWMouseOldX Or iWMouseY<>iWMouseOldY:iMouseInActive=0:EndIf
        
        If GetWindowKeyState(#VK_ESCAPE);GetAsyncKeyState_(#VK_ESCAPE)
          SetFullScreen()
        EndIf
        
        If iMouseInActive>30
          If iShowMainWindowCursor = #True
            ShowCursor_(0)
            iShowMainWindowCursor = #False
            ActivateFullscreenControl(iShowMainWindowCursor)
          EndIf
        Else
          If iShowMainWindowCursor = #False
            ShowCursor_(1)
            iShowMainWindowCursor = #True
          EndIf
          If WindowMouseY(#WINDOW_MAIN)>WindowHeight(#WINDOW_MAIN)-Design_Container_Size
            ActivateFullscreenControl(iShowMainWindowCursor)
          EndIf
        EndIf
      Else
        If iShowMainWindowCursor = #False
          ShowCursor_(1)
          iShowMainWindowCursor = #True
        EndIf
      EndIf
      ;}
      ;{ Play Media
      
      
      
      
      If iMediaObject
        
        MediaState=MediaState(iMediaObject)
        If iIsMediaObjectVideoDVD
          MediaPosition=DShow_DVDGetPosition(IMediaObject)
          If MediaLength<1
            MediaLength=DShow_DVDGetLength(IMediaObject)
          EndIf  
        Else  
          MediaPosition=MediaPosition(IMediaObject)
          If MediaLength<1
            MediaLength=MediaLength(IMediaObject)
          EndIf
        EndIf
        
      Else
        MediaState=#False
        MediaPosition=0
        MediaLength=0
      EndIf 
      
      
      
      If iIsMediaObjectVideoDVD=#False
        If (MediaState=#STATE_STOPPED Or (MediaPosition>=MediaLength And MediaLength>0)) And UsedOutputMediaLibrary <> #MEDIALIBRARY_FLASH
          If MediaFile\iPlaying
            If bCloseAfterPlayback
              EndPlayer()
            EndIf  
            If GetGadgetData(#GADGET_BUTTON_REPEAT)
              ;Gliche Datei Wiederholen
              If MediaLength = MediaPosition
                MediaSeek(iMediaObject, 0)
              EndIf
              PlayMedia(iMediaObject)
              MediaFile\iPlaying = #True
              
            Else
              ;Wiedergabe nach Liste
              If Playlist\iID
                ;Debug Playlist\iCurrentMedia
                If GetGadgetData(#GADGET_BUTTON_RANDOM)
                  If Playlist\iItemCount>0
                    Playlist\iCurrentMedia=(Random(Playlist\iItemCount+100)+GetTickCount_())%Playlist\iItemCount
                  EndIf  
                  
                Else
                  Playlist\iCurrentMedia+1
                  If Playlist\iCurrentMedia>Playlist\iItemCount:Playlist\iCurrentMedia=0:EndIf          
                EndIf
                LoadMediaFile(PlayListItems(Playlist\iCurrentMedia)\sFile, #True, PlayListItems(Playlist\iCurrentMedia)\sTitle)
                If IMediaObject
                  PlayMedia(iMediaObject)
                  MediaFile\iPlaying = #True
                Else
                  MediaFile\iPlaying = #False
                EndIf
              EndIf 
            EndIf
          EndIf
        EndIf
      EndIf
      
      
      If isMainWindowActive And iIsVISUsed
        VIS_Update();Updates the visual effects
      EndIf
      
      iCount+1
      If iCount>4
        iCount=0
        
        If iMediaObject
          OnMediaEvent(iMediaObject);Falls diese zeile entfernt wird muss der Own renderer angepasst werden, device lost.
        EndIf
        
        If ElapsedMilliseconds()=CheckForScreenCaptureTimer
          ElapsedMillisecondsFails+1
        EndIf  
        If ElapsedMilliseconds()-CheckForScreenCaptureTimer>1000
          CheckDebuggerActive()
          If IsSnapshotAllowed=#GFP_DRM_SCREENCAPTURE_PROTECTION_FORCE 
            CheckForScreenCapture()
          EndIf 
          CompilerIf #USE_SUBTITLES
            DisplaySubtitle(MediaPosition)
          CompilerEndIf
          CheckForScreenCaptureTimer=ElapsedMilliseconds()
        EndIf
        
        
        
        If isMainWindowActive
          RunCommand(#COMMAND_ACD_UPDATEDTRACKS)
          If iIsMediaObjectVideoDVD
            If MediaLength>=1
              SetGadgetState(#GADGET_VDVD_TRACKBAR, IntQ((MediaPosition/MediaLength)*10000))
              DisableGadget(#GADGET_VDVD_TRACKBAR, #False)
            Else
              SetGadgetState(#GADGET_VDVD_TRACKBAR, 0)
              DisableGadget(#GADGET_VDVD_TRACKBAR, #True)
            EndIf
            If Design_Buttons=1
              If MediaState=2
                If GetGadgetAttribute(#GADGET_VDVD_BUTTON_PLAY, #PB_Button_Image) <> ImageID(#SPRITE_BREAK)
                  SetGadgetAttribute(#GADGET_VDVD_BUTTON_PLAY, #PB_Button_Image , ImageID(#SPRITE_BREAK))
                  SetPlayTumbButtonImage(#SPRITE_MENU_BREAK)
                EndIf
              Else
                If GetGadgetAttribute(#GADGET_VDVD_BUTTON_PLAY, #PB_Button_Image) <> ImageID(#SPRITE_PLAY)
                  SetGadgetAttribute(#GADGET_VDVD_BUTTON_PLAY, #PB_Button_Image , ImageID(#SPRITE_PLAY))
                  SetPlayTumbButtonImage(#SPRITE_MENU_PLAY)
                EndIf
              EndIf
            EndIf
            
            If MediaLength>0
              sMediaTimeString.s=Time2String(MediaPosition*1000)+"/"+Time2String(MediaLength*1000)
            Else
              sMediaTimeString.s=""
            EndIf
            If sMediaTimeString<>sMediaTimeStringBefore
              sMediaTimeStringBefore=sMediaTimeString
              If Settings(#SETTINGS_USE_STATUSBAR)\sValue="1"
                StatusBarText(0, 1, sMediaTimeString, #PB_StatusBar_Center)
              EndIf  
              GadgetToolTip(#GADGET_TRACKBAR, sMediaTimeString)
            EndIf
          Else
            If MediaLength>=1
              SetGadgetState(#GADGET_TRACKBAR, IntQ((MediaPosition/MediaLength)*10000))
              sMediaTimeString.s=Time2String(MediaPosition)+"/"+Time2String(MediaLength)
              If sMediaTimeString<>sMediaTimeStringBefore
                sMediaTimeStringBefore=sMediaTimeString
                If Settings(#SETTINGS_USE_STATUSBAR)\sValue="1"
                  StatusBarText(0, 1, sMediaTimeString, #PB_StatusBar_Center)
                EndIf  
                
                GadgetToolTip(#GADGET_TRACKBAR, sMediaTimeString)
              EndIf
              DisableGadget(#GADGET_TRACKBAR, #False)
            Else
              If IsGadget(#GADGET_TRACKBAR)
                SetGadgetState(#GADGET_TRACKBAR, 0)
                DisableGadget(#GADGET_TRACKBAR, #True)
              EndIf
              sMediaTimeString.s=""
              If sMediaTimeString<>sMediaTimeStringBefore
                sMediaTimeStringBefore=sMediaTimeString
                If Settings(#SETTINGS_USE_STATUSBAR)\sValue="1"
                  StatusBarText(0, 1, sMediaTimeString, #PB_StatusBar_Center)
                EndIf  
                GadgetToolTip(#GADGET_TRACKBAR, sMediaTimeString)
              EndIf
            EndIf
            If Design_Buttons=1
              If MediaState=2 And MediaPosition<>MediaLength
                If GetGadgetAttribute(#GADGET_BUTTON_PLAY, #PB_Button_Image) <> ImageID(#SPRITE_BREAK)
                  SetGadgetAttribute(#GADGET_BUTTON_PLAY, #PB_Button_Image , ImageID(#SPRITE_BREAK))
                EndIf
              Else
                If GetGadgetAttribute(#GADGET_BUTTON_PLAY, #PB_Button_Image) <> ImageID(#SPRITE_PLAY)
                  SetGadgetAttribute(#GADGET_BUTTON_PLAY, #PB_Button_Image , ImageID(#SPRITE_PLAY))
                EndIf
              EndIf
            EndIf
            
            If MediaState=2 And MediaPosition<>MediaLength
              SetPlayTumbButtonImage(#SPRITE_MENU_BREAK)
            Else
              SetPlayTumbButtonImage(#SPRITE_MENU_PLAY)
            EndIf
            
            
            
          EndIf
          
          
        EndIf
        
        If DebuggerActive Or ElapsedMillisecondsFails>100
          iQuit=#True
        EndIf  
        
      EndIf
      ;}
    Until iQuit=#True
    
    ;{ End Player
    EndPlayer()
    End
    ;}
    ;{ Testing Constante
  CompilerEndIf
  ;}
  ;{ DataSection
  DataSection
    
    DS_SQLDataBase:
    CompilerIf #USE_OEM_VERSION
      IncludeBinary "OEM-data\data.sqlite"
    CompilerElse
      IncludeBinary "data\data.sqlite"
    CompilerEndIf  
    DS_EndSQLDataBase:
    
    CompilerIf #USE_OEM_VERSION=#False
      DS_UpdateProgram:
      IncludeBinary "data\update.exe"
      DS_EndUpdateProgram:
      
      
      DS_ReadmeDE:
      IncludeBinary "ReadmeDE.txt"
      DS_EndReadmeDE:
      DS_ReadmeEN:
      IncludeBinary "ReadmeEN.txt"
      DS_EndReadmeEN:
      DS_ChangeLog:
      IncludeBinary "ChangeLog.txt"
      DS_EndChangeLog:
    CompilerEndIf
    
    
    DS_play:
    IncludeBinary "data\Icons\Icons-24x24\play-blue.ico"
    DS_Previous:
    IncludeBinary "Data\Icons\Icons-24x24\begin-blue.ico"
    DS_stop:
    IncludeBinary "Data\Icons\Icons-24x24\stop-blue.ico"
    DS_Next:
    IncludeBinary "Data\Icons\Icons-24x24\end-blue.ico"
    DS_snapshot:
    IncludeBinary "Data\Icons\Icons-24x24\Photo-blue.ico"   
    
    DS_Light:
    IncludeBinary "data\Icons\Icons-32x32\light.ico"
    DS_Key:
    IncludeBinary "data\Icons\Icons-32x32\KEY.ico"
    DS_EXE:
    IncludeBinary "data\Icons\Icons-32x32\EXE.ico"    
    DS_Tresor:
    IncludeBinary "data\Save.png"
    DS_NoPhoto:
    IncludeBinary "data\Icons\Icons-32x32\no-screenshot.ico"
    
    DS_addlist:
    IncludeBinary "data\Icons\Icons-24x24\PLAYLIST_ADD.ico"
    DS_addtrack:
    IncludeBinary "data\Icons\Icons-24x24\FILE_VIDEO.ico"
    DS_deletelist:
    IncludeBinary "data\Icons\Icons-24x24\PLAYLIST_SUB.ico"
    DS_deletetrack:
    IncludeBinary "data\Icons\Icons-24x24\FILE_REMOVE.ico"
    DS_addfoldertracks:
    IncludeBinary "data\Icons\Icons-24x24\FILE_FOLDER.ico"
    DS_addurl:
    IncludeBinary "data\Icons\Icons-24x24\FILE_URL.ico"
    DS_exportplaylist:
    IncludeBinary "data\Icons\Icons-24x24\PLAYLIST_EXPORT.ico"
    DS_impurtplaylist:
    IncludeBinary "data\Icons\Icons-24x24\PLAYLIST_IMPORT.ico"
    DS_playplaylist:
    IncludeBinary "data\Icons\Icons-24x24\PLAYLIST_PLAY3.ico";play-blue.ico"
    
    DS_playtrack:
    IncludeBinary "data\Icons\Icons-16x16\FILE_FILE.ico"
    DS_playlist:
    IncludeBinary "data\Icons\Icons-16x16\PLAYLIST3.ico"    
    DS_menu_earthtrack:
    IncludeBinary "data\Icons\Icons-16x16\FILE_URL.ico"    
    
    DS_error:
    IncludeBinary "data\Btn_Error3_60x60.png"
    DS_error_end:
    DS_info:
    IncludeBinary "data\Btn_Info3_60x60.png"
    
    
    CompilerIf #USE_OEM_VERSION=#False
      DS_about:
      IncludeBinary "data\about.jpg"
      DS_about_BK:
      IncludeBinary "data\About_BK.jpg"
    CompilerEndIf
    
    DS_noimage:
    IncludeBinary "data\note.png"
    DS_bigkey:
    IncludeBinary "data\key.png"
    DS_noConnection:
    IncludeBinary "data\No_Connection.png"
    DS_noConnection_end:
    
    DS_menu_playlist:
    IncludeBinary "data\Icons\Icons-16x16\PLAYLIST3.ico"
    DS_menu_load:
    IncludeBinary "data\Icons\Icons-16x16\Open-Media.ico"
    DS_menu_save:
    IncludeBinary "data\Icons\Icons-16x16\Icon-Blue-Save_16x16.ico"
    DS_menu_end:
    IncludeBinary "data\Icons\Icons-16x16\quit-16x16_2.ico"
    DS_menu_homepage:
    IncludeBinary "data\Icons\Icons-16x16\i4.ico"
    
    DS_menu_language:
    IncludeBinary "data\Icons\Icons-16x16\Icon-Blue-Bubble_16x16.ico"
    DS_menu_options:
    IncludeBinary "data\Icons\Icons-16x16\i2.ico"
    DS_menu_update:
    IncludeBinary "data\Icons\Icons-16x16\i6_.ico"
    DS_menu_clipboard:
    IncludeBinary "data\Icons\Icons-16x16\i1.ico"
    DS_menu_language_germany:
    IncludeBinary "data\Icons\Icons-16x16\Germany-16x16.ico"
    DS_menu_language_english:
    IncludeBinary "data\Icons\Icons-16x16\Great-Britaion-16x16.ico"
    DS_menu_language_french:
    IncludeBinary "data\Icons\Icons-16x16\France-16x16.ico"
    DS_menu_language_turkish:
    IncludeBinary "data\Icons\Icons-16x16\Turkey.ico"
    DS_menu_language_netherlands:
    IncludeBinary "data\Icons\Icons-16x16\Netherlands.ico"
    DS_menu_language_spain:
    IncludeBinary "data\Icons\Icons-16x16\Spain.ico"
    DS_menu_language_greek:
    IncludeBinary "data\Icons\Icons-16x16\greek.ico"
    DS_menu_language_portugal:
    IncludeBinary "data\Icons\Icons-16x16\Portugal.ico"
    DS_menu_language_italian:
    IncludeBinary "data\Icons\Icons-16x16\Italian.ico"
    DS_menu_language_sweden:
    IncludeBinary "data\Icons\Icons-16x16\Sweden.ico"
    DS_menu_language_russia:
    IncludeBinary "data\Icons\Icons-16x16\Russia.ico"
    DS_menu_language_bulgaria:
    IncludeBinary "data\Icons\Icons-16x16\Bulgaria.ico"
    DS_menu_language_serbien:
    IncludeBinary "data\Icons\Icons-16x16\Serbia.ico"
    DS_menu_language_persian:
    IncludeBinary "data\Icons\Icons-16x16\Persian.ico"   
    DS_menu_Action:
    IncludeBinary "Data\Icons\Icons-16x16\Action-16x16.ico"
    
    DS_Renderer:
    IncludeBinary "Data\Icons\Icons-32x32\Grafikkarte.ico"
    DS_AudioRenderer:
    IncludeBinary "Data\Icons\Icons-32x32\Speaker.ico"
    DS_Language:
    IncludeBinary "Data\Icons\Icons-32x32\Languages.ico"
    DS_Projektor:
    IncludeBinary "Data\Icons\Icons-32x32\Film_32x32.ico"
    DS_Update:
    IncludeBinary "Data\Icons\Icons-32x32\download2.ico"
    DS_BKColor:
    IncludeBinary "Data\Icons\Icons-32x32\Color_4.ico"
    DS_Bug:
    IncludeBinary "Data\Icons\Icons-32x32\Bug_32x32.ico"
    DS_Systray_32x32:
    IncludeBinary "Data\Icons\Icons-32x32\Systray.ico"
    DS_One_Instance:
    IncludeBinary "Data\Icons\Icons-32x32\One-Instance.ico"
    DS_Photo_32x32:
    IncludeBinary "Data\Icons\Icons-32x32\OpenMedia2.ico"
    DS_Photo_File_32x32:
    IncludeBinary "Data\Icons\Icons-32x32\photo-format2-32x32.ico"
    DS_RAM:
    IncludeBinary "Data\Icons\Icons-32x32\RAM-32x32-NEU.ico"
    DS_RAM_FILE:
    IncludeBinary "Data\Icons\Icons-32x32\RAM-32x32-NEU+Media.ico"
    DS_Theme:
    IncludeBinary "Data\Icons\Icons-32x32\Theme32x32.ico"
    
    DS_menu_play:
    IncludeBinary "data\Icons\Icons-16x16\play-blue-16x16.ico"
    DS_menu_backward:
    IncludeBinary "Data\Icons\Icons-16x16\begin-blue-16x16.ico"
    DS_menu_stop:
    IncludeBinary "Data\Icons\Icons-16x16\stop-blue-16x16.ico"
    DS_menu_forward:
    IncludeBinary "Data\Icons\Icons-16x16\end-blue-16x16.ico"
    DS_menu_break:
    IncludeBinary "data\Icons\Icons-16x16\break_16x16.ico"
    
    DS_menu_Tresor:
    IncludeBinary "data\Icons\Icons-16x16\Tresor.ico"
    DS_menu_key:
    IncludeBinary "data\Icons\Icons-16x16\Key.ico"
    DS_menu_Bulldozer:
    IncludeBinary "data\Icons\Icons-16x16\Delete.ico"
    DS_menu_Earth:
    IncludeBinary "data\Icons\Icons-16x16\earth-16x16.ico"
    DS_menu_AudioCD:
    IncludeBinary "data\Icons\Icons-16x16\CD-Drive2-blue.ico"
    DS_menu_Projektor:
    IncludeBinary "Data\Icons\Icons-16x16\FILE_VIDEO.ico"
    
    DS_menu_mute:
    IncludeBinary "Data\Icons\Icons-16x16\volume-off-16x16.ico"
    DS_menu_sound:
    IncludeBinary "Data\Icons\Icons-16x16\volume-16x16.ico"
    
    DS_menu_Monitor:
    IncludeBinary "Data\Icons\Icons-16x16\Monitor-16x16.ico"
    DS_menu_GiveMoney:
    IncludeBinary "Data\Icons\Icons-16x16\Give-Money.ico"
    DS_menu_Download:
    IncludeBinary "Data\Icons\Icons-16x16\download2-16x16.ico"
    DS_menu_Help:
    IncludeBinary "Data\Icons\Icons-16x16\i3.ico"
    DS_menu_minimalmode:
    IncludeBinary "Data\Icons\Icons-16x16\Minimal-View.ico"
    DS_menu_Coverflow:
    IncludeBinary "Data\Icons\Icons-16x16\Coverflow.ico"
    DS_menu_Ram:
    IncludeBinary "Data\Icons\Icons-16x16\ram.ico"
    DS_menu_Rename:
    IncludeBinary "Data\Icons\Icons-16x16\EDIT_TEXT.ico"
    DS_menu_Brush:
    IncludeBinary "Data\Icons\Icons-16x16\Besen5_optimized-for-small-icon.ico"
    
    DS_menu_PlayMedia:
    IncludeBinary "Data\Icons\Icons-16x16\Film.ico"
    DS_menu_PlayAudioCD:
    IncludeBinary "Data\Icons\Icons-16x16\Music-CD.ico"
    DS_menu_PlayDVD:
    IncludeBinary "Data\Icons\Icons-16x16\DVD-Movie.ico"
    DS_menu_Snapshot:
    IncludeBinary "Data\Icons\Icons-16x16\snapshot-16x16.ico"
    DS_menu_PlayFile:
    IncludeBinary "Data\Icons\Icons-16x16\PLAY_FILE.ico"   
    
    
    CompilerIf #USE_OEM_VERSION
      DS_menu_about:
      DS_systray: 
      IncludeBinary "OEM-data\video_16x16.ico"
      DS_menu_encTrack: 
      IncludeBinary "OEM-data\video_16x16.ico"
    CompilerElse
      DS_menu_about:
      DS_systray: 
      IncludeBinary "data\Icons\Icons-16x16\GFP.ico"
      DS_menu_encTrack: 
      IncludeBinary "data\Icons\Icons-16x16\FILE_GFP.ico"
    CompilerEndIf  
    
    
    DS_VIS_DCT_BK: 
    IncludeBinary "data\bk.png"
    DS_VIS_DCT_BT: 
    IncludeBinary "data\Button.png"
    DS_VIS_WhiteLight_WL: 
    IncludeBinary "data\Particle.png"
    DS_VIS_CF_NoCover: 
    IncludeBinary "data\NoCover.jpg"
    DS_VIS_CF_CoverEffect: 
    IncludeBinary "data\CoverEffect.png"
    DS_VIS_CF_BK2: 
    IncludeBinary "data\bk2.png"
    DS_VIS_CF_GFP: 
    IncludeBinary "data\GFP-Logo.png"
    
    DS_VIS_B_Progress: 
    IncludeBinary "data\Progress.png"
    DS_VIS_B_Progress_2: 
    IncludeBinary "data\Progress_2.png"
    
    DS_Sprite2D_Font: 
    IncludeBinary "data\font.png"
  EndDataSection
  ;}
  
  
  

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 6558
; FirstLine = 6525
; Folding = --------------------------------------------
; Markers = 5792
; EnableThread
; EnableXP
; EnableUser
; EnableOnError
; UseIcon = data\Laptop.ico
; Executable = GreenForce-Player.exe
; EnableCompileCount = 4429
; EnableBuildCount = 648
; EnableExeConstant
; IncludeVersionInfo
; VersionField0 = 0,8,0,0
; VersionField1 = 0,8,0,0
; VersionField2 = RRSoftware
; VersionField3 = GreenForce Player
; VersionField4 = 0.80
; VersionField5 = 0.80
; VersionField6 = GreenForce MediaPlayer
; VersionField7 = GreenForce Player
; VersionField8 = GreenForce-Player.exe
; VersionField9 = (c) 2009 - 2010 RocketRider
; VersionField13 = E-Mail@RocketRider.eu
; VersionField14 = http://www.GFP.RRSoftware.de
; VersionField16 = VFT_APP
; VersionField18 = Author
; VersionField21 = RocketRider
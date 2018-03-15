;*************************************** Version: 2.1
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
;FIX FÃ¼r problematisschen DLL-Loadverhalten (wenn die bei LoadLibrary angegebene DLL nicht vorhanden ist)
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
  #PLAYER_COPYRIGHT = "© 2009 - 2017 RocketRider"
  
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


;Bei Ã¤nderung auch hier CheckForScreenCapture() aktualisieren!!!
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
  GetWindowKeyState(#VK_RBUTTON);Wird benÃ¶tigt da der status spÃ¤ter sonst noch aktiv ist.
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
  GetWindowKeyState(#VK_RBUTTON);Wird benÃ¶tigt da der status spÃ¤ter sonst noch aktiv ist.
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
  GetWindowKeyState(#VK_RBUTTON);Wird benÃ¶tigt da der status spÃ¤ter sonst noch aktiv ist.
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
      sXorKeys.s = DRMV2Read_GetBlockString(*GFP_DRM_HEADER_V2, #DRMV2_HEADER_MEDIA_MACHINEID);Muss zur Ã¼berprÃ¼fung immer geladen werden, auch wenn das PW schon gefunden wurde!
      
      
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
      ;Kein Layered Window fÃ¼r Windows XP, da dies mit Overlay flackert!
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





Procedure CloseFRAPS()
  Protected i
  If IsFRAPSLoadedToProcess()
    ;can cause a crash :-(
    ;FreeLibrary_(GetModuleHandle_("FRAPS32.DLL"))   
  EndIf
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
        CloseFRAPS() ;close fraps as it can take screenshots        
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

Procedure.l DownloadToMem(AgentName.s, URL$, ptr.l, Size.l);Scheint unzuverlÃ¤ssig zu sein. schneidet zu frÃ¼h ab
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
  
  ;Hier logfile freigeben, fÃ¼hrte zu Crash mit Virtual file und KompartibilitÃ¤t.
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
      

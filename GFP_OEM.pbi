#PLAYER_COPYRIGHT = ""
#PLAYER_NAME = "GreenFoce-Player"
#PLAYER_GLOBAL_MUTEX = "Video-Player-OEM"
#GFP_PATTERN_PROTECTED_MEDIA = "VideoPlayer (*.oemvideo)|*.oemvideo;|All Files (*.*)|*.*"
#GFP_PROTECTED_FILE_EXTENTION = ".oemvideo"   
#GFP_CODEC_EXTENSION = "oemvideo-codec"
#OEM_MP_MUTEX = "OEMKSZUWD4782F2H"
#GFP_STREAMING_AGENT = ""
#GFP_PATTERN_MEDIA = "Media|*.oemvideo;*.oemvideo-codec;*.ogg;*.flac;*.m4a;*.aud;*.svx;*.voc;*.mka;*.3g2;*.3gp;*.asf;*.asx;*.avi;*.flv;*.mov;*.mp4;*.mpg;*.mpeg;*.rm;*.qt;*.swf;*.divx;*.vob;*.ts;*.ogm;*.m2ts;*.ogv;*.rmvb;*.tsp;*.ram;*.wmv;*.aac;*.aif;*.aiff;*.iff;*.m3u;*.mid;*.midi;*.mp1;*.mp2;*.mp3;*.mpa;*.ra;*.wav;*.wma;*.pls;*.xspf;*.mkv;*.m2v;*.m4v;|All Files (*.*)|*.*"
#USE_DISABLEMENU = #True
#USE_DISABLECONTEXTMENU = #False

#GFP_GUID = "";ADD OEM GUID

#UPDATE_AGENT = ""
#UPDATE_VERSION_URL = ""
#UPDATE_FILE_URL = ""

#OEM_DISALLOW_URL_STREAMING_ERROR = "URL Streaming is not allowed!"

#OEM_ONLY_START_WITH_ACTIVE_MUTEX = #False
#OEM_MUTEX_NOT_ACTIVE_ERROR = "You are not allowed to use this player standalone"

#OEM_OPEN_FILE_REQUESTER_AT_START = #False

#PLAYER_EXTENSION = "oemvideo"
Define sAppDataFile.s = GetSpecialFolder(#CSIDL_APPDATA)+"\OEM-Video-Player\CryptSettings.dat"

#OEM_ENCRYPTTOOL_HELP = "http://gfp.rrsoftware.de";Your help webseite

Procedure OEM_MenuLimitation();Hide Menu options
  MenuLimitations(8)=#True
  MenuLimitations(27)=#True
  MenuLimitations(28)=#True
  MenuLimitations(29)=#True
  MenuLimitations(5)=#True
  MenuLimitations(7)=#True
  MenuLimitations(9)=#True
  MenuLimitations(10)=#True
  MenuLimitations(36)=#True
EndProcedure  
; IDE Options = PureBasic 5.21 LTS (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
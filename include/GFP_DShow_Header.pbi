;***************************************
;*** GreenForce Player *** GF-Player ***
;*** http://GFP.RRSoftware.de **********
;*** (c) 2009 - 2012 RocketRider *******
;***************************************
EnableExplicit
XIncludeFile "GFP_D3D.pbi"

#OATRUE = -1
#OAFALSE = 0
 
#CLSCTX_INPROC_SERVER  = $01
#CLSCTX_INPROC_HANDLER = $02
#CLSCTX_LOCAL_SERVER   = $04
#CLSCTX_REMOTE_SERVER  = $10

#CLSCTX_INPROC = #CLSCTX_INPROC_SERVER|#CLSCTX_INPROC_HANDLER
#CLSCTX_SERVER = #CLSCTX_INPROC_SERVER|#CLSCTX_LOCAL_SERVER|#CLSCTX_REMOTE_SERVER
#CLSCTX_ALL    = #CLSCTX_INPROC_SERVER|#CLSCTX_INPROC_HANDLER|#CLSCTX_LOCAL_SERVER|#CLSCTX_REMOTE_SERVER

#VFW_S_DUPLICATE_NAME = $0004022D
#VFW_S_AUDIO_NOT_RENDERED = $00040258
#VFW_S_VIDEO_NOT_RENDERED = $00040257
#VFW_S_PARTIAL_RENDER = $00040242

#VFW_S_STATE_INTERMEDIATE  = $00040237

Enumeration
  #STATE_STOPPED
  #STATE_PAUSED
  #STATE_RUNNING
EndEnumeration

Enumeration
  #AM_SEEKING_NOPOSITIONING        
  #AM_SEEKING_ABSOLUTEPOSITIONING
EndEnumeration

#VMRMODE_WINDOWED   = 1
#VMRMODE_WINDOWLESS = 2
#VMRMODE_RENDERLESS = 4

#MAX_FILTER_NAME = 128

#WM_GRAPHNOTIFY = #WM_USER + 13

#EC_COMPLETE  = 1

#DVD_Relative_Upper   = 1
#DVD_Relative_Lower   = 2
#DVD_Relative_Left    = 3
#DVD_Relative_Right   = 4

#DVD_DEFAULT_AUDIO_STREAM	= 0

#DVD_CMD_FLAG_None	= $0
#DVD_CMD_FLAG_Flush	= $1
#DVD_CMD_FLAG_SendEvents	= $2
#DVD_CMD_FLAG_Block	= $4
#DVD_CMD_FLAG_StartWhenRendered	= $8
#DVD_CMD_FLAG_EndAfterRendered	= $10

#EC_DVDBASE                              = $0100
#EC_DVD_DOMAIN_CHANGE                    = (#EC_DVDBASE  + $01)
; Parameters: ( DWORD, void ) 
; lParam1 is enum DVD_DOMAIN, and indicates the player's new domain
;
; Raised from following domains: all
;
; Signaled when ever the DVD player changes domains.
#EC_DVD_TITLE_CHANGE                     = (#EC_DVDBASE  + $02)
; Parameters: ( DWORD, void ) 
; lParam1 is the new title number.
;
; Raised from following domains: DVD_DOMAIN_Title
;
; Indicates when the current title number changes.  Title numbers
; range 1 to 99.  This indicates the TTN, which is the title number
; with respect to the whole disc, not the VTS_TTN which is the title
; number with respect to just a current VTS.
#EC_DVD_CHAPTER_START                   = (#EC_DVDBASE  + $03)
; Parameters: ( DWORD, void ) 
; lParam1 is the new chapter number (which is the program number for 
; One_Sequential_PGC_Titles).
;
; Raised from following domains: DVD_DOMAIN_Title
;
; Signales that DVD player started playback of a new program in the Title 
; domain.  This is only signaled for One_Sequential_PGC_Titles.
#EC_DVD_AUDIO_STREAM_CHANGE              = (#EC_DVDBASE  + $04)
; Parameters: ( DWORD, void ) 
; lParam1 is the new user audio stream number.
;
; Raised from following domains: all
;
; Signaled when ever the current user audio stream number changes for the main 
; title.  This can be changed automatically with a navigation command on disc
; as well as through IDVDAnnexJ.
; Audio stream numbers range from 0 to 7.  Stream $ffffffff
; indicates that no stream is selected.
#EC_DVD_SUBPICTURE_STREAM_CHANGE         = (#EC_DVDBASE  + $05)
; Parameters: ( DWORD, BOOL ) 
; lParam1 is the new user subpicture stream number.
; lParam2 is the subpicture's on/off state (TRUE if on)
;
; Raised from following domains: all
;
; Signaled when ever the current user subpicture stream number changes for the main 
; title.  This can be changed automatically with a navigation command on disc
; as well as through IDVDAnnexJ.  
; Subpicture stream numbers range from 0 to 31.  Stream $ffffffff
; indicates that no stream is selected.  
#EC_DVD_ANGLE_CHANGE                     = (#EC_DVDBASE  + $06)
; Parameters: ( DWORD, DWORD ) 
; lParam1 is the number of available angles.
; lParam2 is the current user angle number.
;
; Raised from following domains: all
;
; Signaled when ever either 
;   a) the number of available angles changes, or  
;   b) the current user angle number changes.
; Current angle number can be changed automatically with navigation command 
; on disc as well as through IDVDAnnexJ.
; When the number of available angles is 1, the current video is not multiangle.
; Angle numbers range from 1 to 9.
#EC_DVD_BUTTON_CHANGE                    = (#EC_DVDBASE  + $07)
; Parameters: ( DWORD, DWORD ) 
; lParam1 is the number of available buttons.
; lParam2 is the current selected button number.
;
; Raised from following domains: all
;
; Signaled when ever either 
;   a) the number of available buttons changes, or  
;   b) the current selected button number changes.
; The current selected button can be changed automatically with navigation 
; commands on disc as well as through IDVDAnnexJ.  
; Button numbers range from 1 to 36.  Selected button number 0 implies that
; no button is selected.  Note that these button numbers enumerate all 
; available button numbers, and do not always correspond to button numbers
; used for IDVDAnnexJ::ButtonSelectAndActivate since only a subset of buttons
; may be activated with ButtonSelectAndActivate.
#EC_DVD_VALID_UOPS_CHANGE                = (#EC_DVDBASE  + $08)
; Parameters: ( DWORD, void ) 
; lParam1 is a VALID_UOP_SOMTHING_OR_OTHER bit-field stuct which indicates
;   which IDVDAnnexJ commands are explicitly disable by the DVD disc.
;
; Raised from following domains: all
;
; Signaled when ever the available set of IDVDAnnexJ methods changes.  This
; only indicates which operations are explicited disabled by the content on 
; the DVD disc, and does not guarentee that it is valid to call methods 
; which are not disabled.  For example, if no buttons are currently present,
; IDVDAnnexJ::ButtonActivate() won't work, even though the buttons are not
; explicitly disabled. 
#EC_DVD_STILL_ON                         = (#EC_DVDBASE  + $09)
; Parameters: ( BOOL, DWORD ) 
; lParam1 == 0  -->  buttons are available, so StillOff won't work
; lParam1 == 1  -->  no buttons available, so StillOff will work
; lParam2 indicates the number of seconds the still will last, with $ffffffff 
;   indicating an infinite still (wait till button or StillOff selected).
;
; Raised from following domains: all
;
; Signaled at the beginning of any still: PGC still, Cell Still, or VOBU Still.
; Note that all combinations of buttons and still are possible (buttons on with
; still on, buttons on with still off, button off with still on, button off
; with still off).

#EC_DVD_STILL_OFF                         = (#EC_DVDBASE  + $0a)
; Parameters: ( void, void ) 
;
;   Indicating that any still that is currently active
;   has been released.
;
; Raised from following domains: all
;
; Signaled at the end of any still: PGC still, Cell Still, or VOBU Still.
;
#EC_DVD_CURRENT_TIME                     = (#EC_DVDBASE  + $0b)
; Parameters: ( DWORD, BOOL ) 
; lParam1 is a DVD_TIMECODE which indicates the current 
;   playback time code in a BCD HH:MM:SS:FF format.
; lParam2 == 0  -->  time code is 25 frames/sec
; lParam2 == 1  -->  time code is 30 frames/sec (non-drop).
; lParam2 == 2  -->  time code is invalid (current playback time 
;                    cannot be determined for current title)
;
; Raised from following domains: DVD_DOMAIN_Title
;
; Signaled at the beginning of every VOBU, which occurs every .4 to 1.0 sec.
; This is only signaled for One_Sequential_PGC_Titles.
#EC_DVD_ERROR                            = (#EC_DVDBASE  + $0c)
; Parameters: ( DWORD, void) 
; lParam1 is an enum DVD_ERROR which notifies the app of some error condition.
;
; Raised from following domains: all
;
#EC_DVD_WARNING                           = (#EC_DVDBASE  + $0d)
; Parameters: ( DWORD, DWORD) 
; lParam1 is an enum DVD_WARNING which notifies the app of some warning condition.
; lParam2 contains more specific information about the warning (warning dependent)
;
; Raised from following domains: all
;
#EC_DVD_CHAPTER_AUTOSTOP                  = (#EC_DVDBASE  + $0e)
; Parameters: (BOOL, void)
; lParam1 is a BOOL which indicates the reason for the cancellation of ChapterPlayAutoStop
; lParam1 == 0 indicates successful completion of ChapterPlayAutoStop
; lParam1 == 1 indicates that ChapterPlayAutoStop is being cancelled as a result of another
;            IDVDControl call or the end of content has been reached & no more chapters
;            can be played.
;  Indicating that playback is stopped as a result of a call
;  to IDVDControl::ChapterPlayAutoStop()
;
; Raised from following domains : DVD_DOMAIN_TITLE
;
#EC_DVD_NO_FP_PGC                         = (#EC_DVDBASE  + $0f)
;  Parameters : (void, void)
;
;  Raised from the following domains : FP_DOM
;
;  Indicates that the DVD disc does not have a FP_PGC (First Play Program Chain)
;  and the DVD Navigator will not automatically load any PGC and start playback.
;
#EC_DVD_PLAYBACK_RATE_CHANGE              = (#EC_DVDBASE  + $10)
;  Parameters : (LONG, void)
;  lParam1 is a LONG indicating the new playback rate.
;  lParam1 < 0 indicates reverse playback mode.
;  lParam1 > 0 indicates forward playback mode
;  Value of lParam1 is the actual playback rate multiplied by 10000.
;  i.e. lParam1 = rate * 10000
;
;  Raised from the following domains : TT_DOM
;
;  Indicates that a rate change in playback has been initiated and the parameter
;  lParam1 indicates the new playback rate that is being used.
;
#EC_DVD_PARENTAL_LEVEL_CHANGE            = (#EC_DVDBASE  + $11)
;  Parameters : (LONG, void)
;  lParam1 is a LONG indicating the new parental level.
;
;  Raised from the following domains : VMGM_DOM
;
;  Indicates that an authored Nav command has changed the parental level
;  setting in the player.
;
#EC_DVD_PLAYBACK_STOPPED                 = (#EC_DVDBASE  + $12)
;  Parameters : (DWORD, void)
;
;  Raised from the following domains : All Domains
;
; Indicates that playback has been stopped as the Navigator has completed
; playback of the pgc and did not find any other branching instruction for
; subsequent playback.
;
;  The DWORD returns the reason for the completion of the playback.  See
;  The DVD_PB_STOPPED enumeration for details.
;
#EC_DVD_ANGLES_AVAILABLE                 = (#EC_DVDBASE  + $13)
;  Parameters : (BOOL, void)
;  lParam1 == 0 indicates that playback is not in an angle block and angles are
;             not available
;  lParam1 == 1 indicates that an angle block is being played back and angle changes
;             can be performed.
;
;  Indicates whether an angle block is being played and if angle changes can be 
;  performed. However, angle changes are not restricted to angle blocks and the
;  manifestation of the angle change can be seen only in an angle block.
#EC_DVD_PLAYPERIOD_AUTOSTOP              = (#EC_DVDBASE  + $14)
; Parameters: (void, void)
; Sent when the PlayPeriodInTitle completes or is cancelled
;
; Raised from following domains : DVD_DOMAIN_TITLE
;
#EC_DVD_BUTTON_AUTO_ACTIVATED                 = (#EC_DVDBASE  + $15)
; Parameters: (DWORD button, void)
; Sent when a button is automatically activated
;
; Raised from following domains : DVD_DOMAIN_MENU
;
#EC_DVD_CMD_START                 = (#EC_DVDBASE  + $16)
; Parameters: (CmdID, HRESULT)
; Sent when a command begins
;
#EC_DVD_CMD_END                 = (#EC_DVDBASE  + $17)
; Parameters: (CmdID, HRESULT)
; Sent when a command completes
;
#EC_DVD_DISC_EJECTED                = (#EC_DVDBASE  + $18)
; Parameters: none
; Sent when the nav detects that a disc was ejected and stops the playback
; The app does not need to take any action to stop the playback.
;
#EC_DVD_DISC_INSERTED                = (#EC_DVDBASE  + $19)
; Parameters: none
; Sent when the nav detects that a disc was inserted and the nav begins playback
; The app does not need to take any action to start the playback.
;
#EC_DVD_CURRENT_HMSF_TIME                     = (#EC_DVDBASE  + $1a)
; Parameters: ( ULONG, ULONG ) 
; lParam2 contains a union of the DVD_TIMECODE_FLAGS
; lParam1 contains a DVD_HMSF_TIMECODE.  Assign lParam1 to a ULONG then cast the
; ULONG as a DVD_HMSF_TIMECODE to use its values.
;
; Raised from following domains: DVD_DOMAIN_Title
;
; Signaled at the beginning of every VOBU, which occurs every .4 to 1.0 sec.
#EC_DVD_KARAOKE_MODE                     = (#EC_DVDBASE  + $1b)
; Parameters: ( BOOL, reserved ) 
; lParam1 is either TRUE (a karaoke track is being played) or FALSE (no karaoke data is being played).

#DVD_MENU_Title      = 2     
#DVD_MENU_Root       = 3 
#DVD_MENU_Subpicture = 4
#DVD_MENU_Audio      = 5   
#DVD_MENU_Angle      = 6   
#DVD_MENU_Chapter    = 7   
    
#DVD_Struct_Title                = $02 
#DVD_Title_Movie                 = $39

#AM_DVD_HWDEC_PREFER =   $01
#AM_DVD_HWDEC_ONLY   =   $02
#AM_DVD_SWDEC_PREFER =   $04
#AM_DVD_SWDEC_ONLY   =   $08
#AM_DVD_NOVPE        =  $100
#AM_DVD_DO_NOT_CLEAR =  $200
#AM_DVD_VMR9_ONLY    =  $800
#AM_DVD_EVR_ONLY     = $1000

#PINDIR_INPUT = 0
#PINDIR_OUTPUT = 1

#AM_RENDEREX_RENDERTOEXISTINGRENDERERS = 1

#RenderPrefs_ForceOffscreen               = $00000001
#RenderPrefs_ForceOverlays                = $00000002
#RenderPrefs_AllowOverlays                = $00000000
#RenderPrefs_AllowOffscreen               = $00000000
#RenderPrefs_DoNotRenderColorKeyAndBorder = $00000008
#RenderPrefs_RestrictToInitialMonitor     = $00000010
#RenderPrefs_PreferAGPMemWhenMixing       = $00000020

#VMR9AllocFlag_3DRenderTarget   = $0001
#VMR9AllocFlag_DXVATarget       = $0002
#VMR9AllocFlag_TextureSurface   = $0004
#VMR9AllocFlag_OffscreenSurface = $0008
#VMR9AllocFlag_RGBDynamicSwitch = $0010
#VMR9AllocFlag_UsageReserved    = $00E0
#VMR9AllocFlag_UsageMask        = $00FF

#VMR9AlphaBitmap_Disable  = 1
#VMR9AlphaBitmap_hDC = 2
#VMR9AlphaBitmap_EntireDDS  = 4
#VMR9AlphaBitmap_SrcColorKey  = 8
#VMR9AlphaBitmap_SrcRect  = 16
#VMR9AlphaBitmap_FilterMode  = 32

#VMRBITMAP_DISABLE = 1
#VMRBITMAP_HDC = 2
#VMRBITMAP_ENTIREDDS = 4
#VMRBITMAP_SRCCOLORKEY = 8
#VMRBITMAP_SRCRECT  = 16


;2010-07-10 hinz.
Structure VMR9NormalizedRect
 left.f
  top.f
  right.f
  bottom.f
EndStructure

Structure NORMALIZEDRECT
  left.f
  top.f
  right.f
  bottom.f
EndStructure

Structure VMR9AlphaBitmap
  dwFlags.l
  hdc.l
  pDDS.IDirect3DSurface9
  rSrc.RECT
  rDest.VMR9NormalizedRect
  fAlpha.f
  clrSrcKey.l
  dwFilterMode.l
EndStructure

Structure VMRALPHABITMAP
  dwFlags.l
  hdc.l
  pDDS.IDirectDrawSurface7
  rSrc.RECT
  rDest.NORMALIZEDRECT
  fAlpha.f
  clrSrcKey.l
EndStructure

Structure VMR9AllocationInfo
  dwFlags.l
  dwWidth.l
  dwHeight.l
  Format.l
  Pool.l
  MinBuffers.l
  szAspectRatio.SIZE
  szNativeSize.SIZE
EndStructure



Structure VMR9PresentationInfo
  dwFlags.l
  *lpSurf.IDirect3DSurface9
  rtStart.q
  rtEnd.q
  szAspectRatio.SIZE
  rcSrc.RECT
  rcDst.RECT
  dwReserved1.l
  dwReserved2.l
EndStructure

Structure AM_DVD_RENDERSTATUS
  hrVPEStatus.i
  bDvdVolInvalid.i     
  bDvdVolUnknown.i     
  bNoLine21In.i
  bNoLine21Out.i           
  iNumStreams.i        
  iNumStreamsFailed.i 
  dwFailedStreamsFlag.i 
EndStructure

Structure DVD_HMSF_TIMECODE
  bHours.b
  bMinutes.b
  bSeconds.b
  bFrames.b
EndStructure

Structure MediaType
  majortype.GUID
  subtype.GUID  
  bFixedSizeSamples.l
  bTemporalCompression.l
  lSampleSize.l
  formattype.GUID      
  *pUnk.IUnknown  
  cbFormat.l
  *pbFormat
EndStructure

Structure DVD_PLAYBACK_LOCATION2
  TitleNum.l
  ChapterNum.l
  TimeCode.DVD_HMSF_TIMECODE
  TimeCodeFlags.l
EndStructure

Structure DVD_VideoAttributes
  fPanscanPermitted.l
  fLetterboxPermitted.l
  ulAspectX.l
  ulAspectY.l
  ulFrameRate.l
  ulFrameHeight.l
  Compression.l
  fLine21Field1InGOP.l
  fLine21Field2InGOP.l
  ulSourceResolutionX.l
  ulSourceResolutionY.l
  fIsSourceLetterboxed.l
  fIsFilmMode.l
EndStructure

CompilerIf Defined(FILTER_INFO, #PB_Structure) = #False
  Structure FILTER_INFO
    achName.w[#MAX_FILTER_NAME]
    *pGraph.IFilterGraph 
  EndStructure
CompilerEndIf

CompilerIf Defined(IEnumFilters, #PB_Interface) = #False
  Interface IEnumFilters
    QueryInterface(a, b)
    AddRef()
    Release()
    Next(a, b, c)
    Skip(a)
    Reset()
    Clone(a)
 EndInterface
CompilerEndIf

; Interface IMediaTypeFormat
;   ToCodecDataString()
; EndInterface  
; Structure AMMediaType
;   FixedSizeSamples.i
;   Format.IMediaTypeFormat
;   MajorType.MediaType
;   SubType.MediaType
;   FourCC.l
;   SampleSize.i
; EndStructure


Interface _IMediaSeeking
  QueryInterface(a, b)
  AddRef()
  Release()
  GetCapabilities(a)
  CheckCapabilities(a)
  IsFormatSupported(a)
  QueryPreferredFormat(a)
  GetTimeFormat(a)
  IsUsingTimeFormat(a)
  SetTimeFormat(a)
  GetDuration(a)
  GetStopPosition(a)
  GetCurrentPosition(a)
  ConvertTimeFormat(a, b, c, d, e)
  SetPositions(a, b, c, d)
  GetPositions(a, b)
  GetAvailable(a, b)
  SetRate(a.d)
  GetRate(a)
  GetPreroll(a)
EndInterface

Interface _IDvdInfo2
  QueryInterface(a, b)
  AddRef()
  Release()
  GetCurrentDomain(a)
  GetCurrentLocation(a)
  GetTotalTitleTime(a, b)
  GetCurrentButton(a, b)
  GetCurrentAngle(a, b)
  GetCurrentAudio(a, b)
  GetCurrentSubpicture(a, b, c)
  GetCurrentUOPS(a)
  GetAllSPRMs(a)
  GetAllGPRMs(a)
  GetAudioLanguage(a, b)
  GetSubpictureLanguage(a, b)
  GetTitleAttributes(a, b, c)
  GetVMGAttributes(a)
  GetCurrentVideoAttributes(a)
  GetAudioAttributes(a, b)
  GetKaraokeAttributes(a, b)
  GetSubpictureAttributes(a, b)
  GetDVDVolumeInfo(a, b, c, d)
  GetDVDTextNumberOfLanguages(a)
  GetDVDTextLanguageInfo(a, b, c, d)
  GetDVDTextStringAsNative(a, b, c, d, e, f)
  GetDVDTextStringAsUnicode(a, b, c, d, e, f)
  GetPlayerParentalLevel(a, b)
  GetNumberOfChapters(a, b)
  GetTitleParentalLevels(a, b)
  GetDVDDirectory(a, b, c)
  IsAudioStreamEnabled(a, b)
  GetDiscID(a, b)
  GetState(a)
  GetMenuLanguages(a, b, c)
  GetButtonAtPosition(a, b)
  GetCmdFromEvent(a, b)
  GetDefaultMenuLanguage(a)
  GetDefaultAudioLanguage(a, b)
  GetDefaultSubpictureLanguage(a, b)
  GetDecoderCaps(a)
  GetButtonRect(a, b)
  IsSubpictureStreamEnabled(a, b)
EndInterface
  
Interface _IDvdControl2
  QueryInterface(a, b)
  AddRef()
  Release()
  PlayTitle(a, b, c)
  PlayChapterInTitle(a, b, c, d)
  PlayAtTimeInTitle(a, b, c, d)
  Stop()
  ReturnFromSubmenu(a, b)
  PlayAtTime(a, b, c)
  PlayChapter(a, b, c)
  PlayPrevChapter(a, b)
  ReplayChapter(a, b)
  PlayNextChapter(a, b)
  PlayForwards(a.d, b, c)
  PlayBackwards(a.d, b, c)
  ShowMenu(a, b, c)
  Resume(a, b)
  SelectRelativeButton(a)
  ActivateButton()
  SelectButton(a)
  SelectAndActivateButton(a)
  StillOff()
  Pause(a)
  SelectAudioStream(a, b, c)
  SelectSubpictureStream(a, b, c)
  SetSubpictureState(a, b, c)
  SelectAngle(a, b, c)
  SelectParentalLevel(a)
  SelectParentalCountry(a)
  SelectKaraokeAudioPresentationMode(a)
  SelectVideoModePreference(a)
  SetDVDDirectory(a)
  ActivateAtPosition(a.q)
  SelectAtPosition(a.q)
  PlayChaptersAutoStop(a, b, c, d, e)
  AcceptParentalLevelChange(a)
  SetOption(a, b)
  SetState(a, b, c)
  PlayPeriodInTitleAutoStop(a, b, c, d, e)
  SetGPRM(a, b, c, d)
  SelectDefaultMenuLanguage(a)
  SelectDefaultAudioLanguage(a, b)
  SelectDefaultSubpictureLanguage(a, b)
EndInterface

Interface _IGraphBuilder
  QueryInterface(a, b)
  AddRef()
  Release()
  AddFilter(a, b)
  RemoveFilter(a)
  EnumFilters(a)
  FindFilterByName(a, b)
  ConnectDirect(a, b, c)
  Reconnect(a)
  Disconnect(a)
  SetDefaultSyncSource()
  Connect(a, b)
  Render(a)
  RenderFile(a, b)
  AddSourceFilter(a.p-unicode, b.p-unicode, c)
  SetLogFile(a)
  Abort()
  ShouldOperationContinue()
EndInterface


Macro DEFINE_GUID(Name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8)
  Global Name.GUID
  Name\Data1 = l
  Name\Data2 = w1
  Name\Data3 = w2
  Name\Data4[0] = b1
  Name\Data4[1] = b2
  Name\Data4[2] = b3
  Name\Data4[3] = b4
  Name\Data4[4] = b5
  Name\Data4[5] = b6
  Name\Data4[6] = b7
  Name\Data4[7] = b8
EndMacro

DEFINE_GUID(CLSID_FilterGraph,          $E436EBB3, $524F, $11CE, $9F, $53, $00, $20, $AF, $0B, $A7, $70)
DEFINE_GUID(IID_IDvdGraphBuilder,       $FCC152B6, $F372, $11d0, $8E, $00, $00, $C0, $4F, $D7, $C0, $8B)
DEFINE_GUID(CLSID_IDvdGraphBuilder,     $FCC152B7, $F372, $11d0, $8E, $00, $00, $C0, $4F, $D7, $C0, $8B)

DEFINE_GUID(IID_IGraphBuilder,          $56A868A9, $0AD4, $11CE, $B0, $3A, $00, $20, $AF, $0B, $A7, $70)
DEFINE_GUID(IID_IMediaControl,          $56A868B1, $0AD4, $11CE, $B0, $3A, $00, $20, $AF, $0B, $A7, $70)
DEFINE_GUID(IID_IMediaEventEx,          $56A868C0, $0AD4, $11CE, $B0, $3A, $00, $20, $AF, $0B, $A7, $70)
DEFINE_GUID(IID_IMediaSeeking,          $36B73880, $C2C8, $11CF, $8B, $46, $00, $80, $5F, $6C, $EF, $60)
DEFINE_GUID(IID_IVideoWindow,           $56A868B4, $0AD4, $11CE, $B0, $3A, $00, $20, $AF, $0B, $A7, $70)
DEFINE_GUID(IID_IBasicAudio,            $56A868B3, $0AD4, $11CE, $B0, $3A, $00, $20, $AF, $0B, $A7, $70)
DEFINE_GUID(IID_IBasicVideo,            $56A868B5, $0AD4, $11CE, $B0, $3A, $00, $20, $AF, $0B, $A7, $70)
DEFINE_GUID(IID_IBasicVideo2,           $329bb360, $f6ea, $11d1, $90, $38, $00, $a0, $c9, $69, $72, $98)
DEFINE_GUID(IID_IMediaSeeking,          $36B73880, $C2C8, $11CF, $8B, $46, $00, $80, $5F, $6C, $EF, $60)
DEFINE_GUID(IID_IBaseFilter,            $56A86895, $0AD4, $11CE, $B0, $3A, $00, $20, $AF, $0B, $A7, $70)
DEFINE_GUID(CLSID_VideoMixingRenderer,  $B87BEB7B, $8D29, $423F, $AE, $4D, $65, $82, $C1, $01, $75, $AC)
DEFINE_GUID(IID_IVMRFilterConfig,       $9E5530C5, $7034, $48B4, $BB, $46, $0B, $8A, $6E, $FC, $8E, $36)
DEFINE_GUID(CLSID_VideoMixingRenderer9, $51B4ABF3, $748F, $4E3B, $A2, $76, $C8, $28, $33, $0E, $92, $6A)
DEFINE_GUID(IID_IVMRFilterConfig9,      $5A804648, $4F66, $4867, $9C, $43, $4F, $5C, $82, $2C, $F1, $B8)
DEFINE_GUID(IID_IVMRWindowlessControl9, $8F537D09, $F85E, $4414, $B2, $3B, $50, $2E, $54, $C7, $99, $27)
DEFINE_GUID(IID_IVMRWindowlessControl,  $0EB1088C, $4DCD, $46F0, $87, $8F, $39, $DA, $E8, $6A, $51, $B7)
DEFINE_GUID(CLSID_OverlayMixer,         $CD8743A1, $3736, $11D0, $9E, $69, $00, $C0, $4F, $D7, $C1, $5B)
DEFINE_GUID(CLSID_VideoRenderer,        $70E102B0, $5556, $11CE, $97, $C0, $00, $AA, $00, $55, $59, $5A)
DEFINE_GUID(CLSID_AudioRender,          $E30629D1, $27E5, $11CE, $87, $5D, $00, $60, $8C, $B7, $80, $66)
DEFINE_GUID(TIME_FORMAT_MEDIA_TIME,     $7B785574, $8C82, $11CF, $BC, $0C, $00, $AA, $00, $AC, $74, $F6)
;DSound audio renderer
DEFINE_GUID(CLSID_DSoundRender,$79376820, $07D0, $11CF, $A2, $4D, $0, $20, $AF, $D7, $97, $67)
;DEFINE_GUID(CLSID_MFVideoMixer9,$E474E05A, $AB65, $4f6a, $82, $7C, $21, $8B, $1B, $AA, $F3, $1F)
; {FA10746C-9B63-4b6c-BC49-FC300EA5F256}
DEFINE_GUID(CLSID_EnhancedVideoRenderer, $fa10746c, $9b63, $4b6c, $bc, $49, $fc, $30, $e, $a5, $f2, $56)
DEFINE_GUID(CLSID_MFVideoPresenter9, $98455561, $5136, $4d28, $ab, $8, $4c, $ee, $40, $ea, $27, $81)
;OUR_GUID_ENTRY(CLSID_AudioRender,
;0xe30629d1, 0x27e5, 0x11ce, 0x87, 0x5d, 0x0, 0x60, 0x8c, 0xb7, 0x80, 0x66)
DEFINE_GUID(IID_IMixerPinConfig,$593cdde1, $759, $11d1, $9e, $69, $0, $c0, $4f, $d7, $c1, $5b)
;// {EBF47182-8764-11d1-9E69-00C04FD7C15B}
DEFINE_GUID(IID_IMixerPinConfig2,$ebf47182, $8764, $11d1, $9e, $69, $0, $c0, $4f, $d7, $c1, $5b)
DEFINE_GUID(IID_IVMRAspectRatioControl9, $00d96c29,$bbde,$4efc,$99,$01,$bb,$50,$36,$39,$21,$46)
DEFINE_GUID(IID_IVMRAspectRatioControl, $ede80b5c, $bad6,$4623,$b5,$37,$65,$58,$6c,$9f,$8d,$fd)
DEFINE_GUID(IID_IDvdControl2, $33BC7430, $EEC0, $11D2, $82,$01,$00,$A0,$C9,$D7,$48,$42)
DEFINE_GUID(IID_IDvdInfo2, $34151510, $EEC0,$11D2,$82,$01,$00, $A0,$C9 ,$D7,$48,$42)

;// {6BC1CFFA-8FC1-4261-AC22-CFB4CC38DB50}
;OUR_GUID_ENTRY(CLSID_VideoRendererDefault,
;0x6BC1CFFA, 0x8FC1, 0x4261, 0xAC, 0x22, 0xCF, 0xB4, 0xCC, 0x38, 0xDB, 0x50)

DEFINE_GUID(IID_IFilterGraph2, $36b73882, $c2c8, $11cf, $8b,$46,$00,$80,$5f,$6c,$ef,$60)
DEFINE_GUID(CLSID_WMAsfReader,$187463a0, $5bb7, $11d3, $ac, $be, $0, $80, $c7, $5e, $24, $6e)
DEFINE_GUID(IID_IFileSourceFilter,$56a868a6,$0ad4,$11ce,$b0,$3a,$00,$20,$af,$0b,$a7,$70)

DEFINE_GUID(CLSID_SampleGrabber, $C1F400A0, $3F08, $11d3, $9F,$0B,$00,$60,$08,$03,$9E,$37)
DEFINE_GUID(IID_ISampleGrabber, $6B652FFF, $11FE, $4fce, $92,$AD,$02,$66,$B5,$D7,$C7,$8F)
DEFINE_GUID(MEDIATYPE_Audio,$73647561, $0000, $0010, $80, $00, $00, $aa, $00, $38, $9b, $71)


DEFINE_GUID(FORMAT_WaveFormatEx,$05589f81, $c356, $11ce, $bf, $01, $00, $aa, $00, $55, $59, $5a)

DEFINE_GUID(MEDIASUBTYPE_PCM,$00000001, $0000, $0010, $80, $00, $00, $AA, $00, $38, $9B, $71)


;===============================================================================
; Own Surface Allocator
;===============================================================================

DEFINE_GUID(IID_IVMRSurfaceAllocatorNotify9, $dca3f5df,$bb3a,$4d03,$bd,$81,$84,$61,$4b,$fb,$fa,$0c)


DEFINE_GUID(IID_IVMRImagePresenter9,$69188c61,$12a3,$40f0,$8f,$fc,$34,$2e,$7b,$43,$3f,$d7)


DEFINE_GUID(IID_IVMRSurfaceAllocator9,$8d5148ea,$3f5d,$46cf,$9d,$f1,$d1,$b8,$96,$ee,$db,$1f)

DEFINE_GUID(IID_IUnknown,$00000000,$0000,$0000,$C0,$00,$00,$00,$00,$00,$00,$46)

;===============================================================================

;2010-07-10 hinz.
DEFINE_GUID(IID_IVMRMixerBitmap9,$ced175e5,$1935,$4820,$81,$bd,$ff,$6a,$d0,$0c,$91,$08)
DEFINE_GUID(IID_IVMRMixerControl9,$1a777eaa,$47c8,$4930,$b2,$c9,$8f,$ee,$1c,$1b,$0f,$3b)
DEFINE_GUID(IID_IAMStreamSelect,$c1960960,$17f5,$11d1,$ab,$e1,$00,$a0,$c9,$05,$f3,$75)

DEFINE_GUID(IID_IVMRMixerBitmap,$1E673275,$0257,$40aa,$AF,$20,$7C,$60,$8D,$4A,$04,$28)

; 73646976-0000-0010-8000-00AA00389B71  'vids' == MEDIATYPE_Video
DEFINE_GUID(MEDIATYPE_Video, $73646976, $0000, $0010, $80, $00, $00, $aa, $00, $38, $9b, $71)
; 73647561-0000-0010-8000-00AA00389B71  'auds' == MEDIATYPE_Audio
DEFINE_GUID(MEDIATYPE_Audio, $73647561, $0000, $0010, $80, $00, $00, $aa, $00, $38, $9b, $71)
; 73747874-0000-0010-8000-00AA00389B71  'txts' == MEDIATYPE_Text
DEFINE_GUID(MEDIATYPE_Text, $73747874,  $0000, $0010, $80, $00, $00, $aa, $00, $38, $9b, $71)

DEFINE_GUID(MEDIASUBTYPE_Overlay, $e436eb7f, $524f, $11ce, $9f, $53, $00, $20, $af, $0b, $a7, $70)

DEFINE_GUID(LAV_Splitter,       $171252A0,$8820,$4AFE,$9D,$F8,$5C,$92,$B2,$D6,$6B,$04)

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 727
; FirstLine = 705
; Folding = -
; EnableXP
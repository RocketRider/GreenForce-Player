; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{2318E9DF-8E1D-4E04-84D6-85098CFF854E}}
AppName=GreenForce-Player
AppVerName=GreenForce-Player 2.00
VersionInfoVersion=2.00
AppPublisher=RRSoftware
VersionInfoCopyright=(c) 2009-2017 RocketRider
AppPublisherURL=http://gfp.rrsoftware.de
AppSupportURL=http://gfp.rrsoftware.de
AppUpdatesURL=http://gfp.rrsoftware.de
DefaultDirName={pf}\GreenForce-Player
DefaultGroupName=GreenForce-Player
AllowNoIcons=yes
InfoBeforeFile=..\ReadmeEN.txt
;OutputDir=C:\Users\Admin\Desktop\Projects\PureBasic\GFP-Install
OutputBaseFilename=GFP-Setup-v2.00
SetupIconFile=Icon.ico
WizardSmallImageFile=Box.bmp
WizardImageFile=Logo_Black.bmp
Compression=lzma2/ultra64
SolidCompression=yes
DisableWelcomePage=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "greek"; MessagesFile: "compiler:Languages\Greek.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "Pportuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "serbianLatin"; MessagesFile: "compiler:Languages\SerbianLatin.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"


[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags:checkedonce
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags:checkedonce

[Files]
Source: "..\GreenForce-Player.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\GFP-SDK\*"; DestDir: "{app}\GFP-SDK\"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Help\*"; DestDir: "{app}\Help\"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Data\uninstall.ico"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\GreenForce-Player"; Filename: "{app}\GreenForce-Player.exe"
Name: "{group}\GFPCrypt-GUI"; Filename: "{app}\GFP-SDK\GFPCrypt-GUI\GFPCrypt-GUI.exe"
Name: "{group}\Documentation"; Filename: "{app}\Help\GFP-Documentation.html"
Name: "{group}\FAQ"; Filename: "{app}\Help\FAQ.pdf"
Name: "{group}\{cm:ProgramOnTheWeb,GreenForce-Player}"; Filename: "http://gfp.rrsoftware.de"
Name: "{group}\{cm:UninstallProgram,GreenForce-Player}"; Filename: "{uninstallexe}"; IconFilename: "{app}\uninstall.ico"
Name: "{commondesktop}\GreenForce-Player"; Filename: "{app}\GreenForce-Player.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\GreenForce-Player"; Filename: "{app}\GreenForce-Player.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\GreenForce-Player.exe"; Parameters: "/codecdownload"; Flags: runascurrentuser waituntilterminated
Filename: "{app}\GreenForce-Player.exe"; Description: "{cm:LaunchProgram,GreenForce-Player}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{app}\GreenForce-Player.exe"; Parameters: "/deletelavfilters"; Flags: runascurrentuser waituntilterminated

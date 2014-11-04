//-----------------------------------------------------------------------------------------------
// Include for Lazarus/Delphi to create protected video/audio files
// Written by Michael Moebius
// Version 1.0 (September 2011)
//-----------------------------------------------------------------------------------------------

unit GFPCryptDLL;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
 CRYPT_DLL = 'GFPCrypt.dll';

 DRM_ENCRYPTION_VERSION_1_0 = 0;
 DRM_ENCRYPTION_VERSION_2_0 = 1;

 DRM_CONTENTPROTECTION_ON = 0;
 DRM_CONTENTPROTECTION_OFF = 1;
 DRM_CONTENTPROTECTION_EXTENDED = 2;

function SetMediaHint(sHintText : string) : Integer; stdcall; external CRYPT_DLL name 'SetMediaHintA';
function SetMediaInterpreter(sInterpreterText : string) : Integer; stdcall; external CRYPT_DLL name 'SetMediaInterpreterA';
function SetMediaComment(sCommentText : string) : Integer; stdcall; external CRYPT_DLL name 'SetMediaCommentA';
function SetMediaTitel(sTitleText : string) : Integer; stdcall; external CRYPT_DLL name 'SetMediaTitelA';
function SetMediaAlbum(sAlbumText : string) : Integer; stdcall; external CRYPT_DLL name 'SetMediaAlbumA';
function SetMediaCodecName(sCodecNameText : string) : Integer; stdcall; external CRYPT_DLL name 'SetMediaCodecNameA';
function SetMediaCodecLink(sCodecLinkText : string) : Integer; stdcall; external CRYPT_DLL name 'SetMediaCodecLinkA';
function SetMediaAllowRestore(bAllow : Integer) : Integer; stdcall; external CRYPT_DLL name 'SetMediaAllowRestore';
function SetMediaContentProtection(iContentProtectionOption : Integer) : Integer; stdcall; external CRYPT_DLL name 'SetMediaContentProtection';
function SetMediaLength(qMediaLength : Int64) : Integer; stdcall; external CRYPT_DLL name 'SetMediaLength';
function SetMediaCoverFile(sCover : string) : Integer; stdcall; external CRYPT_DLL name 'SetMediaCoverFileA';
function SetMediaOemText(sOEMText : string) : Integer; stdcall; external CRYPT_DLL name 'SetMediaOemTextA';
function CheckMedia(sFile : string) : Integer; stdcall; external CRYPT_DLL name 'CheckMediaA';
function InitCheckMedia() : Integer; stdcall; external CRYPT_DLL name 'InitCheckMedia';
function FreeCheckMedia() : Integer; stdcall; external CRYPT_DLL name 'FreeCheckMedia';
//function CB(p : Int64,s : Int64): integer;
function EncryptMediaFile(sSource : string; sOutput : string; sPassword : string; Flags : Integer; cbCallback : pointer) : Integer; stdcall; external CRYPT_DLL name 'EncryptMediaFileA';
function DecryptMediaFile(sSource : string; sOutput : string; sPassword : string; Flags : Integer; cbCallback : pointer) : Integer; stdcall; external CRYPT_DLL name 'DecryptMediaFileA';

implementation


end.


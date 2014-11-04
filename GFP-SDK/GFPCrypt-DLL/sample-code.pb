
#DRM_ENCRYPTION_VERSION_1_0 = 0
#DRM_ENCRYPTION_VERSION_2_0 = 1


#DRM_CONTENTPROTECTION_ON = 0
#DRM_CONTENTPROTECTION_OFF = 1
#DRM_CONTENTPROTECTION_EXTENDED = 2

Prototype.i CB(p.q,s.q)
Prototype.i SetMediaHint(sHintText.p-ascii)
Prototype.i SetMediaInterpreter(sInterpreterText.p-ascii)
Prototype.i SetMediaComment(sCommentText.p-ascii)
Prototype.i SetMediaTitel(sTitleText.p-ascii)
Prototype.i SetMediaAlbum(sAlbumText.p-ascii)
Prototype.i SetMediaCodecName(sCodecNameText.p-ascii)
Prototype.i SetMediaCodecLink(sCodecLinkText.p-ascii)
Prototype.i SetMediaAllowRestore(bAllow)
Prototype.i SetMediaContentProtection(iContentProtectionOption)
Prototype.i SetMediaLength(qMediaLength.q)
Prototype.i SetMediaCoverFile(sCover.p-ascii)
Prototype.i SetMediaOemText(sOEMText.p-ascii)
Prototype.i CheckMedia(sFile.p-ascii)
Prototype.i InitCheckMedia()
Prototype.i FreeCheckMedia()
Prototype.i EncryptMediaFile(sSource.p-ascii, sOutput.p-ascii, sPassword.p-ascii, Flags, *cbCallback)
Prototype.i DecryptMediaFile(sSource.p-ascii, sOutput.p-ascii, sPassword.p-ascii, Flags, *cbCallback)


If OpenLibrary(0, "GPFCrypt.dll") = 0
  MessageRequester("Error", "Failed to load dll!")
EndIf  

SetMediaHint.SetMediaHint = GetFunction(0, "SetMediaHintA")
SetMediaInterpreter.SetMediaInterpreter = GetFunction(0, "SetMediaInterpreterA")
SetMediaComment.SetMediaComment = GetFunction(0, "SetMediaCommentA")
SetMediaTitel.SetMediaTitel = GetFunction(0, "SetMediaTitelA")
SetMediaAlbum.SetMediaAlbum = GetFunction(0, "SetMediaAlbumA")
SetMediaCodecName.SetMediaCodecName = GetFunction(0, "SetMediaCodecNameA")
SetMediaCodecLink.SetMediaCodecLink = GetFunction(0, "SetMediaCodecLinkA")
SetMediaAllowRestore.SetMediaAllowRestore = GetFunction(0, "SetMediaAllowRestore")
SetMediaContentProtection.SetMediaContentProtection = GetFunction(0, "SetMediaContentProtection")
SetMediaLength.SetMediaLength = GetFunction(0, "SetMediaLength")
SetMediaCoverFile.SetMediaCoverFile = GetFunction(0, "SetMediaCoverFileA")
SetMediaOemText.SetMediaOemText = GetFunction(0, "SetMediaOemTextA")
EncryptMediaFile.EncryptMediaFile = GetFunction(0, "EncryptMediaFileA")
DecryptMediaFile.DecryptMediaFile = GetFunction(0, "DecryptMediaFileA")
CheckMedia.CheckMedia = GetFunction(0, "CheckMediaA")
InitCheckMedia.InitCheckMedia = GetFunction(0, "InitCheckMedia")
FreeCheckMedia.FreeCheckMedia = GetFunction(0, "FreeCheckMedia")


InitCheckMedia()

Debug CheckMedia("testmusic.ogg")
SetMediaTitel("This is a test title")
SetMediaInterpreter("This is a test interpreter")
SetMediaAlbum("This is a test album")
SetMediaCodecLink("http://gfp.rrsoftware.de")
SetMediaCodecName("MyCodec")
SetMediaCoverFile("testcover.jpg") 
SetMediaAllowRestore(#True)
SetMediaOemText("my_oem_file.dat")
SetMediaContentProtection(#DRM_CONTENTPROTECTION_ON) ; Protection agains screenshots
EncryptMediaFile("testmusic.ogg", "", "test", #DRM_ENCRYPTION_VERSION_2_0, -1) ; "test" is the password

;DecryptMediaFile("testmusic.gfp","restore.ogg", "test", #DRM_ENCRYPTION_VERSION_2_0, -1)
FreeCheckMedia()
CloseLibrary(0)
; IDE Options = PureBasic 4.70 Beta 1 (Windows - x86)
; CursorPosition = 6
; EnableXP
; EnableCompileCount = 4
; EnableBuildCount = 0
; EnableExeConstant
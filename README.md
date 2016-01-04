# GreenForce-Player

It is an alternative player to play video and audio media and it allows to password protect videos. 
It's specifically designed for reducing the hard drives access by using a cache system to extend the battery life of laptops. 
In addition, the player supports the ability to encrypt media files to protect them with a password from unauthorized access.

Currently supported features: 
-----------------------------
- Playing video files (depending on the installed DirectShow codecs) 
- E.g. Windows 7: wmv, avi, mpg, mpeg, vob, asf, ... 
- Audio playback (depending on the installed DirectShow codecs) 
- E.g. Windows 7: ogg, flac, wma, mp3, wav, ... 
- Integrated Ogg and Flac Decoder!
- Custom container format (*. gfp) for password protected media (provides configuration options to prevent screenshots and to restore the original file). 
- For more codecs you can install a codec pack for example K-Lite codecs (http://www.codecguide.com)
- Audio CD playback 
- DVD video playback 
- Video and audio streaming from internet
- Visualisation
- Automatic update function
- Import different playlist formats

- Supported languages are English, German, Turkish, Nederlands, Spanish and French for now (suggestions for improvements and new language translations are welcome) 
- Playlists (with support for import, export, tags) 
- Aspect ratio (1:1, 4:3, 5:4, 16:9, 16:10, 21:9) 
- Play small files from memory (cache function) to reduce the hard drive usage. 
- Snapshot function (save as JPG, JPEG2000, PNG) 
- Various playback options: Repeat, Random Play 
- many different audio and video renderers 
- Full screen mode
- Minimal screen mode
- Intelligent file extension links 
- Command line switch (/aspect, /fullscreen, /?, /volume, /password, /hidden, /Invisible,...) 
- Standalone EXE with only 3 MB (there are no other files required) 
- Fully developed in PureBasic 



Commandline params:
-------------------
/? /help /h 		shows this help
/aspect     		predefines aspect ratio (16:9, 21:9, ...)
/fullscreen 		starts in fullscreen
/volume     		predefines volume (0 - 100)
/password   		predefines password
			use " if it contains spaces
/hidden     		starts player invisible (or /invisible)
/database   		use alternative database file
			use [APPDATA],[DESKTOP],
			[DOCUMENTS],[HOME],[TEMP],
			and [PROGRAM] for predefined paths
/importlist 		imports a playlist permanently
/loglevel   		predefine loglevel
			use 0(None), 1(Error) and 2(Debug)
/restoredatabase	restore default database
/videorenderer		predefines video renderer
			0(Def.), 1(VMR9), 2(VMR7), 3(Old-Rend.),
			4(Overlay),5(DShow Def.), 6(VMR9-Wnd),
			7(VMR7-Wnd), 8(Own Rend.)
/audiorenderer		predefines audio renderer
			0(Def.), 1(Waveout), 2(DSound)
/closeafterplayback	close player after playback of the first media file
/usedesign		sets the used design
/installdesign		installs a new design
/ahook			uses alternative hooking
/disablehook		disables hooking
/disablemenu		hides the menu
/deletestreamingcache	delets the streaming cache
/proxyip		sets the proxy ip
/proxyport		sets the proxy port
/useiesettings		uses the ie settings for proxy
/proxybypasslocal	proxy bypass local
/noredirect		no redirect
/passwordfile		reads the password out of an file
/disablestreaming	disables the streaming
/passwordpipe		reads the password out of an rsa encrypted pipe
/position		set the start position of the video

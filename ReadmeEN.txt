*************************************** Version: 2.1
*** GreenForce Player *** GF-Player ***
***************************************
*** (c) 2009 - 2017 RocketRider *******
*** http://GFP.RRSoftware.de ********** 
***************************************
Support@GFP.RRSoftware.de


GreenForce-Player is an alternative player to play video and audio media. A special feature is that it allows to password protect video and audio files. 
It is specifically designed for reducing the hard drive access by using a cache system to extend the battery life of laptops. 
In addition, the player supports the ability to encrypt media files to protect them with a password from unauthorized access.

Bug reports and suggestions are very welcome.

Currently supported features: 
-----------------------------
- automatic Download of Codecs (LAV Filters)
- Playing video files (depending on the installed DirectShow codecs) 
- E.g. Windows 7: wmv, avi, mpg, mpeg, vob, asf, ... 
- Audio playback (depending on the installed DirectShow codecs) 
- E.g. Windows 7: ogg, flac, wma, mp3, wav, ... 
- Integrated Ogg and Flac Decoder!
- Custom container format (*. gfp) for password protected media (provides configuration options to prevent screenshots and to restore the original file). 
- For more codecs you can install a codec pack like K-Lite codecs (http://www.codecguide.com)
- Audio CD playback 
- DVD video playback 
- Video and audio streaming from internet
- Visualisation
- Automatic update function
- Import different playlist formats

- Supported languages are English, German, Turkish, Nederlands, Spanish, French, Greek, Portuguese, Swedish, Italian, Serbian, Bulgarian, Russian and Persian for now (suggestions for improvements and new language translations are welcome) 
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
- Standalone EXE with only ~4 MB (there are no other files required) 
- Fully developed in PureBasic 



Commandline params:
-------------------
/? /help /h 		shows command line parameters
/morehelp			shows all command line parameters
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
/showmsgbox			- Shows a messagebox with title and text at startup
/showmsgcheck		- Shows a messagebox with title and text at startup with the possiblility to not show it again

Acknowledgements
----------------

Warkering
for the great French translation

Saner Apaydin
for the great Turkish translation

Carl Peeraer
for the great Nederlands translation

Mauricio Cantún Caamal
for the great Spanish translation

Jacobus
for the fantastic green iconset

Surena Karimpour
for the great Persian translation

LAV Filters (https://github.com/Nevcairiel/LAVFilters)
for ffmpeg based DirectShow Splitter and Decoders

http://Xiph.org Xiph.org Foundation
for the fantastic ogg and flac decoder

Independent JPEG Group
this software is based in part on the work of the Independent JPEG Group

OpenJPEG
for the JPEG2000 codec


Terms and conditions
--------------------

This program is provided "As it is".
The author is not responsible for any damage (or damages) caused by GreenForce-Player or caused by the use of the GreenForce-Player.
This is except for damages which cannot be excluded because of law. You are warned that you use this software at your own risk.
No warranties are implied or given by the author or any other representative.
All components are copyrighted by the author.
You are not allowed to reverse engineer the whole or parts of the software.
You are also not allowed to modify or patch executables and other files of this software.

You are allowed to use this software in noncommercial and commercial products.
If the software is used within commercial products a mention of the author and a donate would be desirable but is not necessary.



OpenJPEG

Copyright (c) 2002-2012, Communications and Remote Sensing Laboratory, Universite catholique de Louvain (UCL), Belgium Copyright (c) 2002-2012, Professor Benoit Macq Copyright (c) 2003-2012, Antonin Descampe Copyright (c) 2003-2009, Francois-Olivier Devaux Copyright (c) 2005, Herve Drolon, FreeImage Team Copyright (c) 2002-2003, Yannick Verschueren Copyright (c) 2001-2003, David Janssens All rights reserved. 
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS `AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

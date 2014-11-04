*************************************** Version: 1.21
*** GreenForce Player *** GF-Player ***
***************************************
*** (c) 2009 - 2013 RocketRider *******
*** http://GFP.RRSoftware.de ********** 
***************************************
Support@GFP.RRSoftware.de


Es handelt sich hierbei um einen alternativen Player zum abspielen von Video und Audio Medien.
Er ist speziell für die Reduktion von Festplattenaktivitäten ausgelegt um somit die Akkulaufzeit von Laptops zu verlängern.
Außerdem unterstützt der Player die Möglichkeit Mediendateien mit einem Passwort zu verschlüsseln, um sie vor fremdem Zugriff zu schützen.

Bug Reports und Anregungen sind immer sehr Willkommen.
Bitte wenden Sie sich an Support@GFP.RRSoftware.de.


Momentan unterstützte Funktionalitäten:
---------------------------------------
- Video Dateien Abspielen (abhängig von den installierten DirectShow Codecs)
- z.B. unter Windows 7: wmv, avi, mpg, mpeg, vob, asf, ...
- Audio Dateien Abspielen (abhängig von den installierten DirectShow Codecs)
- z.B. unter Windows 7: ogg, flac, wma, mp3, wav, ...
- Integrierte Ogg und Flac Decoder!
- Eigenes Containerformat(*.gfp) für passwortgeschützte Medien (Bietet Einstellungsmöglichkeiten um Screenshots zu verhindern und Wiederherstellung der Orginaldatei).
- Für weitere Codecs können Codecpacks installiert werden, wie z. B. die K-Lite Codecs (http://www.codecguide.com)
- Audio CDs abspielen
- Video DVDs abspielen
- Video- und Audio-Streaming aus dem Internet
- Visualisierung
- Automatische Updates
- Importieren von verschiedenen Playlistformaten

- Unterstützt die Sprachen Englisch, Deutsch, Türkisch, Spanisch, Niederländisch und Französich ( Verbesserungsvorschläge und andere Sprachenübersetzungen sind Willkommen)
- Playlisten (mit Unterstützung für Import, Export und Auslesen der Tags)
- Seitenverhältnis setzbar (1:1, 4:3, 5:4, 16:9, 16:10, 21:9)
- Cache um kleine Dateien aus dem Arbeitspeicher abzuspielen, um die Festplatte zu schonen.
- Snapshot Funktion (speicherbar als JPG, JPEG2000, PNG)
- Verschiedene Wiedergabemöglichkeiten: Wiederholen, zufällige Wiedergabe
- Viele verschiedene Audio- und Video-Renderer einstellbar
- Fullscreenmodus 
- Minimalmodus
- Intelligente Dateiverknüpfungen
- Kommandozeilenparameter (/aspect, /fullscreen, /?, /volume, /password, /hidden, /Invisible,...)
- Standalone EXE mit nur 3 MB (es werden keine weiteren Dateien benötigt)
- Komplett in PureBasic entwickelt


Commandozeilenparameter:
------------------------
/?,/help,/h        - Zeigt EXE Optionen an
/fullscreen        - Player im Fullscreenmodus starten 
/volume            - Lautstärke setzen
/password          - Passwort 
/hidden /invisible - Player versteckt starten
/database          - Alternativer Pfad zur Datenbank (Ist sinnvoll, damit keine Probleme mit verschiedenen Versionen des Players auftreten)
Automatische Pfadersetzungen:
[APPDATA],[DESKTOP],[DOCUMENTS],[HOME],[TEMP],[PROGRAM]
z.B:
[APPDATA]\GFP\1234567.sqlite

/importlist - Abspielliste importieren
/aspect     - aspect ratio vordefinieren z.B: "16:9", "4:3", ...
/loglevel   - setzt das loglevel 0=None, 1=Error, 2=Debug
/videorenderer - setzt den video renderer (0=Default, 1=VMR9_Windowless, 2=VMR7_Windowless, 3=OldVideoRenderer, 4=OverlayMixer, 5=DSHOWDEFAULT, 6=VMR9_Windowed, 7=VMR7_Windowed, 8=OWN_RENDERER)
/audiorenderer - setzt den audio renderer (0=Default, 1=WAVEOUTRENDERER, 2=DIRECTSOUNDRENDERER)
/restoredatabase - Wiederherstellung der Ursprünglichen Datenbank
...



Acknowledgements
----------------

Warkering

Saner Apaydin

Carl Peeraer

Mauricio Cantún Caamal

Jacobus

http://Xiph.org Xiph.org Foundation

Independent JPEG Group
this software is based in part on the work of the Independent JPEG Group

OpenJPEG
for the JPEG2000 codec



Rechtliches:
------------
Dieses Programm wird bereitgestellt wie es ist.
Der Author ist nicht verantwortlich zu machen für irgendwelche Schäden, die der Software zugeschrieben werden können. Mit Außnahme von Schäden, die gesetzlich nicht ausgeschlossen werden können.
Sie wurden gewarnt, dass Sie diese Software auf Ihr eigenes Risiko benutzen.
Garantien werden vom author oder einem anderen Vertreter weder gegeben noch angedeutet.
Alle Bestandteile sind urheberrechtlich geschützt. 
Es ist nicht erlaubt Anwendungsdateien oder andere Datien dieser Software zu ändern.

Die Software darf in nicht-kommerziellen und komerziellen Produkten genutzt werden.
Wenn die Software in kommerziellen Produkten verwendet wird, wäre eine Erwähnung des Authors und eine spende wünschenswert, ist jedoch nicht erforderlich.


OpenJPEG
Copyright (c) 2002-2012, Communications and Remote Sensing Laboratory, Universite catholique de Louvain (UCL), Belgium Copyright (c) 2002-2012, Professor Benoit Macq Copyright (c) 2003-2012, Antonin Descampe Copyright (c) 2003-2009, Francois-Olivier Devaux Copyright (c) 2005, Herve Drolon, FreeImage Team Copyright (c) 2002-2003, Yannick Verschueren Copyright (c) 2001-2003, David Janssens All rights reserved. 
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS `AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

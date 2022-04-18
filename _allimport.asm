////////////////////////////////////////////////////////////////////////////////
//
// Project   : DaleksAttack - https://github.com/intoinside/DaleksAttack
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Import for any external resource
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.segment Music
Music:
  .var music = LoadSid("./assets/Doctor_Who_Theme.sid")

* = music.location "Music"
  .fill music.size, music.getData(i)

.segment MapData
* = $4400 "MainMap"
  .import binary "./assets/mainmap.bin"
* = $4c00 "MainMap"
  .import binary "./assets/intro.bin"
* = $4800 "Dialogs"
DialogEmpty:
  .import binary "./assets/dialogempty.bin"
DialogNextLevel:
  .import binary "./assets/nextlevel.bin"
DialogGameOver:
  .import binary "./assets/gameover.bin"
DialogDead:
  .import binary "./assets/dead.bin"
DialogTeleport:
  .import binary "./assets/teleport.bin"

.segment Intro
.const KOALA_TEMPLATE = "C64FILE, Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328, BackgroundColor = $2710"
.var picture = LoadBinary("intro.kla", KOALA_TEMPLATE)
* = $4000 "IntroMap";
IntroMap: .fill picture.getScreenRamSize(), picture.getScreenRam(i)
* = $6000 "IntroBitmap";
IntroBitmap:  .fill picture.getBitmapSize(), picture.getBitmap(i)
* = $8000 "IntroColorRam";
IntroColorRam:   .fill picture.getColorRamSize(), picture.getColorRam(i)

.segment Sprites
  .import binary "./assets/sprites.bin"

.segment Charsets
Charset:
  .import binary "./assets/charset.bin"

.segment CharsetsColors
CharColors:
  .import binary "./assets/charcolors.bin"

.print ""
// Print the music info while assembling
.print ""
.print "SID Data"
.print "--------"
.print "location=$"+toHexString(music.location)
.print "init=$"+toHexString(music.init)
.print "play=$"+toHexString(music.play)
.print "songs="+music.songs
.print "startSong="+music.startSong
.print "size=$"+toHexString(music.size)
.print "name="+music.name
.print "author="+music.author
.print "copyright="+music.copyright

.print ""
.print "Additional tech data"
.print "--------------------"
.print "header="+music.header
.print "header version="+music.version
.print "flags="+toBinaryString(music.flags)
.print "speed="+toBinaryString(music.speed)
.print "startpage="+music.startpage
.print "pagelength="+music.pagelength
.print ""

.print ""
.print "INTRO Data"
.print "--------"
.print "getBitmapSize=$"+toHexString(picture.getBitmapSize())
.print ""

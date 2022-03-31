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

.segment MapData
* = $4000 "IntroMap"
  .import binary "./assets/mainmap.bin"
* = $4400 "MainMap"
  .import binary "./assets/mainmap.bin"
* = $4800
DialogEmpty:
  .import binary "./assets/dialogempty.bin"
DialogNextLevel:
  .import binary "./assets/nextlevel.bin"
DialogGameOver:
  .import binary "./assets/gameover.bin"
DialogDead:
  .import binary "./assets/dead.bin"

.segment MapDummyArea
* = $5000 "MapDummyArea"
MapDummyArea:

.segment Sprites
  .import binary "./assets/sprites.bin"

.segment Charsets
Charset:
  .import binary "./assets/charset.bin"

.segment CharsetsColors
CharColors:
  .import binary "./assets/charcolors.bin"

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
/*
* = $4800 "Level2"
  .import binary "./maps/level2.bin"
* = $4c00 "Level3"
  .import binary "./maps/level3.bin"
*/
.segment MapDummyArea
* = $5000 "MapDummyArea"
MapDummyArea:

.segment Sprites
  .import binary "./assets/sprites.bin"

.segment Charsets
Charset:
  .import binary "./assets/charset.bin"

/*
.segment Dialogs
DialogNextLevel:
  .import binary "./maps/dialognextlevel.bin"
DialogGameOver:
  .import binary "./maps/dialoggameover.bin"
*/

.segment CharsetsColors
CharColors:
  .import binary "./assets/charcolors.bin"

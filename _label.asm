////////////////////////////////////////////////////////////////////////////////
//
// Project   : ForestSaver - https://github.com/intoinside/ForestSaver
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Label declaration
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.label ScreenMemoryBaseAddress = $4400

.label FirstSpritePointer = ScreenMemoryBaseAddress + $3f8

.label SPRITE_0     = FirstSpritePointer
.label SPRITE_1     = FirstSpritePointer + 1
.label SPRITE_2     = FirstSpritePointer + 2
.label SPRITE_3     = FirstSpritePointer + 3
.label SPRITE_4     = FirstSpritePointer + 4
.label SPRITE_5     = FirstSpritePointer + 5
.label SPRITE_6     = FirstSpritePointer + 6
.label SPRITE_7     = FirstSpritePointer + 7

CIA1: {
  .label PORT_A             = $dc00
  .label PORT_B             = $dc01
  .label PORT_A_DIRECTION   = $dc02
  .label PORT_B_DIRECTION   = $dc03
}

CIA2: {
  .label PORT_A             = $dd00
}

KEYB: {
  .label CURRENT_PRESSED    = $00cb
  .label BUFFER_LEN         = $0289
  .label REPEAT_SWITCH      = $028a
}

SPRITES: {
// Dalek
  .label DALEK_RIGHT        = $40
  .label DALEK_LEFT         = $41
  .label DALEK_UP           = $42
  .label DALEK_DOWN         = $43

// Player
  .label PLAYER_DOWN        = $44
  .label PLAYER_DOWN_1      = $45
  .label PLAYER_RIGHT       = $46
  .label PLAYER_RIGHT_1     = $47
  .label PLAYER_LEFT        = $48
  .label PLAYER_LEFT_1      = $49
  .label PLAYER_UP          = $4a
  .label PLAYER_UP_1        = $4b
  .label PLAYER_DEAD        = $4c

// Explosions
  .label DalekExplosion1    = $4d
  .label DalekExplosion2    = $4e
  .label DalekExplosion3    = $4f
  .label DalekExplosion4    = $50
  .label DalekExplosion5    = $51
  .label DalekDebris        = $52

// Bombs
  .label BombFrame1         = $53
  .label BombFrame2         = $54
}

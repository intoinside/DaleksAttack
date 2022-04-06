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
  .label DALEK_RIGHT        = $50
  .label DALEK_LEFT         = $51
  .label DALEK_UP           = $52
  .label DALEK_DOWN         = $53

// Player
  .label PLAYER_DOWN        = $54
  .label PLAYER_DOWN_1      = $55
  .label PLAYER_RIGHT       = $56
  .label PLAYER_RIGHT_1     = $57
  .label PLAYER_LEFT        = $58
  .label PLAYER_LEFT_1      = $59
  .label PLAYER_UP          = $5a
  .label PLAYER_UP_1        = $5b
  .label PLAYER_DEAD        = $5c

// Explosions
  .label DalekExplosion1    = $5d
  .label DalekExplosion2    = $5e
  .label DalekExplosion3    = $5f
  .label DalekExplosion4    = $60
  .label DalekExplosion5    = $61
  .label DalekDebris        = $62

// Bombs
  .label BombFrame1         = $63
  .label BombFrame2         = $64
}

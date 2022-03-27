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
  .label PLAYER             = $54

// Explosions
  .label DalekExplosion1    = $5c
  .label DalekExplosion2    = $5d
  .label DalekExplosion3    = $5e
  .label DalekExplosion4    = $5f
  .label DalekExplosion5    = $60
  .label DalekDebris        = $61

// Bombs
  .label BombFrame1         = $62
  .label BombFrame2         = $63
}

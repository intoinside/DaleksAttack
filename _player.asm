////////////////////////////////////////////////////////////////////////////////
//
// Project   : DaleksAttack - https://github.com/intoinside/DaleksAttack
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Player sprite handler
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.filenamespace Player

* = * "Player HandlePlayerMove"
HandlePlayerMove: {
// Direction is 0, no horizontal move
    lda Joystick.Direction
    beq CheckDirectionY

// There is horizontal move, check which direction
    cmp #$ff
    beq MoveToLeft

  MoveToRight:
    lda c64lib.SPRITE_0_X
    cmp #LIMIT_RIGHT
    beq CheckDirectionY
    inc c64lib.SPRITE_0_X
    jmp CheckDirectionY

  MoveToLeft:
    lda c64lib.SPRITE_0_X
    cmp #LIMIT_LEFT
    beq CheckDirectionY
    dec c64lib.SPRITE_0_X

// DirectionY is 0, no vertical move
  CheckDirectionY:
    lda Joystick.DirectionY
    beq Done

// There is vertical move, check which direction
    cmp #$ff
    beq MoveToUp

  MoveToDown:
    lda c64lib.SPRITE_0_Y
    cmp #LIMIT_DOWN
    beq Done
    inc c64lib.SPRITE_0_Y
    jmp Done

  MoveToUp:
    lda c64lib.SPRITE_0_Y
    cmp #LIMIT_UP
    beq Done
    dec c64lib.SPRITE_0_Y

  Done:
    rts
}

.label LIMIT_UP     = 46
.label LIMIT_DOWN   = 228
.label LIMIT_LEFT   = 22
.label LIMIT_RIGHT  = 228

#import "_joystick.asm"

#import "chipset/lib/vic2.asm"

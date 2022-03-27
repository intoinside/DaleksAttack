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

* = * "Player HandleBomb"
HandleBomb: {
    dec CurrentFrame
    bne Done

    lda #16
    sta CurrentFrame

// Switch bomb frame
    lda Level.SPRITE_7
    cmp #SPRITES.BombFrame1
    bne !+
    inc Level.SPRITE_7
    jmp Done
  !:
    dec Level.SPRITE_7

  Done:
    rts

  CurrentFrame: .byte 1
}

* = * "Player BombDropped"
BombDropped: {
    lda BombsLeft
    beq Done

    lda BombActive
    beq CheckIfBombIsReleased

// A bomb has been already dropped, handle its frame
    jsr HandleBomb
    jmp Done

  CheckIfBombIsReleased:
    IsBKeyPressed()
    beq Done

    dec BombsLeft
    inc BombActive

    lda c64lib.SPRITE_0_X
    sta c64lib.SPRITE_7_X
    lda c64lib.SPRITE_0_Y
    sta c64lib.SPRITE_7_Y

    lda c64lib.SPRITE_ENABLE
    ora #%10000000
    sta c64lib.SPRITE_ENABLE
    
  Done:
    rts
}

* = * "Player BombExploded"
BombExploded: {
    lda BombActive
    beq Done

    lda c64lib.SPRITE_ENABLE
    and #%01111111
    sta c64lib.SPRITE_ENABLE

    dec BombActive
  Done:
    rts
}

BombActive: .byte 0

// Count of bombs left
BombsLeft: .byte 2
.label BombsAvailableAtLevelStart = 2

#import "_level.asm"
#import "_utils.asm"
#import "_joystick.asm"

#import "chipset/lib/vic2.asm"

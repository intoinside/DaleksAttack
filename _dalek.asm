////////////////////////////////////////////////////////////////////////////////
//
// Project   : DaleksAttack - https://github.com/intoinside/DaleksAttack
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Dalek sprite handler
//
////////////////////////////////////////////////////////////////////////////////

#importonce

// Update requested Dalek movement, getting toward player
.macro HandleDalekMove(whichDalek) {
    lda #(whichDalek * 2)
    sta Dalek.HandleDalekMove.DalekToMove
    jsr Dalek.HandleDalekMove
}

.filenamespace Dalek

* = * "Dalek HandleDalekMove"
HandleDalekMove: {
    dec DalekSpeedDummy
    bne Done

    lda DalekSpeed
    sta DalekSpeedDummy

    ldx DalekToMove

    lda c64lib.SPRITE_0_X
    cmp c64lib.SPRITE_0_X, x
    beq CheckVertical

// Dalek-x and player-x are different, trying to getting closer
    bcc MoveLeft

  MoveRight:
    inc c64lib.SPRITE_0_X, x
    jmp CheckVertical

  MoveLeft:
    dec c64lib.SPRITE_0_X, x

  CheckVertical:
    lda c64lib.SPRITE_0_Y
    cmp c64lib.SPRITE_0_Y, x
    beq Done

// Dalek-y and player-y are different, trying to getting closer
    bcc MoveUp

  MoveDown:
    inc c64lib.SPRITE_0_Y, x
    jmp Done

  MoveUp:
    dec c64lib.SPRITE_0_Y, x

  Done:
    rts

// Index used for move requested Dalek (set by macro)
  DalekToMove:      .byte 0

// Iterator for Dalek speed
  DalekSpeedDummy:  .byte 8

// Dalek speed
  DalekSpeed:       .byte 8
}

#import "chipset/lib/vic2.asm"

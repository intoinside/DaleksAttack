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

.filenamespace Dalek

* = * "Player HandleDalekMove"
HandleDalekMove: {
    dec DalekSpeedDummy
    bne Done

    lda DalekSpeed
    sta DalekSpeedDummy
    
    lda c64lib.SPRITE_0_X
    cmp c64lib.SPRITE_1_X
    beq CheckVertical

// Dalek-x and player-x are different, trying to getting closer
    bmi MoveLeft

  MoveRight:
    inc c64lib.SPRITE_1_X
    jmp CheckVertical

  MoveLeft:
    dec c64lib.SPRITE_1_X

  CheckVertical:
    lda c64lib.SPRITE_0_Y
    cmp c64lib.SPRITE_1_Y
    beq Done

// Dalek-y and player-y are different, trying to getting closer
    bmi MoveUp

  MoveDown:
    inc c64lib.SPRITE_1_Y
    jmp Done

  MoveUp:
    dec c64lib.SPRITE_1_Y

  Done:
    rts

  DalekSpeedDummy:  .byte 8
  DalekSpeed:       .byte 8
}

#import "chipset/lib/vic2.asm"

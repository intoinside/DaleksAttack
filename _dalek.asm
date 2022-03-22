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
.macro HandleDalekMove(dalekBitMask, dalekIndex) {
    lda #dalekBitMask
    sta Dalek.HandleDalekMove.DalekToMoveBitMask
    lda #dalekIndex
    sta Dalek.HandleDalekMove.DalekIndex
    lda #(dalekIndex * 2)
    sta Dalek.HandleDalekMove.DalekCoordinatePointer
    jsr Dalek.HandleDalekMove
}

.filenamespace Dalek

* = * "Dalek HandleDalekMove"
HandleDalekMove: {
    ldx DalekIndex
    dex
    dec DalekSpeedDummy, x
    bne Done

    lda DalekSpeed
    sta DalekSpeedDummy, x
    inx

// Check if current dalek is dead (and exploded)
    lda DalekToMoveBitMask
    and DalekDead
// If is dead, exit
    bne Done

// Check if current dalek is exploding
    lda DalekToMoveBitMask
    and DalekExploding
// If it's not exploding, go to collision check
    beq CheckCollision
// If it's exploding, go to animation and then exit
    jsr AnimateExploding
    jmp Done

// Check collision between current dalek and player
  CheckCollision:
    lda c64lib.SPRITE_0_X
    sta SpriteCollision.SpriteX1
    lda c64lib.SPRITE_0_Y
    sta SpriteCollision.SpriteY1

    ldx DalekCoordinatePointer
    lda c64lib.SPRITE_0_X, x
    sta SpriteCollision.OtherX
    lda c64lib.SPRITE_0_Y, x
    sta SpriteCollision.OtherY

    jsr SpriteCollision

// No collision detected, check if there is collision between dalek
    beq CheckCollisionWithOtherDalek

// Collision dalek-player, game end and exit
    sta GameEnded
    jmp Done

// Check collision between current dalek and other daleks
  CheckCollisionWithOtherDalek:
    lda c64lib.SPRITE_2S_COLLISION
    and DalekToMoveBitMask
// No sprite collision detected, move dalek    
    beq AliveAndNotExploding

// Collision detected, set collided dalek as exploded and then exit
    jsr Explode
    jmp Done

  AliveAndNotExploding:
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

// Dalek bitmask alive status, each bit is a dalek (1 means exploded and dead)
  DalekDead:        .byte 0

// Dalek bitmask exploding status, each bit is a dalek (1 means exploding)
  DalekExploding:   .byte 0

// Currently moving sprint (bit set)
  DalekToMoveBitMask: .byte 0

// Index used for index to get sprite pointer
  DalekIndex:       .byte 0

// Index used for index to get sprite coordiates
  DalekCoordinatePointer:      .byte 0

// Iterator for Dalek speed
  DalekSpeedDummy:  .byte 8, 8, 8, 8, 8

// Dalek speed
  DalekSpeed:       .byte 6
}

// Manage current dalek explosion
* = * "Dalek AnimateExploding"
AnimateExploding: {
    ldx HandleDalekMove.DalekIndex

// Get current explosion frame
    lda Level.FirstSpritePointer, x
    cmp #SPRITES.DalekDebris
    bcs Done
    cmp #SPRITES.DalekExplosion5
    bcc !+

// Explosion frame done, set debris sprite
    lda HandleDalekMove.DalekToMoveBitMask
    ora HandleDalekMove.DalekDead
    sta HandleDalekMove.DalekDead

    lda #SPRITES.DalekDebris
    sta Level.FirstSpritePointer, x

    jmp Done
  !:
    inc Level.FirstSpritePointer, x

  Done:
    rts
}

// A register should contain latest SPRITE_2S_COLLISION value
* = * "Dalek Explode"
Explode: {
    and HandleDalekMove.DalekToMoveBitMask
    ora HandleDalekMove.DalekExploding
    sta HandleDalekMove.DalekExploding

    ldy HandleDalekMove.DalekIndex
    lda #SPRITES.DalekExplosion1
    sta Level.FirstSpritePointer, y

    rts
}

* = * "Dalek Init"
Init: {
    lda #0
    sta HandleDalekMove.DalekDead
    sta HandleDalekMove.DalekExploding   

    rts
}

* = * "Dalek DeterminePosition"
DeterminePosition: {
  Loop:
    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_1_X
    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_2_X
    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_3_X
    /*
    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_4_X
    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_5_X
    */
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_1_Y
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_2_Y
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_3_Y
    /*
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_4_Y
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_5_Y
    */

    lda c64lib.SPRITE_2S_COLLISION
    bne Loop

    rts
}

#import "_level.asm"
#import "_utils.asm"
#import "_label.asm"

#import "chipset/lib/vic2.asm"

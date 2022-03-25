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

// Initialize dalek for new level
.macro Init(dalekCount) {
    lda #dalekCount
    sta Dalek.DalekCount
    jsr Dalek.Init
}

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

.macro SaveDalekCollisionDetection() {
    lda c64lib.SPRITE_2S_COLLISION
    sta Dalek.SpriteCollisionBuffer
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
    and DeadBitmask
// If is dead, exit
    bne Done

// Check if current dalek is exploding
    lda DalekToMoveBitMask
    and ExplodingBitmask
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
    lda SpriteCollisionBuffer
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


// Currently moving sprint (bit set)
  DalekToMoveBitMask: .byte 0

// Index used for index to get sprite pointer
  DalekIndex:       .byte 0

// Index used for index to get sprite coordiates
  DalekCoordinatePointer:      .byte 0

// Iterator for Dalek speed
  DalekSpeedDummy:  .byte 8, 8, 8, 8, 8

// Dalek speed
  DalekSpeed:       .byte 8
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
    ora DeadBitmask
    sta DeadBitmask

    lda #SPRITES.DalekDebris
    sta Level.FirstSpritePointer, x

// Check if all dalek are exploded
    lda ExplodedCount
    cmp DalekCount
    bcc Done

// All dalek are exploded
    lda #$ff
    sta c64lib.SPRITE_PRIORITY

    // All dalek are dead, show next level dialog
    ShowDialogNextLevel(Level.ScreenMemoryBaseAddress)

    inc Level.LevelCompleted
    
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
    ora ExplodingBitmask
    sta ExplodingBitmask

    ldy HandleDalekMove.DalekIndex
    lda #SPRITES.DalekExplosion1
    sta Level.FirstSpritePointer, y

    inc ExplodedCount

    rts
}

* = * "Dalek Init"
Init: {
    lda #0

    sta c64lib.SPRITE_PRIORITY

    sta DeadBitmask
    sta ExplodingBitmask  
    sta ExplodedCount 

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

// How many dalek are created on this level
DalekCount: .byte 0

// How many dalek are exploded
ExplodedCount: .byte 0

// Dalek bitmask alive status, each bit is a dalek (1 means exploded and dead)
DeadBitmask:        .byte 0

// Dalek bitmask exploding status, each bit is a dalek (1 means exploding)
ExplodingBitmask:   .byte 0

// Sprite collision saver at the end of every loop
SpriteCollisionBuffer: .byte 0

#import "_level.asm"
#import "_utils.asm"
#import "_label.asm"

#import "chipset/lib/vic2.asm"

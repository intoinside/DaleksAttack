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
.macro DalekInit() {
    ldx Level.CurrentLevel
    inx
    inx
    cpx #7    
    bcc !+  // Too much dalek, reset to 6
    ldx #6
  !:
    stx Dalek.DalekCount

    jsr Dalek.Init
}

// Update requested Dalek movement, getting toward player
.macro HandleDalekMove(dalekBitMask, dalekIndex) {
    lda Player.PlayerDead
    bne !+

    ldx Level.CurrentLevel
    inx
    inx
    cpx #dalekIndex 
    bcc !+

    lda #dalekIndex
    sta Dalek.HandleDalekMove.DalekIndex
    asl
    sta Dalek.HandleDalekMove.DalekCoordinatePointer
    lda #dalekBitMask
    sta Dalek.HandleDalekMove.DalekToMoveBitMask
    jsr Dalek.HandleDalekMove
  !:
}

.macro SaveDalekCollisionDetection() {
    lda c64lib.SPRITE_2S_COLLISION
    sta Dalek.SpriteCollisionBuffer
}

.filenamespace Dalek

* = * "Dalek HandleDalekMove"
HandleDalekMove: {
    lda DalekIndex
    tax
    tay
    dex
    dec DalekSpeedDummy, x
    bne DoneFar

    jmp !+

  DoneFar:
    jmp Done

  !:
    lda DalekSpeed
    sta DalekSpeedDummy, x
    inx

// Check if current dalek is dead (and exploded)
    lda DalekToMoveBitMask
    and DeadBitmask
// If is dead, exit
    bne DoneFar

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

// Collision dalek-player, game end and exit
    bne EndGame

// Check collision between current dalek and other daleks
  CheckCollisionWithOtherDalek:
// Avoid collision with player
    lda SpriteCollisionBuffer
    and #%00000001
    bne AliveAndNotExploding

    lda SpriteCollisionBuffer
    and DalekToMoveBitMask
// No sprite collision detected, move dalek    
    beq AliveAndNotExploding

// Collision detected, set collided dalek as exploded and then exit
    jsr Explode
    jsr Sounds.Explosion
    AddPoints(0, 0, 1, 0)
    jmp Done

  AliveAndNotExploding:
    lda c64lib.SPRITE_0_X
    cmp c64lib.SPRITE_0_X, x
    beq CheckVertical

// Dalek-x and player-x are different, trying to getting closer
    bcc MoveLeft

  MoveRight:
    inc c64lib.SPRITE_0_X, x
    lda #SPRITES.DALEK_RIGHT
    sta SPRITE_0, y

    jmp CheckVertical

  MoveLeft:
    dec c64lib.SPRITE_0_X, x
    lda #SPRITES.DALEK_LEFT
    sta SPRITE_0, y

  CheckVertical:
    lda c64lib.SPRITE_0_Y
    cmp c64lib.SPRITE_0_Y, x
    beq Done

// Dalek-y and player-y are different, trying to getting closer
    bcc MoveUp

  MoveDown:
    inc c64lib.SPRITE_0_Y, x
    lda #SPRITES.DALEK_UP
    sta SPRITE_0, y
    jmp Done

  MoveUp:
    dec c64lib.SPRITE_0_Y, x
    lda #SPRITES.DALEK_DOWN
    sta SPRITE_0, y

  Done:
    rts

  EndGame:
    jsr GameEnds
    rts

// Currently moving sprint (bit set)
  DalekToMoveBitMask: .byte 0

// Index used for index to get sprite pointer
  DalekIndex:       .byte 0

// Index used for index to get sprite coordiates
  DalekCoordinatePointer:      .byte 0

// Iterator for Dalek speed
  DalekSpeedDummy:  .byte 8, 8, 8, 8, 8, 8

// Dalek speed
  DalekSpeed:       .byte 8
}

* = * "Dalek GameEnds"
GameEnds: {
    jsr Player.LifeLost

    rts
}

// Manage current dalek explosion
* = * "Dalek AnimateExploding"
AnimateExploding: {
    ldx HandleDalekMove.DalekIndex

// Get current explosion frame
    lda FirstSpritePointer, x
    cmp #SPRITES.DalekDebris
    bcs Done
    cmp #SPRITES.DalekExplosion5
    bcc !+

// Explosion frame done, set debris sprite
    lda HandleDalekMove.DalekToMoveBitMask
    ora DeadBitmask
    sta DeadBitmask

    lda #SPRITES.DalekDebris
    sta FirstSpritePointer, x

// Check if all dalek are exploded
    lda ExplodedCount
    cmp DalekCount
    bcc Done

    // All dalek are dead, show next level dialog
    ShowDialogNextLevel(ScreenMemoryBaseAddress)

    inc Level.LevelCompleted
    
    jmp Done
  !:
    inc FirstSpritePointer, x

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
    sta FirstSpritePointer, y

    inc ExplodedCount

    jsr Player.BombExploded

    rts
}

* = * "Dalek Init"
Init: {
    lda #0

    sta DeadBitmask
    sta ExplodingBitmask  
    sta ExplodedCount 

    rts
}

* = * "Dalek DeterminePosition"
DeterminePosition: {
    lda c64lib.SPRITE_2S_COLLISION

    ldx Level.CurrentLevel

  Loop:
// Calculate position for dalek 1,2,3 (they are always visible)
    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_1_X
    jsr GetRandom
    sta c64lib.SPRITE_2_X
    jsr GetRandom
    sta c64lib.SPRITE_3_X

    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_1_Y
    jsr GetRandom
    sta c64lib.SPRITE_2_Y
    jsr GetRandom
    sta c64lib.SPRITE_3_Y

// If level 2 or higher, draw dalek 4
    cpx #2
    bcc CheckPosition

    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_4_X
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_4_Y

// If level 3 or higher, draw dalek 5
    cpx #3
    bcc CheckPosition

    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_5_X
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_5_Y

// If level 4 or higher, draw dalek 6
    cpx #4
    bcc CheckPosition

    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_6_X
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_6_Y

* = * "Dalek DeterminePosition CheckPosition"
  CheckPosition:
// If a collision is detected, restart from beginning
    lda c64lib.SPRITE_2S_COLLISION
    beq Done
    
    jmp Loop

  Done:
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

//#import "_level.asm"
#import "_sounds.asm"
#import "_utils.asm"
#import "_label.asm"

#import "chipset/lib/vic2.asm"

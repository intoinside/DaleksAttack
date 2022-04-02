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

* = * "Player Init"
Init: {
    lda #LifesAvailableAtLevelStart
    sta LifesLeft
    jsr UpdateLifesLeftOnUi

    lda #BombsAvailableAtLevelStart
    sta BombsLeft
    jsr UpdateBombLeftOnUi

    lda #0
    sta BombActive
    sta PlayerDead

    rts
}

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
    jsr FrameToRight
    jmp CheckDirectionY

  MoveToLeft:
    lda c64lib.SPRITE_0_X
    cmp #LIMIT_LEFT
    beq CheckDirectionY
    dec c64lib.SPRITE_0_X
    jsr FrameToLeft

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
    jsr FrameToDown
    jmp Done

  MoveToUp:
    lda c64lib.SPRITE_0_Y
    cmp #LIMIT_UP
    beq Done
    dec c64lib.SPRITE_0_Y
    jsr FrameToUp

  Done:
    rts
}

* = * "Player FrameToRight"
FrameToRight: {
    jsr CanSwitchFrame
    bcs Done

    lda SPRITE_0
    cmp #SPRITES.PLAYER_RIGHT
    beq Switch
  
    lda #SPRITES.PLAYER_RIGHT
    sta SPRITE_0
    rts

  Switch:
    inc SPRITE_0

  Done:
    rts
}

* = * "Player FrameToLeft"
FrameToLeft: {
    jsr CanSwitchFrame
    bcs Done

    lda SPRITE_0
    cmp #SPRITES.PLAYER_LEFT
    beq Switch
  
    lda #SPRITES.PLAYER_LEFT
    sta SPRITE_0
    rts

  Switch:
    inc SPRITE_0

  Done:
    rts
}

* = * "Player FrameToLeft"
FrameToUp: {
    lda Joystick.Direction
    bne Done

    jsr CanSwitchFrame
    bcs Done

    lda SPRITE_0
    cmp #SPRITES.PLAYER_UP
    beq Switch
  
    lda #SPRITES.PLAYER_UP
    sta SPRITE_0
    rts

  Switch:
    inc SPRITE_0

  Done:
    rts
}

* = * "Player FrameToDown"
FrameToDown: {
    lda Joystick.Direction
    bne Done

    jsr CanSwitchFrame
    bcs Done

    lda SPRITE_0
    cmp #SPRITES.PLAYER_DOWN
    beq Switch
  
    lda #SPRITES.PLAYER_DOWN
    sta SPRITE_0
    rts

  Switch:
    inc SPRITE_0

  Done:
    rts
}

* = * "Player CanSwitchFrame"
CanSwitchFrame: {
    dec FrameDelay
    lda FrameDelay
    lsr
    lsr
    lsr
    bcs Done

    lda #0
    sta FrameDelay

  Done:
    rts
}

FrameDelay: .byte 0

* = * "Player HandleBomb"
HandleBomb: {
    dec CurrentFrame
    bne Done

    lda #16
    sta CurrentFrame

// Switch bomb frame
    lda SPRITE_7
    cmp #SPRITES.BombFrame1
    bne !+
    inc SPRITE_7
    jmp Done
  !:
    dec SPRITE_7

  Done:
    rts

  CurrentFrame: .byte 1
}

* = * "Player BombDropped"
BombDropped: {
    lda BombActive
    beq CheckIfBombIsReleased

// A bomb has been already dropped, handle its frame
    jsr HandleBomb
    jmp Done

  CheckIfBombIsReleased:
    lda BombsLeft
    beq Done

    IsBKeyPressed()
    beq Done

    dec BombsLeft
    jsr UpdateBombLeftOnUi
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

* = * "Player LifeLost"
LifeLost: {
    inc PlayerDead

    dec LifesLeft
    beq IsDead

    ShowDialogDead(ScreenMemoryBaseAddress)
    jmp !+

  IsDead:
    inc GameEnded
    ShowDialogGameOver(ScreenMemoryBaseAddress)

  !:
    IsReturnPressed()
    beq !-

    jsr UpdateLifesLeftOnUi

    rts
}

* = * "Player StartNewLife"
StartNewLife: {
    dec PlayerDead

    rts
}

* = * "Player UpdateLifesLeftOnUi"
UpdateLifesLeftOnUi: {
    lda LifesLeft
    clc
    adc #48
    sta LifesLeftOnUi
 
    rts

  .label LifesLeftOnUi = ScreenMemoryBaseAddress + c64lib_getTextOffset(30, 18)
}

* = * "Player UpdateBombLeftOnUi"
UpdateBombLeftOnUi: {
    lda BombsLeft
    clc
    adc #48
    sta BombsLeftOnUi
 
    rts

  .label BombsLeftOnUi = ScreenMemoryBaseAddress + c64lib_getTextOffset(30, 21)
}

BombActive: .byte 0

// Count of bombs left
BombsLeft: .byte 2
.label BombsAvailableAtLevelStart = 2

LifesLeft: .byte 3
.label LifesAvailableAtLevelStart = 3

PlayerDead: .byte 0

#import "_level.asm"
#import "_utils.asm"
#import "_joystick.asm"

#import "chipset/lib/vic2.asm"

////////////////////////////////////////////////////////////////////////////////
//
// Project   : DaleksAttack - https://github.com/intoinside/DaleksAttack
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Manager for level
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.filenamespace Level

// Manager of level
* = * "Level Manager"
Manager: {
    jsr Init

  JoystickMovement:
    jsr WaitRoutine
    jsr TimedRoutine
    jsr Joystick.GetJoystickMove

    jsr Player.HandlePlayerMove

    lda GameEnded
    beq JoystickMovement

    rts
}

* = * "Level Init"
Init: {
    // CopyScreenRam(ScreenMemoryBaseAddress, MapDummyArea)

    // jsr SetSpriteToForeground
// Set background and border color to brown
    lda #GRAY
    sta c64lib.BORDER_COL
    sta c64lib.BG_COL_0

    lda #ORANGE
    sta c64lib.BG_COL_1
    lda #BLACK
    sta c64lib.BG_COL_2

// Setting sprite multi-color
    lda #LIGHT_RED
    sta c64lib.SPRITE_COL_0

    lda #BLACK
    sta c64lib.SPRITE_COL_1

// Set pointer to char memory to $7800-$7fff (xxxx111x)
// and pointer to screen memory to $4400-$47ff (0001xxxx)
    lda #%00011110
    sta c64lib.MEMORY_CONTROL   

// Player sprite setting
    lda #$0a
    sta c64lib.SPRITE_0_COLOR
    lda #SPRITES.PLAYER
    sta SPRITE_0

// Dalek sprite setting
    lda #YELLOW
    sta c64lib.SPRITE_1_COLOR

    lda #SPRITES.DALEK_RIGHT
    sta SPRITE_1

// TODO: Start position should be random
    lda #$60
    sta c64lib.SPRITE_0_X
    lda #$60
    sta c64lib.SPRITE_0_Y
    lda #$40
    sta c64lib.SPRITE_1_X
    lda #$40
    sta c64lib.SPRITE_1_Y

    EnableSprite(0, true)
    EnableSprite(1, true)

    jmp AddColorToMap   // jsr + rts
}

AddColorToMap: {
    lda #>ScreenMemoryBaseAddress
    sta SetColorToChars.ScreenMemoryAddress

    jmp SetColorToChars
}

* = * "Level TimedRoutine"
TimedRoutine: {
    jsr TimedRoutine10th

    lda DelayCounter
    beq DelayTriggered        // when counter is zero stop decrementing
    dec DelayCounter          // decrement the counter

    jmp Exit

  DelayTriggered:
    lda DelayRequested        // delay reached 0, reset it
    sta DelayCounter

  Waiting:
    // jsr AddEnemy

    jmp Exit

  Exit:
    rts

  DelayCounter: .byte 50      // Counter storage
  DelayRequested: .byte 50    // 1 second delay
}

TimedRoutine10th: {
    lda DelayCounter
    beq DelayTriggered        // when counter is zero stop decrementing
    dec DelayCounter          // decrement the counter

    jmp Exit

  DelayTriggered:
    lda DelayRequested        // delay reached 0, reset it
    sta DelayCounter

  Exit:
    rts

  DelayCounter: .byte 8       // Counter storage
  DelayRequested: .byte 8     // 8/50 second delay
}

.label ScreenMemoryBaseAddress = $4400

.label SPRITE_0     = ScreenMemoryBaseAddress + $3f8
.label SPRITE_1     = ScreenMemoryBaseAddress + $3f9

#import "_utils.asm"
#import "_joystick.asm"
#import "_player.asm"

#import "chipset/lib/vic2.asm"

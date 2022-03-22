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
    HandleDalekMove(%00000010, 1)
    HandleDalekMove(%00000100, 2)
    HandleDalekMove(%00001000, 3)

    lda GameEnded
    beq JoystickMovement

  !:
    jmp !-
    rts
}

* = * "Level Init"
Init: {
    // CopyScreenRam(ScreenMemoryBaseAddress, MapDummyArea)

    // jsr SetSpriteToForeground
// Set background and border color to brown
    lda #GRAY
    sta c64lib.BG_COL_0
    lda #LIGHT_GRAY
    sta c64lib.BORDER_COL

    lda #BLACK
    sta c64lib.BG_COL_1
    lda #WHITE
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
    sta c64lib.SPRITE_2_COLOR
    sta c64lib.SPRITE_3_COLOR
    sta c64lib.SPRITE_4_COLOR
    sta c64lib.SPRITE_5_COLOR

    lda #SPRITES.DALEK_RIGHT
    sta SPRITE_1
    sta SPRITE_2
    sta SPRITE_3
    sta SPRITE_4
    sta SPRITE_5

    jsr Dalek.Init

// Player position
    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_0_X
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_0_Y

// Dalek position
    jsr Dalek.DeterminePosition

    lda #%00001111
    sta c64lib.SPRITE_ENABLE
    sta c64lib.SPRITE_COL_MODE

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

CurrentLevel: .byte 1

.label ScreenMemoryBaseAddress = $4400

.label FirstSpritePointer = ScreenMemoryBaseAddress + $3f8

.label SPRITE_0     = FirstSpritePointer
.label SPRITE_1     = FirstSpritePointer + 1
.label SPRITE_2     = FirstSpritePointer + 2
.label SPRITE_3     = FirstSpritePointer + 3
.label SPRITE_4     = FirstSpritePointer + 4
.label SPRITE_5     = FirstSpritePointer + 5

#import "_utils.asm"
#import "_joystick.asm"
#import "_player.asm"
#import "_dalek.asm"

#import "chipset/lib/vic2.asm"

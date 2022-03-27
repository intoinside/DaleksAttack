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

  StartLevel:
    jsr LevelInit

  JoystickMovement:
    jsr WaitRoutine
    jsr TimedRoutine
    jsr Joystick.GetJoystickMove

    jsr Player.HandlePlayerMove
    HandleDalekMove(%00000010, 1)
    HandleDalekMove(%00000100, 2)
    HandleDalekMove(%00001000, 3)
    HandleDalekMove(%00010000, 4)
    HandleDalekMove(%00100000, 5)
    HandleDalekMove(%01000000, 6)

    SaveDalekCollisionDetection()

// Check if level completed
    lda LevelCompleted
    beq CheckEndGame

    lda #$ff
    sta c64lib.SPRITE_PRIORITY

// Level completed, dialog shown, wait for Return keypress
  HandleLevelCompleted:
    IsReturnPressed()
    beq HandleLevelCompleted

    jsr SetupNextLevel

// Check if game ended
  CheckEndGame:
    lda GameEnded
    bne !+
    
    jmp JoystickMovement

// Game ended, handle it better!
  !:
    jmp !-

    rts
}

* = * "Level Init"
Init: {
    CopyScreenRam(ScreenMemoryBaseAddress, MapDummyArea)

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
    sta c64lib.SPRITE_6_COLOR

    lda #SPRITES.DALEK_RIGHT
    sta SPRITE_1
    sta SPRITE_2
    sta SPRITE_3
    sta SPRITE_4
    sta SPRITE_5
    sta SPRITE_6

// Reset all-dalek coordinates
    lda #0
    sta c64lib.SPRITE_1_X
    sta c64lib.SPRITE_2_X
    sta c64lib.SPRITE_3_X
    sta c64lib.SPRITE_4_X
    sta c64lib.SPRITE_5_X
    sta c64lib.SPRITE_6_X
    sta c64lib.SPRITE_1_Y
    sta c64lib.SPRITE_2_Y
    sta c64lib.SPRITE_3_Y
    sta c64lib.SPRITE_4_Y
    sta c64lib.SPRITE_5_Y
    sta c64lib.SPRITE_6_Y

    lda #0
    sta c64lib.SPRITE_PRIORITY

    jmp AddColorToMap   // jsr + rts
}

* = * "Level LevelInit"
LevelInit: {
    jsr GetSpriteMaskForLevel
    sta c64lib.SPRITE_ENABLE
    sta c64lib.SPRITE_COL_MODE

    lda #DalekSpeedUpToLevel4
    sta Dalek.HandleDalekMove.DalekSpeed

    lda CurrentLevel
    cmp #5
    bcc !+

    lda #DalekSpeedUpToLevel4
    clc
    adc #4
    sbc CurrentLevel
    sta Dalek.HandleDalekMove.DalekSpeed
  !:
    DalekInit()

// Player position
    GetRandomNumberInRange(LIMIT_LEFT, LIMIT_RIGHT)
    sta c64lib.SPRITE_0_X
    GetRandomNumberInRange(LIMIT_UP, LIMIT_DOWN)
    sta c64lib.SPRITE_0_Y

// Dalek position
    jsr Dalek.DeterminePosition

    rts
}

GetSpriteMaskForLevel: {
    ldx CurrentLevel
    dex
    cpx #4
    bcc !+
    ldx #3
  !:
    lda SpriteForLevelMask, x

    rts

  SpriteForLevelMask: .byte %00001111, %00011111, %00111111, %01111111
}

* = * "Level SetupNextLevel"
SetupNextLevel: {
    CopyScreenRam(MapDummyArea, ScreenMemoryBaseAddress)

    lda CurrentLevel
    cmp #MaxLevel
    bcs !+

    inc CurrentLevel
  !:
    rts
}

* = * "Level AddColorToMap"
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

.label MaxLevel = 12

// Hold current level
CurrentLevel: .byte 1

// Detect if level has been completed
LevelCompleted: .byte 0

.label ScreenMemoryBaseAddress = $4400

.label FirstSpritePointer = ScreenMemoryBaseAddress + $3f8

.label SPRITE_0     = FirstSpritePointer
.label SPRITE_1     = FirstSpritePointer + 1
.label SPRITE_2     = FirstSpritePointer + 2
.label SPRITE_3     = FirstSpritePointer + 3
.label SPRITE_4     = FirstSpritePointer + 4
.label SPRITE_5     = FirstSpritePointer + 5
.label SPRITE_6     = FirstSpritePointer + 6

.label DalekSpeedUpToLevel4 = 10

#import "_utils.asm"
#import "_joystick.asm"
#import "_keyboard.asm"
#import "_player.asm"
#import "_dalek.asm"

#import "chipset/lib/vic2.asm"

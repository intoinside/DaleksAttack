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
    jsr Player.BombDropped

    jsr Player.Teleport

    HandleDalekMove(%00000010, 1)
    HandleDalekMove(%00000100, 2)
    HandleDalekMove(%00001000, 3)
    HandleDalekMove(%00010000, 4)
    HandleDalekMove(%00100000, 5)
    HandleDalekMove(%01000000, 6)

    SaveDalekCollisionDetection()

// Check if level completed
    lda LevelCompleted
    beq CheckGameEnded

// Level completed, dialog shown, wait for Return keypress
  HandleLevelCompleted:
    IsReturnPressed()
    beq HandleLevelCompleted

    jsr SetupNextLevel
    jmp StartLevel

  CheckGameEnded:
    lda GameEnded
    beq CheckPlayerDead

    jsr StartNewGame
    jmp StartLevel

  CheckPlayerDead:
    lda Player.PlayerDead
    beq GameInProgress
    
    jsr StartNewLife
    jmp StartLevel

  GameInProgress:
    jmp JoystickMovement

// Game ended, handle it better!
  !:
    jmp !-

    rts
}

* = * "Level Init"
Init: {
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
    lda #SPRITES.PLAYER_DOWN
    sta SPRITE_0

// Dalek sprite setting
    lda #YELLOW
    sta c64lib.SPRITE_7_COLOR

// Bomb sprite
    lda #SPRITES.BombFrame1
    sta SPRITE_7

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

    jsr Player.Init
    jsr UpdateLevelOnUi

    jmp AddColorToMap   // jsr + rts
}

SetSpeed: {
// Up to level 4, speed is always #DalekSpeedUpToLevel4
    lda CurrentLevel
    cmp #5
    bcc MinSpeed

// Over level 10, speed is always #DalekMaxSpeed
    cmp #10
    bcs MaxSpeed

// In any other case, is related to current level
    lda #(DalekSpeedUpToLevel4 + 4)
    sec
    sbc CurrentLevel
    jmp Save

  MinSpeed:
    lda #DalekSpeedUpToLevel4
    jmp Save

  MaxSpeed:
    lda #DalekMaxSpeed

  Save:
    sta Dalek.HandleDalekMove.DalekSpeed

    rts
}

* = * "Level LevelInit"
LevelInit: {
    jsr GetSpriteMaskForLevel
    sta c64lib.SPRITE_ENABLE

    jsr SetSpeed
    
  !:
    lda #Player.BombsAvailableAtLevelStart
    sta Player.BombsLeft
    jsr Player.UpdateBombLeftOnUi

    lda #Player.TeleportAvailableAtLevelStart
    sta Player.TeleportLeft
    jsr Player.UpdateTeleportLeftOnUi

    DalekInit()

    lda #SPRITES.DALEK_RIGHT
    sta SPRITE_1
    sta SPRITE_2
    sta SPRITE_3
    sta SPRITE_4
    sta SPRITE_5
    sta SPRITE_6

    lda #LIGHT_RED
    sta c64lib.SPRITE_0_COLOR

    lda #YELLOW
    sta c64lib.SPRITE_1_COLOR
    sta c64lib.SPRITE_2_COLOR
    sta c64lib.SPRITE_3_COLOR
    sta c64lib.SPRITE_4_COLOR
    sta c64lib.SPRITE_5_COLOR
    sta c64lib.SPRITE_6_COLOR

    lda #0
    sta LevelCompleted

// Player position (always in the middle)
    lda #127
    sta c64lib.SPRITE_0_X
    sta c64lib.SPRITE_0_Y

// Dalek position
    jsr Dalek.DeterminePosition

    rts

  .label PlayerXMin = 22;
  .label PlayerXMax = 70;
  .label PlayerYMin = 48;
  .label PlayerYMax = 90;
}

* = * "Level GetSpriteMaskForLevel"
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

* = * "Level StartNewGame"
StartNewGame: {
    HideDialog(ScreenMemoryBaseAddress)

    jsr CompareAndUpdateHiScore
    jsr ResetScore

    lda #0
    sta GameEnded
    sta LevelCompleted

    lda #1
    sta CurrentLevel
    jsr UpdateLevelOnUi

    jsr Player.Init

    rts
}

* = * "Level SetupNextLevel"
SetupNextLevel: {
    HideDialog(ScreenMemoryBaseAddress)

    lda CurrentLevel
    cmp #MaxLevel
    bcs !+

    inc CurrentLevel
    jsr UpdateLevelOnUi
  !:
    rts
}

* = * "Level StartNewLife"
StartNewLife: {
    HideDialog(ScreenMemoryBaseAddress)

    jsr Player.StartNewLife

    rts
}

* = * "Level UpdateLifesLeftOnUi"
UpdateLevelOnUi: {
    lda CurrentLevel
    clc
    adc #48
    sta CurrentLevelOnUi
 
    rts

  .label CurrentLevelOnUi = ScreenMemoryBaseAddress + c64lib_getTextOffset(31, 7)
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

// Dalek speed up to level 4
.label DalekSpeedUpToLevel4 = 8

// Maximum dalek speed reaching higher level
.label DalekMaxSpeed = 3

#import "_utils.asm"
#import "_joystick.asm"
#import "_keyboard.asm"
#import "_player.asm"
#import "_dalek.asm"

#import "chipset/lib/vic2.asm"

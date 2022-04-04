////////////////////////////////////////////////////////////////////////////////
//
// Project   : DaleksAttack - https://github.com/intoinside/DaleksAttack
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Some useful routine.
//
////////////////////////////////////////////////////////////////////////////////

#importonce

SpriteNumberMask:
    .byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000

.label LIMIT_UP     = 48
.label LIMIT_DOWN   = 228
.label LIMIT_LEFT   = 22
.label LIMIT_RIGHT  = 228

* = * "Utils SpriteCollision"
// Detect if there is a collision between two sprites.
// First sprite coordinates are preloaded in SpriteX1 and SpriteY1.
// Second sprite coordinates are preloaded in OtherX and OtherY.
// Accumulator contains 1 if collision has been detected, 0 otherwise.
SpriteCollision: {
    lda OtherX
    clc
    adc #12
    sta OtherX

    lda OtherY
    clc
    adc #10
    sta OtherY

// Determine first sprite rectangle
    lda SpriteX1
    clc
    adc #24
    sta SpriteX2

    lda SpriteY1
    clc
    adc #21
    sta SpriteY2

    // Collision happened if OtherSprite coordinates is inside Player
    // square. This means that
    // * SpriteX1 < OtherX < SpriteX2
    // * SpriteY1 < OtherY < SpriteY2

    // REMIND: BCC means jump if first value is lower than second value

    // Is like if OtherX < SpriteX1 then jump (no collision)
    // bmi16(OtherX, SpriteX1)             // OtherSpriteX - Player Left
    lda OtherX
    cmp SpriteX1
    bcc NoCollisionDetected

    // Is like if SpriteX2 < OtherX then jump (no collision)
    // bmi16(SpriteX2, OtherX)             // Player Right - OtherSpriteX
    lda SpriteX2
    cmp OtherX
    bcc NoCollisionDetected

    // Is like if OtherY < SpriteY1 then jump (no collision)
    lda OtherY
    cmp SpriteY1
    bcc NoCollisionDetected     // branch to end if value is smaller than low

    // Is like if SpriteY2 < OtherY then jump (no collision)
    lda SpriteY2
    cmp OtherY
    bcc NoCollisionDetected     // branch to end if value is smaller than low

  CollisionDetected:
    lda #$01
    jmp Done

  NoCollisionDetected:
    lda #$00

  Done:
    rts

// Sprite square
  SpriteX1: .byte $00
  SpriteX2: .byte $00
  SpriteY1: .byte $00
  SpriteY2: .byte $00

// Other sprite initial coordinate
  OtherX: .byte $00
  OtherY: .byte $00
}


// Add points to current score
.macro AddPoints(digit4, digit3, digit2, digit1) {
    lda #digit1
    sta AddScore.Points + 3
    lda #digit2
    sta AddScore.Points + 2
    lda #digit3
    sta AddScore.Points + 1
    lda #digit4
    sta AddScore.Points

    jsr AddScore
}

* = * "Utils AddScore"
AddScore: {
    ldx #4
    clc
  !:
    lda CurrentScore - 1, x
    adc Points - 1, x
    cmp #10
    bcc SaveDigit
    sbc #10
    sec

  SaveDigit:
    sta CurrentScore - 1, x
    dex
    bne !-

  Done:
    jmp DrawScore   // jsr + rts

  Points: .byte $00, $00, $00, $00
}

* = * "Utils ResetScore"
ResetScore: {
    ldx #3
    lda #0
  !:
    sta CurrentScore, x
    dex
    bne !-

    jmp DrawScore   // jsr + rts
}

* = * "Utils DrawScore"
DrawScore: {
  // Append current score on score label
    ldx #0
    clc
  !:
    lda CurrentScore, x
    adc #ZeroChar
    sta ScoreLabel, x
    inx
    cpx #$04
    bne !-

  // Draws score label
    ldx #0
  LoopScore:
    lda ScoreLabel, x
  SelfMod:
    sta ScorePtr
    inc SelfMod + 1

    inx
    cpx #$0b
    bne LoopScore

    lda SelfMod + 1
    sbc #$0b
    sta SelfMod + 1

    rts

  .label ScorePtr = $beef
}

CompareAndUpdateHiScore: {
    lda HiScoreLabel
    cmp ScoreLabel
    bcc UpdateHiScore1
    lda HiScoreLabel + 1
    cmp ScoreLabel + 1
    bcc UpdateHiScore2
    lda HiScoreLabel + 2
    cmp ScoreLabel + 2
    bcc UpdateHiScore3
    lda HiScoreLabel + 3
    cmp ScoreLabel + 3
    bcc UpdateHiScore4
    jmp !+

  UpdateHiScore1:
    lda ScoreLabel
    sta HiScoreLabel
  UpdateHiScore2:
    lda ScoreLabel + 1
    sta HiScoreLabel + 1
  UpdateHiScore3:
    lda ScoreLabel + 2
    sta HiScoreLabel + 2
  UpdateHiScore4:
    lda ScoreLabel + 3
    sta HiScoreLabel + 3

  !:
    rts
}

.label ZeroChar = 48;
.label ScoreLabel = ScreenMemoryBaseAddress + c64lib_getTextOffset(30, 11);
.label HiScoreLabel = ScreenMemoryBaseAddress + c64lib_getTextOffset(30, 14);

CurrentScore: .byte 0, 0, 0, 0

// Create a screen memory backup from StartAddress to EndAddress
.macro CopyScreenRam(StartAddress, EndAddress) {
    ldx #250
  !:
    dex
    lda StartAddress, x
    sta EndAddress, x
    lda StartAddress + 250, x
    sta EndAddress + 250, x
    lda StartAddress + 500, x
    sta EndAddress + 500, x
    lda StartAddress + 750, x
    sta EndAddress + 750, x
    cpx #$0
    bne !-
}

.macro ShowDialogNextLevel(ScreenMemoryBaseAddress) {
    lda #<ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress
    lda #>ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress + 1
    lda #<DialogNextLevel
    sta ShowDialog.DialogAddress
    lda #>DialogNextLevel
    sta ShowDialog.DialogAddress + 1
    jsr ShowDialog
}

.macro ShowDialogGameOver(ScreenMemoryBaseAddress) {
    lda #<ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress
    lda #>ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress + 1
    lda #<DialogGameOver
    sta ShowDialog.DialogAddress
    lda #>DialogGameOver
    sta ShowDialog.DialogAddress + 1
    jsr ShowDialog
}

.macro ShowDialogDead(ScreenMemoryBaseAddress) {
    lda #<ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress
    lda #>ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress + 1
    lda #<DialogDead
    sta ShowDialog.DialogAddress
    lda #>DialogDead
    sta ShowDialog.DialogAddress + 1
    jsr ShowDialog
}

.macro HideDialog(ScreenMemoryBaseAddress) {
    lda #<ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress
    lda #>ScreenMemoryBaseAddress
    sta ShowDialog.StartAddress + 1
    lda #<DialogEmpty
    sta ShowDialog.DialogAddress
    lda #>DialogEmpty
    sta ShowDialog.DialogAddress + 1
    jsr ShowDialog
    lda #0
    sta c64lib.SPRITE_PRIORITY
}

* = * "Utils ShowDialog"
ShowDialog: {
    lda #$ff
    sta c64lib.SPRITE_PRIORITY

    lda StartAddress + 1
    sta StartAddressHi

    c64lib_add16(c64lib_getTextOffset(DialogStartX, DialogStartY), StartAddress)

    ldy #DialogHeight
  !Row:
    dey

    lda DialogAddress
    sta DialogAddressPtr + 1
    lda DialogAddress + 1
    sta DialogAddressPtr + 2

    lda StartAddress
    sta StartAddressPtr + 1
    lda StartAddress + 1
    sta StartAddressPtr + 2

    ldx #DialogWidth

  !:
    dex
  DialogAddressPtr:
    lda DialogAddress, x
  StartAddressPtr:
    sta StartAddress, x
    cpx #0
    bne !-

    c64lib_add16(40, StartAddress)
    c64lib_add16(DialogWidth, DialogAddress)

    cpy #0
    bne !Row-

    lda StartAddressHi
    sta SetColorToChars.ScreenMemoryAddress
    jsr SetColorToChars

    inc IsShown
    rts

  .label DialogStartX = 10;
  .label DialogStartY = 5;

  .label DialogWidth = 10;
  .label DialogHeight = 12;

  IsShown: .byte $00

  StartAddress: .word $beef
  DialogAddress: .word $beef
  StartAddressHi: .byte $be
}

.macro GetRandomNumberInRange(minNumber, maxNumber) {
    lda #minNumber
    sta GetRandom.GeneratorMin
    lda #maxNumber
    sta GetRandom.GeneratorMax
    jsr GetRandom
}

* = * "Utils GetRandom"
GetRandom: {
  Loop:
    lda $d012
    eor $dc04
    sbc $dc05
    cmp GeneratorMax
    bcs Loop
    cmp GeneratorMin
    bcc Loop
    rts

    GeneratorMin: .byte $00
    GeneratorMax: .byte $00
}

WaitRoutine: {
  VBLANKWAITLOW:
    lda $d011
    bpl VBLANKWAITLOW
  VBLANKWAITHIGH:
    lda $d011
    bmi VBLANKWAITHIGH
    rts
}

.macro EnableSprite(bSprite, bEnable) {
    ldy #bSprite
    lda SpriteNumberMask, y
    .if (bEnable)   // Build-time condition (not run-time)
    {
      ora c64lib.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    else
    {
      eor #$ff    // Get mask compliment
      and c64lib.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    sta c64lib.SPRITE_ENABLE       // Set the new value into the sprite enable register
}
.assert "EnableSprite($00, true) ", { EnableSprite($be, true) }, {
  ldy #$be; lda SpriteNumberMask, y; ora $d015; sta $d015
}
.assert "EnableSprite($00, false) ", { EnableSprite($be, false) }, {
  ldy #$be; lda SpriteNumberMask, y; eor #$ff; and $d015; sta $d015
}

.macro EnableMultiSprite(SpriteMask, bEnable) {
    lda #SpriteMask
    .if (bEnable)   // Build-time condition (not run-time)
    {
      ora c64lib.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    else
    {
      eor #$ff    // Get mask compliment
      and c64lib.SPRITE_ENABLE   // Merge with the current sprite enable register
    }
    sta c64lib.SPRITE_ENABLE       // Set the new value into the sprite enable register
}
.assert "EnableMultiSprite($be, true) ", { EnableMultiSprite($be, true) }, {
  lda #$be; ora $d015; sta $d015
}
.assert "EnableMultiSprite($00, false) ", { EnableMultiSprite($be, false) }, {
  lda #$be; eor #$ff; and $d015; sta $d015
}

* = * "Utils SetColorToChars"
SetColorToChars: {
    lda ScreenMemoryAddress
    sta Dummy1 + 2
    lda #$d8
    sta ColorMap + 2
    lda #$00
    sta StartLoop + 1

    lda #$04
    sta CleanLoop
  StartLoop:
    ldx #$00
  PaintCols:
  Dummy1:
    ldy DummyScreenRam, x
    lda CharColors, y
  ColorMap:
    sta $d800, x
    dex
    bne PaintCols

    inc Dummy1 + 2
    inc ColorMap + 2
    dec CleanLoop
    lda CleanLoop
    cmp #$01
    beq SetLastRun
    cmp #$00
    beq Done
    jmp StartLoop

  SetLastRun:
    lda #$e7
    sta StartLoop + 1
    jmp StartLoop

  Done:
    rts

  ScreenMemoryAddress: .byte $be

  .label DummyScreenRam = $be00

  CleanLoop: .byte $03
}

#import "_allimport.asm"
#import "_label.asm"

#import "chipset/lib/vic2.asm"
#import "chipset/lib/vic2-global.asm"
#import "common/lib/math-global.asm"

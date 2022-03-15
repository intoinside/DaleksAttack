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

.label LIMIT_UP     = 46
.label LIMIT_DOWN   = 228
.label LIMIT_LEFT   = 22
.label LIMIT_RIGHT  = 228

.macro GetRandomNumberInRange(minNumber, maxNumber) {
    lda #minNumber
    sta GetRandom.GeneratorMin
    lda #maxNumber
    sta GetRandom.GeneratorMax
    jsr GetRandom
}

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

#import "chipset/lib/vic2.asm"

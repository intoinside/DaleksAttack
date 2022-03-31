////////////////////////////////////////////////////////////////////////////////
//
// Project   : DaleksAttack - https://github.com/intoinside/DaleksAttack
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Main source code. Game initialization and main loop container.
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.segmentdef Code [start=$0810]
.segmentdef MapData [start=$4000]
.segmentdef MapDummyArea [start=$5000]
.segmentdef Sprites [start=$5400]
.segmentdef Charsets [start=$7800]
.segmentdef CharsetsColors [start=$c000]

#import "_allimport.asm"

.file [name="./main.prg", segments="Code, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$0810]
.file [name="./DaleksAttack.prg", segments="Code, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$0810]
.disk [filename="./DaleksAttack.d64", name="DALEKSATTACK", id="C2022", showInfo]
{
  [name="----------------", type="rel"],
  [name="--- RAFFAELE ---", type="rel"],
  [name="--- INTORCIA ---", type="rel"],
  [name="----------------", type="rel"],
  [name="DALEKSATTACK", type="prg", segments="Code, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$0810],
  [name="----------------", type="rel"]
}

.segment Code

* = * "Entry"
Entry: {
    MainGameSettings()
    jmp GamePlay
}

* = * "Main GamePlay"
GamePlay: {
// Show intro screen until player start a new game
//    jsr Intro.Manager

  !:  
    IsReturnPressed()
    beq !-
    
// Init a new game
    jsr Level.Manager
    lda GameEnded
    bne GamePlay

  !:
    jmp !-
}

// Initial environment setup
.macro MainGameSettings() {
// Switch out Basic so there is available ram on $a000-$bfff
    lda $01
    ora #%00000010
    and #%11111110
    sta $01

// Set Vic bank 1 ($4000-$7fff)
    lda #%00000010
    sta CIA2.PORT_A

// Set Multicolor mode on
    lda #%00011000
    sta c64lib.CONTROL_2

    lda #$ff
    sta c64lib.SPRITE_COL_MODE

    jsr Keyboard.Init
}

GameEnded:          // $00 - Game in progress
  .byte $00         // $ff - Player dead, game ended

#import "_label.asm"
#import "_level.asm"

/*
#import "_intro.asm"
#import "_level2.asm"
#import "_level3.asm"
#import "_keyboard.asm"
*/

#import "common/lib/math-global.asm"
#import "chipset/lib/vic2.asm"
#import "chipset/lib/vic2-global.asm"

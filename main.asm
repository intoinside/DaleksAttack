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

.segmentdef Music [start=$1000]
.segmentdef Code //[start=$0810]
.segmentdef MapData [start=$4000]
.segmentdef MapDummyArea [start=$5000]
.segmentdef Sprites [start=$5400]
.segmentdef Charsets [start=$7800]
.segmentdef CharsetsColors [start=$c000]

#import "_allimport.asm"

.file [name="./main.prg", segments="Code, Music, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$1500]
.file [name="./DaleksAttack.prg", segments="Code, Music, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$1500]
.disk [filename="./DaleksAttack.d64", name="DALEKSATTACK", id="C2022", showInfo]
{
  [name="----------------", type="rel"],
  [name="--- RAFFAELE ---", type="rel"],
  [name="--- INTORCIA ---", type="rel"],
  [name="----------------", type="rel"],
  [name="DALEKSATTACK", type="prg", segments="Code, Music, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$1500],
  [name="----------------", type="rel"]
}

.segment Code

* = $1500 "Entry"
Entry: {
    MainGameSettings()
    jmp GamePlay
}

* = * "Main GamePlay"
GamePlay: {
// Show intro screen until player start a new game
//    jsr Intro.Manager

    ldx #0
    lda #music.startSong - 1
    jsr music.init

    SetupInterrupt()

    inc MusicActive
  !:
    IsReturnPressed()
    beq !-
  
    dec MusicActive

    StopSounds()
    
// Init a new game
    jsr Level.Manager
    jmp GamePlay

  !:
    jmp !-
}

.macro SetupInterrupt() {
    sei
    lda #<IrqForMusic
    sta $0314
    lda #>IrqForMusic
    sta $0315
    asl $d019
    lda #$7b
    sta $dc0d
    lda #$81
    sta $d01a
    lda #$1b
    sta $d011
    lda #$ff
    sta $d012
}

IrqForMusic: {
    asl $d019
    inc $d020
    lda MusicActive
    beq !+
    jsr music.play 
  !:
    dec $d020
    pla
    tay
    pla
    tax
    pla
    rti
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

MusicActive: .byte 0

#import "_label.asm"
#import "_level.asm"
#import "_sounds.asm"

#import "common/lib/math-global.asm"
#import "chipset/lib/vic2.asm"
#import "chipset/lib/vic2-global.asm"

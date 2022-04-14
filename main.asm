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
.segmentdef Intro
.segmentdef Code
.segmentdef MapData [start=$4000]
.segmentdef MapDummyArea [start=$4c00]
.segmentdef Sprites [start=$5000]
.segmentdef Charsets [start=$5800]
.segmentdef CharsetsColors [start=$c000]

#import "_allimport.asm"

.file [name="./main.prg", segments="Music, Code, Intro, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$1500]
.file [name="./DaleksAttack.prg", segments="Music, Code, Intro, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$1500]
.disk [filename="./DaleksAttack.d64", name="DALEKSATTACK", id="C2022", showInfo]
{
  [name="----------------", type="rel"],
  [name="--- RAFFAELE ---", type="rel"],
  [name="--- INTORCIA ---", type="rel"],
  [name="-- @GMAIL.COM --", type="rel"],
  [name="----------------", type="rel"],
  [name="DALEKSATTACK", type="prg", segments="Music, Code, Intro, Charsets, CharsetsColors, MapData, Sprites", modify="BasicUpstart", _start=$1500],
  [name="----------------", type="rel"]
}

.segment Code

* = $1500 "Entry"
Entry: {
    MainGameSettings()

  GamePlay:
    ldx #0
    lda #music.startSong - 1
    jsr music.init

    SetupInterrupt()

    inc MusicActive

// Show intro screen until player start a new game
    ShowIntro()
    IsReturnPressedAndReleased()
    dec MusicActive

    StopSounds()

    PrepareGame()
    
// Init game
    jsr Level.Manager
    jmp GamePlay
}

.macro ShowIntro() {
    lda #0
    sta c64lib.SPRITE_ENABLE

    lda #%00001000  // Bitmap mem $2000, Screen mem $0000 (+VIC $4000)
    sta c64lib.MEMORY_CONTROL
    lda #%11011000  // 40 cols, multicolor mode
    sta c64lib.CONTROL_2
    lda #%00111011  // 25 rows, screen on, bitmap mode
    sta c64lib.CONTROL_1

    ldx #0
    lda #15
  !Loop:
    .for (var i=0; i<4; i++) {
      sta $d800 + i * $100, x
    }
    inx
    bne !Loop-

    lda #picture.getBackgroundColor()
    sta $d020
    sta $d021
}

.macro SetupInterrupt() {
    sei
    lda #<IrqForMusic
    sta $0314
    lda #>IrqForMusic
    sta $0315
    asl c64lib.IRR
    lda #$7b
    sta $dc0d
    lda #$81
    sta c64lib.IMR
    lda #%00011011
    sta c64lib.CONTROL_1
    lda #$ff
    sta c64lib.RASTER
}

.macro PrepareGame() {
// Set pointer to char memory to $5800-$5fff (xxxx011x)
// and pointer to screen memory to $4400-$47ff (0001xxxx)
    lda #%00010110
    sta c64lib.MEMORY_CONTROL   

    lda #%00011011  // 25 rows, screen on, bitmap mode off
    sta c64lib.CONTROL_1
}

IrqForMusic: {
    asl c64lib.IRR
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
    and #%11111110  // %xxxxxx10 - Ram $a000-$bfff, Kernal $e000-$ffff
    sta $01

// Set Vic bank 1 ($4000-$7fff)
    lda #%00000010
    sta CIA2.PORT_A

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

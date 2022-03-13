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
* = * "Level1 Manager"
Manager: {
    jsr Init

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

    lda #BLACK
    sta c64lib.BG_COL_1
    lda #WHITE
    sta c64lib.BG_COL_2

// Set pointer to char memory to $7800-$7fff (xxxx111x)
// and pointer to screen memory to $4400-$47ff (0001xxxx)
    lda #%00011110
    sta c64lib.MEMORY_CONTROL   

    jmp AddColorToMap   // jsr + rts
}

AddColorToMap: {
    lda #>ScreenMemoryBaseAddress
    sta SetColorToChars.ScreenMemoryAddress

    jmp SetColorToChars
}

.label ScreenMemoryBaseAddress = $4400

#import "_utils.asm"

#import "chipset/lib/vic2.asm"

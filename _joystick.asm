////////////////////////////////////////////////////////////////////////////////
//
// Project   : DaleksAttack - https://github.com/intoinside/DaleksAttack
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Routine for joystick managing
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.filenamespace Joystick

FirePressed: .byte $00

// Player sprite direction
Direction:    .byte $01         // $00 - no move, $01 - right, $ff - left
// Player sprite vertical direction
DirectionY:   .byte $ff         // $00 - no move, $01 - down, $ff - up

// Player sprite orientation
Orientation:  .byte $01         // $01 - right, $ff - left

* = * "Joystick GetJoystickMove"
GetJoystickMove: {
    lda #0
    sta $dc02

    ldx #$00
    lda $dc00

    lsr
    bcs !NoUp+
    ldx #$ff

  !NoUp:
    lsr
    bcs !NoDown+
    ldx #$01
  !NoDown:
    stx DirectionY
    ldx #$00
    lsr
    bcs !NoLeft+
    ldx #$ff
    stx Orientation
  !NoLeft:
    lsr
    bcs !NoRight+
    ldx #$01
    stx Orientation
  !NoRight:
    stx Direction
    ldx #$00
    lsr
    bcs !NoFirePressed+
    ldx #$ff
  !NoFirePressed:
    stx FirePressed
    rts

  CheckOnlyFirePress:
    jmp GetOnlyFirePress
}

// Read joystick (port 2) status and set FirePressed to $ff if fire is pressed
// $00 otherwise
GetOnlyFirePress: {
    lda $dc00
    ldx #0
    lsr
    lsr
    lsr
    lsr
    lsr
    bcs !NoFirePressed+
    ldx #$ff
  !NoFirePressed:
    stx FirePressed

    rts
}

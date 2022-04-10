////////////////////////////////////////////////////////////////////////////////
//
// Project   : DaleksAttack - https://github.com/intoinside/DaleksAttack
// Target    : Commodore 64
// Author    : Raffaele Intorcia - raffaele.intorcia@gmail.com
//
// Routine for sounds
//
////////////////////////////////////////////////////////////////////////////////

#importonce

.macro StopSounds() {
    lda #%00000000
    sta Sounds.SID.VOICE1_CTRL
    sta Sounds.SID.VOICE2_CTRL
    sta Sounds.SID.VOICE3_CTRL
}

.filenamespace Sounds

Explosion: {
    lda #%00001111
    sta SID.VOLUME_FILTER_MODES
    lda #0        
    sta SID.VOICE3_FREQ_1
    lda #5
    sta SID.VOICE3_FREQ_2
    lda #%00001010                  // 2ms attack, 1.5s decay
    sta SID.VOICE3_ATTACK_DECAY
    lda #%00000111                  // 0 sustain volume, 240ms release
    sta SID.VOICE3_SUSTAIN_RELEASE
    lda #%00000000
    sta SID.VOICE3_CTRL
    lda #%10000001          // Noise for explosion
    sta SID.VOICE3_CTRL

    rts
}

SID: {
	.label VOICE1_FREQ_1		= $d400
	.label VOICE1_FREQ_2		= $d401
	.label VOICE1_CTRL			= $d404
	.label VOICE1_ATTACK_DECAY	= $d405
	.label VOICE1_SUSTAIN_RELEASE	= $d406
	.label VOLUME_FILTER_MODES	= $d418

	.label VOICE2_FREQ_1		= $d407
	.label VOICE2_FREQ_2		= $d408
	.label VOICE2_CTRL			= $d40b
	.label VOICE2_ATTACK_DECAY	= $d40c
	.label VOICE2_SUSTAIN_RELEASE	= $d40d

	.label VOICE3_FREQ_1		= $d40e
	.label VOICE3_FREQ_2		= $d40f
	.label VOICE3_CTRL			= $d412
	.label VOICE3_ATTACK_DECAY	= $d413
	.label VOICE3_SUSTAIN_RELEASE	= $d414
}

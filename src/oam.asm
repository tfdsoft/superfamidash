; Copyright (C) 2025 iProgramInCpp

.segment "BSS"

; The low table is 4 bytes per sprite, for a total of 128 sprites.
oam_low_table:	.res 512

; The high table is 2 bits per sprite
oam_high_table:	.res 32

.export _oam_clear=oam_clear

.segment "CODE"

; ** SUBROUTINE: oam_clear
; desc: Clears OAM.
; expects: A and X size: 8 bits
.proc oam_clear
	; Clears OAM.
	lda #0
	ldx #0
:	sta oam_low_table, x
	sta oam_low_table + 256, x
	inx
	bne :-
:	sta oam_high_table, x
	inx
	cpx #32
	bne :-
	rtl
.endproc

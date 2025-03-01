; Copyright (C) 2025 iProgramInCpp

.segment "CODE"

.export _ppu_off
.proc _ppu_off
	lda #$8F
	sta inidisp
	rts
.endproc

.export _ppu_wait_nmi
.proc _ppu_wait_nmi
	lda nmi_counter
:	wai
	cmp nmi_counter
	beq :-
	rts
.endproc

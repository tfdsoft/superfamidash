; Copyright (C) 2025 iProgramInCpp

.segment "CODE"

.proc nmi
	a8
	bit rdnmi
	
	bit nmi_semaphore
	bmi dontRunNMI
	
	inc nmi_counter
	
	ai16
	pha
	phx
	phy
	
	; our operations are done in 8 bit mode.
	ai8
	jsr oam_perform_dma
	jsr hdma_update
	jsr read_cont
	
	ai16
	ply
	plx
	pla

dontRunNMI:
	rti
	ai8
.endproc

; ** SUBROUTINE: oam_perform_dma
; desc: Performs OAM DMA. TODO
.proc oam_perform_dma
	rts
.endproc

; ** SUBROUTINE: hdma_update
; desc: Programs the HDMA registers.
.proc hdma_update
	lda #0
	tax
	
@loop:
	pha
	tay
	
	lda @bitSetTable, x
	bit hdma_enable
	beq @skip
	
	lda hdma_dasb, x
	sta dasb(0), y
	lda hdma_dmap, x
	sta dasb(0), y
	lda hdma_bbad, x
	sta bbad(0), y
	lda hdma_a1tl, x
	sta a1tl(0), y
	lda hdma_a1th, x
	sta a1th(0), y
	lda hdma_a1b, x
	sta a1b(0), y
	
@skip:
	pla
	clc
	adc #8
	inx
	cpx #8
	bne @loop
	
	lda hdma_enable
	sta hdmaen
	
	rts

@bitSetTable:
	.byte $01, $02, $04, $08, $10, $20, $40, $80
.endproc

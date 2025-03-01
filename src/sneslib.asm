; Copyright (C) 2025 iProgramInCpp

.segment "CODE"

.i8
.a8

; These are supposed to be called using `jsl`.
; NOTE: When you add a SNESLIB function, also define it in "stubs.asm".

.proc ppu_off
	lda #$8F
	sta inidisp
	rtl
.endproc

.proc ppu_on_all
	lda #$00
	sta inidisp
	rtl
.endproc

.proc ppu_wait_nmi
	lda nmi_counter
:	wai
	cmp nmi_counter
	beq :-
	rtl
.endproc

;uint8_t __fastcall__ rand8();
;Galois random generator, found somewhere
;out: A random number 0..255
.proc newrand
	ldy #8
	lda RAND_SEED+0
:
	asl
	rol RAND_SEED+1
	rol RAND_SEED+2
	rol RAND_SEED+3
	bcc :+
	eor #$C5
:
	dey
	bne :--
	sta RAND_SEED+0
	cmp #0
	rtl

rand1:

	lda RAND_SEED
	asl a
	bcc @1
	eor #$cf

@1:

	sta RAND_SEED
	rtl

rand2:

	lda RAND_SEED+1
	asl a
	bcc @1
	eor #$d7

@1:

	sta RAND_SEED+1
	rtl
.endproc

.proc vram_adr
	stx vmaddh
	sta vmaddl
	rtl
.endproc

; TODO: This is a placeholder. It currently sets all attributes
; to 0 which may be undesirable. Maybe change this soon.
.proc vram_unrle
	tay
	stx <RLE_HIGH
	lda #0
	sta <RLE_LOW
	
	; set address increment mode (increment after writing $2119)
	lda #%10000000
	sta vmain

	lda (RLE_LOW),y
	sta RLE_TAG
	iny
	bne @1
	inc <RLE_HIGH

@1:

	lda (RLE_LOW),y
	iny
	bne @11
	inc <RLE_HIGH

@11:

	cmp RLE_TAG
	beq @2
	
	sta vmdatal
	stz vmdatah
	
	sta RLE_BYTE
	bne @1

@2:

	lda (RLE_LOW),y
	beq @4
	iny
	bne @21
	inc <RLE_HIGH

@21:

	tax
	lda RLE_BYTE

@3:

	sta vmdatal
	stz vmdatah
	
	dex
	bne @3
	beq @1

@4:

	rtl
.endproc

.proc set_scroll_x
	sta bg1hofs
	stx bg1hofs
	rtl
.endproc

.proc set_scroll_y
	sta bg1vofs
	stx bg1vofs
	rtl
.endproc

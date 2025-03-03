; Copyright (C) 2025 iProgramInCpp

.segment "CODE"

.i8
.a8

; This macro fetches the previous program bank from the stack.
; If you push things before calling this, make sure to account for them and use the _SO variant.
.macro PREPARE_DATA_BANK_SO n
	; we need to fetch the current program bank. Luckily, this is
	; actually relatively straightforward on the 65816:
	lda 3+n, s
	
	; ^ The layout of the stack at this point is `pbr`, `pch`, `pcl`
	; (this is the order in which they were pushed). Load the 3rd entry.
	
	phb
	; Use it as the current data bank.
	pha
	plb
.endmacro

.macro PREPARE_DATA_BANK
	PREPARE_DATA_BANK_SO 0
.endmacro

.export _ppu_off
.export _ppu_on_all
.export _ppu_wait_nmi
.export _vram_adr
.export _vram_unrle
.export __vram_dma
.export _newrand
.export _set_scroll_x
.export _set_scroll_y
.export _set_scroll_x_bg2
.export _set_scroll_y_bg2
.export __pal_bg
.export __pal_spr
.export __pal_all
.export _clear_hdma
.export __set_hdma

; These are supposed to be called using `jsl`.
; NOTE: When you add a SNESLIB function, also define it in "stubs.asm".

.proc _ppu_off
	lda #$8F
	sta inidisp
	rtl
.endproc

.proc _ppu_on_all
	lda #$0F
	sta inidisp
	rtl
.endproc

.proc _ppu_wait_nmi
	; let the NMI know we're ready
	inc nmi_semaphore
	
	; now wait for the NMI counter to change
	lda nmi_counter
:	wai
	cmp nmi_counter
	beq :-
	
	; okay now we aren't ready anymore
	dec nmi_semaphore
	rtl
.endproc

;uint8_t __fastcall__ rand8();
;Galois random generator, found somewhere
;out: A random number 0..255
.proc _newrand
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

.proc _vram_adr
	stx vmaddh
	sta vmaddl
	rtl
.endproc

; TODO: This is a placeholder. It currently sets all attributes
; to 0 which may be undesirable. Maybe change this soon.
;
; Arguments: XA - Address of data to unpack
.proc _vram_unrle
	tay
	stx <RLE_HIGH
	lda #0
	sta <RLE_LOW
	
	PREPARE_DATA_BANK
	
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
	
	; Now, pop the old data bank
	plb
	rtl
.endproc

.proc _set_scroll_x
	sta f:scroll_x
	tax
	sta f:scroll_x+1
	rtl
.endproc

.proc _set_scroll_y
	sta f:scroll_y
	tax
	sta f:scroll_y+1
	rtl
.endproc

.proc _set_scroll_x_bg2
	sta f:scroll_x_bg2
	tax
	sta f:scroll_x_bg2+1
	rtl
.endproc

.proc _set_scroll_y_bg2
	sta f:scroll_y_bg2
	tax
	sta f:scroll_y_bg2+1
	rtl
.endproc

; parameters:
;    XA - The address of the palette.
;    NEXTSPR - The bank to load from.
.proc __pal_bg
	; prepare a DMA transfer
	stx a1th(0)
	sta a1tl(0)
	
	lda NEXTSPR
	sta a1b(0)
	
	stz cgadd
	
	a16
	lda #$0100
	sta dasl(0)
	
	a8
	lda #<cgdata
	sta bbad(0)
	
	stz dmap(0) ; transfer pattern 0, A->B
	
	; transfer!
	lda #1
	sta mdmaen
	
	rtl
.endproc

; parameters:
;    XA - The address of the palette.
;    NEXTSPR - The bank to load from.
.proc __pal_spr
	; prepare a DMA transfer
	stx a1th(0)
	sta a1tl(0)
	
	lda NEXTSPR
	sta a1b(0)
	
	lda #$80
	sta cgadd
	
	a16
	lda #$0100
	sta dasl(0)
	
	a8
	lda #<cgdata
	sta bbad(0)
	
	stz dmap(0) ; transfer pattern 0, A->B
	
	; transfer!
	lda #1
	sta mdmaen
	
	rtl
.endproc

; parameters:
;    XA - The address of the palette.
;    NEXTSPR - The bank to load from.
.proc __pal_all
	; prepare a DMA transfer
	stx a1th(0)
	sta a1tl(0)
	
	lda NEXTSPR
	sta a1b(0)
	
	stz cgadd
	
	a16
	lda #$0200
	sta dasl(0)
	
	a8
	lda #<cgdata
	sta bbad(0)
	
	stz dmap(0) ; transfer pattern 0, A->B
	
	; transfer!
	lda #1
	sta mdmaen
	
	rtl
.endproc

; parameters:
;     XA - low 16 bits of source address
;     NEXTSPR (zp) - high 8 bits of source address
;     PTR (zp) - VRAM dest word address
;     LEN (zp) - VRAM transfer length
.proc __vram_dma
	stx a1th(0)
	sta a1tl(0)
	
	lda NEXTSPR
	sta a1b(0)
	
	; set address increment mode (increment after writing $2119)
	lda #%10000000
	sta vmain
	
	a16
	lda LEN
	sta dasl(0)
	lda PTR
	sta vmaddl
	a8
	
	lda #<vmdatal
	sta bbad(0)
	
	lda #1
	sta dmap(0) ; transfer pattern 1, A->B
	
	;lda #1
	sta mdmaen ; transfer!
	
	rtl
.endproc

; clears HDMA flags
.proc _clear_hdma
	stz hdma_enable
	rtl
.endproc

; sets HDMA for a channel from 0 to 7
; C prototype: void SNESCALL _set_hdma(uint16_t dasb_channel);
; parameters:
;   reg A - The channel number
;   reg X - The DASB (indirect HDMA bank)
;   PTR - The near address of the HDMA table
;   NSP - The bank byte of the HDMA table
;   LEN - The DMAP
;   LEN+1 - The BBAD
.proc __set_hdma
	and #7
	tax
	lda f:@bitSetTable, x
	ora hdma_enable
	sta hdma_enable
	
	; OK. Now load the actual properties.  Since this channel
	; is potentially active we have to store this write somewhere.
	; I suggest we do it in high RAM.
	tya
	sta f:hdma_dasb, x
	lda LEN
	sta f:hdma_dmap, x
	lda LEN+1
	sta f:hdma_bbad, x
	lda PTR
	sta f:hdma_a1tl, x
	lda PTR+1
	sta f:hdma_a1th, x
	lda NEXTSPR
	sta f:hdma_a1b, x
	
	rtl

@bitSetTable:
	.byte $01, $02, $04, $08, $10, $20, $40, $80
.endproc

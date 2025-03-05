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
.export _oam_clear
.export __oam_sprex
.export __oam_spr
.export __oam_meta_spr

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

; clears OAM
.proc _oam_clear
	lda #.bankbyte(oam_buffer_lo)
	pha
	plb
	
	; Clears OAM.
	lda #0
	ldx #0
:	sta oam_buffer_hi, x
	inx
	cpx #32
	bne :-
	
	ldx #0
	lda #$F0
:	sta oam_buffer_lo+1, x
	sta oam_buffer_lo+257, x
	inx
	inx
	inx
	inx
	bne :-
	
	stz oam_wrhead
	stz oam_wrhead+1
	lda #$00
	pha
	plb
	rtl
.endproc

; puts out a sprite
; parameters:
;    XA  - Sprite number
;    LEN - Attribute byte Low, 2 Extended attributes bits High
;    PTR - X coordinate Low, Y coordinate High
.proc __oam_sprex
	pha
	; load high RAM 
	lda #.bankbyte(oam_buffer_lo)
	pha
	plb
	pla
	
	; put the high byte of the number into A
	xba
	tax
	and #1
	; then OR it with the attribute byte
	ora LEN
	
	ai16
	ldx oam_wrhead
	
	; then the tile number and bytes (in one shot)
	xba ; the order was [TILENUMBER*256+ATTRIBUTES], now it's reversed
	sta oam_buffer_lo+2, x
	
	; now load the X/Y coordinates and write them too in one shot
	lda PTR
	sta oam_buffer_lo, x
	
	; now transfer the index to A, shift it twice to get the sprite index
	txa
	lsr
	lsr
	
	; we got the sprite index, get the bit we should modify
	pha
	
	; first, get the in byte position, multiply it by 4 and add the extended attribute bits
	and #3
	sta LEN
	lda LEN+1
	asl
	asl
	clc
	adc LEN
	tay
	
	pla
	
	; now get the byte index
	lsr
	lsr
	tax
	ai8
	
	; Swap X and Y
	txa
	tyx
	tay
	lda oam_buffer_hi, y
	ora f:@table, x
	sta oam_buffer_hi, y
	
	a16
	
	; increment the write head now.
	lda oam_wrhead
	clc
	adc #4
	and #$1FF
	sta oam_wrhead
	
	ai8
	lda #0
	pha
	plb
	rtl

@table:
	.byte $00, $00, $00, $00
	.byte $01, $04, $10, $40
	.byte $02, $08, $20, $40
	.byte $03, $0C, $30, $C0
.endproc

; OAM Legacy Sprite
; This draws an 8x16 sprite to the screen.  It has a few limitations compared to oam_sprex.
; - Cannot use more than 256 tiles at once.
; - Cannot change the size of the sprite or place it partly off the left side of the screen.
; parameters:
;    XA  - Sprite number (A), Attribute Byte (X)
;    PTR - X coordinate Low, Y coordinate High
.proc __oam_spr
	pha
	; load high RAM 
	lda #.bankbyte(oam_buffer_lo)
	pha
	plb
	pla
	
	; put the attribute byte in the high part of A
	xba
	txa
	xba
	
	i16
	ldx oam_wrhead
	
	; write the X/Y coordinates in one shot
	a16
	pha
	lda PTR
	sta oam_buffer_lo, x
	pla
	a8
	
	; then the tile number (low A)
	; note: it has to be converted from NES format to SNES format.
	; basically, the Tile Number is formed like this:
	; AAABCCCD
	; where B and D are swapped in 8x16 mode
	pha
	and #%00011110
	lsr
	sta PTR
	pla
	and #%11100000
	ora PTR
	sta oam_buffer_lo+2, x
	
	; high A contains the attributes
	; we have to convert them to S-NES format (they are in NES format)
	
	; the V and H bits are fine.  The priority bit is also in the correct
	; position although it needs to be flipped, and the other priority bit
	; must be set to 1 so that sprites always render in front of the parallax
	xba
	pha
	and #%11100000
	eor #%00100000
	sta PTR
	and #%00100000
	lsr
	ora #%00100000
	ora PTR
	sta PTR
	
	; now the palette index needs to be shifted a bit
	pla
	and #%00000011
	asl
	ora PTR
	
	; and now write!
	sta oam_buffer_lo+3, x
	
	; now, duplicate this sprite and offset it by 8 pixels down
	a16
	lda oam_buffer_lo, x
	clc
	adc #$0800
	sta oam_buffer_lo+4, x
	
	lda oam_buffer_lo+2, x
	clc
	adc #$0010
	sta oam_buffer_lo+6, x
	
	; increment the write head now.
	lda oam_wrhead
	clc
	adc #8
	and #$1FF
	sta oam_wrhead
	
	ai8
	lda #0
	pha
	plb
	rtl
.endproc

; OAM Meta Sprite
; Data format:
;    [X] [Y] [Tile Number] [NES Attribute Bits]
; Terminator: 0x80
;
; parameters:
;   XA - Data (near)
;   NEXTSPR - Data (bank)
;   sreg[1, 0] = [y, x]
.proc __oam_meta_spr
	; AX = data
	; sreg[0] = x
	; sreg[1] = y
	; NEXTSPR = Data Bank
	sta <PTR
	stx <PTR+1

	lda NEXTSPR
	sta PTR+2    ; == LEN
	lda #.bankbyte(oam_buffer_lo)
	pha
	plb
	
	ai16
	ldy #0
	ldx oam_wrhead
@loop:

	lda [PTR], y
	
	; check if the X is $80
	a8
	cmp #$80
	bne :+
	beq @end
:	a16
	
	; it's not!
	; now, Famidash assumes 8x16 sprites. So let's try our best to emulate them.
	
	; write the XY coordinates
	sta oam_buffer_lo, x
	
	iny
	iny
	
	; load tile number and attributes
	lda [PTR], y
	
	; only write the tile number for now
	a8
	sta oam_buffer_lo + 2, x
	
	; put the attributes in the picture
	xba
	
	; the V and H bits are fine.  The priority bit is also in the correct
	; position although it needs to be flipped, moved 1 to the right, and
	; 2 must be added, so that sprites are never behind the parallax layer
	pha
	and #%11100000
	eor #%00100000
	sta PTR+3
	and #%00100000
	lsr
	ora #%00100000
	ora PTR+3
	sta PTR+3
	
	; now the palette index needs to be shifted a bit
	pla
	and #%00000011
	asl
	ora PTR+3
	
	; there we go, now it's been converted
	sta oam_buffer_lo + 3, x
	
	; now write the high byte
	a16
	lda oam_buffer_lo,     x
	clc
	adc #$0800
	sta oam_buffer_lo+4,   x
	
	; attributes (high) and tile number (low)
	lda oam_buffer_lo + 2, x
	clc
	adc #$10
	sta oam_buffer_lo + 6, x
	
	; now increment X by 8
	txa
	clc
	adc #8
	tax
	jmp @loop
	
@end:
	ai8
	lda #0
	pha
	plb
	rtl
.endproc

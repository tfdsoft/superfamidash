; Copyright (C) 2025 iProgramInCpp
; Based on startup code for cc65 and Shiru's NES library
; Based on code by Groepaz/Hitmen <groepaz@gmx.net>, Ullrich von Bassewitz <uz@cc65.org>

.segment "CODE"
.export _exit,__STARTUP__:absolute=1
.import push0,popa,popax,_main

; linker generated symbols
.import __C_STACK_START__, __C_STACK_SIZE__

reset:
_exit:
	sei
	clc
	xce
	cld
	
	ai16
	
	; setup stack pointer
	ldx #$1FF
	txs
	
	pea 0
	pld         ; reset direct page pointer to 0
	phk
	plb         ; set data bank to program bank
	
	; zero the CPU registers nmitimen through memsel
	; note: since A is 16 bits there are 2 bytes written
	stz nmitimen; and wrio
	stz wrmpya  ; and wrmpyb
	stz wrdivl  ; and wrdivh
	stz wrdivb  ; and htimel
	stz htimeh  ; and vtimel
	stz vtimeh  ; and mdmaen
	stz hdmaen  ; and memsel
	
	lda #$008f
	sta inidisp ; turn off screen (enable force blank)
	; ^ also sets obsel to 0
	
	stz oamaddl ; and oamaddrh
	stz bgmode  ; and mosaic
	stz bg1sc   ; and bg2sc
	stz bg3sc   ; and bg4sc
	stz vmaddl  ; and vmaddh
	stz w12sel  ; and w34sel
	stz wh0     ; and wh1
	stz wh2     ; and wh3
	stz wbglog  ; and wobjlog
	stz tm      ; and ts
	stz tmw     ; and tsw
	
	; disable color math
	lda #$0030
	sta cgwsel
	lda #$00E0
	sta coldata
	
	a8
	stz bg1hofs
	stz bg1hofs
	stz bg1vofs
	stz bg1vofs
	stz bg2hofs
	stz bg2hofs
	stz bg2vofs
	stz bg2vofs
	stz bg3hofs
	stz bg3hofs
	stz bg3vofs
	stz bg3vofs
	stz bg4hofs
	stz bg4hofs
	stz bg4vofs
	stz bg4vofs
	
	stz wobjsel
	
	; fill WRAM with zeroes using two 64kib fixed address DMA transfers to WMDATA.
	stz wmaddl
	stz wmaddm
	stz wmaddh
	
	lda #$08
	sta dmap(0)  ; fixed address transfer to a byte register
	
	lda #<wmdata
	sta bbad(0)
	
	ldx #.loword(zero_byte)
	stx a1tl(0)
	lda #.bankbyte(zero_byte)
	sta a1b(0)
	ldx #0
	sta dasl(0)
	
	; first 64K
	lda #1
	sta mdmaen
	
	; second 64K
	stx dasl(0)
	sta mdmaen
	
	; NMIs can't be processed right now, only until the first ppu_wait_nmi()
	lda #$FF
	sta nmi_semaphore
	
	; enable NMI and controller auto-read
	lda #%10000001
	sta nmitimen
	
	; jump to C main
	; NOTE: as far as I know CC65 just uses 8 bit acc and index registers.
	cli
	ai8
	jml _main

no_int:
irq:
	rti

zero_byte:	.byte 0
message: 	.byte "Hello, world!"
message_end:

; Copyright (C) 2025 iProgramInCpp

.segment "PRG_MAIN"

reset:
	sei
	clc
	xce
	cld
	
	ai16
	
	; zero the CPU registers nmitimen through memsel
	; note: since A is 16 bits there are 2 bytes written
	stz nmitimen; and wrio
	stz wrmpya  ; and wrmpyb
	stz wrdivl  ; and wrdivh
	stz wrdivb  ; and htimel
	stz htimeh  ; and vtimel
	stz vtimeh  ; and mdmaen
	stz hdmaen  ; and memsel
	
	lda #$0080
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
	
	; set up the color palette
	stz cgadd
	
	; color format: 0bbbbbgggggrrrrr
	
	; black
	stz cgdata
	stz cgdata
	
	; dark gray
	lda #%11100111
	sta cgdata
	lda #%00011100
	sta cgdata

	; med gray
	lda #%11101111
	sta cgdata
	lda #%00111101
	sta cgdata
	
	; white
	lda #%11111111
	sta cgdata
	lda #%01111111
	sta cgdata
	
	; set BG Mode to 1
	lda #1
	sta bgmode
	
	; for now, the VRAM will look as follows:
	; $0000 - Screen 0, 1, 2, 3
	; $4000 - Char Set
	
	lda #%00000000 ; address = $0000, no h mirroring, no v mirroring
	sta bg1sc
	
	lda #%00000010 ; address = $4000 >> 13 = $02
	sta bg12nba
	
	; perform DMA on channel 0 to transfer a zero byte into $0000 in VRAM
	lda #%00011001 ; pattern 1, transfer from A to B, A bus addr fixed after copy
	sta dmap(0)
	
	lda #<vmdatal
	sta bbad(0)
	
	; set address increment mode (increment after writing $2119)
	lda #%10000000
	sta vmain
	
	ldx #0
	stx vmaddl
	
	ldx #.loword(zero_byte)
	stx a1tl(0) ; and a1th(0)
	lda #<.hiword(zero_byte)
	sta a1b(0)
	ldx #$1000
	stx dasl(0) ; and dash(0)
	
	lda #1
	sta mdmaen
	
	; perform DMA on channel 0 to transfer our char set into memory
	; bbad and vmain remain the same
	
	lda #%00000001 ; pattern 1, transfer from A to B, increment A bus addr after copy
	sta dmap(0)
	
	; we want to write the char set to $4000
	ldx #$4000>>1
	stx vmaddl
	
	ldx #.loword(charset)
	stx a1tl(0) ; and a1th(0)
	lda #<.hiword(charset)
	sta a1b(0)
	ldx #.loword(charset_end-charset)
	stx dasl(0) ; and dash(0)
	
	; and go !
	lda #1
	sta mdmaen
	
	; let's write "Hello, world!" to the screen.
	ldx #32*5+4  ; x = 4, y = 5
	stx vmaddl
	
	ldx #0
@writeLoop:
	lda message, x
	sta vmdatal
	
	; attributes here -- no high tile index, palette 0, no priority, no H/V flip
	stz vmdatah
	
	inx
	cpx #message_end-message
	bne @writeLoop
	
	; show BG1 in main screen
	lda #1
	sta tm
	
	; turn on the display
	lda #$0f
	sta inidisp
	
loop:
	bra loop


nmi:
	;bit RDNMI
no_int:
irq:
	rti

zero_byte:	.byte 0
message: 	.byte "Hello, world!"
message_end:

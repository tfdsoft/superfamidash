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
	
	; magenta
	; 0bbbbbgggggrrrrr
	lda #%00011111
	sta cgdata
	lda #%01111100
	sta cgdata
	
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

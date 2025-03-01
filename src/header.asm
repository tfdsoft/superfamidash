; Copyright (C) 2025 iProgramInCpp

.segment "PRG_HEADER"
	.byte "SNES TEST            " ; game name
	.byte %00110000   ; fast low ROM
	.byte %00000000   ; ROM only
	.byte $04         ; ROM size - 128KB for now
	.byte $00         ; RAM size - none needed for now
	.byte $01         ; country - NTSC-U
	.byte $00         ; developer ID
	.byte $00         ; ROM version
	.word $0000       ; Check Sum Complement (checksum ^ $FFFF)
	.word $0000       ; Check Sum
	
	; Vectors
	; 65C816 Native Mode Vectors
	.word $0000       ; FFE0 - unused
	.word $0000       ; FFE2 - unused
	.addr no_int      ; FFE4 - unused COP
	.addr no_int      ; FFE6 - unused BRK
	.addr no_int      ; FFE8 - unused ABORT
	.addr nmi         ; FFEA - NMI / vblank interrupt
	.addr no_int      ; FFEC - unused
	.addr irq         ; FFEE - IRQ
	; 6502 Emulation Mode Vectors
	.word $0000       ; FFF0 - unused
	.word $0000       ; FFF2 - unused
	.word $0000       ; FFF4 - unused COP
	.word $0000       ; FFF6 - unused
	.word $0000       ; FFF8 - unused ABORT
	.word $0000       ; FFFA - unused NMI (we almost never run the CPU in 6502 mode)
	.addr reset       ; FFFC - RESET
	.word $0000       ; FFFE - unused IRQ (same deal here)

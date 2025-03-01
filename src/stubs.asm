; Copyright (C) 2025 iProgramInCpp

; These stubs actually execute from low RAM ($1F00-$1FFF).
; Accumulator and Index registers are 8 bits wide.
.a8
.i8

.segment "STUBS"

.align $100
stubs_begin = $808000

.macro stub name
	.export .ident(.concat("_", name))
	.ident(.concat("_", name)):
	jsl .ident(name)
	rts
.endmacro

stub "ppu_off"
stub "ppu_on_all"
stub "ppu_wait_nmi"
stub "vram_adr"
stub "vram_unrle"
stub "newrand"
stub "set_scroll_x"
stub "set_scroll_y"

; Copyright (C) 2025 iProgramInCpp

.segment "BANK1"

; makes a C to C stub
.macro makestub name
	.export .ident(.concat("_CALL_", name))
	.import .ident(.concat("_", name))
	.ident(.concat("_CALL_", name)):
		jsr .ident(.concat("_", name))
		rts
.endmacro

makestub "state_menu"

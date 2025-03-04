; Copyright (C) 2025 iProgramInCpp

.segment "BANK5"

; Character Banks
.export _icon_banks=icon_banks
icon_banks:
	; note: do not use this bank for anything else
	.repeat 15, i
		.incbin .sprintf("GRAPHICS/bankicon%02X-4bpp.chr", i)
	.endrepeat
	
	;2KB free for one more icon bank
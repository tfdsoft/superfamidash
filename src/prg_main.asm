; Copyright (C) 2025 iProgramInCpp

.segment "PRG_MAIN"

reset:
	sei
	clc
	xce
	cld
	
	ai16
	
	
	
loop:
	bra loop


nmi:
	;bit RDNMI
no_int:
irq:
	rti

; Copyright (C) 2025 iProgramInCpp

.segment "CODE"

.proc nmi
	a8
	bit rdnmi
	
	bit nmi_semaphore
	bmi dontRunNMI
	
	inc nmi_counter
	
	ai16
	pha
	phx
	phy
	
	; our operations are done in 8 bit mode.
	ai8
	jsr read_cont
	
	ai16
	ply
	plx
	pla

dontRunNMI:
	rti
	ai8
.endproc

; Copyright (C) 2025 iProgramInCpp

; ****** SNES REGISTERS ******



; ****** ADDRESSING MODE SWITCHES ******
; these macros change the address mode in both ca65
; (.i16) and also on the CPU (through rep/sep)

.macro i16
	rep #$10
	.i16
.endmacro

.macro a16
	rep #$20
	.a16
.endmacro

.macro ai16
	rep #$30
	.a16
	.i16
.endmacro

.macro i8
	sep #$10
	.i16
.endmacro

.macro a8
	sep #$20
	.a16
.endmacro

.macro ai8
	sep #$30
	.a8
	.i8
.endmacro

.define ia8  ai8
.define ia16 ai16

; ****** GAME RELATED ******



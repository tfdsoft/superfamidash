; Copyright (C) 2025 iProgramInCpp

; This file ties everything together.

; -- IMPORTANT --
;
; The C calling convention is currently defines as follows. When you call into or return
; to a C function, the following must be true:
;
; - Accumulator is 8 bits
; - X and Y registers are 8 bits
; - The direct page register is set to $0000
; - The data bank register is set to $00

.p816
.smart
.feature string_escapes
.feature line_continuations

.include "defines.asm"
.include "globals.asm"

.include "header.asm"
.include "czpage.asm"
.include "zeropage.asm"
.include "init.asm"
.include "nmi.asm"
.include "joypad.asm"
.include "oam.asm"
.include "sneslib.asm"
.include "bank1.asm"
.include "bank2.asm"
.include "bank3.asm"
.include "bank4.asm"
.include "bank5.asm"
.include "bank6.asm"
.include "bank7.asm"

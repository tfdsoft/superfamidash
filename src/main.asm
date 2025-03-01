; Copyright (C) 2025 iProgramInCpp

; This file ties everything together.

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
.include "stubs.asm"
.include "oam.asm"
.include "sneslib.asm"
.include "bank1.asm"
.include "bank2.asm"
.include "bank3.asm"

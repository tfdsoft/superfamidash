; Copyright (C)2025 iProgramInCpp

; CC65 runtime
;
; Ullrich von Bassewitz, 06.08.1998
;
; CC65 runtime: Scale the primary register
;
.export shrax1
shrax1: stx     tmp1
        lsr     tmp1
        ror     a
        ldx     tmp1
        rtl

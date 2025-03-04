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

.export incsp1
incsp1:	inc     sp
		bne     @L1
		inc     sp+1
@L1:	rtl

.export pusha0sp
.export pushaysp
.export pusha
pusha0sp:
        ldy     #$00
pushaysp:
        lda     (sp),y
pusha:  ldy     sp              ; (3)
        beq     @L1             ; (6)
        dec     sp              ; (11)
        ldy     #0              ; (13)
        sta     (sp),y          ; (19)
        rtl                     ; (25)

@L1:    dec     sp+1            ; (11)
        dec     sp              ; (16)
        sta     (sp),y          ; (22)
        rtl                     ; (28)

; Copyright (C) 2025 iProgramInCpp

.segment "CODE"

; Reads from the joy pad. Runs in the NMI.
.proc read_cont
	; TODO: If we are using a SNES Mouse, then we should disable auto
	; joypad-read and do the reading manually in the classic NES way.
	
	; Note: Counter to what you might expect, all the NES style buttons
	; are actually in JOYnH and not JOYnL.
	lda joy1h
	sta _joypad1
	lda joy1l
	sta _joypad1h
	
	lda joy2h
	sta _joypad2
	lda joy2l
	sta _joypad2h
	
	rts
.endproc

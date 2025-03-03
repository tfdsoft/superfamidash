; Copyright (C) 2025 iProgramInCpp

.segment "ZEROPAGE"

.export _joypad1
.export _joypad2
.export _joypad1h
.export _joypad2h
.exportzp _temp_ptr=PTR
.exportzp _temp_len=LEN
.exportzp _temp_nsp=NEXTSPR

tmp1:			.res 1
tmp2:			.res 1

RAND_SEED:		.res 4
TEMP: 			.res 11

nmi_counter:	.res 1
nmi_semaphore:  .res 1 ; set to positive if ready for NMI, negative if not
sprid:			.res 1

_joypad2:       .res 1
_joypad1:       .res 1
_joypad1h:		.res 1
_joypad2h:		.res 1

; defines based on the TEMP register
PAD_BUF		=TEMP+1

PTR			=TEMP	;word
LEN			=TEMP+2	;word
NEXTSPR		=TEMP+4
SCRX		=TEMP+5
SCRY		=TEMP+6
SRC			=TEMP+7	;word
DST			=TEMP+9	;word

SP_TEMP     =TEMP+7
CHRBANK_TEMP=TEMP+8

RLE_LOW		=TEMP
RLE_HIGH	=TEMP+1
RLE_TAG		=TEMP+2
RLE_BYTE	=TEMP+3

hdma_enable: .res 1 ; HDMA presence for each channel

.segment "HIGHRAM"

; scheduled HDMAs
scroll_x     : .res 2
scroll_y     : .res 2
scroll_x_bg2 : .res 2
scroll_y_bg2 : .res 2
hdma_dmap    : .res 8  ; DMAP values
hdma_bbad    : .res 8  ; BBAD values
hdma_dasb    : .res 8  ; DASB values
hdma_a1tl    : .res 8  ; A1TL values
hdma_a1th    : .res 8  ; A1TH values
hdma_a1b     : .res 8  ; A1B  values

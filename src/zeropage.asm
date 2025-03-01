; Copyright (C) 2025 iProgramInCpp

.segment "ZEROPAGE"

RAND_SEED:		.res 4
TEMP: 			.res 11


nmi_counter:	.res 1
sprid:			.res 1


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


; Copyright (C) 2025 iProgramInCpp

.p816
.smart
.feature string_escapes
.feature line_continuations

.segment "CODE"

; Custom routines implemented specifically for famidash (some are totally not stolen from famitower)
.importzp _gamemode
.importzp _tmp1, _tmp2, _tmp3, _tmp4, _tmp5, _tmp6, _tmp7, _tmp8, _tmp9, _temptemp5  ; C-safe temp storage
.importzp PTR
.import pusha, pushax, callptr4
.import _scroll_x, _cursedmusic

.define gamemode_count 9

.macro INCW addr
	INC addr
	BNE :+
		INC addr+1
:
.endmacro

.macro incw addr
	INCW addr
.endmacro


.segment "ZEROPAGE"
	rld_value:      	.res 1
	rld_run:        	.res 1

.segment "BSS"
	; column buffer, to be pushed to the collision map
	; 15 metatiles in the top 3 screens 
	; 12 metatiles in the bottom screen
	; 3 metatiles in the ground
	columnBuffer:		.res 15 + 15 + 15 + 12 + 3

	; variables related to the vertical seam / level height
	extceil:			.res 1
	rld_load_value:		.res 1
	min_scroll_y:		.res 2

	; variables related to both the above and below
	old_draw_scroll_y:	.res 2
	seam_scroll_y:		.res 2
	
	; variables related to draw_screen
	rld_column:			.res 1
	drawing_frame:		.res 1
	parallax_scroll_column: .res 1
	parallax_scroll_column_start: .res 1

	current_song_bank:	.res 1
	auto_fs_updates:	.res 1

	hexToDecOutputBuffer: .res 5
 

.export _extceil := extceil
.export _min_scroll_y := min_scroll_y
.export	_seam_scroll_y := seam_scroll_y
.export _old_draw_scroll_y := old_draw_scroll_y

.export _drawing_frame := drawing_frame
.export _parallax_scroll_column := parallax_scroll_column
.export _parallax_scroll_column_start := parallax_scroll_column_start

.export _auto_fs_updates := auto_fs_updates
.export _hexToDecOutputBuffer := hexToDecOutputBuffer

; .export _pad = PAD_STATEP
; .export _pad_new = PAD_STATET

; Standard for function declaration here:
; C function name
; .segment declaration
; [ <empty line>
; imports ]
; <empty line>
; .export declaration
; the function itself


; void __fastcall__ oam_meta_spr_flipped(uint8_t x,uint8_t y,const void *data);
.segment "CODE"

.export __oam_meta_spr_flipped
.proc __oam_meta_spr_flipped
	; AX = data
	; sreg[0] = x
	; sreg[1] = y
	; xargs[0] = flip
	sta <PTR
	stx <PTR+1

	
	
	
	rtl
.endproc


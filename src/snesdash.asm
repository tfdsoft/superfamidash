; Copyright (C) 2025 iProgramInCpp

.p816
.smart
.feature string_escapes
.feature line_continuations

.include "defines.asm"

.segment "CODE"

; Custom routines implemented specifically for famidash (some are totally not stolen from famitower)
.importzp _gamemode
.importzp _tmp1, _tmp2, _tmp3, _tmp4, _tmp5, _tmp6, _tmp7, _tmp8, _tmp9, _temptemp5  ; C-safe temp storage
.importzp PTR, LEN, NEXTSPR
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

.segment "RODATA"

.export _shiftBy4table := shiftBy4table
shiftBy4table:
	.byte $00, $10, $20, $30
	.byte $40, $50, $60, $70
	.byte $80, $90, $A0, $B0
	.byte $C0, $D0, $E0, $F0

.segment "CODE"
; __one_vram_buffer_repeat

.global _level_list_lo, _level_list_hi, _level_list_bank, _sprite_list_lo, _sprite_list_hi, _sprite_list_bank
.import _song, _speed, _lastgcolortype, _lastbgcolortype
.import _level_data_bank, _sprite_data_bank
.import _discomode

; _init_rld
; _unrle_next_column
; loadLevelContinuation
.import umul8x16r24m
; _dummy_unrle_columns
; writeToCollisionMap
.import _scroll_y
; get_seam_scroll_y
.global dsrt_fr1O : zp
; _draw_screen
; _draw_screen_R_tiles
; draw_screen_R_attributes
; draw_screen_UD_tiles_frame0
; draw_screen_UD_tiles_frame1
; _load_ground
; __draw_padded_text

.import _cube_movement, _ship_movement, _ball_movement, _ufo_movement, _robot_movement, _spider_movement, _wave_movement
.import _retro_mode

; _movement

.import _options, FIRST_MUSIC_BANK

; _music_play
; famistudio_dpcm_bank_callback
; _music_update

.import _activesprites_x_lo, _activesprites_x_hi
.import _activesprites_y_lo, _activesprites_y_hi
.import _activesprites_type, _activesprites_activated
.import _activesprites_realx, _activesprites_realy
; load_next_sprite
; _calculate_linear_scroll_y

.importzp _currplayer_y
.import _scroll_y

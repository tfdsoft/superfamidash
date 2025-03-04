
CODE_BANK_PUSH("BANK1")

extern char menu_graphics[];
extern char parallax_graphics[];
extern char parallax_data[];
extern const short splashMenu_[];
extern const short splashMenu2_[];
extern const short game_start_screenv2[];

void check_if_music_stopped();
void clear_shit();
void movement();
void bounds_check();
void title_cube_shit();
void title_robot_shit();
void title_mini_wave_shit();
void title_wave_shit();
void title_ufo_shit();
void title_ball_shit();
void title_swing_shit();
void title_ship_shit();
void refreshmenu();
void refreshmenu_part2();
void loop_routine_update();
void dec_mouse_timer();
void roll_new_mode();
void settings();
void set_title_icon();
void state_demo();
void mouse_and_cursor();
void colorinc();
void colordec();
void leveldec();
void levelinc();
void set_settings();
void start_the_level();

// .......


const uint8_t loNTAddrTableTitleScreen[]={
    LSB(NTADR_A(9, 11)),	// -1 = 4
    LSB(NTADR_A(15, 11)),	// 0
    LSB(NTADR_A(21, 11)),	// 1 
    LSB(NTADR_A(12, 17)),	// 2
    LSB(NTADR_A(18, 17)),	// 3
    LSB(NTADR_A(27, 1)),	// 4
    LSB(NTADR_A(9, 11)),	// 5 = 0
    LSB(NTADR_A(15, 11))	// 5 = 0
};

const uint8_t hiNTAddrTableTitleScreen[]={
    MSB(NTADR_A(9, 11)),	// -1 = 4
    MSB(NTADR_A(15, 11)),	// 0
    MSB(NTADR_A(21, 11)),	// 1
    MSB(NTADR_A(12, 17)),	// 2
    MSB(NTADR_A(18, 17)),	// 3
    MSB(NTADR_A(27, 1)),	// 4
    MSB(NTADR_A(9, 11)),	// 5 = 0
    MSB(NTADR_A(15, 11))	// 5 = 0
};

// ....

// HDMA table to scroll the ground around
// TODO: MOVE THIS INTO HIGH RAM!
#pragma bss-name(push, "HIGHRAM")
uint8_t menu_hdma_table[10];
#pragma bss-name(pop)

uint16_t bg_scroll_x;

void __longfn__ state_menu() {
	// ...
	
	
	
	ppu_off();

	if (all_levels_complete == 0xFC) pal_bg(splashMenu2_);
	else pal_bg (splashMenu_);
	
	newrand();
	
	vram_dma(menu_graphics,     TILE_SET,   8192);
	vram_dma(parallax_graphics, PARALL_SET, 288);
	set_bg_mode(1);
	set_bg12_chr_base(TILE_SET, PARALL_SET);
	set_bg_tilemap(1, NAMETABLE_A, 0, 0);
	set_bg_tilemap(2, NAMETABLE_P, 0, 0);
	
	set_scroll_x(0);
	set_scroll_y(0);
	set_scroll_x_bg2(0);
	set_scroll_y_bg2(0);
	
	set_title_icon();
	set_title_icon();
	
	
	kandowatchesyousleep = 0;

	//if (!NTSC_SYS) multi_vram_buffer_horz(palsystem, sizeof(palsystem)-1, NTADR_A(9,7));
	//mmc3_set_prg_bank_1(GET_BANK(state_menu));
	
	settingvalue = 0;
	practice_point_count = 0;
	
	USE_DB_HRAM1();
	
	menu_hdma_table[0] = 127;   // scanline count
	menu_hdma_table[1] = 0;     // scroll position
	menu_hdma_table[2] = 0;     // scroll position high
	menu_hdma_table[3] = 49;    // scanline count
	menu_hdma_table[4] = 0;     // scroll position
	menu_hdma_table[5] = 0;     // scroll position high
	menu_hdma_table[6] = 1;     // scanline count
	menu_hdma_table[7] = 0;     // scroll position
	menu_hdma_table[8] = 0;     // scroll position high
	menu_hdma_table[9] = 0;     // ending marker
	
	RESET_DB();
	
	set_hdma_n(7, DMAP_POAM, BG1HOFS, menu_hdma_table);
	

	menuMusicCurrentlyPlaying = 1;
	//invisible = 0;
	

	oam_clear();
	
	vram_dma(game_start_screenv2, NAMETABLE_A, 960*2);
	
	// load in parallax data
	vram_dma(parallax_data, NAMETABLE_P,        32*9*2);
	vram_dma(parallax_data, NAMETABLE_P+32*9,   32*9*2);
	vram_dma(parallax_data, NAMETABLE_P+32*18,  32*9*2);
	vram_dma(parallax_data, NAMETABLE_P+32*27,  32*3*2);
	
	//vram_adr(NAMETABLE_A);
	//vram_unrle(game_start_screen);
	//vram_adr(NAMETABLE_B);
	//vram_unrle(game_start_screen);
	
	set_scroll_x(0);
	
	speed = 1;
	enable_layers(T_BG1 | T_BG2);
	ppu_on_all();
	joypad1.press = 0;
	//pal_fade_to_withmusic(0, 4);
	//tmp4 = menuselection; ++tmp4;
	//tmp5 = loNTAddrTableTitleScreen[tmp4]|(hiNTAddrTableTitleScreen[tmp4]<<8);
	//one_vram_buffer('a', tmp5);
	//one_vram_buffer('b', addloNOC(tmp5, 1));
	roll_new_mode();
	kandoframecnt = 0;
	
	//speed = 2;
	
	// TODO
	while (!(joypad1.press & (PAD_START | PAD_A))){
		ppu_wait_nmi();
		bg_scroll_x++;
		
		USE_DB_HRAM1();
		menu_hdma_table[7] = (char) bg_scroll_x;
		RESET_DB();
		
		set_scroll_x_bg2(bg_scroll_x >> 1);
	}
}

// ...

void set_title_icon() {
		if (titlemode < 4) {
			while (tmp7 > 26) {
				tmp7 = newrand() & 31;
			}
			titleicon = tmp7;
			tmp7 = tmp7 * 2;
			tmp7 += 40;
			set_icon_bank(retro_mode ? 18 : tmp7);
		}
		else if ((titlemode <= 7 && titlemode != 6) || titlemode == 13 || titlemode == 10) {
			set_icon_bank(retro_mode == 0 ? 20 : 22);
		}
		else if ((titlemode <= 15 && titlemode != 13) || titlemode == 6) {
			set_icon_bank(retro_mode == 0 ? 24 : 26);
		}
}	

void roll_new_mode() {
	speed = (newrand() & 3); 
	if (speed == 0) speed = 1; 
	currplayer_gravity = GRAVITY_DOWN; 
	currplayer_x_small = 0x08; 
	currplayer_y_small = 0xA0;
	player_vel_y[0] = 0;
	tmpi8 = 0;
	teleport_output = 0XFF;
	tmp7 = titlemode;
	do {
		do {
			titlemode = newrand() & 15;
		} while (titlemode > 9);
	} while (titlemode == tmp7);
	if (titlemode >= 8) {
		titlemode = (newrand() & 7) + 8;
	}
	if (retro_mode && titlemode == 0) titlemode = tmp7;
	if (retro_mode && titlemode == 2) titlemode = tmp7;
//	titlemode = 11; //to test
	if (titlemode == 1 || titlemode == 3 || titlemode == 6 || titlemode == 9 || titlemode == 11 || titlemode == 12) {
		while (tmp1 > 0xA0 && tmp1 <= 0x20) {
			tmp1 = newrand() & 0xFF;
		}
		currplayer_y_small = tmp1;
	}
		
		
	ballframe = 0;
	oam_clear();
/*
	while (tmp1 >= 53) {
		tmp1 = newrand() & 63;
	}
	while (tmp2 >= 53) {
		tmp2 = newrand() & 63;
	}
	while (tmp3 >= 53) {
		tmp3 = newrand() & 63;
	}
*/
//	titlecolor1 = menu_color_table[tmp1];
//	titlecolor2 = menu_color_table[tmp2];   most of our colors suck
//	titlecolor3 = menu_color_table[tmp3];
	set_title_icon();
}			


CODE_BANK_POP()

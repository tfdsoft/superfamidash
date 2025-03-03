
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
uint8_t menu_hdma_table[10];
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
	
	//set_title_icon();
	//set_title_icon();
	
	
	kandowatchesyousleep = 0;
	
	settingvalue = 0;
	practice_point_count = 0;
	
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
	
	//speed = 2;
	
	// TODO
	while (!(joypad1.press & (PAD_START | PAD_A))){
		ppu_wait_nmi();
		bg_scroll_x++;
		
		menu_hdma_table[7] = (char) bg_scroll_x;
		
		set_scroll_x_bg2(bg_scroll_x >> 1);
	}
}


CODE_BANK_POP()

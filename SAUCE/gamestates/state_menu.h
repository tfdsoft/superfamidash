
CODE_BANK_PUSH("BANK1")

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

void state_menu() {
	// ...
	ppu_off();
	
	gamemode = 0;
	
	//set_title_icon();
	//set_title_icon();
	
	
	kandowatchesyousleep = 0;
	
	settingvalue = 0;
	practice_point_count = 0;
	
	//write_hdma_table(menu_hdma_table);
	////edit_hdma_table(2, low_byte(tmp8));
	//set_hdma_ptr(hdmaTable);
	//tmp8 = 0;
	

	menuMusicCurrentlyPlaying = 1;
	//invisible = 0;
	

	oam_clear();
	
	
	vram_adr(NAMETABLE_A);
	vram_unrle(game_start_screen);
	vram_adr(NAMETABLE_B);
	vram_unrle(game_start_screen);
	
	set_scroll_x(0);
	
	speed = 1;
	ppu_on_all();
	
	// TODO
	while (1) {
		ppu_wait_nmi();
	}
}


CODE_BANK_POP()

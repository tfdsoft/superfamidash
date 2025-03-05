
CODE_BANK_PUSH("BANK1")

extern char menu_graphics[];
extern char parallax_graphics[];
extern char parallax_data[];
extern const short splashMenu_[];
extern const short splashMenu2_[];
extern const short game_start_screenv2[];

extern void drawplayerone();

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

const uint8_t UFO_Title_Jump_Table[]={
	5,
	4,
	3,
	3,
	2,
	2,
	2,
	2,
	1,
	1,
	1,
	1,
	1,
	0,
	-1,
	-1,
	-1,
	-1,
	-1,
	-2,
	-2,
	-2,
	-2,
	-3,
	-3,
	-4,
	-5,
};

const uint8_t BALL_Title_Jump_Table[]={
	1,
	1,
	1,
	2,
	2,
	3,
	3,
	4,
};
	
// ...

// HDMA table to scroll the ground around
// TODO: MOVE THIS INTO HIGH RAM!
#pragma bss-name(push, "HIGHRAM")
uint8_t menu_hdma_table[10];
#pragma bss-name(pop)

uint16_t bg_scroll_x;

void __longfn__ state_menu() {
	// ...
	
	all_levels_complete = 0xFC;
	
	ppu_off();

	if (all_levels_complete == 0xFC) pal_bg(splashMenu2_);
	else pal_bg (splashMenu_);
	
	newrand();
	
	vram_dma(menu_graphics,     TILE_SET,   8192);
	vram_dma(parallax_graphics, PARALL_SET, 288);
	set_bg_mode(1);
	set_bg12_chr_base(TILE_SET, PARALL_SET);
	sprite_base(SPRITE_SET);
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
	enable_layers(T_BG1 | T_BG2 | T_OBJ);
	//ppu_on_all();
	joypad1.press = 0;
	//pal_fade_to_withmusic(0, 4);
	//tmp4 = menuselection; ++tmp4;
	//tmp5 = loNTAddrTableTitleScreen[tmp4]|(hiNTAddrTableTitleScreen[tmp4]<<8);
	//one_vram_buffer('a', tmp5);
	//one_vram_buffer('b', addloNOC(tmp5, 1));
	roll_new_mode();
	kandoframecnt = 0;
	teleport_output = 0Xff;
	currplayer_y_small = 160;
	currplayer_x_small = 0;
	if (all_levels_complete != 0xFC) {
		one_vram_buffer(0x01, NTADR_A(27,2));
		one_vram_buffer(0x02, NTADR_A(28,2));
		one_vram_buffer(0x03, NTADR_A(27,3));
		one_vram_buffer(0x04, NTADR_A(28,3));
	}
	else {
		one_vram_buffer(0x086F, NTADR_A(27,2));
		one_vram_buffer(0x0870, NTADR_A(28,2));
		one_vram_buffer(0x0871, NTADR_A(27,3));
		one_vram_buffer(0x0872, NTADR_A(28,3));
	}
	
	ppu_on_all();
	
	while (!(joypad1.press & (PAD_START | PAD_A))){

		//pal_col(0x11,titlecolor3);
		//pal_col(0x12,titlecolor1);
		//pal_col(0x13,titlecolor2);
		//pal_set_update();
		
		loop_routine_update();
		 // read the first controller

		newrand();
		newrand();
		newrand();
		if (titlemode != 0xFF) currplayer_x_small += speed;
		if (currplayer_x_small >= 0xFB) { 
			roll_new_mode();		
		}
		//temp values:
		//teleport_output
		//currplayer_gravity
		//tmp2 tmp7
		//tmpi8



		if (currplayer_x_small <= 0xF7) {
			switch (titlemode) {
				case 0:		//cube
					//oam_spr(currplayer_x_small, currplayer_y_small, 1, 0x20);
					//oam_spr(currplayer_x_small + 8, currplayer_y_small, 3, 0x20);
					title_cube_shit();

					high_byte(player_x[0]) = currplayer_x_small;
					high_byte(player_y[0]) = currplayer_y_small;
					//crossPRGBankJump0(drawplayerone);
					break;
				case 1:		//UFO
					title_ufo_shit();
					
					oam_spr(currplayer_x_small, currplayer_y_small, 0x3F, 0x20);
					oam_spr(currplayer_x_small + 8, currplayer_y_small, 0x3F, 0x60);
					break;
				case 2:		//mini cube
					title_cube_shit();
					mini[0] = 1;
					high_byte(player_x[0]) = currplayer_x_small;
					high_byte(player_y[0]) = currplayer_y_small;
					//crossPRGBankJump0(drawplayerone);
					mini[0] = 0;
					break;
				case 3:		//ship
					title_ship_shit();

					switch (tmpi8) {
						case 0:
							tmp7 = 0x29;
							break;
						case 1:
							tmp7 = 0x2D;
							break;
						case 2:
						case 3:
							tmp7 = 0x31;
							break;
						case -1:
							tmp7 = 0x25;
							break;
						case -2:
						case -3:
							tmp7 = 0x21;
							break;

					};
						if (currplayer_y_small == 160 && tmp7 < 0x29) tmp7 = 0x29;
						else if (currplayer_y_small == 8 && tmp7 > 0x29) tmp7 = 0x29;
						
					oam_spr(currplayer_x_small, currplayer_y_small, tmp7, 0x20);
					oam_spr(currplayer_x_small + 8, currplayer_y_small, tmp7 + 2, 0x20);
					break;
				case 4:		//robot

					title_robot_shit();
					
					if (!(kandoframecnt & 0x07)) ballframe += ballframe == 3 ? -3 : 1;
					if (currplayer_y_small == 160) {
						if (!retro_mode) {
							switch (ballframe) {
								case 0:
									tmp1 = 0x01;
									tmp2 = 0x03;
									tmp3 = 0x05;
									break;
								case 1:
									tmp1 = 0xFF;
									tmp2 = 0x07;
									tmp3 = 0x09;
									break;
								case 2:
									tmp1 = 0x01;
									tmp2 = 0x0B;
									tmp3 = 0x05;
									break;
								case 3:
									tmp1 = 0xFF;
									tmp2 = 0x0D;
									tmp3 = 0x09;
									break;	
							};
						}
						else {
							switch (ballframe) {
								case 0:
									tmp1 = 0xFF;
									tmp2 = 0x01;
									tmp3 = 0x03;
									break;
								case 1:
									tmp1 = 0xFF;
									tmp2 = 0x07;
									tmp3 = 0x09;
									break;
								case 2:
									tmp1 = 0xFF;
									tmp2 = 0x0B;
									tmp3 = 0x0D;
									break;
								case 3:
									tmp1 = 0xFF;
									tmp2 = 0x11;
									tmp3 = 0x13;
									break;	
							};
						}						
					}
					else {
						tmp1 = 0xFF;
						if (!retro_mode) {
							tmp2 = 0x0F;
							tmp3 = 0x11;
						}
						else {
							tmp2 = 0x11;
							tmp3 = 0x13;							
						}
					}
					oam_spr(currplayer_x_small-8, currplayer_y_small, tmp1, 0x20);
					oam_spr(currplayer_x_small, currplayer_y_small, tmp2, 0x20);					
					oam_spr(currplayer_x_small + 8, currplayer_y_small, tmp3, 0x20);					
					break;
				case 5:		//spider
//					if (kandoframecnt & 1) {
//						if (!(newrand() & 31)) 	invert_gravity(currplayer_gravity);
//					}

					//if (!currplayer_gravity) { 
					currplayer_y_small = 160; tmp7 = 0x20; 
					//}
//					else { currplayer_y_small = 8; tmp7 = 0xA0; }

					if (!(kandoframecnt & 0x07)) ballframe += ballframe == 3 ? -3 : 1;
					switch (ballframe) {
						case 0:
							tmp1 = 0x21;
							tmp2 = 0x23;
							tmp3 = 0x25;
							break;
						case 1:
							tmp1 = 0x27;
							tmp2 = 0x29;
							tmp3 = 0x2B;
							break;
						case 2:
							tmp1 = 0x2D;
							tmp2 = 0x2F;
							tmp3 = 0x31;
							break;
						case 3:
							tmp1 = 0xFF;
							tmp2 = 0x33;
							tmp3 = 0x35;
							break;	
					}
					oam_spr(currplayer_x_small - 8, currplayer_y_small, tmp1, tmp7);
					oam_spr(currplayer_x_small, currplayer_y_small, tmp2, tmp7);					
					oam_spr(currplayer_x_small + 8, currplayer_y_small, tmp3, tmp7);					
					break;				
				case 6:		//wave
					title_wave_shit();
					
					if (currplayer_y_small == 160 || currplayer_y_small == 8) {
						tmp1 = 0x29;
						tmp2 = 0x20;
					}
					else if (currplayer_gravity) {
						tmp1 = 0x2D;
						tmp2 = 0xA0;
					}
					else {
						tmp1 = 0x2D;
						tmp2 = 0x20;
					}
					oam_spr(currplayer_x_small, currplayer_y_small, tmp1, tmp2);
					oam_spr(currplayer_x_small + 8, currplayer_y_small, tmp1 + 2, tmp2);
					break;				
				case 7:		//ball
					title_ball_shit();
					
					if (!(kandoframecnt & 0x07)) ballframe ^= 1;

					if (retro_mode && currplayer_gravity) tmp7 = 0xA0;
					else tmp7 = 0x20;

					if (ballframe) tmp2 = 0x3F;
					else tmp2 = 0x1B;						

					oam_spr(currplayer_x_small, currplayer_y_small, tmp2, tmp7);
					oam_spr(currplayer_x_small + 8, currplayer_y_small, tmp2, tmp7 + 0x40);

					break;
				case 8:		//swing
					title_swing_shit();


					if (!(kandoframecnt & 0x07)) ballframe += ballframe == 3 ? -3 : 1;
					switch (ballframe) {
						case 0:
							tmp2 = 0x31;
							tmp7 = 0x20;
							break;
						case 1:
							tmp2 = 0x35;
							tmp7 = 0x20;
							break;
						case 2:
							tmp2 = 0x31;
							tmp7 = 0x20;
						case 3:
							tmp2 = 0x35;
							tmp7 = 0xA0;
							break;	
					};
					oam_spr(currplayer_x_small, currplayer_y_small, tmp2, tmp7);					
					oam_spr(currplayer_x_small + 8, currplayer_y_small, tmp2+2, tmp7);					
					break;
				case 9:		//mini ship
					title_ship_shit();

					switch (tmpi8) {
						case 0:
							tmp7 = 0x05;
							break;
						case 1:
							tmp7 = 0x07;
							break;
						case 2:
						case 3:
							tmp7 = 0x09;
							break;
						case -1:
							tmp7 = 0x03;
							break;
						case -2:
						case -3:
							tmp7 = 0x01;
							break;

					};
					if (currplayer_y_small == 160 && tmp7 < 0x05) tmp7 = 0x05;
					else if (currplayer_y_small == 8 && tmp7 > 0x05) tmp7 = 0x05;					

					oam_spr(currplayer_x_small, currplayer_y_small, tmp7, 0x20);

					break;	
				case 10:		//mini ball
					title_ball_shit();
					if (retro_mode && currplayer_gravity) tmp7 = 0xA0;
					else tmp7 = 0x20;					
					oam_spr(currplayer_x_small, currplayer_y_small, 0x3D, tmp7);
					break;	
				case 11:		//mini wave
					title_mini_wave_shit();
					
					if (currplayer_y_small == 160 || currplayer_y_small == 8) {
						tmp1 = 0x0D;
						tmp2 = 0x20;
						oam_spr(currplayer_x_small, currplayer_y_small, 0x0D, 0x20);
					}
					else if (currplayer_gravity) {
						tmp1 = 0x11;
						tmp2 = 0xA0;
					}
					else {
						tmp1 = 0x11;
						tmp2 = 0x20;
					}
					oam_spr(currplayer_x_small, currplayer_y_small, tmp1, tmp2);
					break;	
				case 12:		//mini ufo
					title_ufo_shit();
					
					oam_spr(currplayer_x_small, currplayer_y_small, 0x19, 0x20);
					break;		
				case 13:		//mini robot
					
					title_robot_shit();

					if (!(kandoframecnt & 0x07)) ballframe += ballframe == 2 ? -2 : 1;

					tmp2 = 0x37 + (ballframe * 2);

					oam_spr(currplayer_x_small, currplayer_y_small, tmp2, 0x20);
					break;

				case 14:		//mini spider
				/*
					if (kandoframecnt & 1) {
						if (!(newrand() & 31)) 	invert_gravity(currplayer_gravity);
					}

					if (!currplayer_gravity) { 
					*/
					currplayer_y_small = 160; tmp7 = 0x20; 
					//}
					//else { currplayer_y_small = 8; tmp7 = 0xA0; }

					
					if (!(kandoframecnt & 0x07)) ballframe += ballframe == 3 ? -3 : 1;
					switch (ballframe) {
						case 0:				
							tmp2 = 0x21;
							break;
						case 1:				
							tmp2 = 0x23;
							break;
						case 2:				
							tmp2 = 0x25;
							break;
						case 3:				
							tmp2 = 0x27;
							break;
					};
					oam_spr(currplayer_x_small, currplayer_y_small, tmp2, tmp7);
					break;
				case 15:		//mini swing

					title_swing_shit();

					if (!(kandoframecnt & 0x07)) ballframe += ballframe == 3 ? -3 : 1;
					switch (ballframe) {
						case 0:	
							tmp7 = 0x3F;
							break;
						case 1:				
							tmp7 = 0x1B;
							break;
						case 2:				
							tmp7 = 0x3F;
							break;
						case 3:				
							tmp7 = 0x3D;
							break;
					};	
					oam_spr(currplayer_x_small, currplayer_y_small, tmp7, 0x20);
					break;
				case 0xFF:
					if (!(kandoframecnt & 0x07)) ballframe += ballframe == 5 ? -5 : 1;
					switch (ballframe) {
						case 0:
							tmp7 = 0x1D;
							break;
						case 1:
							tmp7 = 0x7D;
							break;
						case 2:
							tmp7 = 0x1F;
							break;
						case 3:
							tmp7 = 0x7F;
							break;	
						case 4:
							tmp7 = 0xFF;
							break;	
						case 5:
							roll_new_mode();
							break;
					};
					if (ballframe != 5) {
						oam_spr(currplayer_x_small, currplayer_y_small, tmp7, 0x20);
						oam_spr(currplayer_x_small + 8, currplayer_y_small, tmp7, 0xE0);	
					}
					break;					
			};
		}
		
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

void loop_routine_update() {
	newrand();
	ppu_wait_nmi();
	//music_update();
	oam_clear();
	//mouse_and_cursor();
}			


void bounds_check() {
	if (currplayer_y_small >= 160) {
		currplayer_y_small = 160;
	}		
	else if (currplayer_y_small < 0x08) currplayer_y_small = 0x08;	
}	
void title_ship_shit() {
	if (kandoframecnt & 1) { if (!(newrand() & 7)) invert_gravity(currplayer_gravity); }

	currplayer_y_small -= tmpi8;

	if (currplayer_y_small >= 160) {
		currplayer_y_small = 160;
	}		
	else if (currplayer_y_small < 0x08) { 
		currplayer_y_small = 0x08; 
		currplayer_gravity = GRAVITY_DOWN;
		tmpi8 = 0;
	}					


	if (currplayer_gravity) {
		if (!(kandoframecnt & 7)) { if (tmpi8 < 3) tmpi8++; }
	}

	else {
		
		if (!(kandoframecnt & 7)) { if (tmpi8 > -3) tmpi8--; }
	}
}					

void title_swing_shit() {
	if (kandoframecnt & 1) { 
		if (!(newrand() & 15)) {
			invert_gravity(currplayer_gravity); 
		}
	}

	if ((kandoframecnt & 3) == 0)
			if (currplayer_gravity) {
				currplayer_vel_y_small -= 1;
				if (currplayer_vel_y_small <= -3) currplayer_vel_y_small = -3;
			} else {
				currplayer_vel_y_small += 1;
				if (currplayer_vel_y_small >= 3) currplayer_vel_y_small = 3;
			}

			
	currplayer_y_small += currplayer_vel_y_small;

	bounds_check();
}

void title_ball_shit() {
/*
	USE_DB_PRGBANK();
	if (kandoframecnt & 1 && (currplayer_y_small == 0x08 || currplayer_y_small == 0xA0)) { 
		if (!(newrand() & 31)) {
			if (currplayer_y_small == 0x08) { currplayer_gravity = GRAVITY_UP; teleport_output = 0; }
			else { currplayer_gravity = GRAVITY_DOWN; teleport_output = 0; }
		}
	}

	if (currplayer_gravity) { 
		currplayer_y_small += BALL_Title_Jump_Table[teleport_output];
		if (teleport_output < 7) teleport_output++;
	}

	else { 
		currplayer_y_small -= BALL_Title_Jump_Table[teleport_output];
		if (teleport_output < 7) teleport_output++;
	}
*/
	bounds_check();
}

void title_ufo_shit() {
	USE_DB_PRGBANK();
	if (teleport_output <= 0x1A) {
		currplayer_y_small -= UFO_Title_Jump_Table[teleport_output];		//hop hop
		teleport_output++;
	}
	else currplayer_y_small += 4;
	if (!(newrand() & 15)) teleport_output = 0;
	
	if (currplayer_y_small >= 160) {
		currplayer_y_small = 160;
	}		
	else if (currplayer_y_small < 0x08) { currplayer_y_small = 0x08; teleport_output = 0x0E; }
}	
void title_cube_shit() {
	USE_DB_PRGBANK();
	if (teleport_output <= 0x1A) {
		currplayer_y_small -= UFO_Title_Jump_Table[teleport_output];		//hop hop
		teleport_output++;
	}
	else currplayer_y_small += 4;

	if (currplayer_y_small >= (titlemode == 0 ? 160 : 164)) {
		currplayer_y_small = titlemode == 0 ? 160 : 164;
		player_vel_y[0] = 0;
	}		
	
	if (currplayer_y_small == (titlemode == 0 ? 160 : 164) && !(newrand() & 15)) { 
		teleport_output = 0;
		player_vel_y[0] = 1;
	}
	
	else if (currplayer_y_small < 0x08) { currplayer_y_small = 0x08; teleport_output = 0x0E; }
}					

void title_wave_shit() {
	tmp2 = newrand() & 63;
	if (kandoframecnt & 1) { if (tmp2 >= 60) invert_gravity(currplayer_gravity); }
		
	if (currplayer_gravity) currplayer_y_small -= speed;

	else currplayer_y_small += speed;
	bounds_check();
}
void title_mini_wave_shit() {
	tmp2 = newrand() & 63;
	if (kandoframecnt & 1) { if (tmp2 >= 60) invert_gravity(currplayer_gravity); }
		
	if (currplayer_gravity) currplayer_y_small -= (speed << 1);

	else currplayer_y_small += (speed << 1);
	bounds_check();
}

void title_robot_shit() {
	if (kandoframecnt & 1 && !currplayer_gravity) {
		if (!(newrand() & 15)) { tmpi8 = newrand() & 15; currplayer_gravity = GRAVITY_UP; teleport_output = 0; }
	}

	USE_DB_PRGBANK();
	if (currplayer_gravity) {
		if (teleport_output < 0x0C) { currplayer_y_small -= UFO_Title_Jump_Table[teleport_output]; teleport_output++; }
		if (teleport_output == 0x0C && tmpi8 > 0) { currplayer_y_small -= UFO_Title_Jump_Table[teleport_output]; tmpi8--; }
		else { currplayer_y_small -= UFO_Title_Jump_Table[teleport_output]; teleport_output++; if (teleport_output > 0x1A) teleport_output = 0x1A; }
		if (currplayer_y_small >= 160) { currplayer_gravity = GRAVITY_DOWN; tmpi8 = 0; teleport_output = 0; currplayer_y_small = 160; }
	}
					
}


CODE_BANK_POP()

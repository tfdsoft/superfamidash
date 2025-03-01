// THE GAME LOOP ==============================================
//
// yup, this is the entire game loop. it's that simple.
// I wanted to make the code super easy to read, so I split it
// into dozens of files, each containing segments of code.
//
// ============================================================



// THE INCLUDE FILE ===========================================
//
// The entirety of the project is on the shoulders of this
// singular line. 
//
//                    DO. NOT. REMOVE. IT.
//
// If you have issues with the repository and the cause is you
// removing this line, the entire team will be informed to not
// communicate with you further.
#include "include.h"
// ============================================================



// VOID MAIN() ================================================
//
// This isn't an int main() because i don't use the terminal to
// debug lmao
void main(){
	ppu_off();
	

	// needed for cc65 to export the label for mesen
    gameState = 0x01;
	
	// These are done at init time
    // level = 0x00;
	// auto_fs_updates = 0;

	//mmc3_set_prg_bank_1(GET_BANK(playPCM));
	//playPCM(0);


	
	//gameState = 0x05;
	while (1){
		ppu_wait_nmi();
		switch (gameState){
			case 0x01: {
				//mmc3_set_prg_bank_1(GET_BANK(state_menu));
				if (!kandowatchesyousleep) ;//state_menu();
				else {
					//pal_fade_to_withmusic(4,0);
					//ppu_off();
					//pal_bg(splashMenu);
					//kandowatchesyousleep = 1;

					//
					//practice_point_count = 0;
					//#include "defines/mainmenu_charmap.h"
					//levelselection();
				}
				break;
			}
			case 0x02: {
				//state_game();
				//use_auto_chrswitch = 0;
				break;
			}
			case 0x03: {
				//mmc3_set_prg_bank_1(GET_BANK(state_lvldone));
				//state_lvldone();
				break;
			}
			case 0x04: {
				//mmc3_set_prg_bank_1(GET_BANK(bgmtest));
				//bgmtest();
				break;
			}
			case 0x05: {
				//music_play(song_scheming_weasel);
				//mmc3_set_prg_bank_1(GET_BANK(state_savefile_validate));
				//state_savefile_validate();
				break;
			}
			case 0x06: {
				//mmc3_set_prg_bank_1(GET_BANK(state_savefile_editor));
				//state_savefile_editor();
				break;
			}


			case 0xF0: {
				//mmc3_set_prg_bank_1(GET_BANK(funsettings));
				//funsettings();
				break;
			}
			case 0xF1: {
				//mmc3_set_prg_bank_1(GET_BANK(state_instructions));
				//state_instructions();
				break;
			}
			case 0xFE: {
				//mmc3_set_prg_bank_1(GET_BANK(state_exit));
				//state_exit();
				break;
			}
			default: {
				//mmc3_set_prg_bank_1(GET_BANK(state_demo));
				//state_demo();
				break;
			}
		}
    }
}
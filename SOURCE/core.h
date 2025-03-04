
// sets icon bank
extern char icon_banks[];
void SNESCALL XXXXset_icon_bank(uint8_t bank)
{
	temp_nsp = GET_BANKBYTE(icon_banks);
	temp_ptr = SPRITE_SET;
	
	// each bank is 2048 bytes, so shift by 10 and add to the bank number
	bank <<= 2;
	((uint8_t*)&temp_ptr)[1] += bank;
	
	temp_len = 2048;
	
	_vram_dma(icon_banks);
}

#define set_icon_bank(bankN)  XXXXset_icon_bank((bankN) - 18)


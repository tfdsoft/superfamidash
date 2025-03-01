#ifndef _Sneslib_h
#define _Sneslib_h

// VRAM layout:
// (these are byte addresses.  vram_adr() takes word level addresses.)
// 0x0000 - Nametable A (Upper Left)
// 0x1000 - Nametable B (Upper Right)
// 0x2000 - Nametable C (Lower Left)
// 0x3000 - Nametable D (Lower Right)
// 0x4000 - Parallax Background Nametable
// 0xC000 - Tile Sets
#define NAMETABLE_A  0x0000
#define NAMETABLE_B  0x0800
#define NAMETABLE_C  0x1000
#define NAMETABLE_D  0x1800
#define NAMETABLE_P  0x2000
#define TILE_SET     0x6000


void __fastcall__ ppu_off(void);
void __fastcall__ ppu_on_all(void);
void __fastcall__ ppu_wait_nmi(void);

//clear OAM buffer, all the sprites are hidden
// Note: changed. Now also changes sprid (index to buffer) to zero

void __fastcall__ oam_clear(void);

//set vram pointer to write operations if you need to write some data to vram

void __fastcall__ vram_adr(uintptr_t adr);

//unpack RLE data to current address of vram, mostly used for nametables

void __fastcall__ vram_unrle(const void* data);

uint8_t __fastcall__ newrand(void);


void __fastcall__ set_scroll_x(uint16_t x);
// x can be in the range 0-0x1ff, but any value would be fine, it discards higher bits

#endif//_Sneslib_h

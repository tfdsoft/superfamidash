#ifndef _Sneslib_h
#define _Sneslib_h

// __longfn__ requires my special dialect of cc65: https://github.com/iProgramMC/cc65
#define SNESCALL __fastcall__ __longfn__

// VRAM layout:
// (these are word addresses.  vram_adr() takes word level addresses.)
// 0x0000 - Nametable A (Upper Left)
// 0x1000 - Nametable B (Upper Right)
// 0x2000 - Nametable C (Lower Left)
// 0x3000 - Nametable D (Lower Right)
// 0x4000 - Parallax Background Nametable
// 0x8000 - Sprite Sets
// 0xE000 - Tile Sets
#define NAMETABLE_A  0x0000
#define NAMETABLE_B  0x0400
#define NAMETABLE_C  0x0800
#define NAMETABLE_D  0x0C00
#define NAMETABLE_P  0x1000 // parallax tile map
#define SPRITE_SET   0x4000
#define TILE_SET     0x7000

// Some register defines
#define BGMODE   0x2105
#define BG12NBA  0x210B
#define BG34NBA  0x210C
#define BGSC(n) (0x2107+(n))
#define INIDISP  0x2100
#define TM       0x212C
#define TS       0x212D

// Register Values
// inidisp
#define INIDISP_OFF  0x8F
#define INIDISP_ON   0x0F
// tm/ts/tmw/tsw
#define T_BG1 0x01
#define T_BG2 0x02
#define T_BG3 0x04
#define T_BG4 0x08
#define T_OBJ 0x10

#define POKE(addr, val)    (*(uint8_t*) (addr) = (val))
#define PEEK(addr)         (*(uint8_t*) (addr))

extern uintptr_t temp_ptr;
extern uintptr_t temp_len;
extern uint8_t   temp_nsp;
#pragma zpsym("temp_ptr")
#pragma zpsym("temp_len")
#pragma zpsym("temp_nsp")

void SNESCALL ppu_off(void);
void SNESCALL ppu_on_all(void);
void SNESCALL ppu_wait_nmi(void);

//clear OAM buffer, all the sprites are hidden
// Note: changed. Now also changes sprid (index to buffer) to zero

void SNESCALL oam_clear(void);

//set vram pointer to write operations if you need to write some data to vram

void SNESCALL vram_adr(uintptr_t adr);

//unpack RLE data (from current program bank) to current address of vram, mostly used for nametables

void SNESCALL vram_unrle(const void* data);

uint8_t SNESCALL newrand(void);

void SNESCALL set_scroll_x(uint16_t x);
// x can be in the range 0-0x1ff, but any value would be fine, it discards higher bits

void SNESCALL set_scroll_y(uint16_t y);
// y can be in the range 0-0x1ff, but any value would be fine, it discards higher bits

//set bg and spr palettes, data is 512 bytes array (from current program bank)
void SNESCALL _pal_all(const void *data);
#define pal_all(label) do {     \
	temp_nsp = GET_BANK(label); \
	_pal_all(label);            \
} while (0)

//set bg palette only, data is 256 bytes array (from current program bank)
void SNESCALL _pal_bg(const void *data);
#define pal_bg(label) do {     \
	temp_nsp = GET_BANK(label); \
	_pal_bg(label);             \
} while (0)

//set spr palette only, data is 256 bytes array (from current program bank)
void SNESCALL _pal_spr(const void *data);
#define pal_spr(label) do {     \
	temp_nsp = GET_BANK(label); \
	_pal_spr(label);            \
} while (0)

//transfer 8KB of DMA
void SNESCALL _vram_dma(const void *datanear);
#define vram_dma(label, address, size) do { \
	temp_ptr = address;                     \
	temp_len = size;                        \
	temp_nsp = GET_BANKBYTE(label);         \
	_vram_dma(label);                       \
} while (0)

// set background layer tile set base addresses
#define __bgbaseaddress(bgba) ((bgba) >> 12) // bgba is a word address

#define set_bg12_chr_base(bg1ba, bg2ba) POKE(BG12NBA, (__bgbaseaddress(bg2ba) << 4) | __bgbaseaddress(bg1ba))
#define set_bg34_chr_base(bg3ba, bg4ba) POKE(BG34NBA, (__bgbaseaddress(bg4ba) << 4) | __bgbaseaddress(bg3ba))

#define enable_layers(t) POKE(TM, t)

#define display_on() POKE(INIDISP, INIDISP_ON)
#define display_off() POKE(INIDISP, INIDISP_OFF)

// set background mode
#define set_bg_mode(mode) POKE(BGMODE, mode)

struct pad {
    union {
        unsigned char hold;
        struct {
            unsigned char right : 1;
            unsigned char left : 1;
            unsigned char down : 1;
            unsigned char up : 1;
            unsigned char start : 1;
            unsigned char select : 1;
            unsigned char b : 1;
            unsigned char a : 1;
        };
    };
    union {
        unsigned char press;
        struct {
            unsigned char press_right : 1;
            unsigned char press_left : 1;
            unsigned char press_down : 1;
            unsigned char press_up : 1;
            unsigned char press_start : 1;
            unsigned char press_select : 1;
            unsigned char press_b : 1;
            unsigned char press_a : 1;
        };
    };
    union {
        unsigned char release;
        struct {
            unsigned char release_right : 1;
            unsigned char release_left : 1;
            unsigned char release_down : 1;
            unsigned char release_up : 1;
            unsigned char release_start : 1;
            unsigned char release_select : 1;
            unsigned char release_b : 1;
            unsigned char release_a : 1;
        };
    };
};


extern struct pad joypad1;
#pragma zpsym("joypad1");

extern struct pad joypad2;
#pragma zpsym("joypad2");

// extended joypad registers, since 
extern u8 joypad1h;
#pragma zpsym("joypad1h");
extern u8 joypad2h;
#pragma zpsym("joypad2h");

// WARNING: due to space saving reasons, joypad2 comes before joypad1 in ram
// This means that if you want to access by value, then index 0 is pad 2 and
// index 1 is pad 1.
// Note that if the mouse is connected in slot 2, then use the `mouse` struct
// to access the data instead.
extern struct pad* controllingplayer;
#pragma zpsym("controllingplayer");

#define PAD_A			0x80
#define PAD_B			0x40
#define PAD_SELECT		0x20
#define PAD_START		0x10
#define PAD_UP			0x08
#define PAD_DOWN		0x04
#define PAD_LEFT		0x02
#define PAD_RIGHT		0x01

#define OAM_FLIP_V		0x80
#define OAM_FLIP_H		0x40

#define MAX(x1,x2)		((x1)<(x2)?(x2):(x1))
#define MIN(x1,x2)		((x1)<(x2)?(x1):(x2))

#define MASK_SPR		0x10
#define MASK_BG			0x08
#define MASK_EDGE_SPR	0x04
#define MASK_EDGE_BG	0x02

#endif//_Sneslib_h

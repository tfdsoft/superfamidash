#ifndef _Snesdash_h
#define _Snesdash_h

// Custom functions and macros implemented specifically for famidash

// replacements for C stack
extern uint8_t xargs[4];
#pragma zpsym("xargs")
#define wxargs ((uint16_t * const)xargs)
#define pxargs ((const void ** const)xargs)

#define storeWordToSreg(word) (__AX__ = word, __EAX__<<=16)
#define storeBytesToSreg(a, b) (__AX__ = (byte(b)<<8)|byte(a), __EAX__<<=16)
#define storeByteToSreg(byte) (__A__ = byte, __asm__("sta sreg+0"))

/**
 * @brief Converts a number from scroll_y pixels to linear pixels.
 *
 * @param nonlinearScroll The number in scroll_y pixels to convert.
 *
 * @retval The number in linear pixels.
 */
uint16_t calculate_linear_scroll_y(uint16_t nonlinearScroll);

/**
 * @brief Convert a 16-bit number to 5 decimal digits.
 *
 * @param input The number to convert to decimal.
 *
 * @retval Returns the result @c hexToDecOutputBuffer, and the lowest 2 bytes are also in @c __AX__.
 */
uint16_t __fastcall__ hexToDec (uint16_t input);

/**
 * @brief Convert a 16-bit number to decimal and print it to the VRAM buffer.
 *
 * @param value The value to print.
 * @param digits The amount of digits to print - values 1..5 are valid.
 * @param zeroChr The '0' character in the current context - will add the numbers to it.
 * @param spaceChr The ' ' character in the current context - will be printed for the leftmost unused digits.
 * @param ppu_address The VRAM address of the leftmost digit.
 */
#define printDecimal(value, digits, zeroChr, spaceChr, ppu_address) (storeWordToSreg(value), xargs[0] = digits, xargs[1] = zeroChr, xargs[2] = spaceChr, __AX__ = ppu_address|(NT_UPD_HORZ<<8), _printDecimal(__EAX__))
void _printDecimal (uint32_t args);

/**
 * @brief Update the level completeness percentages
 *
 * @note Automatically accounts for the current level number
 */
void update_level_completeness();

/**
 * @brief Increment the attempt counter
 */
void increment_attempt_count();
/**
 * @brief Display the attempt counter (right-aligned, variable size)
 *
 * @param zeroChr The character ID to add to get tiles 0..9
 * @param ppu_address The PPU address of the *rightmost* digit
 */
#define display_attempt_counter(zeroChr, ppu_address) (storeByteToSreg(zeroChr), __AX__ = ppu_address, _display_attempt_counter(__EAX__))
void _display_attempt_counter (uint32_t args);

#define low_word(a) *((uint16_t*)&a)
#define high_word(a) *((uint16_t*)&a+1)

#define GET_BANK(sym) (__asm__("ldx #0\nlda #<.bank(%v)", sym), __A__)
#define GET_BANKBYTE(sym) (__asm__("ldx #0\nlda #<.bankbyte(%v)", sym), __A__)

#define uint32_inc(long) (__asm__("inc %v+0 \n bne %s", long, __LINE__), __asm__("inc %v+1 \n bne %s", long, __LINE__), __asm__("inc %v+2 \n bne %s", long, __LINE__), __asm__("inc %v+3 \n  %s:", long, __LINE__))

// store a word's high and low bytes into separate places
#define storeWordSeparately(word, low, high) \
                            (__AX__ = word, \
                            __asm__("STA %v", low), \
                            __asm__("STX %v", high))

extern uint8_t auto_fs_updates;
#define pal_fade_to_withmusic(from, to) (++auto_fs_updates, pal_fade_to(from, to), auto_fs_updates = 0)

// Uses the neslib table
// Normal shade is 4, range is 0..8
//#define colBrightness(color, brightness) (__A__ = color, __asm__("tay"), __asm__("lda palBrightTable%s, y", brightness), __A__)
//#define oneShadeDarker(color) colBrightness(color, 3)

#define DO_PRAGMA_(x) _Pragma (#x)
#define DO_PRAGMA(x) DO_PRAGMA_(x)

#define CODE_BANK_PUSH(bank) \
  DO_PRAGMA(code-name(push, bank ))\
  DO_PRAGMA(data-name(push, bank ))\
  DO_PRAGMA(rodata-name(push, bank ))


#define CODE_BANK_POP() \
  DO_PRAGMA(code-name(pop))\
  DO_PRAGMA(data-name(pop))\
  DO_PRAGMA(rodata-name(pop))


#define swapbyte(a, b) do { \
  __A__ = (a); \
  __asm__("pha"); \
  (a) = (b); \
  __asm__("pla"); \
  (b) = __A__; \
} while(0);

//void state_sorrynothing();

// For more than 16 bits use extra macros and shit
// Naming convention: crossPRGBankJump<bitsIn>
#define crossPRGBankJump0(sym) (__asm__("lda #<%v \n ldx #>%v \n ldy #<.bank(%v) \n jsr crossPRGBankJump ", sym, sym, sym), __asm__("lda ptr3 \n ldx ptr3+1"), __AX__)
#define crossPRGBankJump8(sym, args) (__A__ = args, __asm__("sta ptr3 "), crossPRGBankJump0(sym))
#define crossPRGBankJump16(sym, args) (__AX__ = args, __asm__("sta ptr3 \n stx ptr3+1"),crossPRGBankJump0(sym))

// holy fuck i am a genius
#define do_if_flag_common(func, opcode) do { \
__asm__("j" opcode " %s", __LINE__); \
do func while(0); \
 __asm__("%s:", __LINE__); \
} while(0)

#define do_if_c_set(func) do_if_flag_common(func, "cc")
#define do_if_c_clr(func) do_if_flag_common(func, "cs")
#define do_if_z_set(func) do_if_flag_common(func, "ne")
#define do_if_z_clr(func) do_if_flag_common(func, "eq")
#define do_if_v_set(func) do_if_flag_common(func, "vc")
#define do_if_v_clr(func) do_if_flag_common(func, "vs")
#define do_if_n_set(func) do_if_flag_common(func, "pl")
#define do_if_n_clr(func) do_if_flag_common(func, "mi")

// aliases
#define do_if_equal(func) do_if_z_set(func)
#define do_if_zero(func) do_if_z_set(func)
#define do_if_not_equal(func) do_if_z_clr(func)
#define do_if_not_zero(func) do_if_z_clr(func)
#define do_if_carry(func) do_if_c_set(func)
#define do_if_borrow(func) do_if_c_clr(func)
#define do_if_negative(func) do_if_n_set(func)
#define do_if_bit7_set(func) do_if_n_set(func)
#define do_if_positive(func) do_if_n_clr(func) 
#define do_if_bit7_clr(func) do_if_n_clr(func)

#define do_if_bit7_set_mem(val, func) __asm__("BIT %v", val); do_if_bit7_set(func)
#define do_if_bit7_clr_mem(val, func) __asm__("BIT %v", val); do_if_bit7_clr(func)
#define do_if_bit6_set_mem(val, func) __asm__("BIT %v", val); do_if_v_set(func)
#define do_if_bit6_clr_mem(val, func) __asm__("BIT %v", val); do_if_v_clr(func)

#define do_if_in_range(val, min, max, func) __A__ = val; __asm__("sec \n sbc #%b \n sbc #%b-%b+1 ", min, max, min); do_if_c_clr(func)
#define do_if_not_in_range(val, min, max, func) __A__ = val; __asm__("sec \n sbc #%b \n sbc #%b-%b+1 ", min, max, min); do_if_c_set(func)

#define fc_mic_poll() (PEEK(0x4016) & 0x04)

#define sec_adc(a, b) (__A__ = (a), __asm__("sec \nadc %v", b), __A__)
#define clc_sbc(a, b) (__A__ = (a), __asm__("clc \nsbc %v", b), __A__)

#define jumpInTableWithOffset(tbl, val, off) ( \
  __A__ = val << 1, \
  __asm__("tay \n lda %v-%w, y \n ldx %v-%w+1, y \n jsr callax ", tbl, (off * 2), tbl, (off * 2)))

extern uint8_t shiftBy4table[16];
#define shlNibble4(nibble) (idx8_load(shiftBy4table, nibble))
#define shlNibble12(nibble) (idx8_load(shiftBy4table, nibble), __AX__ <<= 8)

#endif//_Snesdash_h

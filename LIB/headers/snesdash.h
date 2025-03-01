#ifndef _Snesdash_h
#define _Snesdash_h




#define POKE(addr, val)    (*(uint8_t*) (addr) = (val))
#define PEEK(addr)         (*(uint8_t*) (addr))
// examples
// POKE(0xD800, 0x12); // stores 0x12 at address 0xd800, useful for hardware registers
// B = PEEK(0xD800); // read a value from address 0xd800, into B, which should be a uint8_t


#endif//_Snesdash_h

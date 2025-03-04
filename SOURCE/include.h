// you probably shouldn't change anything  //
// here unless you know what you're doing. //

#include "BUILD_FLAGS.h" 

// C standard library 
#include "stdint.h"	// defines for standard types
#include "stddef.h"	// more defines for standard types
#include "nonstdint.h"
#include "arr_macros.h" // fast array operations

// asm standard library
#include "sneslib.h"
#include "snesdash.h"

// some core functions
#include "core.h"

// ...


// various game-essential defines
#include "defines/space_defines.h"
#include "defines/physics_defines.h"
#include "defines/level_defines.h"

// grounds go here
#pragma rodata-name (push, "BANK1")
#include "defines/menunametable.h"
#pragma rodata-name (pop)
// ....

// .......



#include "famidash.h"   // where everything is declared. don't move this

// .....

// THE GAME STATE DEFINES //

#include "gamestates/state_menu.h"


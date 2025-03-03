; Copyright (C) 2025 iProgramInCpp

.segment "BANK1"

.export _splashMenu_
.export _splashMenu2_
_splashMenu_:
_splashMenu2_:
	.incbin "GRAPHICS/title_screen.pal"
	
.export _game_start_screenv2
_game_start_screenv2:
	.incbin "GRAPHICS/title_screen.map"


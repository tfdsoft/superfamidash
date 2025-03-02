; Copyright (C) 2025 iProgramInCpp

.segment "BANK7"

.export _menu_graphics=menu_graphics

menu_graphics:
	.incbin "GRAPHICS/menus-4bpp.chr"

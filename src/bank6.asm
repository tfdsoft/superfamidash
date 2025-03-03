; Copyright (C) 2025 iProgramInCpp

.segment "BANK6"

.export _parallax_data = parallax_data
.export _parallax_graphics = parallax_graphics

parallax_graphics:
	.incbin "GRAPHICS/parallax.chr"
parallax_data:
	.incbin "GRAPHICS/parallax.map"

; Copyright (C) 2025 iProgramInCpp

; ****** SNES REGISTERS ******

inidisp   = $2100 ; force blank, screen brightness
obsel     = $2101 ; object size and CHR address
oamaddl   = $2102 ; oam address low
oamaddh   = $2103 ; oam address high + obj priority
oamdata   = $2104
bgmode    = $2105 ; we're using BG mode 1 (4bpp bg1 and bg2, 2bpp bg3)
mosaic    = $2106 ; pixel size + effect mask
bg1sc     = $2107 ; bg1 tile map addr and size
bg2sc     = $2108 ; bg2 tile map addr and size
bg3sc     = $2109 ; bg3 tile map addr and size
bg4sc     = $210a ; bg4 tile map addr and size
bg12nba   = $210b ; bg1 and 2 chr address
bg34nba   = $210c ; bg3 and 4 chr address
bg1hofs   = $210d ; bg 1 h scroll (write twice)
bg1vofs   = $210e ; bg 1 v scroll (write twice)
bg2hofs   = $210f ; bg 2 h scroll (write twice)
bg2vofs   = $2110 ; bg 2 v scroll (write twice)
bg3hofs   = $2111 ; bg 3 h scroll (write twice)
bg3vofs   = $2112 ; bg 3 v scroll (write twice)
bg4hofs   = $2113 ; bg 4 h scroll (write twice)
bg4vofs   = $2114 ; bg 4 v scroll (write twice)
m7hofs    = bg1hofs ; mode 7 h scroll
m7vofs    = bg1vofs ; mode 7 v scroll
vmain     = $2115 ; video port control
vmaddl    = $2116 ; VRAM address low  (note: this is a WORD addr not a BYTE addr)
vmaddh    = $2117 ; VRAM address high
vmdatal   = $2118 ; VRAM data low
vmdatah   = $2119 ; VRAM data high
m7sel     = $211a ; mode 7 settings
m7a       = $211b ; mode 7 matrix A (write twice)
m7b       = $211c ; mode 7 matrix B (write twice)
m7c       = $211d ; mode 7 matrix C (write twice)
m7d       = $211e ; mode 7 matrix D (write twice)
m7x       = $211f ; mode 7 matrix X (write twice)
m7y       = $2120 ; mode 7 matrix Y (write twice)
cgadd     = $2121 ; CGRAM address
cgdata    = $2122 ; CGRAM data write
w12sel    = $2123 ; window mask for BG1 and BG2
w34sel    = $2124 ; window mask for BG3 and BG4
wobjsel   = $2125 ; window mask for OBJ and color window
wh0       = $2126 ; window 1 left
wh1       = $2127 ; window 1 right
wh2       = $2128 ; window 2 left
wh3       = $2129 ; window 2 right
wbglog    = $212a ; window mask logic for BG
wobjlog   = $212b ; window mask logic for OBJ
tm        = $212c ; main screen designation
ts        = $212d ; sub screen designation
tmw       = $212e ; main screen window mask designation
tsw       = $212f ; sub screen window mask designation
cgwsel    = $2130 ; color addition select
cgadsub   = $2131 ; color math designation
coldata   = $2132 ; fixed color data
setini    = $2133 ; screen mode / video select

wmdata    = $2180 ; WRAM data r/w
wmaddl    = $2181 ; WRAM address low byte
wmaddm    = $2182 ; WRAM address mid byte
wmaddh    = $2183 ; WRAM address high byte

nmitimen  = $4200 ; interrupt enable
wrio      = $4201 ; programmable I/O port
wrmpya    = $4202 ; multiplicand A (for 8X8->16 hw mult)
wrmpyb    = $4203 ; multiplicand B (for 8X8->16 hw mult)
wrdivl    = $4204 ; dividend C low
wrdivh    = $4205 ; dividend C high
wrdivb    = $4206 ; divisor B
htimel    = $4207 ; H Timer low
htimeh    = $4208 ; H Timer high
vtimel    = $4209 ; V Timer low
vtimeh    = $420a ; V Timer high
mdmaen    = $420b ; memory DMA enable
hdmaen    = $420c ; h-blank DMA enable
memsel    = $420d ; memory access speed

rdnmi     = $4210 ; NMI flag

; DMA (Channels: 0 - 7)
.define dmap(n) $4300+n<<4 ; DMA properties
.define bbad(n) $4301+n<<4 ; B-bus Address ($2100+BBADn)
.define a1tl(n) $4302+n<<4 ; DMA current address (A Bus)
.define a1th(n) $4303+n<<4 ; DMA current address (A Bus)
.define a1b(n)  $4304+n<<4 ; DMA current address (B Bus)
.define dasl(n) $4305+n<<4 ; DMA byte counter
.define dash(n) $4306+n<<4 ; DMA byte counter
.define dasb(n) $4307+n<<4 ; indirect HDMA bank

; ****** ADDRESSING MODE SWITCHES ******
; these macros change the address mode in both ca65
; (.i16) and also on the CPU (through rep/sep)

.macro i16
	rep #$10
	.i16
.endmacro

.macro a16
	rep #$20
	.a16
.endmacro

.macro ai16
	rep #$30
	.a16
	.i16
.endmacro

.macro i8
	sep #$10
	.i8
.endmacro

.macro a8
	sep #$20
	.a8
.endmacro

.macro ai8
	sep #$30
	.a8
	.i8
.endmacro

.define ia8  ai8
.define ia16 ai16

; ****** GAME RELATED ******



# Copyright (C) 2025 iProgramInCpp

AS = ca65
CC = cc65
LD = ld65

#DEBUGSW=
DEBUGSW=-DDEBUG

# Assembly sources are in src/, C sources are in SOURCE/
SRC=src
SOURCE=SOURCE
TMP=TMP
GFX=GRAPHICS

# C and Assembly files to be imported
CFILES = SOURCE/famidash.c
ASMFILES = src/main.asm

GRAPHICS_OBJECTS = \
	$(shell find $(GFX) -name *.tiles.png) \
	$(shell find $(GFX) -name *.chr) \
	$(shell find $(GFX) -name *.map) \
	$(shell find $(GFX) -name *.pal)

$(info $(GRAPHICS_OBJECTS))

# Compiled C objects
CASSFILES = $(patsubst $(SOURCE)/%, $(TMP)/%.asm, $(CFILES))

ASMOBJECTS = $(patsubst $(SRC)/%, $(TMP)/%.o, $(ASMFILES)) $(patsubst %, %.o, $(CASSFILES))

.PHONY: clean

# enable this if you want famidash.c.asm to be there
.SECONDARY: $(CASSFILES)

build: main.sfc

$(TMP)/%.asm.o: $(SRC)/%.asm
	@mkdir -p $(dir $@)
	$(AS) -g --create-dep "$@.dep" --debug-info $< -o $@ -I. --listing "$(TMP)/$(notdir $@).lst" $(DEBUGSW)

$(TMP)/%.asm.o: $(TMP)/%.asm
	@mkdir -p $(dir $@)
	$(AS) -g --create-dep "$@.dep" --debug-info $< -o $@ --listing "$(TMP)/$(notdir $@).lst" $(DEBUGSW)

$(TMP)/%.c.asm: $(SOURCE)/%.c
	@mkdir -p $(dir $@)
	$(CC) -g --create-dep "$@.dep" --debug-info $< -o $@ $(DEBUGSW) -ILIB/headers -I. -ISOURCE --eagerly-inline-funcs -Osir --cpu 65816

main.sfc: layout $(ASMOBJECTS)
	$(LD) --dbgfile $@.dbg -C $^ -o $@ -m $@.map

clean:
	rm -f main.sfc *.dep *.o *.dbg *.map
	rm -rf $(TMP)
	rm $(GRAPHICS_OBJECTS)

include $(wildcard $(TMP)/*.dep)

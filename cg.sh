#!/bin/sh

# To run this script you will need to have superfamiconv built in the BIN folder. This
# involves building from source (https://github.com/Optiroc/SuperFamiconv) since SFCV
# doesn't come with releases for linux.
#
# The builtin version was compiled with Ubuntu 22.04 on WSL1.

doAsset () {
	asset="$1"
	colorzero="$2"
	./BIN/superfamiconv -F -v --in-image "GRAPHICS/$asset.png" --out-palette "GRAPHICS/$asset.pal" --out-tiles "GRAPHICS/$asset.chr" --out-map "GRAPHICS/$asset.map" --out-tiles-image "GRAPHICS/$asset.tiles.png" --color-zero "$colorzero"
}

# Add your assets here. They must be located within GRAPHICS and be in PNG format.
# Format:  doAsset assetName bgColor

doAsset "title_screen" "#4242FFFF"
	
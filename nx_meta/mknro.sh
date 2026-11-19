#!/bin/bash
# Usage: nx_meta/mknro.sh <build_dir> <variant> -> <build_dir>/pokeplatinum_ss.nro with NACP + icon
set -e
B=$1; V=$2
/opt/devkitpro/tools/bin/nacptool --create "Pokemon Platinum SS ($V)" "pret / cybervisi0n / elyro1" "$(git rev-parse --short HEAD)-$V" nx_meta/$V.nacp >/dev/null
/opt/devkitpro/tools/bin/elf2nro "$B/main" "$B/pokeplatinum_ss.nro" --nacp=nx_meta/$V.nacp --icon=nx_meta/icon.jpg

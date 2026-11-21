#!/bin/bash
# Build O'Blood, Dirt and Cum: compile, write the plugin, fill Data/00 Core, make the release zip.
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
VER=0.5.7
cd "$ROOT"
tools/compile.sh
python3 tools/mkesp.py build/OBlood_Dirt_and_Cum.esp
python3 tools/verify.py build/OBlood_Dirt_and_Cum.esp > build/verify.txt
CORE="Data/00 Core"
rm -rf "$CORE/Scripts"; mkdir -p "$CORE/Scripts/Source"
cp build/Scripts/*.pex "$CORE/Scripts/"
cp src/*.psc "$CORE/Scripts/Source/"
cp build/OBlood_Dirt_and_Cum.esp "$CORE/"
{ cat README.md; echo; echo "---"; echo; cat CHANGELOG.md; } > "$CORE/OBlood_Dirt_and_Cum_README.md"
mkdir -p dist out
rm -f "dist/OBlood_Dirt_and_Cum_$VER.zip" "out/OBlood_Dirt_and_Cum_$VER.zip"
python3 tools/mkzip.py "dist/OBlood_Dirt_and_Cum_$VER.zip" Data fomod "00 Core" "01 Malignis Flag"
cp -f "dist/OBlood_Dirt_and_Cum_$VER.zip" "out/OBlood_Dirt_and_Cum_$VER.zip"
md5sum "out/OBlood_Dirt_and_Cum_$VER.zip"; stat -c '%s bytes' "out/OBlood_Dirt_and_Cum_$VER.zip"

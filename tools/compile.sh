#!/bin/bash
# Compile O'Blood, Dirt and Cum with Caprica (Skyrim SE flags).
# Usage:
#   CAPRICA=/path/to/caprica \
#   IMPORTS=/path/to/skse:/path/to/skyui:/path/to/po3:/path/to/papyrusutil:/path/to/skyrimnet:/path/to/ostim \
#   ./tools/compile.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CAPRICA="${CAPRICA:-caprica}"
OUT="$ROOT/build/Scripts"
rm -rf "$OUT"; mkdir -p "$OUT"
flags=(-i "$ROOT/src" -i "$ROOT/tools/stubs")   # stubs: compile-only, never shipped
IFS=':' read -ra dirs <<< "${IMPORTS:-}"
for d in "${dirs[@]}"; do
  if [ -n "$d" ]; then
    flags+=(-i "$d")
  fi
done
cd "$ROOT/src"
"$CAPRICA" -g skyrim --ignorecwd "${flags[@]}" -f "$ROOT/tools/TESV_Papyrus_Flags.flg" -o "$OUT" *.psc 2>&1 | grep -v "^Adding import" || true
ls "$OUT"/OBDC_Main.pex "$OUT"/OBDC_MCM.pex "$OUT"/OBDC_PlayerAlias.pex "$OUT"/OBDC_OCum.pex > /dev/null
python3 "$ROOT/tools/scrub.py" "$OUT"/*.pex   # keep only the file name of the source in the .pex header

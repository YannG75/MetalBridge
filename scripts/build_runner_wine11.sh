#!/usr/bin/env bash
# Construit ~/gptk-work/build/<RUNNER_NAME> (défaut MetalBridge-Wine11.12-GPTK4b2) : runner Heroic (type "toolkit") basé sur le runtime
# Switchyard Wine (release runtime-34a09170d37, Wine 11.12, notarisé) + charge GPTK 4.0b2 copiée depuis TON DMG.
# Rien n'est écrit hors de ~/gptk-work. Les binaires Mach-O du runtime ne sont pas modifiés (signatures intactes) ;
# seul le script wrapper bin/wine reçoit un défaut pour SWITCHYARD_GPTK_PATH (original conservé : bin/wine.upstream).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=config.sh
. "$SCRIPT_DIR/config.sh"
NAME="$RUNNER_NAME"
SRC="$W/build/switchyard-src/Switchyard-Wine-Runtime-34a09170d375-macos-x86_64"
OUT="$W/build/$NAME"
[ -x "$SRC/bin/wine.switchyard-real" ] || { echo "runtime extrait introuvable: $SRC"; exit 1; }
[ -d "$EVAL/redist/lib/external/D3DMetal.framework" ] || { echo "DMG GPTK 4 non monté: $EVAL"; exit 1; }
[ -e "$OUT" ] && { echo "$OUT existe déjà : supprime-le toi-même pour reconstruire"; exit 1; }

echo "[1/5] Clone APFS du runtime -> Contents/Resources/wine"
mkdir -p "$OUT/Contents/Resources"
cp -cR "$SRC" "$OUT/Contents/Resources/wine"
WINE="$OUT/Contents/Resources/wine"

echo "[2/5] Charge GPTK 4.0b2 (redist/lib du DMG, non modifiée) -> Contents/Resources/gptk/redist/lib"
mkdir -p "$OUT/Contents/Resources/gptk/redist"
ditto "$EVAL/redist/lib" "$OUT/Contents/Resources/gptk/redist/lib"

echo "[3/5] Wrapper : défaut SWITCHYARD_GPTK_PATH + lien wine64 (Heroic exige bin/wine64)"
cp "$WINE/bin/wine" "$WINE/bin/wine.upstream"
python3 - "$WINE/bin/wine" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
anchor = 'runtime_dir="$(cd "$bin_dir/.." && pwd)"\n'
assert s.count(anchor) == 1, "ancre du wrapper introuvable ou multiple"
add = anchor + '''# --- local: GPTK 4.0b2 embarquée par défaut (surchargeable via SWITCHYARD_GPTK_PATH) ---
if [ -z "${SWITCHYARD_GPTK_PATH:-}" ] && [ -d "$runtime_dir/../gptk/redist/lib/wine" ]; then
  export SWITCHYARD_GPTK_PATH="$(cd "$runtime_dir/../gptk" && pwd)"
fi
# --- fin local ---
'''
open(p, "w").write(s.replace(anchor, add))
PY
bash -n "$WINE/bin/wine"
ln -s wine "$WINE/bin/wine64"

echo "[4/5] Info.plist + SOURCE.txt"
cat > "$OUT/Contents/Info.plist" <<'PL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>__NAME__</string>
<key>CFBundleIdentifier</key><string>local.gptk4b2.wine11</string>
<key>CFBundleShortVersionString</key><string>4.0b2-wine11.12</string>
<key>CFBundleVersion</key><string>4.0b2-wine11.12</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSMinimumSystemVersion</key><string>26.0</string>
</dict></plist>
PL
cat > "$OUT/SOURCE.txt" <<'TX'
Runner assemblé localement (aucune redistribution).
Base Wine : Switchyard Wine, release GitHub runtime-34a09170d37, commit 34a09170d3754522dc55416617c6754dd2d9a086
  https://github.com/jungwuk-ryu/switchyard-wine  (LGPL-2.1-or-later ; Wine upstream 0c1585cf, base 11.12)
  archive sha256 5494498f72b2b25bbde7cc74ae4e1afca449e76b75f6a1993a3986d34ac09491, signée Developer ID (Team M3CULMDKU3), notarisée.
Modifications locales : Contents/Resources/wine/bin/wine (défaut SWITCHYARD_GPTK_PATH ; original = bin/wine.upstream), lien bin/wine64, Info.plist.
Charge GPTK : Contents/Resources/gptk/redist/lib = copie de « Evaluation environment for Windows games 4.0 beta 2 » (Apple, usage local uniquement, ne pas redistribuer).
TX
/usr/libexec/PlistBuddy -c "Set :CFBundleName $NAME" "$OUT/Contents/Info.plist"
echo "[5/5] Vérifications"
codesign --verify --strict "$WINE/bin/wine.switchyard-real" && echo "signature wine.switchyard-real OK"
ls -l "$WINE/bin/wine64" "$WINE/bin/wine"
echo "[✓] Runner prêt : $OUT"

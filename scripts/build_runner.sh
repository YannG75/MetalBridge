#!/usr/bin/env bash
# Construit ~/gptk-work/build/GPTK-4.0-Beta à partir d'une COPIE du runner GPTK 3.0-3 (lecture seule sur les sources)
# et du DMG GPTK 4.0b2 déjà monté. Aucune écriture hors de ~/gptk-work. Aucun fichier Apple n'est versionné (build/ est ignoré).
set -euo pipefail
W="$HOME/gptk-work"
BASE="${BASE:-$W/Game-Porting-Toolkit-latest}"
EVAL="${EVAL:-/Volumes/Evaluation environment for Windows games 4.0 beta 2/redist/lib}"
OUT="$W/build/GPTK-4.0-Beta"
PATCHED="$W/build/patched_dlls"
[ -d "$BASE/Contents/Resources/wine/lib" ] || { echo "base introuvable: $BASE"; exit 1; }
[ -d "$EVAL/external/D3DMetal.framework" ] || { echo "DMG GPTK 4 non monté: $EVAL"; exit 1; }
[ -e "$OUT" ] && { echo "$OUT existe déjà: supprime-le toi-même (rm -rf) pour reconstruire"; exit 1; }
mkdir -p "$W/build"
echo "[1/5] Patch des DLL (simulation puis écriture)"
"$W/.venv/bin/python" "$W/scripts/patch_gptk4.py" --src "$EVAL/wine/x86_64-windows"
"$W/.venv/bin/python" "$W/scripts/patch_gptk4.py" --src "$EVAL/wine/x86_64-windows" --apply --out "$PATCHED"
echo "[2/5] Clone APFS de la base"
cp -cR "$BASE" "$OUT"
L="$OUT/Contents/Resources/wine/lib"
echo "[3/5] Remplacement de D3DMetal.framework et libd3dshared.dylib (ditto, préserve les liens symboliques)"
rm -rf "$L/external/D3DMetal.framework" "$L/external/libd3dshared.dylib"
ditto "$EVAL/external/D3DMetal.framework" "$L/external/D3DMetal.framework"
ditto "$EVAL/external/libd3dshared.dylib" "$L/external/libd3dshared.dylib"
echo "[4/5] DLL patchées (+ nvngx.dll = nvngx-on-metalfx.dll patchée, comme le Read Me)"
for f in d3d10 d3d11 d3d12 dxgi nvapi64 nvngx-on-metalfx; do cp "$PATCHED/$f.dll" "$L/wine/x86_64-windows/$f.dll"; done
cp "$PATCHED/nvngx-on-metalfx.dll" "$L/wine/x86_64-windows/nvngx.dll"
echo "[5/5] Info.plist (version) sur la copie uniquement"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 4.0b2-wine7.7" -c "Set :CFBundleVersion 4.0b2-wine7.7" "$OUT/Contents/Info.plist"
echo "[✓] Runner prêt: $OUT"

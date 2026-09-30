#!/usr/bin/env bash
# Génère « Steam (Wine).app » (lanceur Spotlight du client Steam Windows du préfixe prefixes/steam) et l'installe dans ~/Applications.
# L'icône est extraite du steam.exe installé localement (rien n'est versionné ni redistribué).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"; NAME="Steam (Wine)"; T="$W/build/tmp-steam-app"; A="$T/$NAME.app"
EXE="$STEAM_PREFIX/drive_c/Program Files (x86)/Steam/steam.exe"
[ -f "$EXE" ] || { echo "steam.exe introuvable : lance d'abord setup_steam_prefix.sh"; exit 1; }
[ -e "$T" ] && { echo "$T existe déjà : supprime-le puis relance"; exit 1; }
mkdir -p "$A/Contents/MacOS" "$A/Contents/Resources" "$T/icon.iconset"
"$W/.venv/bin/python" "$W/scripts/extract_exe_icon.py" "$EXE" "$T/steam.ico"
sips -s format png "$T/steam.ico" --out "$T/big.png" >/dev/null
for s in 16 32 64 128 256; do sips -z $s $s "$T/big.png" --out "$T/p$s.png" >/dev/null; done
sips -z 512 512 "$T/big.png" --out "$T/p512.png" >/dev/null
cp "$T/p16.png"  "$T/icon.iconset/icon_16x16.png";      cp "$T/p32.png"  "$T/icon.iconset/icon_16x16@2x.png"
cp "$T/p32.png"  "$T/icon.iconset/icon_32x32.png";      cp "$T/p64.png"  "$T/icon.iconset/icon_32x32@2x.png"
cp "$T/p128.png" "$T/icon.iconset/icon_128x128.png";    cp "$T/p256.png" "$T/icon.iconset/icon_128x128@2x.png"
cp "$T/p256.png" "$T/icon.iconset/icon_256x256.png";    cp "$T/p512.png" "$T/icon.iconset/icon_256x256@2x.png"
iconutil -c icns "$T/icon.iconset" -o "$A/Contents/Resources/steam-wine.icns"
cat > "$A/Contents/Info.plist" <<'PL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Steam (Wine)</string>
<key>CFBundleDisplayName</key><string>Steam (Wine)</string>
<key>CFBundleIdentifier</key><string>local.gptk.steam-wine</string>
<key>CFBundleExecutable</key><string>steam-wine</string>
<key>CFBundleIconFile</key><string>steam-wine</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.1</string>
<key>LSMinimumSystemVersion</key><string>26.0</string>
<key>LSUIElement</key><true/>
</dict></plist>
PL
cat > "$A/Contents/MacOS/steam-wine" <<SH
#!/bin/bash
# Lance le client Steam (Windows) du préfixe $STEAM_PREFIX avec le runner $RUNNER_NAME (chemins figés à la génération).
export WINEPREFIX="$STEAM_PREFIX" WINEDEBUG=-all WINEESYNC=1
mkdir -p "$W/logs"
nohup "$RUNNER_WINE/bin/wine64" "C:\\\\Program Files (x86)\\\\Steam\\\\steam.exe" "\$@" >>"$W/logs/steam_app.log" 2>&1 &
SH
chmod +x "$A/Contents/MacOS/steam-wine"; plutil -lint "$A/Contents/Info.plist" >/dev/null
mkdir -p "$HOME/Applications"
ditto "$A" "$HOME/Applications/$NAME.app"
touch "$HOME/Applications/$NAME.app"
rm -r "$T"
echo "[✓] installé : $HOME/Applications/$NAME.app"

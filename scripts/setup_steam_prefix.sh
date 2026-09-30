#!/usr/bin/env bash
# Prépare un préfixe Steam SÉPARÉ (~/gptk-work/prefixes/steam) avec le runner local MetalBridge-Wine11.12-GPTK4b2.
# Ne touche à aucun préfixe Heroic. Étapes : création du préfixe, installation silencieuse de Steam (installeur Valve
# téléchargé dans downloads/ par fetch_steam.sh). Steam se lancera ensuite avec scripts/run_steam.sh.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"; R="$RUNNER_WINE"
export WINEPREFIX="$STEAM_PREFIX" WINEDEBUG="${WINEDEBUG:--all}" WINEESYNC=1
mkdir -p "$W/prefixes" "$W/logs"
[ -f "$W/downloads/SteamSetup.exe" ] || { echo "SteamSetup.exe absent de downloads/"; exit 1; }
echo "[1/3] wineboot (création du préfixe)"; "$R/bin/wine64" wineboot -i >"$W/logs/steam_wineboot.txt" 2>&1 || true
echo "[2/3] Installation silencieuse de Steam"; "$R/bin/wine64" "$W/downloads/SteamSetup.exe" /S >"$W/logs/steam_install.txt" 2>&1 || true
"$R/bin/wineserver" -w || true
ls -la "$WINEPREFIX/drive_c/Program Files (x86)/Steam/steam.exe" && echo "[3/3] Steam installé"

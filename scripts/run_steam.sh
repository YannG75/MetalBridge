#!/usr/bin/env bash
# Lance le client Steam du préfixe séparé (fenêtre visible : l'utilisateur saisit lui-même ses identifiants).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"; R="$RUNNER_WINE"
export WINEPREFIX="$STEAM_PREFIX" WINEDEBUG="${WINEDEBUG:-err+all}" WINEESYNC=1
exec "$R/bin/wine64" "C:\\Program Files (x86)\\Steam\\steam.exe" "$@" 2>&1 | tee "$W/logs/steam_run_$(date +%H%M%S).txt"

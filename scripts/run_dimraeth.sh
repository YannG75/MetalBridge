#!/usr/bin/env bash
# Lance Dimraeth (Steam AppID 2402680) via le client Steam du préfixe séparé : Steam démarre s'il ne tourne pas,
# sinon la commande est transmise à l'instance en cours. Le jeu a besoin de Steam pour SteamApi_Init (mode hôte/serveur).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"; R="$RUNNER_WINE"
export WINEPREFIX="$STEAM_PREFIX" WINEDEBUG="${WINEDEBUG:--all}" WINEESYNC=1
exec "$R/bin/wine64" "C:\\Program Files (x86)\\Steam\\steam.exe" -applaunch 2402680 "$@"

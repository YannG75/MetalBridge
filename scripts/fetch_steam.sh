#!/usr/bin/env bash
# Télécharge l'installeur Steam officiel (Valve) dans downloads/. Affiche la source et demande confirmation (sauf --yes).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"
URL="https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe"
if [ "${1:-}" != "--yes" ]; then read -r -p "Télécharger $URL (~2,4 Mo, installeur Valve) ? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || exit 1; fi
mkdir -p "$W/downloads"; curl -fsSL -o "$W/downloads/SteamSetup.exe" "$URL"
shasum -a 256 "$W/downloads/SteamSetup.exe"; echo "(le hash change à chaque version de Steam ; l'installeur est signé Valve Corp., vérifiable avec la chaîne DigiCert)"

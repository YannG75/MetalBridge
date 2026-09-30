#!/usr/bin/env bash
# Installation complète et reproductible : téléchargement (avec confirmation) -> vérification -> construction -> installation dans Heroic
# [-> Steam optionnel]. Prérequis : DMG « Game Porting Toolkit 4.0 beta 2 » (Apple) monté, ainsi que le DMG imbriqué
# « Evaluation environment for Windows games 4.0 beta 2 ». Aucun fichier Apple n'est copié dans le dépôt ni redistribué.
# Usage : install_all.sh [--with-steam] [--yes]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"
STEAM=0; YES=""; for a in "$@"; do case "$a" in --with-steam) STEAM=1;; --yes) YES="--yes";; esac; done
[ -d "$EVAL/redist/lib/external/D3DMetal.framework" ] || { echo "Monte d'abord le DMG d'évaluation : $EVAL"; exit 1; }
[ -d "$W/build/switchyard-src" ] || bash "$SCRIPT_DIR/fetch_switchyard.sh" $YES
bash "$SCRIPT_DIR/verify_switchyard.sh"
[ -d "$RUNNER_DIR" ] || bash "$SCRIPT_DIR/build_runner_wine11.sh"
if [ -d "$HEROIC_TOOLS/$RUNNER_NAME" ]; then echo "Déjà installé dans Heroic : $RUNNER_NAME (pour réinstaller : uninstall_runner.sh)"; else bash "$SCRIPT_DIR/install_runner.sh"; fi
if [ "$STEAM" = 1 ]; then
  if [ ! -x "$W/.venv/bin/python" ]; then
    [ -n "$YES" ] || { read -r -p "Télécharger la bibliothèque Python « pefile » (PyPI, petit) pour extraire l'icône de Steam ? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || exit 1; }
    python3 -m venv "$W/.venv"; "$W/.venv/bin/pip" install -q pefile
  fi
  [ -f "$W/downloads/SteamSetup.exe" ] || bash "$SCRIPT_DIR/fetch_steam.sh" $YES
  bash "$SCRIPT_DIR/setup_steam_prefix.sh"
  bash "$SCRIPT_DIR/make_steam_app.sh"
  echo "Steam (Wine) est dans ~/Applications ; connecte-toi puis installe/lance tes jeux Steam depuis sa bibliothèque."
fi
echo "[✓] terminé"

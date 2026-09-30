#!/usr/bin/env bash
# Installe le runner construit dans Heroic (ajout seul ; refuse d'écraser un dossier existant ; ne touche à aucun autre runner).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"
DEST="$HEROIC_TOOLS/$RUNNER_NAME"
[ -d "$RUNNER_DIR" ] || { echo "runner non construit : lance build_runner_wine11.sh"; exit 1; }
[ -e "$DEST" ] && { echo "$DEST existe déjà : lance uninstall_runner.sh d'abord"; exit 1; }
mkdir -p "$HEROIC_TOOLS"; cp -cR "$RUNNER_DIR" "$DEST"
echo "[✓] installé : $DEST"
echo "Redémarre Heroic (Cmd+Q), puis choisis « $RUNNER_NAME » dans Paramètres du jeu > Wine, et coche « Promouvoir AVX pour Rosetta »."

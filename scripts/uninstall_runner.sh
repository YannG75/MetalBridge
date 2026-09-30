#!/usr/bin/env bash
# Retire UNIQUEMENT le runner installé dans Heroic (après confirmation). Les jeux qui l'utilisent devront choisir un autre runner.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"
DEST="$HEROIC_TOOLS/$RUNNER_NAME"
[ -d "$DEST" ] || { echo "rien à retirer : $DEST"; exit 0; }
case "$DEST" in "$HEROIC_TOOLS"/?*) ;; *) echo "chemin inattendu"; exit 1;; esac
if [ "${1:-}" != "--yes" ]; then read -r -p "Supprimer $DEST ? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || exit 1; fi
rm -rf -- "$DEST"; echo "[✓] supprimé"

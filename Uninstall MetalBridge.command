#!/bin/bash
# Assistant de désinstallation à double-cliquer : retire UNIQUEMENT le moteur MetalBridge de Heroic (et propose de retirer Steam (Wine)).
cd "$(dirname "$0")" || exit 1
ROOT="$(pwd)"
ask() { local msg="$1"; shift; local list="" b; for b in "$@"; do list="$list\"$b\","; done; list="{${list%,}}"
  osascript -e "button returned of (display dialog \"$msg\" with title \"MetalBridge\" buttons $list default button \"${!#}\")" 2>/dev/null; }
[ "$(ask "Retirer le moteur MetalBridge de Heroic ?\n\nTes jeux et tes autres moteurs ne sont pas touchés. Les jeux qui utilisent ce moteur devront en choisir un autre." "Annuler" "Retirer le moteur")" = "Retirer le moteur" ] || exit 0
bash "$ROOT/scripts/uninstall_runner.sh" --yes
if [ -d "$HOME/Applications/Steam (Wine).app" ]; then
  if [ "$(ask "Mettre aussi l'app « Steam (Wine) » à la corbeille ?\n\nTes jeux Steam (dans le dossier prefixes/steam du dépôt) ne sont pas supprimés." "Garder" "Mettre à la corbeille")" = "Mettre à la corbeille" ]; then
    osascript -e 'tell application "Finder" to delete POSIX file (POSIX path of (path to home folder) & "Applications/Steam (Wine).app")' >/dev/null 2>&1
  fi
fi
ask "Désinstallation terminée.\n\nQuitte Heroic (Cmd+Q) et rouvre-le pour rafraîchir la liste." "Fermer" >/dev/null

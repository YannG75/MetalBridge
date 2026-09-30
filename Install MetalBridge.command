#!/bin/bash
# Assistant d'installation à double-cliquer (macOS). Pose des questions avec des fenêtres, vérifie les prérequis, puis lance scripts/install_all.sh.
# Option de test sans fenêtre : "Install MetalBridge.command" --check
cd "$(dirname "$0")" || exit 1
ROOT="$(pwd)"; APPLE_URL="https://developer.apple.com/download/all/"
EVAL="/Volumes/Evaluation environment for Windows games 4.0 beta 2"
HEROIC_TOOLS="$HOME/Library/Application Support/heroic"
CHECK=0; [ "${1:-}" = "--check" ] && CHECK=1

# ask "message" "bouton1" "bouton2" ... -> affiche le bouton cliqué (dernier = par défaut)
ask() {
  local msg="$1"; shift; local list="" b
  for b in "$@"; do list="$list\"$b\","; done; list="{${list%,}}"
  osascript -e "button returned of (display dialog \"$msg\" with title \"MetalBridge\" buttons $list default button \"${!#}\")" 2>/dev/null
}
stop_msg() { [ $CHECK = 1 ] && { echo "✗ $1"; return; }; ask "$1" "OK" >/dev/null; exit 1; }
ok() { [ $CHECK = 1 ] && echo "✓ $1"; }
clear; echo "MetalBridge — assistant d'installation"; echo

if [ $CHECK = 0 ]; then
  [ "$(ask "Cet assistant va ajouter le moteur MetalBridge (Wine 11 + Game Porting Toolkit 4 bêta 2) à Heroic.\n\nIl ne modifie ni tes jeux ni tes autres moteurs.\nDurée : 5 à 15 minutes." "Annuler" "Continuer")" = "Continuer" ] || exit 0
fi

# 1. Mac et macOS
[ "$(uname -m)" = "arm64" ] || [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" = "1" ] || stop_msg "Ce projet nécessite un Mac Apple Silicon (M1, M2, M3, M4…)."
MAJOR="$(sw_vers -productVersion | cut -d. -f1)"
[ "$MAJOR" -ge 26 ] || stop_msg "macOS 26 ou plus récent est nécessaire (tu as macOS $(sw_vers -productVersion))."
ok "Mac Apple Silicon, macOS $(sw_vers -productVersion)"

# 2. Heroic
if [ ! -d "/Applications/Heroic.app" ] && [ ! -d "$HEROIC_TOOLS" ]; then
  [ $CHECK = 1 ] && { echo "✗ Heroic introuvable"; } || { [ "$(ask "Heroic Games Launcher n'est pas installé.\n\nInstalle-le depuis heroicgameslauncher.com, ouvre-le une fois, puis relance cet assistant." "Annuler" "Ouvrir le site")" = "Ouvrir le site" ] && open "https://heroicgameslauncher.com"; exit 1; }
else ok "Heroic trouvé"; fi

# 3. Outils développeur (python3, git…)
if ! xcode-select -p >/dev/null 2>&1; then
  [ $CHECK = 1 ] && echo "✗ outils développeur absents" || { ask "Les outils de développement d'Apple sont nécessaires (gratuits).\n\nUne fenêtre macOS va s'ouvrir : clique sur Installer, attends la fin, puis relance cet assistant." "OK" >/dev/null; xcode-select --install; exit 1; }
else ok "Outils développeur présents"; fi

# 4. Rosetta
if ! arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
  if [ $CHECK = 1 ]; then echo "✗ Rosetta absent"; else
    [ "$(ask "Rosetta 2 (traducteur d'Apple, gratuit) doit être installé. macOS peut te demander ton mot de passe." "Annuler" "Installer Rosetta")" = "Installer Rosetta" ] || exit 1
    softwareupdate --install-rosetta --agree-to-license || exit 1
  fi
else ok "Rosetta 2 présent"; fi

# 5. Disques Apple montés
while [ ! -d "$EVAL/redist/lib/external/D3DMetal.framework" ]; do
  if [ $CHECK = 1 ]; then echo "✗ disque « Evaluation environment for Windows games 4.0 beta 2 » non monté"; break; fi
  R="$(ask "Il manque le fichier d'Apple « Game Porting Toolkit 4.0 beta 2 ».\n\n1. Télécharge-le sur developer.apple.com (Apple ID gratuit).\n2. Double-clique dessus, puis sur « Evaluation environment for Windows games 4.0 beta 2.dmg » qu'il contient.\n3. Laisse les deux disques ouverts et clique sur Réessayer." "Annuler" "Ouvrir la page Apple" "Réessayer")"
  case "$R" in "Ouvrir la page Apple") open "$APPLE_URL"; sleep 2;; "Réessayer") ;; *) exit 0;; esac
done
[ -d "$EVAL/redist/lib/external/D3DMetal.framework" ] && ok "Fichiers Apple trouvés"
[ $CHECK = 1 ] && { echo; echo "Vérification terminée (aucune installation lancée)."; exit 0; }

# 6. Options + consentement aux téléchargements
CH="$(ask "Que veux-tu installer ?\n\n• Moteur seul : pour jouer avec Heroic.\n• Moteur + Steam : ajoute aussi Steam (version Windows) pour les jeux qui en ont besoin." "Annuler" "Moteur seul" "Moteur + Steam")"
case "$CH" in
  "Moteur seul") ARGS=""; DL="• Le moteur Wine (environ 771 Mo) depuis github.com/jungwuk-ryu/switchyard-wine";;
  "Moteur + Steam") ARGS="--with-steam"; DL="• Le moteur Wine (environ 771 Mo) depuis github.com/jungwuk-ryu/switchyard-wine\n• L'installeur de Steam (environ 2,4 Mo) depuis les serveurs de Valve\n• Une petite bibliothèque Python « pefile » (PyPI) pour l'icône de Steam";;
  *) exit 0;;
esac
[ "$(ask "Téléchargements qui vont avoir lieu :\n\n$DL\n\nLe moteur est vérifié (signature Apple Developer ID, notarisation) avant toute utilisation. Aucun fichier d'Apple n'est envoyé nulle part.\n\nAccepter ?" "Annuler" "Accepter et installer")" = "Accepter et installer" ] || exit 0

# 7. Installation
echo; echo "Installation en cours… (tu peux suivre ici ; ne ferme pas cette fenêtre)"; echo
if bash "$ROOT/scripts/install_all.sh" $ARGS --yes; then
  ask "Installation terminée ✅\n\n1. Quitte Heroic (Cmd+Q) puis rouvre-le.\n2. Dans les paramètres d'un jeu → Wine, choisis « MetalBridge-Wine11.12-GPTK4b2 » et coche « Promouvoir AVX pour Rosetta ».\n\nSi tu as installé Steam : cherche « Steam (Wine) » avec Spotlight." "Fermer" >/dev/null
else
  ask "L'installation a rencontré un problème ❌\n\nLis le message affiché dans la fenêtre du Terminal (en général il dit quoi faire). Tu peux relancer cet assistant sans risque." "Fermer" >/dev/null
  exit 1
fi

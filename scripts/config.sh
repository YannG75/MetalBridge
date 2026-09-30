# Configuration commune aux scripts (à sourcer). Surcharge possible par variables d'environnement.
W="${GPTK_WORK:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"   # racine du dépôt par défaut
RUNNER_NAME="${RUNNER_NAME:-MetalBridge-Wine11.12-GPTK4b2}"
RUNNER_DIR="$W/build/$RUNNER_NAME"
RUNNER_WINE="$RUNNER_DIR/Contents/Resources/wine"
STEAM_PREFIX="${STEAM_PREFIX:-$W/prefixes/steam}"
HEROIC_TOOLS="$HOME/Library/Application Support/heroic/tools/game-porting-toolkit"
EVAL="${EVAL:-/Volumes/Evaluation environment for Windows games 4.0 beta 2}"

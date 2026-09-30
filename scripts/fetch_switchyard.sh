#!/usr/bin/env bash
# Télécharge (dans ~/gptk-work/downloads) la release Switchyard Wine choisie, puis vérifie sha256 + manifeste.
# N'exécute rien du runtime. La signature/notarisation sont vérifiées après extraction (verify_switchyard.sh).
set -euo pipefail
TAG="${TAG:-runtime-34a09170d37}"
REV="${REV:-34a09170d375}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"
D="$W/downloads"
B="https://github.com/jungwuk-ryu/switchyard-wine/releases/download/$TAG"
ZIP="Switchyard-Wine-Runtime-$REV-macos-x86_64.zip"
if [ "${1:-}" != "--yes" ]; then read -r -p "Télécharger $B/$ZIP (~771 Mo, runtime signé et notarisé) ? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || exit 1; fi
mkdir -p "$D"; cd "$D"
curl -fsSL -O "$B/switchyard-runtime-release.json"
curl -fsSL -O "$B/$ZIP.sha256"
[ -f "$ZIP" ] || { curl -fL --progress-bar -o "$ZIP.part" "$B/$ZIP" && mv "$ZIP.part" "$ZIP"; }
expected_file="$(awk '{print $1}' "$ZIP.sha256")"
expected_json="$(python3 -c "import json;print(json.load(open('switchyard-runtime-release.json'))['archiveSha256'])")"
actual="$(shasum -a 256 "$ZIP" | awk '{print $1}')"
echo "sha256 fichier .sha256 : $expected_file"
echo "sha256 manifeste JSON  : $expected_json"
echo "sha256 calculé         : $actual"
[ "$expected_file" = "$expected_json" ] && [ "$actual" = "$expected_json" ] && echo "[OK] les trois sha256 concordent" || { echo "[ÉCHEC] sha256 différents"; exit 1; }

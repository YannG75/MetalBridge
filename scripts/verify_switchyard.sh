#!/usr/bin/env bash
# Vérifie l'archive Switchyard Wine téléchargée (sha256 x3 déjà contrôlés par fetch_switchyard.sh), l'extrait (ditto, rien n'est exécuté),
# puis contrôle : tous les Mach-O signés Developer ID par UNE équipe (M3CULMDKU3), signature stricte valide, notarisation.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$SCRIPT_DIR/config.sh"
REV="${REV:-34a09170d375}"; TEAM="M3CULMDKU3"
ZIP="$W/downloads/Switchyard-Wine-Runtime-$REV-macos-x86_64.zip"; DST="$W/build/switchyard-src"
SRC="$DST/Switchyard-Wine-Runtime-$REV-macos-x86_64"
[ -d "$SRC" ] || { [ -f "$ZIP" ] || { echo "ni archive ($ZIP) ni dossier extrait ($SRC)"; exit 1; }; mkdir -p "$DST"; ditto -x -k "$ZIP" "$DST"; }
python3 - "$SRC" "$TEAM" <<'PY'
import os, subprocess, sys
root, team = sys.argv[1:3]; n = bad = 0
for d, _, fs in os.walk(root):
    for f in fs:
        p = os.path.join(d, f)
        if os.path.islink(p): continue
        try: magic = open(p, "rb").read(4)
        except OSError: continue
        if magic not in (b"\xcf\xfa\xed\xfe", b"\xca\xfe\xba\xbe"): continue
        n += 1
        info = subprocess.run(["codesign", "-dvv", p], capture_output=True, text=True).stderr
        ok = subprocess.run(["codesign", "--verify", "--strict", p], capture_output=True).returncode == 0
        if not ok or f"TeamIdentifier={team}" not in info: bad += 1; print("ANOMALIE:", p)
print(f"{n} Mach-O contrôlés, {bad} anomalie(s)"); sys.exit(1 if bad else 0)
PY
for b in wine.switchyard-real wineserver; do codesign --verify -R="notarized" --check-notarization "$SRC/bin/$b" && echo "notarisation OK : $b"; done
echo "[✓] runtime vérifié : $SRC"

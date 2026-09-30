#!/usr/bin/env bash
# Fabrique l'archive à publier dans les « Releases » GitHub : dist/MetalBridge-Installer-<version>.zip (+ .sha256).
# Elle est faite avec `git archive` : uniquement les fichiers VERSIONNÉS (scripts, README, licence, assistants .command).
# Aucun fichier d'Apple, de Valve ou de Wine ne peut y entrer.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"; cd "$ROOT"
VERSION="${1:-$(git describe --tags --always 2>/dev/null || echo dev)}"
OUT="dist/MetalBridge-Installer-$VERSION.zip"
[ -z "$(git status --porcelain --untracked-files=no)" ] || { echo "Des modifications ne sont pas commitées : commite d'abord."; exit 1; }
mkdir -p dist
git archive --format=zip --prefix="MetalBridge-Installer-$VERSION/" -o "$OUT" HEAD
# contrôle : aucun binaire/DLL/DMG/exe dans l'archive
if unzip -Z1 "$OUT" | grep -i -E '\.(dll|dylib|so|dmg|pkg|exe|framework)(/|$)'; then echo "ARCHIVE REFUSÉE : fichiers binaires détectés"; rm -f "$OUT"; exit 1; fi
( cd dist && shasum -a 256 "$(basename "$OUT")" | tee "$(basename "$OUT").sha256" )
echo "[✓] $OUT ($(unzip -Z1 "$OUT" | wc -l | tr -d ' ') entrées) — à joindre à une Release GitHub"

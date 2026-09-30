# Contribuer

Merci de vouloir aider ! Ce dépôt ne contient que des **scripts et de la documentation** (licence MIT).

## Règle n°1 : aucun fichier propriétaire
Ne jamais ajouter (fichiers, captures contenant des fichiers, pièces jointes d'issue) :
- des fichiers d'Apple : DMG Game Porting Toolkit, `D3DMetal.framework`, `libd3dshared.dylib`, DLL `d3d*.dll`/`dxgi.dll`/`nvapi64.dll`…
- des binaires Wine ou Switchyard, des installeurs Steam ou Valve, des fichiers de jeux.

Les scripts doivent continuer à **télécharger/copier ces fichiers depuis la machine de l'utilisateur**, avec confirmation avant tout téléchargement.

## Signaler un problème (issue)
Indique : macOS (`sw_vers`), puce du Mac, version de Heroic, nom du jeu et API graphique (DX11/DX12), moteur choisi, variables d'environnement,
ce qui se passe, et le log `~/Library/Logs/Heroic Games Launcher/games/<id>/launch.log`.
**Relis le log avant de l'envoyer** : il peut contenir des chemins personnels ou des codes d'authentification (par exemple les arguments `-AUTH_…`
des jeux Epic) — remplace-les par `XXX`.

## Proposer un changement (pull request)
- Garde les scripts lisibles, en `bash` (macOS 3.2 compatible), avec `set -euo pipefail`.
- Une modification = un but. Explique **ce que tu as testé** (macOS, Mac, jeu, runner).
- Toute étape qui télécharge, supprime ou écrit hors du dossier du dépôt doit **demander confirmation** et être **réversible** (documente le retour arrière).
- Ne change pas les hashes épinglés sans expliquer d'où vient la nouvelle version et comment tu l'as vérifiée (signature, notarisation, sha256).
- Mets à jour le README si le comportement visible change.

## Retours de tests
Un tableau « jeu / API / moteur / variables / résultat » est très utile, même pour dire « ne fonctionne pas ». Précise toujours la version de macOS et de GPTK.

## Licence
En contribuant, tu acceptes que ta contribution soit publiée sous licence MIT.

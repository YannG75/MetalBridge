# MetalBridge — jouer à des jeux Windows sur Mac avec Heroic

**MetalBridge-Wine11.12-GPTK4b2** est un petit installateur qui ajoute à **Heroic Games Launcher** un « moteur » capable de lancer
des jeux Windows sur un Mac Apple Silicon (M1, M2, M3, M4…), en utilisant la technologie d'Apple
(*Game Porting Toolkit 4, bêta 2*). Il peut aussi installer **Steam (version Windows)** à côté, pour les jeux qui en ont besoin.

> ⚠️ **Projet de la communauté, en bêta.** Il n'est lié ni à Apple, ni à Heroic, ni à Valve, ni à WineHQ.
> Ça fonctionne sur la machine où il a été fait (MacBook M1 Max, macOS 27.0.1, Heroic 2.22.3) et avec deux jeux testés.
> Sur d'autres Mac ou d'autres jeux, **rien n'est garanti**. Tu ne risques pas de casser tes jeux existants : l'installation *ajoute* un moteur sans toucher aux autres.

## Ce que tu obtiens

- Un nouveau choix de moteur dans Heroic : **MetalBridge-Wine11.12-GPTK4b2** (à côté de ceux que tu as déjà).
- En option : **Steam (Wine)**, une app que tu ouvres avec Spotlight, pour les jeux qui exigent Steam.
- Un moyen de tout **désinstaller** proprement.

## Ce que ce dépôt ne contient pas (et pourquoi)

Aucun fichier d'Apple, de Valve ou de Wine n'est dans ce dépôt. Les scripts les **téléchargent ou les copient depuis ton propre Mac**,
après t'avoir demandé ton accord. C'est voulu : ces fichiers ne sont pas redistribuables.

---

## Avant de commencer (15 minutes, une seule fois)

Coche chaque ligne :

- [ ] **Un Mac Apple Silicon** avec **macOS 26 ou plus récent** (testé sur macOS 27).
- [ ] **Heroic Games Launcher** installé et ouvert au moins une fois ([heroicgameslauncher.com](https://heroicgameslauncher.com)).
- [ ] **Environ 10 Go d'espace libre** (plus la place de tes jeux).
- [ ] **Rosetta 2** installé. Si tu n'es pas sûr, ouvre l'app *Terminal* (Spotlight → « Terminal ») et tape :
  ```
  softwareupdate --install-rosetta --agree-to-license
  ```
- [ ] **Les outils de développement d'Apple** (petit téléchargement gratuit). Dans le Terminal :
  ```
  xcode-select --install
  ```
  Si un message dit « already installed », tout va bien.
- [ ] **Le fichier d'Apple « Game Porting Toolkit 4.0 beta 2 »** :
  1. Va sur <https://developer.apple.com/download/all/> et connecte-toi avec ton Apple ID (gratuit).
  2. Cherche « Game Porting Toolkit » et télécharge la version **4.0 beta 2** (un fichier `.dmg`).
  3. **Double-clique** dessus : un disque apparaît. Dedans, double-clique sur
     **« Evaluation environment for Windows games 4.0 beta 2.dmg »** : un deuxième disque apparaît.
  4. Laisse les deux disques ouverts (ne les éjecte pas) pendant l'installation.

## Installation

*English version: [README.en.md](README.en.md).*

1. **Télécharge le dossier** : sur la page GitHub du projet, onglet **Releases** → télécharge le fichier **`MetalBridge-Installer-….zip`**
   (ou, à défaut, bouton vert **Code → Download ZIP**), puis double-clique dessus pour le décompresser (par exemple dans *Documents*).

### Méthode simple (sans Terminal) — recommandée
2. Dans le dossier décompressé, **double-clique sur « Install MetalBridge.command »**.
3. Suis les fenêtres : l'assistant vérifie ton Mac, t'aide si un élément manque (Rosetta, fichiers d'Apple…), te demande ce que tu veux installer
   (**moteur seul** ou **moteur + Steam**), t'indique **précisément ce qui sera téléchargé** et attend ton accord.
4. Patiente **5 à 15 minutes**. Une fenêtre « Installation terminée » s'affiche à la fin.

> **Si macOS bloque le double-clic** (« Apple n'a pas pu vérifier… ») : c'est normal pour un fichier téléchargé sur Internet qui n'est pas signé par Apple.
> Va dans **Réglages Système → Confidentialité et sécurité**, descends jusqu'au message qui mentionne « Install MetalBridge.command » et clique sur **Ouvrir quand même**,
> puis relance le double-clic. Tu peux lire le contenu du fichier avec un éditeur de texte avant, il est entièrement lisible.

### Méthode Terminal (si tu préfères)
2. Ouvre le **Terminal** (Spotlight → « Terminal »).
3. Tape `cd` suivi d'**un espace**, **glisse le dossier décompressé dans la fenêtre du Terminal**, appuie sur **Entrée**.
4. Lance :
   ```
   bash scripts/install_all.sh              # moteur seul
   bash scripts/install_all.sh --with-steam # moteur + Steam
   ```
   Le script te **demande la permission avant chaque téléchargement** (tape `y` puis Entrée).

Quand tu vois **« terminé »**, c'est fini.

## Utiliser le nouveau moteur dans Heroic

1. **Quitte complètement Heroic** (Cmd + Q) puis rouvre-le.
2. Ouvre un jeu → **Paramètres** (la roue dentée) → onglet **Wine**.
3. Dans **Version de Wine**, choisis **MetalBridge-Wine11.12-GPTK4b2**.
4. Active **« Promouvoir AVX pour Rosetta »**. *(Conseillé : sur un jeu testé, ça a supprimé des plantages dans les menus.)*
5. Lance le jeu.

**Bon à savoir**
- Au **premier lancement**, l'écran peut rester noir quelques secondes et le jeu peut « saccader » un peu : il prépare ses effets graphiques. Les lancements suivants sont plus fluides.
- Deux petites **fenêtres de débogage** peuvent apparaître au début. C'est sans conséquence dans nos tests, tu peux les ignorer.
- Si tu as **déjà utilisé le jeu avec un autre moteur**, le plus simple est de créer un **nouveau préfixe** (un dossier « Wine » vierge) pour ce jeu dans Heroic,
  pour éviter des restes de l'ancien moteur.

## Steam (si tu as choisi `--with-steam`)

Certains jeux ne démarrent qu'avec Steam ouvert (ils affichent par exemple « Server not responding » sinon).
L'installation crée une app **« Steam (Wine) »** dans ton dossier *Applications*.

1. Ouvre **Spotlight** (Cmd + Espace), tape **Steam (Wine)** et valide.
2. Au premier lancement Steam se met à jour (quelques minutes), puis **connecte-toi avec ton compte Steam**. Tu tapes tes identifiants toi-même, le projet n'y a jamais accès.
3. Installe ou lance tes jeux **depuis la bibliothèque Steam**, comme sur un PC.

*Si macOS refuse d'ouvrir l'app (« développeur non identifié »)* : clic droit sur l'app → **Ouvrir** → **Ouvrir**.

## Ça ne marche pas ?

| Ce que tu vois | Que faire |
|---|---|
| Le script dit « Monte d'abord le DMG d'évaluation » | Ouvre aussi le **deuxième** disque (« Evaluation environment for Windows games 4.0 beta 2 ») et relance. |
| Le moteur n'apparaît pas dans Heroic | Quitte Heroic avec **Cmd + Q** (pas juste fermer la fenêtre) et rouvre-le. |
| `d3d11.dll not found` ou le jeu s'arrête tout seul | Le dossier Wine du jeu contient des restes d'un autre moteur : crée un **nouveau préfixe** pour ce jeu dans Heroic. |
| `failed to load il2cpp` | Tu utilises un ancien moteur : choisis **MetalBridge-Wine11.12-GPTK4b2**. |
| « Server not responding », ou le jeu réclame Steam | Lance-le **depuis Steam (Wine)**, pas depuis Heroic. |
| Le jeu plante en fermant un menu | Active **« Promouvoir AVX pour Rosetta »**. |
| Écran noir ou saccades au tout début | Normal au premier lancement ; attends un peu. |
| Autre problème | Voir « Signaler un problème » plus bas. |

## Désinstaller

- **Le moteur** : double-clique sur **« Uninstall MetalBridge.command »** (ou dans le Terminal : `bash scripts/uninstall_runner.sh`). Il demande confirmation et ne retire que ce moteur.
- **Steam (Wine)** : glisse l'app **Steam (Wine)** du dossier *Applications* à la corbeille, et supprime le dossier `prefixes/steam` du dépôt.
- Le reste du dossier du dépôt peut être supprimé librement.

Aucun de tes jeux ni de tes autres moteurs n'est modifié par l'installation.

## Signaler un problème

Ouvre une *issue* sur GitHub en indiquant : ta version de macOS, ton Mac (puce), le jeu, ce que tu as fait, ce qui se passe,
et joins le fichier de log du jeu dans `~/Library/Logs/Heroic Games Launcher/games/…/launch.log` (vérifie qu'il ne contient pas d'infos personnelles avant de l'envoyer).
Voir [CONTRIBUTING.md](CONTRIBUTING.md).

## Contribuer

Les idées, corrections et retours de tests sont les bienvenus : jeux testés (marche / ne marche pas), améliorations des scripts, traductions.
Lis [CONTRIBUTING.md](CONTRIBUTING.md) : **ne joins jamais de fichiers d'Apple, de Valve ou de Wine** (DMG, D3DMetal, DLL, binaires).

---

## Pour les curieux (partie technique)

**Ce que fait l'installation, précisément**
1. `fetch_switchyard.sh` : télécharge (après confirmation) la release GitHub `runtime-34a09170d37` du projet *Switchyard Wine*
   (Wine 11.12, archive signée Developer ID de l'équipe `M3CULMDKU3` et notarisée par Apple) et contrôle son sha256 (`5494498f72b2b25bbde7cc74ae4e1afca449e76b75f6a1993a3986d34ac09491`) à trois endroits.
2. `verify_switchyard.sh` : extrait sans rien exécuter, vérifie la signature de chacun des 59 binaires et la notarisation.
3. `build_runner_wine11.sh` : clone ce runtime, copie les fichiers de ta GPTK 4.0b2 (non modifiés) dans `Contents/Resources/gptk/redist/lib`, ajoute
   un lien `wine64` et fait pointer `SWITCHYARD_GPTK_PATH` par défaut vers cette copie (seul le script `bin/wine` est modifié ; l'original est gardé en `bin/wine.upstream`).
4. `install_runner.sh` : copie le résultat dans `~/Library/Application Support/heroic/tools/game-porting-toolkit/` (Heroic le reconnaît car il contient
   `Contents/Info.plist` et `Contents/Resources/wine/bin/wine64`).
5. Option Steam : `fetch_steam.sh`, `setup_steam_prefix.sh`, `make_steam_app.sh`.

**Variante « Wine 7.7 »** (`build_runner.sh`, `patch_gptk4.py`) : runner de repli construit à partir du runner GPTK 3.0-3 de Heroic, avec un patcheur ciblé
(2 sites et 13 octets modifiés par DLL, mode simulation par défaut, arrêt si le motif diffère). Elle ne convient pas aux jeux qui exigent des
api-sets récentes (ex. jeux Unity IL2CPP récents : « failed to load il2cpp »).

**Limites connues**
- GPTK 4 beta 2 et la base Wine évoluent ; le runtime Switchyard a été validé par son auteur avec la beta 1.
- Sur Aniimo, `-force-d3d12` retombe en D3D11 (`D3D11On12` non supporté) ; freezes possibles dans les zones très peuplées.
- Sans `ROSETTA_ADVERTISE_AVX=1`, un crash reproductible a été observé (lecture nulle dans `ntdll`, TEB à zéro sur un thread natif, à la fermeture d'un menu) ; il a disparu avec l'option AVX sur une session de test. Les détails se discutent dans les *issues*.
- Les performances n'ont pas été mesurées de façon rigoureuse.

## Licence et crédits

Scripts et documentation : **licence MIT** (voir [LICENSE](LICENSE)), © 2026 ImSoChill. Cette licence ne couvre pas les logiciels tiers :
Wine (LGPL-2.1-or-later) et le runtime **Switchyard Wine** ([jungwuk-ryu/switchyard-wine](https://github.com/jungwuk-ryu/switchyard-wine)) sont téléchargés depuis leur source officielle ;
la *Game Porting Toolkit* et D3DMetal appartiennent à Apple ; Steam appartient à Valve. Merci aux auteurs de ces projets.

# MetalBridge — run Windows games on your Mac with Heroic

*Version française : [README.md](README.md).*

**MetalBridge-Wine11.12-GPTK4b2** is a small installer that adds an extra "engine" to **Heroic Games Launcher** so it can run Windows
games on Apple Silicon Macs (M1, M2, M3, M4…), using Apple's technology (*Game Porting Toolkit 4, beta 2*).
It can also install **Steam (Windows version)** alongside, for games that need it.

> ⚠️ **Community project, beta.** It is not affiliated with Apple, Heroic, Valve or WineHQ.
> It works on the machine it was made on (MacBook M1 Max, macOS 27.0.1, Heroic 2.22.3) with two tested games.
> On other Macs or other games, **nothing is guaranteed**. Your existing games are safe: the install *adds* an engine and does not touch the others.

## What you get

- A new engine choice in Heroic: **MetalBridge-Wine11.12-GPTK4b2** (next to the ones you already have).
- Optionally: **Steam (Wine)**, an app you open with Spotlight, for games that require Steam.
- A way to **uninstall** everything cleanly.

## What this repository does not contain (and why)

No file from Apple, Valve or Wine is in this repository. The scripts **download them, or copy them from your own Mac**,
after asking for your consent. This is on purpose: those files cannot be redistributed.

---

## Before you start (15 minutes, once)

Tick each line:

- [ ] **An Apple Silicon Mac** running **macOS 26 or newer** (tested on macOS 27).
- [ ] **Heroic Games Launcher** installed and opened at least once ([heroicgameslauncher.com](https://heroicgameslauncher.com)).
- [ ] **About 10 GB of free space** (plus room for your games).
- [ ] **Rosetta 2** installed. If unsure, open *Terminal* (Spotlight → "Terminal") and type:
  ```
  softwareupdate --install-rosetta --agree-to-license
  ```
- [ ] **Apple's developer tools** (small free download). In Terminal:
  ```
  xcode-select --install
  ```
  If it says "already installed", you are fine.
- [ ] **Apple's "Game Porting Toolkit 4.0 beta 2" file**:
  1. Go to <https://developer.apple.com/download/all/> and sign in with your (free) Apple ID.
  2. Search for "Game Porting Toolkit" and download version **4.0 beta 2** (a `.dmg` file).
  3. **Double-click** it: a disk appears. Inside, double-click
     **"Evaluation environment for Windows games 4.0 beta 2.dmg"**: a second disk appears.
  4. Leave both disks open (do not eject them) during the installation.

## Installation

1. **Download the folder**: on the project's GitHub page, open the **Releases** tab and download **`MetalBridge-Installer-….zip`**
   (or, failing that, green button **Code → Download ZIP**), then double-click it to unzip (for example in *Documents*).

### Easy way (no Terminal) — recommended
2. In the unzipped folder, **double-click "Install MetalBridge.command"**.
3. Follow the windows: the assistant checks your Mac, helps if something is missing (Rosetta, Apple's files…), asks what you want to install
   (**engine only** or **engine + Steam**), tells you **exactly what will be downloaded** and waits for your approval.
4. Wait **5 to 15 minutes**. An "Installation finished" window appears at the end.

> **If macOS blocks the double-click** ("Apple could not verify…"): this is normal for a file downloaded from the Internet that is not signed by Apple.
> Go to **System Settings → Privacy & Security**, scroll down to the message mentioning "Install MetalBridge.command" and click **Open Anyway**,
> then double-click again. You can read the file in a text editor first: it is entirely human-readable.

### Terminal way (if you prefer)
2. Open **Terminal** (Spotlight → "Terminal").
3. Type `cd` followed by **a space**, **drag the unzipped folder into the Terminal window**, press **Enter**.
4. Run:
   ```
   bash scripts/install_all.sh              # engine only
   bash scripts/install_all.sh --with-steam # engine + Steam
   ```
   The script **asks your permission before every download** (type `y`, then Enter).

When you see **"terminé"** (done), you are finished.

## Use the new engine in Heroic

1. **Quit Heroic completely** (Cmd + Q) and reopen it.
2. Open a game → **Settings** (the gear icon) → **Wine** tab.
3. In **Wine Version**, choose **MetalBridge-Wine11.12-GPTK4b2**.
4. Turn on **"Advertise AVX for Rosetta"**. *(Recommended: on one tested game it removed crashes in menus.)*
5. Launch the game.

**Good to know**
- On the **first launch**, the screen may stay black for a few seconds and the game may stutter a little: it is preparing its graphics effects. Later launches are smoother.
- Two small **debug windows** may appear at the start. They had no consequence in our tests; you can ignore them.
- If you **already used the game with another engine**, the easiest fix is to create a **new prefix** (a fresh "Wine folder") for that game in Heroic,
  to avoid leftovers from the old engine.

## Steam (if you chose `--with-steam`)

Some games only start with Steam open (otherwise they show, for example, "Server not responding").
The installation creates a **"Steam (Wine)"** app in your *Applications* folder.

1. Open **Spotlight** (Cmd + Space), type **Steam (Wine)** and press Enter.
2. On first launch Steam updates itself (a few minutes), then **sign in with your Steam account**. You type your credentials yourself; this project never sees them.
3. Install or launch your games **from the Steam library**, as you would on a PC.

*If macOS refuses to open the app ("unidentified developer")*: right-click the app → **Open** → **Open**.

## Something is not working?

| What you see | What to do |
|---|---|
| The script says "Monte d'abord le DMG d'évaluation" (mount the evaluation DMG first) | Also open the **second** disk ("Evaluation environment for Windows games 4.0 beta 2") and run again. |
| The engine does not show in Heroic | Quit Heroic with **Cmd + Q** (not just closing the window) and reopen it. |
| `d3d11.dll not found`, or the game stops by itself | The game's Wine folder contains leftovers from another engine: create a **new prefix** for that game in Heroic. |
| `failed to load il2cpp` | You are using an older engine: choose **MetalBridge-Wine11.12-GPTK4b2**. |
| "Server not responding", or the game needs Steam | Launch it **from Steam (Wine)**, not from Heroic. |
| The game crashes when closing a menu | Turn on **"Advertise AVX for Rosetta"**. |
| Black screen or stutter at the very start | Normal on first launch; wait a bit. |
| Anything else | See "Report a problem" below. |

## Uninstall

- **The engine**: double-click **"Uninstall MetalBridge.command"** (or, in Terminal: `bash scripts/uninstall_runner.sh`). It asks for confirmation and removes only this engine.
- **Steam (Wine)**: drag the **Steam (Wine)** app from *Applications* to the Trash, and delete the `prefixes/steam` folder of the project.
- The rest of the project folder can be deleted freely.

The installation modifies none of your games or other engines.

## Report a problem

Open a GitHub *issue* with: your macOS version, your Mac (chip), the game, what you did, what happens,
and attach the game's log file from `~/Library/Logs/Heroic Games Launcher/games/…/launch.log` (check it contains no personal information before sending).
See [CONTRIBUTING.md](CONTRIBUTING.md).

## Contribute

Ideas, fixes and test reports are welcome: tested games (works / does not work), script improvements, translations.
Read [CONTRIBUTING.md](CONTRIBUTING.md): **never attach files from Apple, Valve or Wine** (DMGs, D3DMetal, DLLs, binaries).

---

## For the curious (technical part)

**What the installation does, precisely**
1. `fetch_switchyard.sh`: downloads (after confirmation) the GitHub release `runtime-34a09170d37` of the *Switchyard Wine* project
   (Wine 11.12, archive signed with a Developer ID of team `M3CULMDKU3` and notarized by Apple) and checks its sha256
   (`5494498f72b2b25bbde7cc74ae4e1afca449e76b75f6a1993a3986d34ac09491`) in three places.
2. `verify_switchyard.sh`: extracts without executing anything, verifies the signature of each of the 59 binaries and the notarization.
3. `build_runner_wine11.sh`: clones this runtime, copies your GPTK 4.0b2 files (unmodified) into `Contents/Resources/gptk/redist/lib`, adds
   a `wine64` link and makes `SWITCHYARD_GPTK_PATH` point to that copy by default (only the `bin/wine` script is modified; the original is kept as `bin/wine.upstream`).
4. `install_runner.sh`: copies the result into `~/Library/Application Support/heroic/tools/game-porting-toolkit/` (Heroic recognizes it because it contains
   `Contents/Info.plist` and `Contents/Resources/wine/bin/wine64`).
5. Steam option: `fetch_steam.sh`, `setup_steam_prefix.sh`, `make_steam_app.sh`.

**"Wine 7.7" variant** (`build_runner.sh`, `patch_gptk4.py`): a fallback runner built from Heroic's GPTK 3.0-3 runner, with a targeted patcher
(2 sites and 13 bytes modified per DLL, dry-run by default, stops if the expected pattern differs). It is not suitable for games requiring
recent api-sets (e.g. recent Unity IL2CPP games: "failed to load il2cpp").

**Release archive**: `scripts/make_release.sh` builds `dist/MetalBridge-Installer-<version>.zip` from the versioned files only (`git archive`) and refuses
to produce it if it contains binaries (.dll, .dylib, .dmg, .exe…). Attach it, with its `.sha256`, to a GitHub Release.

**Known limits**
- GPTK 4 beta 2 and the Wine base keep evolving; the Switchyard runtime was validated by its author with beta 1.
- On Aniimo, `-force-d3d12` falls back to D3D11 (`D3D11On12` unsupported); stutters are possible in crowded areas.
- Without `ROSETTA_ADVERTISE_AVX=1`, a reproducible crash was observed (null read in `ntdll`, TEB at zero on a native thread, when closing a menu); it disappeared with the AVX option in one test session. Details can be discussed in the *issues*.
- Performance was not measured rigorously.

## License and credits

Scripts and documentation: **MIT license** (see [LICENSE](LICENSE)), © 2026 ImSoChill. This license does not cover third-party software:
Wine (LGPL-2.1-or-later) and the **Switchyard Wine** runtime ([jungwuk-ryu/switchyard-wine](https://github.com/jungwuk-ryu/switchyard-wine)) are downloaded from their official source;
the *Game Porting Toolkit* and D3DMetal belong to Apple; Steam belongs to Valve. Thanks to the authors of those projects.

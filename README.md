# Pokémon Platinum PC Port — Single-Screen Mod

Pokémon Platinum on PC, widescreen, on one screen.
This is a mod for the native PC port of Pokémon Platinum. The focus here is a widescreen, single-screen experience, with adapted interfaces, expanded overworld rendering, and quality-of-life improvements.

You must provide your own dumped US Pokémon Platinum ROM (CPUE01). Game assets are extracted from that ROM on first launch. For the full experience, you also need a BW2 ROM.

## Nintendo Switch port (this fork)

This fork adds a native **Nintendo Switch** build (homebrew, libnx) of the single-screen mod. On a Switch running Atmosphère it plays at **full speed at stock clocks**, with the game logic at its original 30 fps and the 720p single-screen layout.

> This fork is not affiliated with upstream, and its changes are not intended for upstream submission. The Switch work was developed with AI assistance (Claude). No game assets or builds are distributed here.

### Status

- Overworld, menus and battles run at a locked 30 fps, which is full DS speed, at stock clocks with the recommended settings below.
- Boot to the title screen takes a few seconds.
- Launch it as a full application, through a forwarder or title takeover. Album/applet mode doesn't leave enough memory for the GL driver, so it crashes there.

### Recommended settings

- **`60Fps=false`** in `sim_config_prj.ini`: the original DS frame rate. The game's speed is tied to its frame rate. The fork's 60 fps mode needs twice the work per second, which the Switch can't sustain.
- **Keep `CapFrameRate=true`** in `sim_config.ini`. With the cap off the game doesn't get smoother; it fast-forwards.
- **VSync off** (`VsyncInterval=0`, or `NX_VSYNC=0` in `nx_env.txt`) is the tested configuration. Pacing is done in software.
- `InternalResolutionScale=2` (3D at 2× the DS resolution) fits the budget.
- **Graphics extras:** press **ZL** in game to open the settings overlay. Its *Graphics* page toggles each extra live. Measured cost on stock clocks, as CPU time per 33 ms game tick:

| Setup | CPU per tick | Speed |
|---|---|---|
| All extras off, or only *Soft character shadows* | ~16–17.5 ms | 100% |
| + day/night grading, regional atmosphere, model lighting | ~17.5 ms (daytime) | 100% |
| + cast shadows, water and weather effects | up to ~27 ms in town | fits, little headroom |
| Everything on, at night (night lighting, glows, bloom) | ~25–26 ms, more with bloom | ~80–88% |

Soft character shadows with everything else off is the tested daily setup.

### What the Switch port changes

The renderer and SDK changes live in [elyro1/libntr](https://github.com/elyro1/libntr), libntrsystem and libntrdwc. They are kept as patches in `subprojects/packagefiles/*-nx.patch`, and Meson applies them automatically when it fetches those subprojects (`diff_files` in the `.wrap` files).

- **Switch build target restored.** Meson cross files (`meson/cross_nx.ini`, plus `meson/cross_nx_opt2.ini` for `-O2` with the flags this codebase needs), packaging (`nx_meta/mknro.sh`), and a Docker helper (`drun_nx.sh`).
- **Switch compatibility.** The game's PC-port code paths are enabled for the Switch target. The Meson build cross-compiles the game and SDK libraries as position-independent code for the `.nro`, while build tools stay native. There are also fixes for devkitA64's GCC and newlib.
- **Faster 2D texture uploads.** On Switch Mesa (nouveau), every `glTexSubImage` allocates and frees a staging buffer through system calls. Uploads now go through a persistent, mapped buffer ring and a small GPU copy shader. `NX_UPLOAD=driver` or `NX_PBO=0` switches this off.
- **No stall on the next screen buffer.** The wait for a free swapchain buffer is deferred until the frame actually draws to it, instead of blocking right after each swap (about 11 ms per frame). `NX_DEFER_FENCE=0` switches this off.
- **G2 compositor shader rewritten.** The shader read each layer from about 38 places inside unrolled loops, which made Mesa's register allocator spend about 4 minutes linking it at every launch. The driver can't cache compiled programs, so this happened every time. Each layer is now read once, which brings the link time to about 1 second, with identical output.
- **30 fps frame skip.** In 30 fps mode the game waits for two vblanks per tick, and the simulator drew and presented a full frame on both. The vblank that repeats the picture now runs only its interrupts and DMA. `NX_SKIPDUP=0` switches this off.
- **Per-tick pacing.** A 30 fps tick is paced as one 33.3 ms slot instead of two 16.6 ms ones, so a slow first half no longer costs time.
- **Diagnostics.** These are in `sdmc:/switch/pokeplatinum_ss/`:
  - `perf_log.txt`, always on: per-step CPU and GPU time every 120 frames.
  - `boot_trace.txt`.
  - An optional sampling profiler (`NX_PROF=1`, writes `prof.txt`).

### Building

You need Linux with Docker. The build runs in the `cybervisi0n/pokeplatinum-build:v2` image (devkitA64, libnx, portlibs). The audio library SoundTouch has to be built for Switch once, into `nx_deps/` (gitignored):

```sh
mkdir -p nx_deps
git clone https://codeberg.org/soundtouch/soundtouch.git nx_deps/soundtouch
./drun_nx.sh "cmake -S nx_deps/soundtouch -B nx_deps/st_build \
  -DCMAKE_TOOLCHAIN_FILE=/opt/devkitpro/cmake/Switch.cmake -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PWD/nx_deps/switch -DSOUNDSTRETCH=OFF -DSOUNDTOUCH_DLL=OFF -DOPENMP=OFF -DNEON=ON \
  && cmake --build nx_deps/st_build -j && cmake --install nx_deps/st_build"
```

`nx_deps` can also be a symlink to a directory outside the repo; `drun_nx.sh` mounts its target too.

Then build and package:

```sh
./drun_nx.sh "make nx BUILD_NX=build_nx NX_EXTRA_CROSS=--cross-file=meson/cross_nx_opt2.ini"
./drun_nx.sh "git config --global --add safe.directory \$PWD; nx_meta/mknro.sh build_nx release"
```

The result is `build_nx/pokeplatinum_ss.nro`, plus the game data in `build_nx/pokeplatinum/`.

### Installing

1. Copy the contents of `build_nx/pokeplatinum/` to `sdmc:/switch/pokeplatinum_ss/`. The `main` file in that folder isn't needed on the console.
2. Copy `build_nx/pokeplatinum_ss.nro` into the same folder.
3. Launch it as an application, for example with a forwarder pointing at that `.nro`.

Saves (`save1.bin`, `autosave/`) and settings (`sim_config.ini`, `sim_config_prj.ini`, `gameplay_config.ini`) live in the same folder. Leave them in place when updating the `.nro`.

### `nx_env.txt` options

Put `KEY=VALUE` lines in `sdmc:/switch/pokeplatinum_ss/nx_env.txt`. Lines starting with `#` are ignored.

| Key | Effect |
|---|---|
| `NX_VSYNC=0` / `1` | Override the VSync setting |
| `NX_SKIPDUP=0` | Draw both vblanks of a 30 fps tick again (old behaviour) |
| `NX_DEFER_FENCE=0` | Wait for the next screen buffer right after each swap (old behaviour) |
| `NX_UPLOAD=driver`, `NX_PBO=0` | Use the driver's texture upload path |
| `NX_PROF=1` | Sampling profiler; writes `prof.txt` |
| `PLATINUM_FRAME_TRACE=sdmc:/switch/pokeplatinum_ss/frame_trace.csv` | Per-frame timing trace. The file grows by several MB per session. |
| `PLATINUM_GPU_TRACE=1` | GPU timer queries in the trace |

### Known issues

- With every extra on at night, the game runs at about 80–88% speed.
- The GPU timestamps in `perf_log.txt` read about 1.6× low on this driver.


## Start playing

You need a **dumped US Pokémon Platinum ROM (CPUE01)**. It is not included.

1. Download the ZIP for Windows or Linux from [Releases](https://github.com/elyro1/pokeplatinum-singlescreen/releases/).
2. Extract it into a new folder.
3. Put your Platinum `.nds` file in that folder, right next to the executable.
4. *Optional, recommended:* add a **US Black 2 or White 2** `.nds` too. This turns on BW2 battle visuals.
5. Run `main.exe` (Windows) or `main` (Linux).

Done. Assets extract by themselves on first launch. 
Press **Tab** for settings.

- **ROM filename?** Doesn't matter.
- **No ROM found?** A file picker opens. Choose your `.nds`.
- **Running slow?** Lower the internal resolution under Graphics.
- **Bug in this fork?** Use the [issue tracker](https://github.com/elyro1/pokeplatinum-singlescreen/issues).

## Features

- **Single-screen:** every screen reworked to play on just the top screen
- **Widescreen:** wider overworld view, adjusted world
- **Black 2 / White 2 style battles**
- **Three save slots:** pick one from the main menu
- **Pokétch in the in-game menu:** once you have it, switch apps with L/R, leave with B or X
- **Better graphics:** richer day/night lighting, improved model lighting, regional haze, smooth 3D edges, post-processing, soft character shadows
- **[Gameplay config](docs/gameplay_config.md):** independent gameplay overrides, so you can play how you want

Visual upgrades are **on by default**. Toggle them under **Tab → Graphics** ([graphics notes](docs/visual_upgrades.md)).

## Keys

| Key | Does |
| --- | --- |
| **Arrow keys** | Move / navigate (D-pad) |
| **Z** | Confirm / interact (A) |
| **X** | Cancel / run where available (B) |
| **C** | Open / close the in-game menu (X) |
| **V** | Use a registered item (Y) |
| **Q** / **E** | L / R, or previous / next Pokétch app |
| **Enter** | Start |
| **Right Shift** | Select |
| **Tab** | Settings and debug tools |
| **Left Shift** (hold) | Fast-forward (5× by default) |
| **F11** | Fullscreen |
| **Left mouse** | Touch, where the screen supports it |

**Remap:** Tab → Controls. These are fresh-install defaults; existing settings keep your old bindings.

<details>
<summary>Controller setup</summary>

- Found in **Tab → Controls → Controller**.
- Each direction has a Primary and a Secondary binding.
- Primary is the D-pad. Secondary is the left stick (axis 0 left/right, axis 1 up/down). Either one works for movement and menus.
- **Clear** removes a secondary binding.
- **Escape** cancels binding capture.
- Saved mappings are preserved, including cleared secondary bindings.
- Configurations without secondary bindings inherit the left-stick defaults.

</details>

## Settings (press Tab)

Out of the box: one screen, 60 FPS, Smooth battle pacing, Fast text, Fast HP/EXP bars. Speed correction is automatic at 60 FPS. Existing config files may override these.

| Page | What's there |
| --- | --- |
| **General** | Fullscreen, menu scale, master volume, ROM info, BW2 battle visuals |
| **Graphics** | Internal resolution, VSync, frame cap, lighting, atmosphere, shadows, water, weather, bloom |
| **Speed & text** | Fast-forward speed, fast wild intros (BW2), battle pacing, text speed, HP/EXP bar speed, low-HP beep toggle, Improved Pokétch, single-screen bag |
| **Controls** | Keyboard and controller mappings, directions, deadzone, PC shortcuts |
| **Gameplay** | All gameplay overrides |
| **Cheats & tools** | Cheats, Pokétch unlocks, Pokémon/item creation, map jumping |
| **Multiplayer** | Host/connect settings, player info |
| **Developer** | 30/60 FPS, screen layout and swap, frame/GPU timings, lighting previews, assertions, build info, ImGui demo |


<details>
<summary>Speed & text options</summary>

| Setting | Options |
| --- | --- |
| Battle pacing | **Smooth:** original effect timing with sprite interpolation. **Quick:** faster effects. **Turbo:** 3× effects, minimal pauses, near-instant fades. |
| Text | Normal, Fast, Faster, Instant. Overrides the in-game setting, in and out of battle. |
| HP/EXP bars | Normal, Fast, Faster |

Works with both Platinum and BW2 visuals. More in [battle speed settings](docs/battle_speed.md).

</details>

<details>
<summary>Changing bindings, gameplay options and tools</summary>

**Bindings:** select one, press the new input. Escape cancels. The window stays responsive during capture.

**Gameplay page** has evolution/eggs, encounters/events, progression/prices, moves/tutors, and battle rules.

- Changes save automatically; restart the game to apply them.
- **Classic Platinum** and **Single-screen mod** presets replace every option at once.
- More in [gameplay configuration](docs/gameplay_config.md).

**Cheats & tools:** creation and travel need normal overworld control.

</details>

<details>
<summary>How the menu behaves</summary>

**Layout**

- It is one centered panel. Categories replace the current page, and tools stay inside the panel.
- It remembers your category and scroll positions during the session.
- On small windows or large menu scales, categories collapse into a picker and pages scroll.

**Pausing**

- **Pause while open** is off by default.
- Closing with Tab, Escape, or Resume clears the automatic pause.
- **Developer → Manual pause** is separate and stays active after closing the panel.
- Automatic pause is suspended while hosting or connected to multiplayer. Menu input still stays out of gameplay.
- Escape cancels a binding or dialog, or returns from a tool, before it closes settings.

**Menu scale** (General)

- Auto, or 100–200% in 25% steps.
- Auto uses the display scale SDL reports. Use a manual value if yours is reported wrong.
- Fonts, spacing, controls, and dialogs scale together.
- Internal resolution changes game sharpness separately.

</details>

<details>
<summary>Where settings are stored</summary>

- PC settings save automatically to `sim_config.ini` and `sim_config_prj.ini`.
- The `[Interface]` section of `sim_config.ini` stores `MenuScalePercent` (0 = Auto) and `PauseWhileOpen`.
- Files without those values get Auto and no automatic pause.
- Gameplay overrides save automatically to `gameplay_config.ini` and load from it at startup.
- Settings the game can't use (wrong section, misspelled, invalid value) are reported as `[config]` lines on the console.
  `main --print-config` lists every effective setting and where it came from; see [configuration](docs/environment_variables.md).

</details>

## If the game crashes or freezes

Send `log.txt` from the game folder (and `log.prev.txt`, the previous run's log, if you've restarted since) with your bug
report. When the game crashes or stops responding for 5 seconds, it writes what it was doing there: where in the code,
which map and position, and your settings. More in [crash reports](docs/crash_reports.md).

## Saves

- **Save in-game before you quit.** Slots are `save1.bin`, `save2.bin`, and `save3.bin` in the game folder.
- **DS saves work as they are:** slots use the same format as a Platinum cartridge. Rename a `.sav` or DeSmuME `.dsv` to `save1.bin`, `save2.bin`, or `save3.bin` to play it here, or copy a slot file to a flashcart or emulator (rename it to `.sav`) to play it there.
- **Saves from older PC builds** used a different format. They're converted automatically on the first start, and the untouched original is kept as `save1.bak` (or `save1.1.bak` if that name is taken). To undo it, rename the `.bak` back to the slot name and use an older build. If the file can't be converted, it's left as it is and the slot shows as unavailable.
- **Back up your saves** before updating builds or deleting a slot.
- Loading a slot always uses your last **manual** save. Autosaves are separate.

<details>
<summary>Autosaves and restoring one</summary>

**What happens**

- A separate autosave is made every 2 minutes of real time.
- It goes in `autosave/`, for example `autosave/save1.bin.2026-10-28_14-30-00-0000.bak`.
- The newest 10 per slot are kept. Older ones are deleted after a successful autosave.
- During dialogue, menus, battles, transitions, communication or special activities, it waits for normal overworld control at a tile boundary.
- Autosaves never replace or create your normal slot files.
- Autosaves use a temporary file and atomic publication, so a failed one leaves existing saves intact.

**Restore one**

1. Close the game.
2. Copy or move the autosave over the slot file.
3. Rename it to `save1.bin`, `save2.bin`, or `save3.bin`.

**Turn it off:** **Tab → Developer → Saving → Autosave**. It applies immediately and is stored as `[Developer] Autosave` in `sim_config_prj.ini` (default: `true`).

</details>


## Build from source

- [Building from source](BUILD.MD)
- [Windows executable, built on Linux (MinGW)](docs/build_mingw.md)

### Development notes

- The opt-in Linux [gym autoplay tests](docs/autoplay_testing.md) play a fresh game through Roark, Gardenia, or Fantina, then save and reload to verify the earned badges. It uses isolated saves and a separate controller; the existing simulator autopilot remains available for bug reproduction.
- A separate [interaction scenario](docs/autoplay_testing.md#general-interaction-scenario) exercises the start menu, wild battles, switching, item rules, catching, PC deposit/withdrawal, and department-store purchases after Fantina.

## Credits

| Project | Role |
| --- | --- |
| [pret/pokeplatinum](https://github.com/pret/pokeplatinum) | Decompilation, documentation, original source tree |
| [cybervisi0n/pokeplatinum](https://github.com/cybervisi0n/pokeplatinum) | The native PC port this fork is built on |
| [cybervisi0n/libntr](https://github.com/cybervisi0n/libntr) | NitroSDK replacement libraries powering the port |
| [fuddlesworth/pokebw2](https://github.com/fuddlesworth/pokebw2/commits/main/) | BW2 battle engine |

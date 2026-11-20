# Pokémon Platinum Single-Screen — Nintendo Switch Port

Pokémon Platinum running natively on a modded Nintendo Switch: widescreen, on one screen, at full speed on stock clocks.

This is a Switch (homebrew, libnx) port of [elyro1/pokeplatinum-singlescreen](https://github.com/elyro1/pokeplatinum-singlescreen). That mod is built on [cybervisi0n's native PC port](https://github.com/cybervisi0n/pokeplatinum) of the [pret decompilation](https://github.com/pret/pokeplatinum). For the PC version, use the upstream projects.

> This fork is not affiliated with upstream, and its changes are not intended for upstream submission. The Switch work was developed with AI assistance (Claude). No game assets or builds are distributed here. You build the game yourself from this source.

## Status

- Overworld, menus and battles run at a locked 30 fps, which is full DS speed, at stock clocks with the recommended settings below.
- Boot to the title screen takes a few seconds.
- Launch it as a full application, through a forwarder or title takeover. Album/applet mode doesn't leave enough memory for the GL driver, so it crashes there.
- BW2 battle visuals need a Black 2 / White 2 ROM. They haven't been tested on the Switch.

## Controls

| Switch | DS |
| --- | --- |
| **D-pad** or **left stick** | D-pad: move and navigate |
| **A** | A: confirm and interact |
| **B** | B: cancel, and run where available |
| **X** | X: open or close the in-game menu |
| **Y** | Y: use a registered item |
| **L** / **R** | L / R, or previous / next Pokétch app |
| **+** | Start |
| **−** | Select |
| **ZL** | Open or close the settings overlay |

You can remap buttons under **ZL → Controls → Controller**.

## Features

These come from the single-screen mod:

- **Single-screen:** every screen is reworked to play on just the top screen.
- **Widescreen:** a wider overworld view and an adjusted world.
- **Black 2 / White 2 style battles.**
- **Three save slots:** pick one from the main menu.
- **Pokétch in the in-game menu:** once you have it, switch apps with L/R and leave with B or X.
- **Optional graphics extras:**
  - richer day/night lighting
  - improved model lighting
  - regional haze
  - character shadows
  - water, weather and night effects
  - bloom

  On the Switch, most of the extras cost performance; see [Recommended settings](#recommended-settings).
- **[Gameplay config](docs/gameplay_config.md):** independent gameplay overrides, so you can play how you want.

## Settings (press ZL)

ZL opens the settings overlay. Navigate it with the controller; touch input isn't supported.

| Page | What's there |
| --- | --- |
| **General** | Master volume, ROM info, BW2 battle visuals |
| **Graphics** | Internal resolution, VSync, frame cap, lighting, atmosphere, shadows, water, weather, bloom |
| **Speed & text** | Fast wild intros (BW2), battle pacing, text speed, HP/EXP bar speed, low-HP beep toggle, Improved Pokétch, single-screen bag |
| **Controls** | Controller mappings, directions, deadzone |
| **Gameplay** | All gameplay overrides |
| **Cheats & tools** | Cheats, Pokétch unlocks, Pokémon/item creation, map jumping |
| **Developer** | 30/60 FPS, frame timings, lighting previews, autosave |

Graphics toggles apply immediately. Gameplay changes save automatically, and apply after you restart the game.

<details>
<summary>Speed & text options</summary>

| Setting | Options |
| --- | --- |
| Battle pacing | **Smooth:** original effect timing with sprite interpolation. **Quick:** faster effects. **Turbo:** 3× effects, minimal pauses, near-instant fades. |
| Text | Normal, Fast, Faster, Instant. Overrides the in-game setting, in and out of battle. |
| HP/EXP bars | Normal, Fast, Faster |

More in [battle speed settings](docs/battle_speed.md).

</details>

<details>
<summary>Gameplay page, cheats and tools</summary>

- The **Gameplay** page has evolution/eggs, encounters/events, progression/prices, moves/tutors, and battle rules.
- The **Classic Platinum** and **Single-screen mod** presets replace every option at once. The defaults are the mod's, not the original game's (for example, cheaper BP prices and higher shiny odds). Pick **Classic Platinum** for the original rules.
- More in [gameplay configuration](docs/gameplay_config.md).
- **Cheats & tools:** creation and travel need normal overworld control.

</details>

<details>
<summary>Where settings are stored</summary>

All of these live in the game folder on the SD card, `sdmc:/switch/pokeplatinum_ss/`, and save automatically:

- `sim_config.ini`: resolution, VSync, frame cap, controller mappings
- `sim_config_prj.ini`: frame rate mode and graphics extras
- `gameplay_config.ini`: gameplay overrides
- `nx_env.txt`: Switch-specific options (optional; see below)

</details>

## Recommended settings

- **30 FPS** (`60Fps=false` in `sim_config_prj.ini`, or **Developer → Frame rate**): the original DS frame rate. The game's speed is tied to its frame rate. The mod's 60 fps mode needs twice the work per second, which the Switch can't sustain.
- **Keep the frame cap on** (`CapFrameRate=true` in `sim_config.ini`). With the cap off the game doesn't get smoother; it fast-forwards.
- **VSync off** (`VsyncInterval=0`, or `NX_VSYNC=0` in `nx_env.txt`) is the tested configuration. Pacing is done in software.
- **Internal resolution 2×** (3D at twice the DS resolution) fits the budget.
- **Graphics extras:** toggle them live on the *Graphics* page. Measured cost on stock clocks, as CPU time per 33 ms game tick:

| Setup | CPU per tick | Speed |
|---|---|---|
| All extras off, or only *Soft character shadows* | ~16–17.5 ms | 100% |
| + day/night grading, regional atmosphere, model lighting | ~17.5 ms (daytime) | 100% |
| + cast shadows, water and weather effects | up to ~27 ms in town | fits, little headroom |
| Everything on, at night (night lighting, glows, bloom) | ~25–26 ms, more with bloom | ~80–88% |

Soft character shadows with everything else off is the tested daily setup.

## Saves

- **Save in-game before you quit.** Slots are `save1.bin`, `save2.bin` and `save3.bin` in the game folder.
- **DS saves work as they are.** Slots use the same format as a Platinum cartridge:
  - To play an existing save here, rename a `.sav` or DeSmuME `.dsv` to `save1.bin`, `save2.bin` or `save3.bin`.
  - To play a save from here on a flashcart or emulator, copy the slot file over and rename it to `.sav`.
- **Back up your saves** before updating builds or deleting a slot.
- Loading a slot always uses your last **manual** save. Autosaves are separate.

<details>
<summary>Autosaves and restoring one</summary>

- An autosave is made every 2 minutes of real time, in `autosave/` (for example `autosave/save1.bin.2026-10-28_14-30-00-0000.bak`).
- The newest 10 per slot are kept.
- It waits for normal overworld control, outside dialogue, menus, battles and transitions.
- Autosaves never replace or create your normal slot files.

**To restore one:**

1. Close the game.
2. Copy the autosave over the slot file, for example from a PC with the SD card or over USB.
3. Rename it to `save1.bin`, `save2.bin` or `save3.bin`.

**To turn autosaves off:** **ZL → Developer → Saving → Autosave**.

</details>

## Building

You need Linux with Docker. The build runs in the `cybervisi0n/pokeplatinum-build:v2` image (devkitA64, libnx, portlibs).

The audio library SoundTouch has to be built for Switch once, into `nx_deps/` (gitignored):

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

## Installing

1. Copy the contents of `build_nx/pokeplatinum/` to `sdmc:/switch/pokeplatinum_ss/`. The `main` file in that folder isn't needed on the console.
2. Copy `build_nx/pokeplatinum_ss.nro` into the same folder.
3. Launch it as an application, for example with a forwarder pointing at that `.nro`.

When updating, replace only the `.nro` and the data folders. Keep your saves (`save*.bin`, `autosave/`) and settings files.

## `nx_env.txt` options

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

## What the Switch port changes

The renderer and SDK changes belong to [elyro1/libntr](https://github.com/elyro1/libntr), libntrsystem and libntrdwc. They are kept as patches in `subprojects/packagefiles/*-nx.patch`, and Meson applies them automatically when it fetches those subprojects (`diff_files` in the `.wrap` files).

- **Switch build target restored.** Meson cross files (`meson/cross_nx.ini`, plus `meson/cross_nx_opt2.ini` for `-O2` with the flags this codebase needs), packaging (`nx_meta/mknro.sh`), and a Docker helper (`drun_nx.sh`).
- **Switch compatibility.** The game's PC-port code paths are enabled for the Switch target. The Meson build cross-compiles the game and SDK libraries as position-independent code for the `.nro`, while build tools stay native. There are also fixes for devkitA64's GCC and newlib.
- **Faster 2D texture uploads.** On Switch Mesa (nouveau), every `glTexSubImage` allocates and frees a staging buffer through system calls. Uploads now go through a persistent, mapped buffer ring and a small GPU copy shader.
- **No stall on the next screen buffer.** The wait for a free swapchain buffer is deferred until the frame actually draws to it, instead of blocking right after each swap (about 11 ms per frame).
- **G2 compositor shader rewritten.** The shader read each layer from about 38 places inside unrolled loops, which made Mesa's register allocator spend about 4 minutes linking it at every launch. The driver can't cache compiled programs, so this happened every time. Each layer is now read once, which brings the link time to about 1 second, with identical output.
- **30 fps frame skip.** In 30 fps mode the game waits for two vblanks per tick, and the simulator drew and presented a full frame on both. The vblank that repeats the picture now runs only its interrupts and DMA.
- **Per-tick pacing.** A 30 fps tick is paced as one 33.3 ms slot instead of two 16.6 ms ones, so a slow first half no longer costs time.
- **Diagnostics.** `perf_log.txt` (per-step CPU and GPU time every 120 frames) and `boot_trace.txt` are written to the game folder. The sampling profiler and per-frame traces are opt-in (see above).

## Known issues

- With every extra on at night, the game runs at about 80–88% speed.
- Fast-forward is bound to a keyboard key only, so it isn't available on the Switch.
- The GPU timestamps in `perf_log.txt` read about 1.6× low on this driver.
- If something goes wrong, `boot_trace.txt` and `perf_log.txt` in the game folder show how far startup got and how each frame was spent.

## Credits

| Project | Role |
| --- | --- |
| [pret/pokeplatinum](https://github.com/pret/pokeplatinum) | Decompilation, documentation, original source tree |
| [cybervisi0n/pokeplatinum](https://github.com/cybervisi0n/pokeplatinum) | The native PC port, including its original Switch target |
| [cybervisi0n/libntr](https://github.com/cybervisi0n/libntr) | NitroSDK replacement libraries powering the port |
| [elyro1/pokeplatinum-singlescreen](https://github.com/elyro1/pokeplatinum-singlescreen) and [elyro1/libntr](https://github.com/elyro1/libntr) | The single-screen mod this fork ports |
| [fuddlesworth/pokebw2](https://github.com/fuddlesworth/pokebw2/commits/main/) | BW2 battle engine |
| [SoundTouch](https://codeberg.org/soundtouch/soundtouch) | Audio time-stretching |

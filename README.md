<div align="center">
  <a href="https://github.com/coonlink">
    <img src="https://raw.coonlink.com/cloud/AeroShake.png" alt="Aero Shake Logo" width="180"/>
  </a>
  <h1>Aero Shake for Linux</h1>

[![English](https://img.shields.io/badge/lang-English%20🇺🇸-white)](README.md)
[![Русский](https://img.shields.io/badge/язык-Русский%20🇷🇺-white)](README.ru.md)

<img alt="last-commit" src="https://img.shields.io/github/last-commit/crc137/Aero-Shake-for-Linux?style=flat&logo=git&logoColor=white&color=0080ff" style="margin: 0px 2px;">
<img alt="repo-top-language" src="https://img.shields.io/github/languages/top/crc137/Aero-Shake-for-Linux?style=flat&color=0080ff" style="margin: 0px 2px;">
<img alt="repo-language-count" src="https://img.shields.io/github/languages/count/crc137/Aero-Shake-for-Linux?style=flat&color=0080ff" style="margin: 0px 2px;">
<img alt="version" src="https://img.shields.io/badge/version-1.0.0-blue" style="margin: 0px 2px;">
<img src="https://img.shields.io/badge/made%20by-coonlink-blueviolet?style=flat-square" alt="coonlink" />

<sub><i>Bring Windows-style "Aero Shake" window minimizing to your Linux desktop.</i></sub>

A port of the classic Windows Aero Shake feature: grab a window by its title bar, shake it left and right, and all other open windows are minimized. The active window stays where it is.

<p align="center">
  <img src="https://raw.coonlink.com/cloud/2026-07-01%2015-39-24.gif" alt="Aero Shake Demo" width="800"/>
</p>

</div>

## Features

- **Aero Shake emulation** — shake the active window left-right to minimize everything else on the current desktop
- **System tray integration** — Enable/Disable/Quit via a tray icon
- **Direction-reversal detection** — tracks movement reversals in a rolling time window with a cooldown to avoid false triggers
- **Autostart** — installs a `.desktop` entry in `~/.config/autostart/`
- **Icon fallback** — icons are fetched remotely during install; if missing at runtime, simple icons are generated on the fly with Pillow
- **GNOME animation nudge** — installer enables `enable-animations` via `gsettings` so minimize animations look smooth (no-op / silently skipped outside GNOME)
- **Duplicate-run guard** — re-running the installer while the app is already running just removes the autostart entry instead of spawning a second instance

## Tech Stack

| Layer | Technology |
|---|---|
| Application logic | Python 3, `subprocess`, `threading`, `time` |
| Desktop & UI integration | `xdotool`, `pystray`, Pillow, `python3-gi`, `gir1.2-ayatanaappindicator3-0.1` (or `gir1.2-appindicator3-0.1`), X11 (Xorg) |
| Installation | Bash, `curl`, `apt` |

## Requirements

- X11 (Xorg) — Wayland is **not** supported, `xdotool` doesn't work properly there
- Python 3
- sudo privileges (installer needs to `apt install` system packages)

## Installation

```bash
curl -sSL https://raw.coonlink.com/cloud/aero_shake.sh | bash
```

Or manually:

```bash
sudo apt install -y xdotool
sudo mkdir -p /opt/aero_shake
sudo curl -sSL https://raw.coonlink.com/cloud/aero_shake.py -o /opt/aero_shake/aero_shake.py
sudo chmod +x /opt/aero_shake/aero_shake.py
python3 /opt/aero_shake/aero_shake.py
```

The installer downloads dependencies, sets up `/opt/aero_shake`, pulls the tray icons, and registers autostart — no manual step needed on future logins.

## Usage

Once installed, the script runs in the background and a tray icon appears next to your volume/mic controls. Click it for Enable/Disable/Quit.

While enabled: grab any window by its title bar, shake it left-right a few times quickly, and every other window on the current desktop minimizes.

To run or stop manually:

```bash
python3 /opt/aero_shake/aero_shake.py   # run manually
pkill -f aero_shake.py                  # stop
```

## How It Works

A background thread polls the active window's position (`xdotool getactivewindow` + `getwindowgeometry`) every 50ms. On each poll it computes movement along the dominant axis (whichever of dx/dy is larger) since the last poll. If that movement exceeds a threshold, it registers a direction (left/right or up/down); whenever the direction flips from the previous one, a "reversal" timestamp is recorded. Once 4+ reversals land within a 0.6s rolling window, all windows on the current desktop except the active one are minimized via `xdotool windowminimize` (found through `xdotool search --desktop <id>`). A 2-second cooldown follows each trigger to prevent repeat firing. The tray icon (`pystray`) runs on the main thread and toggles enable/disable without killing the process; disabling clears the reversal history.

## Settings

All parameters are hardcoded in `aero_shake.py`:

| Variable | What it does | Default |
|---|---|---|
| `MIN_STEP` | Movement threshold (px) to count as a directional step | 12 |
| `MIN_REVERSALS` | Direction reversals required to trigger | 4 |
| `WINDOW_SEC` | Rolling window for counting reversals (s) | 0.6 |
| `cooldown_until = now + 2` | Cooldown after trigger (s) | 2 |
| `time.sleep(0.05)` | Polling interval (s) | 0.05 |
| `AERO_SHAKE_ICON_DIR` (env var) | Where tray icon PNGs are loaded from | `/opt/aero_shake` |

## Known Limitations

- Poll-based, not event-driven — `xdotool getwindowgeometry` can lag under load, causing false positives/negatives
- Triggers on all windows regardless of mouse button, including programmatic moves
- Tested on XFCE; `xdotool windowminimize` behavior on GNOME/KDE may vary by compositor
- Running the installer again while the app is already running removes the autostart entry instead of restarting it — re-download and run `aero_shake.py` manually if you need a fresh instance
- Misbehaving? Click "Disable" in the tray, or `pkill -f aero_shake.py`
- Tray icon needs an AppIndicator-compatible tray — on WMs without one, minimizing still works, just without the toggle
- To disable autostart: remove `~/.config/autostart/aero-shake.desktop`

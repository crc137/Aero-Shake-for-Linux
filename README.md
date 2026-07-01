<p align="center">
  <img src="https://raw.coonlink.com/cloud/AeroShake.png" alt="Aero Shake Logo" width="180"/>
</p>

# Aero Shake for Linux

A port of the classic Windows Aero Shake feature: grab a window by its title bar, shake it left and right, and all other open windows are minimized. The active window stays where it is.

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

## Dependencies

- `xdotool`
- Python 3, `pystray`, `pillow`
- `python3-gi` + `gir1.2-ayatanaappindicator3-0.1` (or `gir1.2-appindicator3-0.1`) — for tray icon support
- X11 (Xorg). Wayland is not supported — `xdotool` does not work properly there.

## Usage

After installation, the script runs in the background and a tray icon appears (next to the volume/mic controls). Click the icon for a menu with "Enable/Disable" and "Quit". While enabled, grab any window by its title bar and shake it left-right several times quickly. All other windows on the current desktop will be minimized.

The script will start automatically on your next login via `~/.config/autostart/aero-shake.desktop`—no need to start it manually every time.

## How it works

A separate thread continuously polls the active window's position (`xdotool getactivewindow` + `getwindowgeometry`) at a 50ms interval. If the total movement between polls exceeds a threshold, it counts as a "shake." If you accumulate 4+ shakes within 1.2 seconds, all windows on the current desktop except the active one are minimized via `xdotool windowminimize`. After triggering, there's a 2 second cooldown to prevent repeated minimizing. The tray icon (via `pystray`) is managed in the main thread and lets you enable or disable without killing the process.

## Settings

Parameters are hardcoded in `aero_shake.py` and can be changed directly:

| Variable                                   | What it does                             | Default |
|---------------------------------------------|------------------------------------------|---------|
| `distance > 15`                            | Movement threshold (px) to count as shake| 15      |
| `shake_count >= 4`                         | Number of shakes required to trigger     | 4       |
| `time.time() - first_shake_time < 1.2`     | Accumulation window for shakes (seconds) | 1.2     |
| `cooldown_until = time.time() + 2`         | Cooldown after trigger (seconds)         | 2       |
| `time.sleep(0.05)`                         | Polling interval (seconds)               | 0.05    |

## Known limitations

- Poll-based detection (not event-driven) — on heavily loaded systems, `xdotool getwindowgeometry` can lag, causing false positives/negatives.
- Works on all windows of the current desktop regardless of mouse button (programmatic window movements are also counted as shakes).
- Tested on XFCE. Behavior of `xdotool windowminimize` on GNOME/KDE may vary depending on compositor.
- If the script misbehaves (spamming minimizes, stuck behavior), click "Disable" in the tray menu or run `pkill -f aero_shake.py`.
- Tray icon requires an AppIndicator-compatible tray. On some lightweight WMs (without a panel supporting indicators), the tray icon may not appear—minimizing will still work, just without the tray toggle.
- Icons (`AeroShake.enabled.png` / `AeroShake.disabled.png`) are fetched from `raw.coonlink.com/cloud/` during install. If the files are unavailable, the script uses fallback icons and logs a warning.
- To disable autostart: remove `~/.config/autostart/aero-shake.desktop`.

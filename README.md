<p align="center">
  <img src="https://raw.coonlink.com/cloud/AeroShake.png" alt="Aero Shake Logo" width="180"/>
</p>

# Aero Shake for Linux

A port of the classic Windows Aero Shake feature: grab a window by its title bar and quickly shake it left and right — all other open windows are minimized. The active window stays where it is.

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
- Python 3, with `pystray`, `pillow`
- `python3-gi` + `gir1.2-ayatanaappindicator3-0.1` (or `gir1.2-appindicator3-0.1`) — for tray icon support
- X11 (Xorg). Wayland is not supported — `xdotool` does not work reliably there.

## Usage

After installation, the script runs in the background and displays a tray icon (near the volume/mic indicators). Click the icon for a menu to Enable/Disable or Quit. While enabled, grab a window by its title bar and shake it quickly left and right several times. All other windows on the current desktop will be minimized.

On next login, the script will start automatically (via `~/.config/autostart/aero-shake.desktop`). There's no need to launch it manually each time.

## How it works

A background thread monitors the active window's position (`xdotool getactivewindow` and `getwindowgeometry`) every 50 ms. If the movement distance between checks exceeds a threshold, a "shake" is counted. If 4 or more shakes occur within 1.2 seconds, all other windows on the desktop are minimized with `xdotool windowminimize`. After activation, there’s a 2-second cooldown to avoid repeated triggers. The tray icon (via `pystray`) in the main thread allows enabling/disabling the script without killing the process.

## Settings

Parameters are hardcoded in `aero_shake.py` and can be changed directly:

| Variable                             | Description                               | Default |
|---------------------------------------|-------------------------------------------|---------|
| `distance > 15`                      | Movement threshold (pixels) for a shake   | 15      |
| `shake_count >= 4`                    | Shakes needed to trigger                  | 4       |
| `time.time() - first_shake_time < 1.2`| Time window to accumulate shakes (sec)    | 1.2     |
| `cooldown_until = time.time() + 2`    | Cooldown after activation (sec)           | 2       |
| `time.sleep(0.05)`                    | Polling interval (sec)                    | 0.05    |

## Known limitations

- Detection is poll-based, not event-based — on overloaded systems, `xdotool getwindowgeometry` may be slow, possibly causing false positives or misses.
- Works on every window on the current desktop regardless of whether the mouse button is pressed — programmatically moving a window can also count as a shake.
- Tested on XFCE. On GNOME/KDE, behavior of `xdotool windowminimize` may vary according to the compositor.
- If the script malfunctions (excessive minimization, gets stuck), use "Disable" from the tray menu or run `pkill -f aero_shake.py`.
- The tray icon requires an AppIndicator-compatible tray. In some lightweight window managers (without a panel supporting indicators), the icon may not appear — the window minimizing logic still works in the background, just without a toggle.
- To disable autostart, remove `~/.config/autostart/aero-shake.desktop`.

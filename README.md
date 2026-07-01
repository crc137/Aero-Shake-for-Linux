<p align="center">
  <img src="https://raw.coonlink.com/cloud/AeroShake.png" alt="Aero Shake Logo" width="180"/>
</p>

# Aero Shake for Linux

A port of the classic Windows Aero Shake feature: grab a window by the title bar and shake it left and right—instantly, all other open windows get minimized, leaving only your active window on screen.

## Installation

```bash
curl -sSL https://raw.coonlink.com/cloud/aero_shake.sh | sh
```

Or install manually:

```bash
sudo apt install -y xdotool
sudo mkdir -p /opt/aero_shake
sudo curl -sSL https://raw.coonlink.com/cloud/aero_shake.py -o /opt/aero_shake/aero_shake.py
sudo chmod +x /opt/aero_shake/aero_shake.py
python3 /opt/aero_shake/aero_shake.py
```

## Dependencies

- `xdotool`
- Python 3
- X11 (Xorg). *Wayland is not supported*—`xdotool` does not work properly there.

## Usage

Run the script (in the terminal or as a background process), then grab a window by its title bar with your mouse and quickly shake it back and forth several times. All other windows on the current desktop will be minimized.

## How it works

The script polls the position of the active window (`xdotool getactivewindow` + `getwindowgeometry`) every 50ms. If the total movement between polls exceeds a threshold, it counts as a “shake”. When 4 or more shakes are detected within 1.2 seconds, all other windows (on the current desktop, except the active one) are minimized using `xdotool windowminimize`. After triggering, there's a 2-second cooldown to prevent rapid repeats.

## Settings

Parameters are hardcoded in `aero_shake.py` and can be modified there:

| Variable                              | Description                                   | Default |
|----------------------------------------|-----------------------------------------------|---------|
| `distance > 15`                       | Movement threshold (pixels) to register a shake | 15      |
| `shake_count >= 4`                    | Number of shakes needed to trigger action     | 4       |
| `time.time() - first_shake_time < 1.2`| Time window to accumulate shakes (seconds)    | 1.2     |
| `cooldown_until = time.time() + 2`    | Pause after trigger (seconds)                 | 2       |
| `time.sleep(0.05)`                    | Polling interval (seconds)                    | 0.05    |

## Known limitations

- Poll-based detection (not event-driven). On heavily loaded systems, `xdotool getwindowgeometry` can lag, resulting in missed or false shake detection.
- Works for all windows on the current desktop and does not verify if the mouse button is held—any programmatic window move can count as a shake.
- Tested on XFCE. On GNOME/KDE, the behavior of `xdotool windowminimize` can vary with compositor.
- If the script misbehaves (e.g., repeatedly minimizes, gets stuck), use `Ctrl+C` in the terminal where it’s running, or terminate with `pkill -f aero_shake.py`.

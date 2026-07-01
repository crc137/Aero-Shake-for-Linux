# Aero Shake for Linux

A port of the classic Windows Aero Shake feature: grab a window by the title bar and shake it left and right — all other open windows get minimized, leaving the active window untouched.

## Installation

```bash
curl -sSL https://raw.coonlink.com/cloud/aero_shake.sh | bash
```

Or, install manually:

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
- X11 (Xorg). Wayland is not supported — `xdotool` does not work properly there.

## Usage

Run the script (from terminal or as a background process), then grab a window by its title bar with the mouse and quickly shake it back and forth several times. All other windows on the current desktop will be minimized.

## How it works

The script polls the position of the active window (`xdotool getactivewindow` + `getwindowgeometry`) every 50 ms. If the total movement detected between polls exceeds a threshold, it counts as a “shake”. If 4 or more shakes accumulate within 1.2 seconds, all windows on the current desktop (except the active one) are minimized using `xdotool windowminimize`. After triggering, there is a 2-second cooldown to prevent rapid repeats.

## Settings

Parameters are hardcoded in `aero_shake.py` and can be edited directly:

| Variable                              | Description                                   | Default |
|----------------------------------------|-----------------------------------------------|---------|
| `distance > 15`                       | Movement threshold (px) to register a shake   | 15      |
| `shake_count >= 4`                    | Number of shakes needed to trigger            | 4       |
| `time.time() - first_shake_time < 1.2`| Time window to accumulate shakes (seconds)    | 1.2     |
| `cooldown_until = time.time() + 2`    | Pause after triggering (seconds)              | 2       |
| `time.sleep(0.05)`                    | Polling interval (seconds)                    | 0.05    |

## Known limitations

- Poll-based detection (not event-driven) — on heavily loaded systems, `xdotool getwindowgeometry` may lag, causing missed or false shake detections.
- Works for all windows on the current desktop, regardless of whether the mouse button is held — programmatic window movement also counts as a shake.
- Tested on XFCE. On GNOME/KDE, behavior of `xdotool windowminimize` may vary depending on the compositor.
- If the script behaves unexpectedly (e.g., spamming minimizes, getting stuck), use `Ctrl+C` in the terminal where it’s running, or kill with `pkill -f aero_shake.py`.

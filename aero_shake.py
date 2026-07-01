#!/usr/bin/env python3
import subprocess
import threading
import time

import os

import pystray
from PIL import Image, ImageDraw

enabled = True

ICON_DIR = os.environ.get("AERO_SHAKE_ICON_DIR", "/opt/aero_shake")
ICON_ENABLED_PATH = os.path.join(ICON_DIR, "AeroShake.enabled.png")
ICON_DISABLED_PATH = os.path.join(ICON_DIR, "AeroShake.disabled.png")


def get_active_window():
    try:
        return subprocess.check_output(["xdotool", "getactivewindow"]).strip().decode()
    except Exception:
        return None


def get_window_position(win_id):
    try:
        out = subprocess.check_output(["xdotool", "getwindowgeometry", "--shell", win_id]).decode()
        x = int([line for line in out.splitlines() if line.startswith("X=")][0].split("=")[1])
        y = int([line for line in out.splitlines() if line.startswith("Y=")][0].split("=")[1])
        return x, y
    except Exception:
        return None, None


def minimize_all_except(active_win):
    try:
        desktop = subprocess.check_output(["xdotool", "get_desktop"]).strip().decode()
        windows = subprocess.check_output(
            ["xdotool", "search", "--all", "--maxdepth", "3", "--desktop", desktop, "--name", ".*"]
        ).decode().splitlines()
        for w in windows:
            w = w.strip()
            if w and w != active_win:
                subprocess.run(["xdotool", "windowminimize", w], timeout=0.5)
    except Exception as e:
        print("Error:", e)


def watch_loop():
    last_win, last_pos, shake_count = None, None, 0
    first_shake_time, cooldown_until = time.time(), 0
    while True:
        if not enabled:
            last_win, last_pos, shake_count = None, None, 0
            time.sleep(0.2)
            continue

        current_win = get_active_window()
        if current_win:
            x, y = get_window_position(current_win)
            if x is not None and y is not None:
                if current_win == last_win and last_pos is not None:
                    distance = abs(x - last_pos[0]) + abs(y - last_pos[1])
                    if time.time() >= cooldown_until and distance > 15:
                        if shake_count == 0:
                            first_shake_time = time.time()
                        shake_count += 1
                        if shake_count >= 4 and (time.time() - first_shake_time < 1.2):
                            minimize_all_except(current_win)
                            shake_count = 0
                            cooldown_until = time.time() + 2
                else:
                    shake_count = 0
                last_pos, last_win = (x, y), current_win
        time.sleep(0.05)


def fallback_icon_image(active: bool) -> Image.Image:
    size = 22
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    color = (80, 200, 120, 255) if active else (140, 140, 140, 255)
    d.rectangle([3, 5, 19, 17], outline=color, width=2)
    if not active:
        d.line([2, 2, 20, 20], fill=(200, 60, 60, 255), width=2)
    return img


def load_icon_image(active: bool) -> Image.Image:
    path = ICON_ENABLED_PATH if active else ICON_DISABLED_PATH
    try:
        return Image.open(path).convert("RGBA")
    except Exception:
        print(f"Icon not found at {path}, using fallback image.")
        return fallback_icon_image(active)


def toggle(icon, item):
    global enabled
    enabled = not enabled
    icon.icon = load_icon_image(enabled)
    icon.title = f"Aero Shake: {'enabled' if enabled else 'disabled'}"


def quit_app(icon, item):
    icon.stop()


def status_text(item):
    """Return the current enable/disable menu text (for pystray)."""
    return "Disable" if enabled else "Enable"


def main():
    threading.Thread(target=watch_loop, daemon=True).start()
    menu = pystray.Menu(
        pystray.MenuItem(status_text, toggle),
        pystray.MenuItem("Quit", quit_app),
    )
    icon = pystray.Icon("aero_shake", load_icon_image(True), "Aero Shake: enabled", menu)
    icon.run()


if __name__ == "__main__":
    main()
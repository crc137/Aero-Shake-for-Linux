#!/usr/bin/env python3
import subprocess
import time
import sys

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
        windows = subprocess.check_output(["xdotool", "search", "--all", "--maxdepth", "3","--desktop", desktop, "--name", ".*"]).decode().splitlines()
        count = 0
        for w in windows:
            w = w.strip()
            if w and w != active_win:
                subprocess.run(["xdotool", "windowminimize", w], timeout=0.5)
                count += 1
        print(f"Aero Shake: minimized {count} windows")
    except Exception as e:
        print("Error:", e)

print("Aero Shake for Linux started (shake window)")
print("Grab the window by the title bar and shake — all others will minimize.\n")

last_win = None
last_pos = None
shake_count = 0
first_shake_time = time.time()
cooldown_until = 0

try:
    while True:
        current_win = get_active_window()
        if current_win:
            x, y = get_window_position(current_win)
            if x is not None and y is not None:
                if current_win == last_win and last_pos is not None:
                    dx = abs(x - last_pos[0])
                    dy = abs(y - last_pos[1])
                    distance = dx + dy
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
                last_pos = (x, y)
                last_win = current_win
        time.sleep(0.05)

except KeyboardInterrupt:
    print("Aero Shake stopped.")
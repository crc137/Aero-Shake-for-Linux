#!/usr/bin/env bash
set -e

INSTALL_DIR="/opt/aero_shake"
SCRIPT_URL="https://raw.coonlink.com/cloud/aero_shake.py"
AUTOSTART_DIR="$HOME/.config/autostart"

cat << 'EOF'
   ___                _____  _           _        
  / _ \ _ __  ___    /  _  \| | __ _  __| | ___   
 / /_)/ '__|/ _ \   | | | | | |/ _` |/ _` |/ _ \  
/ ___/| |  | (_) |  | |_| | | | (_| | (_| | (_) | 
\/    |_|   \___/    \____/|_|\__,_|\__,_|\___/  
        
EOF

RUNNING_COUNT=$(pgrep -fc "python3 $INSTALL_DIR/aero_shake.py")
if [ "$RUNNING_COUNT" -gt 0 ]; then
    echo "Aero Shake is already running ($RUNNING_COUNT processes)."
    echo "Removing autostart entry and not creating new processes..."
    if [ -f "$AUTOSTART_DIR/aero-shake.desktop" ]; then
        rm "$AUTOSTART_DIR/aero-shake.desktop"
        echo "Autostart entry removed: $AUTOSTART_DIR/aero-shake.desktop."
    fi
    echo "Done."
    echo "You can start Aero Shake manually by running: python3 $INSTALL_DIR/aero_shake.py"
    exit 0
fi

echo "==> Checking if window animations are enabled (Gnome)..."
gsettings get org.gnome.desktop.interface enable-animations 2>/dev/null || true
gsettings set org.gnome.desktop.interface enable-animations true 2>/dev/null || true

echo "==> Installing dependencies (xdotool + tray support)..."
sudo apt install -y xdotool python3-pip python3-gi gir1.2-ayatanaappindicator3-0.1 \
  || sudo apt install -y xdotool python3-pip python3-gi gir1.2-appindicator3-0.1
pip install --user --break-system-packages pystray pillow

echo "==> Creating $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"

echo "==> Downloading aero_shake.py..."
sudo curl -sSL "$SCRIPT_URL" -o "$INSTALL_DIR/aero_shake.py"
sudo chmod +x "$INSTALL_DIR/aero_shake.py"

echo "==> Downloading tray icons..."
sudo curl -sSL "https://raw.coonlink.com/cloud/AeroShake.enabled.png" -o "$INSTALL_DIR/AeroShake.enabled.png"
sudo curl -sSL "https://raw.coonlink.com/cloud/AeroShake.disabled.png" -o "$INSTALL_DIR/AeroShake.disabled.png"

echo "==> Setting up autostart on login..."
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/aero-shake.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Aero Shake
Comment=Shaking a window minimizes all others — just like on Windows
Exec=python3 $INSTALL_DIR/aero_shake.py
Icon=preferences-desktop-display
X-GNOME-Autostart-enabled=true
Terminal=false
EOF

echo "==> Starting Aero Shake in the background..."
nohup python3 "$INSTALL_DIR/aero_shake.py" >/tmp/aero_shake.log 2>&1 &
disown

echo "==> Done. You'll see a tray icon next to your volume/mic controls—click it to toggle enable/disable."
echo "==> The script will start automatically next time you log in."
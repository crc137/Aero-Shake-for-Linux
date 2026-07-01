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

echo "==> Checking: are window animations enabled (Gnome)..."
gsettings get org.gnome.desktop.interface enable-animations 2>/dev/null || true
gsettings set org.gnome.desktop.interface enable-animations true 2>/dev/null || true

echo "==> Installing dependencies (xdotool + system tray)..."
sudo apt install -y xdotool python3-pip python3-gi gir1.2-ayatanaappindicator3-0.1 \
  || sudo apt install -y xdotool python3-pip python3-gi gir1.2-appindicator3-0.1
pip install --user --break-system-packages pystray pillow

echo "==> Creating $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"

echo "==> Downloading aero_shake.py..."
sudo curl -sSL "$SCRIPT_URL" -o "$INSTALL_DIR/aero_shake.py"
sudo chmod +x "$INSTALL_DIR/aero_shake.py"

echo "==> Setting up autostart on login..."
mkdir -p "$AUTOSTART_DIR"
cat > "$AUTOSTART_DIR/aero-shake.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Aero Shake
Comment=Shaking a window minimizes all others — just like in Windows
Exec=python3 $INSTALL_DIR/aero_shake.py
Icon=preferences-desktop-display
X-GNOME-Autostart-enabled=true
Terminal=false
EOF

echo "==> Starting Aero Shake in the background..."
nohup python3 "$INSTALL_DIR/aero_shake.py" >/tmp/aero_shake.log 2>&1 &
disown

echo "==> Done. There will be an icon in your system tray (next to volume/mic). Click to enable/disable."
echo "==> The script will start automatically the next time you log in."
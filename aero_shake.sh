#!/usr/bin/env bash
set -e

INSTALL_DIR="/opt/aero_shake"
SCRIPT_URL="https://raw.coonlink.com/cloud/aero_shake.py"

echo "==> Проверка: включена ли анимация окон (Gnome)..."
echo "# проверить, включена ли анимация"
gsettings get org.gnome.desktop.interface enable-animations

echo "# включить (должно быть true)"
gsettings set org.gnome.desktop.interface enable-animations true

echo "==> Установка xdotool..."
sudo apt install -y xdotool

echo "==> Создание $INSTALL_DIR..."
sudo mkdir -p "$INSTALL_DIR"

echo "==> Загрузка aero_shake.py..."
sudo curl -sSL "$SCRIPT_URL" -o "$INSTALL_DIR/aero_shake.py"

echo "==> Делаем исполняемым..."
sudo chmod +x "$INSTALL_DIR/aero_shake.py"

echo "==> Запуск Aero Shake..."
exec python3 "$INSTALL_DIR/aero_shake.py"

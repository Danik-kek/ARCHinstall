#!/bin/bash
# install-hyprland.sh for ArcHIChanAdmin
# Fully automatic Hyprland setup on clean Arch (AMD)

set -e

echo "🚀 Скрипт запущен. Устанавливаю Hyprland..."

# === 1. Обновление системы и зависимости ===
echo "📦 Обновляю систему..."
sudo pacman -Syu --noconfirm

echo "🔧 Ставлю базовые зависимости..."
sudo pacman -S --noconfirm base-devel git wget

# === 2. Добавление Chaotic-AUR ===
echo "🔑 Импортирую GPG-ключ Chaotic-AUR..."
sudo pacman-key --keyserver keyserver.ubuntu.com --recv-keys 3056513887B78AEB
sudo pacman-key --lsign-key 3056513887B78AEB

echo "📥 Скачиваю keyring и mirrorlist..."
wget -qO /tmp/chaotic-keyring.pkg.tar.zst 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
wget -qO /tmp/chaotic-mirrorlist.pkg.tar.zst 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
sudo pacman -U --noconfirm /tmp/chaotic-keyring.pkg.tar.zst /tmp/chaotic-mirrorlist.pkg.tar.zst

echo "📝 Добавляю репозиторий в pacman.conf..."
echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

# === 3. Установка Hyprland и окружения ===
echo "🖥️ Устанавливаю Hyprland и сопутствующие пакеты..."
sudo pacman -Sy --noconfirm
sudo pacman -S --noconfirm \
    hyprland \
    waybar \
    wofi \
    foot \
    kitty \
    swaybg \
    grim \
    slurp \
    swappy \
    thunar \
    xdg-desktop-portal-hyprland \
    pipewire \
    pipewire-pulse \
    pipewire-jack

# === 4. Запуск PipeWire ===
echo "🔊 Запускаю PipeWire..."
systemctl --user enable --now pipewire pipewire-pulse

# === 5. Создание конфига Hyprland ===
echo "🛠️ Настраиваю Hyprland..."
mkdir -p ~/.config/hypr

cat > ~/.config/hypr/hyprland.conf <<'EOF'
# Hyprland config — создано для ArcHIChanAdmin

# Автозапуск
exec-once = waybar
exec-once = swaybg -c '#1e1e2e'

# Горячие клавиши
bind = SUPER, Return, exec, kitty
bind = SUPER, W, exec, firefox
bind = SUPER, Q, killactive,
bind = SUPER, M, exit,

# Тайлинг
layout = dwindle

# Монитор (автоопредление)
monitor = ,preferred,auto,1

# Декорации
decoration {
    rounding = 8
    blur {
        enabled = true
        size = 3
    }
}

# Окна
general {
    gaps_in = 5
    gaps_out = 10
}
EOF

# === 6. Завершение ===
echo ""
echo "✅ ВСЁ ГОТОВО!"
echo "Чтобы запустить Hyprland:"
echo "  1. Переключись в tty1: Ctrl+Alt+F1"
echo "  2. Залогинься как Kanna4ka"
echo "  3. Выполни: Hyprland"
echo ""

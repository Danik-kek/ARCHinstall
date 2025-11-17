#!/bin/bash
# install-hyprland.sh — полная автоматическая установка Hyprland для ArcHIChanAdmin
# Работает на реальном AMD-железе и в VirtualBox

set -e

echo "🚀 Запуск установки Hyprland для ArcHIChanAdmin..."

# === 1. Обновление системы ===
echo "📦 Обновление системы..."
sudo pacman -Syu --noconfirm

# === 2. Установка базовых зависимостей ===
echo "🔧 Установка зависимостей..."
sudo pacman -S --noconfirm base-devel git wget curl

# === 3. Включение multilib (для Steam и 32-битных приложений) ===
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "💿 Включение multilib..."
    sudo sed -i '/^\[multilib\]/,/Include =/s/^#//' /etc/pacman.conf
    sudo pacman -Sy --noconfirm
fi

# === 4. Настройка российских зеркал через reflector ===
echo "🇷🇺 Настройка российских зеркал..."
sudo pacman -S --noconfirm reflector
sudo reflector --country Russia --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Sy --noconfirm

# === 5. Добавление Chaotic-AUR (без git clone!) ===
echo "🔑 Импорт ключа Chaotic-AUR..."
sudo pacman-key --keyserver keyserver.ubuntu.com --recv-keys 3056513887B78AEB
sudo pacman-key --lsign-key 3056513887B78AEB

echo "📥 Установка chaotic-keyring и chaotic-mirrorlist..."
wget -qO /tmp/chaotic-keyring.pkg.tar.zst 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
wget -qO /tmp/chaotic-mirrorlist.pkg.tar.zst 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
sudo pacman -U --noconfirm /tmp/chaotic-keyring.pkg.tar.zst /tmp/chaotic-mirrorlist.pkg.tar.zst

echo "📝 Добавление репозитория в pacman.conf..."
echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
sudo pacman -Sy --noconfirm

# === 6. Установка Hyprland и всего окружения ===
echo "🖥️ Установка Hyprland, Steam, окружения..."
sudo pacman -S --noconfirm \
    hyprland \
    waybar \
    wofi \
    foot \
    fish \
    dolphin \
    thunar \
    xdg-desktop-portal-hyprland \
    mesa \
    vulkan-radeon \
    lib32-mesa \
    lib32-vulkan-radeon \
    steam \
    proton-ge-custom \
    noto-fonts \
    ttf-liberation \
    gamemode

# === 7. Настройка локалей (en_US + ru_RU) ===
echo "🌍 Настройка языка и раскладки..."
sudo sed -i 's/^#\(en_US.UTF-8\)/\1/' /etc/locale.gen
sudo sed -i 's/^#\(ru_RU.UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf

# === 8. Создание конфига Hyprland ===
echo "🛠️ Настройка Hyprland..."
mkdir -p ~/.config/hypr

cat > ~/.config/hypr/hyprland.conf <<'EOF'
# Hyprland config — ArcHIChanAdmin Edition

# Input
input {
    kb_layout = us,ru
    kb_options = grp:alt_shift_toggle
}

# Environment
env = XDG_CURRENT_DESKTOP,Hyprland
env = SDL_VIDEODRIVER,wayland
env = MOZ_ENABLE_WAYLAND,1

# Autostart
exec-once = waybar
exec-once = swaybg -c '#2e3440'

# Keybinds
bind = SUPER, T, exec, foot
bind = SUPER, E, exec, dolphin
bind = SUPER, S, exec, wofi --show drun
bind = SUPER, G, exec, steam
bind = SUPER, Q, killactive,
bind = SUPER, M, exit,

# Window rules
dwindle {
    pseudotile = yes
    preserve_split = yes
}

# Monitor
monitor = ,preferred,auto,1

# Decorations
decoration {
    rounding = 8
    blur {
        enabled = true
        size = 3
    }
}

# Gaps
general {
    gaps_in = 5
    gaps_out = 10
}
EOF

# === 9. Настройка пользователя: fish + foot + dolphin ===
echo "🐚 Настройка fish + foot + dolphin..."

# Сделать fish оболочкой по умолчанию
chsh -s /usr/bin/fish

# Конфиг foot
mkdir -p ~/.config/foot
cat > ~/.config/foot/foot.ini <<'EOF'
[main]
font = JetBrainsMono Nerd Font:size=10
term = xterm-256color

[colors]
background = 2e3440
foreground = eceff4
cursor = eceff4
EOF

# Ассоциации приложений
mkdir -p ~/.config
cat > ~/.config/mimeapps.list <<'EOF'
[Default Applications]
text/plain=foot.desktop
inode/directory=org.kde.dolphin.desktop

[Added Associations]
text/plain=foot.desktop
inode/directory=org.kde.dolphin.desktop
EOF

# === 10. Запуск служб ===
echo "🔊 Запуск фоновых служб..."
systemctl --user enable --now pipewire pipewire-pulse gamemoded

# === 11. Завершение ===
echo ""
echo "✅ ГОТОВО! ArcHIChanAdmin Edition установлен."
echo "Чтобы запустить Hyprland:"
echo "  1. Переключись в tty1: Ctrl+Alt+F1"
echo "  2. Залогинься как Kanna4ka"
echo "  3. Выполни: Hyprland"
echo ""
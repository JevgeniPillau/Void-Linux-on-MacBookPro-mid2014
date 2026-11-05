#!/usr/bin/env bash
set -e

# Проверка на запуск от root/sudo для системных компонентов
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт через sudo: sudo $0"
  exit 1
fi

# Определение реального пользователя, запустившего sudo
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo "~$REAL_USER")

echo "=== 1. Добавление сторонних репозиториев (Makrenne & Black-Hole) ==="
#mkdir -p /etc/xbps.d

# Добавляем репозиторий Makrenne
#cat <<EOF > /etc/xbps.d/10-makrenne.conf
#repository=https://codeberg.org
#EOF

# Добавляем репозиторий mirror.black-hole.dev
#cat <<EOF > /etc/xbps.d/20-blackhole.conf
#repository=https://black-hole.dev
#EOF

echo "=== 2. Обновление индексов и установка зависимостей ==="
xbps-install -Syu -y

# Установка указанных вами зависимостей (используются официальные имена пакетов в Void)
# glslang -> glslang, libzip -> libzip, pugixml -> pugixml, muparser -> muParser, re2 -> re2
xbps-install -y glslang libzip pugixml muparser re2

echo "=== 3. Установка Hyprland, Waybar и окружения ==="
# Устанавливаем сам Hyprland из подключенных репозиториев и остальные утилиты
xbps-install -y hyprland Waybar foot light NetworkManager network-manager-applet \
  bluez blueman pipewire wireplumber pavucontrol playerctl seatd dbus polkit-gnome \
  wl-clipboard cliphist lm_sensors noto-fonts-ttf font-awesome6 wofi

echo "=== 4. Настройка системных служб и групп ==="
usermod -aG video,audio,input,storage,network,_seatd,_pipewire,bluetooth "$REAL_USER"

# Включение Runit служб
for service in dbus seatd NetworkManager bluetoothd; do
  if [ -d "/etc/sv/$service" ] && [ ! -L "/var/service/$service" ]; then
    ln -s "/etc/sv/$service" /var/service/
  fi
done

# Настройка udev правил для управления яркостью (пакет light) без sudo
sudo mkdir -p /etc/udev/rules.d
cat <<EOF > /etc/udev/rules.d/90-backlight.rules
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="leds", RUN+="/bin/chgrp video /sys/class/leds/%k/brightness"
ACTION=="add", SUBSYSTEM=="leds", RUN+="/bin/chmod g+w /sys/class/leds/%k/brightness"
EOF
udevadm control --reload-rules && udevadm trigger

echo "=== 5. Создание конфигурационных директорий пользователя ==="
mkdir -p "$REAL_HOME"/.config/{hypr,waybar}

echo "=== 6. Генерация hyprland.conf ==="
cat <<EOF > "$REAL_HOME"/.config/hypr/hyprland.conf
# Hyprland Config for MBP Mid 2014 (Gruvbox Theme)

# Монитор: 13" Retina (Масштабирование 2x)
monitor=eDP-1,2560x1600@60,0x0,2

# Автозапуск необходимых сервисов и апплетов
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = /usr/libexec/polkit-gnome-authentication-agent-1
exec-once = waybar
exec-once = nm-applet --indicator
exec-once = blueman-applet
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

# Окружение
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = WLR_NO_HARDWARE_CURSORS,1

input {
    kb_layout = us,ru,ee
    kb_options = grp:ctrl_space_toggle
    kb_variant = ,phonetic,
    follow_mouse = 1
    touchpad {
        natural_scroll = true
        tap-to-click = true
        clickfinger_behavior = true
        tap-to-click-delay = 0
    }
}

gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(d65d0eff) rgba(ebdbb2ff) 45deg # Gruvbox Orange/Cream
    col.inactive_border = rgba(282828ff)
    layout = dwindle
}

decoration {
    rounding = 8
    blur {
        enabled = true
        size = 3
        passes = 1
    }
}

animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 5, myBezier
    animation = windowsOut, 1, 5, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 5, default
    animation = workspaces, 1, 6, default
}

# Основные бинды клавиш
\$mainMod = SUPER

bind = \$mainMod, Q, exec, foot
bind = \$mainMod, C, killactive,
bind = \$mainMod, M, exit,
bind = \$mainMod, E, exec, foot -e ranger
bind = \$mainMod, V, togglefloating,
bind = \$mainMod, R, exec, wofi --show drun
bind = \$mainMod, H, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy

# Управление фокусом окон
bind = \$mainMod, left, movefocus, l
bind = \$mainMod, right, movefocus, r
bind = \$mainMod, up, movefocus, u
bind = \$mainMod, down, movefocus, d

# Переключение воркспейсов (Ограничено 7 воркспейсами)
bind = \$mainMod, 1, workspace, 1
bind = \$mainMod, 2, workspace, 2
bind = \$mainMod, 3, workspace, 3
bind = \$mainMod, 4, workspace, 4
bind = \$mainMod, 5, workspace, 5
bind = \$mainMod, 6, workspace, 6
bind = \$mainMod, 7, workspace, 7

# Перемещение окон на ворксейсы
bind = \$mainMod SHIFT, 1, movetoworkspace, 1
bind = \$mainMod SHIFT, 2, movetoworkspace, 2
bind = \$mainMod SHIFT, 3, movetoworkspace, 3
bind = \$mainMod SHIFT, 4, movetoworkspace, 4
bind = \$mainMod SHIFT, 5, movetoworkspace, 5
bind = \$mainMod SHIFT, 6, movetoworkspace, 6
bind = \$mainMod SHIFT, 7, movetoworkspace, 7

# Горячие клавиши MacBook Pro Mid 2014
# Яркость экрана (F1/F2)
bindle = , XF86MonBrightnessDown, exec, light -U 5
bindle = , XF86MonBrightnessUp, exec, light -A 5

# Подсветка клавиатуры Apple SMC (F5/F6)
bindle = , XF86KbdBrightnessDown, exec, light -K -U 10
bindle = , XF86KbdBrightnessUp, exec, light -K -A 10

# Звук и Мультимедиа (F7-F12)
bindl  = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindle = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindle = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindl  = , XF86AudioPlay, exec, playerctl play-pause
bindl  = , XF86AudioNext, exec, playerctl next
bindl  = , XF86AudioPrev, exec, playerctl previous
EOF

echo "=== 7. Генерация конфигурации Waybar ==="
cat <<EOF > "$REAL_HOME"/.config/waybar/config.jsonc
{
    "layer": "top",
    "position": "top",
    "height": 32,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": [
        "cpu", 
        "memory", 
        "temperature", 
        "custom/clipboard", 
        "battery", 
        "wireplumber", 
        "bluetooth", 
        "network", 
        "tray", 
        "custom/power"
    ],

    "hyprland/workspaces": {
        "format": "{num}: {windows}",
        "format-window-separator": " ",
        "window-rewrite-default": "",
        "window-rewrite": {
            "title<.*youtube.*>": "",
            "class<firefox>": "",
            "class<foot>": "",
            "class<code-oss>": "  ",
            "class<thunar>": "  ",
            "class<spotify>": ""
        },
        "persistent-workspaces": {
            "1": [],
            "2": [],
            "3": [],
            "4": [],
            "5": [],
            "6": [],
            "7": []
        }
    },

    "clock": {
        "format": " {:%H:%M   %d/%m/%Y}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },

    "cpu": {
        "format": " {usage}%",
        "tooltip": false
    },

    "memory": {
        "format": " {percentage}%"
    },

    "temperature": {
        "critical-threshold": 80,
        "format": " {temperatureC}°C"
    },

    "custom/clipboard": {
        "format": "  ",
        "on-click": "cliphist list | wofi --dmenu | cliphist decode | wl-copy",
        "tooltip": false
    },

    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": "   {capacity}%",
        "format-plugged": " {capacity}%",
        "format-icons": ["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  "]
    },

    "wireplumber": {
        "format": "{icon} {volume}%",
        "format-muted": "   Muted",
        "on-click": "pavucontrol",
        "format-icons": ["  ", "  ", "  "]
    },

    "bluetooth": {
        "format": " {status}",
        "format-disabled": "   off",
        "format-connected": " {num_connections}",
        "on-click": "blueman-manager"
    },

    "network": {
        "format-wifi": " {essid}",
        "format-ethernet": "   eth",
        "format-disconnected": "   Down",
        "on-click": "nm-connection-editor"
    },

    "tray": {
        "icon-size": 16,
        "spacing": 10
    },

    "custom/power": {
        "format": "⏻",
        "on-click": "shutdown now",
        "tooltip": false
    }
}
EOF

echo "=== 8. Генерация стилей Waybar (Gruvbox Theme) ==="
cat <<EOF > "$REAL_HOME"/.config/waybar/style.css
@define-color bg #282828;
@define-color bg_hard #1d2021;
@define-color fg #ebdbb2;
@define-color gray #928374;
@define-color red #cc241d;
@define-color green #98971a;
@define-color yellow #d79921;
@define-color blue #458588;
@define-color purple #b16286;
@define-color aqua #689d6a;
@define-color orange #d65d0e;

* {
    font-family: "Noto Sans", "Font Awesome 6 Free", sans-serif;
    font-size: 13px;
    font-weight: bold;
    border: none;
    border-radius: 0;
}

window#waybar {
    background-color: @bg_hard;
    color: @fg;
    transition-property: background-color;
    transition-duration: .5s;
    border-bottom: 2px solid @bg;
}

#workspaces button {
    padding: 0 8px;
    background-color: transparent;
    color: @gray;
    border-bottom: 2px solid transparent;
}

#workspaces button.active {
    color: @orange;
    border-bottom: 2px solid @orange;
}

#workspaces button.urgent {
    color: @red;
}

#clock, #cpu, #memory, #temperature, #custom-clipboard, #battery, #wireplumber, #bluetooth, #network, #tray, #custom-power {
    padding: 0 10px;
    margin: 4px 2px;
    border-radius: 4px;
    background-color: @bg;
}
EOF

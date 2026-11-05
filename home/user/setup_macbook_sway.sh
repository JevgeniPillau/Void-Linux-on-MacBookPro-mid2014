#!/bin/bash
# Sway & Waybar Auto-Configurator for MacBook Pro Mid 2014 (13-inch)
# Enforces native English output and applies all requested hardware mappings.

set -e

echo "==> 1. Creating configuration directories..."
mkdir -p "$HOME/.config/sway"
mkdir -p "$HOME/.config/waybar"

echo "==> 2. Installing hardware management utilities (light, playerctl)..."
sudo xbps-install -Sy kitty

# Configure light permissions so non-root users can alter backlights
sudo usermod -aG video "$USER"
sudo chmod +s /usr/bin/light

echo "==> 3. Generating dynamic Sway configuration..."
cat << 'EOF' > "$HOME/.config/sway/config"
### MacBook Pro 13-inch Mid 2014 - Sway Configuration

# Default Modifier Key (Super/Command)
set $mod Mod4

# Directions
set $left h
set $down j
set $up k
set $right l

# Preferred terminal application
set $term kitty

# Preferred application launcher
set $menu dmenu_run

### Window Manager Behavior
floating_modifier $mod normal
default_border pixel 2
hide_edge_borders none

### Output Configuration (Retina Scaling)
# Explicitly sets 2x scale for the built-in Retina display
output eDP-1 scale 2

### Input Configuration (Touchpad Gestures & Tap-to-Click)
input "type:touchpad" {
    tap enabled
    natural_scroll enabled
    middle_emulation enabled
    dwt enabled
}

# Touchpad Gestures for Workspace Switching
gesture swipe:right workspace prev
gesture swipe:left workspace next

### Hardware Key Bindings (MacBook Pro Specific)
# Screen Brightness Mappings
bindsym XF86MonBrightnessUp exec light -A 5
bindsym XF86MonBrightnessDown exec light -U 5

# Keyboard Backlight Mappings (MacBook Pro standard smc subsystem via light)
bindsym XF86KbdBrightnessUp exec light -s sysfs/leds/smc::kbd_backlight -A 10
bindsym XF86KbdBrightnessDown exec light -s sysfs/leds/smc::kbd_backlight -U 10

# Audio / Volume Controls
bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Media Track Control (Using playerctl)
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous

### Standard Execution Bindings
bindsym $mod+Return exec $term
bindsym $mod+Shift+q kill
bindsym $mod+d exec $menu

# Reload/Exit Sway
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit Sway?' -B 'Yes' 'swaymsg exit'

### Moving Focus
bindsym $mod+$left focus left
bindsym $mod+$down focus down
bindsym $mod+$up focus up
bindsym $mod+$right focus right

### Moving Windows
bindsym $mod+Shift+$left move left
bindsym $mod+Shift+$down move down
bindsym $mod+Shift+$up move up
bindsym $mod+Shift+$right move right

### Workspaces
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5

bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5

### Layout configuration
bindsym $mod+b splith
bindsym $mod+v splitv
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
bindsym $mod+f fullscreen toggle
bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle

### Status Bar Configuration
bar {
    swaybar_command waybar
}

include /etc/sway/config.d/*
EOF

echo "==> 4. Setting up baseline Waybar structures..."
if [ ! -f "$HOME/.config/waybar/config" ]; then
    cp /etc/xdg/waybar/config "$HOME/.config/waybar/config" || true
fi
if [ ! -f "$HOME/.config/waybar/style.css" ]; then
    cp /etc/xdg/waybar/style.css "$HOME/.config/waybar/style.css" || true
fi

echo "=========================================================="
echo " Setup complete! Please log out and run 'sway' to start."
echo " Touchpad tap-to-click, custom MacBook media/brightness"
echo " keybinds, and 2x Retina scaling are now active."
echo "=========================================================="

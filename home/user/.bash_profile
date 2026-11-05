# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc
#if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; 
#	then exec Hyprland
#fi

# Автозапуск niri на первом TTY
#if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then
#    # Переменные окружения для Wayland и GTK/Qt приложений в Void Linux
#    export PULSE_SERVER=unix:/run/user/1000/pulse/native
#    export MOZ_ENABLE_WAYLAND=1    
#    export XDG_SESSION_TYPE=wayland
#    export XDG_CURRENT_DESKTOP=niri
#    export QT_QPA_PLATFORM=wayland

# Запускаем звук в фоне прямо здесь
#    pipewire &
#    sleep 1 && wireplumber &

#    # Запуск niri внутри чистой D-Bus сессии
#    exec dbus-run-session niri
#fi


# Убедимся, что система видит наши скрипты в ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# Проверка входа на tty1
if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then
    # Enviroment variables needed to run window managers and services in Void Linux
    export PULSE_SERVER=unix:/run/user/1000/pulse/native
    export MOZ_ENABLE_WAYLAND=1    
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=niri
    export QT_QPA_PLATFORM=wayland
    export XKB_DEFAULT_LAYOUT="us,ru_jp"
    export XKB_DEFAULT_OPTIONS="grp:ctrl_space_toggle"
    # Quietly run sound server
    pipewire >/dev/null 2>&1 &
    sleep 1
    wireplumber >/dev/null 2>&1 &
    sleep 1
    pipewire-pulse >/dev/null 2>&1 &
    echo "=============================="
    echo " Choose what session to start: "
    echo "=============================="
    echo " 1) Niri"
    echo " 2) Hyprland"
    echo " 3) Sway"
    echo " 4) Stay here (TTY1)"
    echo "=============================="
    read -p "Type number please (1-4): " choice

    case $choice in
        1)
            exec dbus-run-session niri > ~/niri-startup.log 2>&1
            ;;
        2)
            exec dbus-run-session hyprland > ~/hyprland-startup.log 2>&1
            ;;
        3)
            exec sway > ~/sway-startup.log 2>&1
            ;;            
        4)
            echo "You stayed on TTY. To start session type: dbus-run-session niri or dbus-run-session hyprland or sway."
            ;;
        *)
            echo "Wrong choice. Staying on TTY."
            ;;
    esac
fi

#export XKB_DEFAULT_LAYOUT="us,ru_jp"
#export XKB_DEFAULT_OPTIONS="grp:ctrl_space_toggle"

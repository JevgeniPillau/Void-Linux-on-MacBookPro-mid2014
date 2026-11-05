# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export SUDO_EDITOR="fresh"

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '

# Цвета Gruvbox (8-битные ANSI-коды для совместимости)
GB_GRAY="\[\033[38;5;246m\]"
GB_GOLD="\[\033[38;5;214m\]"
GB_AQUA="\[\033[38;5;108m\]"
GB_BLUE="\[\033[38;5;109m\]"
GB_RESET="\[\033[0m\]"

# Настройка PS1: [\033... - цвета, \t - время, \u - юзер, \h - хост, \w - папка
#PS1="${GB_GRAY}\t${GB_RESET} [${GB_GOLD}\u${GB_RESET}@${GB_AQUA}\h${GB_RESET}] ${GB_BLUE}\w${GB_RESET}\n\$ "

# Промпт с иконками ( - часы,  - лого Void/Linux,  - папка, ❯ - стрелка)
#PS1="[${GB_GRAY} \t${GB_RESET}] ${GB_GOLD} \u${GB_RESET}@${GB_GOLD}\h${GB_RESET} ${GB_BLUE} \w${GB_RESET}\n${GB_AQUA}--❯${GB_RESET} "


# Цвета блоков (Текст;Фон)
C_TIME="\[\033[38;5;246;48;5;237m\]" # Серый текст на темно-сером фоне
C_USER="\[\033[38;5;235;48;5;214m\]" # Темный текст на желтом фоне
C_DIR="\[\033[38;5;235;48;5;109m\]"  # Темный текст на голубом фоне

# Стрелочки-переходники (Красим текст стрелочки в цвет старого фона, а фон стрелочки в цвет нового)
ARR_TIME_USER="\[\033[38;5;237;48;5;214m\]" # Стрелка цвета времени, фон цвета юзера
ARR_USER_DIR="\[\033[38;5;214;48;5;109m\]"  # Стрелка цвета юзера, фон цвета папки
ARR_DIR_CLOSE="\[\033[0;38;5;109m\]"         # Стрелка цвета папки, фон прозрачный

FG_GOLD="\[\033[0;38;5;214m\]"
RESET="\[\033[0m\]"

# Сборка промпта
PS1="${C_TIME}  \t ${ARR_TIME_USER}${C_USER}  \u@\h ${ARR_USER_DIR}${C_DIR}  \w ${ARR_DIR_CLOSE}${RESET}\n${FG_GOLD}❯❯❯${RESET} "

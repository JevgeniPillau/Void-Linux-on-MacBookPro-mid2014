#!/bin/sh

KEYS="-- Basic Actions --
Confirm                     ➔  enter, right, l
CD & Quit                   ➔  Q
Quit                        ➔  q, esc

-- Navigation --
List Down                   ➔  down, j
List Up                     ➔  up, k
Page Down                   ➔  pgdown
Page Up                     ➔  pgup

-- File Panel Controls --
Close File Panel            ➔  w
Create New File Panel       ➔  n
Next File Panel             ➔  tab, L
Previous File Panel         ➔  shift+left, H
Split File Panel            ➔  N
Toggle File Preview         ➔  f
Open Sort Options           ➔  o
Toggle Reverse Sort         ➔  R
Pinned Directory            ➔  P

-- Focus Manipulation --
Focus on Metadata           ➔  m
Focus on Process Bar        ➔  p
Focus on Sidebar            ➔  s

-- File/Dir Creation & Renaming --
Create Item (File/Dir)      ➔  ctrl+n
Rename Item                 ➔  ctrl+r

-- Main File Operations --
Copy Items                  ➔  ctrl+c
Cut Items                   ➔  ctrl+x
Paste Items                 ➔  ctrl+v, ctrl+w
Delete Items (Trash)        ➔  ctrl+d, delete
Permanently Delete          ➔  D

-- Archive Manipulation --
Compress File               ➔  ctrl+a
Extract File                ➔  ctrl+e

-- Editor Actions --
Open File with Editor       ➔  e
Open Current Dir in Editor  ➔  E

-- Other Actions --
Change Panel Mode           ➔  v
Copy Path                   ➔  ctrl+p
Copy Present Working Dir    ➔  c
Open Command Line           ➔  :
Open Help Menu              ➔  ?
Open SPF Prompt             ➔  >
Open Zoxide                 ➔  z
Toggle Dot Files            ➔  .
Toggle Footer               ➔  F

-- Normal Mode --
Parent Directory            ➔  h, left, backspace
Search Bar                  ➔  /

-- Selection Mode --
Select Items Down           ➔  shift+down, J
Select Items Up             ➔  shift+up, K
Select All Items            ➔  A"

# Инлайн-стили для Wofi без использования Bash-специфичного <(echo)
WOFI_STYLE="
window { font-family: 'FiraCode Nerd Font', monospace; font-size: 14px; background-color: #282828; color: #ebdbb2; border: 2px solid #d65d0e; border-radius: 8px; }
#entry:selected { background-color: #3c3836; color: #b8bb26; }
#input { background-color: #3c3836; color: #fb4934; border-bottom: 1px solid #504945; }
"

# Запускаем wofi, передавая стили через временную переменную окружения или аргумент
echo "$STYLE" > /tmp/wofi-spf.css
echo "$WOFI_STYLE" > /tmp/wofi-spf.css

echo "$KEYS" | wofi --dmenu \
    --prompt "Поиск горячих клавиш Superfile..." \
    --width 450 \
    --height 500 \
    --cache-file /dev/null \
    --style /tmp/wofi-spf.css

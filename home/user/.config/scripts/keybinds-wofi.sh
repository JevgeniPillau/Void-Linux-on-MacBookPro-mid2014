#!/usr/bin/env python3
import os
import re
import subprocess
import sys

def get_niri_binds():
    paths = [
        os.path.expanduser("~/.config/niri/config.kdl"),
        os.path.expanduser("~/.config/niri/cfg/keybinds.kdl")
    ]
    config_file = next((p for p in paths if os.path.exists(p)), None)
    if not config_file:
        return "Error: Niri config file not found."

    # Словари для группировки
    groups = {
        "🛠️ Mod + Alt": [],
        "🔊 Special keys (XF86)": [],
        "⌨️ Mod + letter / number": [],
        "🎛️ Mod + Ctrl": [],
        "⚙️ Mod + Shift": [],
        "🧩 Other hotkeys": []
    }

    with open(config_file, "r", encoding="utf-8") as f:
        for line in f:
            line_str = line.strip()
            
            if line_str.startswith("//") or line_str.startswith("#"):
                continue
                
            if "{" in line_str and "hotkey-overlay-title" in line_str:
                parts = line_str.split("{")[0].strip()
                overlay_match = re.search(r'hotkey-overlay-title=["\'](.*?)["\']', parts)
                
                if overlay_match:
                    title = overlay_match.group(1)
                    key = parts.split("hotkey-overlay-title")[0].strip()
                    formatted_line = f"  {key:<25} ➔  {title}"
                    
                    # Логика распределения по группам (регистронезависимая)
                    key_lower = key.lower()
                    
                    if "xf86" in key_lower:
                        groups["🔊 Special keys (XF86)"].append(formatted_line)
                    elif "mod+ctrl" in key_lower or "ctrl+mod" in key_lower:
                        groups["🎛️ Mod + Ctrl"].append(formatted_line)
                    elif "mod+shift" in key_lower or "shift+mod" in key_lower:
                        groups["⚙️ Mod + Shift"].append(formatted_line)
                    elif "mod+alt" in key_lower or "alt+mod" in key_lower:
                        groups["🛠️ Mod + Alt"].append(formatted_line)
                    elif "mod+" in key_lower:
                        groups["⌨️ Mod + letter / number"].append(formatted_line)
                    else:
                        groups["🧩 Other hotkeys"].append(formatted_line)

    # Собираем финальный текст с красивыми заголовками разделов
    final_output = []
    for group_name, items in groups.items():
        if items: # Выводим группу, только если в ней есть элементы
            final_output.append(f"===[ {group_name} ]===")
            final_output.extend(items)
            final_output.append("") # Пустая строка для отступа между группами

    return "\n".join(final_output).strip()

def main():
    list_data = get_niri_binds()
    
    try:
        subprocess.run([
            "wofi", "--dmenu",
            "--prompt", "⌨️ Grouped hotkeys (ESC to exit)",
            "--style", os.path.expanduser("~/.config/wofi/gruvbox.css"),
            "--width", "650",
            "--height", "550",
            "--cache-file", "/dev/null"
        ], input=list_data, text=True, check=True)
    except FileNotFoundError:
        print("Error: Wofi not installed.")
    except subprocess.CalledProcessError:
        sys.exit(0)

if __name__ == "__main__":
    main()

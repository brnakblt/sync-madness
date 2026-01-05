#!/bin/bash

# --- DMS Wallpaper Switcher ---
# Bu script DMS built-in wallpaper manager kullanır (swww değil)

WALLPAPER_DIR="/home/baran/Pictures/Wallpapers"

# Resim Seçimi (Argüman varsa kullan, yoksa rastgele)
if [ -n "$1" ]; then
    RANDOM_WP="$1"
else
    RANDOM_WP=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | shuf -n 1)
fi

if [ -z "$RANDOM_WP" ]; then
    exit 1
fi

# DMS'e bildir - bu hem desktop hem overview hem theme'i günceller
if command -v dms >/dev/null; then
    dms ipc call wallpaper set "$RANDOM_WP" >/dev/null 2>&1
else
    exit 1
fi

# Custom matugen templates (cava, nvim vb.)
COLOR=""
if command -v matugen >/dev/null; then
    matugen image "$RANDOM_WP" >/dev/null 2>&1
    
    # Get Color for scripts
    if command -v jq >/dev/null; then
        COLOR=$(matugen image "$RANDOM_WP" --json hex --dry-run | jq -r '.colors.primary.default')
    fi

    # Asus ROG Keyboard Light Sync
    if command -v asusctl >/dev/null && [ -n "$COLOR" ] && [ "$COLOR" != "null" ]; then
         # Strip '#'
         HEX_COLOR=${COLOR:1}
         asusctl aura static -c "$HEX_COLOR" >/dev/null 2>&1
    fi
fi

# Spicetify Update
if command -v spicetify >/dev/null; then
    # Check if current theme is already Matugen
    CURRENT_THEME=$(spicetify config current_theme 2>/dev/null)
    if [ "$CURRENT_THEME" != "Matugen" ]; then
        # Theme changed: Must use APPLY
        spicetify config current_theme Matugen color_scheme dynamic >/dev/null 2>&1
        spicetify apply -n >/dev/null 2>&1 &
    else
        # Theme same: Use REFRESH for speed
        spicetify refresh -n >/dev/null 2>&1 &
    fi
fi

# Cava hot reload (SIGUSR1 veya SIGUSR2)
pkill -USR1 cava 2>/dev/null

# Update Pokemon Theme Cache
# We pass the full COLOR (with #) if we found it, otherwise script finds it
/home/baran/Scripts/Utils/pokemon_theme_manager.py "$COLOR" > /dev/null 2>&1 &

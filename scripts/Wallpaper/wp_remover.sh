#!/bin/bash

# --- DMS Wallpaper Remover ---

# DMS'den mevcut duvar kağıdı yolunu al
WALLPAPER_PATH=$(dms ipc call wallpaper get 2>/dev/null)

if [ -z "$WALLPAPER_PATH" ]; then
    echo "Hata: DMS'den duvar kağıdı yolu alınamadı."
    exit 1
fi

if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Hata: Dosya bulunamadı: $WALLPAPER_PATH"
    exit 1
fi

read -p "Sil? [E/h]: " confirm
confirm=${confirm:-e}

if [[ "$confirm" == "e" || "$confirm" == "E" ]]; then
    rm "$WALLPAPER_PATH"
    if [ $? -eq 0 ]; then
        /home/baran/Scripts/Wallpaper/wp_switch.sh
    else
        echo "Hata: Dosya silinemedi."
    fi
else
    echo "İşlem iptal edildi."
fi

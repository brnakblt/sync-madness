#!/bin/bash
# Sync-Madness Otomatik Kurulum Scripti

set -e

echo -e "\033[1;35mSync-Madness Kurulum Sihirbazına Hoş Geldiniz!\033[0m"

# 1. DMS Kontrolü
if ! command -v dms &> /dev/null; then
    echo -e "\033[1;31mHATA: 'dms' (DankMaterialShell) sisteminizde bulunamadı.\033[0m"
    echo "Bu paket, tema senkronizasyonu için DMS'e ihtiyaç duyar."
    echo -e "Lütfen önce şu adresten kurulumu yapın: \033[1;34mhttps://github.com/AvengeMedia/DankMaterialShell\033[0m"
    echo ""
    read -p "Yine de devam etmek istiyor musunuz? (e/H) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ee]$ ]]; then
        echo "Kurulum iptal edildi."
        exit 1
    fi
fi

# 2. Paket Yöneticisi ve AUR Yardımcısı Tespiti
AUR_HELPER=""
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    echo -e "\033[1;31mHATA: AUR yardımcısı (yay veya paru) bulunamadı.\033[0m"
    echo "Bu script Arch Linux tabanlı sistemler için tasarlanmıştır."
    exit 1
fi

echo -e "\033[1;34m:: Resmi depolardaki paketler kuruluyor (pacman)...\033[0m"
sudo pacman -S --needed python jq fastfetch cmatrix cava

echo -e "\033[1;34m:: AUR paketleri kuruluyor ($AUR_HELPER)...\033[0m"
$AUR_HELPER -S --needed matugen-bin

# 3. Pokeget Kurulumu (Cargo Önerilir)
echo
if command -v cargo &> /dev/null; then
    read -p "Pokeget'i Cargo ile kurmak ister misiniz? (Önerilen) (E/h) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Hh]$ ]]; then
        echo ":: Pokeget kuruluyor (cargo)..."
        cargo install pokeget
        echo -e "\033[1;33mNOT: ~/.cargo/bin dizininin PATH'e eklendiğinden emin olun!\033[0m"
    else
        echo ":: Pokeget kuruluyor ($AUR_HELPER)..."
        $AUR_HELPER -S --needed pokeget
    fi
else
    echo ":: Cargo bulunamadı, Pokeget $AUR_HELPER ile kuruluyor..."
    $AUR_HELPER -S --needed pokeget
fi

# 4. ASUS ROG Kontrolü (İsteğe Bağlı)
echo
read -p "ASUS ROG serisi bir laptop kullanıyor musunuz? (Klavye ışık senkronizasyonu için) (e/H) " -n 1 -r
echo
if [[ $REPLY =~ ^[Ee]$ ]]; then
    echo -e "\033[1;34m:: asusctl kuruluyor...\033[0m"
    sudo pacman -S --needed asusctl
else
    echo ":: asusctl kurulumu atlandı."
fi

# 4. Scriptlerin Kopyalanması
echo -e "\033[1;34m:: Scriptler ~/Scripts dizinine kopyalanıyor...\033[0m"
mkdir -p "$HOME/Scripts"
cp -r scripts/* "$HOME/Scripts/"
chmod +x "$HOME/Scripts/Wallpaper/"*.sh
chmod +x "$HOME/Scripts/Coolstf/"*.sh
chmod +x "$HOME/Scripts/Utils/"*.py
chmod +x "$HOME/Scripts/Utils/"*.sh

# 5. Yapılandırma Dosyalarının (Dotfiles) Bağlanması
echo -e "\033[1;34m:: Yapılandırma dosyaları (dotfiles) bağlanıyor...\033[0m"
mkdir -p "$HOME/.config"

CONFIG_DIR="$(pwd)/dotfiles"

for app in "$CONFIG_DIR"/*; do
    app_name=$(basename "$app")
    target="$HOME/.config/$app_name"
    
    if [ -d "$target" ] || [ -f "$target" ]; then
        echo "   UYARI: $target zaten var. Yedekleniyor..."
        mv "$target" "${target}.backup_$(date +%s)"
    fi
    
    ln -s "$app" "$target"
    echo "   -> $app_name bağlandı."
done

# 6. Alias Hatırlatması
echo
echo -e "\033[1;32mKurulum Tamamlandı!\033[0m"
echo
echo "Lütfen shell yapılandırma dosyanıza (.bashrc / .zshrc) şu aliasları eklemeyi unutmayın:"
echo
echo "alias wp='$HOME/Scripts/Wallpaper/wp_switch.sh'"
echo "alias ff='$HOME/Scripts/Coolstf/pokemon.sh -l'"
echo "alias matrix='$HOME/Scripts/Coolstf/cmatrix_runner.sh'"
echo

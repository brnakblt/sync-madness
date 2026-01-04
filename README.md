# Sync-Madness: Tema Senkronizasyon Paketi

**Sync-Madness**, Linux sisteminizin temasını gerçek zamanlı olarak duvar kağıdınızla senkronize eden kapsamlı bir otomasyon paketidir. `matugen` kullanarak renkleri ayıklar ve bunları pencere yöneticinizden terminalinize, CLI araçlarınızdan klavye aydınlatmanıza kadar her yere uygular.

## 🚀 Özellikler

*   **Dinamik Duvar Kağıdı Motoru:** Duvar kağıdını değiştirir ve anında sistem genelinde tema güncellemesini tetikler.
*   **Terminal Entegrasyonu:**
    *   **Fastfetch (`ff`):** Duvar kağıdınızın renk şemasına uygun rastgele bir Pokémon gösterir (Örn: Kırmızı duvar kağıdı -> Charizard).
    *   **Matrix (`matrix`):** `cmatrix` uygulamasını duvar kağıdınıza en yakın renkte çalıştırır.
*   **Uygulama Senkronizasyonu:**
    *   **Cava:** Ses görselleştirici renkleri anında güncellenir (hot-reload).
    *   **Ghostty:** Terminal emülatörü yapılandırma senkronizasyonu.
    *   **Nvim & Yazi:** Editör ve dosya yöneticisi tema entegrasyonu.
    *   **Niri:** Pencere yöneticisi kenarlık ve arayüz renklendirmesi.
    *   **ASUS ROG:** Klavye Aura senkronizasyonu (`asusctl` ile).

## 📂 Dizin Yapısı

```text
├── scripts/
│   ├── wallpaper/   # Beyin takımı (wp_switch.sh)
│   ├── utils/       # İstihbarat (pokemon_theme_manager.py, renk araçları)
│   └── coolstf/     # Göz zevki (pokemon.sh, cmatrix_runner.sh)
├── dotfiles/
│   ├── matugen/     # Renk üretim şablonları
│   ├── fastfetch/   # Fastfetch yapılandırması
│   ├── cava/        # Cava yapılandırması
│   ├── ghostty/     # Ghostty terminal yapılandırması
│   ├── nvim/        # Neovim yapılandırması
│   └── ...          # Diğer yapılandırmalar
```

## 🛠️ Yapılandırma & Kurulum

### 1. Duvar Kağıdı Dizini
Varsayılan olarak script şu dizindeki görsellere bakar:
`$HOME/Pictures/Wallpapers`

**Bunu değiştirmek için:**
1.  `scripts/Wallpaper/wp_switch.sh` dosyasını açın.
2.  `WALLPAPER_DIR` değişkenini düzenleyin:
    ```bash
    WALLPAPER_DIR="/duvar/kagitlarinizin/yolu"
    ```

### 2. Gereksinimler
Aşağıdakilerin yüklü olduğundan emin olun:
*   **Çekirdek:** `python3`, `jq`, `bash`
*   **Temalandırma:** [`matugen`](https://github.com/InioX/matugen)
*   **Duvar Kağıdı Yöneticisi:** `dms` (Dahili/Özel Araç - gerekirse `swww` veya `hyprpaper` ile değiştirin)
*   **Donanım:** `asusctl` (İsteğe bağlı, ROG laptoplar için)
*   **CLI Araçları:**
    *   [`fastfetch`](https://github.com/fastfetch-cli/fastfetch)
    *   [`pokeget-rs`](https://github.com/talwat/pokeget-rs)
    *   [`cmatrix`](https://github.com/abishekvashok/cmatrix)
    *   [`cava`](https://github.com/karlstav/cava)

### 3. Kurulum
1.  **Scriptleri Kopyalayın:**
    ```bash
    cp -r scripts/* ~/Scripts/
    ```
2.  **Dotfile'ları Bağlayın (Symlink):**
    ```bash
    ln -s $(pwd)/dotfiles/* ~/.config/
    ```
3.  **Shell Alias'ları:**
    `.bashrc` veya `.zshrc` dosyanıza ekleyin:
    ```bash
    alias wp='$HOME/Scripts/Wallpaper/wp_switch.sh'
    alias ff='$HOME/Scripts/Coolstf/pokemon.sh -l'
    alias matrix='$HOME/Scripts/Coolstf/cmatrix_runner.sh'
    ```

## 🎮 Kullanım

### Duvar Kağıdı Değiştirme (`wp`)

*   **Rastgele Karıştır:**
    Ayarladığınız `WALLPAPER_DIR` dizininden rastgele bir görsel seçer.
    ```bash
    wp
    ```

*   **Belirli Bir Görsel:**
    Belirli bir görseli duvar kağıdı yapar ve temayı senkronize eder.
    ```bash
    wp /dosya/yolu/resim.jpg
    ```

### Terminal Şekerlemeleri (Eye-Candy)

*   **Tema-Duyarlı Fastfetch:**
    Sistem bilgisini renk uyumlu bir Pokémon ile gösterir.
    ```bash
    ff
    ```

*   **Tema-Duyarlı Matrix:**
    Matrix yağmurunu temanızın ana renginde çalıştırır.
    ```bash
    matrix
    ```

## 🧠 Nasıl Çalışır? (Arkaplandaki Çılgınlık)

`wp` komutunu çalıştırdığınızda bir zincirleme reaksiyon başlar:

1.  **Duvar Kağıdı Ayarlanır:** Masaüstü arka planını güncellemek için `dms ipc` çağrılır.
2.  **Renk Analizi:** `matugen` görseli analiz eder ve ana hex kodunu çıkarır.
3.  **Sistem Üretimi:** `matugen`, `~/.config/matugen/templates` içindeki şablonlara dayanarak `cava`, `ghostty`, `nvim` vb. için yapılandırma dosyalarını oluşturur.
4.  **Donanım Senkronizasyonu:** Eğer `asusctl` mevcutsa, hex kodu klavye arka ışığına uygulanır.
5.  **Uygulama Yenileme:** `cava` gibi uygulamalara yapılandırmalarını yeniden yüklemeleri için sinyaller (SIGUSR1) gönderilir.
6.  **Akıllı Güncelleme:** `pokemon_theme_manager.py` arka planda çalışır:
    *   Renk kategorisini belirler (Örn: #FF0000 -> "Red").
    *   `~/.cache/current_theme_color.txt` dosyasını tam hex koduyla günceller.
    *   `~/.cache/current_theme_pokemons.txt` dosyasını o renge uygun Pokémon listesiyle günceller.
7.  **Sonuç:** Bir sonraki `ff` veya `matrix` çalıştırışınızda, bu önbellek dosyaları anında okunur ve yeni görünüme uyum sağlanır.

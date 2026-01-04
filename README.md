# Sync-Madness: Tema Senkronizasyon Paketi

**Sync-Madness**, Linux sisteminizin temasını gerçek zamanlı olarak duvar kağıdınızla senkronize eden kapsamlı bir otomasyon paketidir. `matugen` kullanarak renkleri ayıklar ve bunları pencere yöneticinizden terminalinize, CLI araçlarınızdan klavye aydınlatmanıza kadar her yere uygular.

## Ozellikler

*   **Dinamik Duvar Kagidi Motoru:** Duvar kağıdını değiştirir ve anında sistem genelinde tema güncellemesini tetikler.
*   **Terminal Entegrasyonu:**
    *   **Fastfetch (ff):** Duvar kağıdınızın renk şemasına uygun rastgele bir Pokémon gösterir (Örn: Kırmızı duvar kağıdı -> Charizard).
    *   **Matrix (matrix):** `cmatrix` uygulamasını duvar kağıdınıza en yakın renkte çalıştırır.
*   **Uygulama Senkronizasyonu:**
    *   **Cava:** Ses görselleştirici renkleri anında güncellenir (hot-reload).
    *   **Ghostty:** Terminal emülatörü yapılandırma senkronizasyonu.
    *   **Nvim & Yazi:** Editör ve dosya yöneticisi tema entegrasyonu.
    *   **Niri:** Pencere yöneticisi kenarlık ve arayüz renklendirmesi.
    *   **ASUS ROG:** Klavye Aura senkronizasyonu (`asusctl` ile).

## Dizin Yapisi

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

## Yapilandirma ve Kurulum

### 1. Duvar Kagidi Dizini
Varsayılan olarak script şu dizindeki görsellere bakar:
`$HOME/Pictures/Wallpapers`

**Bunu degistirmek icin:**
1.  `scripts/Wallpaper/wp_switch.sh` dosyasını açın.
2.  `WALLPAPER_DIR` değişkenini düzenleyin:
    ```bash
    WALLPAPER_DIR="/duvar/kagitlarinizin/yolu"
    ```

### 2. Gereksinimler
Aşağıdakilerin yüklü olduğundan emin olun:
*   **Cekirdek:** `python3`, `jq`, `bash`
*   **Temalandirma:** [`matugen`](https://github.com/InioX/matugen)
*   **Duvar Kagidi Yoneticisi:** `dms` (Dahili/Özel Araç - gerekirse `swww` veya `hyprpaper` ile değiştirin)
*   **Donanim:** `asusctl` (İsteğe bağlı, ROG laptoplar için)
*   **CLI Araclari:**
    *   [`fastfetch`](https://github.com/fastfetch-cli/fastfetch)
    *   [`pokeget-rs`](https://github.com/talwat/pokeget-rs)
    *   [`cmatrix`](https://github.com/abishekvashok/cmatrix)
    *   [`cava`](https://github.com/karlstav/cava)

### 3. Kurulum
1.  **Scriptleri Kopyalayin:**
    ```bash
    cp -r scripts/* ~/Scripts/
    ```
2.  **Dotfile'lari Baglayin (Symlink):**
    ```bash
    ln -s $(pwd)/dotfiles/* ~/.config/
    ```
3.  **Shell Alias'lari:**
    `.bashrc` veya `.zshrc` dosyanıza ekleyin:
    ```bash
    alias wp='$HOME/Scripts/Wallpaper/wp_switch.sh'
    alias ff='$HOME/Scripts/Coolstf/pokemon.sh -l'
    alias matrix='$HOME/Scripts/Coolstf/cmatrix_runner.sh'
    ```

## Kullanim

### Duvar Kagidi Degistirme (wp)

*   **Rastgele Karistir:**
    Ayarladığınız `WALLPAPER_DIR` dizininden rastgele bir görsel seçer.
    ```bash
    wp
    ```

*   **Belirli Bir Gorsel:**
    Belirli bir görseli duvar kağıdı yapar ve temayı senkronize eder.
    ```bash
    wp /dosya/yolu/resim.jpg
    ```

### Terminal Sekerlemeleri

*   **Tema-Duyarli Fastfetch:**
    Sistem bilgisini renk uyumlu bir Pokémon ile gösterir.
    ```bash
    ff
    ```

*   **Tema-Duyarli Matrix:**
    Matrix yağmurunu temanızın ana renginde çalıştırır.
    ```bash
    matrix
    ```

## Nasil Calisir? (Arkaplandaki Mantik)

`wp` komutunu çalıştırdığınızda bir zincirleme reaksiyon başlar:

1.  **Duvar Kagidi Ayarlanir:** Masaüstü arka planını güncellemek için `dms ipc` çağrılır.
2.  **Renk Analizi:** `matugen` görseli analiz eder ve ana hex kodunu çıkarır.
3.  **Sistem Uretimi:** `matugen`, `~/.config/matugen/templates` içindeki şablonlara dayanarak `cava`, `ghostty`, `nvim` vb. için yapılandırma dosyalarını oluşturur.
4.  **Donanim Senkronizasyonu:** Eğer `asusctl` mevcutsa, hex kodu klavye arka ışığına uygulanır.
5.  **Uygulama Yenileme:** `cava` gibi uygulamalara yapılandırmalarını yeniden yüklemeleri için sinyaller (SIGUSR1) gönderilir.
6.  **Akilli Guncelleme:** `pokemon_theme_manager.py` arka planda çalışır:
    *   Renk kategorisini belirler (Örn: #FF0000 -> "Red").
    *   `~/.cache/current_theme_color.txt` dosyasını tam hex koduyla günceller.
    *   `~/.cache/current_theme_pokemons.txt` dosyasını o renge uygun Pokémon listesiyle günceller.
7.  **Sonuc:** Bir sonraki `ff` veya `matrix` çalıştırışınızda, bu önbellek dosyaları anında okunur ve yeni görünüme uyum sağlanır.
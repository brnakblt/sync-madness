# Sync-Madness: Tema Senkronizasyon Paketi

**Sync-Madness**, Linux sisteminizin temasını gerçek zamanlı olarak duvar kağıdınızla senkronize eden kapsamlı bir otomasyon paketidir. `matugen` kullanarak renkleri ayıklar ve bunları pencere yöneticinizden terminalinize, CLI araçlarınızdan klavye aydınlatmanıza kadar her yere uygular.

## Onemli Onkosul

Bu paketin calismasi icin **DankMaterialShell (DMS)** sisteminizde kurulu olmalidir. Eger kurulu degilse, lutfen once onu kurun:

[https://github.com/AvengeMedia/DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)

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
*   **Temel:** `dms` (Sisteminizde kurulu olmalıdır)
*   **Bagimliliklar:** `python3`, `jq`, `matugen`, `fastfetch`, `pokeget`, `cmatrix`, `cava` (Otomatik kurulur)
*   **Opsiyonel:** `asusctl` (ROG laptoplar icin)

### 3. Kurulum (Otomatik)

En kolay kurulum icin repo icindeki scripti calistirin. Bu script bagimliliklari kuracak, scriptleri yerlestirecek ve ayarlari yapacaktir.

> **Onemli:** Bu paketi kurmadan once `dms` kurulumunu tamamlamis olmaniz onerilir.

1.  **Scripti Calistirin:**
    ```bash
    chmod +x install.sh
    ./install.sh
    ```

2.  **Shell Alias'lari:**
    Kurulum bittikten sonra `.bashrc` veya `.zshrc` dosyanıza sunlari ekleyin:
    ```bash
    alias wp='$HOME/Scripts/Wallpaper/wp_switch.sh'
    alias ff='$HOME/Scripts/Coolstf/pokemon.sh -l'
    alias matrix='$HOME/Scripts/Coolstf/cmatrix_runner.sh'
    ```

### 4. Manuel Kurulum
Eger otomatik scripti kullanmak istemezseniz:
1.  **Scriptleri Kopyalayin:**
    ```bash
    cp -r scripts/* ~/Scripts/
    ```
2.  **Dotfile'lari Baglayin (Symlink):**
    ```bash
    ln -s $(pwd)/dotfiles/* ~/.config/
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

## Nasil Calisir?

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

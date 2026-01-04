# Sync-Madness: Theme Synchronization Suite

**Sync-Madness** is a comprehensive automation suite for Linux that synchronizes your entire system's theme to your wallpaper in real-time. It leverages `matugen` to extract colors and applies them across your window manager, terminal, CLI tools, and even your keyboard lighting.

## 🚀 Features

*   **Dynamic Wallpaper Engine:** Switches wallpapers and instantly triggers system-wide theme updates.
*   **Terminal Sync:**
    *   **Fastfetch (`ff`):** Displays a random Pokémon that matches your wallpaper's color scheme (e.g., Red wallpaper -> Charizard).
    *   **Matrix (`matrix`):** Runs `cmatrix` with the color closest to your wallpaper.
*   **App Integration:**
    *   **Cava:** Audio visualizer colors are hot-reloaded.
    *   **Ghostty:** Terminal emulator config sync.
    *   **Nvim & Yazi:** Editor and file manager theme integration.
    *   **Niri:** Window manager border and UI coloring.
    *   **ASUS ROG:** Keyboard Aura sync (via `asusctl`).

## 📂 Directory Structure

```text
├── scripts/
│   ├── wallpaper/   # The brain (wp_switch.sh)
│   ├── utils/       # The intelligence (pokemon_theme_manager.py, color tools)
│   └── coolstf/     # The eye-candy (pokemon.sh, cmatrix_runner.sh)
├── dotfiles/
│   ├── matugen/     # Color generation templates
│   ├── fastfetch/   # Fastfetch config
│   ├── cava/        # Cava config
│   ├── ghostty/     # Ghostty terminal config
│   ├── nvim/        # Neovim config
│   └── ...          # Other configs
```

## 🛠️ Configuration & Setup

### 1. Wallpaper Directory
By default, the script looks for images in:
`$HOME/Pictures/Wallpapers`

**To change this:**
1.  Open `scripts/Wallpaper/wp_switch.sh`.
2.  Edit the `WALLPAPER_DIR` variable:
    ```bash
    WALLPAPER_DIR="/path/to/your/wallpapers"
    ```

### 2. Dependencies
Ensure you have the following installed:
*   **Core:** `python3`, `jq`, `bash`
*   **Theming:** [`matugen`](https://github.com/InioX/matugen)
*   **Wallpaper Manager:** `dms` (Internal/Custom Tool - replace with `swww` or `hyprpaper` if needed)
*   **Hardware:** `asusctl` (Optional, for ROG laptops)
*   **CLI Tools:**
    *   [`fastfetch`](https://github.com/fastfetch-cli/fastfetch)
    *   [`pokeget-rs`](https://github.com/talwat/pokeget-rs)
    *   [`cmatrix`](https://github.com/abishekvashok/cmatrix)
    *   [`cava`](https://github.com/karlstav/cava)

### 3. Installation
1.  **Deploy Scripts:**
    ```bash
    cp -r scripts/* ~/Scripts/
    ```
2.  **Link Dotfiles:**
    ```bash
    ln -s $(pwd)/dotfiles/* ~/.config/
    ```
3.  **Shell Aliases:**
    Add to `.bashrc` / `.zshrc`:
    ```bash
    alias wp='$HOME/Scripts/Wallpaper/wp_switch.sh'
    alias ff='$HOME/Scripts/Coolstf/pokemon.sh -l'
    alias matrix='$HOME/Scripts/Coolstf/cmatrix_runner.sh'
    ```

## 🎮 Usage

### Changing Wallpapers (`wp`)

*   **Random Shuffle:**
    Picks a random image from your configured `WALLPAPER_DIR`.
    ```bash
    wp
    ```

*   **Specific Image:**
    Sets a specific image as wallpaper and syncs the theme.
    ```bash
    wp /path/to/specific/image.jpg
    ```

### Terminal Candy

*   **Theme-Aware Fastfetch:**
    Shows system info with a color-matched Pokémon.
    ```bash
    ff
    ```

*   **Theme-Aware Matrix:**
    Runs the matrix rain in your theme's primary color.
    ```bash
    matrix
    ```

## 🧠 How It Works (The "Madness")

When you run `wp`, a chain reaction occurs:

1.  **Wallpaper Set:** `dms ipc` is called to update the desktop background.
2.  **Color Extraction:** `matugen` analyzes the image and extracts the primary hex color.
3.  **System Generation:** `matugen` generates config files for `cava`, `ghostty`, `nvim`, etc., based on templates in `~/.config/matugen/templates`.
4.  **Hardware Sync:** If `asusctl` is present, the hex color is applied to the keyboard backlight.
5.  **App Reload:** Signals are sent to apps like `cava` (SIGUSR1) to hot-reload their configs.
6.  **Intelligence Update:** `pokemon_theme_manager.py` runs in the background:
    *   It determines the color category (e.g., #FF0000 -> "Red").
    *   It updates `~/.cache/current_theme_color.txt` with the exact hex.
    *   It updates `~/.cache/current_theme_pokemons.txt` with a list of valid Pokémon for that color.
7.  **Result:** The next time you run `ff` or `matrix`, they read these cache files instantly to match the new look.
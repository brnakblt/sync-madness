# Sync-Madness: Theme Synchronization Suite

This repository contains a set of scripts and configuration files to achieve a fully theme-responsive Linux environment. The system automatically extracts colors from your current wallpaper and applies them to various CLI tools and applications in real-time.

## Features

- **Wallpaper & Color Management:** Automatically extracts the primary color from the wallpaper using `matugen`.
- **Terminal Integration:**
  - **Fastfetch (`ff`):** Displays a random Pokémon that matches your current wallpaper color.
  - **Matrix (`matrix`):** Runs `cmatrix` with the color closest to your wallpaper.
- **Application Sync:**
  - **Cava:** Audio visualizer colors are updated.
  - **Ghostty:** Terminal emulator config sync.
  - **Nvim & Yazi:** Theme integration.
  - **Niri:** Window manager theming.

## Directory Structure

```
├── scripts/
│   ├── wallpaper/   # Wallpaper switching logic (wp_switch.sh)
│   ├── utils/       # Color analysis and cache managers (pokemon_theme_manager.py)
│   └── coolstf/     # Fun CLI tools (pokemon.sh, cmatrix_runner.sh)
├── dotfiles/
│   ├── matugen/     # Color generation templates
│   ├── fastfetch/   # Fastfetch config
│   ├── cava/        # Cava config
│   ├── ghostty/     # Ghostty terminal config
│   ├── nvim/        # Neovim config
│   ├── yazi/        # File manager config
│   └── niri/        # Window manager config
```

## Dependencies

Ensure you have the following installed:

*   **Core:** `python3`, `jq`, `bash`
*   **Theming:** [`matugen`](https://github.com/InioX/matugen)
*   **Wallpaper Manager:** `dms` (Internal/Custom Tool)
*   **CLI Tools:**
    *   [`fastfetch`](https://github.com/fastfetch-cli/fastfetch)
    *   [`pokeget`](https://github.com/talwat/pokeget)
    *   [`cmatrix`](https://github.com/abishekvashok/cmatrix)
    *   [`cava`](https://github.com/karlstav/cava)

## Installation & Setup

1.  **Copy Scripts:**
    Move the `scripts` folder to `~/Scripts` (or your preferred location).
    ```bash
    cp -r scripts/* ~/Scripts/
    ```

2.  **Symlink Dotfiles:**
    Link the configurations to `~/.config/`.
    ```bash
    ln -s $(pwd)/dotfiles/* ~/.config/
    ```

3.  **Setup Aliases:**
    Add the following to your shell configuration (`.bashrc` or `.zshrc`):

    ```bash
    # Wallpaper Switching
    alias wp='$HOME/Scripts/Wallpaper/wp_switch.sh'
    
    # Theme-Synced Fastfetch
    alias ff='$HOME/Scripts/Coolstf/pokemon.sh -l'
    
    # Theme-Synced Matrix
    alias matrix='$HOME/Scripts/Coolstf/cmatrix_runner.sh'
    ```

## How It Works

1.  **Trigger:** You run `wp <image_path>` or just `wp` (random).
2.  **Process (`wp_switch.sh`):**
    *   Sets wallpaper via `dms`.
    *   Generates colors via `matugen`.
    *   Reloads `cava`.
    *   Calls `pokemon_theme_manager.py`.
3.  **Update (`pokemon_theme_manager.py`):**
    *   Detects the new wallpaper color.
    *   Updates `~/.cache/current_theme_color.txt` (Hex code).
    *   Updates `~/.cache/current_theme_pokemons.txt` (List of matching Pokemon).
4.  **Display:**
    *   `ff`: Reads the cached Pokemon list and color, prints a matching Pokemon in the correct color.
    *   `matrix`: Reads the cached color, finds the closest `cmatrix` supported color, and launches it.

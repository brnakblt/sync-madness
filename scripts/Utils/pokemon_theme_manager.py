#!/usr/bin/env python3
import sys
import colorsys
import json
import os
import subprocess

CACHE_FILE = os.path.expanduser("~/.cache/pokemon_colors.json")
THEME_LIST_FILE = os.path.expanduser("~/.cache/current_theme_pokemons.txt")
UPDATE_SCRIPT = os.path.expanduser("~/Scripts/Utils/update_pokemon_colors.py")

# Map to PokeAPI colors: black, blue, brown, gray, green, pink, purple, red, white, yellow
def get_color_category(hex_color):
    try:
        h_hex = hex_color.lstrip('#')
        r, g, b = tuple(int(h_hex[i:i+2], 16)/255.0 for i in (0, 2, 4))
    except:
        return 'random'

    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    h_deg = h * 360

    if v < 0.15: return 'black'
    if s < 0.1 and v > 0.8: return 'white'
    if s < 0.15: return 'gray'

    if (h_deg >= 0 and h_deg < 15) or (h_deg >= 345):
        return 'red'
    elif h_deg >= 15 and h_deg < 45:
        return 'brown' if v < 0.6 else 'red'
    elif h_deg >= 45 and h_deg < 75:
        return 'yellow'
    elif h_deg >= 75 and h_deg < 155:
        return 'green'
    elif h_deg >= 155 and h_deg < 190:
        return 'blue' 
    elif h_deg >= 190 and h_deg < 260:
        return 'blue'
    elif h_deg >= 260 and h_deg < 320:
        return 'purple'
    elif h_deg >= 320 and h_deg < 345:
        return 'pink'
    
    return 'random'

def get_wallpaper_color():
    # 1. Try to get from arguments (if not empty)
    if len(sys.argv) > 1 and sys.argv[1].strip():
        return sys.argv[1]
    
    # 2. Try to get from matugen via DMS wallpaper
    try:
        # Get wallpaper path
        wp_path_cmd = subprocess.run(["dms", "ipc", "call", "wallpaper", "get"], capture_output=True, text=True)
        if wp_path_cmd.returncode != 0:
            return None
        wp_path = wp_path_cmd.stdout.strip()
        
        if not os.path.exists(wp_path):
            return None

        # Get color
        matugen_cmd = subprocess.run(
            ["matugen", "image", wp_path, "--json", "hex", "--dry-run"], 
            capture_output=True, text=True
        )
        if matugen_cmd.returncode == 0:
            data = json.loads(matugen_cmd.stdout)
            return data.get('colors', {}).get('primary', {}).get('default')
    except:
        pass
    
    return None

def main():
    # Ensure cache exists
    if not os.path.exists(CACHE_FILE):
        print("Cache not found, running update script...")
        subprocess.run([sys.executable, UPDATE_SCRIPT])

    hex_color = get_wallpaper_color()
    color_cat = 'random'
    
    if hex_color:
        color_cat = get_color_category(hex_color)
        # Save color to cache file for pokemon.sh
        with open(os.path.expanduser("~/.cache/current_theme_color.txt"), "w") as cf:
            cf.write(hex_color)
    else:
        # Save a default or empty
        with open(os.path.expanduser("~/.cache/current_theme_color.txt"), "w") as cf:
            cf.write("#FFFFFF")
    
    print(f"Detected Color: {hex_color} -> Category: {color_cat}")

    pokemon_list = []
    
    try:
        with open(CACHE_FILE, 'r') as f:
            data = json.load(f)
            
        if color_cat in data and data[color_cat]:
            pokemon_list = data[color_cat]
        else:
            # Flatten all lists if random or category not found
            for key in data:
                pokemon_list.extend(data[key])
    except Exception as e:
        print(f"Error reading cache: {e}")
        # If all else fails, write nothing, script will handle fallback
    
    # Write to theme list file
    with open(THEME_LIST_FILE, 'w') as f:
        for p in pokemon_list:
            f.write(f"{p}\n")
    
    print(f"Updated {THEME_LIST_FILE} with {len(pokemon_list)} pokemons.")

if __name__ == "__main__":
    main()

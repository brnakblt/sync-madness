#!/bin/bash
# by discomanfulanito,
# for everyone — as code should be

# Change with your fetcher
FETCHER="fastfetch"
THEME_LIST_FILE="$HOME/.cache/current_theme_pokemons.txt"

FETCHER_HEIGHT=$((($($FETCHER | wc -l) + 1) / 2))

# Extra settings
EXTRA_PADDING_H=2
EXTRA_PADDING_W=0

# Room for the sprite
WIDTH=38

# --- Fast Selection Logic ---

if [ -f "$THEME_LIST_FILE" ] && [ -s "$THEME_LIST_FILE" ]; then
    # Pick a random line from the pre-generated file
    SELECTED_POKEMON=$(shuf -n 1 "$THEME_LIST_FILE")
else
    SELECTED_POKEMON="random"
fi

# 4. Get Sprite
# We use a loop in case the selected pokemon name isn't recognized by pokeget
MAX_ATTEMPTS=3
attempt=0
full_output=""

while [ $attempt -lt $MAX_ATTEMPTS ]; do
    full_output=$(pokeget "$SELECTED_POKEMON" 2>/dev/null)
    if [ -n "$full_output" ]; then
        break
    fi
    # If failed, pick a truly random one
    SELECTED_POKEMON="random"
    attempt=$((attempt + 1))
done

# Final fallback
if [ -z "$full_output" ]; then
    full_output=$(pokeget random)
fi

# Debug logging
echo "Selected: $SELECTED_POKEMON" > /tmp/pokemon_debug.log

# Separate Name and Sprite
# 1. Get the first line (Name)
raw_name=$(echo "$full_output" | head -n 1)
echo "Raw Name: $raw_name" >> /tmp/pokemon_debug.log

# 2. Get the rest (Sprite)
sprite_art=$(echo "$full_output" | tail -n +2)

# If sprite_art is empty, something is wrong, just use full output
if [ -z "$sprite_art" ]; then
    final_logo="$full_output"
    sprite_width=${#full_output}
    real_sprite_width=$(((sprite_width + 35 - 1) / 35))
else
    # Gets sprite's height
    height=$(echo "$sprite_art" | wc -l)
    # Add buffer for name and newlines
    height=$((height + 3))

    # Calculate Sprite Width
    sprite_width=0
    while IFS= read -r line; do
        line_w=${#line}
        if ((line_w > sprite_width)); then
            sprite_width=$line_w
        fi
    done <<<"$sprite_art"

    real_sprite_width=$(((sprite_width + 35 - 1) / 35))
    if [ "$real_sprite_width" -lt 10 ]; then
         real_sprite_width=30
    fi
    
    echo "Calculated Width: $real_sprite_width" >> /tmp/pokemon_debug.log

    # Center the Name
    # EXTRACT REAL NAME FROM OUTPUT (Fixes 'RANDOM' issue)
    raw_first_line=$(echo "$full_output" | head -n 1)
    
    # Strip ANSI codes to check content
    clean_line_text=$(echo -e "$raw_first_line" | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g')
    
    # Check for block characters (sprite artifacts) or empty
    # If it contains blocks or is empty, it's not a name.
    if [[ "$clean_line_text" =~ [▄▀█▓▒░] ]] || [ -z "${clean_line_text// }" ]; then
        # It's a sprite line, not a name!
        if [ "$SELECTED_POKEMON" != "random" ]; then
            clean_name="$SELECTED_POKEMON"
        else
            clean_name="POKEMON"
        fi
        # Since line 1 was sprite, we shouldn't have removed it. Use full output.
        sprite_art="$full_output"
    else
        # It IS a name
        clean_name="$clean_line_text"
        # Since line 1 was name, we correctly took the rest as sprite
        sprite_art=$(echo "$full_output" | tail -n +2)
    fi
    
    # Convert to uppercase
    clean_name=$(echo "$clean_name" | tr '[:lower:]' '[:upper:]')
    name_len=${#clean_name}
    
    # Get Theme Color
    THEME_COLOR_FILE="$HOME/.cache/current_theme_color.txt"
    COLOR_ANSI="\033[1;37m" # Default White
    
    if [ -f "$THEME_COLOR_FILE" ]; then
        HEX=$(cat "$THEME_COLOR_FILE")
        # Check if valid hex #RRGGBB
        if [[ $HEX =~ ^#[0-9a-fA-F]{6}$ ]]; then
            R=$((16#${HEX:1:2}))
            G=$((16#${HEX:3:2}))
            B=$((16#${HEX:5:2}))
            COLOR_ANSI="\033[1;38;2;${R};${G};${B}m"
        fi
    fi

    if [ $real_sprite_width -gt $name_len ]; then
        padding=$(( (real_sprite_width - name_len) / 2 ))
        spaces=$(printf "%${padding}s")
        # Reset + Custom Color Name
        formatted_name="${spaces}\033[0m${COLOR_ANSI}${clean_name}\033[0m"
    else
        formatted_name="\033[0m${COLOR_ANSI}${clean_name}\033[0m"
    fi

    
    # Construct final output: Sprite FIRST, then Name at BOTTOM
    final_logo="${sprite_art}\n\n${formatted_name}"
    
    # Log for debug
    echo -e "$final_logo" > /tmp/pokemon_final.log
    
    sprite_width=$real_sprite_width
fi

# Pad for vertical centering
# Increased padding as requested
pad_top=5

# Calculate the lateral padding
pad_lat=$((($WIDTH - sprite_width) / 2))
pad_lat=$((pad_lat + EXTRA_PADDING_W))
if [ $pad_lat -lt 0 ]; then pad_lat=0; fi

# Output
echo -e "$final_logo" | $FETCHER --file-raw - --logo-padding-top $pad_top --logo-padding-left $pad_lat --logo-padding-right $pad_lat

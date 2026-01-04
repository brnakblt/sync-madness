#!/usr/bin/env python3
import sys
import colorsys
import os

CACHE_FILE = os.path.expanduser("~/.cache/current_theme_color.txt")

# Supported cmatrix colors
COLORS = {
    'green': (0, 1, 0),
    'red': (1, 0, 0),
    'blue': (0, 0, 1),
    'white': (1, 1, 1),
    'yellow': (1, 1, 0),
    'cyan': (0, 1, 1),
    'magenta': (1, 0, 1),
    'black': (0, 0, 0)
}

def hex_to_rgb(h):
    try:
        h = h.lstrip('#')
        return tuple(int(h[i:i+2], 16)/255.0 for i in (0, 2, 4))
    except:
        return (0, 1, 0) # Default green

def get_closest_color(hex_color):
    rgb = hex_to_rgb(hex_color)
    r, g, b = rgb
    
    # Simple formatting for white/black/gray based on saturation/value
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    
    if v < 0.2: return 'black'
    if s < 0.1 and v > 0.7: return 'white'
    
    # Find closest distance in RGB space
    min_dist = float('inf')
    closest = 'green'
    
    for name, c_rgb in COLORS.items():
        if name in ['black', 'white']: continue
        dist = (r - c_rgb[0])**2 + (g - c_rgb[1])**2 + (b - c_rgb[2])**2
        if dist < min_dist:
            min_dist = dist
            closest = name
            
    return closest

try:
    if os.path.exists(CACHE_FILE):
        with open(CACHE_FILE, 'r') as f:
            hex_color = f.read().strip()
        print(get_closest_color(hex_color))
    else:
        print('green')
except:
    print('green')

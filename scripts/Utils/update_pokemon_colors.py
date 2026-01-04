#!/usr/bin/env python3
import json
import urllib.request
import os
import sys

CACHE_FILE = os.path.expanduser("~/.cache/pokemon_colors.json")
COLORS = [
    "black", "blue", "brown", "gray", "green", 
    "pink", "purple", "red", "white", "yellow"
]
API_URL = "https://pokeapi.co/api/v2/pokemon-color/"

def fetch_pokemons_by_color():
    data = {}
    print("Fetching Pokemon color data from PokeAPI...")
    
    for color in COLORS:
        try:
            url = f"{API_URL}{color}"
            print(f"Fetching {color}...", end="", flush=True)
            with urllib.request.urlopen(url) as response:
                if response.status == 200:
                    json_resp = json.loads(response.read().decode())
                    # extract pokemon species names
                    species_list = [p['name'] for p in json_resp['pokemon_species']]
                    data[color] = species_list
                    print(f" Done ({len(species_list)} found)")
                else:
                    print(f" Failed (Status {response.status})")
        except Exception as e:
            print(f" Error: {e}")
            data[color] = []

    # Save to cache
    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, 'w') as f:
        json.dump(data, f)
    print(f"Data saved to {CACHE_FILE}")

if __name__ == "__main__":
    fetch_pokemons_by_color()

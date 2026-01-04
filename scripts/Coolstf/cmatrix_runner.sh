#!/bin/bash
COLOR=$(python3 $HOME/Scripts/Utils/get_cmatrix_color.py)
cmatrix -C "$COLOR" "$@"

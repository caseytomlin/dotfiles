#!/bin/sh
if  command -v fzf >/dev/null 2>&1; then 
    echo "starship already installed"
else
    sudo apt update && sudo apt install fzf
fi

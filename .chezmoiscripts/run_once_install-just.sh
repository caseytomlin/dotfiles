#!/bin/sh
if  command -v just >/dev/null 2>&1; then 
    echo "just already installed"
else
    pipx install rust-just
fi

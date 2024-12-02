#!/bin/sh
if  command -v uv >/dev/null 2>&1; then 
    echo "uv already installed"
else
    curl -LsSf https://astral.sh/uv/install.sh | sudo sh -y
fi

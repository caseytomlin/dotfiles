#!/usr/bin/env bash

set -ex

sudo apt update

echo "Installing tools..."

if  command -v pipx >/dev/null 2>&1; then 
    echo "pipx already installed"
else
    sudo apt install pipx
    pipx ensurepath
fi

if  command -v just >/dev/null 2>&1; then 
    echo "just already installed"
else
    pipx install rust-just
fi

if  command -v fzf >/dev/null 2>&1; then 
    echo "fzf already installed"
else
    sudo apt install fzf
fi

if  command -v uv >/dev/null 2>&1; then 
    echo "uv already installed"
else
    curl -LsSf https://astral.sh/uv/install.sh | sudo sh
fi

if  command -v aws >/dev/null 2>&1; then 
    echo "aws already installed"
else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

if  command -v starship >/dev/null 2>&1; then 
    echo "starship already installed"
else
    curl -fsSL https://starship.rs/install.sh | sudo sh -s -- -y

#!/usr/bin/env bash

set -ex

export DEBIAN_FRONTEND=noninteractive

s() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@"
}

sudo apt-get update && s upgrade

echo "Installing tools..."

if command -v zsh >/dev/null 2>&1; then
    echo "zsh already installed"
else
    s install -y zsh
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh already installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if command -v atuin >/dev/null 2>&1; then
    echo "atuin already installed"
else
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi

if  command -v pipx >/dev/null 2>&1; then 
    echo "pipx already installed"
else
    s install pipx
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
    s install fzf
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
fi

if command -v npm >/dev/null 2>&1; then
    echo "npm already installed"
else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
fi

if command -v ccr >/dev/null 2>&1; then
    echo "claude code router already installed"
else
    # Install Claude Code globally
    npm install -g @anthropic-ai/claude-code

    # Install Claude Code Router for myGenAssist integration
    npm install -g @musistudio/claude-code-router
fi

# if command -v bun >/dev/null 2>&1; then
#     echo "bun already installed"
# else
#     curl -fsSL https://bun.com/install | bash
# fi
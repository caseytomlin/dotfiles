#!/usr/bin/env bash

set -euo pipefail

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

# if command -v opencode >/dev/null 2>&1; then
#     echo "OpenCode CLI already installed"
# else
#     curl -fsSL https://opencode.ai/install.sh | bash
# fi

if command -v ccr >/dev/null 2>&1; then
    echo "claude code router already installed"
else
    # Install Claude Code globally
    npm install -g @anthropic-ai/claude-code

    # Install Claude Code Router for myGenAssist integration
    npm install -g @musistudio/claude-code-router
fi


CONFIG="$HOME/.claude-code-router/config.json"
MODEL_IDS=$(curl -s -H "Authorization: Bearer $MGA_API_KEY" https://chat.int.bayer.com/api/v2/models | jq -r '.data[].id')

PRIMARY_MODEL=$(printf '%s\n' "$MODEL_IDS" | grep -m1 'claude' || printf '%s\n' "$MODEL_IDS" | head -n1)

tmp=$(mktemp)
jq --argjson models "$(printf '%s\n' "$MODEL_IDS" | jq -R . | jq -s .)" \
   --arg primary "$PRIMARY_MODEL" \
   '.Providers[0].models = $models | .Router.default = "myGenAssist,\($primary)"' \
   "$CONFIG" > "$tmp"
mv "$tmp" "$CONFIG"

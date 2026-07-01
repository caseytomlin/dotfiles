#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

s() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" "$@"
}

run_with_timeout() {
    local seconds="$1"
    shift

    if command -v timeout >/dev/null 2>&1; then
        timeout "$seconds" "$@"
    else
        "$@"
    fi
}

init_nvm() {
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        export NVM_DIR="$HOME/.nvm"
    elif [ -s "/usr/local/share/nvm/nvm.sh" ]; then
        export NVM_DIR="/usr/local/share/nvm"
    else
        return 1
    fi

    # shellcheck disable=SC1090
    . "$NVM_DIR/nvm.sh"
}

ensure_nvm_and_node() {
    if [ ! -s "$HOME/.nvm/nvm.sh" ] && [ ! -s "/usr/local/share/nvm/nvm.sh" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    fi

    init_nvm || {
        echo "warning: nvm was not available after install; continuing with existing node"
        return 0
    }

    local default_version major
    default_version="$(nvm version default 2>/dev/null || true)"

    if [ "$default_version" = "N/A" ] || [ -z "$default_version" ]; then
        nvm install --lts
        nvm alias default 'lts/*'
    fi

    nvm use --delete-prefix --silent default >/dev/null 2>&1 || {
        nvm install --lts
        nvm alias default 'lts/*'
        nvm use --delete-prefix --silent default >/dev/null 2>&1 || true
    }

    if command -v node >/dev/null 2>&1; then
        major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
        if [ "${major:-0}" -lt 20 ]; then
            nvm install --lts
            nvm alias default 'lts/*'
            nvm use --delete-prefix --silent default >/dev/null 2>&1 || true
        fi
    fi

    hash -r
}

ensure_user_npm_prefix() {
    if ! command -v npm >/dev/null 2>&1; then
        return 0
    fi

    export CI=true
    export npm_config_update_notifier=false
    export npm_config_fund=false
    export npm_config_audit=false
    export npm_config_progress=false

    local desired_prefix="${HOME}/.local"
    local current_prefix

    current_prefix="$(run_with_timeout 10s npm config get prefix 2>/dev/null || true)"
    current_prefix="$(printf '%s' "$current_prefix" | tr -d '\r')"

    if [ "$current_prefix" != "$desired_prefix" ]; then
        run_with_timeout 10s npm config set prefix "$desired_prefix" --location=user >/dev/null 2>&1 || {
            echo "warning: failed to set npm user prefix to $desired_prefix; continuing"
            return 0
        }
    fi

    mkdir -p "$desired_prefix/bin" "$desired_prefix/lib"

    case ":$PATH:" in
        *":$desired_prefix/bin:"*) ;;
        *) export PATH="$desired_prefix/bin:$PATH" ;;
    esac
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
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

if command -v atuin >/dev/null 2>&1; then
    echo "atuin already installed"
else
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive
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

if command -v jq >/dev/null 2>&1; then
    echo "jq already installed"
else
    s install -y jq
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

ensure_nvm_and_node

ensure_user_npm_prefix

# if command -v opencode >/dev/null 2>&1; then
#     echo "OpenCode CLI already installed"
# else
#     curl -fsSL https://opencode.ai/install.sh | bash
# fi

if command -v ccr >/dev/null 2>&1 && ccr --version >/dev/null 2>&1; then
    echo "claude code router already installed"
else
    # Install Claude Code globally
    npm install -g --no-audit --no-fund --loglevel=error @anthropic-ai/claude-code

    # Install Claude Code Router for myGenAssist integration
    npm install -g --no-audit --no-fund --loglevel=error @musistudio/claude-code-router
fi


CONFIG_DIR="$HOME/.claude-code-router"
CONFIG="$CONFIG_DIR/config.json"
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG" ]; then
        cat > "$CONFIG" <<'EOF'
{
    "Providers": [
        {
        "name": "myGenAssist",
        "api_base_url": "https://chat.int.bayer.com/api/v2/chat/completions",
    "api_key": "${MGA_API_KEY}",
        "models": []
        }
    ],
    "Router": {
        "default": ""
    }
}
EOF
fi

if [ -n "${MGA_API_KEY:-}" ]; then
    MODEL_IDS=$(curl -fss -H "Authorization: Bearer $MGA_API_KEY" https://chat.int.bayer.com/api/v2/models | jq -r '.data[].id')

    if [ -n "$MODEL_IDS" ]; then
        PRIMARY_MODEL=$(printf '%s\n' "$MODEL_IDS" | grep -m1 'claude' || printf '%s\n' "$MODEL_IDS" | head -n1)

        tmp=$(mktemp)
        jq --argjson models "$(printf '%s\n' "$MODEL_IDS" | jq -R . | jq -s .)" \
           --arg primary "$PRIMARY_MODEL" \
           '.Providers[0].models = $models | .Router.default = "myGenAssist,\($primary)"' \
           "$CONFIG" > "$tmp"
        mv "$tmp" "$CONFIG"
    else
        echo "MGA_API_KEY is set, but no models were returned; leaving claude-code-router config unchanged"
    fi
else
    echo "MGA_API_KEY not set - skipping claude-code-router model refresh"
fi

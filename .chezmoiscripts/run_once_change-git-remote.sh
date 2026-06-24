#!/usr/bin/env bash

set -eu

SSH_DIR=$HOME/.ssh
ID_RSA_FILENAME=$SSH_DIR/id_rsa

prefer_github_ssh() {
    if [ "${PREFER_GITHUB_SSH:-}" = "yes" ]; then
        return 0
    fi

    if [ -f /.dockerenv ] || [ -n "${REMOTE_CONTAINERS:-}" ] || [ -n "${DEVCONTAINER:-}" ]; then
        return 1
    fi

    if [ -n "${GH_ID_RSA:-}" ] || [ -f "$ID_RSA_FILENAME" ] || [ -f "$SSH_DIR/id_ed25519" ]; then
        return 0
    fi

    if command -v ssh-add >/dev/null 2>&1 && ssh-add -L >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

if [ -f "$ID_RSA_FILENAME" ]; then
    echo "SSH private key already exists"
else
    echo "SSH private key not found"
    # Only add SSH key if GH_ID_RSA is provided
    if [ -n "${GH_ID_RSA:-}" ]; then
        echo "Adding SSH private key from GH_ID_RSA"
        mkdir -p "$SSH_DIR"
        echo "$GH_ID_RSA" > $ID_RSA_FILENAME
        chmod 600 $ID_RSA_FILENAME
    else
        echo "⚠️  GH_ID_RSA not set - skipping SSH key setup"
        echo "    You can configure SSH manually if needed"
    fi
fi

if [ -z "${CODESPACES:-}" ]; then
    if prefer_github_ssh; then
        echo "Configuring git to prefer SSH for GitHub"
        git config --global url."git@github.com:".insteadOf "https://github.com/" || true
    else
        echo "Skipping GitHub SSH rewrite; HTTPS remains the default"
    fi
fi

exit 0

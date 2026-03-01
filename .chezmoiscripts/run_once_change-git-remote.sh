#!/usr/bin/env bash

set -eu

SSH_DIR=$HOME/.ssh
ID_RSA_FILENAME=$SSH_DIR/id_rsa

if [ -f $ID_RSA_FILENAME ]; then
    echo "SSH private key already exists"
    exit 0
else
    echo "SSH private key not found"
    # Only add SSH key if GH_ID_RSA is provided
    if [ -n "${GH_ID_RSA:-}" ]; then
        echo "Adding SSH private key from GH_ID_RSA"
        mkdir -p $SSH_DIR
        echo "$GH_ID_RSA" > $ID_RSA_FILENAME
        chmod 600 $ID_RSA_FILENAME
    else
        echo "⚠️  GH_ID_RSA not set - skipping SSH key setup"
        echo "    You can configure SSH manually if needed"
    fi
fi

if [ -z "${CODESPACES:-}" ]; then
  echo "Configuring git for SSH"
  git config --global url."git@github.com".insteadOf "https://github.com" || true
  git config --local url."git@github.com".insteadOf "https://github.com" || true
fi

exit 0

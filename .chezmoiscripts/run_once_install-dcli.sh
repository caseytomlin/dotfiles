#!/bin/sh

set -eux

if  command -v dcli >/dev/null 2>&1; then 
    echo "dcli already installed"
else
    wget https://github.com/Dashlane/dashlane-cli/releases/download/v6.2447.2/dcli-linux-x64
    chmod +x dcli-linux-x64
    sudo mv dcli-linux-x64 /usr/local/bin/dcli
fi

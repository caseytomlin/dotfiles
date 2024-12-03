#!/bin/sh

set -eu

SSH_DIR=$HOME/.ssh
ID_RSA_FILENAME=$SSH_DIR/id_rsa

if [ -f $ID_RSA_FILENAME ]; then
    echo "SSH private key already exists"
    exit 0
else
    echo "Adding SSH private key"
    mkdir -p $SSH_DIR
    echo "$GH_ID_RSA" > $ID_RSA_FILENAME
    chmod 600 $ID_RSA_FILENAME
    exit 0
fi


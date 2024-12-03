#!/bin/sh

set -eu

ID_RSA_FILENAME=$HOME/.ssh/id_rsa

echo "$GH_ID_RSA" > $ID_RSA_FILENAME
chmod 600 $ID_RSA_FILENAME

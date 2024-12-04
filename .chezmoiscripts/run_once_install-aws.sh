#!/bin/sh
if  command -v aws >/dev/null 2>&1; then 
    echo "aws already installed"
else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

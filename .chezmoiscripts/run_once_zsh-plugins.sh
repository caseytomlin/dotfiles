#!/bin/sh

set -eux

if [ -d "`eval echo ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use`" ]; then
    git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use pull
else
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
fi

if [ -d "`eval echo ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting`" ]; then
    git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting pull
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

[ -f /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-autosuggestions.gpg ] && sudo rm /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-autosuggestions.gpg 
wget -qO- https://build.opensuse.org/projects/shells:zsh-users:zsh-autosuggestions/signing_keys/download\?kind\=gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/shells_zsh-users_zsh-autosuggestions.gpg

if [ -d "`eval echo ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions`" ]; then
    git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions pull
else
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi
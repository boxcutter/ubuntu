#!/usr/bin/env bash
set -e

echo "Configuring ZSH..."
apt-get purge -y update-notifier-common
apt-get install -y update-notifier-common
apt-get install -y git zsh
if [ ! -d ~vagrant/.oh-my-zsh ]; then
  git clone https://github.com/robbyrussell/oh-my-zsh.git ~vagrant/.oh-my-zsh
fi

chsh -s /usr/bin/zsh vagrant

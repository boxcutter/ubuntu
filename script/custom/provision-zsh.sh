#!/usr/bin/env bash
set -e

echo "Configuring ZSH..."
sudo apt-get install -y zsh
if [ ! -d ~vagrant/.oh-my-zsh ]; then
  git clone https://github.com/robbyrussell/oh-my-zsh.git ~vagrant/.oh-my-zsh
fi

chsh -s /bin/zsh vagrant

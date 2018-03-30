#!/usr/bin/env bash
set -e

# install npm
echo "Provisioning npm..."
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential

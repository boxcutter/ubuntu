#!/usr/bin/env bash
set -e

# install npm
echo "Provisioning npm and node 14 with retirejs..."
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
apt-get install -y nodejs
apt-get install -y npm
npm install -g retire
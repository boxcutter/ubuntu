#!/usr/bin/env bash
set -e

# install npm
echo "Provisioning npm and node 14 with retirejs..."
apt-get install -y curl
## TODO: REDO THIS PART!!!
# curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
# sleep 10
# apt install -y nodejs
# if [ "$USER_FOLDER" = "vagrant" ]
# then
# apt install -y npm
# fi
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" 
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install node

# apt-get install -y -f npm
npm install -g retire
npm install -g license-checker

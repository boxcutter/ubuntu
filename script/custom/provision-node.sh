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

nvm_version="v0.39.1"
mkdir -p "/home/$USER_FOLDER/.nvm"
export NVM_DIR="/home/$USER_FOLDER/.nvm" # to make sure nvm is install for ubuntu user

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh | bash

echo 'export NVM_DIR="$HOME/.nvm"' >> /home/$USER_FOLDER/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm'  >> /home/$USER_FOLDER/.bashrc

#nvm install node

# apt-get install -y -f npm
#npm install -g retire
#npm install -g license-checker

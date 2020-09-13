#!/usr/bin/env bash

echo "Provisioning vault workshop"
cd /home/$USER_FOLDER/workspace
wget https://github.com/benno001/vault-in-practice/archive/master.zip
unzip master.zip && rm master.zip
mv vault-in-practice-master vault-in-practice
sudo chown -R $USER_FOLDER /home/$USER_FOLDER/workspace/vault-in-practice

echo "installing Trufflehog"
sudo apt install-y python3-pip
pip3 install trufflehog
echo "export PATH=\"`python3 -m site --user-base`/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc
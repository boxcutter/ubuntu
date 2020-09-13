#!/usr/bin/env bash
echo "Creating folders"
mkdir -p /home/$USER_FOLDER/workspace
sudo chown -R $USER_FOLDER /home/$USER_FOLDER/workspace
mkdir -p /home/$USER_FOLDER/tools
sudo chown -R $USER_FOLDER /home/$USER_FOLDER/tools
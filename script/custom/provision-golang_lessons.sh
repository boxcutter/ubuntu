#!/usr/bin/env bash
echo "Preparing GolangLessons"
cd /home/$USER_FOLDER/workspace
git clone https://github.com/jlauinger/go-unsafepointer-poc/tree/master/information-leak
sudo apt update
sudo apt install golang-go -y
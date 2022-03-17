#!/usr/bin/env bash
echo "Preparing GolangLessons"
cd /home/$USER_FOLDER/workspace
git clone https://github.com/jlauinger/go-unsafepointer-poc
sudo apt update
sudo apt install golang-go gdb python3-pip python2 -y

echo "preparing peda for golang lessons"
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit
echo "DONE! debug your program with gdb and enjoy"

pip install ropper pwn

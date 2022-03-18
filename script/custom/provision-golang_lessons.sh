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

pip3 install ropper pwn
sudo add-apt-repository universe
sudo apt update 
sudo apt install python2
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py
pip2 --version
pip2 install ropper pwn pathlib2
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source /home/ubuntu/.gvm/scripts/gvm
mkdir /home/ubuntu/workspace/goioutil
git clone https://gist.github.com/a53921529b21b2a05ea5b92a5df00bce.git /home/ubuntu/workspace/goioutil
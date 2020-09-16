#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o xtrace

export DEBIAN_FRONTEND=noninteractive

apt-get clean
cd /var/lib/apt
mv lists lists.old
mkdir -p lists/partial
apt-get clean
apt-get update
apt-get clean

sleep 10

add-apt-repository main
add-apt-repository universe
add-apt-repository restricted
add-apt-repository multiverse
sudo -- sh -c "echo 'deb http://security.ubuntu.com/ubuntu/ bionic-security multiverse main restricted universe' >> /etc/apt/sources.list"
sudo -- sh -c "echo 'deb http://archive.ubuntu.com/ubuntu bionic-updates multiverse main restricted universe' >> /etc/apt/sources.list"
sudo -- sh -c "echo 'deb http://archive.ubuntu.com/ubuntu bionic-backports multiverse main restricted universe' >> /etc/apt/sources.list"

apt-get update -y
apt-get upgrade -y

sleep 10

# Install OpenSSH
apt-get install -y openssh-server tightvncserver
apt-get install -y xfce4 xfce4-goodies

echo "Fixing vnc-server"
mkdir ~/.vnc
echo "#!/bin/sh" >> ~/.vnc/xstartup
echo "" >> ~/.vnc/xstartup
echo "xrdb $HOME/.Xresources" >> ~/.vnc/xstartup
echo "sudo startxfce4 &" >> ~/.vnc/xstartup

chmod 777 ~/.vnc/xstartup

echo "sudo xhost +"  >> ~/quickfix.sh
echo "sudo sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /usr/lib/x86_64-linux-gnu/libxcb.so.1 & " >> ~/quickfix.sh
echo "sudo chown -R ubuntu:$(id -gn ubuntu) /home/ubuntu/.config" >> ~/quickfix.sh
echo "echo \"With this quickfix NPM, Firefox and VS Code should be fixed again. Please click ok at the next dialog\"">> ~/quickfix.sh
echo "code ." >> ~/quickfix.sh
echo "sudo chown -R ubuntu /home/ubuntu/.vscode" >> ~/quickfix.sh
chmod 777 ~/quickfix.sh



sudo snap install firefox


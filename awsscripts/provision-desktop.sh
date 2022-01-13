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
sudo -- sh -c "echo 'deb http://security.ubuntu.com/ubuntu/ focal-security multiverse main restricted universe' >> /etc/apt/sources.list"
sudo -- sh -c "echo 'deb http://archive.ubuntu.com/ubuntu focal-updates multiverse main restricted universe' >> /etc/apt/sources.list"
sudo -- sh -c "echo 'deb http://archive.ubuntu.com/ubuntu focal-backports multiverse main restricted universe' >> /etc/apt/sources.list"

apt-get update -y
apt-get upgrade -y

sleep 10

# Install OpenSSH
apt-get install -y openssh-server tightvncserver mate-desktop-environment mate-indicator-applet firefox

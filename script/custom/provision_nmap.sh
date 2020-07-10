#!/usr/bin/env bash
echo "Provisioning nmap"
sleep 10
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt-get install -y -q
sudo apt-get install -y nmap git

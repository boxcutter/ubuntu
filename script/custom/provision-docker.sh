#!/usr/bin/env bash
echo "provisioning docker"
# Install recommended extra packages
# apt-get install -y \
#     linux-image-extra-$(uname -r) \
#     linux-image-extra-virtual

echo "provisioning docker (apt, ca-cert, curl, software props)"
# Allow apt to use repo over HTTPS
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

echo "provisioning docker(get docker gpg)"
# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "provisioning docker(repo)"
# Set up the stable repo
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "provisioning docker (Update)"
# Update the packages
apt-get update

echo "provisioning docker (install)"
# Install docker-ce
apt-get install -y docker-ce

echo "provisioning docker (Access dockers)"
# Access docker w/o sudo
usermod -aG docker vagrant

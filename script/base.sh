#!/bin/bash -eux

apt-get -y update
apt-get -y upgrade
apt-get -y install curl
# Ensure NFS mounts work properly
apt-get -y install nfs-common
apt-get clean

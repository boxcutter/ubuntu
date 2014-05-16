#!/bin/bash

date > /etc/vagrant_box_build_time

VAGRANT_USER=vagrant
VAGRANT_HOME=/home/$VAGRANT_USER

# Create Vagrant user (if not already present)
if ! id -u $VAGRANT_USER >/dev/null 2>&1; then
    echo "==> Creating $VAGRANT_USER user"
    /usr/sbin/groupadd $VAGRANT_USER
    /usr/sbin/useradd $VAGRANT_USER -g $VAGRANT_USER -G sudo -d $VAGRANT_HOME --create-home
    echo "${VAGRANT_USER}:${VAGRANT_USER}" | chpasswd
fi

# Set up sudo
echo "==> Giving ${VAGRANT_USER} sudo powers"
echo "${VAGRANT_USER}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

echo "==> Installing vagrant key"
mkdir $VAGRANT_HOME/.ssh
chmod 700 $VAGRANT_HOME/.ssh
cd $VAGRANT_HOME/.ssh
# https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
mkdir -p /mnt/floppy
modprobe floppy
mount -t vfat /dev/fd0 /mnt/floppy
cp /mnt/floppy/vagrant.pub $VAGRANT_HOME/.ssh/authorized_keys
umount /mnt/floppy
rmdir /mnt/floppy
chmod 600 $VAGRANT_HOME/.ssh/authorized_keys
chown -R $VAGRANT_USER:$VAGRANT_USER $VAGRANT_HOME/.ssh

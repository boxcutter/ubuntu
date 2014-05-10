#!/bin/bash -eux

# Clean up tmp
rm -rf /tmp/*

# Cleanup apt cache
apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Clean up log files
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count
rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count
rm /boot/whitespace

# Whiteout swaps
swappart=$(cat /proc/swaps | tail -n1 | awk -F ' ' '{print $1}')
if [ "$swappart" != "" ]; then
    swapoff $swappart
    dd if=/dev/zero of=$swappart
    mkswap $swappart
    swapon $swappart
fi

# Wait (otherwise Packer will cry)
sync

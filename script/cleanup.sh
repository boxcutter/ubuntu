#!/bin/bash -eux

SSH_USER=${SSH_USERNAME:-vagrant}
DISK_USAGE_BEFORE_CLEANUP=$(df -h)

# Make sure udev does not block our network - http://6.ptmc.org/?p=164
echo "==> Cleaning up udev rules"
rm -rf /dev/.udev/

if [ -e /lib/udev/rules.d/75-persistent-net-generator.rules ]; then
    rm /lib/udev/rules.d/75-persistent-net-generator.rules > /dev/null 2>&1
fi

echo "==> Cleaning up leftover dhcp leases"
# Ubuntu 10.04
if [ -d "/var/lib/dhcp3" ]; then
    rm /var/lib/dhcp3/* > /dev/null 2>&1
fi
# Ubuntu 12.04 & 14.04
if [ -d "/var/lib/dhcp" ]; then
    rm /var/lib/dhcp/*  > /dev/null 2>&1
fi

# Blank machine-id (DUID) so machines get unique ID generated on boot.
# https://www.freedesktop.org/software/systemd/man/machine-id.html#Initialization
echo "==> Blanking systemd machine-id"
if [ -f "/etc/machine-id" ]; then
    truncate -s 0 "/etc/machine-id"
fi

# Add delay to prevent "vagrant reload" from failing
echo "pre-up sleep 2" >> /etc/network/interfaces

echo "==> Cleaning up tmp"
rm -rf /tmp/* > /dev/null

# Cleanup apt cache
apt-get -y autoremove --purge > /dev/null
apt-get -y clean > /dev/null
apt-get -y autoclean > /dev/null

echo "==> Installed packages"
dpkg --get-selections | grep -v deinstall > /dev/null

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/${SSH_USER}/.bash_history

# Clean up log files
find /var/log -type f | while read f; do echo -ne '' > "${f}"; done;

echo "==> Clearing last login information"
>/var/log/lastlog
>/var/log/wtmp
>/var/log/btmp

if [ "$PACKER_BUILDER_TYPE" == "amazon-ebs"  ]; then
    echo "==> Amazon EBS build. Exiting cleanup.sh"
    exit 0
fi

# Whiteout /boot
if [[ $WHITEOUT  =~ true || $WHITEOUT =~ 1 || $WHITEOUT =~ yes ]]; then
    echo "==> Whiteout /boot"
    count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
    let count--
    dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count > /dev/null 2>&1
    rm /boot/whitespace
fi

echo '==> Clear out swap and disable until reboot'

set +e
swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac

set -e
if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
    /sbin/swapoff "${swappart}"
    dd if=/dev/zero of="${swappart}" bs=1M /dev/null 2>&1 || echo "dd exit code $? is suppressed" 
    /sbin/mkswap -U "${swapuuid}" "${swappart}" > /dev/null 2>&1
fi

# Zero out the free space to save space in the final image
if [[ $ZERO_SWAP  =~ true || $ZERO_SWAP =~ 1 || $ZERO_SWAP =~ yes ]]; then
    echo "==> Zero out free space"
    dd if=/dev/zero of=/EMPTY bs=1M  || echo "dd exit code $? is suppressed"
    rm -f /EMPTY
fi

# Make sure we wait until all the data is written to disk, otherwise
# Packer might quite too early before the large files are deleted
sync

echo "==> Disk usage before cleanup"
echo "${DISK_USAGE_BEFORE_CLEANUP}"

echo "==> Disk usage after cleanup"
df -h

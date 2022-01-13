#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o xtrace

export DEBIAN_FRONTEND=noninteractive

# Wait for cloudinit on the surrogate to complete before making progress
while [[ ! -f /var/lib/cloud/instance/boot-finished ]]; do
    echo 'Waiting for cloud-init...'
    sleep 1
done

# Update apt and install required packages
# apt-get update
apt-get install -y \
	gdisk \
	zfsutils-linux \
	debootstrap

# Partition the new root EBS volume
sgdisk -Zg -n1:0:4095 -t1:EF02 -c1:GRUB -n2:0:0 -t2:BF01 -c2:ZFS /dev/xvdf

# Create zpool and filesystems on the new EBS volume
zpool create \
	-o altroot=/mnt \
	-o ashift=12 \
	-o cachefile=/etc/zfs/zpool.cache \
	-O canmount=off \
	-O compression=lz4 \
	-O atime=off \
	-O normalization=formD \
	-m none \
	rpool \
	/dev/xvdf2

# Root file system
zfs create \
	-o canmount=off \
	-o mountpoint=none \
	rpool/ROOT

zfs create \
	-o canmount=noauto \
	-o mountpoint=/ \
	rpool/ROOT/ubuntu

zfs mount rpool/ROOT/ubuntu

# /home
zfs create \
	-o setuid=off \
	-o mountpoint=/home \
	rpool/home

zfs create \
	-o mountpoint=/root \
	rpool/home/root

# /var
zfs create \
	-o setuid=off \
	-o overlay=on \
	-o mountpoint=/var \
	rpool/var

zfs create \
	-o com.sun:auto-snapshot=false \
	-o mountpoint=/var/cache \
	rpool/var/cache

zfs create \
	-o com.sun:auto-snapshot=false \
	-o mountpoint=/var/tmp \
	rpool/var/tmp

zfs create \
	-o mountpoint=/var/spool \
	rpool/var/spool

zfs create \
	-o exec=on \
	-o mountpoint=/var/lib \
	rpool/var/lib

zfs create \
	-o mountpoint=/var/log \
	rpool/var/log

# Display ZFS output for debugging purposes
zpool status
zfs list

# Bootstrap Ubuntu into /mnt
debootstrap --arch amd64 focal /mnt
# cp /tmp/sources.list /mnt/etc/apt/sources.list
cp /etc/apt/sources.list /mnt/etc/apt/sources.list

# Copy the zpool cache
mkdir -p /mnt/etc/zfs
cp -p /etc/zfs/zpool.cache /mnt/etc/zfs/zpool.cache

# Create mount points and mount the filesystem
mkdir -p /mnt/{dev,proc,sys}
mount --rbind /dev /mnt/dev
mount --rbind /proc /mnt/proc
mount --rbind /sys /mnt/sys

# Copy the bootstrap script into place and execute inside chroot
cp /tmp/chroot-bootstrap.sh /mnt/tmp/chroot-bootstrap.sh
chroot /mnt /tmp/chroot-bootstrap.sh
rm -f /mnt/tmp/chroot-bootstrap.sh

# Copy the nvme identification script into /sbin inside the chroot
mkdir -p /mnt/sbin
cp /tmp/ebsnvme-id /mnt/sbin/ebsnvme-id
chmod +x /mnt/sbin/ebsnvme-id

# Copy the udev rules for identifying nvme devices into the chroot
mkdir -p /mnt/etc/udev/rules.d
cp /tmp/70-ec2-nvme-devices.rules \
	/mnt/etc/udev/rules.d/70-ec2-nvme-devices.rules

# Remove temporary sources list - CloudInit regenerates it
rm -f /mnt/etc/apt/sources.list

# This could perhaps be replaced (more reliably) with an `lsof | grep -v /mnt` loop,
# however in approximately 20 runs, the bind mounts have not failed to unmount.
sleep 10

# Unmount bind mounts
umount -l /mnt/dev
umount -l /mnt/proc
umount -l /mnt/sys

# Export the zpool
zpool export rpool

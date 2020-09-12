#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o xtrace

# Update APT with new sources
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-get --allow-insecure-repositories update -y
# apt-get update 

# Do not configure grub during package install
echo 'grub-pc grub-pc/install_devices_empty select true' | debconf-set-selections
echo 'grub-pc grub-pc/install_devices select' | debconf-set-selections

export DEBIAN_FRONTEND=noninteractive

# Install various packages needed for a booting system
apt-get install -y \
	linux-aws \
	grub-pc \
	zfsutils-linux \
	zfs-initramfs \
	gdisk

cat << EOF > /etc/default/locale
LANG="C.UTF-8"
LC_CTYPE="C.UTF-8"
EOF

# Install OpenSSH
apt-get install -y --no-install-recommends openssh-server

# Install GRUB
# shellcheck disable=SC2016
sed -ri 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="boot=zfs \$bootfs"/' /etc/default/grub
grub-probe /
grub-install /dev/xvdf

# Configure and update GRUB
mkdir -p /etc/default/grub.d
cat << EOF > /etc/default/grub.d/50-aws-settings.cfg
GRUB_RECORDFAIL_TIMEOUT=0
GRUB_TIMEOUT=0
GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0 ip=dhcp tsc=reliable net.ifnames=0"
GRUB_TERMINAL=console
EOF

update-grub

# Set options for the default interface
cat << EOF > /etc/netplan/eth0.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
EOF

# Install standard packages (python is for ebsnvme-id)
apt-get install -y ubuntu-standard \
	cloud-init \
	python

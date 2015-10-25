#!/bin/bash -eux

SSH_USER=${SSH_USERNAME:-vagrant}

if [[ $PACKER_BUILDER_TYPE =~ parallels ]]; then
    echo "==> Installing Parallels tools"
    mount -o loop /home/${SSH_USER}/prl-tools-lin.iso /mnt
    /mnt/install --install-unattended-with-deps
    umount /mnt
    rm -rf /home/${SSH_USER}/prl-tools-lin.iso
    rm -f /home/${SSH_USER}/.prlctl_version
fi

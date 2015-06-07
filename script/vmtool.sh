#!/bin/bash -eux

SSH_USER=${SSH_USERNAME:-vagrant}

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
    echo "==> Installing VMware Tools"
    # Assuming the following packages are installed
    # apt-get install -y linux-headers-$(uname -r) build-essential perl

    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop /home/vagrant/linux.iso /mnt/cdrom
    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/

    if [[ -f /mnt/cdrom/VMwareTools-9.9.2-2496486.tar.gz ]]
    then
        if [[ $(lsb_release -rs) =~ 15.04 ]]
        then
            # VMware Tools 9.9.2 build-2496486 has issues with Ubuntu 15.04
            # Patch the appropriate files to compile successfully      
            mkdir -p /mnt/floppy
            modprobe floppy
            mount -t vfat /dev/fd0 /mnt/floppy

            cd /tmp/vmware-tools-distrib

            pushd lib/modules/source
            if [ ! -f vmhgfs.tar.orig ]
            then
                cp vmhgfs.tar vmhgfs.tar.orig
            fi
            rm -rf vmhgfs-only
            tar xf vmhgfs.tar
            pushd vmhgfs-only
            patch -p1 < /mnt/floppy/vmhgfs-f_dentry-kernel-3.19-tools-9.9.2.patch
            patch inode.c < /mnt/floppy/inode-d_alias.patch
            patch page.c < /mnt/floppy/page-smp_mb.patch
            popd
            tar cf vmhgfs.tar vmhgfs-only
            rm -rf vmhgfs-only

            umount /mnt/floppy
            rmdir /mnt/floppy
        fi
    fi

    /tmp/vmware-tools-distrib/vmware-install.pl -d

    rm /home/vagrant/linux.iso
    umount /mnt/cdrom
    rmdir /mnt/cdrom
    rm -rf /tmp/VMwareTools-*
fi

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
    echo "==> Installing VirtualBox guest additions"
    # Assuming the following packages are installed
    # apt-get install -y linux-headers-$(uname -r) build-essential perl
    # apt-get install -y dkms

    VBOX_VERSION=$(cat /home/${SSH_USER}/.vbox_version)
    mount -o loop /home/${SSH_USER}/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm /home/${SSH_USER}/VBoxGuestAdditions_$VBOX_VERSION.iso
    rm /home/${SSH_USER}/.vbox_version

    if [[ $VBOX_VERSION = "4.3.10" ]]; then
        ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
    fi
fi

if [[ $PACKER_BUILDER_TYPE =~ parallels ]]; then
    echo "==> Installing Parallels tools"

    mount -o loop /home/${SSH_USER}/prl-tools-lin.iso /mnt
    /mnt/install --install-unattended-with-deps
    umount /mnt
    rm -rf /home/${SSH_USER}/prl-tools-lin.iso
    rm -f /home/${SSH_USER}/.prlctl_version
fi

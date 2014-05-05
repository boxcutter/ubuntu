#!/bin/bash -eux

function install_vmware_tools_ubuntu1204 {
    if [[ -f /mnt/cdrom/VMwareTools-9.2.2-893683.tar.gz ]]
    then
        # VMware Tools 9.2.2 build-893683 will fail to find the header files
        # Link to a place where it can find them
        pushd /lib/modules/$(uname -r)/build/include/linux
        ln -s ../generated/utsrelease.h
        ln -s ../generated/autoconf.h
        ln -s ../generated/uapi/linux/version.h
        popd -

        mkdir -p /mnt/floppy
        modprobe floppy
        mount -t vfat /dev/fd0 /mnt/floppy

        cd /tmp/vmware-tools-distrib

        # Patch vmhgfs so it will compile using the 3.8 header files
        pushd lib/modules/source
        if [ ! -f vmhgfs.tar.orig ]
        then
            cp vmhgfs.tar vmhgfs.tar.orig
        fi
        rm -rf vmhgfs-only
        tar xf vmhgfs.tar
        pushd vmhgfs-only/shared
        patch -p1 < /mnt/floppy/vmware9.compat_mm.patch
        popd
        tar cf vmhgfs.tar vmhgfs-only
        rm -rf vmhgfs-only
        popd

        # Patch vmci so it will compile using the 3.8 header files
        pushd lib/modules/source
        if [ ! -f vmci.tar.orig ]
        then
            cp vmci.tar vmci.tar.orig
        fi
        rm -rf vmci-only
        tar xf vmci.tar
        pushd vmci-only
        patch -p1 < /mnt/floppy/vmware9.k3.8rc4.patch
        popd
        tar cf vmci.tar vmci-only
        rm -rf vmci-only
        popd
    elif [[ -f /mnt/cdrom/VMwareTools-9.2.3-1031360.tar.gz ]]
    then
        mkdir -p /mnt/floppy
        modprobe floppy
        mount -t vfat /dev/fd0 /mnt/floppy

        cd /tmp/vmware-tools-distrib

        # Patch vmhgfs so it will compile using the 3.8 header files
        pushd lib/modules/source
        if [ ! -f vmhgfs.tar.orig ]
        then
            cp vmhgfs.tar vmhgfs.tar.orig
        fi
        rm -rf vmhgfs-only
        tar xf vmhgfs.tar
        pushd vmhgfs-only
        patch -p1 < /mnt/floppy/vmtools.inode.c.patch
        popd
        tar cf vmhgfs.tar vmhgfs-only
        rm -rf vmhgfs-only
        popd
    fi

    /tmp/vmware-tools-distrib/vmware-install.pl -d
}

function install_vmware_tools_ubuntu1304 {
    # VMwareTools 9.2.2-893683 doesn't work with the 3.8 kernel
    if [ -f /mnt/cdrom/VMwareTools-9.2.2-893683.tar.gz ]
    then
        # Add some links so the vmware-install.pl can find header files
        cd /lib/modules/$(uname -r)/build/include/linux
        ln -s ../generated/utsrelease.h
        ln -s ../generated/autoconf.h
        ln -s ../generated/uapi/linux/version.h

        mkdir -p /mnt/floppy
        modprobe floppy
        mount -t vfat /dev/fd0 /mnt/floppy
        cd /tmp/vmware-tools-distrib

        # Patch so vmci successfully compiles
        pushd lib/modules/source
        if [ ! -f vmci.tar.orig ]
        then
            cp vmci.tar vmci.tar.orig
        fi
        rm -rf vmci-only
        tar xf vmci.tar
        pushd vmci-only
        patch -p1 < /mnt/floppy/vmware9.k3.8rc4.patch
        popd
        tar cf vmci.tar vmci-only
        rm -rf vmci-only
        popd

        # patch so vmhgfs successfully compiles
        pushd lib/modules/source
        if [ ! -f vmhgfs.tar.orig ]
        then
            cp vmhgfs.tar vmhgfs.tar.orig
        fi
        rm -rf vmhgfs-only
        tar xf vmhgfs.tar
        pushd vmhgfs-only/shared
        patch -p1 < /mnt/floppy/vmware9.compat_mm.patch
        popd
        tar cf vmhgfs.tar vmhgfs-only
        rm -rf vmhgfs-only
        popd

        umount /mnt/floppy
        rmdir /mnt/floppy
    fi

    /tmp/vmware-tools-distrib/vmware-install.pl -d
}

function install_vmware_tools_ubuntu1310 {
    # VMwareTools 9.2.2-893683 doesn't work with the 3.8 kernel
    if [ -f /mnt/cdrom/VMwareTools-9.2.2-893683.tar.gz ]
    then
        # Add some links so the vmware-install.pl can find header files
        cd /lib/modules/$(uname -r)/build/include/linux
        ln -s ../generated/utsrelease.h
        ln -s ../generated/autoconf.h
        ln -s ../generated/uapi/linux/version.h

        mkdir -p /mnt/floppy
        modprobe floppy
        mount -t vfat /dev/fd0 /mnt/floppy
        cd /tmp/vmware-tools-distrib

        # Patch so vmci successfully compiles
        pushd lib/modules/source
        if [ ! -f vmci.tar.orig ]
        then
            cp vmci.tar vmci.tar.orig
        fi
        rm -rf vmci-only
        tar xf vmci.tar
        pushd vmci-only
        patch -p1 < /mnt/floppy/vmware9.k3.8rc4.patch
        popd
        tar cf vmci.tar vmci-only
        rm -rf vmci-only
        popd

        # patch so vmhgfs successfully compiles
        pushd lib/modules/source
        if [ ! -f vmhgfs.tar.orig ]
        then
            cp vmhgfs.tar vmhgfs.tar.orig
        fi
        rm -rf vmhgfs-only
        tar xf vmhgfs.tar
        pushd vmhgfs-only/shared
        patch -p1 < /mnt/floppy/vmware9.compat_mm.patch
        popd
        tar cf vmhgfs.tar vmhgfs-only
        rm -rf vmhgfs-only
        popd

        umount /mnt/floppy
        rmdir /mnt/floppy
    elif [ -f /mnt/cdrom/VMwareTools-9.6.0-1294478.tar.gz ]
    then
        mkdir -p /mnt/floppy
        modprobe floppy
        mount -t vfat /dev/fd0 /mnt/floppy
        cd /tmp/vmware-tools-distrib

        # patch so vmhgfs successfully compiles
        pushd lib/modules/source
        if [ ! -f vmhgfs.tar.orig ]
        then
            cp vmhgfs.tar vmhgfs.tar.orig
        fi
        rm -rf vmhgfs-only
        tar xf vmhgfs.tar
        pushd vmhgfs-only
        patch -p1 < /mnt/floppy/vmhgfs-d_count-kernel-3.11-tools-9.6.0.patch
        popd
        tar cf vmhgfs.tar vmhgfs-only
        rm -rf vmhgfs-only
        popd

        umount /mnt/floppy
        rmdir /mnt/floppy
    fi

    /tmp/vmware-tools-distrib/vmware-install.pl -d
}

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
    echo "Installing VMware Tools"
    apt-get install -y linux-headers-$(uname -r) build-essential perl

    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop /home/vagrant/linux.iso /mnt/cdrom
    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/

    ubuntu_release=$(lsb_release -rs)
    if [[ "${ubuntu_release}" == "10.04" ]]
    then
        /tmp/vmware-tools-distrib/vmware-install.pl -d
    elif [[ "${ubuntu_release}" == "12.04" ]]
    then
        install_vmware_tools_ubuntu1204
    elif [[ "${ubuntu_release}" == "13.04" ]]
    then
        install_vmware_tools_ubuntu1304
    elif [[ "${ubuntu_release}" == "13.10" ]]
    then
        install_vmware_tools_ubuntu1310
    else
        /tmp/vmware-tools-distrib/vmware-install.pl -d
    fi

    rm /home/vagrant/linux.iso
    umount /mnt/cdrom
    rmdir /mnt/cdrom

    #apt-get -y remove linux-headers-$(uname -r) build-essential perl
    #apt-get -y autoremove
fi

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
    echo "Installing VirtualBox guest additions"

    apt-get install -y linux-headers-$(uname -r) build-essential perl
    apt-get install -y dkms

    VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
    mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt
    rm /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso

    if [[ $VBOX_VERSION = "4.3.10" ]]; then
        ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
    fi
fi

#!/bin/bash -eux

SSH_USERNAME=${SSH_USERNAME:-vagrant}

function install_open_vm_tools {
    echo "==> Installing Open VM Tools"
    # Install open-vm-tools so we can mount shared folders
    apt-get install -y open-vm-tools
    # Install open-vm-tools-desktop so we can copy/paste, resize, etc.
    if [[ "$DESKTOP" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
        apt-get install -y open-vm-tools-desktop
    fi
    # Add /mnt/hgfs so the mount works automatically with Vagrant
    mkdir /mnt/hgfs
}

function install_vmware_tools {
    echo "==> Installing VMware Tools"
    # Assuming the following packages are installed
    # apt-get install -y linux-headers-$(uname -r) build-essential perl

    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop /home/${SSH_USERNAME}/linux.iso /mnt/cdrom

    VMWARE_TOOLS_PATH=$(ls /mnt/cdrom/VMwareTools-*.tar.gz)
    VMWARE_TOOLS_VERSION=$(echo "${VMWARE_TOOLS_PATH}" | cut -f2 -d'-')
    VMWARE_TOOLS_BUILD=$(echo "${VMWARE_TOOLS_PATH}" | cut -f3 -d'-')
    VMWARE_TOOLS_BUILD=$(basename ${VMWARE_TOOLS_BUILD} .tar.gz)
    echo "==> VMware Tools Path: ${VMWARE_TOOLS_PATH}"
    echo "==> VMWare Tools Version: ${VMWARE_TOOLS_VERSION}"
    echo "==> VMware Tools Build: ${VMWARE_TOOLS_BUILD}"

    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/
    VMWARE_TOOLS_MAJOR_VERSION=$(echo ${VMWARE_TOOLS_VERSION} | cut -d '.' -f 1)
    if [ "${VMWARE_TOOLS_MAJOR_VERSION}" -lt "10" ]; then
        /tmp/vmware-tools-distrib/vmware-install.pl -d
    else
        /tmp/vmware-tools-distrib/vmware-install.pl -f
    fi

    rm /home/${SSH_USERNAME}/linux.iso
    umount /mnt/cdrom
    rmdir /mnt/cdrom
    rm -rf /tmp/VMwareTools-*

    VMWARE_TOOLBOX_CMD_VERSION=$(vmware-toolbox-cmd -v)
    echo "==> Installed VMware Tools ${VMWARE_TOOLBOX_CMD_VERSION}"
}

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
    KERNEL_VERSION=$(uname -r | cut -d. -f1-2)
    echo "==> Kernel version ${KERNEL_VERSION}"
    MAJOR_VERSION=$(echo ${KERNEL_VERSION} | cut -d '.' -f1)
    MINOR_VERSION=$(echo ${KERNEL_VERSION} | cut -d '.' -f2)
    if [ "${MAJOR_VERSION}" -ge "4" ] && [ "${MINOR_VERSION}" -ge "1" ]; then
      # open-vm-tools supports shared folders on kernel 4.1 or greater
      . /etc/lsb-release
      if [[ $DISTRIB_RELEASE == 14.04 ]]; then
        install_vmware_tools
        # Ensure that VMWare Tools recompiles kernel modules
        echo "answer AUTO_KMODS_ENABLED yes" >> /etc/vmware-tools/locations
      else 
        install_open_vm_tools
      fi
    else
      install_vmware_tools
    fi 
fi

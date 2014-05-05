#!/bin/bash

UBUNTU_MAJOR_VERSION=$(lsb_release -rs | cut -f1 -d .)

function legacy_docker_install {
    # Add the Docker repository to your apt sources list.
    echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list

    # Update your sources
    apt-get update

    # Install, you will see another warning that the package cannot be authenticated. Confirm install.
    apt-get install -y --force-yes lxc-docker

    # Enable memory and swap accounting
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
    update-grub

    # reboot
    echo "Rebooting the machine..."
    reboot
    sleep 60
}

function docker_install {
    # Update sources
    apt-get update

    apt-get install -y docker.io

    # Enable memory and swap accounting
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
    update-grub
}

if [[ $UBUNTU_MAJOR_VERSION == "12" || $UBUNTU_MAJOR_VERSION == "13" ]]
then
    legacy_docker_install 
elif [[ $UBUNTU_MAJOR_VERSION == "14" ]]
then
    docker_install
fi

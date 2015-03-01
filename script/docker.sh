#!/bin/bash

UBUNTU_MAJOR_VERSION=$(lsb_release -rs | cut -f1 -d .)
SSH_USER=${SSH_USERNAME:-vagrant}

docker_package_install() {
    # Add the Docker repository to your apt sources list.
    echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
    # Add the Docker repository GPG key
    curl -s https://get.docker.io/gpg | apt-key add -

    # Update your sources
    apt-get update

    # Install Docker
    apt-get install -y lxc-docker

    # Enable memory and swap accounting
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
    update-grub

    # reboot
    echo "Rebooting the machine..."
    reboot
    sleep 60
}

docker_io_install() {
    echo "==> Installing Docker"
    
    # Update sources
    apt-get update
    apt-get install -y docker.io

    # Create /usr/bin/docker the Debian/Ubuntu way
    # (avoid conflicting with docker – System tray)
    update-alternatives --install /usr/bin/docker docker /usr/bin/docker.io 50

    # Allow bash completion for docker
    cp -a /etc/bash_completion.d/docker{.io,}
    sed -i 's/\(docker\)\.io/\1/g' /etc/bash_completion.d/docker

    # Allow zsh completion for docker
    cp -a /usr/share/zsh/vendor-completions/_docker{.io,}
    sed -i 's/\(docker\)\.io/\1/g' /usr/share/zsh/vendor-completions/_docker

    # the man page for docker
    ln -s /usr/share/man/man1/docker{.io,}.1.gz

    # not really needed because docker.io is still there
    sed -i 's/\(docker\)\.io/\1/g' /usr/share/docker.io/contrib/*.sh
    
    # Enable memory and swap accounting
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
    update-grub
}

docker_install() {
    echo "==> Installing Docker from the Docker repository"

    curl -s https://get.docker.io/ubuntu/ | sudo sh

    # Enable memory and swap accounting
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
    update-grub
}

give_docker_non_root_access() {
    # Add the docker group if it doesn't already exist
    groupadd docker

    # Add the connected "${USER}" to the docker group.
    gpasswd -a ${USER} docker
    gpasswd -a ${SSH_USER} docker

    # Restart the Docker daemon
    #service docker restart
}

give_docker_non_root_access
docker_package_install 

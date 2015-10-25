#!/bin/bash

if [[ ! "$DOCKER" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
  exit
fi

SSH_USERNAME=${SSH_USERNAME:-vagrant}

UBUNTU_MAJOR_VERSION=$(lsb_release -rs | cut -f1 -d .)

docker_package_install() {
    # Update your sources
    apt-get update

    # Get the latest docker package
    curl -sSL https://get.docker.com/gpg | sudo apt-key add -

    # Install Docker
    curl -sSL https://get.docker.com/ | sh

    # Enable memory and swap accounting
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
    update-grub

    # Docker package does not current configure daemon to start on boot
    # for Ubuntu 15.04 and up
    if [[ "${UBUNTU_MAJOR_VERSION}" -gt "14" ]]; then
      sudo systemctl enable docker
    fi

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
    gpasswd -a ${SSH_USERNAME} docker
}

give_docker_non_root_access
docker_package_install 

#!/bin/bash -eux

echo "==> Updating list of repositories"
apt-get -y update

if [[ ${AUTO_UPGRADE:-} == 'true' ]]; then
    echo "==> Performing dist-upgrade (all packages and kernel)"
    apt-get -y dist-upgrade --force-yes
    reboot
    sleep 60
fi

#!/bin/bash -eux

echo "==> Updating list of repositories"
apt-get -y update

if [[ ${AUTO_UPGRADE:-} == 'true' ]]; then
    echo "==> Performing upgrades"
    apt-get -y upgrade
    echo "==> Performing dist-upgrade"
    apt-get -y dist-upgrade --force-yes
    reboot
    sleep 60
fi

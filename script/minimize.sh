#!/bin/bash -eux

if [[ "$DESKTOP" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
  exit
fi

echo "==> Disk usage before minimization"
df -h

echo "==> Installed packages before cleanup"
dpkg --get-selections | grep -v deinstall > /dev/null

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg --list | awk '{ print $2 }' | grep -e 'linux-\(headers\|image\)-.*[0-9]\($\|-generic\)' | grep -v "$(uname -r | sed 's/-generic//')" | xargs apt-get -y purge > /dev/null
echo "==> Removing linux source"
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge > /dev/null
echo "==> Removing development packages"
dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge > /dev/null
echo "==> Removing documentation"
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y purge > /dev/null
echo "==> Removing development tools"
#dpkg --list | grep -i compiler | awk '{ print $2 }' | xargs apt-get -y purge
#apt-get -y purge cpp gcc g++ 
apt-get -y purge build-essential git > /dev/null
echo "==> Removing default system Ruby"
apt-get -y purge ruby ri > /dev/null
echo "==> Removing default system Python"
apt-get -y purge python-dbus libiw30 libdbus-glib-1-2 python-pexpect python-pycurl python-gobject python-pam python-openssl > /dev/null
echo "==> Removing X11 libraries"
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6 > /dev/null
echo "==> Removing obsolete networking components"
apt-get -y purge ppp pppconfig pppoeconf > /dev/null
echo "==> Removing other oddities"
apt-get -y purge popularity-contest installation-report landscape-common wireless-tools wpasupplicant > /dev/null

# Need bc to make the code snippets below work
apt-get -y install bc > /dev/null 

if [ `echo "$DISTRIB_RELEASE < 20.04" | bc` ]; then
  apt-get -y purge python-smartpm python-twisted-core python-twisted-bin python-serial > /dev/null
fi

# ubuntu-serverguide is not in 18.04
# doc, from default system Ruby not in 18.04
# libnl1, from default system Python not in 18.04
#
if [ `echo "$DISTRIB_RELEASE < 18.04" | bc` ]; then
  apt-get -y purge ubuntu-serverguide doc libnl1 libffi5 > /dev/null
fi

apt-get -y purge bc > /dev/null
echo "==> Removing bc"

# Clean up the apt cache
{
  apt-get -y autoremove --purge
  apt-get -y autoclean
  apt-get -y clean
} > /dev/null

# Clean up orphaned packages with deborphan
apt-get -y install deborphan > /dev/null
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
    deborphan --guess-all --libdevel | xargs apt-get -y purge > /dev/null
done
apt-get -y purge deborphan dialog > /dev/null

echo "==> Removing man pages"
rm -rf /usr/share/man/*
echo "==> Removing APT files"
find /var/lib/apt -type f | xargs rm -f
echo "==> Removing any docs"
rm -rf /usr/share/doc/*
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;
# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

echo "==> Disk usage after cleanup"
df -h

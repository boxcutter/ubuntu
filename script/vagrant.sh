date > /etc/vagrant_box_build_time

VAGRANT_USER=vagrant
VAGRANT_HOME=/home/$VAGRANT_USER
VAGRANT_KEY_URL=https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub

# Create Vagrant user (if not already present)
if ! id -u $VAGRANT_USER >/dev/null 2>&1; then
    /usr/sbin/groupadd $VAGRANT_USER
    /usr/sbin/useradd $VAGRANT_USER -g $VAGRANT_USER -G sudo -d $VAGRANT_HOME --create-home
    echo "${VAGRANT_USER}:${VAGRANT_USER}" | chpasswd
fi

# Set up sudo
echo "${VAGRANT_USER}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# Install vagrant keys
mkdir $VAGRANT_HOME/.ssh
chmod 700 $VAGRANT_HOME/.ssh
cd $VAGRANT_HOME/.ssh
wget --no-check-certificate "${VAGRANT_KEY_URL}" -O authorized_keys
chmod 600 $VAGRANT_HOME/.ssh/authorized_keys
chown -R $VAGRANT_USER:$VAGRANT_USER $VAGRANT_HOME/.ssh

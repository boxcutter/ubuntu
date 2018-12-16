#!/bin/bash

if [[ ! "$DESKTOP" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
  exit
fi

SSH_USER=${SSH_USERNAME:-vagrant}

echo "==> Checking version of Ubuntu"
. /etc/lsb-release

echo "==> Installing ubuntu-desktop"
apt-get install -y ubuntu-desktop

USERNAME=${SSH_USER}
LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
GDM_CUSTOM_CONFIG=/etc/gdm3/custom.conf

if [ -f $GDM_CUSTOM_CONFIG ]; then
    mkdir -p $(dirname ${GDM_CUSTOM_CONFIG})
    > $GDM_CUSTOM_CONFIG
    echo "[daemon]" >> $GDM_CUSTOM_CONFIG
    echo "# Enabling automatic login" >> $GDM_CUSTOM_CONFIG
    echo "AutomaticLoginEnable = true" >> $GDM_CUSTOM_CONFIG
    echo "AutomaticLogin = ${USERNAME}" >> $GDM_CUSTOM_CONFIG
fi

if [ -f $LIGHTDM_CONFIG ]; then
    echo "==> Configuring lightdm autologin"
    echo "[SeatDefaults]" >> $LIGHTDM_CONFIG
    echo "autologin-user=${USERNAME}" >> $LIGHTDM_CONFIG
    echo "autologin-user-timeout=0" >> $LIGHTDM_CONFIG
fi

if [ -d /etc/xdg/autostart/ ]; then
    echo "==> Disabling screen blanking"
    NODPMS_CONFIG=/etc/xdg/autostart/nodpms.desktop
    echo "[Desktop Entry]" >> $NODPMS_CONFIG
    echo "Type=Application" >> $NODPMS_CONFIG
    echo "Exec=xset -dpms s off s noblank s 0 0 s noexpose" >> $NODPMS_CONFIG
    echo "Hidden=false" >> $NODPMS_CONFIG
    echo "NoDisplay=false" >> $NODPMS_CONFIG
    echo "X-GNOME-Autostart-enabled=true" >> $NODPMS_CONFIG
    echo "Name[en_US]=nodpms" >> $NODPMS_CONFIG
    echo "Name=nodpms" >> $NODPMS_CONFIG
    echo "Comment[en_US]=" >> $NODPMS_CONFIG
    echo "Comment=" >> $NODPMS_CONFIG
fi

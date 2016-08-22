#!/bin/bash

if [[ ! "$DESKTOP" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
  exit
fi

SSH_USER=${SSH_USERNAME:-vagrant}

configure_ubuntu1204_autologin()
{
    USERNAME=${SSH_USER}
    LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf

    echo "==> Configuring lightdm autologin"
    if [ -f $LIGHTDM_CONFIG ]; then
        echo "" >> $LIGHTDM_CONFIG
        echo "autologin-user=${USERNAME}" >> $LIGHTDM_CONFIG
        echo "autologin-user-timeout=0" >> $LIGHTDM_CONFIG
    fi
}

echo "==> Checking version of Ubuntu"
. /etc/lsb-release

if [[ $DISTRIB_RELEASE == 12.04 ]]; then

    configure_ubuntu1204_autologin

elif [[ $DISTRIB_RELEASE == 14.04 || $DISTRIB_RELEASE == 15.04 || $DISTRIB_RELEASE == 16.04 ]]; then
    echo "==> Installing ubunutu-desktop"
    apt-get install -y ubuntu-desktop

    USERNAME=${SSH_USER}
    LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
    GDM_CUSTOM_CONFIG=/etc/gdm/custom.conf

    mkdir -p $(dirname ${GDM_CUSTOM_CONFIG})
    echo "[daemon]" >> $GDM_CUSTOM_CONFIG
    echo "# Enabling automatic login" >> $GDM_CUSTOM_CONFIG
    echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG
    echo "AutomaticLoginEnable=${USERNAME}" >> $GDM_CUSTOM_CONFIG

    echo "==> Configuring lightdm autologin"
    echo "[SeatDefaults]" >> $LIGHTDM_CONFIG
    echo "autologin-user=${USERNAME}" >> $LIGHTDM_CONFIG
fi

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

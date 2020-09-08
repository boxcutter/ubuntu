#!/usr/bin/env bash
echo "Provisioning Docker verification tooling..."
echo "Installing Vino"
sudo apt-get install -y vino gconf2

gsettings set org.gnome.Vino prompt-enabled false
gsettings set org.gnome.Vino authentication-methods "['vnc']"
gsettings set org.gnome.Vino require-encryption false
gsettings set org.gnome.Vino vnc-password $(echo -n 'welcome_to_the_show'|base64)
gsettings set org.gnome.settings-daemon.plugins.sharing active true
eths=$(nmcli -t -f uuid,type c s --active | grep 802 | awk -F  ":" '{ print "'\''" $1 "'\''" }' | paste -s -d, -)
gsettings set org.gnome.settings-daemon.plugins.sharing.service:/org/gnome/settings-daemon/plugins/sharing/vino-server/ enabled-connections "[ $eths ]"
/usr/lib/vino/vino-server &
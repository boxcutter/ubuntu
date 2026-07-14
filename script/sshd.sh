#!/bin/bash -eux

echo "UseDNS no" >> /etc/ssh/sshd_config
if [[ $SSH_DISABLE_PASSWORD_AUTH  =~ true || $SSH_DISABLE_PASSWORD_AUTH =~ 1 || $SSH_DISABLE_PASSWORD_AUTH =~ yes ]]; then
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
fi

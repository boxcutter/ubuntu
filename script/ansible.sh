#!/bin/bash

export PS1="packer> "
VIRTUAL=/Users/tanner/projects/py3-ansible
PLAYBOOKS=$VIRTUAL/src/playbooks.git

source $VIRTUAL/bin/activate > /dev/null 2>&1
source $VIRTUAL/src/ansible/hacking/env-setup > /dev/null 2>&1

export ANSIBLE_CONFIG=$PLAYBOOKS/comap.com/ansible.cfg

cd $VIRTUAL/src/playbooks.git/comap.com

echo "==> Ansible version"
ansible --version

echo "==> ssh version"
ssh -V

echo "==> Run ansible: `pwd`"
ansible-playbook "$@"

exit 0

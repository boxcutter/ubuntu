# Packer templates for Ubuntu (trainerbox)

## Overview

This repository contains [Packer](https://packer.io/) templates for creating Ubuntu Vagrant boxes, currently the focus is on ubuntu Desktop 16.04. With the box you get:
- Docker & docker images of Webgoat 7, Webgoat 8 and a few others
- Zap (2.7.0)
- nmap
- Burproxy

This is a fork of [boxcutter](https://github.com/boxcutter/ubuntu).

## Project status

This project is a prototype and is currently no longer actively being maintained, until the next workshop/training that has to be given on ZAP/Burp websecurity. Nevertheless: feel free to make use of it.

## How to use the vagrant box

Requires: Virtualbox 5, Vagrant.

Go to https://app.vagrantup.com/commjoen/boxes/trainingbox and follow instructions.

## How to create your own box
Requires: Virtualbox 5, Vagrant, Packer.

- prepare a release at https://app.vagrantup.com
- update `box_tag` in ubuntu.json
- run `packer build -only=virtualbox-iso -var-file=ubuntu1604-desktop.json -var 'vagrant_cloud_token=<YOURVAGRANTCLODUTOKENHERE>' -var 'version=<VERSIONHERE>' ubuntu.json` & in the vm:
  - Complete the setup wizard
  - reboot
  - run sshd from terminal (e.g. type sshd and follow instructions). After this, packer will take over.
- Finalize your release at https://app.vagrantup.com or use the locally created virtualbox and export it for your own usage/training.

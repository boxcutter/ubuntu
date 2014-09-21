# Packer templates for Ubuntu
[![Build Status](https://box-cutter.ci.cloudbees.com/buildStatus/icon?job=ubuntu-vm)](https://box-cutter.ci.cloudbees.com/job/ubuntu-vm/)

### Overview

This repository contains templates for Ubuntu that can create Vagrant boxes
using Packer.

## Current Boxes

64-bit boxes:

* [box-cutter/ubuntu1404](https://vagrantcloud.com/box-cutter/ubuntu1404) - Ubuntu Server 14.04.1 (64-bit), VMware 329MB/VirtualBox 290MB
* [box-cutter/ubuntu1404-desktop](https://vagrantcloud.com/box-cutter/ubuntu1404-desktop) - Ubuntu Desktop 14.04.1 (64-bit), VMware 1.1GB/VirtualBox 1GB
* [box-cutter/ubuntu1404-docker](https://vagrantcloud.com/box-cutter/ubuntu1404-docker) - Ubuntu Server 14.04.1 (64-bit) with Docker preinstalled, VMware 446MB/VirtualBox 410MB
* [box-cutter/ubuntu1204](https://vagrantcloud.com/box-cutter/ubuntu1204) - Ubuntu Server 12.04.5 (64-bit), VMware 284MB, VirtualBox 240MB
* [box-cutter/ubuntu1204-desktop](https://vagrantcloud.com/box-cutter/ubuntu1204-desktop) - Ubuntu Desktop 12.04.4 (64-bit), VMware 918MB/VirtualBox 823MB
* [box-cutter/ubuntu1204-docker](https://vagrantcloud.com/box-cutter/ubuntu1204-docker) - Ubuntu Server 12.04.5 (64-bit) with Docker preinstalled, VMware 393MB/VirtualBox 349MB
* [box-cutter/ubuntu1004](https://vagrantcloud.com/box-cutter/ubuntu1004)  - Ubuntu Server 10.04.4 (64-bit), VMware 223MB/VirtualBox 182MB

32-bit boxes:

* [box-cutter/ubuntu1404-i386](https://vagrantcloud.com/box-cutter/ubuntu1404-i386) - Ubuntu Server 14.04.1 (32-bit), VMware 323MB/VirtualBox 282MB
* [box-cutter/ubuntu1204-i386](https://vagrantcloud.com/box-cutter/ubuntu1204-i386) - Ubuntu Server 12.04.5 (32-bit), VMware 278MB/VirtualBox 237MB
* [box-cutter/ubuntu1004-i386](https://vagrantcloud.com/box-cutter/ubuntu1004-i386) - Ubuntu Server 10.04.4 (32-bit), VMware 227MB/VirtualBox 186MB

## Building the Vagrant boxes

To build all the boxes, you will need Packer ([Website](packer.io)) 
and both VirtualBox and VMware Fusion installed.

A GNU Make `Makefile` drives the process via the following targets:

    make        # Build all the box types (VirtualBox & VMware)
    make test   # Run tests against all the boxes
    make list   # Print out individual targets
    make clean  # Clean up build detritus

### Proxy Settings

The templates respect the following network proxy environment variables
and forward them on to the virtual machine environment during the box creation
process, should you be using a proxy:

* http_proxy
* https_proxy
* ftp_proxy
* rsync_proxy
* no_proxy

### Tests

The tests are written in [Serverspec](http://serverspec.org) and require the
`vagrant-serverspec` plugin to be installed with:

    vagrant plugin install vagrant-serverspec
    
The `Makefile` has individual targets for each box type with the prefix
`test-*` should you wish to run tests individually for each box.  For example:

    make test-box/virtualbox/ubuntu1404-nocm.box

Similarly there are targets with the prefix `ssh-*` for registering a
newly-built box with vagrant and for logging in using just one command to
do exploratory testing.  For example, to do exploratory testing
on the VirtualBox training environmnet, run the following command:

    make ssh-box/virtualbox/ubuntu1404-nocm.box
    
Upon logout `make ssh-*` will automatically de-register the box as well.

### Makefile.local override

You can create a `Makefile.local` file alongside the `Makefile` to override
some of the default settings.  The variables can that can be currently
used are:

* CM
* CM_VERSION
* \<iso_path\>
* UPDATE

`Makefile.local` is most commonly used to override the default configuration
management tool, for example with Chef:

    # Makefile.local
    CM := chef

Changing the value of the `CM` variable changes the target suffixes for
the output of `make list` accordingly.

Possible values for the CM variable are:

* `nocm` - No configuration management tool
* `chef` - Install Chef
* `chefdk` - Install Chef Development Kit
* `puppet` - Install Puppet
* `salt`  - Install Salt

You can also specify a variable `CM_VERSION`, if supported by the
configuration management tool, to override the default of `latest`.
The value of `CM_VERSION` should have the form `x.y` or `x.y.z`,
such as `CM_VERSION := 11.12.4`

The variable `UPDATE` can be used to perform OS patch management.  The
default is to not apply OS updates by default.  When `UPDATE := true`,
the latest OS updates will be applied.

Another use for `Makefile.local` is to override the default locations
for the Ubuntu install ISO files.

For Ubuntu, the ISO path variables are:

* UBUNTU1004_SERVER_AMD64
* UBUNTU1004_SERVER_I386
* UBUNTU1204_SERVER_AMD64
* UBUNTU1204_SERVER_I386
* UBUNTU1204_ALTERNATE_AMD64
* UBUNTU1304_SERVER_AMD64
* UBUNTU1304_SERVER_I386
* UBUNTU1310_SERVER_AMD64
* UBUNTU1310_SERVER_I386
* UBUNTU1404_SERVER_AMD64
* UBUNTU1404_SERVER_I386

This override is commonly used to speed up Packer builds by
pointing at pre-downloaded ISOs instead of using the default
download Internet URLs:
`UBUNTU1404_SERVER_AMD64 := file:///Volumes/Ubuntu/ubuntu-14.04.1-server-amd64.iso`

### Acknowledgments

[CloudBees](http://www.cloudbees.com) is providing a hosted [Jenkins master](http://box-cutter.ci.cloudbees.com/) through their CloudBees FOSS program. Their [On-Premise Executor](https://developer.cloudbees.com/bin/view/DEV/On-Premise+Executors) feature is used to connect physical machines as build slaves running VirtualBox, VMware Fusion, VMware Workstation, VMware ESXi/vSphere and Hyper-V.

![Powered By CloudBees](http://www.cloudbees.com/sites/default/files/Button-Powered-by-CB.png "Powered By CloudBees")![Built On DEV@Cloud](http://www.cloudbees.com/sites/default/files/Button-Built-on-CB-1.png "Built On DEV@Cloud")

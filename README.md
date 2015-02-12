# Packer templates for Ubuntu

### Overview

This repository contains templates for Ubuntu that can create Vagrant boxes
using Packer.

## Current Boxes

64-bit boxes:

* [Ubuntu Server 14.10 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1410), VMware 360MB/VirtualBox 326MB/Parallels 3337MB
* [Ubuntu Server 14.10 (64-bit) with Docker preinstalled](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1410-docker), VMware 502MB/VirtualBox 474MB/Parallels 480MB
* [Ubuntu Server 14.04.1 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404), VMware 342MB/VirtualBox 296MB/Parallels 319MB
* [Ubuntu Desktop 14.04.1 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404-desktop), VMware 1.19GB/VirtualBox 1.15GB/Parallels 1.17GB
* [Ubuntu Server 14.04.1 (64-bit) with Docker preinstalled](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404-docker), VMware 472MB/VirtualBox 429MB/Parallels 452MB
* [Ubuntu Server 12.04.5 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204), VMware 306MB, VirtualBox 251MB/Parallels 276MB
* [Ubuntu Desktop 12.04.4 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204-desktop), VMware 968MB/VirtualBox 855MB/Parallels 997MB
* [Ubuntu Server 12.04.5 (64-bit) with Docker preinstalled](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204-docker), VMware 417MB/VirtualBox 365MB/Parallels 393MB
* [Ubuntu Server 10.04.4 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1004), VMware 236MB/VirtualBox 177MB/Parallels 228MB

32-bit boxes:

* [Ubuntu Server 14.10 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1410-i386), VMware 354MB/VirtualBox 327MB/Parallels 344MB
* [Ubuntu Server 14.04.1 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404-i386), VMware 339MB/VirtualBox 299MB/Parallels 313MB
* [Ubuntu Server 12.04.5 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204-i386), VMware 300MB/VirtualBox 260MB/Parallels 268MB
* [Ubuntu Server 10.04.4 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1004-i386), VMware 231MB/VirtualBox 156MB/Parallels 215MB

## Building the Vagrant boxes

To build all the boxes, you will need VirtualBox, VMware Fusion, and Parallels Desktop for Mac installed.

Parallels requires that the
[Parallels Virtualization SDK for Mac](http://ww.parallels.com/downloads/desktop)
be installed as an additional preqrequisite.

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
* UBUNTU1404_SERVER_AMD64
* UBUNTU1404_SERVER_I386
* UBUNTU1410_SERVER_AMD64
* UBUNTU1410_SERVER_I386

This override is commonly used to speed up Packer builds by
pointing at pre-downloaded ISOs instead of using the default
download Internet URLs:
`UBUNTU1404_SERVER_AMD64 := file:///Volumes/Ubuntu/ubuntu-14.04.1-server-amd64.iso`

### Acknowledgments

[SmartyStreets](http://www.smartystreets.com) is providing basebox hosting for the box-cutter project.

![Powered By SmartyStreets](https://smartystreets.com/resources/images/smartystreets-flat.png)

# Packer templates for Ubuntu

### Overview

This repository contains [Packer](https://packer.io/) templates for creating Ubuntu Vagrant boxes.

## Current Boxes

64-bit boxes:

* [Ubuntu Server 16.04 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1604)
* [Ubuntu Server 15.10 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1510)
* [Ubuntu Server 14.04.4 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404)
* [Ubuntu Desktop 14.04.4 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404-desktop)
* [Ubuntu Server 14.04.4 (64-bit) with Docker preinstalled](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404-docker)
* [Ubuntu Server 12.04.5 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204)
* [Ubuntu Desktop 12.04.5 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204-desktop)
* [Ubuntu Server 12.04.5 (64-bit) with Docker preinstalled](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204-docker)

32-bit boxes:

* [Ubuntu Server 14.04.4 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404-i386)
* [Ubuntu Server 12.04.5 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204-i386)

## Building the Vagrant boxes with Packer

To build all the boxes, you will need [VirtualBox](https://www.virtualbox.org/wiki/Downloads), 
[VMware Fusion](https://www.vmware.com/products/fusion)/[VMware Workstation](https://www.vmware.com/products/workstation) and
[Parallels](http://www.parallels.com/products/desktop/whats-new/) installed.

Parallels requires that the
[Parallels Virtualization SDK for Mac](http://www.parallels.com/downloads/desktop)
be installed as an additional preqrequisite.

VMware Fusion boxes require this patch when running version 8.1.0 to enable port forwarding:
https://blogs.vmware.com/teamfusion/2016/01/workaround-of-nat-port-forwarding-issue-in-fusion-8-1.html

We make use of JSON files containing user variables to build specific versions of Ubuntu.
You tell `packer` to use a specific user variable file via the `-var-file=` command line
option.  This will override the default options on the core `ubuntu.json` packer template,
which builds Ubuntu 16.04 by default.

For example, to build Ubuntu 16.04, use the following:

    $ packer build -var-file=ubuntu1604.json ubuntu.json
    
If you want to make boxes for a specific desktop virtualization platform, use the `-only`
parameter.  For example, to build Ubuntu 16.04 for VirtualBox:

    $ packer build -only=virtualbox-iso -var-file=ubuntu1604.json ubuntu.json

The boxcutter templates currently support the following desktop virtualization strings:

* `parallels-iso` - [Parallels](http://www.parallels.com/products/desktop/whats-new/) desktop virtualization (Requires the Pro Edition - Desktop edition won't work)
* `virtualbox-iso` - [VirtualBox](https://www.virtualbox.org/wiki/Downloads) desktop virtualization
* `vmware-iso` - [VMware Fusion](https://www.vmware.com/products/fusion) or [VMware Workstation](https://www.vmware.com/products/workstation) desktop virtualization

## Building the Vagrant boxes with the box script

We've also provided a wrapper script `bin/box` for ease of use, so alternatively, you can use
the following to build Ubuntu 16.04 for all providers:

    $ bin/box build ubuntu1604

Or if you just want to build Ubuntu 16.04 for VirtualBox:

    $ bin/box build ubuntu1604 virtualbox

## Building the Vagrant boxes with the Makefile

A GNU Make `Makefile` drives a complete basebox creation pipeline with the following stages:

* `build` - Create basebox `*.box` files
* `assure` - Verify that the basebox `*.box` files produced function correctly
* `deliver` - Upload `*.box` files to [Artifactory](https://www.jfrog.com/confluence/display/RTF/Vagrant+Repositories), [Atlas](https://atlas.hashicorp.com/) or an [S3 bucket](https://aws.amazon.com/s3/)

The pipeline is driven via the following targets, making it easy for you to include them
in your favourite CI tool:

    make build   # Build all available box types
    make assure  # Run tests against all the boxes
    make deliver # Upload box artifacts to a repository
    make clean   # Clean up build detritus

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

Automated tests are written in [Serverspec](http://serverspec.org) and require
the `vagrant-serverspec` plugin to be installed with:

    vagrant plugin install vagrant-serverspec

The `bin/box` script has subcommands for running both the automated tests
and for performing exploratory testing.

Use the `bin/box test` subcommand to run the automated Serverspec tests.
For example to execute the tests for the Ubuntu 14.04 box on VirtualBox, use
the following:

    bin/box test ubuntu1604 virtualbox

Similarly, to perform exploratory testing on the VirtualBox image via ssh,
run the following command:

    bin/box ssh ubuntu1604 virtualbox

### Variable overrides

There are several variables that can be used to override some of the default
settings in the box build process. The variables can that can be currently
used are:

* cm
* cm_version
* cpus
* disk_size
* memory
* update

Changing the value of the `CM` variable changes the target suffixes for
the output of `make list` accordingly.

Possible values for the CM variable are:

* `nocm` - No configuration management tool
* `ansible` - Install Ansible
* `chef` - Install Chef
* `chefdk` - Install Chef Development Kit
* `puppet` - Install Puppet
* `salt`  - Install Salt

You can also specify a variable `CM_VERSION`, if supported by the
configuration management tool, to override the default of `latest`.
The value of `CM_VERSION` should have the form `x.y` or `x.y.z`,
such as `CM_VERSION := 12.9.32`

The variable `HEADLESS` can be set to run Packer in headless mode.
Set `HEADLESS := true`, the default is false.

The variable `UPDATE` can be used to perform OS patch management.  The
default is to not apply OS updates by default.  When `UPDATE := true`,
the latest OS updates will be applied.

The variable `PACKER` can be used to set the path to the packer binary.
The default is `packer`.

The variable `ISO_PATH` can be used to set the path to a directory with
OS install images. This override is commonly used to speed up Packer builds
by pointing at pre-downloaded ISOs instead of using the default download
Internet URLs.

The variables `SSH_USERNAME` and `SSH_PASSWORD` can be used to change the
 default name & password from the default `vagrant`/`vagrant` respectively.

The variable `INSTALL_VAGRANT_KEY` can be set to turn off installation of the
default insecure vagrant key when the image is being used outside of vagrant.
Set `INSTALL_VAGRANT_KEY := false`, the default is true.

## Contributing


1. Fork and clone the repo.
2. Create a new branch, please don't work in your `master` branch directly.
3. Add new [Serverspec](http://serverspec.org/) or [Bats](https://blog.engineyard.com/2014/bats-test-command-line-tools) tests in the `test/` subtree for the change you want to make.  Run `make test` on a relevant template to see the tests fail (like `make test-virtualbox/ubuntu1404`).
4. Fix stuff.  Use `make ssh` to interactively test your box (like `make ssh-virtualbox/ubuntu1404`).
5. Run `make test` on a relevant template (like `make test-virtualbox/ubuntu1404`) to see if the tests pass.  Repeat steps 3-5 until done.
6. Update `README.md` and `AUTHORS` to reflect any changes.
7. If you have a large change in mind, it is still preferred that you split them into small commits.  Good commit messages are important.  The git documentatproject has some nice guidelines on [writing descriptive commit messages](http://git-scm.com/book/ch5-2.html#Commit-Guidelines).
8. Push to your fork and submit a pull request.
9. Once submitted, a full `make test` run will be performed against your change in the build farm.  You will be notified if the test suite fails.

### Would you like to help out more?

Contact moujan@annawake.com 

### Acknowledgments

[Parallels](http://www.parallels.com/) provides a Business Edition license of
their software to run on the basebox build farm.

<img src="http://www.parallels.com/fileadmin/images/corporate/brand-assets/images/logo-knockout-on-red.jpg" width="80">

[SmartyStreets](http://www.smartystreets.com) is providing basebox hosting for the box-cutter project.

![Powered By SmartyStreets](https://smartystreets.com/resources/images/smartystreets-flat.png)

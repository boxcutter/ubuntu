# Packer templates for Ubuntu

### Overview

This repository contains templates for Ubuntu that can create Vagrant boxes
using Packer.

## Current Boxes

64-bit boxes:

* [Ubuntu Server 15.04 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1504)
* [Ubuntu Desktop 15.04 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1504-desktop)
* [Ubuntu Server 15.04 (64-bit) with Docker preinstalled](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1504-docker)
* [Ubuntu Server 14.10 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1410)
* [Ubuntu Server 14.10 (64-bit) with Docker preinstalled](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1410-docker)
* [Ubuntu Server 14.04.2 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404)
* [Ubuntu Desktop 14.04.2 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404-desktop)
* [Ubuntu Server 14.04.2 (64-bit) with Docker preinstalled](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404-docker)
* [Ubuntu Server 12.04.5 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204)
* [Ubuntu Desktop 12.04.4 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204-desktop)
* [Ubuntu Server 12.04.5 (64-bit) with Docker preinstalled](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204-docker)
* [Ubuntu Server 10.04.4 (64-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1004)

32-bit boxes:

* [Ubuntu Server 15.04 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1504-i386)
* [Ubuntu Server 14.10 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1410-i386)
* [Ubuntu Server 14.04.1 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1404-i386)
* [Ubuntu Server 12.04.5 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1204-i386)
* [Ubuntu Server 10.04.4 (32-bit)](https://atlas.hashicorp.com/boxcutter/boxes/ubuntu1004-i386)

## Building the Vagrant boxes

To build all the boxes, you will need VirtualBox, VMware Fusion, and Parallels Desktop for Mac installed.

Parallels requires that the
[Parallels Virtualization SDK for Mac](http://www.parallels.com/downloads/desktop)
be installed as an additional preqrequisite.

A GNU Make `Makefile` drives the process via the following targets:

    make        # Build all available box types
    make test   # Run tests against all the boxes
    make list   # Print out the list of all available boxes
    make clean  # Clean up build detritus

To build one particular box, e.g. `ubuntu1404`,
for just one provider, e.g. VirtualBox,
first run `make list` subcommand:

    make list

This command prints the list of available boxes.
Then you can build one particular box for choosen provider:

    make virtualbox/ubuntu1404

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
* `ansible` - Install Ansible
* `chef` - Install Chef
* `chefdk` - Install Chef Development Kit
* `puppet` - Install Puppet
* `salt`  - Install Salt

You can also specify a variable `CM_VERSION`, if supported by the
configuration management tool, to override the default of `latest`.
The value of `CM_VERSION` should have the form `x.y` or `x.y.z`,
such as `CM_VERSION := 11.12.4`

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

### Acknowledgments

[SmartyStreets](http://www.smartystreets.com) is providing basebox hosting for the box-cutter project.

![Powered By SmartyStreets](https://smartystreets.com/resources/images/smartystreets-flat.png)

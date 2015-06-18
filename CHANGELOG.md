# Changelog

## 1.0.20 (2015-06-18)

* Increase lazy-allocated disk size for server images to 64GB
* Increase lazy-allocated disk size for desktop images to 127GB

## 1.0.19 (2015-06-07)

* Add Ubuntu 15.04 images for VMware

## 1.0.18 (2015-06-06)

* Removed 10.04 images - Ubuntu 10.04 stopped getting updates April 2015
* Upgrade Parallels Tools to 10.2.1
* Add Ubuntu 15.04 images for Parallels
* Upgrade VirtualBox Guest Additions to 4.3.28

## 1.0.17 (2015-05-05)

* Ubuntu 15.04 released, switch to release ISOs instead of daily ISOs
* Upgrade Parallels Tools to 10.2.0

## 1.0.16 (2015-03-20)

* Upgrade Virtual Box Guest Additions to 4.3.26

## 1.0.15 (2015-03-12)

* Upgrade Virtual Box Guest Additions to 4.3.24
* Fix issues with upgrading Parallels tools

## 1.0.14 (2015-02-26)

* Use the SATA HDD controller for faster disk IO speeds on VirtualBox

## 1.0.13 (2015-02-22)

* Upgrade Ubuntu 14.04.1 to Ubuntu 14.04.2
* Upgrade Parallels tools to 10.1.4
* Upgrade VirtualBox Guest Additions to 4.3.22
* Upgrade VMware Tools to 9.9.2 for VMware Fusion 7.1.1

## 1.0.11 (2014-12-23)

* Upgrade Parallels Tools to 10.1.2
* Default timezone is now UTC

## 1.0.10 (2014-12-06)

* Upgrade VMware Tools to 9.9.0 for VMware Fusion 7.1.0

## 1.0.9 (2014-11-26)

* Upgrade VirtualBox Guest Addition to 4.3.20
* Upgrade Docker version to 1.3.2

## 1.0.8 (2014-11-05)

* Upgraded VMware Tools to 9.8.4 for VMware Fusion 7
* Added Ubuntu 14.10 templates
* Bump Docker version to 1.3.1
* Enable 3D acceleration under VMware Fusion and Workstation

## 1.0.7 (2014-10-16)

* Upgraded VirtualBox Guest Additions to 4.3.18

## 1.0.6 (2014-09-21)

* Upgraded VirtualBox Guest Additions to 4.3.16
* Fix regression in vagrant user not being added to docker group

## 1.0.5 (2014-09-05)

* Upgraded VMware Tools to 9.8.3 for VMware Fusion 7
* Bump Docker version to 1.20

## 1.0.4 (2014-08-01)

* Adding fix to prevent issue when vagrant reload is used with public_network

## 1.0.3 (2014-07-29)

* Upgrade Docker to 0.11.1
* Upgrade Ubuntu 14.04.0 to 14.04.1
* Bump desktop disk size to 40GB

## 1.0.1 (2014-05-19)

Upgrade Docker to 0.11 RC

* Default to installing from the Docker repository instead of Canonical repo
* Add ability to install from Docker repository, as Canonical repo lags
* Giver Docker non-root access
* Add docker alias when installed via docker.io package with update-alternatives

## 1.0.0 (2014-05-09)

* Initial commit

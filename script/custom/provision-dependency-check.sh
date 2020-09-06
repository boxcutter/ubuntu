#!/usr/bin/env bash
echo "Provisioning dependency check"

cd tools
wget "https://dl.bintray.com/jeremy-long/owasp/dependency-check-5.3.2-release.zip"
unzip dependency-check-5.3.2-release.zip
rm dependency-check-5.3.2-release.zip
echo "export PATH=\$PATH:/home/vagrant/tools/dependency-check/bin" >> ~/.bashrc

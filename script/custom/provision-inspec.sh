#!/usr/bin/env bash
echo "provisioning inspec"
curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec

cd workspace
wget https://github.com/commjoen/inspec_intro/archive/master.zip
unzip master.zip
rm master.zip
mv inspec_intro-master inspec_intro

echo "provisioning lynis"
sudo apt-get install lynis

echo "provisioning cvescan"
sudo snap install cvescan

echo "provisioning openscap"
cd ~/tools
mkdir openscap
cd openscap
apt-get install -y libopenscap8
echo "wget https://people.canonical.com/~ubuntu-security/oval/com.ubuntu.$(lsb_release -cs).cve.oval.xml.bz2" >> openscap.sh
ehco "bunzip2 com.ubuntu.$(lsb_release -cs).cve.oval.xml.bz2" >> openscap.sh
echo "oscap oval eval --report report.htm com.ubuntu.$(lsb_release -cs).cve.oval.xml" >> openscap.sh
chmod +x openscap.sh
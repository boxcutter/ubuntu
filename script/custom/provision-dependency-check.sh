#!/usr/bin/env bash
echo "Provisioning dependency check"

cd tools
wget "https://dl.bintray.com/jeremy-long/owasp/dependency-check-5.3.2-release.zip"
unzip dependency-check-5.3.2-release.zip
rm dependency-check-5.3.2-release.zip
echo "export PATH=\$PATH:/home/$USER_FOLDER/tools/dependency-check/bin" >> ~/.bashrc
chmod 777 -R /home/$USER_FOLDER/tools/dependency-check

echo "setup example with webgoat"
cd /home/$USER_FOLDER/workspace 
wget https://github.com/WebGoat/WebGoat/archive/develop.zip
unzip develop.zip && rm develop.zip
chown -R $USER_FOLDER /home/$USER_FOLDER/workspace/WebGoat-develop
apt install -y maven


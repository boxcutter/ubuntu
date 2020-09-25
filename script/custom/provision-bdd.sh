#!/usr/bin/env bash
echo "provisioning the BDD exercises"

echo "provisioning ropeytasks"
cd /home/$USER_FOLDER/tools
mkdir ropeytasks && cd ropeytasks
wget https://github.com/iriusrisk/RopeyTasks/raw/master/ropeytasks.jar

echo "java -jar /home/$USER_FOLDER/tools/ropeytasks/ropeytasks.jar" > ropeytasks.sh
chmod +x ropeytasks.sh
echo "export PATH=\$PATH:/home/$USER_FOLDER/tools/ropeytasks" >> ~/.bashrc


echo "provisioning bdd-security"
cd /home/$USER_FOLDER/workspace
git clone https://github.com/continuumsecurity/bdd-security.git
sudo chown -R $USER_FOLDER /home/$USER_FOLDER/workspace/bdd-security


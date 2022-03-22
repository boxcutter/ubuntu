#!/usr/bin/env bash
echo "Preparing oauth and oidc lessons"
cd /home/$USER_FOLDER/workspace
git clone https://github.com/koenbuyens/Vulnerable-OAuth-2.0-Applications.git
cd Vulnerable-OAuth-2.0-Applications/insecureapplication
sudo apt install mongodb-server-core mongo-tools -y
sudo mkdir /data/db


cd gallery/mongodbdata
mongorestore -d gallery2 gallery2/
cd ../..
cd gallery
npm install
cd ..
cd photoprint
npm install
cd ..
cd attacker
npm install
cd ..



echo "#!/usr/bin/env bash" >> start.sh
echo "cd gallery" >> start.sh
echo "npm start &" >> start.sh
echo "cd .." >> start.sh
echo "cd photoprint" >> start.sh
echo "npm start &" >> start.sh
echo "cd .." >> start.sh
echo "cd attacker" >> start.sh
echo "npm start &" >> start.sh
chmod 777 start.sh

echo "127.0.0.1 photoprint gallery attacker mongodb" >> /etc/hosts

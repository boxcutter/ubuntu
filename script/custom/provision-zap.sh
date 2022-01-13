#!/usr/bin/env bash
set -e

echo "Provisioning ZAP..."
cd tools
zap_version="2.11.1"
wget https://github.com/zaproxy/zaproxy/releases/download/v${zap_version}/ZAP_${zap_version}_Linux.tar.gz
tar xvfx ZAP_${zap_version}_Linux.tar.gz
rm -rf ZAP_${zap_version}_Linux.tar.gz
echo "export PATH=\$PATH:/home/$USER_FOLDER/tools/ZAP_${zap_version}" >> /home/$USER_FOLDER/.bashrc

echo "provision exercise material..."
cd /home/$USER_FOLDER/workspace
wget https://github.com/OWASP/NodeGoat/archive/master.zip
unzip master.zip && rm master.zip
mv NodeGoat-master nodegoat
cd nodegoat
rm config/env/all.js
echo "// default app configuration" >> config/env/all.js
echo "" >> config/env/all.js
echo "const port = process.env.PORT || 4000;" >> config/env/all.js
echo "let db = process.env.MONGOLAB_URI || process.env.MONGODB_URI;" >> config/env/all.js
echo "" >> config/env/all.js
echo "if (!db) {" >> config/env/all.js
echo "  db = \"mongodb://localhost:27017/nodegoat\" " >> config/env/all.js
echo "}" >> config/env/all.js
echo "" >> config/env/all.js
echo "module.exports = {" >> config/env/all.js
echo "    port," >> config/env/all.js
echo "    db," >> config/env/all.js
echo "    cookieSecret: \"session_cookie_secret_key_here\"," >> config/env/all.js
echo "    cryptoKey: \"a_secure_key_for_crypto_here\"," >> config/env/all.js
echo "    cryptoAlgo: \"aes256\"," >> config/env/all.js
echo "    hostName: \"localhost\"" >> config/env/all.js
echo "};" >> config/env/all.js

echo "docker run -d -p 27017:27017 -v ~/data:/data/db mongo" >> startmongo.sh
chmod 777 startmongo.sh

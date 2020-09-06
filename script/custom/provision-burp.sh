#!/usr/bin/env bash
echo "Provisioning burp"

cd tools
mkdir burp
cd burp
curl 'https://portswigger.net/burp/releases/download?product=community&version=2020.8.1&type=Jar' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:79.0) Gecko/20100101 Firefox/79.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Connection: keep-alive' -H 'Referer: https://portswigger.net/burp/releases/professional-community-2020-8-1' -H 'Cookie: SessionId=FFCD743944FF4E69C47013891BF907C00D60DF8917B1A9833BAB8510647D5A3ECC029AE70D1655F6' -H 'Upgrade-Insecure-Requests: 1' --output burp.jar

echo "java -jar /home/vagrant/tools/burp/burp.jar" > burp.sh
chmod +x burp.sh
echo "export PATH=$PATH:/home/vagrant/tools/burp" >> ~/.bashrc

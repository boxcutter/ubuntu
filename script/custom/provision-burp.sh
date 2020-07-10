#!/usr/bin/env bash
echo "Provisioning burp"

cd tools
mkdir burp
cd burp
wget "https://portswigger.net/burp/releases/initiatedownload?product=community&version=2020.6&type=Jar"
mv * burp.jar

echo "java -jar burp.jar" > burp.sh
chmod +x burp.sh

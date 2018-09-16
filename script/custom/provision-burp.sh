#!/usr/bin/env bash
echo "Provisioning burp"

cd tools
mkdir burp
cd burp
wget "https://portswigger.net/burp/releases/download?product=community&version=1.7.36&type=jar"
mv * burp.jar
echo "java -jar burp.jar" > burp.sh
chmod +x burp.sh

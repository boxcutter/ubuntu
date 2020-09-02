#!/usr/bin/env bash
echo "Provisioning burp"

cd tools
mkdir burp
cd burp
#TODO: FIX THE ISSUE BELOW!
wget "https://portswigger.net/burp/releases/initiatedownload?product=community&version=2020.8.1&type=Jar"
mv * burp.jar

echo "java -jar burp.jar" > burp.sh
chmod +x burp.sh

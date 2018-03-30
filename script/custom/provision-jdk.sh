#!/usr/bin/env bash
set -e

# install JDK as it was meant to be - from scratch
# echo "Provisioning Java JDK..."
# mkdir -p /home/vagrant/java
# cd /home/vagrant/java
# test -f /tmp/jdk-8-linux-x64.tar.gz || curl -q -L --cookie "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jdk-8u162-linux-i586.tar.gz -o /tmp/jdk-8-linux-x64.tar.gz
# sha256sum -c <<<"eecf88dbcf7c78d236251d44350126f1297a522f2eab974b4027ef20f7a6fb24 */tmp/jdk-8-linux-x64.tar.gz"
#
# sudo mkdir -p /usr/lib/jvm
#
# sudo tar zxf /tmp/jdk-8-linux-x64.tar.gz -C /usr/lib/jvm
#
# # register Java
# sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_162/bin/java" 1
# sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_162/bin/javac" 1
# sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.8.0_162/bin/javaws" 1
#
# sudo chmod a+x /usr/bin/java
# sudo chmod a+x /usr/bin/javac
# sudo chmod a+x /usr/bin/javaws
# sudo chown -R root:root /usr/lib/jvm/jdk1.8.0_162
# ln -s /usr/lib/jvm/jdk1.8.0_162/ /usr/lib/jvm/current

#sudo echo -e "export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_162" >> /etc/environment
#echo "export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_162" >> /home/vagrant/.zshrc

# echo "Provisinong maven..."
#
# sudo apt-get install -y maven

echo "Provisioning runtime next to the JDK"
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get update -y
sudo apt-get install oracle-java8-installer -y
sudo apt-get install ant -y

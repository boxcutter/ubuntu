#!/usr/bin/env bash
echo "Provisioning Docker verification tooling..."

echo "provisioning Dockle"
 DOCKLE_VERSION=$(
 curl --silent "https://api.github.com/repos/goodwithtech/dockle/releases/latest" | \
 grep '"tag_name":' | \
 sed -E 's/.*"v([^"]+)".*/\1/' \
) && curl -L -o dockle.deb https://github.com/goodwithtech/dockle/releases/download/v${DOCKLE_VERSION}/dockle_${DOCKLE_VERSION}_Linux-64bit.deb
sudo dpkg -i dockle.deb && rm dockle.deb

echo "provisioning Hadolint"
wget https://github.com/hadolint/hadolint/releases/download/v1.18.0/hadolint-Linux-x86_64
mv hadolint-Linux-x86_64 /usr/bin/hadolint
chmod 777 /usr/bin/hadolint

mkdir /home/$USER_FOLDER/workspace/example
cd /home/$USER_FOLDER/workspace/example
wget https://raw.githubusercontent.com/mikesplain/openvas-docker/master/9/Dockerfile

echo "Provisioning Trivy"
wget https://github.com/aquasecurity/trivy/releases/download/v0.11.0/trivy_0.11.0_Linux-64bit.deb
dpkg -i trivy_0.11.0_Linux-64bit.deb 
rm trivy_0.11.0_Linux-64bit.deb


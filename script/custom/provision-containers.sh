echo "provisioning containers"
echo "container overview:" >> containers.md

echo "juiceshop container:">> containers.md
echo "docker run -d --rm -p 3000:3000 bkimminich/juice-shop" >> containers.md
echo "https://github.com/bkimminich/juice-shop" >> containers.md
docker pull bkimminich/juice-shop

echo "Downloading additional sources"
cd workspace
wget https://github.com/bkimminich/juice-shop/archive/master.zip
unzip master.zip
rm master.zip
mv juice-shop-master juice-shop
chown -R $USER_FOLDER /home/$USER_FOLDER/workspace/juice-shop

echo "getting more containers"

echo " ">> containers.md
echo "webgoat and webwolf container:" >> containers.md
echo "docker run -p 8080:8080 -t webgoat/webgoat-8.0" >> containers.md
echo "https://github.com/WebGoat/WebGoat" >> containers.md
docker pull webgoat/webgoat-8.0

echo " ">> containers.md
echo"docker run -d -p 27017:27017 -v ~/data:/data/db mongo">> containers.md
docker pull mongo

# echo " ">> containers.md
# echo "dvws container:">> containers.md
# echo "docker run -d -p 80:80 -p 8080:8080 tssoffsec/dvws" >> containers.md
# echo "https://hub.docker.com/r/tssoffsec/dvws/" >> containers.md
# docker pull tssoffsec/dvws

echo " " >> containers.md
echo "Gitlab container: " >> containers.md
echo " docker run --detach \
  --hostname gitlab.example.com \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab \
  --restart always \
  --volume /srv/gitlab/config:/etc/gitlab \
  --volume /srv/gitlab/logs:/var/log/gitlab \
  --volume /srv/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest" >> containers.md
docker pull gitlab/gitlab-ce

echo " ">> containers.md
echo "openvas container:">> containers.md
echo "docker run --detach --publish 8080:9392 -e PASSWORD=PASSWORD HERE --name openvas immauss/openvas" >> containers.md
echo "https://hub.docker.com/r/mikesplain/openvas/" >> containers.md
docker pull immauss/openvas

echo " ">> containers.md
echo "docker run -it --net host --pid host --userns host --cap-add audit_control \ " >> containers.md
echo "    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \ " >> containers.md
echo "    -v /etc:/etc:ro \ " >> containers.md
echo "    -v /lib/systemd/system:/lib/systemd/system:ro \ " >> containers.md
echo "    -v /usr/bin/containerd:/usr/bin/containerd:ro \ " >> containers.md
echo "    -v /usr/bin/runc:/usr/bin/runc:ro \ " >> containers.md
echo "    -v /usr/lib/systemd:/usr/lib/systemd:ro \ " >> containers.md
echo "    -v /var/lib:/var/lib:ro \ " >> containers.md
echo "    -v /var/run/docker.sock:/var/run/docker.sock:ro \ " >> containers.md
echo "    --label docker_bench_security \ " >> containers.md
docker pull docker/docker-bench-security

echo " ">> containers.md



exit
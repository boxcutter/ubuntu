echo "provisioning containers"
echo "container overview:" >> containers.md

echo "juiceshop container:">> containers.md
echo "docker run -d --rm -p 3000:3000 bkimminich/juice-shop" >> containers.md
echo "https://github.com/bkimminich/juice-shop" >> containers.md
docker pull bkimminich/juice-shop

echo " ">> containers.md
echo "webgoat and webwolf container:" >> containers.md
echo "docker run -p 8080:8080 -t webgoat/webgoat-8.0" >> containers.md
echo "https://github.com/WebGoat/WebGoat" >> containers.md
docker pull webgoat/webgoat-8.0

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
echo "docker run -d -p 443:443 --name openvas mikesplain/openvas" >> containers.md
echo "https://hub.docker.com/r/mikesplain/openvas/" >> containers.md
docker pull mikesplain/openvas
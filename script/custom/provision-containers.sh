echo "provisioning containers"
echo "container overview:" >> containers.md

echo "juiceshop container:">> containers.md
echo "docker run --rm -p 3000:3000 bkimminich/juice-shop" >> containers.md
echo "https://github.com/bkimminich/juice-shop" >> containers.md
docker pull bkimminich/juice-shop

echo " ">> containers.md
echo "webgoat container (7.1):" >> containers.md
echo "docker run -p 8080:8080 -t webgoat/webgoat-7.1" >> containers.md
echo "https://github.com/WebGoat/WebGoat" >> containers.md
docker pull webgoat/webgoat-7.1

echo " ">> containers.md
echo "webgoat container (8.0):" >> containers.md
echo "docker run -p 8080:8080 -it webgoat/webgoat-8.0 /home/webgoat/start.sh" >> containers.md
echo "https://github.com/WebGoat/WebGoat" >> containers.md
docker pull webgoat/webgoat-8.0

echo " ">> containers.md
echo "dvws container:">> containers.md
echo "docker run -d -p 80:80 -p 8080:8080 tssoffsec/dvws" >> containers.md
echo "https://hub.docker.com/r/tssoffsec/dvws/" >> containers.md
docker pull tssoffsec/dvws

echo " ">> containers.md
echo "xvwa container:">> containers.md
echo "docker run --name xvwa -d -p 80:80 tuxotron/xvwa" >> containers.md
echo "https://github.com/s4n7h0/xvwa" >> containers.md
docker pull tuxotron/xvwa



# echo " ">> containers.md
# echo "openvas container:">> containers.md
# echo "docker run -d -p 443:443 --name openvas mikesplain/openvas" >> containers.md
# echo "https://hub.docker.com/r/mikesplain/openvas/" >> containers.md
# docker pull mikesplain/openvas

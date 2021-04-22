#!/bin/bash

echo "installing Docker"
sudo apt-get remove docker docker-engine docker.io containerd runc

sudo apt-get update || exit 1

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release || exit 1

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg || exit 1
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || exit 1

sudo apt-get update || exit 1
sudo apt-get install docker-ce docker-ce-cli containerd.io -y || exit 1

echo "Pulling Postgres latest image"
sudo docker pull postgres:latest || exit 1

echo "Starting Postgress Container"
sudo docker run -d --name DB --restart always -p 5432:5432 -e 'POSTGRES_PASSWORD=p@ssw0rd42' -v /custom/mount:/var/lib/postgresql/data postgres || exit 1
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
apt-get install -y docker-compose

echo "cloning Docker compose Repo"

sudo mkdir -p /home/azureuser/work
sudo chmod -R 777 /home/azureuser/work

git clone https://github.com/natalicot/Jenkins_GitLab_Artifactory_compose.git /home/azureuser/work

sudo docker build -t jenkins /home/azureuser/work/
cd /home/azureuser/work/ || exit 1
sudo docker-compose up 


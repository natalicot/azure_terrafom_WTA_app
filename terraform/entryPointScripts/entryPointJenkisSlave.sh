#!/bin/bash

echo "installing JRE & JDK"
sudo apt update || exit 1

sudo apt install default-jre -y || exit 1

sudo apt install default-jdk -y || exit 1

echo "creating jenkins working directory"
sudo mkdir -p /home/azureuser/work || exit 1

sudo chmod -R 777 /home/azureuser/work || exit 1

echo "installing zip & unzip"
sudo apt-get install zip unzip || exit 1
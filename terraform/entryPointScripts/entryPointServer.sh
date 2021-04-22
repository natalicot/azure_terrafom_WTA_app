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

echo "installing node"
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - || exit 1

sudo apt install nodejs || exit 1

# cd /home/azureuser/work || exit 1

# git clone https://natalicot@dev.azure.com/natalicot/SELA_Bootcamp/_git/WeightTracker /home/azureuser/work || exit 1

# echo "installing npm"
# npm install || exit 1

# echo "running init DB"
# npm run initdb || exit 1

echo "installing PM2"
sudo npm install pm2@latest -g || exit 1

# echo "Running the app on PM2"
# pm2 start src/index.js || exit 1
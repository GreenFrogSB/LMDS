#!/bin/bash
DCV=$(docker-compose --version)

echo  ""
echo  -e "\e[32;1m Current: $DCV \e[0m"

FILE=docker-compose.yml
if [ -f "$FILE" ]; then
    echo  -e "\e[33;1m   Stopping all containers\e[0m"
    docker-compose stop
else 
    echo -e "\e[33;1m   No runing containers detected - $FILE does not exist yet.\e[0m"
fi

echo  -e "\e[33;1m    Removing Docker-compose\e[0m"
sudo apt-get remove docker-compose -y &> /dev/null

echo  -e "\e[33;1m    Getting Python3\e[0m"
sudo apt-get install libffi-dev libssl-dev -y &> /dev/null
sudo apt-get install python3-dev -y &> /dev/null
sudo apt-get install python3 python3-pip -y &> /dev/null

echo  -e "\e[33;1m    Installing new Docker-compose via pip3\e[0m"
sudo pip3 install docker-compose  &> /dev/null
sudo mv  /usr/local/bin/docker-compose /usr/bin/docker-compose  &> /dev/null

FILE=docker-compose.yml
if [ -f "$FILE" ]; then
    echo  -e "\e[33;1m   Starting all container up again\e[0m"
    docker-compose up -d
else 
     echo -e "\e[33;1m   No containers to start $FILE does not exist yet.\e[0m"
fi

DCV=$(docker-compose --version)
echo  -e "\e[32;1m Updated current: $DCV\e[0m"
echo  ""
#!/bin/bash
DCV=$(docker-compose --version)

echo  ""
echo  -e "\e[32;1m Current: $DCV \e[0m"

echo  -e "\e[33;1m    Stopping Docker-compose\e[0m"
docker-compose stop

echo  -e "\e[33;1m    Removing Docker-compose\e[0m"
sudo apt-get remove docker-compose -y &> /dev/null

echo  -e "\e[33;1m    Getting Python3\e[0m"
sudo apt-get install libffi-dev libssl-dev -y &> /dev/null
sudo apt-get install python3-dev -y &> /dev/null
sudo apt-get install python3 python3-pip -y &> /dev/null

echo  -e "\e[33;1m    Installing new Docker-compose via pip3\e[0m"
sudo pip3 install docker-compose  &> /dev/null

echo  -e "\e[33;1m    Starting stack up again\e[0m"
docker-compose up -d

DCV=$(docker-compose --version)
echo  -e "\e[32;1m Updated current: $DCV\e[0m"
echo  ""
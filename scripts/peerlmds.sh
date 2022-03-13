#!/bin/bash
if [ -d services/peer2profit ]
then
echo -e "\e[36;1mPeer2Profit already deployed - check docker-compose.yml\e[0m"

else
mkdir services/peer2profit
cat .templates/peer2profit/servive.yml >> docker-compose.yml 
cat >> services/selection.txt <<EOF
peer2profit
EOF

echo -e "\e[36;1mEdit docker-compose.yml file located inside LMDS folder. \nFind Peer2Profit container declaration and replace default settings. \nWhen done run \e[104;1mdocker-compose up -d\e[0m \e[36;1mto start new containers\e[0m"
fi

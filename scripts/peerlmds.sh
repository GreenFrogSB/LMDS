#!/bin/bash 

mkdir services/peer2profit
cat .templates/peer2profit/servive.yml >> docker-compose.yml 
cat >> services/selection.txt <<EOF
peer2profit
EOF

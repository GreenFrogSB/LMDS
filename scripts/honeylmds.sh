#!/bin/bash 

mkdir services/honeygain 
cat .templates/honeygain/servive.yml >> docker-compose.yml 
cat >> services/selection.txt <<EOF
honeygain
EOF


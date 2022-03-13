#!/bin/bash
if [ -d services/honeygain ]
then
echo -e "\e[36;1mHoneygain already deployed - check docker-compose.yml\e[0m"

else
 mkdir services/honeygain
 cp .templates/honeygain/service.yml services/honeygain/
 cat .templates/honeygain/service.yml >> docker-compose.yml
 cat >> services/selection.txt <<EOF
honeygain
EOF

echo -e "\e[36;1mEdit docker-compose.yml file located inside LMDS folder. \nFind Honeygain container declaration and replace default settings. \nWhen done run \e[104;1mdocker-compose up -d\e[0m \e[36;1mto start new containers\e[0m"
fi

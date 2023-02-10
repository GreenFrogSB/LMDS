#!/bin/bash

# Server 1
[ -d ./volumes/WebServ/ngnix01/www/html/ ] || mkdir -p ./volumes/WebServ/ngnix01/www/html/;
[ -d ./volumes/WebServ/ngnix01/config/conf.d/ ] || mkdir -p ./volumes/WebServ/ngnix01/config/conf.d/;
cp .templates/web/config/nginx/index.php ./volumes/WebServ/ngnix01/www/html/index.php;
cp .templates/web/config/nginx/site.conf ./volumes/WebServ/ngnix01/config/conf.d/site.conf;

# Server 2 
[ -d ./volumes/WebServ/ngnix02/www/html/ ] || mkdir -p ./volumes/WebServ/ngnix02/www/html/;
[ -d ./volumes/WebServ/ngnix02/config/conf.d/ ] || mkdir -p ./volumes/WebServ/ngnix02/config/conf.d/;
cp .templates/web/config/nginx/index.php ./volumes/WebServ/ngnix02/www/html/index.php;
cp .templates/web/config/nginx/site.conf ./volumes/WebServ/ngnix02/config/conf.d/site.conf;
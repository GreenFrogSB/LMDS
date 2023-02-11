#!/bin/bash

# Server 1
[ -d ./volumes/WebServ/nginx01/www/html/ ] || mkdir -p ./volumes/WebServ/nginx01/www/html/;
[ -d ./volumes/WebServ/nginx01/config/conf.d/ ] || mkdir -p ./volumes/WebServ/nginx01/config/conf.d/;
cp .templates/web/config/nginx/index.php ./volumes/WebServ/nginx01/www/html/index.php;
cp .templates/web/config/nginx/NG01.conf ./volumes/WebServ/nginx01/config/conf.d/site.conf;

# Server 2 
[ -d ./volumes/WebServ/nginx02/www/html/ ] || mkdir -p ./volumes/WebServ/nginx02/www/html/;
[ -d ./volumes/WebServ/nginx02/config/conf.d/ ] || mkdir -p ./volumes/WebServ/nginx02/config/conf.d/;
cp .templates/web/config/nginx/index.php ./volumes/WebServ/nginx02/www/html/index.php;
cp .templates/web/config/nginx/NG02.conf ./volumes/WebServ/nginx02/config/conf.d/site.conf;
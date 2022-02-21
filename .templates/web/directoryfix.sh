#!/bin/bash
[ -d ./volumes/WebServ/ngnix01/www/html/ ] || sudo mkdir -p ./volumes/WebServ/ngnix01/www/html/;
[ -d ./volumes/WebServ/ngnix01/config/conf.d/ ] || sudo mkdir -p ./volumes/WebServ/ngnix01/config/conf.d/;
sudo  cp .templates/web/config/nginx/index.php ./volumes/WebServ/ngnix01/www/html/index.php;
sudo cp .templates/web/config/nginx/site.conf ./volumes/WebServ/ngnix01/config/conf.d/site.conf;
[ -d ./volumes/WebServ/ngnix01/www/html/ ] || sudo mkdir -p ./volumes/WebServ/ngnix01/www/html/;
[ -d ./volumes/WebServ/php7/config.d/ ] || sudo mkdir -p ./volumes/WebServ/php7/config.d/;
[ -d ./volumes/WebServ/php7/php.ini/ ] || sudo mkdir -p ./volumes/WebServ/php7/php.ini/;
sudo cp .templates/web/config/php/php.ini ./volumes/WebServ/php7/php.ini/php.ini;
sudo cp .templates/web/config/php/uploads.ini ./volumes/WebServ/php7/config.d/uploads.ini 

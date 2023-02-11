#!/bin/bash

ip=$(hostname -I | cut -d' ' -f1)
# Server 1
[ -d ./volumes/WebServ/nginx01/www/html/ ] || mkdir -p ./volumes/WebServ/nginx01/www/html/;
[ -d ./volumes/WebServ/nginx01/config/conf.d/ ] || mkdir -p ./volumes/WebServ/nginx01/config/conf.d/;
cp .templates/web/config/nginx/index.php ./volumes/WebServ/nginx01/www/html/index.php;
cp .templates/web/config/nginx/NG01.conf ./volumes/WebServ/nginx01/config/conf.d/site.conf;
echo -e "\e[32;1m    Web Server nginx01 configured \e[0m"
echo -e "\e[32;1m    Web Server nginx01 startig at: http://$ip:60101 \e[0m" 
echo "" 
# Server 2 
[ -d ./volumes/WebServ/nginx02/www/html/ ] || mkdir -p ./volumes/WebServ/nginx02/www/html/;
[ -d ./volumes/WebServ/nginx02/config/conf.d/ ] || mkdir -p ./volumes/WebServ/nginx02/config/conf.d/;
cp .templates/web/config/nginx/index.php ./volumes/WebServ/nginx02/www/html/index.php;
cp .templates/web/config/nginx/NG02.conf ./volumes/WebServ/nginx02/config/conf.d/site.conf;
echo -e "\e[32;1m    Web Server nginx02 configured \e[0m"
echo -e "\e[32;1m    Web Server nginx02 startig at: http://$ip:60102 \e[0m" 
echo "" 
# Install and configure FTP server 
sudo apt install vsftpd -y &> /dev/null
sudo mv /etc/vsftpd.conf /etc/vsftpd.conf.old &> /dev/null
sudo echo 'listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
local_root=/home/user' > vsftpd.conf

sudo mv vsftpd.conf /etc/vsftpd.conf &> /dev/null
sudo service vsftpd restart &> /dev/null

echo -e "\e[32;1m    SFTP Server configured \e[0m"
echo -e "\e[32;1m    Use sFTP client of your choice and connect to $ip \e[0m"
echo -e "\e[32;1m    Use your local username and password \e[0m"

# LMDS Stack

<b>Linux Media Delivery System Stack based on Docker and Raspberry Pi</b>

## About

Project goal is to simplify Docker and Docker-compose deployment on Raspberry Pi.
LMDS will allow you to dynamically choose containers and automate their deployment.
Create Docker server and start microservices in minutes with LMDS.

<b>What is currently a part of the LMDS Stack:</b>

<ul>
  <li>Portainer - GUI Docker Manager :9000</li>
  <li> Sonarr : 8989</li>
  <li> Medusa : 8081</li>
  <li> Radarr : 7878</li>
  <li> Lidarr : 8686</li>
  <li> Bazarr : 6767</li>
  <li> Jackett : 9117</li>
  <li> Prowlarr - Jackett alternative (dev) : 9696</li>
  <li> Deluge - Torrent Client : 8112</li>
  <li> qBittorrent - Torrent Client : 15080</li>
  <li> Transmission - Torrent Client : 9091</li>
  <li> NZBGet - Usenet groups client : 6789</li>
  <li> SABnzbd - Usenet groups client : 8080</li>
  <li> JellyFin - Media manager OpenSource : <b>8096</b></li>
  <li> Emby - Media manager like Plex : <b>8096</b></li>
  <li> Plex - Media manager : 32400/web</li>
  <li> Ombi - Plex Requests Server : 3579</li>
  <li> Overseerr - Plex Requests Server : 5055</li>
  <li> EmbyStat - Statistics for Emby : 6555</li>
  <li> TVheadend - TV streaming server : 9981 </li>
  <li> NPMP Server - NGINX + PHP + MariaDB + phpMyAdmin: 80 (Instructions: https://greenfrognest.com/LMDSwebServ.php)</li>
  <li> Pi-Hole - Private DNS sinkhole : 8089 <b>WebPass: <i>greenfrog</i></b></li>
  <li> VPN-Client - OpenVPN Gateway (Instructions: https://greenfrognest.com/LMDSVPN.php)</li>
  <li> Traefik 2 - Reverse Proxy (Instructions: https://greenfrognest.com/LMDSTraefikProxy.php)</li>
  </ul>
<br>
<i>Numbers after ":" identify a port that particular container will respond on, i.e. Portainer default port is :9000, point your browser it to your server IP adding :9000 at the end i.e. http://192.168.100.100:9000 you will see Portainer login page.</i>

### Raspberry Pi LMDS Server Docker Edition

YouTube: https://youtu.be/oLxsSQIqOMw

### GreenFrog Nest

Blog link: http://greenfrognest.com/lmdsondocker.php

## How to Use it?

<b>Before you start using LMDS, set your Raspberry Pi IP address to be static, it will make some things easier later on.
Static IP address is not absolutely necessary just to try the project to find out if you like it or not, but in case if you would like to properly utilize pi-hole in your network - you would have to point your router towards RPi IP for DNS resolution and having it static would be mandatory.</b>

- install git using a command:
<pre><code>sudo apt-get install git</code></pre>

- Clone the repository with:
<pre><code>git clone https://github.com/GreenFrogSB/LMDS.git ~/LMDS</code></pre>

<i>Do not change name of the folder on your local system it should stay as is for the script to work properly</i>

- Enter the directory and run:

<pre><code>cd ~/LMDS</code></pre>
<pre><code>./deploy.sh</code></pre>

## Menu

### Install Docker & Docker-compose

<p>First "Install Docker & Docker-compose" this might take a while. Script will install Docker and Docker-compose. When installation is completed you will be prompted to reboot, please do so before continuing.<p>

### Build LMDS Stack

<p>Next "Build LMDS Stack", select docker containers that you would like to pull and deploy. You do not have to select them all, select only the one you will use. You can add or remove your selection later on if needed. Selecting only containers you need will reduce RAM consumption on your Pi what might be a problem on RPi 3 that has only 1GB or RAM</p>

<p>You might want to install Portainer among all the other containers for sure - Portainer is a graphical interface that lets you manage Docker engine - very useful tool if you don’t want to use Docker command Line interface.</p>

### Docker commands

<p>This small section contains few useful commands in case of Portainer is not available (stop working) and you would like to get something done without the GUI.</p>

### Miscellaneous commands.

<p>There are three scripts that could be used in case you would like to disable swapping to your SD card. You might want to do this in order to extend life of your SD card. SD cards were not designed for intensive IO tasks, therefore using them like normal HDDs is not ideal. Swap file is used to offload your RAM in case of OS wanting to dump it somewhere. Swap will be quite often modify, what might wear out your SD card in a long run. In other hand if your OS is swapping it means his RAM size is generally to small - this might be a case on RPi3 where we have only 1GB of RAM.</p>

### Update LMDS Stack

<p>Each time you run <code>./deploy.sh</code> script will check GitHub repository for any updates and download them if available. You can also manually check for update using this option. Updates will not modify your configuration or any private files except the ones that are part of the LMDS logic. Some new functions might be added or new containers etc.</p>

### Update Docker-compose

<p>Debian based distribution is not always first to adopt latest Docker-compose updates and even if you keep your system up to date issuing apt-get update $ upgrade you will find out that your Docker-compose version is sometimes quite out of date. This option is specifically created to target Docker-compose updates to be done as easily as possible. Script is removing current Docker-compose and utilizing PIP Install newest available published by Docker-compose guys independently from what is available in Debian repository.</p>

### Backup and Restore LMDS

<p> This option will let you backup LMDS config and store it locally or in the cloud. Local backup is great for small changes that you are not sure of, so you can recover from failure quickly. Backup can be also configured to go in to the cloud i.e. Google Drive, Amazon, DropBox etc. This is great in case you would like to migrate or completely wipeout current SD card but in the same time you would like easily recover LMDS in to new OS installation. </p>

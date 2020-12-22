# LDS Stack

<b>Linux Download System Stack based on Docker for Raspberry Pi</b>

## About

Project goal is to simplify LDS deployment and maintenance on Raspberry Pi.
This repository will allow you to dynamically choose needed containers and automate their deployment.

<b>What is currently a part of the LDS Stack:</b>

<ul>
  <li>Portainer - GUI Docker Manager :9000</li>
  <li> Sonarr : 8989</li>
  <li> Radarr : 7878</li>
  <li> Lidarr : 8686</li>
  <li> Bazarr : 6767</li>
  <li> Jackett : 9117</li>
  <li> Deluge - Torrent Client : 8112</li>
  <li> qBittorrent - Torrent Client : 15080</li>
  <li> Transmission - Torrent Client : 9091</li>
  <li> NZBGet - Usenet groups client : 6789</li>
  <li> SABznbd - Usenet groups client : 8080</li>
  <li> JellyFin - Media manager OpenSource : <b>8096</b></li>
  <li> Emby - Media manager like Plex : <b>8096</b></li>
  <li> Plex - Media manager : 32400/web</li>
  <li> EmbyStat - Statistics for Emby : 6555</li>
  <li> TVheadend - TV streaming server : 9981 </li>
  <li> Ngnix - Web Server with links to all services deployed : 80</li>
  <li> Pi-Hole - Private DNS sinkhole : 8089 <b>WebPass: <i>greenfrog</i></b></li>
  </ul>
<br>
<i>Numbers after ":" identify a port that particular container will respond on, i.e. Portainer default port is :9000, point your browser it to your server IP adding :9000 at the end i.e. http://192.168.100.100:9000 you will see Portainer login page.</i>


### Raspberry Pi LDS Server Docker Edition
YouTube: https://youtu.be/oLxsSQIqOMw

### GreenFrog Small Blog
Blog link: http://greenfrog.eu5.net/ldsondocker.php

## How to Use it?
<b>Before you start using LDS, set your Raspberry Pi IP address to be static, it will make some things easier later on.
Static IP address is not absolutely necessary just to try the project and find out if you like it, but i.e. if you would like to properly utilize pihole in your network - you will have to point your router to your RPi IP for DNS resolution.</b>

- install git using a command:
<pre><code>sudo apt-get install git</code></pre>

- Clone the repository with:
<pre><code>git clone https://github.com/GreenFrogSB/LDS.git ~/LDS</code></pre>

<i>Do not change name of the folder on your local system it should stay as is for the script to work properly</i>

- Enter the directory and run:

<pre><code>cd ~/LDS</code></pre>
<pre><code>./deploy.sh</code></pre>

## Menu

### Install docker
<p>First "Install docker" this might take a while. Process will install latest Docker and Docker-compose for ARM. When installation is completed you will be prompted to reboot, please do so before continuing.<p>

### Build LDS Stack
<p>Next "Build LDS Stack", select docker containers that you would like to pull and deploy. You do not have to select them all, select only the one you will use. Selecting only the one you need will reduce RAM consumption on your Pi what might be a problem on RPi 3, not so much on RPi 4 I guess. I do not have RPi 4 so I was only able to test it on my old RPi 3B SBC</p>

<p>You might like to install Portainer among all the other containers - Portainer is a graphical interface that lets you manage Docker engine - very useful tool if you don’t want to use Docker CLI.</p>

### Docker commands

<p>This small section contains few useful commands in case your Portainer is not started and you would like to get something done without the GUI.</p>


### Miscellaneous commands.

<p>There are three scripts that can be used in case you would like to disable swapping to your SD card. You might want to do it in order to extend life of your SD card. SD cards were not designed for intensive IO tasks, therefore using them like normal HDDs is not ideal. Swap file is used to offload your RAM in case of OS need to dump it somewhere. Swap will be quite often modify, what might wear out your SD card in a long run. In other hand if your OS is swapping a lot of data it means his RAM size is generally to small - this might be a case on RPi3 where we have only 1GB of RAM.</p>        

### Update LDS Stack

<p>Each time you run <code>./deploy.sh</code> script will check GitHub repository for any updates and download them if available. You can also manually check for update using this option without running <code>./deploy.sh</code> script. Updates will not modify your configuration or any private files except the ones that are part of the LDS logic. Some new functions might be added or new containers etc.</p>

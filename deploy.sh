#!/bin/bash

#make sure you are in right directory
# pushd ~/LMDS

#Menu Display Name
#[CONTAINER NAME]="MENU Text"
declare -A cont_array=(
	[portainer]="Portainer - GUI Docker Manager"
	[sonarr]="Sonarr"
	[medusa]="Medusa"
	[radarr]="Radarr"
	[lidarr]="Lidarr"
	[bazarr]="Bazarr"
	[jackett]="Jackett"
	[prowlarr]="Prowlarr - Jackett alternative (dev)"
	[deluge]="Deluge - Torrent Client"
	[qbittorrent]="qBittorrent - Torrent Client"
	[transmission]="Transmission - Torrent Client"
	[nzbget]="NZBGet - Usenet groups client"
	[sabznbd]="SABznbd - Usenet groups client"
	[jellyfin]="JellyFin - Media manager no license needed"
	[plex]="Plex - Media manager"
	[ombi]="Ombi - Plex Requests Server"
	[overseerr]="Overseerr - Plex Requests Server"
	[emby]="Emby - Media manager like Plex"
	[embystat]="EmbyStat - Statistics for Emby"
	[tvheadend]="TVheadend - TV streaming server"
	[traefik]="Traefik 2 - Reverse Proxy"
	[web]="NPMP Server - NGINX + PHP + MariaDB + phpMyAdmin"
	[pihole]="Pi-Hole - Private DNS sinkhole"
	[vpn]="VPN-Client - OpenVPN Gateway"
	[honeygain]="Check - Earn \$ with LMDS - in main menu"
	[iproyal]="Check - Earn \$ with LMDS - in main menu"
  	[peer2profit]="Check - Earn \$ with LMDS - in main menu"

)

# CONTAINER keys
declare -a armhf_keys=(
	"portainer"
	"sonarr"
	"medusa"
	"radarr"
	"lidarr"
	"bazarr"
	"jackett"
	"prowlarr"
	"jellyfin"
	"emby"
	"embystat"
	"plex"
	"ombi"
	"overseerr"
	"tvheadend"
	"transmission"
	"deluge"
	"qbittorrent"
	"nzbget"
	"sabznbd"
	"pihole"
	"web"
	"traefik"
	"vpn"
	"honeygain"
	"iproyal"
	"peer2profit"

)

sys_arch=$(uname -m)

#timezones
timezones() {

	env_file=$1
	TZ=$(cat /etc/timezone)

	#test TimeZone=
	[ $(grep -c "TZ=" $env_file) -ne 0 ] && sed -i "/TZ=/c\TZ=$TZ" $env_file

}

# This function creates the volumes, services and backup directories.
# It then assisgns the current user to the ACL to give full read write access
docker_setfacl() {
	[ -d ./services ] || mkdir ./services
	[ -d ./volumes ] || mkdir ./volumes
	[ -d ./LMDSBackups ] || mkdir ./LMDSBackups

	#give current user rwx on the volumes and backups
	[ $(getfacl ./volumes | grep -c "default:user:$USER") -eq 0 ] && sudo setfacl -Rdm u:$USER:rwx ./volumes
	[ $(getfacl ./LMDSBackups | grep -c "default:user:$USER") -eq 0 ] && sudo setfacl -Rdm u:$USER:rwx ./LMDSBackups
}

#future function add password in build phase
password_dialog() {
	while [[ "$passphrase" != "$passphrase_repeat" || ${#passphrase} -lt 8 ]]; do

		passphrase=$(whiptail --passwordbox "${passphrase_invalid_message}Please enter the passphrase (8 chars min.):" 20 78 3>&1 1>&2 2>&3)
		passphrase_repeat=$(whiptail --passwordbox "Please repeat the passphrase:" 20 78 3>&1 1>&2 2>&3)
		passphrase_invalid_message="Passphrase too short, or not matching! "
	done
	echo $passphrase
}
#test=$( password_dialog )

command_exists() { command -v "$@" >/dev/null 2>&1 ; }

#function copies the template yml file to the local service folder and appends to the docker-compose.yml file
yml_builder() {

	service="services/$1/service.yml"

	[ -d ./services/ ] || mkdir ./services/

		if [ -d ./services/$1 ]; then
			#directory already exists prompt user to overwrite
			sevice_overwrite=$(whiptail --radiolist --title "Deployment Option" --notags \
				"$1 was already created before, use [SPACEBAR] to select redeployment configuation" 20 78 12 \
				"none" "Use recent config" "ON" \
				"env" "Preserve Environment and Config files" "OFF" \
				"full" "Pull config from template" "OFF" \
				3>&1 1>&2 2>&3)

			case $sevice_overwrite in

			"full")
				echo "...pulled full $1 from template"
				rsync -a -q .templates/$1/ services/$1/ --exclude 'build.sh'
				;;
			"env")
				echo "...pulled $1 excluding env file"
				rsync -a -q .templates/$1/ services/$1/ --exclude 'build.sh' --exclude '$1.env' --exclude '*.conf'
				;;
			"none")
				echo "...$1 service not overwritten"
				;;

			esac

		else
			mkdir ./services/$1
			echo "...pulled full $1 from template"
			rsync -a -q .templates/$1/ services/$1/ --exclude 'build.sh'
		fi


	#if an env file exists check for timezone
	[ -f "./services/$1/$1.env" ] && timezones ./services/$1/$1.env

	#add new line then append service
	echo "" >>docker-compose.yml
	cat $service >>docker-compose.yml

	#test for post build
	if [ -f ./.templates/$1/build.sh ]; then
		chmod +x ./.templates/$1/build.sh
		bash ./.templates/$1/build.sh
	fi

	#test for directoryfix.sh
	if [ -f ./.templates/$1/directoryfix.sh ]; then
		chmod +x ./.templates/$1/directoryfix.sh
		echo "...Running directoryfix.sh on $1"
		bash ./.templates/$1/directoryfix.sh
	fi

	#make sure terminal.sh is executable
	[ -f ./services/$1/terminal.sh ] && chmod +x ./services/$1/terminal.sh

}

#---------------------------------------------------------------------------------------------------
# Project updates
echo "Checking for project update"
# git fetch origin main

if [ $(git status | grep -c "Your branch is up to date") -eq 1 ]; then
	#delete .outofdate if it exisist
	[ -f .outofdate ] && rm .outofdate
	echo "Project is up to date"

else
	echo "An update is available for the project"
	if [ ! -f .outofdate ]; then
		whiptail --title "Project update" --msgbox "An update is available for the project\nYou will not be reminded again until you next update" 8 78
		touch .outofdate
	fi
fi

#---------------------------------------------------------------------------------------------------
# Menu system starts here
# Display main menu
mainmenu_selection=$(whiptail --title "Main Menu" --menu --notags \
	"" 20 78 12 -- \
	"install" "Install Docker & Docker-compose" \
	"build" "Build LMDS Stack" \
	"commands" "Docker commands" \
	"misc" "Miscellaneous commands" \
	"update" "Update LMDS Stack" \
	"update_compose" "Update Docker-compose" \
	"backup" "Backup and Restore LMDS" \
	"earn" "Earn \$ with LMDS" \
	3>&1 1>&2 2>&3)


case $mainmenu_selection in
#MAINMENU Install docker  ------------------------------------------------------------
"install")
	#sudo apt update && sudo apt upgrade -y ;;

	if command_exists docker; then
		echo -e "     "
		echo -e "\e[30;48;5;82m    Docker already installed\e[0m"
	else

		echo -e "     "
		echo -e "\e[33;1m    Installing Docker - please wait\e[0m"
		curl -fsSL https://get.docker.com | sh &> /dev/null
		sudo usermod -aG docker $USER &> /dev/null
		# backporting libseccomp to prevent issues bug 8,9,10 and 11
        # Releases : https://github.com/seccomp/libseccomp/releases
                wget http://ftp.us.debian.org/debian/pool/main/libs/libseccomp/libseccomp2_2.5.1-1_armhf.deb  &> /dev/null
                sudo dpkg -i libseccomp2_2.5.1-1_armhf.deb &> /dev/null
                sudo rm libseccomp2_2.5.1-1_armhf.deb &> /dev/null
		echo -e "\e[32;1m    Docker Installed\e[0m"

	fi

	if command_exists docker-compose; then
		echo -e "\e[30;48;5;82m   Docker-compose already installed\e[0m"
	else
		echo -e "\e[33;1m    Installing docker-compose - please wait\e[0m"
		sudo apt install -y docker-compose &> /dev/null
		echo -e "\e[32;1m    Docker-compose Installed\e[0m"
		echo -e "     "
	fi

	if (whiptail --title "Restart Required" --yesno "It is recommended that you restart your device now. User (pi) was added to the (docker) user group for this to take effect logout and log back in or reboot. Select yes to do so now" 20 78); then
		sudo reboot
	fi
	;;
	#MAINMENU Build stack ------------------------------------------------------------
"build")

	title=$'Container Selection'
	message=$'Use the [SPACEBAR] to select which containers you would like to use'
	entry_options=()

	#check architecture and display appropriate menu
	if [ $(echo "$sys_arch" | grep -c "arm") ]; then
		keylist=("${armhf_keys[@]}")
	else
		echo "your architecture is not supported yet"
		exit
	fi

	#loop through the array of descriptions
	for index in "${keylist[@]}"; do
		entry_options+=("$index")
		entry_options+=("${cont_array[$index]}")

		#check selection
		if [ -f ./services/selection.txt ]; then
			[ $(grep "$index" ./services/selection.txt) ] && entry_options+=("ON") || entry_options+=("OFF")
		else
			entry_options+=("OFF")
		fi
	done

	container_selection=$(whiptail --title "$title" --notags --separate-output --checklist \
		"$message" 20 78 12 -- "${entry_options[@]}" 3>&1 1>&2 2>&3)

	mapfile -t containers <<<"$container_selection"

	#if no container is selected then dont overwrite the docker-compose.yml file
	if [ -n "$container_selection" ]; then
		touch docker-compose.yml
		echo "version: '2'" >docker-compose.yml
		echo "services:" >>docker-compose.yml

		#set the ACL for the stack
		#docker_setfacl

		# store last sellection
		[ -f ./services/selection.txt ] && rm ./services/selection.txt
		#first run service directory wont exist
		[ -d ./services ] || mkdir services
		touch ./services/selection.txt
		#Run yml_builder of all selected containers
		for container in "${containers[@]}"; do
			echo "Adding $container container"
			yml_builder "$container"
			echo "$container" >>./services/selection.txt
		done

		# add custom containers
		if [ -f ./services/custom.txt ]; then
			if (whiptail --title "Custom Container detected" --yesno "custom.txt has been detected do you want to add these containers to the stack?" 20 78); then
				mapfile -t containers <<<$(cat ./services/custom.txt)
				for container in "${containers[@]}"; do
					echo "Adding $container container"
					yml_builder "$container"
				done
			fi
		fi

		echo "docker-compose successfully created"
		echo -e "run \e[104;1mdocker-compose up -d\e[0m to start the stack"
	else

		echo "Build cancelled"

	fi
	;;
	#MAINMENU Docker commands -----------------------------------------------------------
"commands")

	docker_selection=$(
		whiptail --title "Docker commands" --menu --notags \
			"Shortcut to common docker commands" 20 78 12 -- \
			"aliases" "Add LMDS_up and LMDS_down aliases" \
			"start" "Start stack" \
			"restart" "Restart stack" \
			"stop" "Stop stack" \
			"stop_all" "Stop any running container regardless of stack" \
			"pull" "Update all containers" \
			"prune_volumes" "Delete all stopped containers and docker volumes" \
			"prune_images" "Delete all images not associated with container" \
			3>&1 1>&2 2>&3
	)

	case $docker_selection in
	"start") ./scripts/start.sh ;;
	"stop") ./scripts/stop.sh ;;
	"stop_all") ./scripts/stop-all.sh ;;
	"restart") ./scripts/restart.sh ;;
	"pull") ./scripts/update.sh ;;
	"prune_volumes") ./scripts/prune-volumes.sh ;;
	"prune_images") ./scripts/prune-images.sh ;;
	"aliases")
		touch ~/.bash_aliases
		if [ $(grep -c 'LMDS' ~/.bash_aliases) -eq 0 ]; then
			echo ". ~/LMDS/.bash_aliases" >>~/.bash_aliases
			echo "added aliases"
		else
			echo "aliases already added"
		fi
		source ~/.bashrc
		echo "aliases will be available after a reboot"
		;;
	esac
	;;

	#Update Docker-compose --------------------------------------------------------$
"update_compose")
	if command_exists docker-compose; then
		 ./scripts/update_compose.sh
	else
		echo -e "     "
		echo -e "\e[33;1m   Docker-compose not installed yet.\e[0m"
		echo -e "\e[32;1m   Install it first then update if needed.\e[0m"
		echo -e "     "
	fi
 ;;

       #Earn with LMDS ---------------------------------------------------------------------
"earn")
#Add x86 to crontab so it rund after reboot 
        function addtocrontab () {
          local frequency=$1
          local command=$2
          local job="$frequency $command"
        cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
        }
        addtocrontab "@reboot" "docker run --privileged --rm tonistiigi/binfmt --install x86_64"
# Earn options 
	earn_sellection=$(
		whiptail --title "Earn with LMDS" --menu --notags \
			"Current Earning Options supported by LMDS" 20 78 12 -- \
			"honeygain" "HoneyGain - Docker container" \
			"iproyal" "IPRoyal - Docker container" \
			"peer2profit" "Peer2Profit - Docker container" \
			"earnapp" "EarnApp - Native Linux App" \
			3>&1 1>&2 2>&3
	)

	case $earn_sellection in
	"earnapp")
		if (whiptail --title "EarnApp" --yesno "Native Linux App not a container. \nnThis App will use some of your Internet bandwidth to generate profit. \nEarnings depend on your geographical location rather than Internet speed or anything else. \n\nFor more details on how does it work visit: https://greenfrognest.com/EarnAppLMDS.php \n\nThis is not CPU intensive process, therefore can be run on low powered devices like Raspberry Pi \n\nCreate an acount before continuing at: \nhttps://earnapp.com/i/snq8y4m" 20 70)
		then 
			sudo ./scripts/earnlmds.sh
fi
;;
	"honeygain")
honeyemail=$(whiptail --inputbox "Steps: \n1. Register at: https://r.honeygain.me/GREENFDEC8 \n2. Enter Email used during registration to the filed below\n3. OK \n\nHoneygain is a Docker based application that can be run alongsite other containers deployed on LMDS. App will use some of your Internet bandwidth to generate profit. Earnings depend on your geographical location rather than Internet speed or anything else. \n\nFor more details on how does it work visit: https://greenfrognest.com/HoneyGainLMDS.php \n\nEnter Email you registered with Honeygain" 22 80 your@email --title "Honeygain Container Setup" 3>&1 1>&2 2>&3)
honeypass=$(whiptail --inputbox "Steps: \n4. Enter Honeygain password you use on the website \n5. OK" 15 60 password --title "Honeygain Container Setup" 3>&1 1>&2 2>&3) 
honeyname=$(whiptail --inputbox "Steps: \n6. Enter a container name for deployment \n7. OK" 15 60 honeygain01 --title "Honeygain Container Setup" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ] && [ -z "$honeyemail" ]
	then
		echo -e "\e[36;1mCancel - Container not created\e[0m"
	else
		#echo $honeyemail $honeypass $honeyname
		if [ -d services/honeygain ]
		then
			echo -e "\e[36;1mHoneygain already deployed - check docker-compose.yml\e[0m"
			echo -e "\e[36;1mIf missing, edit and copy definitions from ~/LMDS/services/honeygain/service.yml\e[0m"
		else
			mkdir -p services/honeygain
			mkdir .templates/honeygain
			touch .templates/honeygain/service.yml
			cat > .templates/honeygain/service.yml <<EOF
  $honeyname:
    container_name: $honeyname
    image: honeygain/honeygain
    command:  -tou-accept -email $honeyemail -pass $honeypass -device $honeyname
    restart: unless-stopped
EOF
			cat .templates/honeygain/service.yml >> docker-compose.yml
			cp .templates/honeygain/service.yml services/honeygain/
			cat >> services/selection.txt <<EOF 
honeygain
EOF
			docker run --privileged --rm tonistiigi/binfmt --install x86_64  &> /dev/null
			echo -e "\e[36;1mOK - Container definition added to the docker-compose file\e[0m"
			echo -e "\e[36;1mrun \e[104;1mdocker-compose up -d\e[0m to create container\e[0m"
			fi	
	fi
;;

	"iproyal")
iproyalemail=$(whiptail --inputbox "Steps: \n1. Register at: https://iproyal.com/pawns?r=lmds \n2. Enter Email used during registration to the filed below\n3. OK \n\nIPRoyal Pown is a Docker based application that can be run alongsite other containers deployed on LMDS. App will use some of your Internet bandwidth to generate profit. Earnings depend on your geographical location rather than Internet speed or anything else. \n\nFor more details on how does it work visit: https://greenfrognest.com/IPRoyalLMDS.php \n\nEnter Email you registered with IPRoyals" 22 80 your@email --title "IPRoyal Container Setup" 3>&1 1>&2 2>&3)
iproyalpass=$(whiptail --inputbox "Steps: \n4. Enter IPRoyal password you use on the website \n5. OK" 15 60 password --title "IPRoyal Container Setup" 3>&1 1>&2 2>&3) 
iproyalname=$(whiptail --inputbox "Steps: \n6. Enter a container name for deployment \n7. OK" 15 60 IPRoyal01 --title "IPRoyal Container Setup" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ] && [ -z "$iproyalemail" ]
	then
	echo -e "\e[36;1mCancel - Container not created\e[0m"
else
		#echo $honeyemail $honeypass $honeyname
		if [ -d services/iproyal ]
		then
			echo -e "\e[36;1mIPRoyal already deployed - check docker-compose.yml\e[0m"
			echo -e "\e[36;1mIf missing, edit and copy definitions from ~/LMDS/services/iproyal/service.yml\e[0m"
		else
			mkdir -p services/iproyal
			mkdir .templates/iproyal
			touch .templates/iproyal/service.yml
			cat > .templates/iproyal/service.yml <<EOF
  $iproyalname:
    container_name: $iproyalname
    image: iproyal/pawns-cli
    command:  -accept-tos -email=$iproyalemail -password=$iproyalpass -device-name=$iproyalname 
    restart: unless-stopped
EOF

			cat .templates/iproyal/service.yml >> docker-compose.yml
			cp .templates/iproyal/service.yml services/iproyal/
			cat >> services/selection.txt <<EOF 
iproyal
EOF
			echo -e "\e[36;1mOK - Container definition added to the docker-compose file\e[0m"
			echo -e "\e[36;1mrun \e[104;1mdocker-compose up -d\e[0m to create container\e[0m"
			fi
	fi
;;

	"peer2profit")
peeremail=$(whiptail --inputbox "Steps: \n1. Register at: https://p2pr.me/164528477962110dab05459 \n2. Enter Email used in registration to the filed below\n3. OK \n\nPeer2Profit is a Docker based application that can be run alongsite other containers deployed on LMDS. App will use some of your Internet bandwidth to generate profit. Earnings depend on your geographical location rather than Internet speed or anything else. \n\nFor more details on how does it work visit: https://greenfrognest.com/Peer2ProfitLMDS.php \n\nProvide Email you registered with Peer2Profit" 22 80 your@email --title "Peer2Profit Container Setup" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]
	then
		if [ -d services/peer2profit ]
		then
			echo -e "\e[36;1mPeer2Profit already deployed - check docker-compose.yml\e[0m"
			echo -e "\e[36;1mIf missing, edit and copy definitions from ~/LMDS/services/peer2profit/service.yml\e[0m"
		else
			mkdir -p services/peer2profit
			mkdir .templates/peer2profit
			touch .templates/peer2profit/service.yml
			cat > .templates/peer2profit/service.yml <<EOF
  peer2profit01:
    container_name: peer2profit01
    image: peer2profit/peer2profit_x86_64:latest
    environment:
      P2P_EMAIL: ${peeremail}
    restart: unless-stopped
EOF
			cat .templates/peer2profit/service.yml >> docker-compose.yml
			cp .templates/peer2profit/service.yml services/peer2profit/
			cat >> services/selection.txt <<EOF 
peer2profit
EOF
			docker run --privileged --rm tonistiigi/binfmt --install x86_64 &> /dev/null
			echo -e "\e[36;1mOK - Container definition added to the docker-compose file\e[0m"
			echo -e "\e[36;1mrun \e[104;1mdocker-compose up -d\e[0m to create container\e[0m"
			fi
	else
    	echo -e "\e[36;1mCancel - Container not created\e[0m"
	fi
		;;
	esac
	;;


	#Backup menu ---------------------------------------------------------------------
"backup")
	backup_selection=$(
		whiptail --title "Backup and Restore LMDS" --menu --notags \
			"While configuring rclone to work with Google Drive (option 12), make sure you give a folder name of (gdrive). Be carefull when you restore from backup. All containers will be stop and their settings overwritten with what is in your last backup file. All containers will start automatically after restore is done." 20 78 12 -- \
			"rclone" "Install rclone and configure (gdrive) for backup" \
			"rclone_backup" "Backup LMDS" \
			"rclone_restore" "Restore LMDS" \
			3>&1 1>&2 2>&3
	)

	case $backup_selection in
	"rclone") 
    if dpkg-query -W rclone | grep -w 'rclone' &> /dev/null && rclone listremotes | grep -w 'gdrive:' >> /dev/null ; then

        #rclone installed and gdrive exist
			echo -e "\e[32m=====================================================================================\e[0m"
			echo -e "\e[36;1m    rclone installed and gdrive configured, go to Backup or Restore \e[0m" 
   		    echo -e "\e[32m=====================================================================================\e[0m"
	else
		sudo apt install -y rclone
			echo -e "\e[32m=====================================================================================\e[0m"
			echo -e "     Please run \e[32;1mrclone config\e[0m and create remote \e[34;1m(gdrive)\e[0m for backup   "
			echo -e "     "
			echo -e "     Do as folows:"
			echo -e "      [n] [gdrive] [13] [Enter] [Enter] [1] [Enter] [Enter] [n] [n]"
			echo -e "      [Copy link from SSH console and paste it into the browser]"
			echo -e "      [Login to your google account]"
			echo -e "      [Copy token from Google and paste it into the SSH console]"
			echo -e "      [n] [y] [q]"
			echo -e "\e[32m=====================================================================================\e[0m"
	fi
		;;

	"rclone_backup") ./scripts/rclone_backup.sh ;;
	"rclone_restore") ./scripts/rclone_restore.sh ;;

	esac
	;;

	#MAINMENU Misc commands------------------------------------------------------------
"misc")
	misc_sellection=$(
		whiptail --title "Miscellaneous Commands" --menu --notags \
			"Some helpful commands" 20 78 12 -- \
			"swap" "Disable swap by uninstalling swapfile" \
			"swappiness" "Disable swap by setting swappiness to 0" \
			"log2ram" "install log2ram to decrease load on sd card, moves /var/log into ram" \
			3>&1 1>&2 2>&3
	)

	case $misc_sellection in
	"swap")
		sudo dphys-swapfile swapoff
		sudo dphys-swapfile uninstall
		sudo update-rc.d dphys-swapfile remove
		sudo systemctl disable dphys-swapfile
		#sudo apt-get remove dphys-swapfile
		echo "Swap file has been removed"
		;;
	"swappiness")
		if [ $(grep -c swappiness /etc/sysctl.conf) -eq 0 ]; then
			echo "vm.swappiness=0" | sudo tee -a /etc/sysctl.conf
			echo "updated /etc/sysctl.conf with vm.swappiness=0"
		else
			sudo sed -i "/vm.swappiness/c\vm.swappiness=0" /etc/sysctl.conf
			echo "vm.swappiness found in /etc/sysctl.conf update to 0"
		fi

		sudo sysctl vm.swappiness=0
		echo "set swappiness to 0 for immediate effect"
		;;
	"log2ram")
		if [ ! -d ~/log2ram ]; then
			git clone https://github.com/azlux/log2ram.git ~/log2ram
			chmod +x ~/log2ram/install.sh
			pushd ~/log2ram && sudo ./install.sh
			popd
		else
			echo "log2ram already installed"
		fi
		;;
	esac
	;;


"update")
	echo "Pulling latest project file from Github.com ---------------------------------------------"
	git pull origin main
	echo "git status ------------------------------------------------------------------------------"
	git status
	;;

*) ;;

esac

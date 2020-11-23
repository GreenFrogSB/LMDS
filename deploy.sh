#!/bin/bash

#make sure you are in right directory
pushd ~/LDS

#Menu Display Name
#[CONTAINER NAME]="MENU Text"
declare -A cont_array=(
	[portainer]="Portainer - GUI Docker Manager"
	[sonarr]="Sonarr"
	[radarr]="Radarr"
	[lidarr]="Lidarr"
	[bazarr]="Bazarr"
	[jackett]="Jackett"
	[deluge]="Deluge - Torrent Client"
	[qbittorrent]="qBittorrent - Torrent Client"
	[transmission]="Transmission - Torrent Client"
	[emby]="Emby - Media manager like Plex"
	[embystat]="EmbyStat - Statistics for Emby"
	[nginx]="Ngnix - Web Server with links to all servises deployed"
	[pihole]="Pi-Hole - Private DNS sinkhole"
)

# CONTAINER keys
declare -a armhf_keys=(
	"portainer"
	"sonarr"
	"radarr"
	"lidarr"
	"bazarr"
	"jackett"
	"deluge"
	"qbittorrent"
	"pihole"
	"emby"
	"embystat"
	"transmission"
	"nginx"
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
	[ -d ./backups ] || mkdir ./backups

	#give current user rwx on the volumes and backups
	[ $(getfacl ./volumes | grep -c "default:user:$USER") -eq 0 ] && sudo setfacl -Rdm u:$USER:rwx ./volumes
	[ $(getfacl ./backups | grep -c "default:user:$USER") -eq 0 ] && sudo setfacl -Rdm u:$USER:rwx ./backups
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

function command_exists() {
	command -v "$@" >/dev/null 2>&1
}

#function copies the template yml file to the local service folder and appends to the docker-compose.yml file
function yml_builder() {

	service="services/$1/service.yml"

	[ -d ./services/ ] || mkdir ./services/

		if [ -d ./services/$1 ]; then
			#directory already exists prompt user to overwrite
			sevice_overwrite=$(whiptail --radiolist --title "Overwrite Option" --notags \
				"$1 service directory has been detected, use [SPACEBAR] to select you overwrite option" 20 78 12 \
				"none" "Do not overwrite" "ON" \
				"env" "Preserve Environment and Config files" "OFF" \
				"full" "Pull full service from template" "OFF" \
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
echo "checking for project update"
git fetch origin master

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
	"install" "Install Docker" \
	"build" "Build LDS Stack" \
	"commands" "Docker commands" \
	"misc" "Miscellaneous commands" \
	"update" "Update LDS Stack" \
	3>&1 1>&2 2>&3)

#   "backup" "Backup options" \ # work in progress

case $mainmenu_selection in
#MAINMENU Install docker  ------------------------------------------------------------
"install")
	#sudo apt update && sudo apt upgrade -y ;;

	if command_exists docker; then
		echo -e "\e[30;48;5;82mdocker already installed\e[0m"
	else
		echo -e "\e[33m;1Instaling Docker - please wait\e[0m"
		curl -fsSL https://get.docker.com | sh &> /dev/null
		sudo usermod -aG docker $USER &> /dev/null
		echo -e "\e[32;1mDocker Installed\e[0m"

	fi

	if command_exists docker-compose; then
		echo -e "\e[30;48;5;82mdocker-compose already installed\e[0m"
	else
		echo -e "\e[33;1mInstaling docker-compose - please wait\e[0m"
		sudo apt install -y docker-compose &> /dev/null
		echo -e "\e[32;1mDocker-compose Installed\e[0m"
	fi

	if (whiptail --title "Restart Required" --yesno "It is recommended that you restart your device now. User (pi) was added to the (docker) user group for this to take effect logout and log back in or reboot. Select yes to do so now" 20 78); then
		sudo reboot
	fi
	;;
	#MAINMENU Build stack ------------------------------------------------------------
"build")

	title=$'Container Selection'
	message=$'Use the [SPACEBAR] to select which containers you would like to install'
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
			"aliases" "Add LDS_up and LDS_down aliases" \
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
		if [ $(grep -c 'LDS' ~/.bash_aliases) -eq 0 ]; then
			echo ". ~/LDS/.bash_aliases" >>~/.bash_aliases
			echo "added aliases"
		else
			echo "aliases already added"
		fi
		source ~/.bashrc
		echo "aliases will be available after a reboot"
		;;
	esac
	;;
	#Backup menu ---------------------------------------------------------------------
"backup")
	backup_sellection=$(whiptail --title "Backup Options" --menu --notags \
		"Select backup option" 20 78 12 -- \
		"dropbox-uploader" "Dropbox-Uploader" \
		"rclone" "google drive via rclone" \
		3>&1 1>&2 2>&3)

	case $backup_sellection in

	"dropbox-uploader")
		if [ ! -d ~/Dropbox-Uploader ]; then
			git clone https://github.com/andreafabrizi/Dropbox-Uploader.git ~/Dropbox-Uploader
			chmod +x ~/Dropbox-Uploader/dropbox_uploader.sh
			pushd ~/Dropbox-Uploader && ./dropbox_uploader.sh
			popd
		else
			echo "Dropbox uploader already installed"
		fi

		#add enable file for Dropbox-Uploader
		[ -d ~/LDS/backups ] || sudo mkdir -p ~/LDS/backups/
		sudo touch ~/LDS/backups/dropbox
		;;
	"rclone")
		sudo apt install -y rclone
		echo "Please run 'rclone config' to configure the rclone google drive backup"

		#add enable file for rclone
		[ -d ~/LDS/backups ] || sudo mkdir -p ~/LDS/backups/
		sudo touch ~/LDS/backups/rclone
		;;
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
	git pull origin master
	echo "git status ------------------------------------------------------------------------------"
	git status
	;;

*) ;;

esac

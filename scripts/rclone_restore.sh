# check if rclone is installed and gdrive: configured 
	if dpkg-query -W rclone | grep -w 'rclone' >> /dev/null && rclone listremotes | grep -w 'gdrive:' >> /dev/null ; then
		
    	#create backup folder
		[ -d ~/LMDS/LMDSBackups ] || sudo mkdir -p ~/LMDS/LMDSBackups/

		#change permissions to pi
		sudo chown pi:pi ~/LMDS/LMDSBackups
		
		# resync from gdrive to ~/LMDS/LMDSBackups
		rclone sync -P gdrive:/LMDSBackups/ --include "/LMDSbackup*" ./LMDSBackups > ./LMDSBackups/rclone_sync_log
	    
		# no check if online - mayve some another time just assume it is online 
		echo -e "\e[32m=====================================================================================\e[0m"
		echo -e "\e[36;1m    Sync with Google Drive \e[32;1msucessfull\e[0m"

		# check for recent backup file 
	 	restorefile="$(ls -t1 ~/LMDS/LMDSBackups/LMDS* | head -1 | grep -o 'LMDSbackup.*')"
		echo -e "\e[36;1m    Restoring \e[32;1m $restorefile\e[0m"
 
		# stop all container
		echo -e "\e[36;1m    Stopping all containers\e[0m"
		sudo docker stop $(docker ps -a -q) 

		# owerwrite all container
		echo -e "\e[36;1m    Restoring all containers from backup\e[0m"
		sudo tar -xzf "$(ls -t1 ~/LMDS/LMDSBackups/LMDS* | head -1)" -C ~/LMDS/

		# start all containers from docker-comose/yml
		echo -e "\e[36;1m    Starting all containers\e[0m"
		docker-compose up -d

		sleep 7
		echo -e "\e[36;1m    Restore completed\e[0m"
        echo -e "\e[32m=====================================================================================\e[0m"

	else
		echo -e "\e[32m=====================================================================================\e[0m"
		echo -e "\e[36;1m    \e[34;1mrclone\e[0m\e[36;1m not installed or \e[34;1m(gdrive)\e[0m\e[36;1m not configured \e[32;1mchecking local backup\e[0m"

		if ls ~/LMDS/LMDSBackups/ | grep -w 'LMDSbackup' >> /dev/null ; then

			# local files restore
			echo -e "\e[36;1m    Local backup found \e[32;1m"$(ls -t1 ~/LMDS/LMDSBackups/LMDS* | head -1)"\e[0m"

			# stop all container
			echo -e "\e[36;1m    Stopping all containers\e[0m"
			sudo docker stop $(docker ps -a -q) 

			# owerwrite all container
			echo -e "\e[36;1m    Restoring all containers from local backup\e[0m"
			sudo tar -xzf "$(ls -t1 ~/LMDS/LMDSBackups/LMDS* | head -1)" -C ~/LMDS/

			# start all containers from docker-comose/yml
			echo -e "\e[36;1m    Starting all containers\e[0m"
			docker-compose up -d

			sleep 7
			echo -e "\e[36;1m    Restore completed \e[0m"
     		echo -e "\e[32m=====================================================================================\e[0m"
		else
		        echo -e "                                                             "
		        echo -e "            \e[41m    ==============================    \e[0m"
    			echo -e "            \e[41m    NO LOCAL BACKUP FILES FOUND!!!    \e[0m"
				echo -e "            \e[41m    ==============================    \e[0m"
				echo -e "                                                             "
			echo -e "\e[32m=====================================================================================\e[0m"
		fi

	fi

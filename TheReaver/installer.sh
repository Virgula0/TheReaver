#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "[*] You must run it as root" 2>&1
  exit 1
fi
printf "[*] Creating directory\n";
command mkdir /usr/share/thereaver/;
printf "[*] Giving permissions\n";
command chmod 777 -R /usr/share/thereaver/;
printf "[*] Installing thereaver\n";
command cp TheReaver.sh /usr/share/thereaver/thereaver.sh;
command cp thereaverchecksum.txt /usr/share/thereaver/thereaverchecksum.txt;
command cp known_pins.db /usr/share/thereaver/known_pins.db;
command chmod 777 -R /usr/share/thereaver;
printf "[*] Finishing\n";
command printf '#!/bin/bash\ncommand /usr/share/thereaver/thereaver.sh;' > /usr/local/bin/thereaver;
command chmod 777 /usr/local/bin/thereaver;
printf "[*] Done\n";
printf "[!] Note that 3WIFI WPS PIN Generator files weren't installed. So you have to make a manual local copy of it and access it manually every time.\n";

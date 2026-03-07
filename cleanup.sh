#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

pacLock="/var/lib/pacman/db.lck"

if [ -f $pacLock ]; then
        echo -e "${RED}pacman is running, aborting${RESET}"
        echo -e "${CYAN}lock at:${RESET}" $pacLock
        ps aux | grep pacman
        exit 1
fi
 
echo -e "${GREEN}===Updating Pacman===${RESET}"
sudo pacman -Syu --noconfirm
 
echo -e "${GREEN}===Updating Yay===${RESET}"
yay -Syu --noconfirm
 
echo -e "${GREEN}===Updating Flatpak===${RESET}"
sudo flatpak update --noninteractive
echo "all updated"

echo -e "${YELLOW}Remove Cache + Orphans? [y/N]:${RESET}"        
read -r cacheRM
if [[ "$cacheRM" = Y || "$cacheRM" = y ]]; then       
        echo -e "${GREEN}===Removing Cache===${RESET}"
        sudo pacman -Scc --noconfirm
        
        echo -e "${GREEN}===Removing Orphan Libraries===${RESET}"
        sudo pacman -Qtdq --noconfirm
fi

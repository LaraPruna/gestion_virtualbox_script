#!/bin/bash

#Esta función comprueba si eres root.
#No acepta argumentos
#Devuelve 0 si eres root y 1 si no lo eres.
function f_eres_root {
	if [[ $(whoami) = 'root' ]]
		then
			return 0
		else
			return 1
	fi
}

#Esta función comprueba si un paquete está instalado o no.
#Acepta como argumento el nombre del paquete.
#Devuelve 0 si está instalado y 1 si no lo está.
function f_esta_instalado {
	if [[ $(dpkg -l | egrep -i $1) ]]
		then
			return 0
		else
			return 1
	fi
}

#Esta función instala el paquete Virtualbox en Debian 10.
#No acepta argumentos de entrada, y necesitas ser root para ejecutarla.
#Devuelve 0 una vez instalado el paquete de virtualbox, 1 si no eres root, 2 si virtualbox ya está instalado,
#y 3 si ha habido algún error en la instalación.
function f_instalar_virtualbox {
	if [[ $(f_eres_root;echo $?) = 0 ]]; then
		if [[ $(f_esta_instalado virtualbox;echo $?) = 1 ]]; then
			echo 'Añadiendo repositorio...'
			sed -i '$a deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib' /etc/apt/sources.list
			if [[ $(f_esta_instalado gnupg2;echo $?) = 1 ]]; then
				echo 'Actualizando repositorios...'
				apt update -y &> /dev/null && apt upgrade -y &> /dev/null
				echo 'Instalando gnupg2...'
				apt-get install -y gnupg2 &> /dev/null
			fi
			echo 'Añadiendo claves de Oracle...'
			wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add - &> /dev/null
			wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - &> /dev/null
			echo 'Instalando virtualbox...'
			echo 'La instalación puede durar varios minutos.'
			apt-get install -y virtualbox-6.0 &> /dev/null
			if [[ $(f_esta_instalado virtualbox;echo $?) = 0 ]]; then
				echo 'Paquete instalado.'
				return 0
			else
				echo 'No se pudo instalar el paquete.'
				return 3
			fi
		else
			echo 'Virtualbox ya está instalado.'
			return 2
		fi
	else
		echo 'No eres root.'
		return 1
	fi
}

#Esta función muestra información sobre las máquinas virtuales registradas. Mediante un menú guardado
#en otro fichero y mostrado a través de esta función, el usuario podrá elegir el tipo de información
#que busca en particular.
#No acepta argumentos de entrada.
function f_vminfo_ {
	cat ./info.txt
	read opcion
	while [[ $opcion != 16 ]]; do
		if [[ $opcion = 1 ]]; then
			vboxmanage list vms
		elif [[ $opcion = 2 ]]; then
                        vboxmanage list runningvms
		elif [[ $opcion = 3 ]]; then
                        vboxmanage list ostypes
		elif [[ $opcion = 4 ]]; then
                        vboxmanage list intnets
		elif [[ $opcion = 5 ]]; then
                        vboxmanage list bridgedifs
		elif [[ $opcion = 6 ]]; then
                        vboxmanage list hostonlyifs
		elif [[ $opcion = 7 ]]; then
                        vboxmanage list natnets
		elif [[ $opcion = 8 ]]; then
                        vboxmanage list dhcpservers
		elif [[ $opcion = 9 ]]; then
                        vboxmanage list hostinfo
		elif [[ $opcion = 10 ]]; then
                        vboxmanage list hdds
		elif [[ $opcion = 11 ]]; then
                        vboxmanage list dvds
		elif [[ $opcion = 12 ]]; then
                        vboxmanage list usbhost
		elif [[ $opcion = 13 ]]; then
                        vboxmanage list systemproperties
		elif [[ $opcion = 14 ]]; then
                        vboxmanage list extpacks
		elif [[ $opcion = 15 ]]; then
                        vboxmanage list groups
		else
			echo 'Error. Introduce una opción del menú.'
		fi
		cat ./info.txt
	        read opcion
	done
}



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
#No acepta argumentos de entrada.
#
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

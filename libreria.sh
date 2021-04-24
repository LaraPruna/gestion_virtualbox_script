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

#Esta función instala un paquete.
#Acepta como argumento el nombre del paquete.
#Devuelve 0 al instalar el paquete, 1 si no eres root y 2 si el paquete
#ya está instalado.
function f_instalar {
	if [[ $(f_esta_instalado $1;echo $?) = 1 ]]
		then
			if [[ $(f_eres_root;echo $?) = 0 ]]
				then
					apt-get install &>/dev/null -y $1 > /dev/null
					return 0
				else
					echo 'No eres root'
					return 1
			fi
		else
			echo 'El paquete ya está instalado'
			return 2
	fi
}


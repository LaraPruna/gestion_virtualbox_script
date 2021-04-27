#!/bin/bash

. ./libreria.sh

if [[ $(f_eres_root;echo $?) = 0 ]]; then
        echo 'Ejecuta el programa con tu usuario.'
        exit
fi

echo 'Inicio del programa. Comprobando el estado del paquete virtualbox...'
if [[ $(f_esta_instalado virtualbox;echo $?) = 1 ]]; then
	echo 'No tienes instalado Virtualbox. ¿Quieres instalarlo? (s/n)'
	read res1
	if [[ $res1 = 's' ]]; then
		if [[ $(f_eres_root;echo $?) = 1 ]]; then
			sudo su
		fi
		f_instalar_virtualbox
		if [[ $(echo $?) = 3 ]]; then
			exit
		fi
	else
		echo 'Fin del programa.'
		exit
	fi
fi
cat ./menu.txt
read opcion
while [[ $opcion != 14 ]]; do
	if [[ $opcion = 1 ]]; then
		f_vmsinfo
	elif [[ $opcion = 2 ]]; then
		echo 'Introduce el nombre de la máquina virtual:'
		read mv1
		f_vminfo $mv1
	elif [[ $opcion = 3 ]]; then
		f_crearvm
	else
		echo 'Error. Introduce una opción del menú.'
	fi
	cat ./menu.txt
	read opcion
done

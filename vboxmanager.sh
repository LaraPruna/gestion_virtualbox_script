#!/bin/bash

. ./libreria.sh
set -x
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
if [[ $(f_eres_root;echo $?) = 0 ]]; then
        echo 'Se recomienda entrar como usuario en este programa.'
fi
cat ./menus/mainmenu.txt
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
	elif [[ $opcion = 4 ]]; then
		cat ./menus/registros/registros.txt
		read opcion2
		while [[ $opcion2 != 3 ]]; do
			if [[ $opcion2 = 1 ]]; then
				f_registrarvm
			elif [[ $opcion2 = 2 ]]; then
				f_eliminar_registro_vm
			else
				echo 'Opción incorrecta.'
			fi
			cat ./menus/registros/registros.txt
                	read opcion2
		done
	elif [[ $opcion = 5 ]]; then
		f_movervm
	elif [[ $opcion = 6 ]]; then
		echo 'Introduce el nombre de la máquina virtual que quieres configurar:'
		read vm
		if [[ $(vboxmanage showvminfo $vm &> /dev/null;echo $?) = 0 ]]; then
			cat ./menus/vmconfig/vmconfig.txt
			read opcion2
			while [[ $opcion2 != 10 ]]; do
				if [[ $opcion2 = 1 ]]; then
					f_config_general $vm
				elif [[ $opcion2 = 2 ]]; then
					f_config_sistema $vm
				elif [[ $opcion2 = 3 ]]; then
					f_config_pantalla $vm
				else
					echo 'Opción incorrecta.'
				fi
				cat ./menus/vmconfig/vmconfig.txt
	                        read opcion2
			done
		else
			echo 'No hay ninguna máquina registrada con ese nombre.'
		fi
	else
		echo 'Error. Introduce una opción del menú.'
	fi
	cat ./menus/mainmenu.txt
	read opcion
done

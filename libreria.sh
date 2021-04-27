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

#Mediante esta función, comprobamos la existencia de un directorio.
#Devuelve un 0 si el directorio existe y 1 si no existe.
#Acepta un argumento, que es el directorio que se quiera comprobar.
function f_existe_directorio {
        if [[ -d $1 ]]
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

#Esta función muestra información general sobre las máquinas virtuales registradas. Mediante un menú guardado
#en otro fichero y mostrado a través de esta función, el usuario podrá elegir el tipo de información
#que busca en particular.
#No acepta argumentos de entrada.
function f_vmsinfo {
	cat ./info.txt
	read opcion
	while [[ $opcion != 16 ]]; do
		if [[ $opcion = 1 ]]; then
			if [[ $(vboxmanage list vms | wc -l) = 0 ]]; then
				echo 'No tienes ninguna máquina virtual registrada.'
			else
				echo 'Máquinas virtuales registradas:'
				vboxmanage list vms
			fi
		elif [[ $opcion = 2 ]]; then
			if [[ $(vboxmanage list runningvms | wc -l) = 0 ]]; then
				echo 'No se está ejecutando ninguna máquina virtual en este momento.'
			else
				echo 'Máquinas virtuales en ejecución:'
        	                vboxmanage list runningvms
			fi
		elif [[ $opcion = 3 ]]; then
			echo 'Sistemas operativos disponibles en Virtualbox:'
                        vboxmanage list ostypes
		elif [[ $opcion = 4 ]]; then
			if [[ $(vboxmanage list intnets | wc -l) = 0 ]]; then
				echo 'No se ha encontrado ninguna red interna.'
			else
				echo 'Redes internas:'
	                        vboxmanage list intnets
			fi
		elif [[ $opcion = 5 ]]; then
			if [[ $(vboxmanage list bridgedifs | wc -l) = 0 ]]; then
				echo 'No se ha encontrado ninguna interfaz con adaptador puente disponible.'
			else
				echo 'Interfaces con adaptador puente:'
	                        vboxmanage list bridgedifs
			fi
		elif [[ $opcion = 6 ]]; then
			if [[ $(vboxmanage list hostonlyifs | wc -l) = 0 ]]; then
                                echo 'No se ha encontrado ninguna interfaz de solo anfitrión disponible.'
                        else
                                echo 'Interfaces de solo anfitrión:'
	                        vboxmanage list hostonlyifs
			fi
		elif [[ $opcion = 7 ]]; then
			if [[ $(vboxmanage list natnets | wc -l) = 0 ]]; then
                                echo 'No se ha encontrado ninguna interfaz con NAT.'
                        else
                                echo 'Interfaces con NAT:'
	                        vboxmanage list natnets
			fi
		elif [[ $opcion = 8 ]]; then
			if [[ $(vboxmanage list dhcpservers | wc -l) = 0 ]]; then
                                echo 'No se ha encontrado ningún servidor DHCP disponible.'
                        else
                                echo 'Servidores DHCP:'
	                        vboxmanage list dhcpservers
			fi
		elif [[ $opcion = 9 ]]; then
			echo 'Información sobre el host:'
                        vboxmanage list hostinfo
		elif [[ $opcion = 10 ]]; then
			if [[ $(vboxmanage list hdds | wc -l) = 0 ]]; then
                                echo 'No estás utilizando ningún disco duro en este momento.'
                        else
                                echo 'Discos duros en uso:'
	                        vboxmanage list hdds
			fi
		elif [[ $opcion = 11 ]]; then
			if [[ $(vboxmanage list dvds | wc -l) = 0 ]]; then
                                echo 'No estás utilizando ningún disco de DVD en este momento.'
                        else
                                echo 'Discos de DVD en uso:'
	                        vboxmanage list dvds
			fi
		elif [[ $opcion = 12 ]]; then
			if [[ $(vboxmanage list usbhost | egrep '<none>') ]]; then
                                echo 'No hay ningún dispositivo USB conectado al host en este momento.'
                        else
                                echo 'Dispositivos USB conectados al host:'
	                        vboxmanage list usbhost
			fi
		elif [[ $opcion = 13 ]]; then
			echo 'Configuración general de Virtualbox:'
                        vboxmanage list systemproperties
		elif [[ $opcion = 14 ]]; then
			if [[ $(vboxmanage list extpacks | egrep 'Extension Packs: 0') ]]; then
                                echo 'No tienes instalado ningún paquete de extensión en Virtualbox.'
			else
				echo 'Paquetes de extensión instalados:'
	                        vboxmanage list extpacks
			fi
		elif [[ $opcion = 15 ]]; then
			if [[ $(vboxmanage list groups | wc -l) = 0 ]]; then
                                echo 'No tienes ningún grupo de máquinas virtuales creado.'
                        else
                                echo 'Grupos de máquinas virtuales:'
	                        vboxmanage list groups
			fi
		else
			echo 'Error. Introduce una opción del menú.'
		fi
		cat ./info.txt
	        read opcion
	done
}

#Esta función muestra información sobre una máquina virtual en particular.
#Acepta como argumento de entrada el nombre o la UUID de la máquina virtual.
#Devuelve 0 al mostrar la información y 1 si no se encuentra la máquina.
function f_vminfo {
	if [[ $(vboxmanage showvminfo $1 &> /dev/null; echo $?) = 0 ]]; then
		vboxmanage showvminfo $1
	else
		echo 'Esa máquina no se encuentra registrada.'
	fi
}

#Esta función crea una máquina virtual a partir de la información introducida por el usuario
#mediante un cuestionario.
#No acepta argumentos de entrada.
function f_crearvm {
	echo '¿Cómo quieres llamar a la máquina?'
	read nombre
	echo 'Introduce la ruta del directorio donde quieres guardarla (por defecto, /home/usuario/VirtualBox VMs):'
	read ruta
	if [[ $ruta != $null ]]; then
		while [[ $(cd $ruta;echo $?) = 1 ]]; do
        	        echo 'Ese directorio no existe. Introduce otra ruta:'
        	        read ruta
                	if [[ $ruta = $null ]]; then
	                	continue
                	fi
        	done
	fi
	while [[ $(cd $ruta;echo $?) = 1 ]]; do
		echo 'Ese directorio no existe. Introduce otra ruta:'
		read ruta
		if [[ $ruta = $null ]]; then
                	ruta="/home/usuario/VirtualBox\ VMs/"
	        fi
	done
	echo 'Introduce el nombre del grupo que quieras asignarle a la máquina (por defecto "/"):'
	read grupo
	if [[ $grupo != $null ]]; then
		while [[ $(vboxmanage list groups | egrep $grupo; echo $?) = 1 ]]; do
			echo 'No hay ningún grupo con ese nombre. Introduce otro:'
			read grupo
			if [[ $grupo = $null ]]; then
				continue
			fi
		done
	fi
	echo '¿Qué sistema operativo quieres asignarle a la máquina? (L para mostrar los sistemas operativos disponibles)'
	read os
	if [[ $os = 'L' ]]; then
		vboxmanage list ostypes
		echo '¿Qué sistema operativo quieres asignarle a la máquina? (L para mostrar los sistemas operativos disponibles)'
	        read os
	fi
	while [[ $(vboxmanage list ostypes | egrep $os; echo $?) = 1 ]]; do
		echo 'No hay ningún sistema operativo disponible con ese nombre.'
		echo 'Introduce otro sistema operativo (L para mostrar los sistemas operativos disponibles):'
		read os
		if [[ $os = 'L' ]]; then
			vboxmanage list ostypes
		fi
	done
	echo '¿Quieres registrar la nueva máquina virtual en Virtualbox? (s/n)'
	read reg
	echo 'Creando máquina virtual...'
	if [[ $reg = 's' ]]; then
		if [[ $ruta = $null ]]; then
			if [[ $grupo = $null ]]; then
				vboxmanage createvm --name $nombre --basefolder /home/usuario/VirtualBox\ VMs/ --ostype $os --register
			else
				vboxmanage createvm --name $nombre --basefolder /home/usuario/VirtualBox\ VMs/ --group $grupo --ostype $os --register
			fi
		else
			if [[ $grupo = $null ]]; then
				vboxmanage createvm --name $nombre --basefolder $ruta --ostype $os --register
			else
				vboxmanage createvm --name $nombre --basefolder $ruta --group $grupo --ostype $os --register
			fi
                        echo 'Máquina virtual creada. Puedes configurarla desde el menú principal.'
		fi
	else
		if [[ $ruta = $null ]]; then
			if [[ $grupo = $null ]]; then
				vboxmanage createvm --name $nombre --basefolder /home/usuario/VirtualBox\ VMs/ --ostype $os
			else
				vboxmanage createvm --name $nombre --basefolder /home/usuario/VirtualBox\ VMs/ --group $grupo --ostype $os
			fi
		else
			if [[ $grupo = $null ]]; then
				vboxmanage createvm --name $nombre --basefolder $ruta --ostype $os
			else
				vboxmanage createvm --name $nombre --basefolder $ruta --group $grupo --ostype $os
			fi
		fi
		echo 'Máquina virtual creada. Puedes registrarla y configurarla desde el menú principal.'
	fi
}

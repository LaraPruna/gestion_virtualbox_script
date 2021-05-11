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

#Esta función muestra información general sobre las máquinas virtuales registradas y la configuración
#de VirtualBox. Mediante un menú guardado en otro fichero y mostrado a través de esta función,
#el usuario podrá elegir el tipo de información que busca en particular.
#No acepta argumentos de entrada.
function f_vmsinfo {
	cat ./menus/info.txt
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
		cat ./menus/info.txt
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
	echo 'Introduce la ruta del directorio donde quieres guardarla (por defecto, ~/VirtualBox VMs/):'
	read ruta
	if [[ $ruta != $null ]]; then
		while [[ $(cd $ruta;echo $?) = 1 ]]; do
        	        echo 'Ese directorio no existe. Introduce otra ruta:'
        	        read ruta
                	if [[ $ruta = $null ]]; then
	                	ruta="/home/$USER/VirtualBox\ VMs/"
                	fi
        	done
	fi
	while [[ $(cd $ruta;echo $?) = 1 ]]; do
		echo 'Ese directorio no existe. Introduce otra ruta:'
		read ruta
		if [[ $ruta = $null ]]; then
                	ruta="/home/$USER/VirtualBox\ VMs/"
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
		if [[ $grupo = $null ]]; then
			vboxmanage createvm --name $nombre --basefolder "$ruta" --ostype $os --register
		else
			vboxmanage createvm --name $nombre --basefolder "$ruta" --group $grupo --ostype $os --register
		fi
                echo 'La máquina virtual se ha creado con el hardware mínimo. Puedes configurarla desde el menú principal.'
	else
		if [[ $grupo = $null ]]; then
			vboxmanage createvm --name $nombre --basefolder "$ruta" --ostype $os
		else
			vboxmanage createvm --name $nombre --basefolder "$ruta" --group $grupo --ostype $os
		fi
		echo 'La máquina virtual se ha creado con el hardware mínimo. Puedes registrarla y configurarla desde el menú principal.'
	fi
}

#Esta función registra una máquina virtual en Virtualbox.
#No acepta argumentos de entrada.
#Devuelve 0 al registrar la máquina virtual, 1 si no se ha encontrado la ruta,
#2 si se ha introducido una opción incorrecta y 3 si ha habido algún error durante el registro.
function f_registrarvm {
	echo '¿La máquina virtual se ha guardado en la ruta por defecto o en otro directorio?'
	echo '1) Ruta por defecto'
	echo '2) Otro directorio'
	echo 'Opción:'
	read opcion
	if [[ $opcion = 1 ]]; then
		echo 'Introduce el nombre de la máquina virtual:'
		read vm
		if [[ $(f_existe_directorio /home/$USER/VirtualBox\ VMs/$vm;echo $?) = 0 ]]; then
			vboxmanage registervm /home/$USER/VirtualBox\ VMs/$vm/$vm.vbox
			if [[ $(vboxmanage showvminfo $vm &> /dev/null;echo $?) = 0 ]]; then
				echo 'Máquina registrada.'
				return 0
			else
				echo 'Error. Máquina no registrada.'
				return 3
			fi
		else
			echo 'Máquina no encontrada. Vuelve a intentarlo.'
			return 1
		fi
	elif [[ $opcion = 2 ]]; then
		echo 'Introduce la ruta absoluta de la máquina virtual:'
		read vm
		if [[ $(f_existe_directorio $vm;echo $?) = 0 ]]; then
En determinadas opciones, devuelve los siguientes códigos:
			vboxmanage registervm $vm
			if [[ $(vboxmanage showvminfo $vm &> /dev/null;echo $?) = 0 ]]; then
				echo 'Máquina registrada.'
				return 0
			else
				echo 'Error. Máquina no registrada.'
				return 3
			fi
		else
			echo 'Ruta no encontrada. Vuelve a intentarlo.'
			return 1
		fi
	else
		echo 'Opción incorrecta.'
		return 2
	fi
}

#Esta función elimina el registro de una máquina virtual en Virtualbox.
#No acepta argumentos de entrada.
function f_eliminar_registro_vm {
	echo 'Introduce el nombre de la máquina virtual:'
	read vm
	if [[ $(vboxmanage showvminfo $vm &> /dev/null; echo $?) = 1 ]]; then
		echo 'No hay ninguna máquina virtual registrada con ese nombre.'
	else
		cat ./menus/registros/elimreg.txt
		read res
		if [[ $res = 's' ]]; then
			vboxmanage unregistervm $vm --delete &> /dev/null
		else
			vboxmanage unregistervm $vm &> /dev/null
		fi
		echo 'Registro de máquina eliminado.'
	fi
}

#Esta función mueve una máquina virtual a otro directorio.
#No acepta argumentos de entrada.
#Devuelve 0 al mover la máquina de directorio, 1 si no se introduce un nombre de máquina incorrecto,
#2 si se introduce una ruta incorrecta y 3 si ocurre algún error durante el intento de desplazamiento.
function f_movervm {
	echo 'Introduce el nombre de la máquina virtual:'
	read vm
	if [[ $(vboxmanage showvminfo $vm &> /dev/null;echo $?) = 0 ]]; then
		echo 'Introduce la ruta relativa o absoluta del nuevo directorio (por defecto, ~/VirtualBox VMs/):'
		read dir
		if [[ $dir = $null ]]; then
                        vboxmanage movevm $vm --type basic --folder /home/$USER/VirtualBox\ VMs/ &> /dev/null
			if [[ $(f_existe_directorio /home/$USER/VirtualBox\ VMs/$vm;echo $?) = 0 ]]; then
				echo 'Desplazamiento realizado correctamente.'
				return 0
			else
				echo 'Error. No se ha podido mover la máquina de directorio.'
				return 3
			fi
		else
			if [[ $(f_existe_directorio $dir;echo $?) = 0 ]]; then
				vboxmanage movevm $vm --type basic --folder $dir &> /dev/null
				if [[ $(f_existe_directorio $dir/$vm;echo $?) = 0 ]]; then
					echo 'Desplazamiento realizado correctamente.'
					return 0
				else
					echo 'Error. No se ha podido mover la máquina de directorio.'
					return 3
				fi
			else
				echo 'Directorio no encontrado.'
				return 2
			fi
		fi
	else
		echo 'No hay ninguna máquina registrada con ese nombre.'
		return 1
	fi
}

#Esta función modifica los ajustes básicos de una máquina virtual.
#Acepta como argumento el nombre de la máquina virtual.
#En determinadas opciones, devuelve los siguientes códigos:
#- Nombre: 0 si se ha cambiado el nombre y 1 si no se ha cambiado.
#- Grupo: 0 si se ha cambiado el grupo, 1 si no se ha podido cambiar y 2 si se ha introducido un grupo incorrecto.
#- Sistema operativo: 0 si se ha cambiado, 1 si no se ha podido cambiar y 2 si se ha introducido un sistema incorrecto.
#- Fichero de icono: 0 si se ha cambiado y 1 si se ha introducido una ruta incorrecta.
#- Directorio de instantáneas: 0 si se ha cambiado la ruta, 1 si no se ha podido cambiar y 2 si se ha introducido una ruta incorrecta.
function f_config_general {
	cat ./menus/vmconfig/general.txt
	read opcion
	while [[ $opcion != 9 ]]; do
		if [[ $opcion = 1 ]]; then
			echo 'Introduce el nuevo nombre de la máquina:'
			read nombre
			vboxmanage modifyvm $1 --name $nombre
			if [[ $(vboxmanage showvminfo $nombre &> /dev/null; echo $?) = 0 ]]; then
				echo 'Nombre cambiado.'
				return 0
			else
				echo 'Error. Nombre no cambiado.'
				return 1
			fi
		elif [[ $opcion = 2 ]]; then
			echo '¿Cuántos grupos quieres introducir?'
			read num
			for i in {1..$num}; do
				echo "Grupo:"
				read grupo
				if [[ $(vboxmanage list groups | egrep $grupo) ]]; then
					vboxmanage modifyvm $1 --groups $grupo
					if [[ $(vboxmanage showvminfo $1 | egrep Groups | egrep $grupo) ]]; then
						echo 'Máquina añadida al grupo.'
						return 0
					else
						echo 'Error. La máquina no se ha añadido al grupo.'
						return 1
					fi
				else
					echo 'No hay ningún grupo registrado con ese nombre.'
					return 2
				fi
			done
			echo 'La máquina se encuentra ahora en los siguientes grupos:'
			vboxmanage showvminfo $1 | egrep Groups | awk '{print $2}'
		elif [[ $opcion = 3 ]]; then
			echo 'Introduce la nueva descripción:'
			read descripcion
			vboxmanage modifyvm $1 --description "$descripcion"
			echo 'Descripción modificada.'
		elif [[ $opcion = 4 ]]; then
			echo 'Introduce el nuevo sistema operativo (L para ver la lista de sistemas operativos disponibles):'
			read os
			while [[ $os = 'L' ]]; do
				vboxmanage list ostypes
				echo 'Introduce el nuevo sistema operativo (L para ver la lista de sistemas operativos disponibles):'
                        	read os
			done
			if [[ $(vboxmanage list ostypes | egrep $os) ]]; then
				vboxmanage modifyvm $1 --ostype $os
				if [[ $(vboxmanage showvminfo $1 | awk '{print $3}' | egrep $os) ]]; then
					echo 'Sistema operativo modificado.'
					return 0
				else
					echo 'Error. No se ha cambiado el sistema operativo.'
					return 1
				fi
			else
				echo 'No hay disponible ningún sistema operativo con ese nombre.'
				return 2
			fi
		elif [[ $opcion = 5 ]]; then
			echo 'Introduce la ruta de la imagen:'
			read ruta
			if [[ -e $ruta ]]; then
				vboxmanage modifyvm $1 --iconfile "$ruta"
				echo 'Icono cambiado.'
				return 0
			else
				echo 'La ruta introducida no existe.'
				return 1
			fi
		elif [[ $opcion = 6 ]]; then
			echo 'Introduce la nueva ruta (INTRO si quieres selecccionar la ruta por defecto):'
			read ruta
			if [[ $ruta = $null ]]; then
				vboxmanage modifyvm $1 --snapshotfolder default
				echo 'Ruta de instantáneas modificada.'
				return 0
			else
				if [[ $(f_existe_directorio $ruta;echo $?) ]]; then
					vboxmanage modifyvm $1 --snapshotfolder "$ruta"
					if [[ $(vboxmanage modifyvm $1 | egrep Snapshot | awk '{print $3}') = $ruta ]]; then
						echo 'Ruta de instantáneas modificada.'
						return 0
					else
						echo 'Error. Ruta no modificada.'
						return 1
					fi
				else
					echo 'Ruta no encontrada.'
					return 2
				fi
			fi
		elif [[ $opcion = 7 ]]; then
			cat ./menus/vmconfig/clipdrag.txt
			read opcion2
			if [[ $opcion2 = 1 ]]; then
				vboxmanage modifyvm $1 --clipboard disabled
			elif [[ $opcion2 = 2 ]]; then
				vboxmanage modifyvm $1 --clipboard hosttoguest
			elif [[ $opcion2 = 3 ]]; then
				vboxmanage modifyvm $1 --clipboard guesttohost
			elif [[ $opcion2 = 4 ]]; then
				vboxmanage modifyvm $1 --clipboard bidirectional
			fi
		elif [[ $opcion = 8 ]]; then
			cat ./menus/vmconfig/clipdrag.txt
			read opcion2
			if [[ $opcion2 = 1 ]]; then
                                vboxmanage modifyvm $1 --draganddrop disabled
                        elif [[ $opcion2 = 2 ]]; then
                                vboxmanage modifyvm $1 --draganddrop hosttoguest
                        elif [[ $opcion2 = 3 ]]; then
                                vboxmanage modifyvm $1 --draganddrop guesttohost
                        elif [[ $opcion2 = 4 ]]; then
                                vboxmanage modifyvm $1 --draganddrop bidirectional
                        fi
		else
			echo 'Opción incorrecta. Introduce una opción del menú.'
		fi
		cat ./menus/vmconfig/general.txt
		read opcion
	done
}

#Esta función configura la pestaña de sistema de una máquina virtual en VirtualBox.
#Las distintas opciones que aparecen en esta función se corresponden con las de los diferentes menús
#invocados en el script, y cuyos ficheros de texto se encuentran en el directorio ./menus/.
#Acepta como argumento el nombre de la máquina virtual.
function f_config_sistema {
	cat ./menus/vmconfig/sistema/sistema.txt
	read opcion
	while [[ $opcion != 10 ]]; do
		if [[ $opcion = 1 ]]; then
			echo 'Introduce el tamaño de memoria en MB (debe ser igual o mayor que 4):'
			read size
			vboxmanage modifyvm $1 --memory $size
			if [[ $(vboxmanage showvminfo $1 | egrep Memory | awk '{print $3}' | egrep "$size") ]]; then
				echo 'Memoria modificada.'
			else
				echo 'Error. Memoria no modificada.'
			fi
		elif [[ $opcion = 2 ]]; then
			echo 'Introduce el orden (un número entre 1 y 4):'
			read orden
			if [[ $orden > 0 && $orden < 5 ]]; then
				echo "¿Qué dispositivo quieres arrancar en $ordenº lugar?"
				cat ./menus/vmconfig/sistema/orden_arranque.txt
				read opcion2
				if [[ $opcion2 = 1 ]]; then
					vboxmanage modifyvm $1 --boot$orden disk
					echo "Disco duro establecido en $ordenº lugar."
				elif [[ $opcion2 = 2 ]]; then
					vboxmanage modifyvm $1 --boot$orden dvd
					echo "Óptica establecida en $ordenº lugar."
				elif [[ $opcion2 = 3 ]]; then
					vboxmanage modifyvm $1 --boot$orden net
					echo "Red establecida en $ordenº lugar."
				elif [[ $opcion2 = 4 ]]; then
					vboxmanage modifyvm $1 --boot$orden floppy
					echo "Disquete establecido en $ordenº lugar."
				elif [[ $opcion2 = 5 ]]; then
					vboxmanage modifyvm $1 --boot$orden none
					echo "Ningún dispositivo establecido en $ordenº lugar"
				else
					echo 'Opción incorrecta.'
				fi
			else
				echo 'Orden incorrecta.'
			fi
		elif [[ $opcion = 3 ]]; then
			echo 'Selecciona un chipset de los siguientes:'
			echo ''
			echo '1) PIIX3'
			echo '2) ICH9'
			echo ''
			echo 'Opción:'
			read opcion2
			if [[ $opcion2 = 1 ]]; then
				vboxmanage modifyvm $1 --chipset piix3
				echo 'Se ha seleccionado el chipset PIIX3.'
			elif [[ $opcion2 = 2 ]]; then
				vboxmanage modifyvm $1 --chipset ich9
				echo 'Se ha seleccionado el chipset ICH9.'
			else
				echo 'Opción incorrecta.'
			fi
		elif [[ $opcion = 4 ]]; then
			cat ./menus/vmconfig/sistema/apuntador.txt
			read opcion2
			if [[ $opcion2 = 1 ]]; then
				vboxmanage modifyvm $1 --mouse ps2
				echo 'Se ha seleccionado el ratón PS/2 como apuntador.'
			elif [[ $opcion2 = 2 ]]; then
				vboxmanage modifyvm $1 --mouse usb
				echo 'Se ha seleccionado el ratón USB como apuntador.'
			elif [[ $opcion2 = 3 ]]; then
				vboxmanage modifyvm $1 --mouse usbtablet
				echo 'Se ha seleccionado la tableta USB como apuntador.'
			elif [[ $opcion2 = 4 ]]; then
				vboxmanage modifyvm $1 --mouse usbmultitouch
				echo 'Se ha seleccionado la tableta multitáctil USB como apuntador.'
			else
				echo 'Opción incorrecta.'
			fi
		elif [[ $opcion = 5 ]]; then
			cat ./menus/vmconfig/sistema/placabase.txt
			read opcion2
			while [[ $opcion2 != 5 ]]; do
				if [[ $opcion2 = 1 ]]; then
					echo '(H)abilitar	(D)eshabilitar'
					read opcion3
					if [[ $opcion3 = 'H' ]]; then
						vboxmanage modifyvm $1 --ioapic on
						echo 'I/O APIC habilitado.'
					elif [[ $opcion3 = 'D' ]]; then
						vboxmanage modifyvm $1 --ioapic off
						echo 'I/O APIC deshabilitado.'
					else
						echo 'Opción incorrecta.'
					fi
				elif [[ $opcion2 = 2 ]]; then
					echo '(H)abilitar       (D)eshabilitar'
					read opcion3
					if [[ $opcion3 = 'H' ]]; then
                                                vboxmanage modifyvm $1 --acpi on
                                                echo 'ACPI habilitado.'
                                        elif [[ $opcion3 = 'D' ]]; then
                                                vboxmanage modifyvm $1 --acpi off
                                                echo 'ACPI deshabilitado.'
                                        else
                                                echo 'Opción incorrecta.'
					fi
				elif [[ $opcion2 = 3 ]]; then
					echo '(H)abilitar       (D)eshabilitar'
					read opcion3
                                        if [[ $opcion3 = 'H' ]]; then
                                                vboxmanage modifyvm $1 --firmware efi
                                                echo 'ACPI habilitado.'
                                        elif [[ $opcion3 = 'D' ]]; then
                                                vboxmanage modifyvm $1 --firmware bios
                                                echo 'ACPI deshabilitado.'
                                        else
                                                echo 'Opción incorrecta.'
                                        fi
				elif [[ $opcion2 = 4 ]]; then
					echo '¿Quieres establecer el reloj en tiempo UTC? (s/n)'
					read opcion3
					if [[ $opcion3 = 's' ]]; then
						vboxmanage modifyvm $1 --rtcuseutc on
						echo 'Reloj establecido en UTC.'
					elif [[ $opcion3 = 'n' ]]; then
						vboxmanage modifyvm $1 --rtcuseutc off
						echo 'Reloj no establecido en UTC.'
					else
						echo 'Opción incorrecta.'
					fi
				else
					echo 'Opción incorrecta.'
				fi
				cat ./menus/vmconfig/sistema/placabase.txt
				read opcion2
			done
		elif [[ $opcion = 6 ]]; then
			echo '¿Cuántos núcleos del procesador físico quieres que use la máquina?'
			read numproc
			if [[ $numproc < $(cat /proc/cpuinfo | egrep processor | wc -l) || $numproc = $(cat /proc/cpuinfo | egrep processor | wc -l) ]]; then
				vboxmanage modifyvm $1 --cpus $numproc
				if [[ $(vboxmanage showvminfo $1 | egrep CPUs | awk '{print $4}') = $numproc ]]; then
					echo "Número de CPUs establecido: $numproc"
				else
					echo 'Error. El número de CPUs no se ha modificado.'
				fi
			else
				echo 'Error. El número de CPUs introducido sobrepasa la cantidad permitida.'
			fi
		elif [[ $opcion = 7 ]]; then
			echo 'Introduce el porcentaje de ejecución del procesador físico para tareas de virtualización (1-100):'
			read porcentaje
			if [[ $porcentaje > 0 && $porcentaje < 101 ]]; then
				vboxmanage modifyvm $1 --cpuexecutioncap $porcentaje
				if [[ $(vboxmanage showvminfo $1 | egrep exec | awk '{print $4}') = "$porcentaje%" ]]; then
					echo 'Límite de ejecución modificado.'
				else
					echo 'Error. Límite de ejecución no modificado.'
				fi
			else
				echo 'Respuesta no válida.'
			fi
		elif [[ $opcion = 8 ]]; then
			cat ./menus/vmconfig/sistema/procesador.txt
			read opcion2
			while [[ $opcion2 != 3 ]]; do
				if [[ $opcion2 = 1 ]]; then
					echo '¿Quieres habilitar PAE? (s/n)'
					read opcion3
					if [[ $opcion3 = 's' ]]; then
						vboxmanage modifyvm $1 --pae on
						echo 'PAE habilitado.'
					elif [[ $opcion3 = 'n' ]]; then
						vboxmanage modifyvm $1 --pae off
						echo 'PAE deshabilitado.'
					else
						echo 'Opción incorrecta.'
					fi
				elif [[ $opcion2 = 2 ]]; then
					echo '¿Quieres habilitar las extensiones de virtualización VT-x/AMD-V anidado?'
					read opcion3
					if [[ $opcion3 = 's' ]]; then
						vboxmanage modifyvm $1 --hwvirtex on
                                                echo 'VT-x/AMD-V anidado habilitado.'
                                        elif [[ $opcion3 = 'n' ]]; then
                                                vboxmanage modifyvm $1 --hwvirtex off
                                                echo 'VT-x/AMD-V anidado deshabilitado.'
                                        else
                                                echo 'Opción incorrecta.'
                                        fi
				else
					echo 'Opción incorrecta.'
				fi
			cat ./menus/vmconfig/sistema/procesador.txt
                        read opcion2
			done
		elif [[ $opcion = 9 ]]; then
			cat ./menus/vmconfig/sistema/aceleracion.txt
			read opcion2
			while [[ $opcion2 != 3 ]]; do
				if [[ $opcion2 = 1 ]]; then
					cat ./menus/vmconfig/sistema/intparavt.txt
					read opcion3
					if [[ $opcion3 = 1 ]]; then
						vboxmanage modifyvm $1 --paravirtprovider none
						echo 'Interfaz deshabilitada.'
					elif [[ $opcion3 = 2 ]]; then
						vboxmanage modifyvm $1 --paravirtprovider default
						echo 'Interfaz seleccionada: determinada.'
					elif [[ $opcion3 = 3 ]]; then
						vboxmanage modifyvm $1 --paravirtprovider legacy
						echo 'Interfaz seleccionada: heredada.'
					elif [[ $opcion3 = 4 ]]; then
						vboxmanage modifyvm $1 --paravirtprovider minimal
						echo 'Interfaz seleccionada: mínima.'
					elif [[ $opcion3 = 5 ]]; then
						vboxmanage modifyvm $1 --paravirtprovider hyperv
						echo 'Interfaz seleccionada: Hyper-V.'
					elif [[ $opcion3 = 6 ]]; then
						vboxmanage modifyvm $1 --paravirtprovider kvm
						echo 'Interfaz seleccionada: KVM.'
					else
						echo 'Opción incorrecta.'
					fi
				elif [[ $opcion2 = 2 ]]; then
					echo '¿Quieres habilitar la paginación anidada? (s/n)'
					read opcion3
					if [[ $opcion3 = 's' ]]; then
						vboxmanage modifyvm $1 --nestedpaging on
						echo 'Paginación anidada habilitada.'
					elif [[ $opcion3 = 'n' ]]; then
						vboxmanage modifyvm $1 --nestedpaging off
						echo 'Paginación anidada deshabilitada.'
					else
						echo 'Opción incorrecta.'
					fi
				else
					echo 'Opción incorrecta.'
				fi
			cat ./menus/vmconfig/sistema/aceleracion.txt
			read opcion2
			done
		else
			echo 'Opción incorrecta.'
		fi
		cat ./menus/vmconfig/sistema/sistema.txt
		read opcion
	done
}

#Esta función permite configurar las distintas opciones que se ven en la pestaña Pantalla
#de la ventana de configuración de una máquina virtual en VirtualBox. Para ello, se toma como referencia
#los diferentes menús alojados en ./menus/pantalla/.
#Acepta como argumento de entrada el nombre de la máquina virtual.
function f_config_pantalla {
	cat ./menus/vmconfig/pantalla/pantalla.txt
	read opcion
	while [[ $opcion != 7 ]]; do
		if [[ $opcion = 1 ]]; then
			echo 'Introduce el tamaño de memoria de vídeo en MB:'
			read size
			vboxmanage modifyvm $1 --vram $size
			if [[ $(vboxmanage showvminfo $1 | egrep VRAM | egrep $size) ]]; then
				echo 'Tamaño de memoria de vídeo modificado.'
			else
				echo 'Error. Tamaño no modificado.'
			fi
		elif [[ $opcion = 2 ]]; then
			echo 'Introduce el número de monitores que quieres asignar a la máquina:'
			read num
			vboxmanage modifyvm $1 --monitorcount $num
			if [[ $(vboxmanage showvminfo $1 | egrep Monitor | awk '{print $3}') = $num ]]; then
				echo 'Número de monitores modificado.'
			else
				echo 'Error. Número de monitores no modificado.'
			fi
		elif [[ $opcion = 3 ]]; then
			cat ./menus/vmconfig/pantalla/controlador.txt
			read opcion2
			if [[ $opcion2 = 1 ]]; then
				vboxmanage modifyvm $1 --graphicscontroller none
				echo 'Controlador seleccionado: ninguno'
			elif [[ $opcion2 = 2 ]]; then
				vboxmanage modifyvm $1 --graphicscontroller vboxvga
				echo 'Controlador seleccionado: VBoxVGA'
			elif [[ $opcion2 = 3 ]]; then
				vboxmanage modifyvm $1 --graphicscontroller vmsvga
				echo 'Controlador seleccionado: VMSVGA'
			elif [[ $opcion2 = 4 ]]; then
				vboxmanage modifyvm $1 --graphicscontroller vboxsvga
				echo 'Controlador seleccionado: VBoxSVGA'
			else
				echo 'Opción incorrecta.'
			fi
		elif [[ $opcion = 4 ]]; then
			echo '¿Quieres habilitar la aceleración 3D? (s/n)'
			read opcion2
			if [[ $opcion2 = 's' ]]; then
				vboxmanage modifyvm $1 --accelerate3d on
				echo 'Aceleración 3D habilitada.'
			elif [[ $opcion2 = 'n' ]]; then
				vboxmanage modifyvm $1 --accelerate3d off
				echo 'Aceleración 3D deshabilitada.'
			fi
		elif [[ $opcion = 5 ]]; then
			echo '¿Quieres tener habilitada la pantalla remota? (s/n)'
			read res1
			if [[ $res1 = 's' ]]; then
				vboxmanage modifyvm $1 --vrde on
				echo 'Pantalla remota habilitada.'
				echo '¿Quieres modificar las opciones de pantalla remota? (s/n)'
				read res2
				if [[ $res2 = 's' ]]; then
					cat ./menus/vmconfig/pantalla/remota.txt
					read opcion2
					while [[ $opcion2 != 5 ]]; do
						if [[ $opcion2 = 1 ]]; then
							echo '¿Quieres que el puerto sea el predeterminado (3389)? (s/n)'
							read res3
							if [[ $res3 = 's' ]]; then
								vboxmanage modifyvm $1 --vrdeport default
								echo 'Puerto seleccionado: 3389'
							elif [[ $res3 = 'n' ]]; then
								echo 'Introduce el número de puerto:'
								read puerto
								vboxmanage modifyvm $1 --vrdeport $puerto
								if [[ $(vboxmanage showvminfo $1 | egrep 'VRDE' | awk '{print $5}') = $puerto ]]; then
									echo "Puerto establecido: $puerto"
								else
									echo 'Error. Puerto no establecido.'
								fi
							fi
						elif [[ $opcion2 = 2 ]]; then
							echo '¿IPv4, IPv6 o ambos? (4/6)'
							read res3
							if [[ $res3 = 4 ]]; then
								echo 'Introduce una dirección IPv4 (por defecto, 0.0.0.0):'
								read ip
								if [[ $ip = $null ]]; then
									vboxmanage modifyvm $1 --vrdeaddress "0.0.0.0"
									echo 'Se ha establecido la IPv4 por defecto.'
								else
									vboxmanage modifyvm $1 --vrdeaddress $ip
									if [[ $(vboxmanage showvminfo $1 | egrep 'VRDE' | awk '{print $4}') = "$ip," ]]; then
										echo "Dirección IPv4 establecida: $ip"
									else
										echo 'Error. Dirección IP no establecida.'
									fi
								fi
							elif [[ $res3 = 6 ]]; then
								echo 'Introduce una dirección IPv6 (por defecto, ::):'
                                                                read ip
                                                                if [[ $ip = $null ]]; then
                                                                        vboxmanage modifyvm $1 --vrdeaddress "::"
                                                                        echo 'Se ha establecido la IPv6 por defecto.'
                                                                else
                                                                        vboxmanage modifyvm $1 --vrdeaddress $ip
                                                                        if [[ $(vboxmanage showvminfo $1 | egrep 'VRDE' | awk '{print $4}') = "$ip," ]]; then
                                                                                echo "Dirección IPv6 establecida: $ip"
                                                                        else
                                                                                echo 'Error. Dirección IP no establecida.'
                                                                        fi
                                                                fi
							fi
						elif [[ $opcion2 = 3 ]]; then
							cat ./menus/vmconfig/pantalla/rvauth.txt
							read opcion3
							if [[ $opcion3 = 1 ]]; then
								vboxmanage modifyvm $1 --vrdeauthtype null
								echo 'Tipo de autenticación seleccionada: nulo'
							elif [[ $opcion3 = 2 ]]; then
								vboxmanage modifyvm $1 --vrdeauthtype external
								echo 'Tipo de autenticación seleccionada: externo'
							elif [[ $opcion3 = 3 ]]; then
								vboxmanage modifyvm $1 --vrdeauthtype guest
								echo 'Tipo de autenticación seleccionada: invitado'
							else
								echo 'Opción incorrecta.'
							fi
						elif [[ $opcion2 = 4 ]]; then
							echo '¿Quieres permitir múltiples conexiones? (s/n)'
							read res3
							if [[ $res3 = 's' ]]; then
								vboxmanage modifyvm $1 --vrdemulticon on
								echo 'Ahora se permiten múltiples conexiones.'
							elif [[ $res3 = 'n' ]]; then
								vboxmanage modifyvm $1 --vrdemulticon off
								echo 'Ahora no se permiten múltiples conexiones.'
							fi
						else
							echo 'Opción incorrecta.'
						fi
						cat ./menus/vmconfig/pantalla/remota.txt
                                	        read opcion2
					done
				fi
			elif [[ $res1 = 'n' ]]; then
				vboxmanage modifyvm $1 --vrde off
				echo 'Pantalla remota deshabilitada.'
			fi
		elif [[ $opcion = 6 ]]; then
			echo '¿Quieres tener habilitada la grabación de sesiones en la máquina? (s/n)'
			read res1
			if [[ $res1 = 's' ]]; then
				vboxmanage modifyvm $1 --recording on
				echo 'Grabación habilitada.'
				echo '¿Quieres modificar las opciones de grabación? (s/n)'
				read res2
				if [[ $res2 = 's' ]]; then
					cat ./menus/vmconfig/pantalla/grabacion.txt
					read opcion2
					while [[ $opcion2 != 8 ]]; do
						if [[ $opcion2 = 1 ]]; then
							echo '¿Quieres grabar todas las pantallas o solo una? (1/n)'
							read res3
							if [[ $res3 = 1 ]]; then
								echo 'Introduce el identificador de la pantalla:'
								read pantalla
								vboxmanage modifyvm $1 --recordingscreens $pantalla
								echo "Pantalla seleccionada: $pantalla"
							elif [[ $res3 = 'n' ]]; then
								vboxmanage modifyvm $1 --recordingscreens all
								echo 'Se han seleccionado todas las pantallas.'
							fi
						elif [[ $opcion2 = 2 ]]; then
							echo "Introduce la ruta del archivo de grabación (por defecto, ~/VirtualBox VMs/$1/):"
							read ruta
							if [[ $ruta = $null ]]; then
								ruta="/home/$USER/VirtualBox VMs/$1"
								vboxmanage modifyvm $1 --recordingfile "$ruta/$1.webm"
                                                                        if [[ $(vboxmanage showvminfo $1 | egrep 'Capture file' | egrep "$ruta") ]]; then
                                                                                echo 'Ruta modificada.'
                                                                        else
                                                                                echo 'Error. Ruta no modificada.'
                                                                        fi
							else
								if [[ $(f_existe_directorio "$ruta";echo $?) = 0 ]]; then
									vboxmanage modifyvm $1 --recordingfile "$ruta/$1.webm"
									if [[ $(vboxmanage showvminfo $1 | egrep 'Capture file' | egrep "$ruta") ]]; then
										echo 'Ruta modificada.'
									else
										echo 'Error. Ruta no modificada.'
									fi
								else
									echo 'Ruta no encontrada.'
								fi
							fi
						elif [[ $opcion2 = 3 ]]; then
							echo 'Introduce el tamaño máximo del archivo en MB:'
							read size
							vboxmanage modifyvm $1 --recordingmaxsize $size
							echo "Tamaño máximo establecido: $sizeMB"
						elif [[ $opcion2 = 4 ]]; then
							echo 'Introduce el tiempo máximo de grabación en segundos:'
							read tiempo
							vboxmanage modifyvm $1 --recordingmaxtime $tiempo
							if [[ $tiempo -gt 3600 || $tiempo = 3600 ]]; then
								let horas=$tiempo/3600
                                                                let segundos=$tiempo%3600
                                                                if [[ $segundos -gt 60 || $segundos = 60 ]]; then
                                                                        let minutos=$segundos/60
                                                                        let segundos=$segundos%60
                                                                        echo "Tiempo máximo de grabación: $horas hora(s), $minutos minuto(s) y $segundos segundo(s)."
                                                                else
                                                                        echo "Tiempo máximo de grabación: $horas hora(s) y $segundos segundo(s)."
                                                                fi
							elif [[ $tiempo -gt 60 || $tiempo = 60 ]]; then
								let minutos=$tiempo/60
								let segundos=$tiempo%60
								echo "Tiempo máximo de grabación: $minutos minuto(s) y $segundos segundo(s)."
							fi
						elif [[ $opcion2 = 5 ]]; then
							echo 'Introduce un número máximo de fps:'
							read fps
							vboxmanage modifyvm $1 --recordingvideofps $fps
							echo "Número máximo de fps establecido: $fps"
						elif [[ $opcion2 = 6 ]]; then
							echo 'Introduce una tasa de bits por segundo en kilobits:'
							read kb
							vboxmanage modifyvm $1 --recordingvideorate $kb
							echo "Tasa establecida: $kb kilobits"
						elif [[ $opcion2 = 7 ]]; then
							echo 'Introduce la anchura en píxeles:'
							read anchura
							echo 'Introduce la altura en píxeles:'
							read altura
							vboxmanage modifyvm $1 --recordingvideores "$anchura"x"$altura"
							if [[ $(vboxmanage showvminfo prueba | egrep 'Capture dimensions' | egrep "$anchura"x"$altura") ]]; then
								echo 'Resolución cambiada correctamente.'
							else
								echo 'Error. Resolución no modificada.'
							fi
						else
							echo 'Opción incorrecta.'
						fi
						cat ./menus/vmconfig/pantalla/grabacion.txt
	                                        read opcion2
					done
				fi
			elif [[ $res1 = 'n' ]]; then
				vboxmanage modifyvm $1 --recording off
				echo 'Grabación deshabilitada.'
			fi
		else
			echo 'Opción incorrecta.'
		fi
		cat ./menus/vmconfig/pantalla/pantalla.txt
        	read opcion
	done
}

#Esta función añade un nuevo controlador de almacenamiento a una determinada máquina virtual en Virtualbox.
#En el programa vboxmanager.sh, se emplea como parte de la función de configuración de almacenamiento (f_config_almacenamiento).
#Acepta como argumento de entrada el nombre o la UUID de la máquina virtual.
#Devuelve 0 al añadir el controlador en la máquina virtual, y 1 si no se ha podido añadir.
function f_añadecontrolador {
	echo '¿Qué nombre quieres darle al nuevo controlador?'
	read nombre
	if [[ $(vboxmanage showvminfo $1 | egrep 'Storage Controller Name' | grep $nombre) ]]; then
		echo 'Ya existe un controlador con ese nombre en la máquina.'
	else
		cat ./menus/vmconfig/almacenamiento/busessistema.txt
		read opcion
		while [[ $opcion < 1 || $opcion > 7 ]]; do
			echo 'Opción incorrecta.'
	        	cat ./menus/vmconfig/almacenamiento/busessistema.txt
        		read opcion2
		done
		if [[ $opcion = 1 ]]; then
			bus="ide"
		elif [[ $opcion = 2 ]]; then
        		bus="sata"
		elif [[ $opcion = 3 ]]; then
        		bus="scsi"
		elif [[ $opcion = 4 ]]; then
        		bus="floppy"
		elif [[ $opcion = 5 ]]; then
		        bus="sas"
		elif [[ $opcion = 6 ]]; then
			bus="usb"
		else
		        bus="pcie"
		fi
		chipset=false
		echo '¿Quieres elegir un chipset en particular? (s/n)'
		read res
		if [[ $res = 's' ]]; then
			chipset=true
	        	cat ./menus/vmconfig/almacenamiento/chipsets.txt
	        	read opcion2
	        	if [[ $opcion2 = 1 ]]; then
	        		tipo="PIIX4"
	        	elif [[ $opcion2 = 2 ]]; then
	              		tipo="PIIX3"
	        	elif [[ $opcion2 = 3 ]]; then
	                	tipo="ICH6"
	        	elif [[ $opcion2 = 4 ]]; then
	        	        tipo="IntelAhci"
	        	elif [[ $opcion2 = 5 ]]; then
	        	        tipo="LSILogic"
	        	elif [[ $opcion2 = 6 ]]; then
	        	        tipo="BusLogic"
			elif [[ $opcion2 = 7 ]]; then
	        	        tipo="I82078"
	        	elif [[ $opcion2 = 8 ]]; then
	        	        tipo="LSILogic SAS"
	        	elif [[ $opcion2 = 9 ]]; then
	        	        tipo="USB"
	        	elif [[ $opcion2 = 10 ]]; then
	        	        tipo="NVMe"
	        	elif [[ $opcion2 = 11 ]]; then
	        	        tipo="VirtIO"
	        	else
	        	        echo 'Opción incorrecta.'
	        	fi
		fi
		numpuertos=false
		if [[ $opcion = 2 || $opcion = 5 ]]; then
			echo '¿Quieres especificar una cantidad de puertos? (s/n)'
			read res
			if [[ $res = 's' ]]; then
				numpuertos=true
	        		echo 'Introduce una cantidad entre 1 y 30:'
			        read num
	        		while [[ $num -lt 1 || $num -gt 30 ]]; do
	        			echo 'Cantidad incorrecta.'
					echo 'Introduce una cantidad entre 1 y 30:'
	                		read num
	        		done
			fi
		fi
		cache=false
		echo '¿Quieres usar la caché de E/S del anfitrión? (s/n)'
		read res
		if [[ $res = 's' ]]; then
			cache=true
		fi
		arrancable=false
		echo '¿Quieres que sea arrancable?'
		read res
		if [[ $res = 's' ]]; then
			arrancable=true
		fi
		if [[ $chipset = true ]]; then
			if [[ $numpuertos = true ]]; then
	        		if [[ $cache = true ]]; then
	                		if [[ $arrancable = true ]]; then
	                        		vboxmanage storagectl $1 --name $nombre --add $bus --controller $tipo --portcount $num --hostiocache on --bootable on
        	                	else
                	                	vboxmanage storagectl $1 --name $nombre --add $bus --controller $tipo --portcount $num --hostiocache on --bootable off
                        		fi
	                	else
					if [[ $arrancable = true ]]; then
	                               		vboxmanage storagectl $1 --name $nombre --add $bus --controller $tipo --portcount $num --hostiocaache off --bootable on
	                        	else
	                        		vboxmanage storagectl $1 --name $nombre --add $bus --controller $tipo --portcount $num --hostiocache off --bootable off
	                        	fi
	                	fi
	        	else
	                	if [[ $cache = true ]]; then
        	                	if [[ $arrancable = true ]]; then
                	                	vboxmanage storagectl $1 --name $nombre --add $bus --controller $tipo --hostiocache on --bootable on
              	          		else
	                                	vboxmanage storagectl $1 --name $nombre --add $bus --controller $tipo --hostiocache on --bootable off
        	                	fi
	                	else
        	                	if [[ $arrancable = true ]]; then
                	        	        vboxmanage storagectl $1 --name $nombre --add $bus --controller $tipo --hostiocache off --bootable on
                        		else
                        		        vboxmanage storagectl $1 --name $nombre --add $bus --controller $tipo --hostiocache off --bootable off
	                        	fi
        	        	fi
			fi
		else
			if [[ $numpuertos = true ]]; then
        			if [[ $cache = true ]]; then
                			if [[ $arrancable = true ]]; then
                        			vboxmanage storagectl $1 --name $nombre --add $bus --portcount $num --hostiocache on --bootable on
	                        	else
        	                		vboxmanage storagectl $1 --name $nombre --add $bus --portcount $num --hostiocache on --bootable off
                	        	fi
	                	else
        	                	if [[ $arrancable = true ]]; then
                	                	vboxmanage storagectl $1 --name $nombre --add $bus --portcount $num --hostiocache off --bootable on
                        		else
	                                	vboxmanage storagectl $1 --name $nombre --add $bus --portcount $num --hostiocache off --bootable off
        	                	fi
                		fi
	        	else
        	        	if [[ $cache = true ]]; then
                		        if [[ $arrancable = true ]]; then
                        		        vboxmanage storagectl $1 --name $nombre --add $bus --hostiocache on --bootable on
	                	        else
        	        	                vboxmanage storagectl $1 --name $nombre --add $bus --hostiocache on --bootable off
                		        fi
	                	else
					if [[ $arrancable = true ]]; then
                	        	        vboxmanage storagectl $1 --name $nombre --add $bus --hostiocache off --bootable on
                        		else
	                        	        vboxmanage storagectl $1 --name $nombre --add $bus --hostiocache off --bootable off
        	                	fi
                		fi
	        	fi
		fi
		if [[ $(vboxmanage showvminfo $1 | egrep 'Storage Controller Name' | egrep $nombre) ]]; then
			echo "Controlador $nombre creado."
			return 0
		else
			echo 'Error. Controlador no creado.'
			return 1
		fi
	fi
}

#Esta función elimina un controlador existente en una máquina virtual dada.
#Acepta como argumento de entrada el nombre de la máquina virtual en la que se quiere eliminar un controlador.
#Devuelve 0 después de eliminar el controlador, 1 si no hay ningún controlador en la máquina con ese nombre
#y 2 si dicho controlador se encuentra en la máquina pero no se ha podido eliminar.
#Esta función se emplea como una de las opciones en la función de configuración f_config_almacenamiento.
function f_eliminar_controlador {
	echo "Controladores de $1:"
	vboxmanage showvminfo $1 | egrep 'Storage Controller Name' | awk '{print $5}'
	echo 'Introduce el nombre del controlador que quieres eliminar:'
	read controlador
        if [[ $(vboxmanage showvminfo $1 | egrep 'Storage Controller Name' | egrep $controlador) ]]; then
		vboxmanage storagectl $1 --name $controlador --remove
		if [[ $(vboxmanage showvminfo $1 | egrep 'Storage Controller Name' | egrep $controlador) ]]; then
			echo 'Error. Controlador no eliminado.'
			return 2
		else
			echo "Controlador $controlador eliminado."
			return 0
		fi
	else
		echo "No hay ningún controlador en $1 con ese nombre."
		return 1
	fi

}

#Esta función modifica un atributo concreto de un controlador de almacenamiento en una determinada máquina virtual.
#Acepta como argumento de entrada el nombre de la máquina virtual.
#Esta función se emplea como una de las opciones de la función de configuración f_config_almacenamiento.
function f_modificar_controlador_almacenamiento {
	echo "Controladores de $1:"
	vboxmanage showvminfo $1 | egrep 'Storage Controller Name' | awk '{print $5}'
	echo 'Introduce el nombre del controlador que quieras modificar:'
	read controlador
	if [[ $(vboxmanage showvminfo $1 | egrep 'Storage Controller Name'| grep "$nombre") ]]; then
		cat ./menus/vmconfig/almacenamiento/controlmod.txt
		read opcion
		if [[ $opcion = 1 ]]; then
			echo 'Introduce el nuevo nombre del controlador:'
			read nuevo
			vboxmanage storagectl $1 --name $controlador --rename $nuevo
			if [[ $(vboxmanage showvminfo $1 | egrep 'Storage Controller Name' | grep "$nombre") ]]; then
				echo 'Nombre modificado.'
			else
				echo 'Error. No se ha cambiado el nombre.'
			fi
		elif [[ $opcion = 2 ]]; then
			cat ./menus/vmconfig/almacenamiento/chipsets.txt
                	read opcion2
	                if [[ $opcion2 = 1 ]]; then
        	                tipo="PIIX4"
                	elif [[ $opcion2 = 2 ]]; then
                	        tipo="PIIX3"
                	elif [[ $opcion2 = 3 ]]; then
                	        tipo="ICH6"
                	elif [[ $opcion2 = 4 ]]; then
                	        tipo="IntelAhci"
                	elif [[ $opcion2 = 5 ]]; then
                	        tipo="LSILogic"
                	elif [[ $opcion2 = 6 ]]; then
                	        tipo="BusLogic"
                	elif [[ $opcion2 = 7 ]]; then
                	        tipo="I82078"
                	elif [[ $opcion2 = 8 ]]; then
                	        tipo="LSILogic SAS"
                	elif [[ $opcion2 = 9 ]]; then
				tipo="USB"
        	        elif [[ $opcion2 = 10 ]]; then
                	        tipo="NVMe"
                	elif [[ $opcion2 = 11 ]]; then
                	        tipo="VirtIO"
                	else
                	        echo 'Opción incorrecta.'
                	fi
			vboxmanage storagectl $1 --name $controlador --controller $tipo
			if [[ $(vboxmanage showvminfo $1 | egrep 'Storage Controller Type' | grep "$tipo") ]]; then
				echo "Nuevo chipset de $controlador: $tipo"
			else
				echo 'Error. Chipset no cambiado.'
			fi
		elif [[ $opcion = 3 ]]; then
			index=$(vboxmanage showvminfo $1 | egrep 'Storage Controller Name' | grep "$controlador" | awk '{print $4}')
			echo 'Introduce un nuevo número de puertos:'
			echo "Número máximo de puertos: $(vboxmanage showvminfo $1 | egrep 'Max Port Count' | grep $index | awk '{print $7}')"
			read numpuertos
			max=$(vboxmanage showvminfo $1 | egrep 'Max Port Count' | grep "$index" | awk '{print $7}')
			if [[ $numpuertos -lt $max || $numpuertos -eq $max ]]; then
				vboxmanage storagectl $1 --name $controlador --portcount $numpuertos
				num=$(vboxmanage showvminfo $1 | egrep 'Controller Port Count' | grep "$index" | awk '{print $6}')
				if [[ $num = $numpuertos ]]; then
					echo 'Número de puertos modificado.'
				else
					echo 'Error. Número de puertos no modificado.'
				fi
			else
				echo 'El número de puertos sobrepasa el máximo permitido.'
			fi
		elif [[ $opcion = 4 ]]; then
			echo '¿Quieres habilitar el uso de la caché de E/S del anfitrión? (s/n)'
			read res
			if [[ $res = 's' ]]; then
				vboxmanage storagectl $1 --name $controlador --hostiocache on
				echo 'Uso de la caché habilitada.'
			elif [[ $res = 'n' ]]; then
				vboxmanage storagectl $1 --name $controlador --hostiocache off
				echo 'Uso de la caché deshabilitada.'
			fi
		elif [[ $opcion = 5 ]]; then
			echo '¿Quieres que el controlador sea arrancable? (s/n)'
			read res
			if [[ $res = 's' ]]; then
                                vboxmanage storagectl $1 --name $controlador --bootable on
                                echo 'El controlador ahora es arrancable.'
                        elif [[ $res = 'n' ]]; then
                                vboxmanage storagectl $1 --name $controlador --bootable off
                                echo 'El controlador ya no es arrancable.'
                        fi
		else
			echo 'Opción incorrecta.'
		fi
	else
		echo 'No se encuentra ningún controlador con ese nombre.'
	fi
}

#Esta función agrega o modifica una nueva conexión de almacenamiento a una determinada máquina de Virtualbox.
#Los atributos configurados en la función son los justos y necesarios para agregar la conexión.
#Acepta como argumento de entrada el nombre de la máquina virtual.
function f_modificar_conexion_almacenamiento {
	echo "Controladores de $1:"
        vboxmanage showvminfo $1 | egrep 'Storage Controller Name' | awk '{print $5}'
	echo 'Introduce el nombre del controlador:'
	read controlador
	index=$(vboxmanage showvminfo $1 | egrep 'Controller Name' | egrep $controlador | awk '{print $4}')
	if [[ $(vboxmanage showvminfo $1 | egrep 'Controller Port Count' | grep "$index" | awk '{print $7}') != 1 ]]; then
		tipo=$(vboxmanage showvminfo $1 | egrep 'Storage Controller Type' | grep "$index" | awk '{print $5}')
                puerto=$(vboxmanage showvminfo $1 | egrep "^$controlador" | awk '{print $2}')
                dispositivo=$(vboxmanage showvminfo $1 | egrep "^$controlador" | awk '{print $3}')
		if [[ $tipo = 'PIIX4' || $tipo = 'PIIX3' || $tipo = 'ICH6' ]]; then
			echo "Número de puertos de $controlador: $(vboxmanage showvminfo $1 | egrep 'Port Count' | grep $index | awk '{print $7}')"
			echo 'Introduce el puerto en el que quieres conectar el dispositivo:'
			read numpuerto
			if [[ $numpuerto -gt $(vboxmanage showvminfo $1 | egrep 'Max Port Count' | grep "$index" | awk '{print $7}') ]]; then
				echo 'Ese puerto no existe.'
			else
				echo 'Introduce un número de dispositivo en ese puerto (0/1):'
				read numdispositivo
				cat ./menus/vmconfig/almacenamiento/medioconexion.txt
				read opcion
				if [[ $opcion = 1 ]]; then
					vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --medium none
				elif [[ $opcion = 2 ]]; then
					cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
					read opcion2
					if [[ $opcion2 = 2 ]]; then
						echo 'Tipo de conexión no permitida.'
					else
						if [[ $opcion2 = 1 ]]; then
							vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type dvddrive --medium emptydrive
						elif [[ $opcion2 = 3 ]]; then
							vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type fdd --medium emptydrive
						fi
					fi
				elif [[ $opcion = 3 ]]; then
					vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --medium additions
				elif [[ $opcion = 4 ]]; then
					cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
					read opcion2
					if [[ $opcion2 = 1 ]]; then
						if [[ $(vboxmanage list dvds | egrep '(^UUID|^Location)') ]]; then
							echo 'Introduce una UUID de la siguiente lista:'
							vboxmanage list dvds | egrep '(^UUID|^Location)'
							echo 'UUID:'
							read uuid
							vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type dvddrive --medium $uuid
						else
							echo 'No tienes ninguna unidad de DVD en Virtualbox.'
						fi
					elif [[ $opcion2 = 2 ]]; then
						if [[ $(vboxmanage list hdds | egrep '(^UUID|^Location)') ]]; then
                                                	echo 'Introduce una UUID de la siguiente lista:'
                                                        vboxmanage list hdds | egrep '(^UUID|^Location)'
                                                        echo 'UUID:'
                                                        read uuid
							vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type hdd --medium $uuid
                                                else
                                                        echo 'No tienes ningún disco duro en Virtualbox.'
                                                fi
					elif [[ $opcion2 = 3 ]]; then
						if [[ $(vboxmanage list floppies | egrep '(^UUID|^Location)') ]]; then
                                                	echo 'Introduce una UUID de la siguiente lista:'
                                                        vboxmanage list floppies | egrep '(^UUID|^Location)'
                                                        echo 'UUID:'
                                                        read uuid
                                                        vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type fdd --medium $uuid
                                                else
                                                	echo 'No tienes ninguna unidad de disquete en Virtualbox.'
                                                fi
					fi
				elif [[ $opcion = 5 ]]; then
					echo 'Introduce la ruta del fichero:'
					cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
					read opcion2
					if [[ $opcion2 ]]; then
						echo "Rutas de unidades de DVD guardadas en Virtualbox:"
						vboxmanage list dvds | egrep '(^Location)'
						read ruta
						if [[ -e $ruta ]]; then
							echo 'Ruta no encontrada.'
						else
							vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type dvddrive --medium $ruta
						fi
					elif [[ $opcion2 ]]; then
						echo "Rutas de discos duros guardados en Virtualbox:"
                                                vboxmanage list hdds | egrep '(^Location)'
						read ruta
						if [[ -e $ruta ]]; then
                                                	echo 'Ruta no encontrada.'
                                                else
							vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type hdd --medium $ruta
						fi
					elif [[ $opcion2 ]]; then
						echo "Rutas de unidades de disquete guardadas en Virtualbox:"
                                                vboxmanage list floppies | egrep '(^Location)'
						read ruta
						if [[ -e $ruta ]]; then
                                                        echo 'Ruta no encontrada.'
                                                else
							vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type fdd --medium $ruta
						fi
					fi
				elif [[ $opcion = 6 ]]; then
					echo 'Introduce la unidad de máquina anfitrión que quieras usar:'
					read unidad
					cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
       	                                read opcion2
               	                        if [[ $opcion2 = 2 ]]; then
                       	                        echo 'Tipo de conexión no permitida.'
                               	        else
                                  	        if [[ $opcion2 = 1 ]]; then
                                            	        vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type dvddrive --medium $unidad
                                                elif [[ $opcion2 = 3 ]]; then
                                       	              	vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --device $numdispositivo --type fdd --medium $unidad
                                                fi
                                        fi
				fi
			fi
		elif [[ $tipo = 'IntelAhci' || $tipo = 'LsiLogicSas' ]]; then
			echo "Número de puertos de $controlador: $(vboxmanage showvminfo $1 | egrep 'Controller Port Count' | grep $index | awk '{print $6}')"
                	echo 'Introduce el puerto en el que quieres conectar el dispositivo:'
                	read numpuerto
                	if [[ $numpuerto -gt $(vboxmanage showvminfo $1 | egrep 'Max Port Count' | grep $index | awk '{print $7}') ]]; then
                        	echo 'Ese puerto no existe.'
                	else
				cat ./menus/vmconfig/almacenamiento/medioconexion.txt
                        	read opcion
                        	if [[ $opcion = 1 ]]; then
                        		vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --medium none
                        	elif [[ $opcion = 2 ]]; then
                        		cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
                                	read opcion2
                                	if [[ $opcion2 = 2 ]]; then
                                		echo 'Tipo de conexión no permitida.'
                                	else
                                		if [[ $opcion2 = 1 ]]; then
                                        		vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type dvddrive --medium emptydrive
                                        	elif [[ $opcion2 = 3 ]]; then
                                        		vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type fdd --medium emptydrive
                                        	fi
                                	fi
                       		elif [[ $opcion = 3 ]]; then
                        		vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --medium additions
				elif [[ $opcion = 4 ]]; then
                                	cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
                                	read opcion2
                                	if [[ $opcion2 = 1 ]]; then
                        			if [[ $(vboxmanage list dvds | egrep '(^UUID|^Location)') ]]; then
                                        		echo 'Introduce una UUID de la siguiente lista:'
                                                	vboxmanage list dvds | egrep '(^UUID|^Location)'
                                                	echo 'UUID:'
                                                	read uuid
                                                	vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type dvddrive --medium $uuid
                                        	else
                                        		echo 'No tienes ninguna unidad de DVD en Virtualbox.'
                                       		fi
                                	elif [[ $opcion2 = 2 ]]; then
                                		if [[ $(vboxmanage list hdds | egrep '(^UUID|^Location)') ]]; then
							echo 'Introduce una UUID de la siguiente lista:'
                                        	        vboxmanage list hdds | egrep '(^UUID|^Location)'
                                                	echo 'UUID:'
                                                	read uuid
                                                	vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type hdd --medium $uuid
						else
							echo 'No tienes ningún disco duro en Virtualbox.'
						fi
					elif [[ $opcion2 = 3 ]]; then
                                		if [[ $(vboxmanage list floppies | egrep '(^UUID|^Location)') ]]; then
                                	                echo 'Introduce una UUID de la siguiente lista:'
                                	        	vboxmanage list floppies | egrep '(^UUID|^Location)'
                                	                echo 'UUID:'
                                	                read uuid
                                	                vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type fdd --medium $uuid
                                	       	else
                                	        	echo 'No tienes ninguna unidad de disquete en Virtualbox.'
                                	        fi
					fi
				elif [[ $opcion = 5 ]]; then
                        		cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
                                	read opcion2
                                	if [[ $opcion2 ]]; then
						echo "Rutas de unidades de DVD guardadas en Virtualbox:"
                                	        vboxmanage list dvds | egrep '(^Location)'
                                       		read ruta
                                        	if [[ -e $ruta ]]; then
                                        		echo 'Ruta no encontrada.'
                                        	else
                                        		vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type dvddrive --medium $ruta
						fi
                                	elif [[ $opcion2 ]]; then
						echo "Rutas de discos duros guardadas en Virtualbox:"
                                	        vboxmanage list hdds | egrep '(^Location)'
                                	        read ruta
                                	        if [[ -e $ruta ]]; then
                                	        	echo 'Ruta no encontrada.'
                                	        else
	                        	                vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type hdd --medium $ruta
						fi
                                	elif [[ $opcion2 ]]; then
						echo "Rutas de unidades de disquete guardadas en Virtualbox:"
                                	        vboxmanage list floppies | egrep '(^Location)'
                                       		read ruta
                                        	if [[ -e $ruta ]]; then
                                        		echo 'Ruta no encontrada.'
                                        	else
                                        	       	vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type fdd --medium $ruta
						fi
                                	fi
                        	elif [[ $opcion = 6 ]]; then
                        		echo 'Introduce la unidad de máquina anfitrión que quieras usar:'
                                	read unidad
                                	cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
                                	read opcion2
                                	if [[ $opcion2 = 2 ]]; then
                                		echo 'Tipo de conexión no permitida.'
                                	else
                                		if [[ $opcion2 = 1 ]]; then
                                	        	vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type dvddrive --medium $unidad
                                	        elif [[ $opcion2 = 3 ]]; then
                                	        	vboxmanage storageattach $1 --storagectl $controlador --port $numpuerto --type fdd --medium $unidad
                                	        fi
                                	fi
				fi
			fi
		else
        		cat ./menus/vmconfig/almacenamiento/medioconexion.txt
                	read opcion
                	if [[ $opcion = 1 ]]; then
                		vboxmanage storageattach $1 --storagectl $controlador --medium none
                	elif [[ $opcion = 2 ]]; then
	        		cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
        		        read opcion2
                		if [[ $opcion2 = 2 ]]; then
                	        	echo 'Tipo de conexión no permitida.'
                	        else
                	        	if [[ $opcion2 = 1 ]]; then
                	                	vboxmanage storageattach $1 --storagectl $controlador --type dvddrive --medium emptydrive
                	              	elif [[ $opcion2 = 3 ]]; then
                	                        vboxmanage storageattach $1 --storagectl $controlador --type fdd --medium emptydrive
					fi
                	        fi
                	elif [[ $opcion = 3 ]]; then
                		vboxmanage storageattach $1 --storagectl $controlador --medium additions
                	elif [[ $opcion = 4 ]]; then
				cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
                		read opcion2
                		if [[ $opcion2 = 1 ]]; then
                	        	if [[ $(vboxmanage list dvds | egrep '(^UUID|^Location)') ]]; then
                	                	echo 'Introduce una UUID de la siguiente lista:'
                	                        vboxmanage list dvds | egrep '(^UUID|^Location)'
                	                        echo 'UUID:'
                	                        read uuid
                	                        vboxmanage storageattach $1 --storagectl $controlador --type dvddrive --medium $uuid
                	                else
                	                	echo 'No tienes ninguna unidad de DVD en Virtualbox.'
                	                fi
                	        elif [[ $opcion2 = 2 ]]; then
                	        	if [[ $(vboxmanage list hdds | egrep '(^UUID|^Location)') ]]; then
                	                	echo 'Introduce una UUID de la siguiente lista:'
                	                        vboxmanage list dvds | egrep '(^UUID|^Location)'
                	                        echo 'UUID:'
                	                        read uuid
						vboxmanage storageattach $1 --storagectl $controlador --type hdd --medium $uuid
                	                else
                	                	echo 'No tienes ningún disco duro en Virtualbox.'
                	                fi
                	        elif [[ $opcion2 = 3 ]]; then
                	        	if [[ $(vboxmanage list floppies | egrep '(^UUID|^Location)') ]]; then
                	                	echo 'Introduce una UUID de la siguiente lista:'
                	                        vboxmanage list floppies | egrep '(^UUID|^Location)'
                	                        echo 'UUID:'
                	                        read uuid
                        	                vboxmanage storageattach $1 --storagectl $controlador --type fdd --medium $uuid
                        	        else
                        	        	echo 'No tienes ninguna unidad de disquete en Virtualbox.'
                        	        fi
				fi
                	elif [[ $opcion = 5 ]]; then
                		cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
                	        read opcion2
                	        if [[ $opcion2 ]]; then
					echo "Rutas de unidades de DVD guardadas en Virtualbox:"
                	                vboxmanage list dvds | egrep '(^Location)'
                	                read ruta
                	                if [[ -e $ruta ]]; then
                	                	echo 'Ruta no encontrada.'
                	                else
                	                	vboxmanage storageattach $1 --storagectl $controlador --type dvddrive --medium $ruta
					fi
                	        elif [[ $opcion2 ]]; then
					echo "Rutas de discos duros guardadas en Virtualbox:"
                	                vboxmanage list hdds | egrep '(^Location)'
                        	        read ruta
                        	        if [[ -e $ruta ]]; then
                        	        	echo 'Ruta no encontrada.'
                        	        else
                        	                vboxmanage storageattach $1 --storagectl $controlador --type hdd --medium $ruta
					fi
                        	elif [[ $opcion2 ]]; then
					echo "Rutas de unidades de disquete guardadas en Virtualbox:"
                        	        vboxmanage list floppies | egrep '(^Location)'
                               		read ruta
                                	if [[ -e $ruta ]]; then
                                		echo 'Ruta no encontrada.'
                                	else
                                	        vboxmanage storageattach $1 --storagectl $controlador --type fdd --medium $ruta
					fi
				fi
                	elif [[ $opcion = 6 ]]; then
                		echo 'Introduce la unidad de máquina anfitrión que quieras usar:'
                	        read unidad
                	        cat ./menus/vmconfig/almacenamiento/tipoconexion.txt
                	        read opcion2
                	        if [[ $opcion2 = 2 ]]; then
                	        	echo 'Tipo de conexión no permitida.'
                	        else
                	                if [[ $opcion2 = 1 ]]; then
                	                	vboxmanage storageattach $1 --storagectl $controlador --type dvddrive --medium $unidad
                	                elif [[ $opcion2 = 3 ]]; then
                	                        vboxmanage storageattach $1 --storagectl $controlador --type fdd --medium $unidad
                	                fi
                	        fi
                	fi
                fi
	else
		echo "No hay ningún controlador en la máquina $1 con ese nombre."
	fi
	if [[ $numdispositivo = $null ]]; then
		if [[ $(vboxmanage showvminfo $1 | grep "$controlador ($numpuerto, 0)") ]]; then
			echo 'Conexión añadida.'
		else
			echo 'Error. Conexión no añadida.'
		fi
	else
		if [[ $(vboxmanage showvminfo $1 | grep "$controlador ($numpuerto, $numdispositivo)") ]]; then
                        echo 'Conexión añadida.'
                else
                        echo 'Error. Conexión no añadida.'
                fi
	fi
}

#Esta función configura las opciones de almacenamiento de una máquina virtual en Virtualbox.
#Para ello, se toma como referencia los diferentes menús alojados en ./menus/almacenamiento/.
#Acepta como argumento de entrada el nombre de la máquina virtual.
function f_config_almacenamiento {
	cat ./menus/vmconfig/almacenamiento/almacenamiento.txt
	read opcion
	while [[ $opcion != 5 ]]; do
		if [[ $opcion = 1 ]]; then
			f_añadecontrolador $1
		elif [[ $opcion = 2 ]]; then
                        f_eliminar_controlador $1
		elif [[ $opcion = 3 ]]; then
			f_modificar_conexion_almacenamiento $1
		elif [[ $opcion = 4 ]]; then
			f_modificar_controlador_almacenamiento $1
		else
			echo 'Opción incorrecta.'
		fi
		cat ./menus/vmconfig/almacenamiento/almacenamiento.txt
	        read opcion
	done
}

#Esta función configura la pestaña de audio en la configuración de una máquina virtual en Virtualbox.
#Acepta como argumento de entrada el nombre de la máquina virtual.
function f_config_audio {
	echo "¿Quieres habilitar el audio en la máquina $1? (s/n)"
	read res
	if [[ $res = 's' ]]; then
		cat ./menus/vmconfig/audio/ctlanfitrion.txt
		read opcion
		if [[ $opcion = 1 ]]; then
			audio='null'
		elif [[ $opcion = 2 ]]; then
			audio='oss'
		elif [[ $opcion = 3 ]]; then
			audio='alsa'
		elif [[ $opcion = 4 ]]; then
			audio='pulse'
		elif [[ $opcion = 5 ]]; then
			audio='coreaudio'
		else
			echo 'Opción incorrecta.'
		fi
		if [[ $audio != $null ]]; then
			echo '¿Quieres modificar otros atributos? (s/n)'
			read res2
			if [[ $res2 = 's' ]]; then
				cat ./menus/vmconfig/audio/opc_audio.txt
				read opcion2
				while [[ $opcion2 != 4 ]]; do
					if [[ $opcion2 = 1 ]]; then
						cat ./menus/vmconfig/audio/ctlaudio.txt
						read opcion3
						if [[ $opcion3 = 1 ]]; then
							ctl='ac97'
						elif [[ $opcion3 = 2 ]]; then
							ctl='sb16'
						elif [[ $opcion3 = 3 ]]; then
							ctl='hda'
						fi
					elif [[ $opcion2 = 2 ]]; then
						echo '¿Quieres habilitar la salida de audio? (s/n)'
						read res3
						if [[ $res3 = 's' ]]; then
							salida='on'
						elif [[ $res3 = 'n' ]]; then
							salida='off'
						fi
					elif [[ $opcion2 = 3 ]]; then
                                                echo '¿Quieres habilitar la entrada de audio? (s/n)'
                                                read res3
                                                if [[ $res3 = 's' ]]; then
                                                        entrada='on'
                                                elif [[ $res3 = 'n' ]]; then
                                                        entrada='off'
                                                fi
					else
						echo 'Opción incorrecta.'
					fi
					cat ./menus/vmconfig/audio/opc_audio.txt
                                	read opcion2
				done
				if [[ $ctl = $null && $entrada = $null && $salida = $null ]]; then
					vboxmanage modifyvm $1 --audio $audio
					echo 'Audio habilitado.'
				elif [[ $ctl = $null && $salida = $null ]]; then
					vboxmanage modifyvm $1 --audio $audio --audioin $entrada
                                        echo 'Audio habilitado.'
				elif [[ $ctl = $null && $entrada = $null ]]; then
					vboxmanage modifyvm $1 --audio $audio --audioout $salida
                                        echo 'Audio habilitado.'
				elif [[ $entrada = $null && $salida = $null ]]; then
					vboxmanage modifyvm $1 --audio $audio --audiocontroller $ctl
                                        echo 'Audio habilitado.'
				elif [[ $ctl = $null ]]; then
					vboxmanage modifyvm $1 --audio $audio --audioin $entrada --audioout $salida
                                        echo 'Audio habilitado.'
				elif [[ $entrada = $null ]]; then
					vboxmanage modifyvm $1 --audio $audio --audiocontroller $ctl --audioout $salida
                                        echo 'Audio habilitado.'
				elif [[ $salida = $null ]]; then
					vboxmanage modifyvm $1 --audio $audio --audiocontroller $ctl --audioin $entrada
                                        echo 'Audio habilitado.'
				else
					vboxmanage modifyvm $1 --audio $audio --audiocontroller $ctl --audioin $entrada --audioout $salida
                                        echo 'Audio habilitado.'
				fi
			else
				vboxmanage modifyvm $1 --audio $audio
				echo 'Audio habilitado.'
			fi
		fi
	else
		vboxmanage modifyvm --audio none
		echo 'Audio deshabilitado.'
	fi
}

#Esta función configura la pestaña de red en la configuración de una máquina virtual en Virtualbox.
#Acepta como argumento de entrada el nombre de la máquina virtual.
function f_config_red {
	echo 'Introduce el número de adaptador que quieras configurar:'
	read num
	echo '¿Qué tipo de red quieres asignarle al adaptador?'
	cat ./menus/vmconfig/red/adaptadores.txt
	read opcion
	if [[ $opcion = 1 ]]; then
		vboxmanage modifyvm $1 --nic$num none
	elif [[ $opcion = 2 ]]; then
		vboxmanage modifyvm $1 --nic$num null
	elif [[ $opcion = 3 ]]; then
		vboxmanage modifyvm $1 --nic$num nat
	elif [[ $opcion = 4 ]]; then
		vboxmanage modifyvm $1 --nic$num natnetwork
	elif [[ $opcion = 5 ]]; then
		vboxmanage modifyvm $1 --nic$num bridged
	elif [[ $opcion = 6 ]]; then
		vboxmanage modifyvm $1 --nic$num intnet
	elif [[ $opcion = 7 ]]; then
		vboxmanage modifyvm $1 --nic$num hostonly
	elif [[ $opcion = 8 ]]; then
		vboxmanage modifyvm $1 --nic$num generic
	else
		echo 'Opción incorrecta.'
	fi
	if [[ $opcion = 1 ]]; then
		continue
	elif [[ $opcion != $null ]]; then
		cat ./menus/vmconfig/red/opc_red.txt
		read opcion2
		while [[ $opcion2 != 8 ]]; do
			if [[ $opcion2 = 1 ]]; then
				if [[ $opcion = 2 || $opcion = 3 ]]; then
					echo 'Esta opción no está disponible para el tipo de red seleccionado.'
				else
					if [[ $opcion = 4 ]]; then
						echo 'Introduce el nombre de la interfaz:'
                                        	read nombre
						vboxmanage modifyvm $1 --nat-network$num $nombre
						if [[ $(vboxmanage showvminfo $1 | egrep "NIC $num:" | awk '{print $8}' | grep "$nombre") ]]; then
							echo 'Nombre modificado.'
						else
							echo 'Error. Nombre no modificado.'
						fi
					elif [[ $opcion = 5 ]]; then
						echo '¿Quieres especificar una interfaz? (s/n)'
                                                read res
                                                if [[ $res = 's' ]]; then
							vboxmanage modifyvm $1 --bridgeadapter$num $nombre
							if [[ $(vboxmanage showvminfo $1 | egrep "NIC $num:" | awk '{print $8}' | grep "$nombre") ]]; then
                	                                        echo 'Nombre modificado.'
                        	                        else
                                	                        echo 'Error. Nombre no modificado.'
                                        	        fi
						elif [[ $res = 'n' ]]; then
							vboxmanage modifyvm $1 --bridgeadapter$num none
						fi
					elif [[ $opcion = 6 ]]; then
						vboxmanage modifyvm $1 --intnet$num $nombre
						if [[ $(vboxmanage showvminfo $1 | egrep "NIC $num:" | awk '{print $8}' | grep "$nombre") ]]; then
                                                        echo 'Nombre modificado.'
                                                else
                                                        echo 'Error. Nombre no modificado.'
                                                fi
					elif [[ $opcion = 7 ]]; then
						echo '¿Quieres especificar una interfaz? (s/n)'
                                                read res
                                                if [[ $res = 's' ]]; then
							vboxmanage modifyvm $1 --hostonlyadapter$num $nombre
							if [[ $(vboxmanage showvminfo $1 | egrep "NIC $num:" | awk '{print $8}' | grep "$nombre") ]]; then
                                                                echo 'Nombre modificado.'
                                                        else
                                                                echo 'Error. Nombre no modificado.'
                                                        fi
						elif [[ $res = 'n' ]]; then
							vboxmanage modifyvm $1 --hostonlyadapter$num none
						fi
					elif [[ $opcion = 8 ]]; then
						vboxmanage modifyvm $1 --nicgenericdrv$num $nombre
						if [[ $(vboxmanage showvminfo $1 | egrep "NIC $num:" | awk '{print $8}' | grep "$nombre") ]]; then
                                                        echo 'Nombre modificado.'
                                                else
                                                	echo 'Error. Nombre no modificado.'
                                                fi
					fi
				fi
			elif [[ $opcion2 = 2 ]]; then
				cat ./menus/vmconfig/red/tiposadaptador.txt
				read opcion3
				if [[ $opcion3 = 1 ]]; then
					tipo='Am79C970A'
					vboxmanage modifyvm $1 --nictype$num Am79C970A
				elif [[ $opcion3 = 2 ]]; then
					tipo='Am79C973'
					vboxmanage modifyvm $1 --nictype$num Am79C973
				elif [[ $opcion3 = 3 ]]; then
					tipo='82540EM'
					vboxmanage modifyvm $1 --nictype$num 82540EM
				elif [[ $opcion3 = 4 ]]; then
					tipo='82543GC'
					vboxmanage modifyvm $1 --nictype$num 82543GC
				elif [[ $opcion3 = 5 ]]; then
					tipo='82545EM'
					vboxmanage modifyvm $1 --nictype$num 82545EM
				elif [[ $opcion3 = 6 ]]; then
					tipo='virtio'
					vboxmanage modifyvm $1 --nictype$num virtio
				fi
				echo "Tipo de adaptador seleccionado: $tipo"
			elif [[ $opcion2 = 3 ]]; then
				if [[ $opcion = 2 || $opcion = 3 || $opcion = 8 ]]; then
					echo 'Esta opción no está disponible para el tipo de red seleccionado.'
				else
					cat ./menus/vmconfig/red/modopromiscuo.txt
					read opcion3
					if [[ $opcion3 = 1 ]]; then
						vboxmanage modifyvm $1 --nicpromisc$num deny
						echo 'Modo promiscuo denegado.'
					elif [[ $opcion3 = 2 ]]; then
						vboxmanage modifyvm $1 --nicpromisc$num allow-vms
						echo 'Modo promiscuo permitido para todas las VM.'
					elif [[ $opcion3 = 3 ]]; then
						vboxmanage modifyvm $1 --nicpromisc$num allow-all
						echo 'Modo promiscuo permitido siempre.'
					fi
				fi
			elif [[ $opcion2 = 4 ]]; then
				echo '¿Quieres generar la MAC de manera automática? (s/n)'
				read res
				if [[ $res = 's' ]]; then
					vboxmanage modifyvm $1 --macaddress$num auto
					echo "Nueva MAC: $(vboxmanage showvminfo $1 | grep 'NIC $num:' | awk '{print $4}' | egrep -o '[0-9A-Z]*')"
				elif [[ $res = 'n' ]]; then
					echo 'Introduce la nueva MAC:'
					read mac
					vboxmanage modifyvm $1 --macaddress$num $mac
					echo "Nueva MAC: $(vboxmanage showvminfo $1 | grep 'NIC $num:' | awk '{print $4}' | egrep -o '[0-9A-Z]*')"
				fi
			elif [[ $opcion2 = 5 ]]; then
				echo '¿Quieres habilitar la opción de cable conectado? (s/n)'
				read res
				if [[ $res = 's' ]]; then
					vboxmanage modifyvm $1 --cableconnected$num on
					echo 'Cable conectado.'
				elif [[ $res = 'n' ]]; then
					vboxmanage modifyvm $1 --cableconnected$num off
					echo 'Cable desconectado.'
				fi
			elif [[ $opcion2 = 6 ]]; then
				if [[ $opcion = 3 ]]; then
					echo '¿Quieres (a)ñadir o (e)liminar una regla?'
					read res
					if [[ $res = 'a' ]]; then
						echo 'Dale un nombre a la nueva regla:'
						read nombre
						echo '¿(T)CP o (U)DP?'
						read protocolo
						if [[ $protocolo != 'T' || $protocolo != 'U' ]]; then
							echo 'Respuesta errónea.'
						else
							echo 'Puerto del host:'
							read hport
							echo 'Puerto de la máquina virtual:'
							read gport
							echo '¿Quieres especificar la IP del host? (s/n)'
							read res2
							if [[ $res2 = 's' ]]; then
								echo 'IP del host:'
								read iphost
							fi
							echo '¿Quieres especificar la IP de la máquina virtual? (s/n)'
							read res2
							if [[ $res2 = 's' ]]; then
                                                                echo 'IP de la máquina virtual:'
                                                                read ipguest
                                                        fi
							if [[ $iphost = $null && $ipguest = $null ]]; then
								vboxmanage modifyvm $1 --natpf$num $nombre,$protocolo,$hport,$gport
							elif [[ $iphost = $null ]]; then
								vboxmanage modifyvm $1 --natpf$num $nombre,$protocolo,$hport,$ipguest,$gport
							elif [[ $ipguest = $null ]]; then
								vboxmanage modifyvm $1 --natpf$num $nombre,$protocolo,$iphost,$hport,$gport
							else
								vboxmanage modifyvm $1 --natpf$num $nombre,$protocolo,$iphost,$hport,$ipguest,$gport
							fi
						fi
					elif [[ $res = 'e' ]]; then
						echo 'Introduce el nombre de la regla que quieres eliminar:'
						read nombre
						vboxmanage modifyvm $1 --natpf$num delete $nombre
					fi
				else
					echo 'Esta opción no está disponible para el tipo de red seleccionado.'
				fi
			elif [[ $opcion2 = 7 ]]; then
				if [[ $opcion = 8 ]]; then
					echo '¿Cuántos parámetros quieres pasar?'
					read cantidad
					for i in [1..$cantidad]; do
						echo 'Parámetro:'
						read par
						echo 'Valor del parámetro:'
						read valor
						vboxmanage modifyvm $1 --nicproperty$num $par="$valor"
					done
					echo 'Parámetros añadidos.'
				else
					echo 'Esta opción no está disponible para el tipo de red seleccionado.'
				fi
			else
				echo 'Opción incorrecta.'
			fi
			cat ./menus/vmconfig/red/opc_red.txt
                	read opcion2
		done
	fi
}

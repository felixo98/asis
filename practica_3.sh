#!/bin/bash
#746207, Garcia Rodrigez, Felix, T, 1, B
#737400, Echavarri Sola, Alvaro, T, 1, B 

if [[ $(id -u) != 0 ]] #El usuario efectivo distinto de 0
	then
		echo -e "Este script necesita privilegios de administracion"
		exit 1
fi

if [[ $1 != "-a" && $1 != "-s" ]]
	then
		>&2 echo "Opcion invalida"
		exit 1
fi

if [ $# != 2 ]
	then
  		>&2 echo "Numero incorrecto de parametros"
		exit 1
fi


#Caso añadir usuarios
if [[ $1 = "-a" ]]
	then
		while IFS=, read usuario contrasena nombre          #delimitador del fichero es ','
		do
		if [[ -z "$usuario" || -z "$contrasena" || -z "$nombre" ]]    #variables no vacias
			then
				echo "Campo invalido"
				exit 1
		fi
	
		if id -u "$usuario"  2>&1 >/dev/null #redirige la salida para que no se muestre 
			then
				echo "El usuario $usuario ya existe"
			else
				useradd -c "$nombre" "$usuario" -m -k /etc/skel -K UID_MIN=1815 -K PASS_MAX_DAYS=30 -U  # -K quita opciones por defecto , -U crea grupo mismo nombre , -m crea directorio home
				usermod -d "/home/$usuario" $usuario                          # -d cambia direccion de la carpeta home
				echo "$usuario:$contrasena" | chpasswd
				echo "$nombre ha sido creado"
		fi
	done < $2
fi

#Caso borrar usuarios
if [[ $1 = "-s" ]]
	then
		if [ ! -d "/extra/backup" ]						#Si no existe crea el directorio
		then
			mkdir -p "/extra/backup"					
		fi
		while IFS=, read usuario contrasena nombre     #delimitador fichero ','
		do
		if id -u "$usuario" >/dev/null 2>&1			   #Si existe el usuario (no muestra el mensaje)
		then
			if [ $( tar Pcfz "/extra/backup/$usuario.tar" "/home/$usuario")=0 ]       #Si se consigue crear la backup
			then
				userdel -f -r $usuario											  # -f -r para borrarlo aunque tenga sesion iniciada y borrar el directorio home
			fi
		fi
	done < $2
fi

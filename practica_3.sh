leerBorrar(){
    oldIFS=$IFS
    IFS=','
    mkdir -p /extra/backup
    while read nombre ignore
    do
        id $nombre 2> /dev/null > /dev/null
        if [ $? -eq 0 ]
        then
            uhome=$(cat /etc/passwd | egrep "$nombre" | grep -o ":/[^:]*:" | tr -d ':')
            tar -cvf /extra/backup/$nombre.tar $uhome 2> /dev/null > /dev/null
            if [ $? -eq 0 ]
            then
                userdel -r $nombre 2> /dev/null
            fi
        fi
        
    done < $1
    IFS=$oldIFS      
}

leerInsertar(){
    oldIFS=$IFS
    IFS=,
    while read nombre contrasena nomC
    do
        if [[ -z "$nombre" || -z "$contrasena" || -z "${nomC}" ]]
        then
            echo "Campo invalido"
        else
            useradd -c "$nomC" $nombre -m -k /etc/skel -K UID_MIN=1815 -U 2> /dev/null
            anyadido=$?
            if [ $anyadido -eq 9 ]
            then
                    echo "El usuario $nombre ya existe"
            elif [ $anyadido -eq 0 ]
            then
                usermod -f0 $nombre
                echo "${nombre}:$contrasena" | chpasswd
                passwd -x30 $nombre > /dev/null
     
                echo "$nomC ha sido creado"
            fi
        fi
    done < $1
    IFS=$oldIFS      
}



if [ $(id -u) -eq 0 ]
then
     if [ $# -ne 2 ]
     then
            echo "Numero incorrecto de parametros"
    else
        if [ $1 == "-a" ]
        then
            leerInsertar $2
        elif [ $1 == "-s" ]
        then
            leerBorrar $2
        else
            echo "Opcion invalida" >&2
        fi
    fi
else
    echo "Este script necesita privilegios de administracion"
    exit 1
fi
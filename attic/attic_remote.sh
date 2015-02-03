#!/bin/sh

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

REPOSITORY=$1

SERVER_IP="10.100.66.77"
SERVER_USER="attic"

for f in $REPOSITORY/clients/*.conf
do
    echo "$(date +%Y-%m-%d\ %H:%M) :::: INICIANDO RESPALDO DE $f"
    echo "$(date +%Y-%m-%d\ %H:%M) Leyendo variables."
    source $f

    if [ ! -f $REPOSITORY/logs/status ]; then
        echo "$(date +%Y-%m-%d\ %H:%M) Repositorios con errores de integridad. Saliendo."
        exit 1
    fi
	
    if [ "$HOST_AUTOBK" == "yes" ]; then
        
        echo "$(date +%Y-%m-%d\ %H:%M) Iniciando respaldo remoto."
        ssh $HOST_USER@$HOST_IP "sudo attic create --stats $HOST_EXCLUDE $SERVER_USER@$SERVER_IP:$REPOSITORY/data.attic::$HOST_NAME-$(date +%Y%m%d%H%M) $HOST_PATH"
            
        if [ $? -eq 0 ]; then
            echo "$(date +%Y-%m-%d\ %H:%M) Respaldo terminó correctamente."
            echo "$(date +%Y-%m-%d\ %H:%M) Actualizando último respaldo correcto para este cliente."
            date > $REPOSITORY/logs/$HOST_NAME.last
        else
            echo "$(date +%Y-%m-%d\ %H:%M) Respaldo terminó con problemas."
        fi

	echo "$(date +%Y-%m-%d\ %H:%M) Verificando integridad del repositorio"
        attic check $REPOSITORY/data.attic
		
        if [ $? -ne 0 ]; then
            echo "$(date +%Y-%m-%d\ %H:%M) Integridad comprometida. Saliendo."
            rm -f $REPOSITORY/logs/status
            exit 1
	else
            echo "$(date +%Y-%m-%d\ %H:%M) Integridad correcta."
        fi

        echo "$(date +%Y-%m-%d\ %H:%M) Actualizando último respaldo correcto."
        date > $REPOSITORY/logs/status

    fi
done

echo "$(date +%Y-%m-%d\ %H:%M) Eliminado logs antiguos"
find $REPOSITORY/logs/* -mtime +30 -exec rm {} \;

echo "$(date +%Y-%m-%d\ %H:%M) Saliendo."
exit 0

# IMPORTANTE: En windows xp tienen que tener instalado el rktools.exe, se descarga de microsoft download center.
#
# Script para realizar backup de un escritorio a un disco USB
# Directorio origen:%userprofile%\Documents o Documentos
# Destino: USB seleccionado en DIRDST= variable
#
# Author: Pablo Estigarribia 23/07/2015
# Modo de uso: Crear una carpeta "Respaldo" en la unidad de USB a usar para respaldo.
# Guardar el script con nombre backups_desktops.bat en c:\scripts (crear carpeta)
# Revisar los comentarios más abajo->
#
# Task scheduler windows:
# and to execute it:
# Execute with powershell and arguments:
# powershell -Executionpolicy Bypass -File C:\scripts\file.ps1
#
# Define variables

# Opciones de Robocopy, copia sin borrar, solo hace 1 reintento si falla
# Agregar /IPG:1 para enlaces lentos!!!!.
# /RH:1800-0600 "Run hours at desired start times"
$PROGRAM = "robocopy.exe"

$LOG_FILE = "C:\scripts\sync_files.log"
# Antes de iniciar el comando verifica que exista el archivo de prueba
# Mantener un archivo actualizado generando uno en el origen (este archivo va dentro del if que verifica si exite %DIRSRC%)
# echo Archivo de prueba origen > %DIRSRC%\prueba.txt

function copyfiles( $DIRSRC, $DIRDST ) {
    if (Test-Path  -Path $DIRSRC,$DIRDST) {
	    Write-Host "Copying $DIRSRC to $DIRDST"
        cmd /c "$PROGRAM" $DIRSRC $DIRDST /E /NP /W:0 /R:1  /IPG:1 /LOG+:$LOG_FILE
	}
	else {
	    Write-Host "$DIRSRC or $DIRDST is not reachable"
	}
}



# START COMMANDS
# Este comando se puede usar para respaldos por red,
# net use /user:Dominio\usuario "\\serverdestino\COMPARTIDO" Contraseña
#
# Execute first selection
copyfiles "\\servidor.ip\share\folder" "\\serverdestino\\COMPARTIDO\\folder"

# Add more selections like the previousone to sync more files
# You can also use local disks like c:\dir\dir2

#
# En la siguiente línea se debe quitar el comentario (#) si se usa una unidad de red
# para desconectar la misma:
# net use \\serverdestino\compartido /delete

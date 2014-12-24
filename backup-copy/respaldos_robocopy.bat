@echo off
:: IMPORTANTE: En windows xp tienen que tener instalado el rktools.exe, se descarga de microsoft download center. 
:: 
:: Script para realizar backup de un escritorio a un disco USB
:: Directorio origen:%userprofile%\Documents o Documentos
:: Destino: USB seleccionado en DIRDST= variable
:: 
:: Author: Pablo Estigarribia 17/10/2013
:: Modo de uso: Crear una carpeta "Respaldo" en la unidad de USB a usar para respaldo. 
:: IMPORTANTE: Crear un archivo test_connection.txt sin contenido dentro de la carpeta de destino en el disco o unidad de red para que el script pruebe la conexiÃ³n antes de empezar
:: Guardar el script con nombre backups_desktops.bat en c:\scripts (crear carpeta)
:: Revisar los comentarios mÃ¡s abajo->
:: 
:: Define variables

:: Opciones de Robocopy, copia sin borrar, solo hace 1 reintento si falla
:: Agregar /IPG:1 para enlaces lentos. 
set ROBOCOPY_OPTIONS=/E /NP /W:0 /R:1
set PROGRAM=robocopy.exe
:: START COMMANDS
:: Este comando se puede usar para respaldos por red, si se usa hay que cambiar DIRDST="K:\"
:: net use K: /user:Dominio\usuario "\\SERVIDOR.IP\COMPARTIDO" ContraseÃ±a
::
:: Execute first selection

:: Cambiar esta variable por la carpeta de origen que se desea respaldar, %userprofile% se refiere a c:\users\usuario en windows 7
set DIRSRC=%userprofile%\Documentos
:: Cambiar esta variable por el disco USB o unidad de red conectada que se desea usar: 
set DIRDST=E:\Respaldo\


set LOG_FILE=C:\scripts\C_Usuario_Documents_Respaldo.log
:: Antes de iniciar el comando verifica que exista el archivo de prueba
:: Mantener un archivo actualizado generando uno en el origen (este archivo va dentro del if que verifica si exite %DIRSRC%)
:: echo Archivo de prueba origen > %DIRSRC%\prueba.txt

if exist %DIRDST%\test_connection.txt (
echo Archivo de prueba origen > %DIRSRC%\prueba.txt
%PROGRAM% "%DIRSRC%" "%DIRDST%" %ROBOCOPY_OPTIONS% /LOG:%LOG_FILE% 
) else ( 
        echo No esta conectado %DIRDST% > %LOG_FILE%
)


::
:: Esta línea se debe quitar el comentario (::) si se usa una unidad de red: 
:: net use K: /delete
:: La línea anterior desconecta la unidad K: 
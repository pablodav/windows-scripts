@echo off
:: This is a start sqlcmd intent to avoid usage of same lines in script repeatedly. 
:: This script was created by Pablo Estigarribia at 09/12/2014. 
:: Version 3

set SQL_SCRIPTS=E:\SQL_SCRIPTS
set LOG_FOLDER=%SQL_SCRIPTS%\Logs

if not exist "%LOG_FOLDER%" (
md %LOG_FOLDER%
)

:: References for variables with sqlcmd and use in .sql file called from sqlcmd
:: http://msdn.microsoft.com/en-us/library/ms188714.aspx

:: Usage: sqlcommon.bat variables_dbname.bat TYPE 
:: type could be: (full/diff)
:: variables_dbname.bat should contain:
:: set SERVER=Server\instance (\instance only is needed if it is not default)
:: set DATABASE=databasename
:: set BACKUP_FOLDER=backupfolder
:: set BACKUP_FILE=%BACKUP_FOLDER%\%DATABASE%_FULL.BAK

set BVARIABLES=%1
set BACKUPTYPE=%2
call %BVARIABLES%

set LOG_FILE=%LOG_FOLDER%\%DATABASE%.log.txt

echo Server is %SERVER% > %LOG_FILE%
echo Database is %DATABASE% >> %LOG_FILE%
echo Backup file is %BACKUP_FILE% >> %LOG_FILE%
echo Backup type is %BACKUPTYPE% >> %LOG_FILE%
echo Log file is %LOG_FILE% >> %LOG_FILE%

IF %BACKUPTYPE%==diff (
call:differential
)
IF %BACKUPTYPE%==full (
call:full
)

sqlcmd -S %SERVER% -Q "BACKUP DATABASE [$(DATABASE)] TO  DISK = N'$(BACKUP_FILE)' WITH $(BTYPE),  NAME = N'BACKUP $(DATABASE) $(BACKUPTYPE)', SKIP, NOREWIND, NOUNLOAD,  STATS = 10" >> %LOG_FILE%
sqlcmd -S %SERVER% -Q "BACKUP LOG [$(DATABASE)] TO  DISK = '$(BACKUP_FILE)'" >> %LOG_FILE%
IF %BACKUPTYPE%==full (
echo shrink the database >> %LOG_FILE%
sqlcmd -S %SERVER% -Q "DBCC SHRINKDATABASE ($(DATABASE), 10)" >> %LOG_FILE%
)

:differential
set BTYPE=DIFFERENTIAL, NOFORMAT, NOINIT
goto:eof

:full
set BTYPE=NOFORMAT, INIT
goto:eof

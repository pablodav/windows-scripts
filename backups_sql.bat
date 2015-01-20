@echo off
:: This is a start sqlcmd intent to avoid usage of same lines in script repeatedly. 
:: This script was created by Pablo Estigarribia at 19/12/2014. 
:: Version 4

::Set log folder working with "Working directory"
set SQL_SCRIPTS=%CD%
set LOG_FOLDER=%SQL_SCRIPTS%\Logs

::Create log folder if not exist
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

::Set variables coming from command line sqlcommon.bat %1 %2
set BVARIABLES=%1
set BACKUPTYPE=%2
::Execute variables_dbname.bat from %1 to set variables for example above.
call %BVARIABLES%
::Set log file utilizing database name.
set LOG_FILE=%LOG_FOLDER%\%DATABASE%.log.txt

echo Server is %SERVER% > %LOG_FILE%
echo Database is %DATABASE% >> %LOG_FILE%
echo Backup file is %BACKUP_FILE% >> %LOG_FILE%
echo Log file is %LOG_FILE% >> %LOG_FILE%

::Setting variables from :differential or :full and continue.
IF %BACKUPTYPE%==diff (
call:differential
)
IF %BACKUPTYPE%==full (
call:full
)

::Verify if option %2 was full or diff and exit with error if it does not exist.
if %BTYPEVAR==OK (
echo BTYPEVAR is ok, continue with backup script >> %LOG_FILE%
echo Backup type is %BACKUPTYPE% >> %LOG_FILE%
) else (
echo BTYPEVAR is wrong, it's %BACKUPTYPE% but must be exactly full or diff case sensitive, end backup script >> %LOG_FILE%
exit /B 2
)

::Execute backup of sql server.
sqlcmd -S %SERVER% -Q "BACKUP DATABASE [$(DATABASE)] TO  DISK = N'$(BACKUP_FILE)' WITH $(BTYPE),  NAME = N'BACKUP $(DATABASE) $(BACKUPTYPE)', SKIP, NOREWIND, NOUNLOAD,  STATS = 10" >> %LOG_FILE%
sqlcmd -S %SERVER% -Q "BACKUP LOG [$(DATABASE)] TO  DISK = '$(BACKUP_FILE)'" >> %LOG_FILE%

::Execute shrink of database only if backup was full.
IF %BACKUPTYPE%==full (
echo shrink the database >> %LOG_FILE%
sqlcmd -S %SERVER% -Q "DBCC SHRINKDATABASE ($(DATABASE), 10)" >> %LOG_FILE%
)

:differential
set BTYPE=DIFFERENTIAL, NOFORMAT, NOINIT
set BTYPEVAR=OK
goto:eof

:full
set BTYPE=NOFORMAT, INIT
set BTYPEVAR=OK
goto:eof

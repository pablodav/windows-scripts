# Create c:\scripts\logs
# Run this file with:
# powershell -Executionpolicy Bypass -File C:\scripts\move_files_by_year.ps1

$LOG_FOLDER='C:\scripts\logs'
$LOG_FILE=Join-Path $LOG_FOLDER + 'move_files.log.txt'

function logging ($msg) {
  $logtime = Get-Date -Format u
  if ( $log_level -eq "1" ) {
      Add-Content $LOG_FILE "$logtime : $msg"
  }
}

# obtained from: http://www.thomasmaurer.ch/2015/03/move-files-to-folder-sorted-by-year-and-month-with-powershell/
# Get the files which should be moved, without folders
$files = Get-ChildItem 'c:\path\to\origen' -Recurse | where {!$_.PsIsContainer}

# List Files which will be moved
logging "Files to move: "
logging "$files"

# Target Filder where files should be moved to. The script will automatically create a folder for the year and month.
$targetPath = 'C:\path\destino'

foreach ($file in $files)
{
    # Get year and Month of the file
    # I used LastWriteTime since this are synced files and the creation day will be the date when it was synced
    $year = $file.LastWriteTime.Year.ToString()
    $month = $file.LastWriteTime.Month.ToString()

    # Out FileName, year and month
    logging "Moving file: $file.Name with:"
    logging "Year: $year"
    logging "Month: $month"

    # Set Directory Path
    $directory = $targetPath + "\" + $year + "\" + $month
    logging "To: $directory"
    # Create directory if it doesn't exsist
    if (!(Test-Path $directory))
        {
        New-Item $directory -type directory
    }

    # Move File to new location
    $file | Move-Item -Destination $directory
}

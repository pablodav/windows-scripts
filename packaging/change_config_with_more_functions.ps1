# Powershell
# Script to modify configuration files
# Options: 
# initialchange 

# Set variables to change a file
$original_file = "$env:programfiles\burp\burp.conf"
# Set temp file if the original file will be modified
# Set dest file if the original will be used and is a template
$destination_file =  "$env:temp\burp.conf"


#Set location code if needed
$Locationcode = "$env:Locationcode"
switch ($Locationcode) {
    L240 { $SERVERADDRESS = "IP.ADD.RE.SS" }
    default { $SERVERADDRESS = "IP.ADD.RE.SS" }
}

$CLIENTNAME = "$env:computername"

#Call with initialchange if you are working with initial installation. 
function initialchange {
    $lookupTable = @{
    'server = SERVERIPADDRESS' = "server = $SERVERADDRESS"
    'cname = CLIENTNAME' = "cname = $CLIENTNAME"
    }
    Modifyfile
}

# Function to modify a file from original file
function Modifyfile ($x) 
{
    Get-Content -Path $original_file | ForEach-Object { 
        $line = $_

        $lookupTable.GetEnumerator() | ForEach-Object {
            if ($line -match $_.Key)
            {
                $line = $line -replace $_.Key, $_.Value
            }
        }
       $line
    } | Set-Content -Path $destination_file
    # Modify the original file using a temp file if called with orig parameter
    if ($x -Match 'orig') {
       Copy-Item $destination_file $original_file -Force
    }   
}

# Call with post 0 for post backup script
# it will not change the file if backup was not successfull
function post ($x)
{
    if($x -eq 0) {
        $lookupTable = @{
        'ratelimit = 10' = "ratelimit = 1"
        }
        #Call function modifyfile
        Modifyfile orig
    }
}


# Call with pre for pre backup script
function pre{
    $lookupTable = @{
    'ratelimit = 1' = "ratelimit = 10"
    }
    #Call function modifyfile
    Modifyfile orig
}


#Examples: 

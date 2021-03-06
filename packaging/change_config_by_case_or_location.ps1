$Locationcode = "$env:Locationcode"
switch ($Locationcode) {
    Location1 { $SERVERADDRESS = "IP.ADD.RE.SS" }
    default { $SERVERADDRESS = "IP.ADD.RE.SS" }
}

$CLIENTNAME = "$env:computername"

$lookupTable = @{
'server = SERVERIPADDRESS' = "server = $SERVERADDRESS"
'cname = CLIENTNAME' = "cname = $CLIENTNAME"
}

# Function to generate the configuration for the client. 
$original_file = "$env:temp\originalfolder\template.conf"
$destination_file =  "C:\Program Files\someprog\someprog.conf"

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
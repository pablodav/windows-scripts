# Powershell
# Script to modify configuration files
# Pablo Estigarribia
# 
# 
#Examples: 
# burp_clientconfig3.ps1 pre
# burp_clientconfig3.ps1 post 0
# burp_clientconfig3.ps1 initialchange


$function = $args[0]
$level = $args[1]
 
Write-host $function
Write-host $level

$original_file = "$env:programfiles\burp\burp.conf"
# Set temp file if the original file will be modified
$destination_file =  "$env:temp\burp.conf"


#Set location code if needed
$Locationcode = "$env:Locationcode"
switch ($Locationcode) {
    LOC1 { $SERVERADDRESS = "ip.add.rr.ess" }
    default { $SERVERADDRESS = "ip.add.rr.ess" }
}

$CLIENTNAME = "$env:computername"

#Function to modify configuration files
# Extracted from http://stackoverflow.com/questions/15662799/powershell-function-to-replace-or-add-lines-in-text-files
function setConfig( $file, $key, $value ) {
    $content = Get-Content $file
    if ( $content -match "^$key\s*=" ) {
        $content -replace "^$key\s*=.*", "$key = $value" |
        Set-Content $file     
    } else {
        Add-Content $file "$key = $value"
    }
}

# Call with post 0 for post backup script
# it will not change the file if backup was not successfull
function post ($x)
{
    if($x -eq 0) {
        setConfig $original_file "ratelimit" "1"
    }
}


# Call with pre for pre backup script
function pre{
    setConfig $original_file "ratelimit" "5"
}

#Call with initialchange if you are working with initial installation. 
function initialchange {
    setConfig $original_file "ratelimit" "5"
    setConfig $original_file "server" "$SERVERADDRESS"
    setConfig $original_file "cname" "$CLIENTNAME"
    setConfig $original_file "backup_script_post" "C:/Program Files/Burp/burp_clientconfig3.bat"
}


switch ($function) {
    pre { pre }
    post { post $level }
    initialchange { initialchange }
}
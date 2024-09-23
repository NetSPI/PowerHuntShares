# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-BootstrapConfig {
    param (
        [string]$FilePath
    )

    # Read all lines from the provided file path
    $iniContent = Get-Content -Path $FilePath

    # Initialize a hash table to store key-value pairs
    $fields = @{
        Username = $null
        Password = $null
        Public   = $null
        Private  = $null
        Key      = $null
        Secret   = $null
    }

    # Loop through each line and look for the required fields
    foreach ($line in $iniContent) {
        if ($line -match 'username\s*=\s*(.*)') {
            $fields['Username'] = $matches[1].Trim()
        }
        if ($line -match 'password\s*=\s*(.*)') {
            $fields['Password'] = $matches[1].Trim()
        }
        if ($line -match 'public\s*=\s*(.*)') {
            $fields['Public'] = $matches[1].Trim()
        }
        if ($line -match 'private\s*=\s*(.*)') {
            $fields['Private'] = $matches[1].Trim()
        }
        if ($line -match 'key\s*=\s*(.*)') {
            $fields['Key'] = $matches[1].Trim()
        }
        if ($line -match 'secret\s*=\s*(.*)') {
            $fields['Secret'] = $matches[1].Trim()
        }
    }

    # Convert the hash table into a custom PowerShell object
    $configObject = [PSCustomObject]$fields

    # Output the custom object
    return $configObject
}

# Example call using the example file path
$bootstrapIniPath = "c:\temp\configs\bootstrap.ini"
$config = Get-BootstrapConfig -FilePath $bootstrapIniPath

# Output the result
$config


<# bootstrap.ini

[GeneralSettings]
username=adminUser
password=P@ssw0rd123
timeout=30
loglevel=info
public=public
private=mysecret
secret=mysecret 
key=mykey

[DatabaseSettings]
db_name=my_database
db_host=localhost
db_port=3306

[NetworkSettings]
protocol=http
port=8080

#>

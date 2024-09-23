# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-PhpIniCredentials {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Initialize a hashtable to store extracted values
    $configData = @{
        Username = $null
        Password = $null
    }

    # Check if the file exists
    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Read the configuration file
    $configFile = Get-Content -Path $FilePath

    # Parse the configuration file line by line
    foreach ($line in $configFile) {
        # Ignore comment lines and empty lines
        if ($line -match '^\s*;' -or $line -match '^\s*$') {
            continue
        }

        # Extract the username (e.g., mysql.default_user)
        if ($line -match '^\s*mysql\.default_user\s*=\s*"(.+)"') {
            $configData.Username = $matches[1].Trim()
        }

        # Extract the password (e.g., mysql.default_password)
        if ($line -match '^\s*mysql\.default_password\s*=\s*"(.+)"') {
            $configData.Password = $matches[1].Trim()
        }
    }

    # Output the extracted configuration as a PowerShell object
    [PSCustomObject]@{
        Username = $configData.Username
        Password = $configData.Password
    }
}

# Example usage:
$credentials = Get-PhpIniCredentials -FilePath "c:\temp\configs\php.ini"
$credentials | Format-List


<# php.ini - storing mysql credentials


[PHP]
; Basic PHP settings

; Maximum size of POST data allowed
post_max_size = 8M

; Maximum allowed size for uploaded files
upload_max_filesize = 2M

; INSECURE: Storing database credentials in php.ini (not recommended)
; This exposes credentials to anyone with access to php.ini or via phpinfo() if not secured.

mysql.default_user = "dbuser"
mysql.default_password = "P@ssw0rd123"
mysql.default_host = "localhost"
mysql.default_database = "example_db"

; Log errors to a file
log_errors = On
error_log = /var/log/php_errors.log

; Ensure that this option is Off to avoid disclosing sensitive configuration details
expose_php = Off

; Ensure that phpinfo() is secured or disabled to prevent exposure of configuration data
disable_functions = phpinfo


#>
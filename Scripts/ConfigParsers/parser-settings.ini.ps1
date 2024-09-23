# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-IniCredentials {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Initialize an array to store the credentials
    $credentials = @()

    # Check if the file exists
    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Read the INI file content
    $iniFile = Get-Content -Path $FilePath

    # Initialize variables to track current section and credentials
    $currentSection = ""
    $username = $null
    $password = $null

    # Parse the INI file line by line
    foreach ($line in $iniFile) {
        # Ignore comment lines and empty lines
        if ($line -match '^\s*;' -or $line -match '^\s*$') {
            continue
        }

        # Detect section headers (e.g., [DatabaseSettings])
        if ($line -match '^\s*\[(.+)\]\s*$') {
            # If we have collected username and password, store them before moving to the next section
            if ($username -and $password) {
                $credentials += [PSCustomObject]@{
                    Section   = $currentSection
                    Username  = $username
                    Password  = $password
                }
            }
            # Reset username and password for the new section
            $username = $null
            $password = $null

            # Update current section
            $currentSection = $matches[1].Trim()
            continue
        }

        # Match username and password in the lines
        if ($line -match '^\s*username\s*=\s*(.+)$') {
            $username = $matches[1].Trim()
        } elseif ($line -match '^\s*password\s*=\s*(.+)$') {
            $password = $matches[1].Trim()
        } elseif ($line -match '^\s*user\s*=\s*(.+)$') {
            $username = $matches[1].Trim()
        } elseif ($line -match '^\s*pass\s*=\s*(.+)$') {
            $password = $matches[1].Trim()
        }
    }

    # Capture any remaining username/password pair after the last section
    if ($username -and $password) {
        $credentials += [PSCustomObject]@{
            Section   = $currentSection
            Username  = $username
            Password  = $password
        }
    }

    # Output the credentials as PowerShell objects
    return $credentials
}

# Example usage:
$parsedCredentials = Get-IniCredentials -FilePath "c:\temp\configs\setting.ini"
$parsedCredentials | Format-Table -AutoSize



<# setting.ini

[GeneralSettings]
app_name = MyApp
version = 1.0.0
theme = dark

[DatabaseSettings]
host = localhost
port = 3306
username = dbuser
password = dbpass

[CustomSettings]
user = myuser
pass = mypass

[Logging]
log_level = DEBUG
log_file = /var/log/myapp.log

#>
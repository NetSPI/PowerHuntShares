# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-PgPassCredentials {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Ensure the file exists
    if (-Not (Test-Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Read the .pgpass file
    $pgpassEntries = Get-Content -Path $FilePath

    # Array to store the extracted credentials
    $credentialsList = @()

    # Loop through each line in the .pgpass file
    foreach ($entry in $pgpassEntries) {
        # Skip comments and empty lines
        if ($entry -match '^\s*#' -or $entry -match '^\s*$') {
            continue
        }

        # Split the line by colon, expecting the format: hostname:port:database:username:password
        $fields = $entry -split ':'

        if ($fields.Length -eq 5) {
            # Create a custom object for each entry
            $credential = [PSCustomObject]@{
                Hostname = $fields[0]
                Port     = $fields[1]
                Database = $fields[2]
                Username = $fields[3]
                Password = $fields[4]
            }

            # Add the credential object to the list
            $credentialsList += $credential
        }
        else {
            Write-Warning "Invalid format in entry: $entry"
        }
    }

    # Output the results as a PowerShell object
    return $credentialsList
}

# Example usage:
$pgpassCredentials = Get-PgPassCredentials -FilePath "c:\temp\configs\.pgpass"
$pgpassCredentials

<# .pgpass file - used for postgres

# Format: hostname:port:database:username:password

# Local database connection
localhost:5432:mydatabase:myuser:mypassword

# Remote database connection
remote.server.com:5432:anotherdb:anotheruser:anotherpassword

# Default connection for any database on localhost
localhost:*:*:defaultuser:defaultpassword

# Wildcard example: Any database and any user connecting to localhost
localhost:*:*:*:supersecretpassword


#>
# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Extract-OracleCredentials {
    param(
        [string]$FilePath
    )

    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "File path does not exist: $FilePath"
        return
    }

    # Initialize an empty array to store the results
    $credentialsList = @()

    # Read the file contents
    $fileContent = Get-Content -Path $FilePath

    # Initialize variables to store temporary values
    $currentDatabase = $null
    $currentUser = $null
    $currentPassword = $null

    foreach ($line in $fileContent) {
        # Trim the line for easier processing
        $line = $line.Trim()

        # Match a database name (lines that don't start with a '(' and end with '=')
        if ($line -match '^\w+\s*=\s*$') {
            if ($currentDatabase -and $currentUser -and $currentPassword) {
                # Store the previous credentials
                $credentialsList += [pscustomobject]@{
                    Database = $currentDatabase
                    User     = $currentUser
                    Password = $currentPassword
                }
            }

            # Reset the user and password for the next database entry
            $currentDatabase = $line -replace '\s*=\s*$', '' # Remove the equals sign
            $currentUser = $null
            $currentPassword = $null
        }

        # Match the USER line
        if ($line -match 'USER\s*=\s*(.+)$') {
            $currentUser = $matches[1]
        }

        # Match the PASSWORD line
        if ($line -match 'PASSWORD\s*=\s*(.+)$') {
            $currentPassword = $matches[1]
        }
    }

    # Capture the last set of credentials
    if ($currentDatabase -and $currentUser -and $currentPassword) {
        $credentialsList += [pscustomobject]@{
            Database = $currentDatabase
            User     = $currentUser
            Password = $currentPassword
        }
    }

    # Output the results as a list of objects
    return $credentialsList
}

# Example usage:
$result = Extract-OracleCredentials -FilePath "c:\temp\configs\tnsnames.ora"
$result | Format-Table



<# tnsnames.ora - oracle

MYDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = mydbserver.example.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVICE_NAME = mydbservice)
    )
  )
  (USER = myusername)
  (PASSWORD = mypassword)

MYDB_ALIAS =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = mydbserver.example.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = mydbservice)
    )
  )
  (USER = anotheruser)
  (PASSWORD = anotherpassword)

  #>
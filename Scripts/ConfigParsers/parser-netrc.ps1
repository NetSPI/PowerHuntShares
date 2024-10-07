# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# Intended input: .netrc file
function Get-PwNetrc {
    param (
        [string]$ComputerName = $null,   # Optional
        [string]$ShareName    = $null,   # Optional
        [string]$UncFilePath  = $null,   # Optional
        [string]$FileName     = $null,   # Optional
        [string]$FilePath                # Required
    )

    # Initialize an array to store parsed entries
    $entries = @()

    # Read file contents
    $fileContent = Get-Content -Path $FilePath -ErrorAction Stop

    # Initialize variables for each entry
    $currentEntry = @{
        ComputerName = $ComputerName
        ShareName    = $ShareName
        UncFilePath  = $UncFilePath
        FileName     = $FileName
        Section      = "NA"
        ObjectName   = "NA"
        TargetURL    = "NA"
        TargetServer = "NA"
        TargetPort   = "NA"
        Database     = "NA"
        Domain       = "NA"
        Username     = "NA"
        Password     = "NA"
        PasswordEnc  = "NA"
        KeyFilePath  = "NA"
    }

    # Parse lines from the .netrc file
    foreach ($line in $fileContent) {
        # Match each .netrc directive with regex
        if ($line -match "^machine\s+(\S+)") {
            # If an entry already exists, add it to the array
            if ($currentEntry.TargetServer -ne "NA") {
                $entries += [pscustomobject]$currentEntry
            }
            # Start a new entry
            $currentEntry.TargetServer = $matches[1]
            $currentEntry.Username = "NA"
            $currentEntry.Password = "NA"
        }
        elseif ($line -match "^login\s+(\S+)") {
            $currentEntry.Username = $matches[1]
        }
        elseif ($line -match "^password\s+(\S+)") {
            $currentEntry.Password = $matches[1]
        }
    }

    # Add the last entry if present
    if ($currentEntry.TargetServer -ne "NA") {
        $entries += [pscustomobject]$currentEntry
    }

    # Output the result
    return $entries
}

# Sample command
# Get-PwNetrc -ComputerName "MyComputer" -ShareName "MyShare" -UncFilePath "\\MyComputer\MyShare\netrc" -FileName ".netrc" -FilePath "C:\temp\.netrc"

<# .netrc sample file

# Sample .netrc file

# Configuration for accessing example.com
machine example.com
login exampleuser
password examplepass

# Configuration for accessing another-site.com
machine another-site.com
login anotheruser
password anotherpass

# Configuration for accessing an FTP server at ftp.myserver.com
machine ftp.myserver.com
login ftpuser
password ftppass

# Configuration with an account for systems that require it
machine account-required.com
login myuser
password mypassword
account myaccount

# Wildcard for default login when no specific machine is specified
default
login defaultuser
password defaultpass

#>

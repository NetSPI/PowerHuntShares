# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-PureFtpCredentials {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Check if the file exists
    if (-Not (Test-Path $FilePath)) {
        Write-Error "The file at path $FilePath does not exist."
        return
    }

    # Initialize an array to store user credentials
    $credentials = @()

    # Read the file line by line
    Get-Content $FilePath | ForEach-Object {
        # Skip empty lines
        if ($_ -match '^\s*$') { return }

        # Split the line into components using ':' as delimiter
        $fields = $_ -split ':'

        # Check if we have at least the username and password fields
        if ($fields.Length -ge 2) {
            $username = $fields[0]
            $passwordHash = $fields[1]

            # Create a custom object for each user
            $credentialObject = [PSCustomObject]@{
                Username     = $username
                PasswordHash = $passwordHash
            }

            # Add the object to the credentials array
            $credentials += $credentialObject
        } else {
            Write-Error "The line '$_' does not contain enough fields."
        }
    }

    # Output the results as a PowerShell object array
    return $credentials
}


$ftpCredentials = Get-PureFtpCredentials -FilePath "c:\temp\configs\pureftpd.passwd"
$ftpCredentials | Format-Table


<# pureftpd.passwd - used by pureftpd, passwords stored as MD5 or SHA-1 hash

username:$1$X9p2ER8W$M7P5CxX5CHPxuAiB5BBJq/:1001:1001::/home/ftp/username:/bin/false::
user2:$1$XYz3ERzW$G9P7CxF6CPxxuAiB6BBJq/:1002:1002::/home/ftp/user2:/bin/false::


#>
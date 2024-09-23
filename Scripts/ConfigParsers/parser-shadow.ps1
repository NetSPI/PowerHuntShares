# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)


function Get-ShadowFileCredentials {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Initialize an array to store extracted user data
    $credentials = @()

    # Check if the file exists
    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Read the shadow file
    $shadowFile = Get-Content -Path $FilePath

    # Parse each line in the shadow file
    foreach ($line in $shadowFile) {
        # Ignore empty lines or comments (if any)
        if ($line -match '^\s*$' -or $line -match '^\s*#') {
            continue
        }

        # Split the line into fields using colon as a delimiter
        $fields = $line -split ':'

        # Extract username and password hash
        $username = $fields[0]
        $passwordHash = $fields[1]

        # Create an object to store the extracted information
        $userObject = [PSCustomObject]@{
            Username     = $username
            PasswordHash = $passwordHash
        }

        # Add the object to the array
        $credentials += $userObject
    }

    # Output the array of credentials
    return $credentials
}

# Example usage:
$shadowData = Get-ShadowFileCredentials -FilePath "c:\temp\configs\shadow"
$shadowData | Format-Table -AutoSize


<# shadow - linux password file

root:$6$examplehash$E5iNRLtC5/j/kCkRhYlOro.Y9PzE0Gv8jlsfLZUNwlEm7HMBZSO9.mUvefOrKT6BjKSO4obQ.EtCZKhQgmgwV0:19000:0:99999:7:::
user1:$6$examplehash$OwhxlyS5hoxfFE4tmtyOR8Hw1k8PLqokP9FYxYP8QMG3wO0u.0Xvd4g/0Udr6BQZilJk4k7XwlxJ6p0RJ2IL5/:19000:0:99999:7:::
nobody:*:19000:0:99999:7:::
daemon:*:19000:0:99999:7:::

#>
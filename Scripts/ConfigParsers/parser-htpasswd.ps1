# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-HtpasswdContent {
    param (
        [string]$FilePath
    )

    # Check if the file exists
    if (-Not (Test-Path $FilePath)) {
        Write-Error "File not found at path: $FilePath"
        return
    }

    # Read the file contents
    $lines = Get-Content $FilePath

    # Initialize an array to store user objects
    $users = @()

    # Process each line
    foreach ($line in $lines) {
        # Split each line into username and hashed password
        $parts = $line -split ':', 2
        if ($parts.Length -eq 2) {
            # Create a custom object for each user
            $userObj = [pscustomobject]@{
                Username = $parts[0]
                PasswordHash = $parts[1]
            }
            # Add the user object to the array
            $users += $userObj
        }
    }

    # Output the results
    return $users
}

# Example usage
$result = Get-HtpasswdContent -FilePath "c:\temp\configs\.htpasswd"
$result

<# .htpasswd

user1:$apr1$5lRQ1y3v$pmOQf9/fNVE5dTtQDBl9D1
user2:$apr1$Jd9UE91p$J/H8G9HSvj5l8LKQ2qfd3.
admin:$apr1$GZJoqjNF$wl8IjDhZC84z5Bb4wHOv50


#>
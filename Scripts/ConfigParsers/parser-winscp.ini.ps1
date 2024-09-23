# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-WinSCPConfig {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Check if file exists
    if (-not (Test-Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Read the WinSCP.ini file content
    $content = Get-Content -Path $FilePath

    # Initialize an empty object for results
    $result = [PSCustomObject]@{
        HostName       = $null
        PortNumber     = $null
        PrivateKeyFile = $null
        UserName       = $null
        Password       = $null
    }

    # Parse the .ini file for relevant information
    foreach ($line in $content) {
        if ($line -match '^HostName=(.*)') {
            $result.HostName = $matches[1]
        } elseif ($line -match '^PortNumber=(.*)') {
            $result.PortNumber = [int]$matches[1]
        } elseif ($line -match '^PrivateKeyFile=(.*)') {
            $result.PrivateKeyFile = $matches[1]
        } elseif ($line -match '^UserName=(.*)') {
            $result.UserName = $matches[1]
        } elseif ($line -match '^Password=(.*)') {
            $result.Password = $matches[1]  # Encrypted password in .ini
        }
    }

    # Return the result object
    return $result
}

# Example usage
$winSCPConfig = Get-WinSCPConfig -FilePath "c:\temp\configs\WinSCP.ini"
$winSCPConfig

<# winscp decryption function that uses dpapi below

function ConvertFrom-DPAPI {
    param (
        [Parameter(Mandatory = $true)]
        [string]$EncryptedPassword
    )

    # Convert the base64 encoded password back to byte array
    $passwordBytes = [Convert]::FromBase64String($EncryptedPassword)

    # Use the Windows DPAPI to decrypt the password
    $decryptedBytes = [System.Security.Cryptography.ProtectedData]::Unprotect($passwordBytes, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)

    # Convert the decrypted byte array back to a string (UTF-8 encoded)
    $decryptedPassword = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)

    return $decryptedPassword
}

# Example usage with an encrypted password from WinSCP.ini
$encryptedPassword = "Base64EncryptedPasswordHere"
$decryptedPassword = ConvertFrom-DPAPI -EncryptedPassword $encryptedPassword
Write-Output "Decrypted Password: $decryptedPassword"


#>


<# winscp.ini


[Configuration\Interface]
Random=4074A9829D979781989E96

[Sessions\example]
HostName=ftp.example.com
PortNumber=21
UserName=myuser
Password=0V5aNH+/kT8=  ; Encrypted password
LocalDirectory=C:\Users\myuser\Documents
RemoteDirectory=/public_html
FSProtocol=0
PostLoginCommands=
PrivateKeyFile=

[Configuration\Interface\Commander]
LastLocalDirectory=C:\Users\myuser\Documents
LastRemoteDirectory=/public_html


#>
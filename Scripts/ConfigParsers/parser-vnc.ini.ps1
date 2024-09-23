# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
function Get-VNCPassword {
    param (
        [Parameter(Mandatory=$true)]
        [string]$VncIniPath
    )

    # Define the fixed DES key used by VNC
    $desKey = [byte[]](0x23, 0x52, 0x6A, 0x3B, 0x58, 0x92, 0x67, 0x34)

    # Read the vnc.ini file
    if (-Not (Test-Path -Path $VncIniPath)) {
        Write-Error "The file path '$VncIniPath' does not exist."
        return
    }

    $vncIniContent = Get-Content -Path $VncIniPath

    # Extract the encrypted password from the ini file
    $encryptedHex = ($vncIniContent | ForEach-Object {
        if ($_ -match '^Password=(.+)$') {
            return $matches[1]
        }
    }).Trim()

    if (-not $encryptedHex) {
        Write-Output "Password not found in vnc.ini"
        return
    }

    # Convert the hex string to a byte array
    $encryptedBytes = for ($i = 0; $i -lt $encryptedHex.Length; $i += 2) {
        [Convert]::ToByte($encryptedHex.Substring($i, 2), 16)
    }

    # Create a DES crypto object and set the key and mode
    $des = New-Object System.Security.Cryptography.DESCryptoServiceProvider
    $des.Key = $desKey  # Assign the key as a byte array
    $des.Mode = [System.Security.Cryptography.CipherMode]::ECB
    $des.Padding = [System.Security.Cryptography.PaddingMode]::None

    # Create a decryptor
    $decryptor = $des.CreateDecryptor()

    # Decrypt the encrypted password
    $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)

    # Convert the decrypted byte array to a string, trimming null characters
    $decryptedPassword = [System.Text.Encoding]::ASCII.GetString($decryptedBytes).Trim("`0")

    # Return the decrypted password as an object
    return [pscustomobject]@{
        DecryptedPassword = $decryptedPassword
    }
}

# Example usage
$path = "c:\temp\configs\vnc.ini"
$passwordObject = Get-VNCPassword -VncIniPath $path
$passwordObject




<# vnc.ini

[Server]
# The port on which the VNC server listens for connections (default: 5900)
Port=5900

# Defines the IP address to bind the VNC server to. Leave blank to bind to all interfaces.
BindTo=0.0.0.0

# Enable or disable authentication. If 1, authentication is enabled.
Authentication=1

# VNC password (encoded or plain text depending on the software)
Password=01d47b4186dfa5a3

# Encryption (optional). Enable or disable encryption for VNC connections.
Encryption=1

# Set the idle timeout for client connections (in seconds)
IdleTimeout=600

# Maximum number of clients that can connect at once
MaxClients=5

[Security]
# Use SSL encryption for communication between VNC clients and server
UseSSL=0

# If SSL is enabled, provide the path to the SSL certificate file.
SSLCertificateFile=C:\path\to\ssl\certificate.pem

# Enable or disable TLS encryption
UseTLS=1

[Logging]
# Enable or disable logging. If 1, logging is enabled.
EnableLogging=1

# Log file location
LogFile=C:\path\to\log\vncserver.log

# Log level (INFO, DEBUG, ERROR, etc.)
LogLevel=INFO


#>
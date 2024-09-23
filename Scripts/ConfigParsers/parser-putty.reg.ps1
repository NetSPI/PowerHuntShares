# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# Putty.reg does not store passwords, but can point to private keys

function Parse-PuttyRegFile {
    param (
        [string]$filePath
    )

    # Check if the file exists
    if (-not (Test-Path $filePath)) {
        Write-Host "File not found: $filePath"
        return
    }

    # Read the contents of the .reg file
    $regContent = Get-Content -Path $filePath

    # Create a list to store extracted session details
    $sessionDetails = @()

    # Variables to hold extracted data for each session
    $currentSession = ""
    $hostName = ""
    $portNumber = ""
    $userName = ""
    $privateKeyPath = ""

    # Iterate through the lines of the file
    foreach ($line in $regContent) {
        # Detect session headers (e.g., "[HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\My%20SSH%20Session]")
        if ($line -match '^\[HKEY_CURRENT_USER\\Software\\SimonTatham\\PuTTY\\Sessions\\(.+?)\]') {
            # If we're processing a new session, save the previous one
            if ($currentSession -ne "") {
                $sessionDetails += [pscustomobject]@{
                    Session        = $currentSession
                    HostName       = $hostName
                    Port           = [int]$portNumber
                    UserName       = $userName
                    PrivateKeyPath = $privateKeyPath
                }
            }

            # Reset variables for the new session
            $currentSession = $matches[1]
            $hostName = ""
            $portNumber = ""
            $userName = ""
            $privateKeyPath = ""
        }

        # Extract HostName
        if ($line -match '"HostName"="(.+?)"') {
            $hostName = $matches[1]
        }

        # Extract PortNumber (convert hex to decimal)
        if ($line -match '"PortNumber"=dword:(\w{8})') {
            $portNumber = [convert]::ToInt32($matches[1], 16)
        }

        # Extract UserName
        if ($line -match '"UserName"="(.+?)"') {
            $userName = $matches[1]
        }

        # Extract PrivateKeyFile (path to the private key)
        if ($line -match '"PublicKeyFile"="(.+?)"') {
            $privateKeyPath = $matches[1]
        }
    }

    # After the loop, add the last session if it exists
    if ($currentSession -ne "") {
        $sessionDetails += [pscustomobject]@{
            Session        = $currentSession
            HostName       = $hostName
            Port           = [int]$portNumber
            UserName       = $userName
            PrivateKeyPath = $privateKeyPath
        }
    }

    # Return the session details
    return $sessionDetails
}

# Example usage:
$puttySessions = Parse-PuttyRegFile -filePath "c:\temp\configs\putty.reg"

# Display the results
$puttySessions | Format-Table -AutoSize


<# putty.reg

Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\SimonTatham\PuTTY]
"TermWidth"=dword:00000050
"TermHeight"=dword:00000018
"WinTitle"="PuTTY"

[HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\Default%20Settings]
"HostName"=""
"PortNumber"=dword:00000016
"Protocol"="ssh"
"TerminalType"="xterm"
"Font"="Courier New"
"FontHeight"=dword:0000000a
"WinHeight"=dword:00000018
"WinWidth"=dword:00000050
"ConnectionSharing"=dword:00000001

[HKEY_CURRENT_USER\Software\SimonTatham\PuTTY\Sessions\My%20SSH%20Session]
"HostName"="192.168.1.100"
"PortNumber"=dword:00000016
"Protocol"="ssh"
"TerminalType"="xterm"
"Font"="Courier New"
"FontHeight"=dword:0000000a
"WinHeight"=dword:00000018
"WinWidth"=dword:00000050
"Compression"=dword:00000001
"ConnectionSharing"=dword:00000001
"PublicKeyFile"="C:\\Users\\YourUsername\\.ssh\\id_rsa.ppk"
"LogFileName"="C:\\putty_logs\\my_session.log"
"LogType"=dword:00000001
"LogFileClash"=dword:00000001
"LogFlush"=dword:00000001
"LogOmitPasswords"=dword:00000001
"LogOmitData"=dword:00000000
"UserName"="myusername"  ; Username stored here


#>
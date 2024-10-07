
# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# Intended input: .remmina file
function Get-PwRemmina {
    param (
        [string]$ComputerName = $null,
        [string]$ShareName    = $null,
        [string]$UncFilePath  = $null,
        [string]$FileName     = $null,
        [string]$FilePath     # Required
    )

    # Array to hold individual records
    $outputArray = @()

    # Check if the file exists
    if (-not (Test-Path -Path $FilePath)) {
        Write-Host "File not found at path: $FilePath"
        return $outputArray
    }

    # Read the file content and parse for each protocol setting
    $fileContent = Get-Content -Path $FilePath

    # Initialize variables for each record type
    $vncSettings = @{
        ComputerName = $ComputerName
        ShareName    = $ShareName
        UncFilePath  = $UncFilePath
        FileName     = $FileName
        Section      = "NA"
        ObjectName   = "VNC"
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
    
    $sshSettings = @{
        ComputerName = $ComputerName
        ShareName    = $ShareName
        UncFilePath  = $UncFilePath
        FileName     = $FileName
        Section      = "NA"
        ObjectName   = "SSH"
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

    # Parse each line and fill in the appropriate settings
    foreach ($line in $fileContent) {
        if ($line -match "^protocol=(.+)") {
            $protocol = $matches[1].Trim()
            if ($protocol -eq "VNC") {
                $vncSettings["ObjectName"] = "VNC"
            } elseif ($protocol -eq "SSH") {
                $sshSettings["ObjectName"] = "SSH"
            }
        }
        elseif ($line -match "^server=(.+)") {
            $vncSettings["TargetServer"] = $matches[1].Trim()
        } elseif ($line -match "^listenport=(\d+)") {
            $vncSettings["TargetPort"] = $matches[1].Trim()
        } elseif ($line -match "^username=(.+)") {
            $vncSettings["Username"] = $matches[1].Trim()
        } elseif ($line -match "^password=(.+)") {
            $vncSettings["Password"] = $matches[1].Trim()
        }
        elseif ($line -match "^ssh_server=(.+)") {
            $sshSettings["TargetServer"] = $matches[1].Trim()
        } elseif ($line -match "^ssh_username=(.+)") {
            $sshSettings["Username"] = $matches[1].Trim()
        } elseif ($line -match "^ssh_privatekey=(.+)") {
            $sshSettings["KeyFilePath"] = $matches[1].Trim()
        }
    }

    # Add each filled record to the output array
    $outputArray += [PSCustomObject]$vncSettings
    $outputArray += [PSCustomObject]$sshSettings

    # Return the array of records
    return $outputArray
}

# Example command
# Get-PwRemmina -ComputerName "MyComputer" -ShareName "MyShare" -UncFilePath "\\MyComputer\MyShare\.remmina" -FileName ".remmina" -FilePath "C:\temp\.remmina"

<# .remmina example config

[remmina]
name=myvnc
group=RemoteServers           ; Group label for organization, such as "RemoteServers"
server=192.168.1.10
protocol=VNC
username=myusername
password=mysecretpassword      ; Avoid storing passwords in cleartext; keyring storage is recommended
domain=demo.com
clientname=                    ; Leave empty to use the default client name

# Display settings
resolution=AUTO                ; Use AUTO for adaptive resolution
keymap=default                 ; Default keymap for the connection
gkeymap=                       ; Global keymap if different from the default
colordepth=16                  ; Color depth setting
quality=9                      ; Set connection quality, 0 to 9 (9 = best quality)
viewmode=1                     ; Set view mode: 1 for full screen, 4 for windowed

# Connection and scaling
listenport=5500                ; Port Remmina listens on for reverse connections
hscale=100                     ; Horizontal scale in percent, e.g., 100% = no scaling
vscale=100                     ; Vertical scale in percent, e.g., 100% = no scaling
bitmapcaching=false            ; Bitmap caching to improve speed at cost of memory
compression=true               ; Enable compression to improve speed (especially on slower networks)
showcursor=true                ; Show remote cursor in VNC sessions
viewonly=false                 ; Set true for view-only mode (no interaction)
console=false                  ; Use this as a console session
disableserverinput=false       ; Allow server to receive input events
aspectscale=false              ; Maintain aspect ratio while scaling

# Advanced features
shareprinter=false             ; Set to true to share printers
once=false                     ; Connect only once if true

# SSH tunneling settings
ssh_enabled=true               ; Enable SSH tunneling
ssh_server=192.168.1.20        ; SSH server address for tunneling
ssh_auth=1                     ; SSH authentication method (1 = private key, 0 = password)
ssh_username=sshuser           ; SSH username for tunneling
ssh_privatekey=/home/user/.ssh/id_rsa ; Path to SSH private key (if using key-based auth)
ssh_charset=UTF-8              ; Character set for SSH if necessary

# Window settings
scale=false                    ; Auto scale window to screen resolution
keyboard_grab=false            ; Allow keyboard grabbing for shortcuts
window_width=1024              ; Window width in pixels
window_height=808              ; Window height in pixels
window_maximize=false          ; Start maximized if true
toolbar_opacity=0              ; Opacity of the toolbar when visible (0 = transparent)
#>

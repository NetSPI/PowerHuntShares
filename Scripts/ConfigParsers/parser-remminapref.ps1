# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# Intended input: remmina.pref file
function Get-PwRemminaPref {
    param (
        [string]$ComputerName = $null,
        [string]$ShareName    = $null,
        [string]$UncFilePath  = $null,
        [string]$FileName     = $null,
        [string]$FilePath     # Required
    )

    # Initialize the output object with default values
    $output = [PSCustomObject]@{
        ComputerName = $ComputerName
        ShareName    = $ShareName
        UncFilePath  = $UncFilePath
        FileName     = $FileName
        Section      = "remmina_pref"
        ObjectName   = "Remmina Configuration"
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

    # Check if the file exists
    if (-not (Test-Path -Path $FilePath)) {
        Write-Host "File not found at path: $FilePath"
        return $output
    }

    # Read the file content and parse for the 'secret' field in the remmina_pref section
    $fileContent = Get-Content -Path $FilePath
    $inRemminaPrefSection = $false

    foreach ($line in $fileContent) {
        # Check if we are in the [remmina_pref] section
        if ($line -match "^\[remmina_pref\]") {
            $inRemminaPrefSection = $true
        }
        # Exit the section if a new section starts
        elseif ($line -match "^\[.*\]") {
            $inRemminaPrefSection = $false
        }
        # Parse 'secret' value in the remmina_pref section
        elseif ($inRemminaPrefSection -and $line -match "^secret=(.+)") {
            $output.PasswordEnc = $matches[1].Trim()
        }
    }

    # Output the final object
    return $output
}

# Example command
# Get-PwRemminaPref -ComputerName "MyComputer" -ShareName "MyShare" -UncFilePath "\\MyComputer\MyShare\.remmina" -FileName ".remmina" -FilePath "c:\temp\remmina.pref"

<# Sample config

[remmina_pref]
secret=A123kgXlYRiCAdDcbFsE8SAoCGUanspg123=
recent_RDP=myserver.demo.local
save_view_mode=true
invisible_toolbar=false
default_action=0
scale_quality=0
hide_toolbar=false
hide_statusbar=false
small_toolbutton=false
view_file_mode=0
resolutions=640x480,800x600,1024x768,1152x864,1280x960,1400x1050
main_width=600
main_height=400
main_maximize=false
main_sort_column_id=1
main_sort_order=0
sshtunnel_port=4732
applet_quick_ontop=false
applet_hide_count=false
recent_maximum=10
default_mode=0
tab_mode=9

#>

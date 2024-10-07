# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# Intended input: grub.conf, grub.config, grub.cfg
function Get-PwGrubConfig {
    param (
        [string]$ComputerName = $null,  # Optional
        [string]$ShareName    = $null,  # Optional
        [string]$UncFilePath  = $null,  # Optional
        [string]$FileName     = $null,  # Optional
        [string]$FilePath               # Required
    )

    # Check if the FilePath exists
    if (-not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Initialize the output structure with default values
    $output = [pscustomobject]@{
        ComputerName = $ComputerName
        ShareName    = $ShareName
        UncFilePath  = $UncFilePath
        FileName     = $FileName
        Section      = "NA"
        ObjectName   = 'NA'
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

    # Read the file contents
    $fileContent = Get-Content -Path $FilePath -Raw

    # Extract the superuser username
    if ($fileContent -match 'set superusers\s*=\s*"([^"]+)"') {
        $output.Username = $matches[1].Trim()
    }

    # Use the extracted username in the password regex
    if ($output.Username -ne "NA") {
        $usernamePattern = [regex]::Escape($output.Username)
        $passwordPattern = "password\s+$usernamePattern\s+(\S+)"
        if ($fileContent -match $passwordPattern) {
            $output.Password = $matches[1].Trim()
        }
    }

    # Debug output to verify matching sections in file content
    if ($output.Username -eq "NA") {
        # Write-Host "Username not found. Ensure 'set superusers' syntax is correct."
    } else {
        # Write-Host "Username extracted successfully: $($output.Username)"
    }

    if ($output.Password -eq "NA") {
        # Write-Host "Password not found. Ensure 'password <username>' syntax is correct."
    } else {
        # Write-Host "Password extracted successfully: $($output.Password)"
    }

    # Return the output structure
    return $output
}

# Get-PwGrubConfig -FilePath "C:\temp\grub.cfg" -ComputerName "MyComputer" -ShareName "MyShare" -FileName grub.cfg

<# grub.cfg

# Set the default menu entry to boot
set default=0

# Set the timeout for the GRUB menu
set timeout=5

# Set the GRUB background image (optional)
if loadfont /boot/grub/fonts/unicode.pf2; then
  insmod gfxterm
  insmod png
  set gfxmode=auto
  set background_image="/boot/grub/background.png"
  terminal_output gfxterm
fi

# Define the superuser and plain-text password (for demo purposes only)
set superusers="admin"
password admin myplaintextpassword

# Load necessary modules for Linux booting
insmod gzio
insmod part_msdos
insmod ext2

# Specify the path to the main GRUB boot configuration
set root='hd0,msdos1'
search --no-floppy --fs-uuid --set=root 1234-5678

# Boot menu entries
menuentry 'Ubuntu 22.04 LTS' --class ubuntu --class gnu-linux --class os {
    recordfail
    load_video
    gfxmode $linux_gfx_mode
    insmod gzio
    insmod part_msdos
    insmod ext2
    set root='hd0,msdos1'
    linux /vmlinuz-5.15.0-30-generic root=UUID=1234-5678 ro quiet splash
    initrd /initrd.img-5.15.0-30-generic
}

# Protected entry for recovery mode (requires superuser password)
menuentry 'Ubuntu 22.04 LTS (Recovery Mode)' --class ubuntu --class gnu-linux --class os --unrestricted {
    recordfail
    load_video
    gfxmode $linux_gfx_mode
    insmod gzio
    insmod part_msdos
    insmod ext2
    set root='hd0,msdos1'
    linux /vmlinuz-5.15.0-30-generic root=UUID=1234-5678 ro recovery nomodeset
    initrd /initrd.img-5.15.0-30-generic
}

# Additional entry for Windows booting (if dual-booted)
menuentry 'Windows 10' --class windows --class os {
    insmod part_msdos
    insmod ntfs
    set root='hd0,msdos2'
    chainloader +1
}

# Boot to GRUB command line (restricted access, requires superuser password)
menuentry 'GRUB Command Line' --class cmdline --unrestricted {
    insmod all_video
    terminal_input console
    terminal_output console
}

#>

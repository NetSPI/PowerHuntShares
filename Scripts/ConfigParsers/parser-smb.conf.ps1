# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-SmbConfCredentials {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Initialize a hashtable to store extracted values
    $configData = @{
        Username = $null
        Password = $null
    }

    # Check if the file exists
    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Read the configuration file
    $configFile = Get-Content -Path $FilePath

    # Parse the configuration file line by line
    foreach ($line in $configFile) {
        # Ignore comment lines and empty lines
        if ($line -match '^\s*#' -or $line -match '^\s*$') {
            continue
        }

        # Extract the username
        if ($line -match '^\s*username\s*=\s*(.+)') {
            $configData.Username = $matches[1].Trim()
        }

        # Extract the password
        if ($line -match '^\s*password\s*=\s*(.+)') {
            $configData.Password = $matches[1].Trim()
        }
    }

    # Output the extracted configuration as a PowerShell object
    [PSCustomObject]@{
        Username = $configData.Username
        Password = $configData.Password
    }
}

# Example usage:
$credentials = Get-SmbConfCredentials -FilePath "c:\temp\configs\smb.conf"
$credentials | Format-List


<# smb.conf

[global]
    # General server settings
    workgroup = EXAMPLE
    realm = EXAMPLE.COM
    server string = Samba Server Version %v
    security = ads
    encrypt passwords = yes
    kerberos method = secrets and keytab
    log file = /var/log/samba/log.%m
    max log size = 50

    # Domain and authentication settings
    idmap config * : backend = tdb
    idmap config EXAMPLE : backend = rid
    idmap config EXAMPLE : range = 10000-20000
    template shell = /bin/bash
    winbind use default domain = yes
    winbind offline logon = yes
    winbind enum users = yes
    winbind enum groups = yes

    # INSECURE: Credentials for binding to Active Directory (avoid plaintext credentials)
    # This exposes the AD admin account and password directly in the smb.conf file
    username = ad-admin
    password = P@ssw0rd123

    # Kerberos keytab file location (more secure than plaintext credentials)
    dedicated keytab file = /etc/krb5.keytab
    kerberos method = secrets and keytab

[homes]
    comment = Home Directories
    browseable = no
    writable = yes

[printers]
    comment = All Printers
    path = /var/spool/samba
    printable = yes
    guest ok = no
    writable = no
    browseable = no

[shared]
    path = /srv/samba/shared
    browseable = yes
    read only = no
    valid users = @staff
#>
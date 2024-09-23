# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-ConfigCredentials {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Initialize a hashtable to store extracted values
    $configData = @{
        Domain   = $null
        Server   = $null
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

        # Extract the domain (e.g., default_realm or ad_domain or similar)
        if ($line -match 'default_realm\s*=\s*(.+)') {
            $configData.Domain = $matches[1].Trim()
        }

        # Extract the server (e.g., kdc or krb5_server or similar)
        if ($line -match 'kdc\s*=\s*(.+)') {
            $configData.Server = $matches[1].Trim()
        }

        # Extract the username (e.g., principal or ldap_default_bind_dn or similar)
        if ($line -match 'principal\s*=\s*(.+)') {
            $configData.Username = $matches[1].Trim()
        }
        elseif ($line -match 'ldap_default_bind_dn\s*=\s*(.+)') {
            $configData.Username = $matches[1].Trim()
        }

        # Extract the password (e.g., password or ldap_default_authtok or similar)
        if ($line -match 'password\s*=\s*(.+)') {
            $configData.Password = $matches[1].Trim()
        }
        elseif ($line -match 'ldap_default_authtok\s*=\s*(.+)') {
            $configData.Password = $matches[1].Trim()
        }
    }

    # Output the extracted configuration as a PowerShell object
    [PSCustomObject]@{
        Domain   = $configData.Domain
        Server   = $configData.Server
        Username = $configData.Username
        Password = $configData.Password
    }
}

# Example usage:
$config = Get-ConfigCredentials -FilePath "c:\temp\configs\krb5.conf"
$config | Format-List


<# krb5.conf - use for kerberos authention on linux systems

[libdefaults]
    default_realm = EXAMPLE.COM
    dns_lookup_realm = false
    dns_lookup_kdc = true
    rdns = false
    ticket_lifetime = 24h
    forwardable = yes

[realms]
    EXAMPLE.COM = {
        kdc = ad.example.com
        admin_server = ad.example.com
        default_domain = example.com
    }

[domain_realm]
    .example.com = EXAMPLE.COM
    example.com = EXAMPLE.COM

# Insecure: Exposing credentials in krb5.conf for automated ticket retrieval (NOT recommended)
[login]
    krb5_get_init_creds_keytab = false

# Insecure: Plaintext credentials for AD principal
[appdefaults]
    kinit = {
        principal = admin@EXAMPLE.COM
        password = P@ssw0rd123
    }

    pam = {
        debug = false
        ticket_lifetime = 36000
        renew_lifetime = 36000
        forwardable = true
    }


#>
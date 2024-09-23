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

        # Extract the domain (e.g., ad_domain or similar)
        if ($line -match 'ad_domain\s*=\s*(.+)') {
            $configData.Domain = $matches[1].Trim()
        }

        # Extract the server (e.g., krb5_server or similar)
        if ($line -match 'krb5_server\s*=\s*(.+)') {
            $configData.Server = $matches[1].Trim()
        }

        # Extract the username (e.g., ldap_default_bind_dn or similar)
        if ($line -match 'ldap_default_bind_dn\s*=\s*(.+)') {
            $configData.Username = $matches[1].Trim()
        }

        # Extract the password (e.g., ldap_default_authtok or similar)
        if ($line -match 'ldap_default_authtok\s*=\s*(.+)') {
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
$config = Get-ConfigCredentials -FilePath "c:\temp\configs\sssd.conf"
$config | Format-List


<# sssd.conf - used to support kerberos authentication in Linux


[sssd]
config_file_version = 2
services = nss, pam, ssh, sudo
domains = example.com

[nss]
filter_groups = root
filter_users = root

[pam]
offline_credentials_expiration = 2
offline_failed_login_attempts = 3
offline_failed_login_delay = 5

[domain/example.com]
# Basic configuration for connecting to Active Directory
id_provider = ad
auth_provider = ad
access_provider = ad

# Enable Kerberos for authentication
krb5_realm = EXAMPLE.COM
krb5_server = ad.example.com
krb5_kpasswd = ad.example.com

# Active Directory server information
ad_domain = example.com
ad_server = ad.example.com
ad_hostname = linuxclient.example.com

# INSECURE PRACTICE: Hardcoding AD username and password in sssd.conf
# These values will expose the username and password in plaintext
ldap_default_bind_dn = cn=admin,cn=users,dc=example,dc=com
ldap_default_authtok = P@ssw0rd123

# Using the above configuration exposes credentials to anyone who can read this file

# User and group filtering (optional)
ldap_id_mapping = true

# Performance optimizations
cache_credentials = true
enumerate = false
use_fully_qualified_names = false

# Access Control (Optional: limit login to users in AD group 'LinuxAdmins')
access_provider = simple
simple_allow_groups = LinuxAdmins

# Security settings
min_id = 1000
fallback_homedir = /home/%u

# Timeout and retry settings for better AD stability
ldap_search_timeout = 10
ldap_connection_expire_timeout = 60

# Debugging options (uncomment for troubleshooting)
# debug_level = 9


#>
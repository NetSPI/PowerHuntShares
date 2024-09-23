
# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-MySQLCredentials {
    param (
        [string]$FilePath
    )

    # Check if the file exists
    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return $null
    }

    # Read the file content
    $fileContent = Get-Content -Path $FilePath

    # Initialize variables to store username and password
    $username = $null
    $password = $null

    # Parse the file content
    foreach ($line in $fileContent) {
        if ($line -match '^\s*user\s*=\s*(.+)$') {
            $username = $matches[1].Trim()
        }
        elseif ($line -match '^\s*password\s*=\s*(.+)$') {
            $password = $matches[1].Trim()
        }
    }

    # Check if both username and password are found
    if ($username -and $password) {
        # Create a custom PowerShell object to return the credentials
        $credentials = [PSCustomObject]@{
            Username = $username
            Password = $password
        }
        return $credentials
    } else {
        Write-Warning "Username or password not found in the file."
        return $null
    }
}

# Example usage:
$credentials = Get-MySQLCredentials -FilePath "c:\temp\configs\my.cnf"
$credentials


<# my.cnf

[client]
# Client configuration options
user=yourusername
password=yourpassword
port=3306
socket=/var/run/mysqld/mysqld.sock

[mysqld]
# MySQL server configuration
user=mysql
pid-file=/var/run/mysqld/mysqld.pid
socket=/var/run/mysqld/mysqld.sock
port=3306
basedir=/usr
datadir=/var/lib/mysql
tmpdir=/tmp
log-error=/var/log/mysql/error.log
bind-address=127.0.0.1
max_connections=100
skip-external-locking

# Buffer pool size for InnoDB
innodb_buffer_pool_size=256M

# Other MySQL server settings
max_allowed_packet=16M
query_cache_limit=1M
query_cache_size=16M
log_bin=/var/log/mysql/mysql-bin.log

[mysql]
# Client-specific settings for the MySQL command-line tool
user=yourusername
password=yourpassword
no-auto-rehash

#>
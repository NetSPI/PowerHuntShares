# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-WPConfigCredentials {
    param (
        [string]$FilePath
    )

    # Check if the file exists
    if (-Not (Test-Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Initialize variables for username and password
    $dbUsername = $null
    $dbPassword = $null

    # Read the file line by line
    Get-Content $FilePath | ForEach-Object {
        $line = $_

        # Match the DB_USER line and extract the username
        if ($line -match "define\(\s*'DB_USER'\s*,\s*'([^']+)'\s*\)") {
            $dbUsername = $matches[1]
        }

        # Match the DB_PASSWORD line and extract the password
        if ($line -match "define\(\s*'DB_PASSWORD'\s*,\s*'([^']+)'\s*\)") {
            $dbPassword = $matches[1]
        }
    }

    # Check if both username and password were found
    if ($dbUsername -and $dbPassword) {
        # Return the results as a PowerShell object
        [PSCustomObject]@{
            Username = $dbUsername
            Password = $dbPassword
        }
    }
    else {
        Write-Error "Username or Password not found in the configuration file."
    }
}

# Example usage
$credentials = Get-WPConfigCredentials -FilePath "c:\temp\configs\wp-config.php"
$credentials


<# wp-config.php

<?php
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'your_database_name' );

/** MySQL database username */
define( 'DB_USER', 'your_database_username' );

/** MySQL database password */
define( 'DB_PASSWORD', 'your_secure_password_here' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the WordPress.org secret-key service
 * https://api.wordpress.org/secret-key/1.1/salt/
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 */
define('AUTH_KEY',         'put_your_unique_phrase_here');
define('SECURE_AUTH_KEY',  'put_your_unique_phrase_here');
define('LOGGED_IN_KEY',    'put_your_unique_phrase_here');
define('NONCE_KEY',        'put_your_unique_phrase_here');
define('AUTH_SALT',        'put_your_unique_phrase_here');
define('SECURE_AUTH_SALT', 'put_your_unique_phrase_here');
define('LOGGED_IN_SALT',   'put_your_unique_phrase_here');
define('NONCE_SALT',       'put_your_unique_phrase_here');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';


#>
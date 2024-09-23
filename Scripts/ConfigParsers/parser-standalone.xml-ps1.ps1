# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Parse-DataSourceConfig {
    param (
        [string]$ConfigPath
    )
    
    # Load the XML config
    [xml]$configXml = Get-Content -Path $ConfigPath

    # Define a hashtable to store results
    $result = @{}

    # Parse the server and port from the connection URL
    $connectionUrl = $configXml.server.subsystem.datasources.datasource."connection-url"
    if ($connectionUrl -match "jdbc:mysql://([^:/]+)(?::(\d+))?") {
        $result.Server = $matches[1]
        $result.Port = if ($matches[2]) { $matches[2] } else { "3306" } # Default MySQL port
    }

    # Get the username
    $result.Username = $configXml.server.subsystem.datasources.datasource.security."user-name"

    # Get the password
    $result.Password = $configXml.server.subsystem.datasources.datasource.security.password

    # Get the keystore password from the vault section
    $keystorePassword = $configXml.server.security.vault."vault-option" | Where-Object { $_.name -eq "KEYSTORE_PASSWORD" }
    $result.KeystorePassword = $keystorePassword.value

    # Convert hashtable to PowerShell object
    $resultObject = [PSCustomObject]$result
    
    # Output the result object
    return $resultObject
}

# Example usage
$parsedConfig = Parse-DataSourceConfig -ConfigPath "c:\temp\configs\standalone.xml"
$parsedConfig


<# standalone.xml used by jboss

<?xml version="1.0" encoding="UTF-8"?>
<server xmlns="urn:jboss:domain:11.0">

    <extensions>
        <extension module="org.jboss.as.connector"/>
        <!-- Other extensions -->
    </extensions>

    <subsystem xmlns="urn:jboss:domain:datasources:5.0">
        <datasources>
            <datasource jndi-name="java:/jdbc/MyDS" pool-name="MyDS_Pool" enabled="true" use-java-context="true">
                <connection-url>jdbc:mysql://localhost:3306/mydatabase</connection-url>
                <driver>mysql</driver>
                <security>
                    <user-name>${VAULT::vault::mydbuser}</user-name>
                    <password>${VAULT::vault::mydbpassword}</password>
                </security>
                <pool>
                    <min-pool-size>5</min-pool-size>
                    <max-pool-size>20</max-pool-size>
                </pool>
                <validation>
                    <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker"/>
                    <validate-on-match>true</validate-on-match>
                    <background-validation>true</background-validation>
                </validation>
                <timeout>
                    <blocking-timeout-millis>5000</blocking-timeout-millis>
                </timeout>
                <statement>
                    <track-statements>false</track-statements>
                </statement>
            </datasource>

            <drivers>
                <driver name="mysql" module="com.mysql">
                    <xa-datasource-class>com.mysql.jdbc.jdbc2.optional.MysqlXADataSource</xa-datasource-class>
                </driver>
            </drivers>
        </datasources>
    </subsystem>

    <security>
        <vault>
            <vault-option name="KEYSTORE_URL" value="${jboss.server.config.dir}/vault.keystore"/>
            <vault-option name="KEYSTORE_PASSWORD" value="password"/>
            <vault-option name="VAULT_BLOCK" value="vault"/>
            <vault-option name="ATTRIBUTE" value="my_password"/>
        </vault>
    </security>

    <!-- Other subsystems like transactions, deployments, security, etc. -->

</server>


#>
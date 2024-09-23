# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

# Define the function to extract username and password from a jboss-cli.xml file and return an object
function Get-JbossCredentials {
    param (
        [string]$FilePath
    )

    # Check if the file exists
    if (-not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return $null
    }

    # Load the XML file
    [xml]$jbossCliXml = Get-Content -Path $FilePath

    # Extract the username and password
    $username = $jbossCliXml."jboss-cli".authentication.username
    $password = $jbossCliXml."jboss-cli".authentication.password

    # Return a PowerShell object with the username and password
    return [pscustomobject]@{
        Username = $username
        Password = $password
    }
}

# Example usage
$xmlFilePath = "c:\temp\configs\jboss-cli.xml"
$credentials = Get-JbossCredentials -FilePath $xmlFilePath

# Output the returned object (optional for testing)
$credentials

<# jboss-cli.xml

<jboss-cli xmlns="urn:jboss:cli:1.2">
    <!-- The default controller host and port -->
    <controller>
        <host>127.0.0.1</host> <!-- Specify the host, e.g., localhost or a remote address -->
        <port>9990</port> <!-- The management port of JBoss/WildFly, default is 9990 -->
    </controller>

    <!-- The authentication details for the controller -->
    <authentication>
        <username>admin</username> <!-- Your management user -->
        <password>password</password> <!-- Your management user's password -->
    </authentication>

    <!-- Optionally enable secure connections using SSL -->
    <ssl>
        <enabled>false</enabled> <!-- Set to true if using SSL/TLS for the connection -->
        <keystore-path></keystore-path>
        <keystore-password></keystore-password>
        <truststore-path></truststore-path>
        <truststore-password></truststore-password>
    </ssl>

    <!-- Custom properties for the CLI session -->
    <properties>
        <!-- For example, to disable coloring in the CLI output -->
        <property name="jboss.cli.color" value="false"/>
    </properties>

    <!-- Configuration of command history behavior -->
    <history>
        <enabled>true</enabled> <!-- Whether to enable CLI command history -->
        <max-size>500</max-size> <!-- The maximum number of commands to store in history -->
    </history>
</jboss-cli>

#>

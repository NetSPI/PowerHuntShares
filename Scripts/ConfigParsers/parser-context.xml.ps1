# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

# Function to extract credentials from a given context.xml file
function Get-CredentialsFromContextXml {
    param (
        [string]$contextXmlPath
    )

    # Check if the file exists
    if (-Not (Test-Path $contextXmlPath)) {
        Write-Host "File not found: $contextXmlPath"
        return
    }

    # Load the XML file
    [xml]$xml = Get-Content $contextXmlPath

    # Extract username and password from the Resource element
    $username = $xml.Context.Resource | Where-Object { $_.name -eq 'jdbc/MyDB' } | Select-Object -ExpandProperty username
    $password = $xml.Context.Resource | Where-Object { $_.name -eq 'jdbc/MyDB' } | Select-Object -ExpandProperty password

    # Create a PowerShell object to hold the extracted information
    $credentials = [PSCustomObject]@{
        Username = $username
        Password = $password
    }

    # Return the credentials object
    return $credentials
}

# Example usage of the function
$exampleFilePath = "c:\temp\configs\context.xml"
$credentials = Get-CredentialsFromContextXml -contextXmlPath $exampleFilePath

# Display the credentials
$credentials

<# context.xml
<Context>
    <Resource name="jdbc/MyDB"
              auth="Container"
              type="javax.sql.DataSource"
              maxTotal="100"
              maxIdle="30"
              maxWaitMillis="10000"
              username="dbuser"
              password="dbpassword"
              driverClassName="com.mysql.jdbc.Driver"
              url="jdbc:mysql://localhost:3306/mydb"/>
</Context>

#>
# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-SSISCredentials {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Check if the file exists
    if (-not (Test-Path -Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Load the XML content from the file
    [xml]$xmlContent = [xml](Get-Content -Path $FilePath -Raw)

    # Ensure the XML content is valid
    if (-not $xmlContent) {
        Write-Error "Failed to load XML content."
        return
    }

    # Define the namespace manager and add the DTS namespace
    $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmlContent.NameTable)
    $namespaceManager.AddNamespace("DTS", "http://schemas.microsoft.com/sqlserver/Dts")

    # Prepare an array to hold extracted credentials
    $credentials = @()

    # Extract OLEDB connection credentials
    $dbConnections = $xmlContent.SelectNodes("//DTS:ConnectionManager[@DTS:CreationName='OLEDB']/DTS:Properties", $namespaceManager)
    foreach ($dbConnection in $dbConnections) {
        $connString = $dbConnection.SelectSingleNode("DTS:Property[@DTS:Name='ConnectionString']", $namespaceManager).'#text'
        if ($connString -match "Data Source=([^;]+);.*User ID=([^;]+);.*Password=([^;]+);") {
            $credentials += [pscustomobject]@{
                ConnectionType = "Database"
                Server         = $matches[1]
                Port           = "N/A"  # OLEDB typically does not specify a port
                Username       = $matches[2]
                Password       = $matches[3]
            }
        }
    }

    # Extract FTP connection credentials
    $ftpConnections = $xmlContent.SelectNodes("//DTS:ConnectionManager[@DTS:CreationName='FTP']/DTS:Properties", $namespaceManager)
    foreach ($ftpConnection in $ftpConnections) {
        $server = $ftpConnection.SelectSingleNode("DTS:Property[@DTS:Name='ServerName']", $namespaceManager).'#text'
        $port = $ftpConnection.SelectSingleNode("DTS:Property[@DTS:Name='ServerPort']", $namespaceManager).'#text'
        $username = $ftpConnection.SelectSingleNode("DTS:Property[@DTS:Name='ServerUserName']", $namespaceManager).'#text'
        $password = $ftpConnection.SelectSingleNode("DTS:Property[@DTS:Name='ServerPassword']", $namespaceManager).'#text'

        $credentials += [pscustomobject]@{
            ConnectionType = "FTP"
            Server         = $server
            Port           = $port
            Username       = $username
            Password       = $password
        }
    }

    # Extract SMTP connection credentials
    $smtpConnections = $xmlContent.SelectNodes("//DTS:ConnectionManager[@DTS:CreationName='SMTP']/DTS:Properties", $namespaceManager)
    foreach ($smtpConnection in $smtpConnections) {
        $server = $smtpConnection.SelectSingleNode("DTS:Property[@DTS:Name='SmtpServer']", $namespaceManager).'#text'
        $port = $smtpConnection.SelectSingleNode("DTS:Property[@DTS:Name='Port']", $namespaceManager).'#text'
        $username = $smtpConnection.SelectSingleNode("DTS:Property[@DTS:Name='UserName']", $namespaceManager).'#text'
        $password = $smtpConnection.SelectSingleNode("DTS:Property[@DTS:Name='Password']", $namespaceManager).'#text'

        $credentials += [pscustomobject]@{
            ConnectionType = "SMTP"
            Server         = $server
            Port           = $port
            Username       = $username
            Password       = $password
        }
    }

    # Return all credentials
    return $credentials
}

# Example usage:
$results = Get-SSISCredentials -FilePath "c:\temp\configs\example.dtsx"
$results | Format-Table -AutoSize



<# example.dtsx - SQL Server ssis package file

<DTS:Executable 
    xmlns:DTS="http://schemas.microsoft.com/sqlserver/Dts"
    DTS:refId="Package" 
    DTS:CreationName="Microsoft.SqlServer.Dts.Runtime.Package">

  <DTS:ConnectionManagers>
    
    <!-- Database Connection 1 -->
    <DTS:ConnectionManager
      DTS:refId="Package.ConnectionManagers[DB1]"
      DTS:CreationName="OLEDB">
      <DTS:Properties>
        <DTS:Property DTS:Name="ConnectionString">
          Data Source=dbserver1;Initial Catalog=Database1;User ID=dbuser1;Password=dbpassword1;
        </DTS:Property>
        <DTS:Property DTS:Name="Description">Primary Database Connection</DTS:Property>
        <DTS:Property DTS:Name="RetainSameConnection">True</DTS:Property>
      </DTS:Properties>
    </DTS:ConnectionManager>
    
    <!-- Database Connection 2 -->
    <DTS:ConnectionManager
      DTS:refId="Package.ConnectionManagers[DB2]"
      DTS:CreationName="OLEDB">
      <DTS:Properties>
        <DTS:Property DTS:Name="ConnectionString">
          Data Source=dbserver2;Initial Catalog=Database2;User ID=dbuser2;Password=dbpassword2;
        </DTS:Property>
        <DTS:Property DTS:Name="Description">Secondary Database Connection</DTS:Property>
        <DTS:Property DTS:Name="RetainSameConnection">True</DTS:Property>
      </DTS:Properties>
    </DTS:ConnectionManager>

    <!-- FTP Connection -->
    <DTS:ConnectionManager
      DTS:refId="Package.ConnectionManagers[FTPConnection]"
      DTS:CreationName="FTP">
      <DTS:Properties>
        <DTS:Property DTS:Name="ServerName">ftpserver.com</DTS:Property>
        <DTS:Property DTS:Name="ServerUserName">ftpuser</DTS:Property>
        <DTS:Property DTS:Name="ServerPassword">ftppassword</DTS:Property>
        <DTS:Property DTS:Name="ServerPort">21</DTS:Property>
        <DTS:Property DTS:Name="Timeout">60</DTS:Property>
        <DTS:Property DTS:Name="UsePassiveMode">True</DTS:Property>
      </DTS:Properties>
    </DTS:ConnectionManager>

    <!-- SMTP Connection -->
    <DTS:ConnectionManager
      DTS:refId="Package.ConnectionManagers[SMTPConnection]"
      DTS:CreationName="SMTP">
      <DTS:Properties>
        <DTS:Property DTS:Name="SmtpServer">smtp.mailserver.com</DTS:Property>
        <DTS:Property DTS:Name="Port">25</DTS:Property>
        <DTS:Property DTS:Name="UserName">smtpuser</DTS:Property>
        <DTS:Property DTS:Name="Password">smtppassword</DTS:Property>
        <DTS:Property DTS:Name="EnableSsl">True</DTS:Property>
        <DTS:Property DTS:Name="Description">SMTP Server Connection for Emails</DTS:Property>
      </DTS:Properties>
    </DTS:ConnectionManager>

  </DTS:ConnectionManagers>

  <!-- Tasks or Control Flow Elements -->
  <DTS:Executables>
    <!-- Sample Execute SQL Task using Database 1 -->
    <DTS:Executable
      DTS:refId="Package.Executable[SQLTask1]"
      DTS:CreationName="Microsoft.SqlServer.Dts.Tasks.ExecuteSQLTask.ExecuteSQLTask">
      <DTS:Properties>
        <DTS:Property DTS:Name="Connection">Package.ConnectionManagers[DB1]</DTS:Property>
        <DTS:Property DTS:Name="SQLStatement">SELECT * FROM Table1;</DTS:Property>
      </DTS:Properties>
    </DTS:Executable>

    <!-- Sample FTP Task -->
    <DTS:Executable
      DTS:refId="Package.Executable[FTPTask1]"
      DTS:CreationName="Microsoft.SqlServer.Dts.Tasks.FtpTask.FtpTask">
      <DTS:Properties>
        <DTS:Property DTS:Name="Connection">Package.ConnectionManagers[FTPConnection]</DTS:Property>
        <DTS:Property DTS:Name="RemotePath">/data/</DTS:Property>
        <DTS:Property DTS:Name="LocalPath">C:\data\</DTS:Property>
        <DTS:Property DTS:Name="Operation">Receive</DTS:Property>
      </DTS:Properties>
    </DTS:Executable>

    <!-- Sample Email Task -->
    <DTS:Executable
      DTS:refId="Package.Executable[EmailTask1]"
      DTS:CreationName="Microsoft.SqlServer.Dts.Tasks.SendMailTask.SendMailTask">
      <DTS:Properties>
        <DTS:Property DTS:Name="Connection">Package.ConnectionManagers[SMTPConnection]</DTS:Property>
        <DTS:Property DTS:Name="From">noreply@mailserver.com</DTS:Property>
        <DTS:Property DTS:Name="To">user@example.com</DTS:Property>
        <DTS:Property DTS:Name="Subject">SSIS Task Notification</DTS:Property>
        <DTS:Property DTS:Name="MessageSource">Task has been completed successfully.</DTS:Property>
      </DTS:Properties>
    </DTS:Executable>

  </DTS:Executables>
</DTS:Executable>

#>

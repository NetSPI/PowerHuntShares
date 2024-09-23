# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

# Function to parse configuration files for credentials
function Get-CredentialsFromConfigFile {
    param (
        [string]$configFilePath
    )

    # Load the config file as XML
    [xml]$configXml = Get-Content $configFilePath

    # Initialize a DataTable to store results
    $dtCredentials = New-Object System.Data.DataTable
    $null = $dtCredentials.Columns.Add("Name", [string])
    $null = $dtCredentials.Columns.Add("Section", [string])
    $null = $dtCredentials.Columns.Add("URL", [string])
    $null = $dtCredentials.Columns.Add("Server", [string])
    $null = $dtCredentials.Columns.Add("Port", [string])
    $null = $dtCredentials.Columns.Add("UserName", [string])
    $null = $dtCredentials.Columns.Add("Password", [string])

    # Helper function to add rows to DataTable
    function Add-CredentialsToDataTable {
        param (
            [string]$name,
            [string]$section,
            [string]$url,
            [string]$server,
            [string]$port,
            [string]$username,
            [string]$password
        )
        $null = $dtCredentials.Rows.Add($name, $section, $url, $server, $port, $username, $password)
    }

    # Dictionary to temporarily store related credentials
    $credentialPairs = @{}

    # Function to store credentials in temporary dictionary
    function Add-CredentialPair {
        param (
            [string]$name,
            [string]$section,
            [string]$key,
            [string]$value
        )
        
        if ($credentialPairs[$name]) {
            $credentialPairs[$name][$key] = $value
        } else {
            $credentialPairs[$name] = @{}
            $credentialPairs[$name][$key] = $value
            $credentialPairs[$name]["Section"] = $section
        }

        # If both username and password are available, add them to the DataTable
        if ($credentialPairs[$name]["UserName"] -and $credentialPairs[$name]["Password"]) {
            Add-CredentialsToDataTable -name $name -section $credentialPairs[$name]["Section"] `
                -url $credentialPairs[$name]["URL"] -server $credentialPairs[$name]["Server"] `
                -port $credentialPairs[$name]["Port"] -username $credentialPairs[$name]["UserName"] `
                -password $credentialPairs[$name]["Password"]

            # Clear the stored credential after adding it to the table
            $credentialPairs.Remove($name)
        }
    }

    # Parse all instances of appSettings for OAuth, WebClient, API, and other credentials
    if ($configXml.SelectNodes('//appSettings')) {
        foreach ($appSettings in $configXml.SelectNodes('//appSettings')) {
            foreach ($setting in $appSettings.add) {
                $key = $setting.key
                $value = $setting.value
                $section = "AppSettings"

                # Handle specific cases for OAuth, API, and WebClient settings
                switch ($key) {
                    "OAuthServiceUrl" { Add-CredentialPair -name "OAuth" -section $section -key "URL" -value $value }
                    "ClientId" { Add-CredentialPair -name "OAuth" -section $section -key "UserName" -value $value }
                    "ClientSecret" { Add-CredentialPair -name "OAuth" -section $section -key "Password" -value $value }
                    "ServiceUrl" { Add-CredentialPair -name "WebClient" -section $section -key "URL" -value $value }
                    "ServiceUserName" { Add-CredentialPair -name "WebClient" -section $section -key "UserName" -value $value }
                    "ServicePassword" { Add-CredentialPair -name "WebClient" -section $section -key "Password" -value $value }
                    "ApiEndpoint" { Add-CredentialPair -name "API" -section $section -key "URL" -value $value }
                    "ApiUserName" { Add-CredentialPair -name "API" -section $section -key "UserName" -value $value }
                    "ApiPassword" { Add-CredentialPair -name "API" -section $section -key "Password" -value $value }
                    "ApplicationUsername" { Add-CredentialPair -name "Application" -section $section -key "UserName" -value $value }
                    "ApplicationPassword" { Add-CredentialPair -name "Application" -section $section -key "Password" -value $value }
                }
            }
        }
    }

    # Parse custom serviceCredentials section
    if ($configXml.configuration.serviceCredentials) {
        foreach ($setting in $configXml.configuration.serviceCredentials.add) {
            $key = $setting.key
            $value = $setting.value
            $section = "ServiceCredentials"

            # Handle specific cases for custom service credentials
            switch ($key) {
                "ServiceUrl" { Add-CredentialPair -name "CustomService" -section $section -key "URL" -value $value }
                "UserName" { Add-CredentialPair -name "CustomService" -section $section -key "UserName" -value $value }
                "Password" { Add-CredentialPair -name "CustomService" -section $section -key "Password" -value $value }
            }
        }
    }

    # Parse connectionStrings for server, port, username, and password
    if ($configXml.configuration.connectionStrings) {
        foreach ($connection in $configXml.configuration.connectionStrings.add) {
            $connectionString = $connection.connectionString
            $providerName = $connection.providerName
            $name = $connection.name

            # Initialize variables for potential data
            $server = $null
            $port = $null
            $user = $null
            $password = $null
            $url = $null

            # Parse connection strings
            if ($connectionString -match "Host\s*=\s*([^;]+).*?Port\s*=\s*(\d+).*?Username\s*=\s*([^;]+).*?Password\s*=\s*([^;]+)") {
                $server = $matches[1]
                $port = $matches[2]
                $user = $matches[3]
                $password = $matches[4]
                $url = "Host=$server;Port=$port"
            } elseif ($connectionString -match "(Server|Data Source)\s*=\s*([^;,]+)(?:,(\d+))?") {
                $server = $matches[2]
                if ($matches[3]) { $port = $matches[3] }
                $url = "Server=$server"
            }

            if ($connectionString -match "User\s*Id\s*=\s*([^;]+)") {
                $user = $matches[1]
            }
            if ($connectionString -match "Password\s*=\s*([^;]+)") {
                $password = $matches[1]
            }

            # Add row to the DataTable if username and password exist
            if ($user -and $password) {
                Add-CredentialsToDataTable -name $name -section "ConnectionStrings ($providerName)" -url $url -server $server -port $port -username $user -password $password
            }
        }
    }

    # Parse system.net/mailSettings for SMTP credentials and URLs
    if ($configXml.configuration.'system.net'.mailSettings) {
        foreach ($smtp in $configXml.configuration.'system.net'.mailSettings.smtp) {
            $smtpServer = $smtp.network.host
            $smtpPort = $smtp.network.port
            $smtpUser = $smtp.network.userName
            $smtpPass = $smtp.network.password
            $url = "smtp://${smtpServer}:${smtpPort}"

            if ($smtpUser -and $smtpPass) {
                Add-CredentialsToDataTable -name "SMTP Configuration" -section "SMTP" -url $url -server $smtpServer -port $smtpPort -username $smtpUser -password $smtpPass
            }
        }
    }

    # Output the parsed credentials using the DataTable
    if ($dtCredentials.Rows.Count -eq 0) {
        Write-Host "No credentials found." -ForegroundColor Red
    } else {
        $dtCredentials | select Name, Section, URL, Server, Port, UserName, Password
    }
}

# Example of calling the function with a file path
Get-CredentialsFromConfigFile -configFilePath "c:\temp\configs\machine.config"


<# machine.config

<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <configSections>
    <!-- Section handlers for configuration settings -->
    <sectionGroup name="system.net">
      <section name="settings" type="System.Net.Configuration.SettingsSection, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" />
    </sectionGroup>
  </configSections>

  <!-- App settings for all .NET applications -->
  <appSettings>
    <!-- Example of username and password in appSettings -->
    <add key="ApplicationUsername" value="myAppUser" />
    <add key="ApplicationPassword" value="myAppPassword" />
  </appSettings>
    
  <!-- OAuth/Token-Based Service Endpoints -->
  <appSettings>
  <add key="OAuthServiceUrl" value="https://oauth.example.com/token" />
  <add key="ClientId" value="myClientId" />
  <add key="ClientSecret" value="myClientSecret" />
  </appSettings>
  
   <!--  WebClient or HttpClient Credentials -->
   <appSettings>
	  <add key="ServiceUrl" value="https://service.example.com/api" />
	  <add key="ServiceUserName" value="serviceUser" />
	  <add key="ServicePassword" value="servicePassword" />
   </appSettings>   
 
  <!-- AppSettings Section -->
  <appSettings>
	  <add key="ApiEndpoint" value="https://api.example.com/endpoint" />
	  <add key="ApiUserName" value="apiUser" />
	  <add key="ApiPassword" value="apiPassword" />
  </appSettings> 
  
  <!-- Custom Sections for Service Credentials -->
  <configSections>
	  <section name="serviceCredentials" type="System.Configuration.NameValueSectionHandler" />
  </configSections>

  <serviceCredentials>
	  <add key="ServiceUrl" value="https://customservice.example.com" />
	  <add key="UserName" value="customUser" />
	  <add key="Password" value="customPassword" />
  </serviceCredentials>   

  <!-- Connection string settings -->
  <connectionStrings>
    <!-- SQL Server (Standard Authentication) -->
    <add name="SqlServerConnection"
         connectionString="Data Source=localhost;Initial Catalog=myDB;User ID=myUser;Password=myPass;"
         providerName="System.Data.SqlClient" />

    <!-- SQL Server (Windows Authentication) -->
    <add name="SqlServerIntegratedSecurity"
         connectionString="Data Source=localhost;Initial Catalog=myDB;Integrated Security=True;"
         providerName="System.Data.SqlClient" />

    <!-- SQL Server (Encrypted Connection) -->
    <add name="SqlServerEncryptedConnection"
         connectionString="Data Source=localhost;Initial Catalog=myDB;User ID=myUser;Password=myPass;Encrypt=True;TrustServerCertificate=False;"
         providerName="System.Data.SqlClient" />

    <!-- MySQL (Standard Connection) -->
    <add name="MySqlConnection"
         connectionString="Server=localhost;Database=myDB;User=myUser;Password=myPass;"
         providerName="MySql.Data.MySqlClient" />

    <!-- MySQL (SSL/Encrypted Connection) -->
    <add name="MySqlConnectionWithSSL"
         connectionString="Server=localhost;Database=myDB;User=myUser;Password=myPass;SslMode=Required;"
         providerName="MySql.Data.MySqlClient" />

    <!-- PostgreSQL (Standard Connection) -->
    <add name="PostgreSqlConnection"
         connectionString="Host=localhost;Port=5432;Database=myDB;Username=myUser;Password=myPass;"
         providerName="Npgsql" />

    <!-- Oracle (Standard Connection) -->
    <add name="OracleConnection"
         connectionString="Data Source=MyOracleDB;User Id=oracleUser;Password=oraclePass;"
         providerName="System.Data.OracleClient" />

    <!-- Oracle (TNS Connection) -->
    <add name="OracleTNSConnection"
         connectionString="Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=myHost)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=myService)));User Id=oracleUser;Password=oraclePass;"
         providerName="Oracle.ManagedDataAccess.Client" />

    <!-- SQLite (No Authentication Required) -->
    <add name="SQLiteConnection"
         connectionString="Data Source=myDatabase.db;"
         providerName="System.Data.SQLite" />

    <!-- Microsoft Access (OLEDB with username and password) -->
    <add name="AccessConnection"
         connectionString="Provider=Microsoft.ACE.OLEDB.12.0;Data Source=C:\myAccessFile.accdb;User Id=admin;Password=myPass;"
         providerName="System.Data.OleDb" />

    <!-- Azure SQL (Standard SQL Authentication) -->
    <add name="AzureSqlConnection"
         connectionString="Server=tcp:myserver.database.windows.net,1433;Initial Catalog=myDB;Persist Security Info=False;User ID=myUser;Password=myPass;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
         providerName="System.Data.SqlClient" />
  </connectionStrings>

  <!-- Compilation settings for applications -->
  <system.web>
    <compilation debug="false" />
    <authentication mode="Forms">
      <!-- Forms authentication with username and password -->
      <forms loginUrl="login.aspx" timeout="30">
        <credentials passwordFormat="Clear">
          <user name="user1" password="password1" />
          <user name="user2" password="password2" />
        </credentials>
      </forms>
    </authentication>
    <customErrors mode="Off" />
  </system.web>

  <!-- Machine-wide database settings -->
  <system.data>
    <DbProviderFactories>
      <add name="Microsoft SQL Server Compact Data Provider"
           invariant="System.Data.SqlServerCe.4.0"
           description=".NET Framework Data Provider for Microsoft SQL Server Compact"
           type="System.Data.SqlServerCe.SqlCeProviderFactory, System.Data.SqlServerCe, Version=4.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" />
    </DbProviderFactories>
  </system.data>

  <!-- Credentials for SMTP (system.net) -->
  <system.net>
    <mailSettings>
      <smtp from="you@example.com">
        <network host="smtp.example.com" port="587"
                 userName="smtpUser"
                 password="smtpPassword"
                 defaultCredentials="false" />
      </smtp>
    </mailSettings>
  </system.net>

  <!-- Global assembly cache settings -->
  <runtime>
    <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
      <dependentAssembly>
        <assemblyIdentity name="System.Web" publicKeyToken="b03f5f7f11d50a3a" culture="neutral" />
        <bindingRedirect oldVersion="1.0.0.0-4.0.0.0" newVersion="4.0.0.0" />
      </dependentAssembly>
    </assemblyBinding>
  </runtime>

  <!-- Logging and tracing settings -->
  <system.diagnostics>
    <sources>
      <source name="System.Net" switchValue="Verbose">
        <listeners>
          <add name="consoleListener" type="System.Diagnostics.ConsoleTraceListener" />
        </listeners>
      </source>
    </sources>
  </system.diagnostics>
  
	<!-- WCF (Windows Communication Foundation) Service Bindings  -->
	<system.serviceModel>
	  <bindings>
		<basicHttpBinding>
		  <binding name="MyBinding">
			<security mode="Transport">
			  <transport clientCredentialType="Basic" />
			</security>
		  </binding>
		</basicHttpBinding>
	  </bindings>
	  <client>
		<endpoint address="https://example.com/service"
				  binding="basicHttpBinding"
				  bindingConfiguration="MyBinding"
				  contract="IMyService" />
	  </client>
	  <behaviors>
		<endpointBehaviors>
		  <behavior>
			<clientCredentials>
			  <userName userName="serviceUser" password="servicePassword" />
			</clientCredentials>
		  </behavior>
		</endpointBehaviors>
	  </behaviors>
	</system.serviceModel>  
</configuration>


#>
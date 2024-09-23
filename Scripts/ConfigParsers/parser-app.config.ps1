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
Get-CredentialsFromConfigFile -configFilePath "c:\temp\configs\app.config"


<# app.config

<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <configSections>
    <!-- Section handlers for custom service credentials -->
    <section name="serviceCredentials" type="System.Configuration.NameValueSectionHandler" />
    <sectionGroup name="system.net">
      <section name="settings" type="System.Net.Configuration.SettingsSection, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" />
    </sectionGroup>
  </configSections>

  <!-- Application-specific settings -->
  <appSettings>
    <add key="ApplicationUsername" value="myAppUser" />
    <add key="ApplicationPassword" value="myAppPassword" />
    <add key="OAuthServiceUrl" value="https://oauth.example.com/token" />
    <add key="ClientId" value="myClientId" />
    <add key="ClientSecret" value="myClientSecret" />
    <add key="ServiceUrl" value="https://service.example.com/api" />
    <add key="ServiceUserName" value="serviceUser" />
    <add key="ServicePassword" value="servicePassword" />
    <add key="ApiEndpoint" value="https://api.example.com/endpoint" />
    <add key="ApiUserName" value="apiUser" />
    <add key="ApiPassword" value="apiPassword" />
  </appSettings>

  <!-- Custom service credentials -->
  <serviceCredentials>
    <add key="ServiceUrl" value="https://customservice.example.com" />
    <add key="UserName" value="customUser" />
    <add key="Password" value="customPassword" />
  </serviceCredentials>

  <!-- Connection strings for various databases -->
  <connectionStrings>
    <add name="SqlServerConnection"
         connectionString="Data Source=localhost;Initial Catalog=myDB;User ID=myUser;Password=myPass;"
         providerName="System.Data.SqlClient" />
    <add name="SqlServerIntegratedSecurity"
         connectionString="Data Source=localhost;Initial Catalog=myDB;Integrated Security=True;"
         providerName="System.Data.SqlClient" />
    <add name="MySqlConnection"
         connectionString="Server=localhost;Database=myDB;User=myUser;Password=myPass;"
         providerName="MySql.Data.MySqlClient" />
    <add name="PostgreSqlConnection"
         connectionString="Host=localhost;Port=5432;Database=myDB;Username=myUser;Password=myPass;"
         providerName="Npgsql" />
    <add name="OracleConnection"
         connectionString="Data Source=MyOracleDB;User Id=oracleUser;Password=oraclePass;"
         providerName="Oracle.ManagedDataAccess.Client" />
  </connectionStrings>

  <!-- Web-specific settings -->
  <system.web>
    <compilation debug="true" />
    <authentication mode="Forms">
      <forms loginUrl="login.aspx" timeout="30">
        <credentials passwordFormat="Clear">
          <user name="user1" password="password1" />
          <user name="user2" password="password2" />
        </credentials>
      </forms>
    </authentication>
    <customErrors mode="Off" />
  </system.web>

  <!-- Email (SMTP) configuration -->
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

  <!-- WCF Service configuration -->
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
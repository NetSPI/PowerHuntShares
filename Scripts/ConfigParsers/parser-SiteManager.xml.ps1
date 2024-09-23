# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

# Function to check if a string is a valid base64-encoded string
function IsBase64String {
    param ([string]$string)
    if ($string -match '^[a-zA-Z0-9\+/]*={0,2}$' -and ($string.Length % 4 -eq 0)) {
        return $true
    }
    return $false
}

# Function to process the SiteManager.xml file and extract server information
function Get-SiteManagerServerInfo {
    param (
        [string]$xmlFilePath
    )

    # Check if the file exists
    if (-not (Test-Path $xmlFilePath)) {
        Write-Error "File not found: $xmlFilePath"
        return
    }

    # Load the XML file
    $xml = [xml](Get-Content $xmlFilePath)

    # Iterate through each server entry and extract relevant information
    $xml.FileZilla3.Servers.Server | ForEach-Object {
        $decodedPassword = "Invalid or not present"

        # Access the Pass element's inner text, ensuring it's properly treated as a string
        [string]$base64Pass = $_.Pass.InnerText
        # Check if the password is a valid base64 string before decoding
        if ($base64Pass) {
            try {
                # Trim any extra whitespace from the base64 string
                $cleanPass = $base64Pass.Trim()
                $decodedPassword = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($cleanPass))
            } catch {
                $decodedPassword = "Error decoding password: $_"
            }
        }

        # Output the server details
        [pscustomobject]@{
            Server   = $_.Host
            Port     = $_.Port
            Username = $_.User
            Password = $decodedPassword
        }
    }
}

# Example usage
$xmlFilePath = "c:\temp\configs\SiteManager.xml"
Get-SiteManagerServerInfo -xmlFilePath $xmlFilePath




<# SiteManager.xml

<?xml version="1.0" encoding="UTF-8"?>
<FileZilla3>
  <Servers>
    <Server>
      <Host>ftp.example.com</Host>
      <Port>21</Port>
      <Protocol>0</Protocol> <!-- 0 for FTP, 1 for SFTP -->
      <Type>0</Type> <!-- 0 for normal FTP, 1 for FTP over TLS/SSL -->
      <User>username</User>
      <Pass encoding="base64">SGVsbG9QYXNzd29yZA==</Pass> <!-- Password encoded in base64 -->
      <Logontype>1</Logontype> <!-- 0 for anonymous, 1 for normal -->
      <TimezoneOffset>0</TimezoneOffset>
      <PasvMode>MODE_DEFAULT</PasvMode> <!-- Default is passive mode -->
      <MaximumMultipleConnections>0</MaximumMultipleConnections>
      <EncodingType>Auto</EncodingType>
      <BypassProxy>0</BypassProxy>
      <Name>My FTP Site</Name>
      <Comments>Sample FTP site for demonstration</Comments>
      <LocalDir/>
      <RemoteDir/>
      <SyncBrowsing>0</SyncBrowsing>
      <DirectoryComparison>0</DirectoryComparison>
    </Server>

    <Server>
      <Host>sftp.example.com</Host>
      <Port>22</Port>
      <Protocol>1</Protocol> <!-- 1 for SFTP -->
      <Type>1</Type> <!-- 1 for explicit FTP over TLS -->
      <User>sftpuser</User>
      <Pass encoding="base64">SGVsbG9QYXNzd29yZA==</Pass>
      <Logontype>1</Logontype>
      <TimezoneOffset>0</TimezoneOffset>
      <PasvMode>MODE_DEFAULT</PasvMode>
      <MaximumMultipleConnections>1</MaximumMultipleConnections>
      <EncodingType>Auto</EncodingType>
      <BypassProxy>0</BypassProxy>
      <Name>My SFTP Site</Name>
      <Comments>Sample SFTP site</Comments>
      <LocalDir/>
      <RemoteDir/>
      <SyncBrowsing>0</SyncBrowsing>
      <DirectoryComparison>0</DirectoryComparison>
    </Server>
  </Servers>
</FileZilla3>


#>
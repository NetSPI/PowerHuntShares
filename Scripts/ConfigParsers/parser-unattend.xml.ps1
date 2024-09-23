# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Parse-UnattendFile {
    param (
        [string]$filePath
    )

    # Load the XML file
    [xml]$xmlContent = Get-Content -Path $filePath

    # Create an array to store the parsed credentials
    $credentials = @()

    # Define namespaces used in the XML file
    $namespace = @{ 
        "unattend" = "urn:schemas-microsoft-com:unattend" 
        "wcm" = "http://schemas.microsoft.com/WMIConfig/2002/State"
    }

    # Function to decode Base64 if password is encoded
    function Decode-PasswordIfNeeded {
        param (
            [string]$passwordValue,
            [bool]$isPlainText
        )
        
        if ($isPlainText -eq $false) {
            try {
                # Decode Base64 password
                $decodedPassword = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($passwordValue))
                return $decodedPassword
            } catch {
                Write-Host "Error: Unable to decode Base64 string, returning original value."
                return $passwordValue
            }
        }
        else {
            return $passwordValue
        }
    }

    # Parse AutoLogon credentials
    $autoLogon = $xmlContent.unattend.settings.component | Where-Object { 
        $_.name -eq "Microsoft-Windows-Shell-Setup" -and $_.AutoLogon -ne $null 
    }
    if ($autoLogon) {
        $username = $autoLogon.AutoLogon.Username
        $password = $autoLogon.AutoLogon.Password.Value
        $isPlainText = $autoLogon.AutoLogon.Password.PlainText -eq "true"

        # Decode password if necessary
        $password = Decode-PasswordIfNeeded -passwordValue $password -isPlainText $isPlainText

        $credentials += [pscustomobject]@{
            User     = $username
            Password = $password
            Source   = "AutoLogon"
        }
    }

    # Parse LocalAccounts credentials
    $localAccounts = $xmlContent.unattend.settings.component.UserAccounts.LocalAccounts.LocalAccount | Where-Object { $_ -ne $null }
    foreach ($account in $localAccounts) {
        $username = $account.Name
        $password = $account.Password.Value
        $isPlainText = $account.Password.PlainText -eq "true"

        # Decode password if necessary
        $password = Decode-PasswordIfNeeded -passwordValue $password -isPlainText $isPlainText

        $credentials += [pscustomobject]@{
            User     = $username
            Password = $password
            Source   = "LocalAccount"
        }
    }

    # Return the collected credentials as an array of objects
    return $credentials
}

# Example usage:
$parsedCredentials = Parse-UnattendFile -filePath "c:\temp\configs\unattend-base64.xml"

# Display the results
$parsedCredentials | Format-Table -AutoSize



<# unattend.xml

<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <ComputerName>*</ComputerName>
            <RegisteredOrganization>acme corp.</RegisteredOrganization>
            <RegisteredOwner>acme corp.</RegisteredOwner>
            <WindowsFeatures>
                <ShowInternetExplorer>false</ShowInternetExplorer>
            </WindowsFeatures>
            <AutoLogon>
                <Username>LocalAdmin</Username>
                <Enabled>true</Enabled>
                <LogonCount>10</LogonCount>
                <Password>
                    <Value>UEBzc3dvcmQxMjMh</Value>  <!-- This is Base64 for 'P@ssword123!' -->
                    <PlainText>false</PlainText>
                </Password>
            </AutoLogon>
        </component>
    </settings>

    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>UEBzc3dvcmQxMjMh</Value>  <!-- This is Base64 for 'P@ssword123!' -->
                            <PlainText>false</PlainText>
                        </Password>
                        <Group>Administrators</Group>
                        <Description>Provisioning Admin</Description>
                        <DisplayName>LocalAdmin</DisplayName>
                        <Name>LocalAdmin</Name>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <ProtectYourPC>1</ProtectYourPC>
            </OOBE>
        </component>
    </settings>
</unattend>


#>
# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-SysprepCredentials {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    # Check if file exists
    if (-Not (Test-Path $FilePath)) {
        Write-Error "File does not exist: $FilePath"
        return
    }

    # Initialize an empty hashtable to store credentials
    $credentials = @{ 
        AdminPassword        = $null
        JoinDomain           = $null
        DomainAdmin          = $null
        DomainAdminPassword  = $null
    }

    # Read the sysprep.inf file
    $fileContent = Get-Content -Path $FilePath

    # Loop through each line and extract relevant credentials
    foreach ($line in $fileContent) {
        if ($line -match 'AdminPassword\s*=\s*(.+)') {
            $credentials['AdminPassword'] = $matches[1].Trim()
        }

        if ($line -match 'JoinDomain\s*=\s*(.+)') {
            $credentials['JoinDomain'] = $matches[1].Trim()
        }

        if ($line -match 'DomainAdmin\s*=\s*(.+)') {
            $credentials['DomainAdmin'] = $matches[1].Trim()
        }

        if ($line -match 'DomainAdminPassword\s*=\s*(.+)') {
            $credentials['DomainAdminPassword'] = $matches[1].Trim()
        }
    }

    # Create and return a PowerShell object
    $credObject = [pscustomobject]@{
        AdminPassword        = $credentials['AdminPassword']
        JoinDomain           = $credentials['JoinDomain']
        DomainAdmin          = $credentials['DomainAdmin']
        DomainAdminPassword  = $credentials['DomainAdminPassword']
    }

    return $credObject
}

# Example usage:
$result = Get-SysprepCredentials -FilePath "c:\temp\configs\sysprep.inf"
$result

<# sysprep.inf

[Unattended]
OemSkipEula=Yes
InstallFilesPath=C:\sysprep\i386

[GuiUnattended]
AdminPassword=YourAdminPassword
EncryptedAdminPassword=NO
OEMSkipRegional=1
TimeZone=004
OemSkipWelcome=1

[UserData]
ProductKey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
FullName="Your Name"
OrgName="Your Organization"
ComputerName=*

[Display]
BitsPerPel=32
Xresolution=1024
YResolution=768
Vrefresh=60

[SetupMgr]
DistFolder=C:\sysprep\i386
DistShare=windist

[Identification]
JoinDomain=YourDomain
DomainAdmin=YourDomainAdmin
DomainAdminPassword=YourDomainAdminPassword

[Networking]
InstallDefaultComponents=Yes

#>
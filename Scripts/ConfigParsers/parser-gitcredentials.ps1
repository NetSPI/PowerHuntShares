# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# Intended input: .git-credentials files
function Get-PwGitCredentials {
    param (
        [string]$ComputerName = $null,   # Optional
        [string]$ShareName    = $null,   # Optional
        [string]$UncFilePath  = $null,   # Optional
        [string]$FileName     = $null,   # Optional
        [string]$FilePath                # Required
    )

    # Check if file exists
    if (-Not (Test-Path -Path $FilePath)) {
        Write-Error "File not found at path: $FilePath"
        return
    }

    # Array to store parsed credentials
    $credentialsList = @()

    # Parse each line in .git-credentials
    foreach ($line in Get-Content -Path $FilePath) {
        if ($line -match 'https://([^:]+):([^@]+)@(.*)') {
            $username = $matches[1]
            $passwordEnc = $matches[2]
            $targetServer = $matches[3] -replace '/.*', ''  # Extract server without path
            $targetURL = $matches[3]

            # Create output structure
            $credentialsList += [PSCustomObject]@{
                ComputerName = $ComputerName
                ShareName    = $ShareName
                UncFilePath  = $UncFilePath
                FileName     = $FileName
                Section      = "NA"
                ObjectName   = "NA"
                TargetURL    = $targetURL
                TargetServer = $targetServer
                TargetPort   = "NA"          # Not in .git-credentials format
                Database     = "NA"
                Domain       = "NA"
                Username     = $username
                Password     = "NA"          # Decrypted password not available
                PasswordEnc  = $passwordEnc  # Original token/password as in file
                KeyFilePath  = "NA"
            }
        }
    }

    # Return parsed credentials
    return $credentialsList
}

# Example usage
# Get-PwGitCredentials -FilePath "C:\temp\.git-credentials" -ComputerName "MyComputer" -ShareName "MyShare" -UncFilePath "\\MyComputer\MyShare\.git-credentials" -FileName ".git-credentials"

<# Example config

https://username1:ghp_token1example@github.com
https://username2:ghp_token2example@bitbucket.org
https://my-gitlab-username:glpat_token3example@gitlab.com
https://username4:ghp_token4example@company-git.example.com

#>


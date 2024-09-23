# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-JenkinsUserCredentials {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    # Ensure the file exists
    if (-Not (Test-Path $FilePath)) {
        Write-Error "File not found: $FilePath"
        return
    }

    # Read the XML content as plain text
    $xmlText = Get-Content -Path $FilePath -Raw

    # Replace XML version 1.1 with 1.0
    $xmlText = $xmlText -replace "version='1.1'", "version='1.0'"

    # Now parse the XML
    [xml]$xmlContent = [xml]$xmlText

    # Extract the full name (username)
    $fullName = $xmlContent.user.fullName

    # Extract the password hash
    $passwordHash = $xmlContent.user.properties.'hudson.security.HudsonPrivateSecurityRealm_-Details'.passwordHash

    # Create and return the result as a PowerShell object
    $result = [PSCustomObject]@{
        Username     = $fullName
        PasswordHash = $passwordHash
    }

    return $result
}


# Example usage:
$userCredentials = Get-JenkinsUserCredentials -FilePath "c:\temp\configs\config.xml"
$userCredentials


<# config.xml - jenkins - hudson.security.HudsonPrivateSecurityRealm - stored in $JENKINS_HOME/users/username/config.xml

$JENKINS_HOME/users/username/config.xml

<?xml version='1.1' encoding='UTF-8'?>
<user>
  <fullName>John Doe</fullName>
  <properties>
    <hudson.security.HudsonPrivateSecurityRealm_-Details>
      <!-- Hashed password using bcrypt -->
      <passwordHash>#jbcrypt:$2a$10$D6wVozrLhk.TIq.jBBKZluIh/EqzpjCUJFT/mWUnyAO4EYmxk5.aK</passwordHash>
    </hudson.security.HudsonPrivateSecurityRealm_-Details>
  </properties>
</user>

#>
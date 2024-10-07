# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# Intended input: .fetchmailrc files

function Get-PwFetchmailrc {
    param (
        [string]$FilePath,
        [string]$ComputerName = "NA",
        [string]$ShareName = "NA",
        [string]$UncFilePath = "NA",
        [string]$FileName = "NA",
        [string]$TargetURL = "NA"
    )

    if (-not (Test-Path -Path $FilePath)) {
        Write-Host "File not found: $FilePath"
        return
    }

    # Read and clean the lines into a modifiable list
    $lines = [System.Collections.Generic.List[string]](Get-Content -Path $FilePath | ForEach-Object {
        $_.Trim()
    } | Where-Object { $_ -notmatch '^#' }) # Remove comments

    # Consolidate multi-line configurations
    for ($i = $lines.Count - 1; $i -gt 0; $i--) {
        if ($lines[$i] -notmatch '^(defaults|poll|skip)\s+') {
            $lines[$i - 1] += " " + $lines[$i]
            $lines.RemoveAt($i)
        }
    }

    # Initialize variables
    $defaults = @{}
    $credentials = @()

    # Function to parse individual configuration lines
    function Parse-FetchmailRCLine {
        param ($line)
        $cred = @{
            "Username"   = @()
            "Password"   = @()
            "TargetServer" = ""
            "Section"    = ""
            "TargetPort" = ""
        }

        # Extract users, passwords, server, protocol, and port
        $userMatch = [regex]::Match($line, '\s+user(?:name)?\s+"([^"]+)"')
        if ($userMatch.Success) {
            $cred["Username"] = $userMatch.Groups[1].Value
        }

        $passMatch = [regex]::Match($line, '\s+pass(?:word)?\s+"([^"]+)"')
        if ($passMatch.Success) {
            $cred["Password"] = $passMatch.Groups[1].Value
        }

        $cred["TargetServer"] = if ($line -match '^(?:poll|skip)\s+(\S+)') { $matches[1] } else { $cred["TargetServer"] }
        $cred["Section"]    = if ($line -match '\s+proto(?:col)?\s+(\S+)') { $matches[1] } else { $cred["Section"] }
        $cred["TargetPort"] = if ($line -match '\s+(?:port|service)\s+(\S+)') { $matches[1] } else { $cred["TargetPort"] }

        # Return credentials if found
        return $cred
    }

    # Parse each line for credentials
    foreach ($line in $lines) {
        # If 'defaults' line, save defaults
        if ($line -match '^defaults') {
            $defaults = Parse-FetchmailRCLine -line $line
            continue
        }

        # Parse line, merge with defaults if any
        $parsedCred = Parse-FetchmailRCLine -line $line
        foreach ($key in $defaults.Keys) {
            if (-not $parsedCred[$key] -or ($parsedCred[$key] -is [array] -and $parsedCred[$key].Count -eq 0)) {
                $parsedCred[$key] = $defaults[$key]
            }
        }

        # Add parsed credentials if valid
        if ($parsedCred["TargetServer"] -and $parsedCred["Section"] -and $parsedCred["Username"] -and $parsedCred["Password"]) {
            $credentials += [pscustomobject]@{
                ComputerName = $ComputerName
                ShareName    = $ShareName
                UncFilePath  = $UncFilePath
                FileName     = $FileName
                Section      = $parsedCred["Section"]
                ObjectName   = "NA"
                TargetURL    = $TargetURL
                TargetServer = $parsedCred["TargetServer"]
                TargetPort   = $parsedCred["TargetPort"]
                Database     = "NA"
                Domain       = "NA"
                Username     = $parsedCred["Username"]
                Password     = $parsedCred["Password"]
                PasswordEnc  = "NA"
                KeyFilePath  = "NA"
            }
        }
    }

    # Output credentials
    if ($credentials.Count -eq 0) {
        Write-Host "No credentials found in $FilePath"
    } else {
        $credentials | Format-Table -AutoSize
    }

    return $credentials
}

# Sample Command
# Get-PwFetchmailrc -FilePath "C:\temp\.fetchmailrc" -ComputerName "MyComputer" -ShareName "MyShare" -UncFilePath "\\path\to\.fetchmailrc" -FileName ".fetchmailrc" 

<# Sample .fetchmailrc file

# Global options
set daemon 300

# Default options for all servers
defaults
protocol IMAP
port 993
keep

# Fetch mail from the first server
poll mail.example.com
    proto IMAP
    user "user1@example.com" pass "password1"
    ssl

# Fetch mail from another server with custom settings
poll mail.anotherexample.com
    proto POP3
    user "user2@anotherexample.com" pass "password2"
    port 995
    ssl

# Another example with a forwarding SMTP setup
poll mail.forwardexample.com via smtp.example.com
    proto IMAP
    user "forwarduser@forwardexample.com" pass "forwardpassword"
    smtphost smtp.example.com
    esmtpname "smtpuser@example.com" esmtppassword "smtppassword"

# Additional account with a different protocol and no SSL
poll plainexample.com
    proto POP3
    user "plainuser@plainexample.com" pass "plainpassword"
    port 110


#>

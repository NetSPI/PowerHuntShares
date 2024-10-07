# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)
# This is for parsing group policy preference files and should support groups.xml, datasources.xml, drives.xml, printers.xml, scheduletasks.xml, and services.xml

function Get-GPPPasswordMod {
<#
.SYNOPSIS
    Retrieves plaintext passwords from specified Group Policy XML files and provides functionality to encrypt passwords.

.DESCRIPTION
    This function processes specified GPP XML files and retrieves plaintext passwords for accounts pushed through Group Policy Preferences.
    It also provides a method to encrypt passwords for use in XML files.

.EXAMPLE
    PS C:\> Get-GPPPasswordMod -InputFilePath "\\192.168.1.1\sysvol\demo.com\Policies\{31B2F340-016D-11D2-945F-00C04FB984F9}\USER\Preferences"
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]$InputFilePath
    )

    # ----------------------------------------------------------------
    # Function to decrypt cpassword
    # ----------------------------------------------------------------
    function Get-DecryptedCpassword {
        [CmdletBinding()]
        Param (
            [string] $Cpassword 
        )
        
        try {
            # Append padding
            $Mod = ($Cpassword.length % 4)
            switch ($Mod) {
                '1' { $Cpassword = $Cpassword.Substring(0,$Cpassword.Length -1) }
                '2' { $Cpassword += ('=' * (4 - $Mod)) }
                '3' { $Cpassword += ('=' * (4 - $Mod)) }
            }
            $Base64Decoded = [Convert]::FromBase64String($Cpassword)
            $AesObject = New-Object System.Security.Cryptography.AesCryptoServiceProvider
            [Byte[]] $AesKey = @(0x4e,0x99,0x06,0xe8,0xfc,0xb6,0x6c,0xc9,0xfa,0xf4,0x93,0x10,0x62,0x0f,0xfe,0xe8,0xf4,0x96,0xe8,0x06,0xcc,0x05,0x79,0x90,0x20,0x9b,0x09,0xa4,0x33,0xb6,0x6c,0x1b)
            $AesIV = New-Object Byte[]($AesObject.IV.Length)
            $AesObject.IV = $AesIV
            $AesObject.Key = $AesKey
            $DecryptorObject = $AesObject.CreateDecryptor()
            [Byte[]] $OutBlock = $DecryptorObject.TransformFinalBlock($Base64Decoded, 0, $Base64Decoded.length)
            return [System.Text.UnicodeEncoding]::Unicode.GetString($OutBlock)
        } catch { Write-Error $Error[0] }
    }


    # ----------------------------------------------------------------
    # Setup data table to store GPP Information
    # ----------------------------------------------------------------
    if ($InputFilePath) {
        $TableGPPPasswords = New-Object System.Data.DataTable         
        $TableGPPPasswords.Columns.Add('NewName') | Out-Null
        $TableGPPPasswords.Columns.Add('Changed') | Out-Null
        $TableGPPPasswords.Columns.Add('UserName') | Out-Null        
        $TableGPPPasswords.Columns.Add('CPassword') | Out-Null
        $TableGPPPasswords.Columns.Add('Password') | Out-Null        
        $TableGPPPasswords.Columns.Add('File') | Out-Null           

        # ----------------------------------------------------------------
        # Find, parse, decrypt, and display results from XML files
        # ----------------------------------------------------------------
        $XmlFiles = Get-ChildItem -Path $InputFilePath -Recurse -ErrorAction SilentlyContinue -Include 'Groups.xml','Services.xml','ScheduledTasks.xml','DataSources.xml','Printers.xml','Drives.xml'

        # Parse GPP config files
        $XmlFiles | ForEach-Object {
            $FileFullName = $_.FullName
            $FileName = $_.Name

            # Read the file content as a string
            $fileContentString = Get-Content -Path "$FileFullName" -Raw
            
            try {
                # Attempt to load the XML content
                [xml]$FileContent = [xml]$fileContentString
            } catch {
                Write-Error "Failed to parse XML in file '$FileFullName'. Error: $_"
                return
            }
            
            # Process Drives.xml
            if ($FileName -eq "Drives.xml") {
                $FileContent.Drives.Drive | ForEach-Object {
                    [string]$Username = $_.Properties.username
                    [string]$CPassword = $_.Properties.cpassword
                    [string]$Password = Get-DecryptedCpassword $CPassword
                    [datetime]$Changed = $_.Changed
                    [string]$NewName = ""         
                    $TableGPPPasswords.Rows.Add($NewName, $Changed, $Username, $CPassword, $Password, $FileFullName) | Out-Null      
                }
            }

            # Process Groups.xml
            if ($FileName -eq "Groups.xml") {
                $FileContent.Groups.User | ForEach-Object {
                    [string]$Username = $_.Properties.username
                    [string]$CPassword = $_.Properties.cpassword
                    [string]$Password = Get-DecryptedCpassword $CPassword
                    [datetime]$Changed = $_.Changed
                    [string]$NewName = $_.Properties.newname        
                    $TableGPPPasswords.Rows.Add($NewName, $Changed, $Username, $CPassword, $Password, $FileFullName) | Out-Null      
                }
            }

            # Process Services.xml
            if ($FileName -eq "Services.xml") {
                $FileContent.NTServices.NTService | ForEach-Object {
                    [string]$Username = $_.Properties.accountname
                    [string]$CPassword = $_.Properties.cpassword
                    [string]$Password = Get-DecryptedCpassword $CPassword
                    [datetime]$Changed = $_.Changed
                    [string]$NewName = ""         
                    $TableGPPPasswords.Rows.Add($NewName, $Changed, $Username, $CPassword, $Password, $FileFullName) | Out-Null      
                }
            }

            # Process ScheduledTasks.xml
            if ($FileName -eq "ScheduledTasks.xml") {
                $FileContent.ScheduledTasks.Task | ForEach-Object {
                    [string]$Username = $_.Properties.runas
                    [string]$CPassword = $_.Properties.cpassword
                    [string]$Password = Get-DecryptedCpassword $CPassword
                    [datetime]$Changed = $_.Changed
                    [string]$NewName = ""         
                    $TableGPPPasswords.Rows.Add($NewName, $Changed, $Username, $CPassword, $Password, $FileFullName) | Out-Null      
                }
            }

            # Process DataSources.xml
            if ($FileName -eq "DataSources.xml") {
                $FileContent.DataSources.DataSource | ForEach-Object {
                    [string]$Username = $_.Properties.username
                    [string]$CPassword = $_.Properties.cpassword
                    [string]$Password = Get-DecryptedCpassword $CPassword
                    [datetime]$Changed = $_.Changed
                    [string]$NewName = ""         
                    $TableGPPPasswords.Rows.Add($NewName, $Changed, $Username, $CPassword, $Password, $FileFullName) | Out-Null      
                }
            }

            # Process Printers.xml
            if ($FileName -eq "Printers.xml") {
                $FileContent.Printers.SharedPrinter | ForEach-Object {
                    [string]$Username = $_.Properties.username
                    [string]$CPassword = $_.Properties.cpassword
                    [string]$Password = Get-DecryptedCpassword $CPassword
                    [datetime]$Changed = $_.Changed
                    [string]$NewName = ""         
                    $TableGPPPasswords.Rows.Add($NewName, $Changed, $Username, $CPassword, $Password, $FileFullName) | Out-Null      
                }
            }
        }

        # Check if anything was found
        if (-not $XmlFiles) {
            throw 'No preference files found.'
            return
        }

        # Display results
        $TableGPPPasswords
    }

    # Allow users to encrypt passwords
    function Set-EncryptedCpassword {
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true)]
            [string]$Password
        )
        
        # Create a new AES .NET Crypto Object
        $AesObject = New-Object System.Security.Cryptography.AesCryptoServiceProvider
        [Byte[]] $AesKey = @(0x4e,0x99,0x06,0xe8,0xfc,0xb6,0x6c,0xc9,0xfa,0xf4,0x93,0x10,0x62,0x0f,0xfe,0xe8,0xf4,0x96,0xe8,0x06,0xcc,0x05,0x79,0x90,0x20,0x9b,0x09,0xa4,0x33,0xb6,0x6c,0x1b)
        $AesIV = New-Object Byte[]($AesObject.IV.Length)
        $AesObject.IV = $AesIV
        $AesObject.Key = $AesKey
        $EncryptorObject = $AesObject.CreateEncryptor()
        
        # Convert password to byte array and encrypt
        [Byte[]] $InputBytes = [System.Text.Encoding]::Unicode.GetBytes($Password)
        [Byte[]] $EncryptedBytes = $EncryptorObject.TransformFinalBlock($InputBytes, 0, $InputBytes.Length)
        $EncryptedCpassword = [Convert]::ToBase64String($EncryptedBytes)

        return $EncryptedCpassword
    }
}

# Example path to the directory containing the GPP XML files
$pathToGPPFiles = "c:\temp\configs\ScheduledTasks.xml"

# Call the function
$gppPasswords = Get-GPPPasswordMod -InputFilePath $pathToGPPFiles

# Display the results
$gppPasswords


<# Bonus function for encrypting password

    # ----------------------------------------------------------------
    # Function to encrypt a password
    # ----------------------------------------------------------------
    function Set-EncryptedCpassword {
        [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true)]
            [string]$Password
        )
        
        # Create a new AES .NET Crypto Object
        $AesObject = New-Object System.Security.Cryptography.AesCryptoServiceProvider
        [Byte[]] $AesKey = @(0x4e,0x99,0x06,0xe8,0xfc,0xb6,0x6c,0xc9,0xfa,0xf4,0x93,0x10,0x62,0x0f,0xfe,0xe8,0xf4,0x96,0xe8,0x06,0xcc,0x05,0x79,0x90,0x20,0x9b,0x09,0xa4,0x33,0xb6,0x6c,0x1b)
        $AesIV = New-Object Byte[]($AesObject.IV.Length)
        $AesObject.IV = $AesIV
        $AesObject.Key = $AesKey
        $EncryptorObject = $AesObject.CreateEncryptor()
        
        # Convert password to byte array and encrypt
        [Byte[]] $InputBytes = [System.Text.Encoding]::Unicode.GetBytes($Password)
        [Byte[]] $EncryptedBytes = $EncryptorObject.TransformFinalBlock($InputBytes, 0, $InputBytes.Length)
        $EncryptedCpassword = [Convert]::ToBase64String($EncryptedBytes)

        return $EncryptedCpassword
    }

    $plainTextPassword = "MyAwesomePassword!"
    $encryptedPassword = Set-EncryptedCpassword -Password $plainTextPassword
    Write-Output $encryptedPassword

#>

<# Printers.xml

<?xml version="1.0" encoding="utf-8"?>
<Printers 
           clsid="{1F577D12-3D1B-471e-A1B7-060317597B9C}" 
           disabled="1">
   <SharedPrinter 
           clsid="{9A5E9697-9095-436d-A0EE-4D128FDFBCE5}" 
           name="b35-1053-a" status="b35-1053-a" 
           image="2" 
           changed="2007-07-06 20:49:50" 
           uid="{D954AF72-DDFC-498D-A185-A569A0D02FC4}">
     <Properties 
           action="U" 
           comment="" 
           path="\\PRN-CORP1\b35-1053-a" 
           location="" 
           default="1" 
           skipLocal="1" 
           deleteAll="0" 
           persistent="0" 
           deleteMaps="0" 
           cpassword="5gn5fUqMaeGJkLEPgl3iH9UfLATVxRAHE8GvAvekwnicLYf2Pynj7ifihvajBRA3"
           port=""/>
   </SharedPrinter>
   <PortPrinter 
           clsid="{C3A739D2-4A44-401e-9F9D-88E5E77DFB3E}" 
           name="10.10.10.10" 
           status="10.10.10.10" 
           image="2" 
           changed="2007-07-06 20:50:43" 
           uid="{6A331F02-C488-44B6-988C-0730C2C1E374}">
     <Properties 
           ipAddress="10.10.10.10" 
           action="U" 
           location="1st Floor" 
           localName="Lexmark 1150S" 
           comment="Only for use by graphics" 
           default="1" 
           skipLocal="1" 
           useDNS="0" 
           path="Lexmark 1150S (Color)" 
           deleteAll="0" 
           lprQueue="" 
           snmpCommunity="Local" 
           protocol="PROTOCOL_RAWTCP_TYPE" 
           portNumber="9100" 
           doubleSpool="0" 
           snmpEnabled="1" 
           snmpDevIndex="1"/>
   </PortPrinter>
   <LocalPrinter 
           clsid="{F08996D5-568B-45f5-BB7A-D3FB1E370B0A}" 
           name="Epsom DotMatrix" 
           status="1st Floor Copy Room" 
           image="2" 
           changed="2007-07-06 20:51:47" 
           uid="{65D3663D-BC4E-45D2-8EA8-1DB3AC7158CB}">
     <Properties 
           action="U" 
           name="Epsom DotMatrix" 
           port="LPT1:" 
           path="EpsomDots" 
           default="1" 
           deleteAll="0" 
           location="1st Floor Copy Room" 
           comment="Old printer. Don't use."/>
   </LocalPrinter>
</Printers>

#>


<# ScheduledTasks.xml

<?xml version="1.0" encoding="utf-8"?>
<ScheduledTasks clsid="{CC63F200-7309-4ba0-B154-A71CD118DBCC}"
                 disabled="1">
   <Task clsid="{2DEECB1C-261F-4e13-9B21-16FB83BC03BD}"
         name="Cleanup" 
         image="2" 
         changed="2007-07-06 20:54:40"
         uid="{96C2DBEF-ECAE-4BD4-B1C7-0CD71116595C}">
     <Filters>
       <FilterOs hidden="1" 
                 not="1" 
                 bool="AND" 
                 class="NT"
                 version="VISTA" 
                 type="NE" 
                 edition="NE" 
                 sp="NE"/>
     </Filters>
     <Properties action="U" 
                 name="Cleanup"
                 appName="\\scratch\filecleanup.exe" 
                 args="-all" 
                 startIn="c:\"
                 comment="Runs for almost 4 hours" 
                 enabled="1"
                 deleteWhenDone="0" 
                 startOnlyIfIdle="0" 
                 stopOnIdleEnd="0"
                 noStartIfOnBatteries="1" 
                 stopIfGoingOnBatteries="1"
                 cpassword="5gn5fUqMaeGJkLEPgl3iH9UfLATVxRAHE8GvAvekwnicLYf2Pynj7ifihvajBRA3"
                 systemRequired="0">
       <Triggers>
         <Trigger type="DAILY" 
                  startHour="10" 
                  startMinutes="0"
                  beginYear="2007" 
                  beginMonth="7" 
                  beginDay="6"
                  hasEndDate="0" 
                  repeatTask="0" 
                  interval="1"/>
       </Triggers>
     </Properties>
   </Task>
  
   <ImmediateTask clsid="{9F030D12-DDA3-4C26-8548-B7CE9151166A}"
                  name="PingCorporate" 
                  changed="2007-07-06 20:55:15"
                  uid="{3D15BAA9-E05A-470C-9298-FA4C0B701695}">
     <Filters>
       <FilterOs hidden="1" 
                 not="1" 
                 bool="AND" 
                 class="NT"
                 version="VISTA" 
                 type="NE" 
                 edition="NE" 
                 sp="NE"/>
     </Filters>
     <Properties name="PingCorporate" 
                 appName="c:\ping.exe"
                 args="-ip 10.10.10.10" 
                 startIn="" 
                 comment=""
                 maxRunTime="259200000" 
                 startOnlyIfIdle="1" 
                 idleMinutes="10"
                 deadlineMinutes="60" 
                 stopOnIdleEnd="0"
                 noStartIfOnBatteries="1" 
                 stopIfGoingOnBatteries="1"
                 systemRequired="0"/>
   </ImmediateTask>
 <TaskV2 clsid="{D8896631-B747-47a7-84A6-C155337F3BC8}" 
 name="Demo" 
 image="2" 
 changed="2008-05-28 21:07:40" 
 uid="{BA81EFFF-E567-4CB8-8708-6C17A5950B0A}" 
 bypassErrors="0" 
 userContext="0" removePolicy="0" 
 desc="This is a test of the system.">
 <Properties action="U" 
   name="Demo" 
   runAs="%LogonDomain%\%LogonUser%" 
 logonType="InteractiveToken">
 <Task version="1.2">
 <RegistrationInfo>
   <Author>WIN-P3LTV7KC6IO\Administrator</Author>
   <Description>Demo</Description>
 </RegistrationInfo>
 <Principals>
   <Principal id="Author">
     <UserId>%LogonDomain%\%LogonUser</UserId>
     <LogonType>InteractiveToken</LogonType>
     <RunLevel>LeastPrivilege</RunLevel>
   </Principal>
 </Principals>
 <Settings>
   <IdleSettings>
     <Duration>PT10M</Duration>
     <WaitTimeout>PT1H</WaitTimeout>
     <StopOnIdleEnd>true</StopOnIdleEnd>
     <RestartOnIdle>true</RestartOnIdle>
   </IdleSettings>
 <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
 <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
 <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
 <AllowHardTerminate>true</AllowHardTerminate>
 <StartWhenAvailable>true</StartWhenAvailable>
 <RunOnlyIfNetworkAvailable>true</RunOnlyIfNetworkAvailable>
 <AllowStartOnDemand>true</AllowStartOnDemand>
 <Enabled>true</Enabled>
 <Hidden>false</Hidden>
 <RunOnlyIfIdle>true</RunOnlyIfIdle>
 <WakeToRun>true</WakeToRun>
 <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
 <Priority>7</Priority>
 <RestartOnFailure>
 <Interval>PT1M</Interval>
 <Count>3</Count>
 </RestartOnFailure>
 </Settings>
 <Triggers>
   <TimeTrigger>
     <StartBoundary>2008-05-28T14:06:04</StartBoundary>
     <Enabled>true</Enabled>
   </TimeTrigger>
   <CalendarTrigger>
     <StartBoundary>2008-05-28T14:06:08</StartBoundary>
     <Enabled>true</Enabled>
     <ScheduleByDay>
     <DaysInterval>1</DaysInterval>
     </ScheduleByDay>
   </CalendarTrigger>
   <CalendarTrigger>
     <StartBoundary>2008-05-28T14:06:11</StartBoundary>
     <Enabled>true</Enabled>
     <ScheduleByWeek>
       <WeeksInterval>1</WeeksInterval>
       <DaysOfWeek>
          <Sunday/>
          <Thursday/>
       </DaysOfWeek>
     </ScheduleByWeek>
   </CalendarTrigger>
   <CalendarTrigger>
     <StartBoundary>2008-05-28T14:06:16</StartBoundary>
     <Enabled>true</Enabled>
     <ScheduleByMonth>
       <DaysOfMonth>
         <Day>1</Day>
       </DaysOfMonth>
       <Months>
          <January/>
       </Months>
     </ScheduleByMonth>
   </CalendarTrigger>
   <LogonTrigger>
      <Enabled>true</Enabled>
   </LogonTrigger>
   <BootTrigger>
     <Enabled>true</Enabled>
   </BootTrigger>
   <IdleTrigger>
     <Enabled>true</Enabled>
   </IdleTrigger>
   <RegistrationTrigger>
     <Enabled>true</Enabled>
   </RegistrationTrigger>
   <SessionStateChangeTrigger>
     <Enabled>true</Enabled>
     <StateChange>RemoteConnect</StateChange>
   </SessionStateChangeTrigger>
   <SessionStateChangeTrigger>
     <Enabled>true</Enabled>
     <StateChange>RemoteConnect</StateChange>
   </SessionStateChangeTrigger>
   <SessionStateChangeTrigger>
     <Enabled>true</Enabled>
     <StateChange>SessionLock</StateChange>
   </SessionStateChangeTrigger>
   <SessionStateChangeTrigger>
     <Enabled>true</Enabled>
     <StateChange>SessionUnlock</StateChange>
   </SessionStateChangeTrigger>
 </Triggers>
 <Actions>
   <Exec>
     <Command>a</Command>
     <Arguments>b</Arguments>
     <WorkingDirectory>c</WorkingDirectory>
   </Exec>
   <SendEmail>
     <From>a</From>
     <To>b</To>
     <Subject>c</Subject>
     <Body>d</Body>
     <HeaderFields/>
     <Attachments>
       <File>e</File>
      </Attachments>
      <Server>f</Server>
   </SendEmail>
       <ShowMessage>
          <Title>aa</Title>
          <Body>bb</Body>
       </ShowMessage>
     </Actions>
   </Task>
   </Properties>
 </TaskV2>
 <ImmediateTaskV2 clsid="{9756B581-76EC-4169-9AFC-0CA8D43ADB5F}" 
 name="ImdTask" 
 image="2" 
 changed="2008-05-27 03:49:21" 
 uid="{541F1F1E-CAD4-447C-B26F-5D1EAD6965AA}">
 <Filters>
   <FilterOs hidden="1" not="0" bool="AND" class="NT" version="Vista" type="NE" edition="NE" sp="NE"/>
   <FilterOs hidden="1" not="0" bool="OR" class="NT" version="2K8" type="NE" edition="NE" sp="NE"/>
   <FilterOs hidden="1" not="0" bool="OR" class="NT" version="WIN7" type="NE" edition="NE" sp="NE"/>
 </Filters>
 <Properties action="U" 
 name="ImdTask" 
 runAs="%LogonDomain%\%LogonUser%" 
 logonType="InteractiveToken">
 <Task version="1.2">
   <RegistrationInfo>
     <Author>WIN-P3LTV7KC6IO\Administrator</Author>
     <Description>Demo ImdTask </Description>
   </RegistrationInfo>
   <Principals>
     <Principal id="Author">
       <UserId>%LogonDomain%\%LogonUser</UserId>
       <LogonType>InteractiveToken</LogonType>
       <RunLevel>HighestAvailable</RunLevel>
     </Principal>
   </Principals>
 <Settings>
   <IdleSettings>
     <Duration>PT10M</Duration>
     <WaitTimeout>PT1H</WaitTimeout>
     <StopOnIdleEnd>true</StopOnIdleEnd>
     <RestartOnIdle>false</RestartOnIdle>
   </IdleSettings>
   <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
   <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
   <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
   <AllowHardTerminate>true</AllowHardTerminate>
   <StartWhenAvailable>false</StartWhenAvailable>
   <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
   <AllowStartOnDemand>true</AllowStartOnDemand>
   <Enabled>true</Enabled>
   <Hidden>false</Hidden>
   <RunOnlyIfIdle>false</RunOnlyIfIdle>
   <WakeToRun>false</WakeToRun>
   <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
   <Priority>7</Priority>
 </Settings>
   <Actions>
     <Exec><Command>calc.exe</Command>
     </Exec>
   </Actions>
 </Task>
 </Properties>
 </ImmediateTaskV2>
</ScheduledTasks>

#>

<# Services.xml

<?xml version="1.0" encoding="utf-8"?>  
<NTServices clsid="{2CFB484A-4E96-4b5d-A0B6-093D2F91E6AE}">
	<NTService 
           clsid="{AB6F0B67-341F-4e51-92F9-005FBFBA1A43}"
           name="Computer Browser" 
           image="0" 
           changed="2007-07-10 22:52:45"
           uid="{8A3CC7D5-89F1-44DB-8D41-80F6471E17BF}">
	<Properties 
           startupType="NOCHANGE" 
           serviceName="Computer Browser"
           timeout="30" 
           accountName="LocalSystem" 
           interact="1"
           firstFailure="NOACTION" 
           secondFailure="NOACTION"
           thirdFailure="RESTART" 
           resetFailCountDelay="0"
           cpassword="5gn5fUqMaeGJkLEPgl3iH9UfLATVxRAHE8GvAvekwnicLYf2Pynj7ifihvajBRA3"
           restartServiceDelay="900000"/>
	</NTService>
</NTServices>


#>

<# Drives.xml

<?xml version="1.0" encoding="utf-8"?>
<Drives clsid="{8FDDCC1A-0C3C-43cd-A6B4-71A6DF20DA8C}" 
         disabled="1">
   <Drive clsid="{935D1B74-9CB8-4e3c-9914-7DD559B7A417}" 
          name="S:" 
          status="S:" 
          image="2" 
          changed="2007-07-06 20:57:37" 
          uid="{4DA4A7E3-F1D8-4FB1-874F-D2F7D16F7065}">
     <Properties action="U" 
                 thisDrive="NOCHANGE" 
                 allDrives="NOCHANGE" 
                 userName="test" 
                 cpassword="5gn5fUqMaeGJkLEPgl3iH9UfLATVxRAHE8GvAvekwnicLYf2Pynj7ifihvajBRA3" 
                 path="\\scratch" 
                 label="SCRATCH" 
                 persistent="1" 
                 useLetter="1" 
                 letter="S"/>
   </Drive> 
</Drives>

#>

<# Groups.xml

<?xml version="1.0" encoding="utf-8"?>
<Groups clsid="{D4A3F943-1B57-4B98-B5E4-1E9C7A84B292}">
    <User clsid="{A7D5F186-71E5-4A24-8B2A-C3BDE98BA2D2}" 
          name="example.com\IT_Dept" 
          image="2"
          changed="2023-09-23 12:00:00" 
          uid="{B8C7DA29-6F69-4530-B99E-B9B5B88B215B}">
        <Properties action="U" 
                    newName="" 
                    fullName="IT Department" 
                    description="Group for IT department staff"
                    cpassword="5gn5fUqMaeGJkLEPgl3iH9UfLATVxRAHE8GvAvekwnicLYf2Pynj7ifihvajBRA3" 
                    changeLogon="0" 
                    noChange="0" 
                    neverExpires="0" 
                    acctDisabled="0" 
                    userName="example.com\IT_Dept"/>
    </User>
</Groups>


#>

<# DataSources.xml

<?xml version="1.0" encoding="utf-8"?>
 <DataSources clsid="{380F820F-F21B-41ac-A3CC-24D4F80F067B}" disabled="0">
   <DataSource clsid="{5C209626-D820-4d69-8D50-1FACD6214488}" name="LocalContacts" 
     image="1" bypassErrors="0" userContext="1" removePolicy="1" 
     desc="This is a local database on the local machine." 
     changed="2007-07-06 20:33:47" uid="{5AA6C3F8-B6D3-4FE1-8925-FEBE6F15310A}">
     <Properties action="R" userDSN="1" dsn="LocalContacts" 
       driver="Microsoft Access (*.mdb)" description="Local Access Database" 
       username="test" cpassword="5gn5fUqMaeGJkLEPgl3iH9UfLATVxRAHE8GvAvekwnicLYf2Pynj7ifihvajBRA3">
       <Attributes>
         <Attribute name="DSN" value="C:\USERS\DEMO.MDB"/>
       </Attributes>
     </Properties>
   </DataSource>
   <DataSource clsid="{5C209626-D820-4d69-8D50-1FACD6214488}" name="SystemNodes" 
     image="2" bypassErrors="0" userContext="1" removePolicy="0" 
     changed="2007-07-06 20:35:31" uid="{F2174147-A906-4977-AE6F-019C427979D8}">
     <Properties action="U" userDSN="0" dsn="SystemNodes" 
       driver="Microsoft Access (*.mdb)" description="All system nodes." 
       username="test23" cpassword="j1Uyj3Vx8TY9LtLZil2uAuZkFQA/4latT76ZwgdHdhw">
       <Attributes>
         <Attribute name="DSN" value="c:\nodelist.mdb"/>
       </Attributes>
     </Properties>
     <Filters>
       <FilterRunOnce hidden="1" not="0" bool="AND" 
         id="{8F7D51B0-F798-4C5F-972B-36FCD0399A33}"/>
     </Filters>
   </DataSource>
</DataSources>


#>

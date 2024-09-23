# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

# Function to extract credentials from the file
function Get-CredentialsFromConfig {
    param (
        [string]$filePath
    )

    # Check if the file exists
    if (-Not (Test-Path $filePath)) {
        Write-Host "File not found: $filePath"
        return
    }

    # Read the content of the file
    $fileContent = Get-Content -Path $filePath

    # Create an array to hold the results
    $credentials = @()

    # Initialize variables for the current section and credentials
    $currentSection = ""
    $currentUsername = ""
    $currentPassword = ""

    # Loop through each line of the file
    foreach ($line in $fileContent) {
        # Check if the line indicates a new section (e.g., [DB2], [MySQL])
        if ($line -match '^\[.*\]$') {
            # If we have collected both a username and password, store the credentials
            if ($currentUsername -and $currentPassword) {
                $credentials += [PSCustomObject]@{
                    Section  = $currentSection
                    Username = $currentUsername
                    Password = $currentPassword
                }
            }

            # Start a new section
            $currentSection = $line.Trim('[]')
            $currentUsername = ""
            $currentPassword = ""
        }

        # Check if the line contains a User_Name field
        if ($line -match '^User_Name=(.*)$') {
            $currentUsername = $matches[1].Trim()
        }

        # Check if the line contains a Password field
        if ($line -match '^Password=(.*)$') {
            $currentPassword = $matches[1].Trim()
        }
    }

    # If the last section contains credentials, add them to the array
    if ($currentUsername -and $currentPassword) {
        $credentials += [PSCustomObject]@{
            Section  = $currentSection
            Username = $currentUsername
            Password = $currentPassword
        }
    }

    # Return the results
    return $credentials
}

# Example call to the function with a sample file path
$filePath = "c:\temp\configs\dbxdrivers.ini"
$credentials = Get-CredentialsFromConfig -filePath $filePath

# Display the results
$credentials | Format-Table -AutoSize


<# dbxdrivers.ini

[Installed Drivers]
DB2=1
Interbase=1
MySQL=1
Oracle=1
Informix=1
MSSQL=1
UIB Interbase6=1
UIB Interbase65=1
UIB Interbase7=1
UIB Interbase71=1
UIB FireBird102=1
UIB FireBird103=1
UIB FireBird15=1
UIB Yaffil=1

[DB2]
GetDriverFunc=getSQLDriverDB2
LibraryName=dbexpdb2.dll
VendorLib=db2cli.dll
Database=DBNAME
User_Name=user
Password=password
BlobSize=-1
ErrorResourceFile=
LocaleCode=0000
DB2 TransIsolation=ReadCommited

[Interbase]
GetDriverFunc=getSQLDriverINTERBASE
LibraryName=dbexpint.dll
VendorLib=gds32.dll
Database=database.gdb
RoleName=RoleName
User_Name=sysdba
Password=masterkey
ServerCharSet=
SQLDialect=1
BlobSize=-1
CommitRetain=False
WaitOnLocks=True
ErrorResourceFile=
LocaleCode=0000
Interbase TransIsolation=ReadCommited
Trim Char=False

[MySQL]
GetDriverFunc=getSQLDriverMYSQL
LibraryName=dbexpmysql.dll
VendorLib=libmysql.dll
HostName=localhost
Database=DBNAME
User_Name=root
Password=
BlobSize=-1
ErrorResourceFile=
LocaleCode=0000

[Oracle]
GetDriverFunc=getSQLDriverORACLE  
LibraryName=dbexpora.dll
VendorLib=oci.dll
DataBase=Database Name
User_Name=user
Password=password
BlobSize=-1
ErrorResourceFile=
LocaleCode=0000
Oracle TransIsolation=ReadCommited
RowsetSize=20
OS Authentication=False
Multiple Transaction=False
Trim Char=False

[Informix]
GetDriverFunc=getSQLDriverINFORMIX  
LibraryName=dbexpinf.dll
VendorLib=isqlb09a.dll
HostName=ServerName
DataBase=Database Name
User_Name=user
Password=password
BlobSize=-1
ErrorResourceFile=
LocaleCode=0000
Informix TransIsolation=ReadCommited
Trim Char=False

[MSSQL]
GetDriverFunc=getSQLDriverMSSQL  
LibraryName=dbexpmss.dll
VendorLib=oledb
HostName=ServerName
DataBase=Database Name
User_Name=user
Password=password
BlobSize=-1
ErrorResourceFile=
LocaleCode=0000
MSSQL TransIsolation=ReadCommited
OS Authentication=False


[AutoCommit]
False=0
True=1

[BlockingMode]
False=0
True=1

[WaitOnLocks]
False=1
True=0

[CommitRetain]
False=0
True=1

[OS Authentication]
False=0
True=1

[Multiple Transaction]
False=0
True=1

[Trim Char]
False=0
True=1

[DB2 TransIsolation]
DirtyRead=0
ReadCommited=1
RepeatableRead=2

[Interbase TransIsolation]
ReadCommited=1
RepeatableRead=2

[Oracle TransIsolation]
DirtyRead=0
ReadCommited=1
RepeatableRead=2

[Informix TransIsolation]
DirtyRead=0
ReadCommited=1
RepeatableRead=2

[MSSQL TransIsolation]
DirtyRead=0
ReadCommited=1
RepeatableRead=2

[SQLDialect]
1=0
2=1
3=2

[UIB Interbase6]
GetDriverFunc=getSQLDriverINTERBASE
LibraryName=dbexpUIBint6.dll
VendorLib=GDS32.DLL
BlobSize=-1
CommitRetain=False
Database=database.ib
ErrorResourceFile=
LocaleCode=0000
Password=masterkey
RoleName=RoleName
ServerCharSet=
SQLDialect=3
Interbase TransIsolation=ReadCommited
User_Name=SYSDBA
WaitOnLocks=True

[UIB Interbase65]
GetDriverFunc=getSQLDriverINTERBASE
LibraryName=dbexpUIBint65.dll
VendorLib=GDS32.DLL
BlobSize=-1
CommitRetain=False
Database=database.ib
ErrorResourceFile=
LocaleCode=0000
Password=masterkey
RoleName=RoleName
ServerCharSet=
SQLDialect=3
Interbase TransIsolation=ReadCommited
User_Name=SYSDBA
WaitOnLocks=True

[UIB Interbase7]
GetDriverFunc=getSQLDriverINTERBASE
LibraryName=dbexpUIBint7.dll
VendorLib=GDS32.DLL
BlobSize=-1
CommitRetain=False
Database=database.ib
ErrorResourceFile=
LocaleCode=0000
Password=masterkey
RoleName=RoleName
ServerCharSet=
SQLDialect=3
Interbase TransIsolation=ReadCommited
User_Name=SYSDBA
WaitOnLocks=True

[UIB Interbase71]
GetDriverFunc=getSQLDriverINTERBASE
LibraryName=dbexpUIBint71.dll
VendorLib=GDS32.DLL
BlobSize=-1
CommitRetain=False
Database=database.ib
ErrorResourceFile=
LocaleCode=0000
Password=masterkey
RoleName=RoleName
ServerCharSet=
SQLDialect=3
Interbase TransIsolation=ReadCommited
User_Name=SYSDBA
WaitOnLocks=True

[UIB FireBird102]
GetDriverFunc=getSQLDriverINTERBASE
LibraryName=dbexpUIBfire102.dll
VendorLib=GDS32.DLL
BlobSize=-1
CommitRetain=False
Database=database.fb
ErrorResourceFile=
LocaleCode=0000
Password=masterkey
RoleName=RoleName
ServerCharSet=
SQLDialect=3
Interbase TransIsolation=ReadCommited
User_Name=SYSDBA
WaitOnLocks=True

[UIB FireBird103]
GetDriverFunc=getSQLDriverINTERBASE
LibraryName=dbexpUIBfire103.dll
VendorLib=GDS32.DLL
BlobSize=-1
CommitRetain=False
Database=database.fb
ErrorResourceFile=
LocaleCode=0000
Password=masterkey
RoleName=RoleName
ServerCharSet=
SQLDialect=3
Interbase TransIsolation=ReadCommited
User_Name=SYSDBA
WaitOnLocks=True

[UIB FireBird15]
GetDriverFunc=getSQLDriverINTERBASE
LibraryName=dbexpUIBfire15.dll
VendorLib=fbclient.dll
BlobSize=-1
CommitRetain=False
Database=database.fb
ErrorResourceFile=
LocaleCode=0000
Password=masterkey
RoleName=RoleName
ServerCharSet=
SQLDialect=3
Interbase TransIsolation=ReadCommited
User_Name=SYSDBA
WaitOnLocks=True

[UIB Yaffil]
GetDriverFunc=getSQLDriverINTERBASE
LibraryName=dbexpUIByaffil.dll
VendorLib=GDS32.DLL
BlobSize=-1
CommitRetain=False
Database=database.gdb
ErrorResourceFile=
LocaleCode=0000
Password=masterkey
RoleName=RoleName
ServerCharSet=
SQLDialect=3
Interbase TransIsolation=ReadCommited
User_Name=SYSDBA
WaitOnLocks=True


#>
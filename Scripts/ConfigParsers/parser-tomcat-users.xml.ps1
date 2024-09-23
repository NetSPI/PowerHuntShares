# Author: Scott Sutherland, NetSPI (@_nullbind / nullbind)

function Get-TomcatUsers {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TomcatConfigFile
    )

    # Load the XML file
    [xml]$xml = Get-Content -Path $TomcatConfigFile

    # Create an array to store the results
    $usersList = @()

    # Select the user nodes from the XML
    $users = $xml.'tomcat-users'.user

    # Loop through each user and extract the name and password attributes
    foreach ($user in $users) {
        # Create a PowerShell object for each user
        $userObject = [PSCustomObject]@{
            Username = $user.name
            Password = $user.password
        }

        # Add the object to the list
        $usersList += $userObject
    }

    # Display the list of users as a table
    return $usersList
}

# Example usage
$tomcatConfigFilePath = "c:\temp\configs\tomcat-users.xml"
Get-TomcatUsers -TomcatConfigFile $tomcatConfigFilePath | Format-Table -AutoSize


<# tomcat-users.xml

<?xml version='1.0' encoding='utf-8'?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<tomcat-users>
<!--
  NOTE:  By default, no user is included in the "manager-gui" role required
  to operate the "/manager/html" web application.  If you wish to use this app,
  you must define such a user - the username and password are arbitrary.
-->
<!--
  NOTE:  The sample user and role entries below are wrapped in a comment
  and thus are ignored when reading this file. Do not forget to remove
  <!.. ..> that surrounds them.
-->
  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>
  <role rolename="manager-gui"/>
  <role rolename="manager-status"/>
  <role rolename="manager-script"/>
  <role rolename="manager-jmx"/>
  <user name="admin" password="admin" roles="admin-gui,admin-script,manager-gui,manager-status,manager-script,manager-jmx"/>
</tomcat-users>

#>
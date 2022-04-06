# PowerHuntShares
PowerHuntShares is design to automatically inventory, analyze, and report excessive privilege assigned to SMB shares on Active Directory domain joined computers.  
It is intented to help IAM and other blue teams gain a better understand of their SMB Share attack surface and provides data insights to help naturally group related share to help stream line remediation efforts at scale.

It supports functionality to:
* <strong>Authenticate</strong> using the current user context, a credential, or clear text user/password.
* <strong>Discover</strong> accessible systems associated with an Active Directory domain automatically. It will also filter Active Directory computers based on available open ports.
* <strong>Target</strong> a single computer, list of computers, or discovered Active Directory computers (default).
* <strong>Collect</strong> SMB share ACL information from target computers using PowerShell.
* <strong>Analyze</strong> collected Share ACL data.
* <strong>Report</strong> summary reports and excessive privilege details in HTML and CSV file formats.

Excessive SMB share ACLs are a systemic problem and an attack surface that all organizations struggle with.  The goal of this project is to provide a proof concept that will work towards building a better share collection and data insight engine that can help inform and priorititize remediation efforts.

# Example Commands
Important Note: All commands should be run as an unprivileged domain user.
<pre>
.EXAMPLE 1: Run from a domain computer. Performs Active Directory computer discovery by default.
PS C:\temp\test> Invoke-HuntSMBShares -Threads 100 -OutputDirectory c:\temp\test 

.EXAMPLE 2: Run from a domain computer with alternative domain credentials. Performs Active Directory computer discovery by default.
PS C:\temp\test> Invoke-HuntSMBShares -Threads 100 -OutputDirectory c:\temp\test -Credentials domain\user

.EXAMPLE 3: Run from a domain computer as current user. Target hosts in a file. One per line.
PS C:\temp\test> Invoke-HuntSMBShares -Threads 100 -OutputDirectory c:\temp\test  -HostList c:\temp\hosts.txt      

.EXAMPLE 4: Run from a non-domain computer with credential. Performs Active Directory computer discovery by default.
C:\temp\test> runas /netonly /user:domain\user PowerShell.exe
PS C:\temp\test> Import-Module Invoke-HuntSMBShares.ps1
PS C:\temp\test> Invoke-HuntSMBShares -Threads 100 -RunSpaceTimeOut 10 -OutputDirectory c:\folder\ -DomainController 10.1.1.1 -Credential domain\user 

---------------------------------------------------------------
INVOKE-HUNTSMBSHARES 
---------------------------------------------------------------
 This function automates the following tasks:     

 o Determine current computer's domain
 o Enumerate domain computers        
 o Filter for computers that respond to ping reqeusts          
 o Filter for computers that have TCP 445 open and accessible  
 o Enumerate SMB shares 
 o Enumerate SMB share permissions   
 o Identify shares with potentially excessive privielges       
 o Identify shares that provide reads & write access           
 o Identify shares thare are high risk
 o Identify common share owners, names, & directory listings   
 o Generate last written & last accessed timelines
 o Generate html summary report and detailed csv files         

 Note: This can take hours to run in large environments.       
---------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
---------------------------------------------------------------
SHARE DISCOVERY      
---------------------------------------------------------------
[*][03/01/2021 09:35] Scan Start
[*][03/01/2021 09:35] Output Directory: c:\temp\smbshares\SmbShareHunt-03012021093504
[*][03/01/2021 09:35] Successful connection to domain controller: dc1.demo.local
[*][03/01/2021 09:35] Performing LDAP query for computers associated with the demo.local domain
[*][03/01/2021 09:35] - 245 computers found
[*][03/01/2021 09:35] Pinging 245 computers
[*][03/01/2021 09:35] - 55 computers responded to ping requests.
[*][03/01/2021 09:35] Checking if TCP Port 445 is open on 55 computers
[*][03/01/2021 09:36] - 49 computers have TCP port 445 open.
[*][03/01/2021 09:36] Getting a list of SMB shares from 49 computers
[*][03/01/2021 09:36] - 217 SMB shares were found.
[*][03/01/2021 09:36] Getting share permissions from 217 SMB shares
[*][03/01/2021 09:37] - 374 share permissions were enumerated.
[*][03/01/2021 09:37] Getting directory listings from 33 SMB shares
[*][03/01/2021 09:37] - Targeting up to 3 nested directory levels
[*][03/01/2021 09:37] - 563 files and folders were enumerated.
[*][03/01/2021 09:37] Identifying potentially excessive share permissions
[*][03/01/2021 09:37] - 33 potentially excessive privileges were found across 12 systems..
[*][03/01/2021 09:37] Scan Complete
---------------------------------------------------------------
SHARE ANALYSIS      
---------------------------------------------------------------
[*][03/01/2021 09:37] Analysis Start
[*][03/01/2021 09:37] - 14 shares can be read across 12 systems.
[*][03/01/2021 09:37] - 1 shares can be written to across 1 systems.
[*][03/01/2021 09:37] - 46 shares are considered non-default across 32 systems.
[*][03/01/2021 09:37] - 0 shares are considered high risk across 0 systems
[*][03/01/2021 09:37] - Identified top 5 owners of excessive shares.
[*][03/01/2021 09:37] - Identified top 5 share groups.
[*][03/01/2021 09:37] - Identified top 5 share names.
[*][03/01/2021 09:37] - Identified shares created in last 90 days.
[*][03/01/2021 09:37] - Identified shares accessed in last 90 days.
[*][03/01/2021 09:37] - Identified shares modified in last 90 days.
[*][03/01/2021 09:37] Analysis Complete
---------------------------------------------------------------
SHARE REPORT SUMMARY      
---------------------------------------------------------------
[*][03/01/2021 09:37] Domain: demo.local
[*][03/01/2021 09:37] Start time: 03/01/2021 09:35:04
[*][03/01/2021 09:37] End time: 03/01/2021 09:37:27
[*][03/01/2021 09:37] Run time: 00:02:23.2759086
[*][03/01/2021 09:37] 
[*][03/01/2021 09:37] COMPUTER SUMMARY
[*][03/01/2021 09:37] - 245 domain computers found.
[*][03/01/2021 09:37] - 55 (22.45%) domain computers responded to ping.
[*][03/01/2021 09:37] - 49 (20.00%) domain computers had TCP port 445 accessible.
[*][03/01/2021 09:37] - 32 (13.06%) domain computers had shares that were non-default.
[*][03/01/2021 09:37] - 12 (4.90%) domain computers had shares with potentially excessive privileges.
[*][03/01/2021 09:37] - 12 (4.90%) domain computers had shares that allowed READ access.
[*][03/01/2021 09:37] - 1 (0.41%) domain computers had shares that allowed WRITE access.
[*][03/01/2021 09:37] - 0 (0.00%) domain computers had shares that are HIGH RISK.
[*][03/01/2021 09:37] 
[*][03/01/2021 09:37] SHARE SUMMARY
[*][03/01/2021 09:37] - 217 shares were found. We expect a minimum of 98 shares
[*][03/01/2021 09:37]   because 49 systems had open ports and there are typically two default shares.
[*][03/01/2021 09:37] - 46 (21.20%) shares across 32 systems were non-default.
[*][03/01/2021 09:37] - 14 (6.45%) shares across 12 systems are configured with 33 potentially excessive ACLs.
[*][03/01/2021 09:37] - 14 (6.45%) shares across 12 systems allowed READ access.
[*][03/01/2021 09:37] - 1 (0.46%) shares across 1 systems allowed WRITE access.
[*][03/01/2021 09:37] - 0 (0.00%) shares across 0 systems are considered HIGH RISK.
[*][03/01/2021 09:37] 
[*][03/01/2021 09:37] SHARE ACL SUMMARY
[*][03/01/2021 09:37] - 374 ACLs were found.
[*][03/01/2021 09:37] - 374 (100.00%) ACLs were associated with non-default shares.
[*][03/01/2021 09:37] - 33 (8.82%) ACLs were found to be potentially excessive.
[*][03/01/2021 09:37] - 32 (8.56%) ACLs were found that allowed READ access.
[*][03/01/2021 09:37] - 1 (0.27%) ACLs were found that allowed WRITE access.
[*][03/01/2021 09:37] - 0 (0.00%) ACLs were found that are associated with HIGH RISK share names.
[*][03/01/2021 09:37] 
[*][03/01/2021 09:37] - The 5 most common share names are:
[*][03/01/2021 09:37] - 9 of 14 (64.29%) discovered shares are associated with the top 5 share names.
[*][03/01/2021 09:37]   - 4 backup
[*][03/01/2021 09:37]   - 2 ssms
[*][03/01/2021 09:37]   - 1 test2
[*][03/01/2021 09:37]   - 1 test1
[*][03/01/2021 09:37]   - 1 users
[*] -----------------------------------------------

</pre>

# Credits
<strong>Author</strong><Br>
Scott Sutherland (@_nullbind)<Br>
           
<strong>Open-Source Code Used</strong> <Br>
These individuals wrote open source code that was used as part of this project. A big thank you goes out them and their work!<br>
|Name|Site|
|:--------------------------------|:-----------|
|Will Schroeder (@harmj0y)|https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1
|Warren F (@pscookiemonster)|https://github.com/RamblingCookieMonster/Invoke-Parallel

<strong>License</strong><Br>
BSD 3-Clause

Primary Todo
--
**Fixes**
* TBD
  
**Features**
*TBD


  









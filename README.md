# PowerHuntShares v2

PowerHuntShares is PowerShell tool designed to help cybersecurity teams and penetration testers better identify, understand, attack, and remediate SMB shares in the Active Directory environments they protect. Every hacker has a story about abusing SMB shares, but it’s an attack surface that cybersecurity teams still struggle to defend. This project aims to provide an open proof-of-concept tool for creating a comprehensive share inventory, leveraging statistics, charts, graphs, and language models to contextualize shares, summarize relationships, assess risks, and prioritize remediation.

It supports functionality to:
* <strong>Authenticate</strong> using the current user context, a credential, or clear text user/password.
* <strong>Discover</strong> accessible systems associated with an Active Directory domain automatically. It will also filter Active Directory computers based on available open ports.
* <strong>Target</strong> a single computer, list of computers, or discovered Active Directory computers (default).
* <strong>Collect</strong> SMB share ACL information from target computers using PowerShell.
* <strong>Analyze</strong> collected Share ACL data.
* <strong>Report</strong> summary reports and excessive privilege details in HTML and CSV file formats.

Bonus Features:
<br>
* Stand alone LLM functions: https://github.com/NetSPI/PowerHuntShares/blob/main/Scripts/Invoke-FingerPrintShare.ps1
* Stand alone password parsers: https://github.com/NetSPI/PowerHuntShares/tree/main/Scripts/ConfigParsers

PowerHuntShares v2 Resources:
* v2 Blog: https://www.netspi.com/blog/technical-blog/network-pentesting/powerhuntshares-2-0-release/

PowerHuntShares v1 Resources:
* v1 Blog: https://www.netspi.com/blog/technical/network-penetration-testing/network-share-permissions-powerhuntshares/
* v1 Presentation Video : https://www.youtube.com/watch?v=TtwyQchCz6E
* v1 Presentation Slides: https://www.slideshare.net/nullbind/into-the-abyss-evaluating-active-directory-smb-shares-on-scale-secure360-251762721

# Vocabulary
PowerHuntShares will inventory SMB share ACLs configured with "excessive privileges" and highlight "high risk" ACLs.  Below is how those are defined in this context.

<strong>Excessive Privileges</strong><br>
Excessive read and write share permissions have been defined as any network share ACL containing an explicit ACE (Access Control Entry) for the "Everyone", "Authenticated Users", "BUILTIN\Users", "Domain Users", or "Domain Computers" groups. All provide domain users access to the affected shares due to privilege inheritance issues.  Note there is a parameter that allow operators to add their own target groups.<br>
Below is some additional background:<br>
* Everyone is a direct reference that applies to both unauthenticated and authenticated users.  Typically only a null session is required to access those resources.
* BUILTIN\Users contains Authenticated Users
* Authenticated Users contains Domain Users on domain joined systems. That's why Domain Users can access a share when the share permissions have been assigned to "BUILTIN\Users".
* Domain Users is a direct reference
* Domain Users can also create up to 10 computer accounts by default that get placed in the Domain Computers group
* Domain Users that have local administrative access to a domain joined computer can also impersonate the computer account. 

Please Note: Share permissions can be overruled by NTFS permissions. Also, be aware that testing excluded share names containing the following keywords: <pre>print$, prnproc$, printer, netlogon,and sysvol</pre>

<strong>High Risk Shares</strong><br>
In the context of this report, high risk shares have been defined as shares that provide unauthorized remote access to a system or application. 
By default, that includes the shares <pre> wwwroot, inetpub, c$, and admin$   </pre>
However, additional exposures may exist that are not called out beyond that.

# Setup Commands
Below is a list of commands that can be used to load PowerHuntShares into your current PowerShell session. Please note that one of these will have to be run each time you run PowerShell is run.  It is not persistent. 
<pre>
# Bypass execution policy restrictions
Set-ExecutionPolicy -Scope Process Bypass

# Import module that exists in the current directory
Import-Module .\PowerHuntShares.psm1

or

# Reduce SSL operating level to support connection to github
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
[Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12

# Download and load PowerHuntShares.psm1 into memory
IEX(New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/NetSPI/PowerHuntShares/main/PowerHuntShares.psm1")
</pre>

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
PS C:\temp\test> Import-Module PowerHuntShares.psm1
PS C:\temp\test> Invoke-HuntSMBShares -Threads 100 -RunSpaceTimeOut 10 -OutputDirectory c:\folder\ -DomainController 10.1.1.1 -Credential domain\user 

===============================================================
PowerHuntShares
===============================================================
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
 o Generate creation, last written, & last accessed timelines
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

# HTML Report Examples

### Summary Report Page
![HtmlReport1](https://raw.githubusercontent.com/NetSPI/PowerHuntShares/main/Images/v2/1-Dashboard.png)

### Interesting Files Page
![HtmlReport2](https://raw.githubusercontent.com/NetSPI/PowerHuntShares/main/Images/v2/11-InterestingFiles.png)

### Extracted Secrets Page
![HtmlReport3](https://raw.githubusercontent.com/NetSPI/PowerHuntShares/main/Images/v2/10-ExtractedSecrets.png)

### ShareGraph Explorer Page
![HtmlReport4](https://raw.githubusercontent.com/NetSPI/PowerHuntShares/main/Images/v2/9-ShareGraph.png)

# Credits
<strong>Author</strong><Br>
Scott Sutherland (@_nullbind)<Br>
           
<strong>Open-Source Code Used</strong> <Br>
These individuals wrote open source code that was used as part of this project. A big thank you goes out them and their work!<br>
|Name|Site|
|:--------------------------------|:-----------|
|Will Schroeder (@harmj0y)|https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1
|Warren F (@pscookiemonster)|https://github.com/RamblingCookieMonster/Invoke-Parallel
|Luben Kirov|http://www.gi-architects.co.uk/2016/02/powershell-check-if-ip-or-subnet-matchesfits/|

<strong>License</strong><Br>
BSD 3-Clause

Todos
--
**Pending Fixes/Bugs**
* Update code to avoid defender
* Password extraction functions current return a "valid" record when the fields are found in the file, but the have blank values. Also, some directories appear to be treated as files.
* ACLs associated with Builtin\Users sometimes shows up as LocalSystem under undefined conditions, and as a result, doesnt show up in the Excessive Privileges export. - Thanks Sam!
 
**Pending Features**
* Add powerhuntshares version to html report output
* Add options to opt out of interesting file enumeration and secrets parsing.
* Add ability to specify additional groups to target
* Add file content search.
* Add DontExcludePrintShares option
* Add auto targeting of groups that contain a large % of the user population; over 70% (make configurable). Add as option. 
* Add configuration fid:
 netlogon and sysvol you may get access denied when using windows 10 unless the setting below is configured. Automat a check for this, and attempt to modify if privs are at correct level. gpedit.msc, go to Computer -> Administrative Templates -> Network -> Network Provider -> Hardened UNC Paths, enable the policy and click "Show" button. Enter your server name (* for all servers) into "Value name" and enter the folowing text "RequireMutualAuthentication=0,RequireIntegrity=0,RequirePrivacy=0" wihtout quotes into the "Value" field. 
* Add active sessions data to help identify potential owners/users of share.
* Pull spns and computer description/spn account descriptions to help identify owner/business unit.
* Create bloodhound import file / edge (highrisk share)
* Add better support for IPv6, IPv6 addresses dont show up in subnets summary
* Dynamic identification of spikes in high risk share creation/common groupings, need to better summarize supporting detail beyond just the timeline. For each of the data insights, add average number of shares created for insight grouping by year/month (for folder hash / name etc), and the increase the month/year it spikes. (attempt to provide some historical context); maybe even list the most common non default directories being used by each of those. Potentially adding "first seen date" as well. (in alpha)
* Dynamic identification of share creation, modification, and access cadence across a share population that share a name and have a high similarity level.
* add showing share permissions (along with the already displayed NTFS permissions) and resultant access (most restrictive wins)
* add depth, file/directory flag
* So. Many. Other. Things.
</pre>
 


  









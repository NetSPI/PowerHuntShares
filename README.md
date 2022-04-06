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

Excessive SMB share ACLs are a systemic problem that all organizations struggle with and almost none have solved.  The goal of this project is to provide a proof concept that will work towards better inferences that can help the blue team prioritize the remeidation of potentially a hundred thousand or more excessive Share ACLS.

<strong>Author</strong><Br>
Scott Sutherland (@_nullbind) <Br>

<strong>License</strong><Br>
BSD 3-Clause

Primary Todo
--
**Fixes**
* TBD
  
**Features**
*TBD


  









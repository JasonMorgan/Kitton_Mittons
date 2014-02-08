Create and Audit Shares

This Package comes with 3 files, CreateDeptShare.ps1, AuditDeptShare.ps1, and Permissions.psm1.

Both ps1 files require the Permissions module be available by name so ensure you have it loaded in your PSModulePath before using.

We were too lazy to write an install this time so we are depending on you, the user, to do it yourself.

CreateDeptShare.ps1

Input a Group Identity and a domain name, NETBIOS or FQDN.  This script will then list out the subgroups and create a folder structure like:

$path\MainGroup
$path\MainGroup_Open
$path\SubGroup1_Shared
$path\SubGroup1_Private
$path\SubGroup1_Lead
$path\SubGroup2_Shared
$path\SubGroup2_Private
$path\SubGroup2_Lead
etc

It will also apply the Audit group permissions to every folder for every group specified.

The default value for AuditGroup is Audit but this must be set to be whatever group you are using for Audit.

An invalid Audit group value will prevent the script from running.

Crucially this function also produces a hashtable with the permissions information for every folder created.  The Hashtable is stored
in the path specified to the -StorePath Parameter.  If you need to manually create a hashtable for a folder structure simply adhere to 
the following format:

Key = Path
Value = ACLObject


AuditDeptShare.ps1

Audits folders based on the data from a CreateDeptShare.ps1 operation.  The Hashtable structure is used to iterate through and validate
every ACL object, and specifically the access property on the ACL object.  It can generate a report, send variance objects to the pipeline, 
or simply remediate any variances found.

Permissions.psm1

Contains the functions required to run CreateDeptShare.ps1 and AuditDeptShare.ps1.  Must be properly stored in your PSModulePath.

ex:
$env:userprofile\Documents\WindowsPowerShell\Modules\Permissions\Permissions.psm1

Thank you, and good luck!


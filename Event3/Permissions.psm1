Function New-ACE
{
<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.EXAMPLE

.NOTES

#>
Param
    (
        # Specify Identity in Domain\UserName format, this works with group names as well
        [string]$Identity,

        #
        [ValidateSet("Read","Write","Delete","ReadAndExecute","Modify")]
        [string[]]$permission,

        #
        [ValidateSet("ContainerInherit","ObjectInherit","None")]
        [string[]]$inheritance,

        #
        [ValidateSet("InheritOnly","NoPropagateInherit","None")]
        [string]$Propagation,

        #
        [switch]$Deny

    )
if ($Deny)
    {
        $type = [System.Security.AccessControl.AccessControlType]::Deny
    }
else {
        $type = [System.Security.AccessControl.AccessControlType]::Allow
    }

$perm = [System.Security.AccessControl.FileSystemRights]$permission
$inh = [System.Security.AccessControl.InheritanceFlags]$inheritance
$Prop = [System.Security.AccessControl.PropagationFlags]$Propagation
$Principal = New-Object System.Security.Principal.NTAccount($Identity)
New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule  -ArgumentList (
        $Principal,
        $perm,
        $inh,
        $prop,
        $type
    )
}

Function Add-Rule
{
<##>
Param
    (
        #
        $ACL,
        
        #
        $ACE,
        
        # Specifiy rule type
        [alidateSet("Audit","Access")]
        $Type,
        
        #
        [switch]$passthru 
    )
switch ($Type)
    {
        Audit {$ACL.AddAuditRule($ACE)}
        Access {$ACL.AddAccessRule($ACE)}
    }
If ($passthru) {$ACL}
}

Function Audit-Folder
{
<##>

}
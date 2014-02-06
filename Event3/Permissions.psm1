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
        $ACLObject,
        
        #
        $ACE,
        
        # Specifiy rule type
        [ValidateSet("Audit","Access")]
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

Function Test-FolderPermission
{
<#

#>
Param
    (
        # Enter path to target folder
        [validateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Path,

        # Specify a valid ACL object
        [System.Security.AccessControl.DirectorySecurity]$ACLObject,
        
        # Set if you want the function to reaply the orginal permissions
        [Switch]$Remediate
    )

#region Open
try {$Current = Get-Acl -Path $Path}
Catch {Throw "Unable to read ACL for $Path"}
#endregion Open

#region Compare
if (Compare-Object -ReferenceObject $ACLObject -DifferenceObject $Current -Property access)
    {
        if ($Remediate)
            {
                Try {Set-Acl -Path $Path -AclObject $ACLObject} catch {Write-Error "Unable to set permissions on $path"}
            }
        else
            {
                $false    
            }
    }
Else {$true}
#endregion Compare
}
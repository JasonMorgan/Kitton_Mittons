Function New-ACE
{
<#
.SYNOPSIS
Creates ACE object 
 
.DESCRIPTION
Creates an ACE object that can be applied to an ACL
 
.EXAMPLE
New-Ace -Identity "$Domain\Accounting" -permission "Modify" -inheritance "ContainerInherit","ObjectInherit" -Propagation 'None'
 
Creates an ACE object for the group Accounting with the Modify permission and Inheritance enabled

.EXAMPLE
New-Ace -Identity 'contoso\johnDoe' -permission "Read' -inheritance 'None' -Propagation 'none'
 
Creates an ACE object for the AD user JohnDoe with read permissions and inheritance blocked
 
.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 2/5/2014
Last Modified: 2/5/2014

#>
Param
    (
        # Specify Identity in Domain\UserName format, this works with group names as well
        [Parameter(Mandatory)]
        [string]$Identity,

        #
        [Parameter(Mandatory)]
        [ValidateSet("Read","Write","Delete","ReadAndExecute","Modify")]
        [string[]]$permission,

        #
        [Parameter(Mandatory)]
        [ValidateSet("ContainerInherit","ObjectInherit","None")]
        [string[]]$inheritance,

        #
        [Parameter(Mandatory)]
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

Try {$perm = [System.Security.AccessControl.FileSystemRights]$permission} 
catch {
        Write-Warning $_.exception.message
        Throw "Failed to create ACE"
    }
Try {$inh = [System.Security.AccessControl.InheritanceFlags]$inheritance}
catch {
        Write-Warning $_.exception.message
        Throw "Failed to create ACE"
    }
try {$Prop = [System.Security.AccessControl.PropagationFlags]$Propagation}
catch {
        Write-Warning $_.exception.message
        Throw "Failed to create ACE"
    }
try {$Principal = New-Object System.Security.Principal.NTAccount($Identity)}
catch {
        Write-Warning $_.exception.message
        Throw "Failed to create ACE"
    }
Try {New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule  -ArgumentList (
            $Principal,
            $perm,
            $inh,
            $prop,
            $type
        ) -ErrorAction Stop
    }
catch {
        Write-Warning $_.exception.message
        Throw "Failed to create ACE"
    }
}

Function Add-Rule
{
<#
.SYNOPSIS
Adds access rule to ACL
 
.DESCRIPTION
Adds the specified access rule to the Discrtionary Access control List (DACL) or the specifed audit rule to the System Access 
Control List (SACL)
 
.EXAMPLE
$acl = Get-ACL \\server\share
Add-Rule -ACL $acl -ACE $ACE -Access
 
Adds the $ACE object to the ACL for \\server\share
 
 
.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 2/5/2014
Last Modified: 2/5/2014

#>
Param
    (
        # Select an ACL object to be modified
        [Parameter(Mandatory)]
        $ACLObject,
        
        # Enter an ACE object to be added
        [Parameter(Mandatory)]
        [System.Security.AccessControl.FileSystemAccessRule]$ACE,
        
        # Specifiy rule type
        [Parameter(Mandatory)]
        [ValidateSet("Audit","Access")]
        $Type,
        
        # Set if you wish this function to output the modified ACL object
        [switch]$passthru 
    )
switch ($Type)
    {
        Audit {$ACLObject.AddAuditRule($ACE)}
        Access {$ACLObject.AddAccessRule($ACE)}
    }
If ($passthru) {$ACLObject}
}

Function Test-FolderPermission
{
<#
.SYNOPSIS
Test permissions on a given folder

.DESCRIPTION
References a given ACL object and tests the permissions on a given folder to ensure the Permissions are correct.

Able to remediate any varinces that are detected during a test.

.EXAMPLE
(Import-clixml .\FolderPermissions.xml).getenumerator() | foreach {$_ | test-FolderPermission -remediate $true}

Tests all folder permissions in the folderPermissions.xml file and remediates any variances if required.
This will produce a Boolean true for every folder audited.

.EXAMPLE
Test-Permission -path c:\folder -aclobject $badACL

This will test the folder C:\Folder and return a boolean value indicating if the ACL, $BadACL, matches the ACL on the folder.

Our Example would return false as $BadACL is not the correct ACL for that folder.

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.2
Created on: 2/5/2014
Last Modified: 2/7/2014

#>
Param
    (
        # Enter path to target folder
        [Parameter(Mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName)]
        [validateScript({Test-Path -Path $_ -PathType Container})]
        [Alias("Key")]
        [string]$Path,

        # Specify a valid ACL object
        [Parameter(Mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName)]
        [Alias("Value")]
        [System.Security.AccessControl.DirectorySecurity]$ACLObject,
        
        # Set if you want the function to reaply the orginal permissions
        [bool]$Remediate
    )
Process
  {
  #region Open
  try {$Current = Get-Acl -Path $Path}
  Catch {Throw "Unable to read ACL for $Path"}
  #endregion Open

  #region Compare
  if (Compare-Object -ReferenceObject $ACLObject -DifferenceObject $Current -Property access)
    {
        if ($Remediate)
            {
                Try {Set-Acl -Path $Path -AclObject $ACLObject} 
                catch {
                        Write-Error $_.exception.message
                        throw "Unable to set permissions on $path"
                    }
                $true
            }
        else
            {
                $false    
            }
    }
  Else {$true}
  #endregion Compare
  }
}
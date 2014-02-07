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
Get-ACL \\server\share | Add-Rule -ACL $_ -ACE $ACE -Access
 
Adds the $ACE object to the SACL for \\server\share
 
 
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

.DESCRIPTION

.EXAMPLE

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 2/5/2014
Last Modified: 2/5/2014

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
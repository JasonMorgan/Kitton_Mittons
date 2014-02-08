<#
.SYNOPSIS
This script accepts a department name and folder path, and will create a department shared folder structure at a given location. 

.DESCRIPTION
This script requires a domain name, identity of a department group, a root path for the share, and a store path for the permissions history,
Permissions are stored as a hash table object in an xml file with the folder paths stored as the key and the ACLs stored as the value, and 
the ACEs stored in the .  This file is saved in the specified store path. 

.EXAMPLE
C:\powershell\scripts\CreateDeptShare.ps1 

Creates the default folder structure with the CONTOSO domain, Temp_Finance Department, \\Server\Share root folder, and the permissions
history will be stored in the \\server\share folder. 

.EXAMPLE
C:\powershell\scripts\CreateDeptShare.ps1 -Identity Marketing -Path \\FileServer1\Contoso -StorePath \\FileServer1\PermissionLogs -Domain MakeStuff -AuditGroup MakeStuff_Audit

Creates the Marketing department folder structure in the Makestuff share on the FileServer1 server with the logs in a PermissionLogs folder on the same server.
The Audit group in this case is named MakeStuff_Audit. 

.EXAMPLE
get-content .\Groups.txt | Foreach { C:\powershell\scripts\CreateDeptShare.ps1 -path \\server\Share\ -identity $_ -domain Contoso.com -storepath c:\perms }

Creates a Debt folder structure for each dept listed in the Groups.txt file

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 2/6/2014
Last Modified: 2/7/2014

#requires -version 3.0 
#requires -Modules @{Name='ActiveDirectory';ModuleVersion=1.0.0.0}

#>

[cmdletbinding()]
Param (
        # Enter the Group name for the target Dept
        [ValidateScript({ if (-not(Get-ADGroup -Identity $_)) {Throw "$_ is not a valid group name"} })]
        [string]$Identity = 'Temp_finance',
        
        # Enter the path to the target shared folder
        [ValidateScript({ Test-Path -Path $_ -PathType container })]
        [string]$Path = "\\Server\Share",
        
        # Enter the path to where you want the Permissions data stored
        [ValidateScript({ Test-Path -Path $_ -PathType container })]
        [string]$StorePath = "\\Server\Share",
        
        # Enter the Domain name
        [string]$Domain = "CONTOSO",
        
        # Enter the name of the Auditor group
        [ValidateScript({ if (-not(Get-ADGroup -Identity $_)) {Throw "$_ is not a valid group name"} })]
        [string]$AuditGroup = "Audit"
    )

Import-Module Permissions

#region ScriptBlocks
Write-Verbose "Building Scriptblocks"
$IsAudit = {
    if (-not($audit))
        {
            $param.Identity = "$Domain\$AuditGroup"
            $param.permission = "ReadAndExecute"
            $param.inheritance = "ContainerInherit","ObjectInherit"
            $ACE = New-ACE @param
            Try {Add-Rule -ACL $ACL -ACE $ACE -Type Access}
            Catch {Throw "Unable to add Audit to ACL"}
        }
  }
#endregion ScriptBlocks

#region Variables
Write-Verbose "Defining Variables"
$ACEStore = @{}
$dept = Get-ADGroup -Identity $Identity -Properties Members
Write-Debug "Dept: $($dept.Name)"
$Teams = $dept.Members
Write-Debug "Teams: $Teams"
$Teampaths = $Teams | foreach {
        "$path\$($_.split(',')[0].trimstart('CN='))_Shared"  
        "$path\$($_.split(',')[0].trimstart('CN='))_Private"
        "$path\$($_.split(',')[0].trimstart('CN='))_Lead"
    }
$deptpaths = "$path\$($dept.Name)","$path\$($dept.Name)_Open"
$paths =  $deptFolders + $Teampaths
Write-Debug "Paths: $paths"
#endregion Variables

#region CreateFolders
foreach ($p in $paths)
{
  Switch ($p)
    {
      {$_ -in $deptpaths} 
        {
          #region Dept
          Switch ($_) 
            {
              {$_.EndsWith('Open')} 
                {
                  Write-Verbose "Creating Dept Open @ $_"
                  New-Item -ItemType directory -Path $_ | Out-Null
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$($dept.Name)"
                      permission = "Modify"
                      inheritance = "ContainerInherit","ObjectInherit"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  Try {Add-Rule -ACLObject $ACL -ACE $ACE -Type Access}
                  Catch {Throw "Unable to add Audit to ACL"}
                  $param.Identity = "$Domain\Domain Users"
                  $param.permission = "ReadAndExecute"
                  $ACE = New-ACE @param
                  Try {Add-Rule -ACLObject $ACL -ACE $ACE -Type Access}
                  Catch {Throw "Unable to add Audit to ACL"}
                  & $IsAudit
                  $ACEStore.Add($_,$ACL)
                  Write-Debug "Folder to Modify $_"
                  Try {Set-Acl -Path $_ -AclObject $ACL}
                  Catch {Throw "Unable to add set ACL on folder"}
                  break
                }
              default 
                {
                  Write-Verbose "Creating Dept folder @ $_"
                  New-Item -ItemType directory -Force -Path $_ | Out-Null
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$($dept.Name)"
                      permission = "ReadAndExecute"
                      inheritance = "ContainerInherit","ObjectInherit"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  Try {Add-Rule -ACLObject $ACL -ACE $ACE -Type Access}
                  Catch {Throw "Unable to add Audit to ACL"}
                  & $IsAudit
                  $ACEStore.Add($_,$ACL)
                  Write-Debug "Folder to Modify $_"
                  Try {Set-Acl -Path $_ -AclObject $ACL}
                  Catch {Throw "Unable to add ACL to folder"}
                }
            }
          break
          #endregion Dept
        }
      {$_ -in $Teampaths} 
        {
          #region Team
          Switch ($_) 
            { 
              {$_.EndsWith('Lead')} 
                {
                  Write-Verbose "Create $($_.Split('\')[-1].split('_')[0] ) Lead Folder @ $_"
                  New-Item -ItemType directory -Path $_ | Out-Null
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$(($_.Split('\')[-1].split('_')[0] ) + "_Lead")"
                      permission = "Modify"
                      inheritance = "ContainerInherit","ObjectInherit"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  try {Add-Rule -ACLObject $ACL -ACE $ACE -Type Access}
                  Catch {Throw "Unable to add ACE to ACL"}
                  & $IsAudit
                  $ACEStore.Add($_,$ACL)
                  Write-Debug "Folder to Modify $_"
                  Try {Set-Acl -Path $_ -AclObject $ACL}
                  Catch {Throw "Unable to add ACL to folder"}
                  break
                } 
              {$_.EndsWith('Shared')} 
                {
                  Write-Verbose "Create $($_.Split('\')[-1].split('_')[0] ) Shared Folder @ $_"
                  New-Item -ItemType directory -Path $_ | Out-Null
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$($_.Split('\')[-1].split('_')[0] )"
                      permission = "Modify"
                      inheritance = "ContainerInherit","ObjectInherit"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  try {Add-Rule -ACLObject $ACL -ACE $ACE -Type Access}
                  Catch {Throw "Unable to add ACE to ACL"}
                  $param.Identity = "$Domain\$($dept.Name)"
                  $param.permission = "ReadAndExecute"
                  $ACE = New-ACE @param
                  Try {Add-Rule -ACLObject $ACL -ACE $ACE -Type Access}
                  Catch {Throw "Unable to add ACE to ACL"}
                  & $IsAudit
                  $ACEStore.Add($_,$ACL)
                  Write-Debug "Folder to Modify $_"
                  Try {Set-Acl -Path $_ -AclObject $ACL}
                  Catch {Throw "Unable to add set ACL on folder"}
                  break
                } 
              {$_.EndsWith('Private')} 
                {
                  Write-Verbose "Create $($_.Split('\')[-1].split('_')[0] ) Private Folder @ $_"
                  New-Item -ItemType directory -Path $_ | Out-Null
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$($_.Split('\')[-1].split('_')[0] )"
                      permission = "Modify"
                      inheritance = "ContainerInherit","ObjectInherit"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  Try {Add-Rule -ACLObject $ACL -ACE $ACE -Type Access}
                  Catch {Throw "Unable to add ACE to ACL"}
                  & $IsAudit
                  $ACEStore.Add($_,$ACL)
                  Write-Debug "Folder to Modify $_"
                  Try {Set-Acl -Path $_ -AclObject $ACL}
                  Catch {Throw "Unable to add set ACL on folder"}
                }
            } 
          #endregion Team
        }
    }
}
#endregion CreateFolders

#region ExportHistory
Try {$ACEStore | Export-Clixml -Path "$StorePath\$($dept.Name)_$(get-date -Format yyyyMMdd_HHmmss).xml"}
Catch {Write-Warning "Failed to export historical data.  You must manually audit ACLs at this time"}
Write-Debug "Storepath: $StorePath\$($dept.Name)_$(get-date -Format yyyyMMdd_HHmmss).xml"
#endregion ExportHistory
<#
Create folders
Set permissions
Store permissions as set
    Store with datetime in filename
Audit permissions with an HTML report
    Able to restore permissions on modded folders


1 access dept group
2 List teams in group
3 Make folder structure
4 set permissions on folder structure
5 store permission objects
6 Audit Folder permissions
7 Reset folder with drift

#>


Param (
        $ADGroupName = 'Temp_finance'
    )

$dept = Get-ADGroup -Identity $ADGroupName -Properties Members
new-item -ItemType directory -Path $dept.Name | set-location
New-item -ItemType directory -Path "$($dept.Name)_Open"
Foreach ($g in ($dept.Members | foreach {$_.split(',')[0].trimstart('CN=')}))
    {
        New-Item -ItemType directory -Path $g 
    }

#region DefineRoot
$perm = [System.Security.AccessControl.FileSystemRights]"Read, Write, Traverse"
$inh = [System.Security.AccessControl.InheritanceFlags]::None
$prop = [System.Security.AccessControl.PropagationFlags]::InheritOnly
$allow = [System.Security.AccessControl.AccessControlType]::Allow 
$grp = New-Object System.Security.Principal.NTAccount('F9VS\Temp_Finance')
$ace = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule  -ArgumentList ($grp,$perm,$inh,$prop,$allow)
$fol = Get-Acl
$fol.AddAccessRule($ace)
$perm = [System.Security.AccessControl.FileSystemRights]"Read, Traverse"
$prop = [System.Security.AccessControl.PropagationFlags]::None
$grp = New-Object System.Security.Principal.NTAccount('F9VS\Temp_All')


set-acl -Path (Get-Location) -AclObject $fol
#endregion DefineRoot

#region DefineOpen
$perm = [System.Security.AccessControl.FileSystemRights]"Read, Write"
$inh = [System.Security.AccessControl.InheritanceFlags]::None
$prop = [System.Security.AccessControl.PropagationFlags]::InheritOnly
$allow = [System.Security.AccessControl.AccessControlType]::Allow 
$grp = New-Object System.Security.Principal.NTAccount('F9VS\Temp_Finance')
$ace = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule  -ArgumentList ($grp,$perm,$inh,$prop,$allow)
#endregion DefineOpen

#region DefineTeamFolder

#endregion DefineTeamFolder
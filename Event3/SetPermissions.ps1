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
8 HTML report

#>

[cmdletbinding()]
Param (
        $Identity = 'Temp_finance',
        $Path = "\\Server\Share",
        $StorePath = "\\Server\Share"

    )

$dept = Get-ADGroup -Identity $Identity -Properties Members
new-item -ItemType directory -Path $path\$dept.Name | set-location
Write-Debug "Current path: $(get-location)"

#region CommonVariables
$ACEStore = @{}

$permSet = @{
        permissions = [System.Security.AccessControl.FileSystemRights]"Read, Write, Traverse"
        inheritance = [System.Security.AccessControl.InheritanceFlags]::None
        propagation = [System.Security.AccessControl.PropagationFlags]::InheritOnly
        allow = [System.Security.AccessControl.AccessControlType]::Allow 
        group = New-Object System.Security.Principal.NTAccount('F9VS\Temp_Finance')
    }

#endregion CommonVariables

#region ScriptBlocks

$sb = {
        New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule  -ArgumentList (
            $permSet.group,
            $permSet.permissions,
            $permSet.inheritance,
            $permSet.propagation,
            $permSet.allow
        )
    }
$sba = {
        ## repeat A
        Write-Verbose "Create Access Control Entry"
        $ace = $sb.Invoke()
        Write-Verbose "Add ACE to ACL"
        $fol.AddAccessRule($ace)
        Write-Debug "`$ACE : $($ace.IdentityReference)"
        ##
    }

$addAudit = {
        Write-Verbose "Setting Audit permissions"
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\Temp_Audit")
        $permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Traverse"
        $sba.Invoke()
    }

#endregion ScriptBlocks

#region DefineRoot

##Repeat C
$fol = Get-Acl
##

$sba.Invoke()

Write-Verbose "Modify permissions for $(Get-Location)"
$permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Traverse"
$permSet.propagation = [System.Security.AccessControl.PropagationFlags]::None
$permSet.group = New-Object System.Security.Principal.NTAccount('F9VS\Temp_All')

$sba.Invoke()

##Repeat B
$ACEStore.Add((Get-Location).path,$fol)
set-acl -Path (Get-Location) -AclObject $fol
##

#endregion DefineRoot

#region DefineOpen

New-item -ItemType directory -Path "$($dept.Name)_Open" | Set-Location
Write-Debug "Current path: $(get-location)"
Write-Verbose "Modify permissions for $(Get-Location)"
$permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Write, traverse, delete"
$permSet.propagation = [System.Security.AccessControl.PropagationFlags]::InheritOnly
$permSet.group = New-Object System.Security.Principal.NTAccount('F9VS\Temp_Finance')

##Repeat C
$fol = Get-Acl

$sba.Invoke()

Write-Verbose "Modify permissions for $(Get-Location)"
$permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Traverse"
$permSet.propagation = [System.Security.AccessControl.PropagationFlags]::None
$permSet.group = New-Object System.Security.Principal.NTAccount('F9VS\Temp_All')

$sba.Invoke()

## Repeat B
$ACEStore.Add((Get-Location).path,$fol)
set-acl -Path (Get-Location) -AclObject $fol
##

#endregion DefineOpen



Foreach ($g in ($dept.Members | foreach {$_.split(',')[0].trimstart('CN=')}))
    {
        Write-Verbose "Test for Audit"
        $audit = ($g -like "Audit*")
        Write-Verbose "Set path to dept root"
        Set-Location -Path (Split-Path -Path (Get-Location))
        Write-Debug "Current path: $(get-location)"
        Write-Verbose "Create team root"
        New-Item -ItemType directory -Path $g | Set-Location
        Write-Debug "Current path: $(get-location)"



        #region TeamRootPermissions
        $fol = Get-Acl

        $permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Write, traverse, delete"
        $permSet.propagation = [System.Security.AccessControl.PropagationFlags]::InheritOnly
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$g")
        
        $sba.Invoke()

        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$($dept.name)")
        $permSet.permissions= [System.Security.AccessControl.FileSystemRights]"Read, Traverse"

        $sba.Invoke()

        
        If (-not($audit)) {$addAudit.Invoke()}
        ## Repeat B
        $ACEStore.Add((Get-Location).path,$fol)
        set-acl -Path (Get-Location) -AclObject $fol
        ##
        #endregion TeamRootPermissions

        New-Item -ItemType Directory -Path Shared

        #region TeamSharePermissions
        $fol = Get-Acl -Path .\Shared ### If we push and reset the path at every folder we could reduce all unique occurences of this command

        $permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Write, traverse, delete"
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$g")

        $sba.Invoke()
        
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$($dept.name)")
        $permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Traverse"
        
        $sba.Invoke()
        
        If (-not($audit)) {$addAudit.Invoke()}

        ## Repeat B
        $ACEStore.Add((Get-Location).path,$fol)
        set-acl -Path (Get-Location) -AclObject $fol
        ##
        #endregion TeamSharePermissions

        New-Item -ItemType Directory -Path Private
        #region PrivatePermissions
        $perm = [System.Security.AccessControl.FileSystemRights]"Read, Write, traverse, delete"
        $inh = [System.Security.AccessControl.InheritanceFlags]::None
        $prop = [System.Security.AccessControl.PropagationFlags]::InheritOnly
        $allow = [System.Security.AccessControl.AccessControlType]::Allow 
        $grp = New-Object System.Security.Principal.NTAccount("F9VS\$g")
        $ace = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule  -ArgumentList ($grp,$perm,$inh,$prop,$allow)
        $fol = Get-Acl -Path .\Private
        $fol.AddAccessRule($ace)
        If (-not($audit)) {$addAudit.Invoke()}
        ## Repeat B
        $ACEStore.Add((Get-Location).path,$fol)
        set-acl -Path (Get-Location) -AclObject $fol
        ##
        #endregion PrivatePermissions

        New-Item -ItemType Directory -Path Lead

        #region Permissions
        $perm = [System.Security.AccessControl.FileSystemRights]"Read, Write, traverse, delete"
        $inh = [System.Security.AccessControl.InheritanceFlags]::None
        $prop = [System.Security.AccessControl.PropagationFlags]::InheritOnly
        $allow = [System.Security.AccessControl.AccessControlType]::Allow 
        $grp = New-Object System.Security.Principal.NTAccount("F9VS\$g" + "_Lead")
        $ace = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule  -ArgumentList ($grp,$perm,$inh,$prop,$allow)
        $fol = Get-Acl -Path .\Lead
        $fol.AddAccessRule($ace)
        If (-not($audit)) {$addAudit.Invoke()}
        ## Repeat B
        $ACEStore.Add((Get-Location).path,$fol)
        set-acl -Path (Get-Location) -AclObject $fol
        ##
        #endregion Permissions
    }



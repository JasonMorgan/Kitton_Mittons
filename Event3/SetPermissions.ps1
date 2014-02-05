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
        $fol = Get-Acl
        Write-Debug "Current path: $(get-location)"

        #region TeamRootPermissions
        Write-Verbose "Modify permissions for $(Get-Location)"
        $permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Write, traverse, delete"
        $permSet.propagation = [System.Security.AccessControl.PropagationFlags]::InheritOnly
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$g")
        
        $sba.Invoke()
        Write-Verbose "Modify permissions for $(Get-Location)"
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$($dept.name)")
        $permSet.permissions= [System.Security.AccessControl.FileSystemRights]"Read, Traverse"

        $sba.Invoke()

        
        If ($audit) {$addAudit.Invoke()}
        ## Repeat B
        $ACEStore.Add((Get-Location).path,$fol)
        set-acl -Path (Get-Location) -AclObject $fol
        ##
        #endregion TeamRootPermissions

        New-Item -ItemType Directory -Path Shared | Set-Location
        $fol = Get-Acl
        Write-Debug "Current path: $(get-location)"
        #region TeamSharePermissions
        
        Write-Verbose "Modify permissions for $(Get-Location)"
        $permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Write, traverse, delete"
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$g")

        $sba.Invoke()
        Write-Verbose "Modify permissions for $(Get-Location)"
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$($dept.name)")
        $permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Traverse"
        
        $sba.Invoke()
        
        If ($audit) {$addAudit.Invoke()}

        ## Repeat B
        $ACEStore.Add((Get-Location).path,$fol)
        set-acl -Path (Get-Location) -AclObject $fol
        ##
        #endregion TeamSharePermissions

        Write-Verbose "Set path to team root"
        Set-Location -Path (Split-Path -Path (Get-Location))
        

        New-Item -ItemType Directory -Path Private | Set-Location
        $fol = Get-Acl
        Write-Debug "Current path: $(get-location)"

        #region PrivatePermissions
        
        Write-Verbose "Modify permissions for $(Get-Location)"
        $permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Write, traverse, delete"
        $permSet.propagation = [System.Security.AccessControl.PropagationFlags]::InheritOnly
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$g")

        $sba.Invoke()
        If ($audit) {$addAudit.Invoke()}
        ## Repeat B
        $ACEStore.Add((Get-Location).path,$fol)
        set-acl -Path (Get-Location) -AclObject $fol
        ##
        #endregion PrivatePermissions

        Write-Verbose "Set path to team root"
        Set-Location -Path (Split-Path -Path (Get-Location))

        New-Item -ItemType Directory -Path Lead | Set-Location
        $fol = Get-Acl
        Write-Debug "Current path: $(get-location)"

        #region Permissions
        Write-Verbose "Modify permissions for $(Get-Location)"
        $permSet.permissions = [System.Security.AccessControl.FileSystemRights]"Read, Write, traverse, delete"
        $permSet.propagation = [System.Security.AccessControl.PropagationFlags]::InheritOnly
        $permSet.group = New-Object System.Security.Principal.NTAccount("F9VS\$g" + "_Lead")

        $sba.Invoke()
        If ($audit) {$addAudit.Invoke()}

        ## Repeat B
        $ACEStore.Add((Get-Location).path,$fol)
        set-acl -Path (Get-Location) -AclObject $fol
        ##
        #endregion Permissions
    }



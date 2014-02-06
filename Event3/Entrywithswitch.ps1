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
        $StorePath = "\\Server\Share",
        $Domain = "F9VS",
        $AuditGroup = "Team_Audit"
    )
$ACEStore = @{}
$dept = Get-ADGroup -Identity $Identity -Properties Members
$Teams = $dept.Members
$Teampaths = $Teams | foreach {"$path\$($dept.Name)\$($_.split(',')[0].trimstart('CN='))"  
        "$path\$($dept.Name)\$($_.split(',')[0].trimstart('CN='))\Shared"  
        "$path\$($dept.Name)\$($_.split(',')[0].trimstart('CN='))\Private"
        "$path\$($dept.Name)\$($_.split(',')[0].trimstart('CN='))\Lead"
    }
$deptpaths = "$path\$($dept.Name)","$path\$($dept.Name)_Open"
$paths = $Teampaths + $deptFolders
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
                  New-Item -ItemType file -Path $_ | Out-Null
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$($dept.Name)"
                      permission = "Modify"
                      inheritance = "ContainerInherit","ObjectInherit"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  Add-Rule -ACL $ACL -ACE $ACE
                  $param.Identity = "$Domain\Domain Users"
                  $param.permission = "ReadAndExecute"
                  $ACE = New-ACE @param
                  Add-Rule -ACL $ACL -ACE $ACE
                  $ACEStore.Add($_.path,$ACL)
                  Set-Acl -Path $_ -AclObject $ACL
                  break
                }
              default 
                {
                  New-Item -ItemType file -Force -Path $_ | Out-Null
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$($dept.Name)"
                      permission = "ReadAndExecute"
                      inheritance = "None"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  Add-Rule -ACL $ACL -ACE $ACE
                  $param.Identity = "$Domain\Domain Users"
                  $ACE = New-ACE @param
                  Add-Rule -ACL $ACL -ACE $ACE
                  $ACEStore.Add($_.path,$ACL)
                  Set-Acl -Path $_ -AclObject $ACL
                }
            }
          break
          #endregion Dept
        }
      {$_ -in $Teampaths} 
        {
          #region Team
          Write-Verbose "Test for Audit"
          $audit = ($g -like "Audit*")
          Write-Verbose "Creating Folders"
          Switch ($_) 
            { 
              {$_.EndsWith('Lead')} 
                {
                  Write-Verbose "Create Lead Folder"
                  New-Item -ItemType directory -Path $_
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$($_.Split('\')[-2] + "_Lead")"
                      permission = "Modify"
                      inheritance = "ContainerInherit","ObjectInherit"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  Add-Rule -ACL $ACL -ACE $ACE
                  if (-not($audit))
                    {
                        $param.Identity = "$Domain\$AuditGroup"
                        $param.permission = "ReadAndExecute"
                        $ACE = New-ACE @param
                        Add-Rule -ACL $ACL -ACE $ACE    
                    }
                  $ACEStore.Add($_.path,$ACL)
                  Set-Acl -Path $_ -AclObject $ACL
                  break
                } 
              {$_.EndsWith('Shared')} 
                {
                  Write-Verbose "Create Shared Folder"
                  New-Item -ItemType directory -Path $_
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$($_.Split('\')[-2])"
                      permission = "Modify"
                      inheritance = "ContainerInherit","ObjectInherit"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  Add-Rule -ACL $ACL -ACE $ACE
                  $param.Identity = "$Domain\$($dept.Name)"
                  $ACE = New-ACE @param
                  Add-Rule -ACL $ACL -ACE $ACE
                  if (-not($audit))
                    {
                        $param.Identity = "$Domain\$AuditGroup"
                        $param.permission = "ReadAndExecute"
                        $ACE = New-ACE @param
                        Add-Rule -ACL $ACL -ACE $ACE    
                    }
                  $ACEStore.Add($_.path,$ACL)
                  Set-Acl -Path $_ -AclObject $ACL
                  break
                } 
              {$_.EndsWith('Private')} {"Private: $_" ; break} 
              default 
                {
                  Write-Verbose "Create team root"
                  New-Item -ItemType directory -Path $_
                  $ACL = Get-Acl -Path $_
                  $param = @{
                      Identity = "$Domain\$($_.Split('\')[-2])"
                      permission = "Modify"
                      inheritance = "None"
                      Propagation = "None"
                    }
                  $ACE = New-ACE @param
                  Add-Rule -ACL $ACL -ACE $ACE
                  $param.Identity = "$Domain\$($dept.Name)"
                  $ACE = New-ACE @param
                  Add-Rule -ACL $ACL -ACE $ACE
                  if (-not($audit))
                    {
                        $param.Identity = "$Domain\$AuditGroup"
                        $param.permission = "ReadAndExecute"
                        $ACE = New-ACE @param
                        Add-Rule -ACL $ACL -ACE $ACE    
                    }
                  $ACEStore.Add($_.path,$ACL)
                  Set-Acl -Path $_ -AclObject $ACL

                } 
            } 
          #endregion Team
        }
    }
}
#region ScriptBlocks
    
$sba = {
        ## repeat A
        Write-Verbose "Create Access Control Entry"
        $ace = New-ACE -Identity $permSet.group -permission $permSet.permissions -inheritance $permSet.inheritance -Propagation $permSet.propagation 
        Write-Verbose "Add ACE to ACL"
        $fol.AddAccessRule($ace)
        Write-Debug "`$ACE : $($ace.IdentityReference)"
        ##
    }

$addAudit = {
        Write-Verbose "Setting Audit permissions"
        $permSet.group = "F9VS\Temp_Audit"
        $permSet.permissions = "ReadandExecute" 
        $permSet.inheritance = "ContainerInherit","ObjectInherit"
        $ace = New-ACE -Identity $permSet.group -permission $permSet.permissions -inheritance $permSet.inheritance -Propagation $permSet.propagation
        $fol.AddAccessRule($ace) 
    }

#endregion ScriptBlocks
Foreach ($g in ($dept.Members | foreach {$_.split(',')[0].trimstart('CN=')}))
    {
        
         $g | Set-Location
        $fol = Get-Acl
        Write-Debug "Current path: $(get-location)"

        #region TeamRootPermissions
        Write-Verbose "Modify permissions for $(Get-Location)"
        $permSet.permissions = "Modify"
        $permSet.propagation = "None"
        $permSet.inheritance = "None"
        $permSet.group = "F9VS\$g"
        
        $sba.Invoke()
        Write-Verbose "Modify permissions for $(Get-Location)"
        $permSet.group = "F9VS\$($dept.name)"
        $permSet.permissions= "ReadAndExecute"

        $sba.Invoke()
        
        If (-not ($audit)) {$addAudit.Invoke()}
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
        $permSet.permissions = "Modify"
        $permSet.group = "F9VS\$g"
        $permSet.inheritance = "ContainerInherit","ObjectInherit"

        $sba.Invoke()
        Write-Verbose "Modify permissions for $(Get-Location)"
        $permSet.group = "F9VS\$($dept.name)"
        $permSet.permissions = "ReadAndExecute"
        $permSet.inheritance = "ContainerInherit","ObjectInherit"
        
        $sba.Invoke()
        
       # If (-not ($audit)) {$addAudit.Invoke()}

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
        $permSet.permissions = "Modify"
        $permSet.inheritance = "ContainerInherit","ObjectInherit"
        $permSet.group = "F9VS\$g"

        $sba.Invoke()
       # If (-not ($audit)) {$addAudit.Invoke()}
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
        $permSet.permissions = "Modify"
        $permSet.inheritance = "ContainerInherit","ObjectInherit"
        $permSet.group = "F9VS\$g" + "_Lead"

        $sba.Invoke()
       # If (-not ($audit)) {$addAudit.Invoke()}

        ## Repeat B
        $ACEStore.Add((Get-Location).path,$fol)
        set-acl -Path (Get-Location) -AclObject $fol
        ##
        #endregion Permissions

        Write-Verbose "Set path to team root"
        Set-Location -Path (Split-Path -Path (Get-Location))
    }
$ACEStore | Export-Clixml -Path $StorePath


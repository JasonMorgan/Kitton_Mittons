<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.NOTES
#>
[CmdletBinding(ConfirmImpact='High')]
Param
    (
        #
        [String]$Path = "$env:ProgramFiles\Security Audit",
        
        #
        [string]$ModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\SecAudit"
    )
#region Initialize
Write-Verbose "Admin check"
if (-not(Test-IsAdministrator))
    {
        Throw "Operation Aborted: You are not authorized to run this command"
    }
Write-Verbose "Determining root directory"
try {$root = Split-Path $($MyInvocation.MyCommand.path)}
catch {Throw "Unable to establish Root Directory"}
Write-Debug "`$root = $root"
#endregion Initialize

#region PrepInstall
if (-not(Test-path $Path))
    {
        Write-Verbose "Creating Application directory"
        New-Item -ItemType directory -Path $Path -Force | Out-Null
    }
else
    {
        Write-Verbose "Removing old install"
        Get-ChildItem $Path | Remove-Item -Recurse
    }
if (-not(Test-path $ModulePath))
    {
        Write-Verbose "Creating Module directory"
        New-Item -ItemType directory -Path $ModulePath -Force | Out-Null
    }
else
    {
        Write-Verbose "Removing Legacy Modules"
        Get-ChildItem $Path | Remove-Item -Recurse
    }
New-Item -ItemType Directory -Path $Path\Extensions | Out-Null
New-Item -ItemType file -Path $Path\Config.xml -Force | Out-Null
#endregion PrepInstall

#region CopyFiles
Copy-Item -Path $root\SecAudit.psm1 -Destination $ModulePath -Force
Copy-Item -Path $root\SecAudit.ps1 -Destination $Path -Force
Copy-Item -Path $root\Key.xml -Destination $Path -Force
Copy-Item -Path $root\Extensions\* -Destination $Path\Extensions
#endregion CopyFiles

#region RegisterScripts
Write-Verbose "Importing SecAudit"
Try {Import-Module -Name SecAudit}
Catch {Throw "Unable to load the SecAudit Module, the install has failed"}
Get-ChildItem -Path $Path\Extensions | Register-Extension -force 
#endregion RegisterScripts
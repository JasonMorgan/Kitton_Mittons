<#
.SYNOPSIS
Deploy the SecAudit tool to a computer

.DESCRIPTION
Deploys the SecAudit tool to a workstation by copying the reqired files from the install directory
to the client which launched the install script.

.EXAMPLE
\\server\share\installroot\install.ps1

Deploys the SecAudit tool from the share, \\server\share\installroot, to the local computer

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/26/2014
Last Modified: 1/31/2014

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
Write-Verbose "Determining root directory"
try {$root = Split-Path $($MyInvocation.MyCommand.path)}
catch {Throw "Unable to establish Root Directory"}
Write-Debug "`$root = $root"
#endregion Initialize

#region PrepInstall
if (-not(Test-path $Path))
    {
        Write-Verbose "Creating Application directory"
        Try {New-Item -ItemType directory -Path $Path -Force | Out-Null}
        Catch {Throw "Unable to create $Path"}
    }
else
    {
        Write-Verbose "Removing old install"
        Get-ChildItem $Path | Remove-Item -Recurse
    }
if (-not(Test-path $ModulePath))
    {
        Write-Verbose "Creating Module directory"
        Try {New-Item -ItemType directory -Path $ModulePath -Force | Out-Null}
        Catch {Throw "Unable to create $ModulePath"}
    }
else
    {
        Write-Verbose "Removing Legacy Modules"
        Get-ChildItem $ModulePath | Remove-Item -Recurse
    }
Try {New-Item -ItemType Directory -Path $Path\Extensions | Out-Null}
Catch {Throw "Unable to create $Path\Extensions"}
Try {New-Item -ItemType file -Path $Path\Config.xml -Force | Out-Null}
Catch {Throw "Unable to create $Path\Config.xml"}
#endregion PrepInstall

#region CopyFiles
Try {
        Copy-Item -Path $root\SecAudit.psm1 -Destination $ModulePath -Force -ErrorAction stop
        Copy-Item -Path $root\SecAudit.ps1 -Destination $Path -Force -ErrorAction stop
        Copy-Item -Path $root\Key.xml -Destination $Path -Force -ErrorAction stop
        Copy-Item -Path $root\Extensions\* -Destination $Path\Extensions -ErrorAction stop
    }
Catch
    {
        Throw "Operation Aborted: Unable to copy install files"
    }
#endregion CopyFiles

#region RegisterScripts
Write-Verbose "Importing SecAudit"
Try {Import-Module -Name SecAudit}
Catch {Throw "Unable to load the SecAudit Module, the install has failed"}
$extensions = Get-ChildItem -Path $Path\Extensions 
foreach ($e in $extensions) 
    { 
        Try {$e | Register-Extension -force | Out-Null}
        Catch {Write-Warning "Unable to properly register $($e.FullName)"}
    }
#endregion RegisterScripts
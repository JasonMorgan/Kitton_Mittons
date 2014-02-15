<#
.SYNOPSIS
Install DRSMonitoring files to a computer

.DESCRIPTION
This script will copy all the required files for the Kitton Mittons' entry4 to any judge's computer.

This has been provided to assist the judges in very quickly running the modules and scripts provided on their own systems.

.EXAMPLE
\\server\share\installroot\install.ps1

Deploys the entry 3 scripts from the share, \\server\share\installroot, to the local computer

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 2/15/2014
Last Modified: 2/15/2014

#requires -Version 3

#>
[CmdletBinding(ConfirmImpact='High')]
Param
    (
        # Path to Application directory
        [String]$path = "$env:userprofile\Documents\ScriptingGames" ,

        # Path to Config file store
        [String]$StorePath = "C:\MonitoringFiles",
        
        # Path to Module store
        [string]$ModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\Monitoring"
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
        Write-Verbose "Creating script directory"
        Try {New-Item -ItemType directory -Path $Path -Force | Out-Null}
        Catch {Throw "Unable to create $Path"}
    }
else
    {
        Write-Verbose "Removing old install"
        Get-ChildItem $Path | Remove-Item -Recurse
    }
if (-not(Test-path $StorePath))
    {
        Write-Verbose "Creating config store directory"
        Try {New-Item -ItemType directory -Path $Path -Force | Out-Null}
        Catch {Throw "Unable to create $Path"}
    }
else
    {
        Write-Verbose "Removing old configs"
        Get-ChildItem $StorePath | Remove-Item -Recurse
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
#endregion PrepInstall

#region CopyFiles
Try {
        Copy-Item -Path $root\Monitoring.psm1 -Destination $ModulePath -Force -ErrorAction stop
        Copy-Item -Path $root\Monitoring.psd1 -Destination $ModulePath -Force -ErrorAction stop
        Copy-Item -Path $root\DRSMonitoring.ps1xml -Destination $ModulePath -Force -ErrorAction stop
        Copy-Item -Path $root\Servers.csv -Destination $Path -Force -ErrorAction stop
        Copy-Item -Path $root\DeployConfig.ps1 -Destination $Path -Force -ErrorAction stop
        Copy-Item -Path $root\AuditCOnfig.ps1 -Destination $Path -Force -ErrorAction stop
    }
Catch
    {
        Throw "Operation Aborted: Unable to copy install files"
    }
#endregion CopyFiles
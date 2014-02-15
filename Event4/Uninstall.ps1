<#
.SYNOPSIS
Uninstall DRSMonitoring files from a computer

.DESCRIPTION
This script will remove all the required files for the Kitton Mittons' entry4 from any judge's computer.

This scripts allows you to easily revert your computer to the pre-testing state, and removes all Kitten Mittons items.


.EXAMPLE
\\server\share\installroot\uninstall.ps1

Removes the three scripts from your local computer.

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
        [string]$ModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\SecAudit"
    )
#region Initialize
Write-Verbose "Determining root directory"
try {$root = Split-Path $($MyInvocation.MyCommand.path)}
catch {Throw "Unable to establish Root Directory"}
Write-Debug "`$root = $root"
#endregion Initialize


#region RemoveFiles
Try {
        Remove-Item -Path $ModulePath -Force -ErrorAction stop -Recurse -
        Remove-Item -Path $StorePath -Force -ErrorAction stop -Recurse
        Remove-Item -Path $Path -Force -ErrorAction stop -Recurse
    }
Catch [System.Management.Automation.ItemNotFoundException]

    {
       "Path not found, already removed?" 
    }
Catch 
    {
    Throw "Operation Aborted: Unable to remove files"
    }

#endregion RemoveFiles




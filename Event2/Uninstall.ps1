<#

.SYNOPSIS
Uninstalls the SecAudit tool

.DESCRIPTION
Removes all files and Scheduled jobs used by the SecAudit tool

.EXAMPLE
$env:programfiles\SecAudit\uninstall.ps1

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.3
Created on: 1/26/2014
Last Modified: 2/1/2014

#requires -Version 3

#>
Param
    (
        [String]$Path = "$env:ProgramFiles\Security Audit",
        [string]$ModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\SecAudit"
    )
try {
        Import-module -name SecAudit 
        Get-Extension -listAvailable | Unregister-Extension
        Remove-Item $Path -Recurse -ErrorAction stop
        Remove-Item $ModulePath -Recurse -ErrorAction stop
    }
Catch 
    {
        Write-Warning $_.exception.message
        Throw "Uninstall failed, please manually remove SecAudit files and unregister SecAudit Scheduled jobs"
    }
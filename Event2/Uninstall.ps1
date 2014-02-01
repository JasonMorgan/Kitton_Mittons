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

#>
Param
    (
        [String]$Path = "$env:ProgramFiles\Security Audit",
        [string]$ModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\SecAudit"
    )
try {
        Import-Clixml $path\config.xml -ErrorAction stop | foreach {Unregister-ScheduledJob -Name $_.name  -ErrorAction stop }
        Remove-Item $Path -Recurse -ErrorAction stop
        Remove-Item $ModulePath -Recurse -ErrorAction stop
    }
Catch 
    {
        Throw "Uninstall failed, please manually remove SecAudit files and unregister SecAudit Scheduled jobs"
    }
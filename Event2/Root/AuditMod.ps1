<#

.SYNOPSIS
Master script that launches registered extension scripts, stores data on central share, and sends alerts if necessary

.DESCRIPTION

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 1/26/2014
Last Modified: 1/26/2014

***One  outstanding item will be a switch to allow you to set schedules for the various extensions.  Seems to be a requirement for this task.

#>
Param 
    (
        $netpath,
        $progress,
        $key
    )
#region Initialize
Import-Module -Name PSScheduledJob
#load config file
#config file contains all registered extension job names and Section Titles
Import-Clixml .\Config.xml
#endregion Initialize

#region RunScripts
#Add progress bar
do {"Progress"}
While ((Get-Job).state -contains "Running")
#Start jobs
foreach ($j in $jobs)
    {
        Start-Job -DefinitionName $j
    }


#watch for errors
#endregion RunScripts

#region TestShare
#be able to start network watcher job
Test-Path -Path $netshare

#Test-write
New-Item -ItemType file -Path $netshare\Reports\$(Get-Date -Format MM_dd_yyyy)\$env:COMPUTERNAME.html -Force

#be able to switch to local store on failure

# set alert flag on failure
#$can'tfind
#$Can'tWrite
#endregion TestShare


#region CheckKeyfile
if ((Get-Item -Path $netshare\Common\key.xml).LastWriteTime -gt (Get-Item .\key.xml).LastWriteTime)
    {
        Copy-Item -Path $netshare\Common\key.xml -Destination .\key.xml -Force -ErrorAction Stop
    }
#endregion CheckKeyfile

#region HTMLReport
#endregion HTMLReport

#only do if you have time
#region XMLReport
#endregion XMLReport

#may be superfluous
#region SendNotification
#endregion SendNotification
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
[cmdletbinding()]
Param 
    (
        #
        [Parameter(ParameterSet="Default")]
        [Parameter(ParameterSet="local")]
        [switch]$progress,

        #
        [Parameter(ParameterSet="Default")]
        [bool]$encrypt = $true,
        
        #
        [Parameter(ParameterSet="Default")]
        [Parameter(ParameterSet="local")]
        $Path = "\\Server\Share\Reports",
        
        #
        [Parameter(ParameterSet="Default")]
        $keyPath = "\\Server\Share\Common",
        
        #
        [Parameter(ParameterSet="Default")]
        $EmailAddress,
        
        #
        [Parameter(ParameterSet="local")]
        $extension = "All",
        
        #
        [Parameter(ParameterSet="list")]
        [switch]$listextension,
        
        #
        [Parameter(ParameterSet="Default")]
        $name = "$env:COMPUTERNAME.html"
    )
#region Initialize
Import-Module -Name PSScheduledJob
#load config file
$jobs = Import-Clixml .\Config.xml
#endregion Initialize

#region RunScripts

#Start jobs
foreach ($n in $jobs.name)
    {
        Start-Job -DefinitionName $n
    }

#Add progress bar
if ($progress)
    { 
        do {"Progress"}
        While ((Get-Job).state -contains "Running")
    }
Else
    {
        do {Start-Sleep -Seconds 15}
        While ((Get-Job).state -contains "Running")
    }
#watch for errors
#endregion RunScripts

#region TestShare
#be able to start network watcher job
if (Test-Path -Path $Path)
    {
        #Test-write
        Try
            {
                New-Item -ItemType file -Path $Path\Reports\$(Get-Date -Format MM_dd_yyyy)\$env:COMPUTERNAME.html -Force
            }
        Catch
            {
                $nowrite = $true
            }
    }
Else {$notfound = $true}
#be able to switch to local store on failure
#endregion TestShare


#region CheckKeyfile
if ((Get-Item -Path $keyPath\key.xml).LastWriteTime -gt (Get-Item .\key.xml).LastWriteTime)
    {
        Copy-Item -Path $keyPath\key.xml -Destination .\key.xml -Force -ErrorAction Stop
    }
#endregion CheckKeyfile

#region HTMLReport
$report = @"
HTMLhead

$(
Foreach ($j in $jobs)
    {
        @"
<h3> $($j.title) <h3>
<br>
$(Receive-Job -Name $j.name | ConvertTo-Html -As $j.format -Fragment | Out-String)
<br>
"@
    }
)

HTMLTail
"@
#endregion HTMLReport

#only do if you have time
#region XMLReport
#endregion XMLReport

#region SendNotification
if ($notfound)
    {
        $body = @"

"@
        $params = @{
                
            }
        Send-MailMessage @params
    }
If ($nowrite)
    {
        $body = @"

"@
        $params = @{
                
            }
        Send-MailMessage @params
    }
#endregion SendNotification
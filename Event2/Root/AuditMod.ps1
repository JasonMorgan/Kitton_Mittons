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

-requires PowerShell V3

#>
[cmdletbinding()]
Param 
    (
        # Enable the progress bar
        [Parameter(ParameterSet="Default")]
        [Parameter(ParameterSet="local")]
        [switch]$progress,

        # Enable encryption
        [Parameter(ParameterSet="Default")]
        [bool]$encrypt = $true,
        
        # Set path to store the report
        [Parameter(ParameterSet="Default")]
        [Parameter(ParameterSet="local")]
        $Path = "\\Server\Share\Reports\$(Get-Date -Format MM_dd_yyyy)\$env:COMPUTERNAME",
        
        # Path to network based key file
        [Parameter(ParameterSet="Default")]
        $keyPath = "\\Server\Share\Common\key.xml",
        
        # Email address for notifications
        [Parameter(ParameterSet="Default")]
        $EmailAddress,
        
        # Specify Extensions to be run
        [Parameter(ParameterSet="local")]
        [ValidateSet({(Import-Clixml .\Config.xml | select -ExpandProperty Name),"all"})] # not sure if this works
        [string[]]$extension = "All",
        
        # 
        [Parameter(ParameterSet="list")]
        [switch]$listextension
    )
#region Initialize
Write-Verbose "Import Scheduled Jobs Module"
Try {Import-Module -Name PSScheduledJob} Catch {Throw "Unable to load Scheduled Jobs Module"}
If ($listextension)
    {
        Write-Verbose "Listing Extensions"
        Import-Clixml .\Config.xml
        break
    }
#load config file
try {$jobs = Import-Clixml .\Config.xml} Catch {Throw "Unable to load config.xml, please verify that SecAudit has been deployed correctly"}
#endregion Initialize

#region RunScripts

Write-Verbose "Starting jobs"
foreach ($n in $jobs.name)
    {
        try {Start-Job -DefinitionName $n} catch {Write-Warning "Unable to launch the job: $n"}
    }
if ($progress)
    { 
        Write-Verbose "Create progress bar"
        do {
                $params = @{
                        Activity = "Running Security Audit" 
                        Status = "Completed $(((Get-Job).state -contains "Completed").count) of $((Get-Job).Count) jobs" 
                        PercentComplete = ((((Get-Job).state -contains "Completed").count)/(Get-Job).Count)
                    }
                Write-Progress @params
           }
        While ((Get-Job).state -contains "Running")
    }
Else
    {
        do {Start-Sleep -Seconds 15}
        While ((Get-Job).state -contains "Running")
    }

#endregion RunScripts

#region TestShare
#be able to start network watcher job
if (Test-Path -Path (Split-Path $Path))
    {
        #Test-write
        Try
            {
                New-Item -ItemType file -Path $Path -Force
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

if ((Get-Item -Path $keyPath).LastWriteTime -gt (Get-Item .\key.xml).LastWriteTime)
    {
        Copy-Item -Path $keyPath -Destination .\key.xml -Force -ErrorAction Stop
    }

#endregion CheckKeyfile

#region HTMLReport

$report = @"
HTMLhead

$(
Foreach ($j in $jobs)
    {
        if ((Get-Job -Name $j.name).ChildJobs[0].Output)
            {
                @"
<h3> $($j.title) <h3>
<br>
$(if ((Get-Job -Name $j.name).ChildJobs[0].error) {"This job generated $((Get-Job -Name $j.name).ChildJobs[0].error.count) errors while running"})
<br>
$(Receive-Job -Name $j.name | ConvertTo-Html -As $j.format -Fragment | Out-String)
<br>
"@
            }
    }
)

HTMLTail
"@

#endregion HTMLReport

#region Encryption

if ($encrypt)
    {
        $report = ConvertTo-SecureString -String $report -AsPlainText -Key (Import-Clixml .\key.xml)
    }

#endregion Encryption

#region SaveReport

$report | Out-File -FilePath $Path

#endregion SaveReport
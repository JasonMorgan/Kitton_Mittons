<#

.SYNOPSIS
Master script that launches registered extension scripts, stores data on central share, and sends alerts if necessary

.DESCRIPTION
This script is loaded into the task scheduler as a regular scheduled task by the install.ps1 script.  It will execute 
all the scheduled jobs that have been registered by the install script, or the Register-Extension function, with the
SecAudit tool.  The jobs are then collected and added to a common html report, which may or may not be encrypted.
Encyption is selected by the -Encryption parameter and defaults to $true.  When run interactively the user is able to 
select particular extensions to run using the extension parameter.

.EXAMPLE

$env:programfiles\SecAudit\SecAudit.ps1 -path c:\report.html -encryption:$false -progress

Run the tool with a progress bar.  This will save the report to the local disk at C:\Report.html.

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.3
Created on: 1/26/2014
Last Modified: 1/31/2014

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
        [ValidateScript({Test-Path -Path (Split-Path -parent $_)})]
        $Path = "\\Server\Share\Reports\$(Get-Date -Format MM_dd_yyyy)\$env:COMPUTERNAME",
        
        # Path to network based key file
        [Parameter(ParameterSet="Default")]
        [ValidateScript({(Test-Path -Path $_ -PathType Leaf) -and ($_.endswith('.xml'))})]
        $keyPath = "\\Server\Share\Common\key.xml",
        
        # Specify Extensions to be run
        [Parameter(ParameterSet="local")]
        [ValidateSet({(Import-Clixml .\Config.xml | select -ExpandProperty Name),"all"})] # not sure if this works
        [string[]]$extension = "All"
    )

#region Initialize

Write-Verbose "Determining root directory"
$root = Split-Path $($MyInvocation.MyCommand.path)
Write-Debug "`$root = $root"
Write-Verbose "Import Scheduled Jobs Module"
Try {Import-Module -Name PSScheduledJob} 
Catch {Throw "Unable to load Scheduled Jobs Module"}
Write-Verbose "Importing SecAudit"
Try {Import-Module -Name SecAudit}
Catch {Throw "Unable to load the SecAudit Module, please verify your install"}
Write-Verbose "Admin check"
if (-not(Test-IsAdministrator))
    {
        Throw "Operation Aborted: You are not authorized to run this command"
    }
Write-Verbose "Load config.xml"
try {$jobs = Import-Clixml $root\Config.xml} Catch {Throw "Unable to load config.xml, please verify that SecAudit has been deployed correctly"}
Write-Debug "$($jobs.Count) jobs loaded in $root\Config.xml"

#endregion Initialize

#region RunScripts

Write-Verbose "Starting jobs"
foreach ($n in $jobs.name)
    {
        try {Start-Job -DefinitionName $n} 
        catch {Write-Warning "Unable to launch the job: $n"}
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
                Write-Verbose "running 1 second delay"
                Start-Sleep -Seconds 1
           }
        While ((Get-Job).state -contains "Running")
    }
Else
    {
        do {Start-Sleep -Seconds 15}
        While ((Get-Job).state -contains "Running")
    }

#endregion RunScripts

#region CheckKeyfile

Write-Verbose "Checking key file"
if (((Get-Item -Path $keyPath).LastWriteTime -gt (Get-Item .\key.xml).LastWriteTime) -and $encrypt)
    {
        Write-Verbose "Updating key file"
        try {Copy-Item -Path $keyPath -Destination .\key.xml -Force -ErrorAction Stop}
        catch {Throw "Unable to copy latest version of key file"}
    }

#endregion CheckKeyfile

#region HTMLReport

Write-Verbose "Generating Report"
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
        Write-Verbose "Encrypting Module"
        $report = ConvertTo-SecureString -String $report -AsPlainText -Key (Import-Clixml .\key.xml)
    }

#endregion Encryption

#region SaveReport
Write-Verbose "Writing report to $path"
Try {$report | Out-File -FilePath $Path}
Catch 
    {
        Write-Error $_.exception.message
        Throw "Unable to save $report"
    }

#endregion SaveReport

#region Exit

Write-Verbose "Setting lastexitcode for TaskScheduler"
exit $LASTEXITCODE

#endregion Exit
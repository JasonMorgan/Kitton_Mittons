<#
.SYNOPSIS
Audit the deployment of the DRSMonitoring configurations

.DESCRIPTION
This script will audit one or more computers and, optionally, create a report based on it's findings.  
If no report is created audit objects will be returned to the pipeline.  All actions in this script
can be handled manually by using the test-* functions loaded in the monitoring module.

.EXAMPLE
.\AuditConfig.ps1 -computername Server01,Server02

The audit objects for server01 and Server 02 will be displayed

.EXAMPLE
.\AuditConfig.ps1 -computername Server01,Server02,Server03 -report -path c:\report.html

The servers listed will be audited and a report will be generated at c:\report.html

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.4
Created on: 2/14/2014
Last Modified: 2/15/2014

#requires -Version 3
#>
[cmdletbinding(DefaultParameterSetName="Default")]
Param
(
    # Enter the target computername(s)
    [Parameter(Mandatory,ParameterSetName="Default")]
    [Parameter(Mandatory,ParameterSetName="Report")]
    [Parameter(Mandatory,ParameterSetName="Remediate")]
    [string[]]$ComputerName,
    
    # Path to config files directory
    [Parameter(ParameterSetName="Default")]
    [Parameter(ParameterSetName="Report")]
    [Parameter(ParameterSetName="Remediate")]
    [string]$ConfigPath = "C:\monitoringFiles",

    # Path to audit for install directories, only set if you are using a non standard install root
    [Parameter(ParameterSetName="Default")]
    [Parameter(ParameterSetName="Report")]
    [Parameter(ParameterSetName="Remediate")]
    [string]$InstallPath = "c:\DRSMonitoring\config.xml",

    # Set if you'd like the Script to automatically remediate old config files
    [Parameter(ParameterSetName="Remediate")]
    [switch]$Remediate,

    # Set this flag if you would like to view progress reports during the audit
    [Parameter(ParameterSetName="Default")]
    [Parameter(ParameterSetName="Report")]
    [Parameter(ParameterSetName="Remediate")]
    [switch]$ShowProgress,

    # Set this flag if you would like to store the report as an html file
    [Parameter(ParameterSetName="Report")]
    [Switch]$Report,

    # Enter the path for the HTML file
    [Parameter(Mandatory,
    ParameterSetName="Report")]
    [String]$Path
)

#region Opening
Write-Verbose "Load Module"
Try {Import-Module Monitoring}
Catch {Throw "Unable to load Module file, verify that the Monitoring.psm1 file has been loaded on this computer."}
$InstallPath = $InstallPath.replace(':','$')
Write-Debug "`$installpath: $InstallPath "
#endregion Opening

#region Audit
Write-Verbose "Creating Jobs"
$i=0
foreach ($c in $computername)
  {
    $i++
    Start-Job -Name Test$i -ArgumentList $c,$InstallPath,$Remediate -ScriptBlock {
        Param ($Computer,$installpath,$Remediate)
        Write-Verbose "Build Audit object"
        $aud = Test-Deployment -ComputerName $Computer
        Write-Verbose "Update config if required"
        $current = $true
        if (-not(Test-Config -Target (Join-Path -Path \\$Computer -ChildPath $InstallPath) -Path C:\MonitoringFiles\$Computer.xml ))
          {
            if ($Remediate)
              {
                Try {Test-Config -Target (Join-Path -ChildPath \\$Computer -ChildPath $InstallPath) -Remediate -ErrorAction stop}
                Catch {
                    Write-Error "Unable to update config.xml on $Computer"
                    $current = $false
                  }
              }
            else {$current = $false}
          }
        $aud | Add-Member -MemberType NoteProperty -Name ConfigFileCurrent -Value $current
        $aud
      } | Out-Null
  }
if ($ShowProgress)
  {
    While ((get-job -Name Test*).State -contains "Running")
      {
        $prog = @{
            Activity = "Running Jobs"
            Status = "$((get-job -Name Test* | where State -like "Completed").count) of $((Get-Job -Name Test*).Count) Complete" 
            PercentComplete = (((get-job -Name Test* | where State -like "Completed").count / (Get-Job -Name Test*).Count) * 100 )
          }
        Write-Progress @prog
      }
  }
While ((get-job -Name Test*).State -contains "Running")
  {
    Write-Verbose "Waiting on jobs to finish"
    Start-Sleep -Seconds 1
  }
#endregion Audit

#region Report
if ($Report)
  {
$html = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>DRSMonitoring Report</title>
</head><body>
  $(get-job -Name Test* | receive-job | 
  ConvertTo-Html -Property ComputerName,Last_Audit,ConfigExists,MonitoringKeyExists,MonitoringKeyValue,MonitoringKeyCorrect,ConfigFileCurrent -Fragment -as List |
  Out-String )
</body></html>
"@ 

    $html | Out-File -FilePath $Path -Force
  }
else {get-job -Name Test* | receive-job}
#endregion Report

#region Cleanup
Write-Verbose "Cleaning up jobs"
get-job -Name Test* | Remove-Job
#endregion Cleanup
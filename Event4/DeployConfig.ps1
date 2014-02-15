<#
.SYNOPSIS
Generates and Deploys XML files to a computer or computers and sets a registry value

.DESCRIPTION
Generates an XML configuration file which is then deployed to a computer to a specified directory.

If the directory does not exist, it is created, then a registry key is created which is used by
the Dr's Monitoring tool.

.EXAMPLE
.\DeployConfig -path .\servers.csv

Read the Servers.csv file and deploy the config file and registry settings for each entry

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.3
Created on: 2/14/2014
Last Modified: 2/15/2014

#requires -Version 3

#>
[CmdletBinding(ConfirmImpact='High')]
Param
  (
    # Path to input csv file
    [Parameter(Mandatory)]
    [ValidateScript({ (Test-Path -PathType leaf -Path $_) -and ($_.endswith('.csv')) })]
    [string]$Path,

    # Install path for remote computers
    [String]$InstallPath = "C:\DRSMonitoring",

    # Path to config file store
    [ValidateScript({Test-Path -PathType Container -path $_})]
    [string]$StorePath = "C:\MonitoringFiles",

    # Set if you would like to view progress
    [switch]$ShowProgress
  )

#region Opening
Write-Verbose "Load Module"
Try {Import-Module Monitoring}
Catch {Throw "Unable to load Module file, verify that the Monitoring.psm1 file has been loaded on this computer."}
$InstallPath = $InstallPath.replace(';','$')
Write-Debug "`$installpath: $InstallPath "
Try {
    Write-Verbose "Load CSV"
    $total = Import-Csv -Path $path
  }
Catch {Throw "Unable to load csv file @ $Path"}
#endregion Opening

#region Do work
Write-Verbose "Building Config files"
Try {
    $i = 0
    $total | New-XMLConfig | foreach { 
        if ($ShowProgress)
          {
            Write-Debug "Count is $($total.count)"
            $i ++
            $prog = @{
                Activity = "Building Configs"
                Status = "$i of $($total.count)"
                PercentComplete = ($i/($total.count) *100)
              }
            Write-Progress @prog
          }
        out-XMLFile -XML $_ -Path "C:\MonitoringFiles\$($_.DRSmonitoring.Server.Name).xml" 
      }
  }
Catch {
    Write-Warning $_.exception.message
    Throw "Unable to build config files, aborting operation"
  }
Write-Verbose "Deploy config files"
try {
    $i = 0
    Foreach ($t in $Total)
      {
        if ($ShowProgress)
          {
            $i ++
            $prog = @{
                Activity = "Deploying Config files"
                Status = "$i of $($total.count)"
                PercentComplete = ($i/$total.count *100)
              }
            Write-Progress @prog
          }
        Install-Config -Path "$StorePath\$($t.Server).xml" -ComputerName $t.server
      }
  }
Catch 
  {
    Write-Warning $_.exception.message
    Throw "Unable to deploy config files, aborting operation"
  }
Write-Verbose "Deploy Registry key"
try {
    $i = 0
    Foreach ($t in $Total)
      {
        if ($ShowProgress)
          {
            $i ++
            $prog = @{
                Activity = "Deploying Registry key"
                Status = "$i of $($total.count)"
                PercentComplete = ($i/$total.count *100)
              }
            Write-Progress @prog
          }
        Install-Key -ComputerName $t.server | Out-Null
      }
  }
Catch 
  {
    Write-Warning $_.exception.message
    Throw "Unable to deploy Registry keys, aborting operation"
  }
#endregion Do Work

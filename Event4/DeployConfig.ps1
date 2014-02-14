<#
.SYNOPSIS
Generates and Deploys XML files to a computer or computers and sets a registry value

.DESCRIPTION
Generates an XML configuration file which is then deployed to a computer to a specified directory.

If the directory does not exist, it is created, then a registry key is created which is used by
the Dr's Monitoring tool.

.EXAMPLE
C:\powershell\scripts\DeployConfig.ps1 -ComputerName Server01 -IpAddress 192.168.10.1 -MonitorCPU True -MonitorRam True -MonitorDisk True -MonitorNetwork False

Creates an .XML file with the desired configuration and deploys it to Server01 in the default folder, then sets the registry value.

.Example
C:\powershell\scripts\Import-csv .\servers.csv | DeployConfig.ps1

Creates an .XML file for each server found in the servers.csv file and deploys it to each in the default folder, then sets the registry value.

.Example
C:\powershell\scripts\Import-csv .\servers.csv | DeployConfig.ps1 -Destination C:\ProgramFiles\DrsMonitoring

Creates an .XML file for each server found in the servers.csv file and deploys in a custom location, rather than the default path of C:\DrsMonitoring.

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 2/14/2014
Last Modified: 2/14/2014

#requires -Version 3

#>
[CmdletBinding(ConfirmImpact='High')]
Param
  (
    # Path to input csv file
    [string]$path,

    # Install path for remote computers
    [String]$InstallPath = "C:\DRSMonitoring",

    # Path to config file store
    [string]$StorePath = "C:\MonitoringFiles",

    #
    [switch]$ShowProgress
  )

#region Opening
Write-Verbose "Load Module"
Try {Import-Module Monitoring}
Catch {Throw "Unable to load Module file, verify that the MOnitoring.psm1 file has been loaded on this computer."}
$InstallPath = $InstallPath.replace(';','$')
Write-Debug "`$installpath: $InstallPath "
#endregion Opening

#region Create jobs
Write-Verbose "Building Config files"
Try {
    $i = 0
    Import-Csv -Path $path | Tee-Object -Variable Total | New-XMLConfig | foreach { 
        if ($ShowProgress)
          {
            $i ++
            $prog = @{
                Activity = "Building Configs"
                Status = "$i of $($total.count)"
                PercentComplete = ($i/$total.count *100)
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
#endregion Create jobs

#region complete

#endregion
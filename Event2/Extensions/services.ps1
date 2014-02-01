<#

.SYNOPSIS
This script will collect information about local services.

.DESCRIPTION
This script is intended to run as a scheduled job.  Use the register switch when loading the header data.

.EXAMPLE
.\Services.ps1

Outputs service data for the local computer

.EXAMPLE

. .\Shares.ps1 -register

Load header variables into your current scope without triggering the data collection job

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.2
Created on: 1/26/2014
Last Modified: 2/1/2014

#>

Param 
    (
        [switch]$Register
    )

#region GatherData

$job = {
        Get-CimInstance Win32_service  | Select Name,ProcessID,State,StartName,PathName,ExitCode
    }
#endregion GatherData

#region run
Switch ($Register)
    {
        $true {
                $Name = "Services"
                $title = "Service Info"
                $format = "List"
            }
        $false {$job.invoke()}
    }
#endregion run
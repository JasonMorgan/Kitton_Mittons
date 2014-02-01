<#

.SYNOPSIS
This script will collect information about local processes.

.DESCRIPTION
This script is intended to run as a scheduled job.  Use the register switch when loading the header data.

.EXAMPLE
.\Procs.ps1

Outputs local process data for the local computer

.EXAMPLE

. .\Procs.ps1 -register

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

#region job
$job = {
        Get-CimInstance win32_process | Select Name,Path,CreationDate,ExecutablePath
    }
#endregion job

#region run
Switch ($Register)
    {
        $true {
                $Name = "Procs"
                $title = "Process Info"
                $format = "List" 
            }
        $false {$job.invoke()}
    }
#endregion run
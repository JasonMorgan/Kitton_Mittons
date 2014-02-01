<#

.SYNOPSIS
This script will collect information about the environment variables.

.DESCRIPTION
This script is intended to run as a scheduled job.  Use the register switch when loading the header data.

.EXAMPLE
.\env.ps1

Outputs environment variable data for the local computer

.EXAMPLE

. .\env.ps1 -register

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
        Get-ChildItem Env: | Select Name,Value
    }
#endregion GatherData

#region run
Switch ($Register)
    {
        $true {
                $Name = "Env"
                $title = "Environmental Variables"
                $format = "Table"
            }
        $false {$job.invoke()}
    }
#endregion run
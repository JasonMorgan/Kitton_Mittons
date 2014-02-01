<#

.SYNOPSIS


.DESCRIPTION
This script is intended to run as a scheduled job.  Use the register switch when loading the header data.

.EXAMPLE
.\Shares.ps1

Outputs share folder data for the local computer

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

#region Job
$job = {
        Write-Verbose "Collecting Shares"
        $types = @{
                "0" = "Disk Drive"
                "1" = "Print Queue"
                "2" = "Device"
                "3" = "IPC"
                "2147483648" = "Disk Drive Admin"
                "2147483649" = "Print Queue Admin"
                "2147483650" = "Device Admin"  
                "2147483651" =  "IPC Admin"   
            }
        Get-CimInstance win32_share | select Name,Description,Status,@{l="Type";e={ $types.Item("$($_.type)") } },Path
    }
#endregion Job

#region run
Switch ($Register)
    {
        $true {
                $Name = "Shares"
                $title = "Available Network Shares"
                $format = "Table"
            }
        $false {$job.invoke()}
    }
#endregion run
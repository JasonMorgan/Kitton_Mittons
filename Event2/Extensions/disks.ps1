<#

.SYNOPSIS
This script will collect information about local disks.

.DESCRIPTION
This script is intended to run as a scheduled job.  Use the register switch when loading the header data.

.EXAMPLE
.\Disks.ps1

Outputs volume data for the local computer

.EXAMPLE

. .\Disks.ps1 -register

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
        $Type = @{
                '0' = 'Unknown'
                '1' = 'No Root Directory'
                '2' = 'Removable Disk'
                '3' = 'Local Disk'
                '4' = 'Network Drive'
                '5' = 'Compact Disk'
                '6' = 'RAM Disk'
            }

        Get-CimInstance win32_volume  | Select Caption,InstallDate,DeviceID,
        @{ l='DriveType';e={ $Type.item("$($_.DriveType)") } },AutoMount,DriveLetter,capacity,freespace
    }
#endregion GatherData

#region run
Switch ($Register)
    {
        $true {
                $Name = "Disks"
                $title = "Local Disks"
                $format = "Table"
            }
        $false {$job.invoke()}
    }
#endregion run
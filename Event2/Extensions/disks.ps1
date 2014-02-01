<#

.SYNOPSIS


.DESCRIPTION

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 1/26/2014
Last Modified: 1/26/2014


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
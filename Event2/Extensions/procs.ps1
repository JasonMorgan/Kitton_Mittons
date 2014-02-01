<#
.SYNOPSIS


.DESCRIPTION

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
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
<#

.SYNOPSIS
Collect Environment variables

.DESCRIPTION

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 1/27/2014
Last Modified: 1/27/2014


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
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

#region ExtensionHeader
$Name = "Shares"
$title = "Available Network Shares"
$format = "Table"
if ($Register)
    {
        Break
    }
#endregion ExtensionHeader

#region GatherData
Write-Verbose "Collecting Shares"
$types = @{
        "0" = "Disk Drive"
        "1" = "Print Queue"
        "2" = "Device"
        "3" = "IPC"
        "2147483648" = "Disk Drive Admin"
        "2147483649" = "Print Queue Admin"
        "2147483650" = "Device Admin"  
        2147483651 =  "IPC Admin"   
    }
Get-CimInstance win32_share | select Name,Description,Status,@{l="Type";e={ $types.Item("$($_.type)") } },Path
#endregion GatherData
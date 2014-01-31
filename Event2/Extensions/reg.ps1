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
$Name = "Reg"
$title = "AutoRun Keys"
$format = "List"
if ($Register)
    {
        Break
    }
#endregion ExtensionHeader

#region GatherData
$keys = @()
foreach ($k in $keys)
    {
        foreach ($p in $props) 
            {
                [PSObject]@{$p = (Get-ItemProperty -Path $k.name -Name $p).$p} 
            }
    }

#region GatherData

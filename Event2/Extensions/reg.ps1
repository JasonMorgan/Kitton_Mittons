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
Write-Verbose "Adding HKU"
New-PSDrive -PSProvider Registry -Root HKEY_USERS -Name HKU
$keys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices"
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce"
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce\Setup"

    )
foreach ($k in $keys)
    {
        foreach ($p in $props) 
            {
                [PSObject]@{
                        Key = $k.name
                        $p = (Get-ItemProperty -Path $k.name -Name $p).$p
                    } 
            }
    }

#region GatherData

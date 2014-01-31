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

Get-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\ | Select-Object -ExpandProperty property
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
New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR
$keys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" #All values in this key are executed#
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" #All values in this key are executed, and then their autostart reference is deleted#
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices" #All values in this key are executed as services#
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce" #All values in this key are executed as services, and then their autostart reference is deleted#
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" #All values in this key are executed#
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" #All values in this key are executed, and then their autostart reference is deleted#
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce\Setup" #Used only by Setup. Displays a progress dialog box as the keys are run one at a time#
        "HKU:\Default\Software\Microsoft\Windows\Cur rentVersion\Run" #All values in this key are executed#
        "HKU:\Default\Software\Microsoft\Windows\Cur rentVersion\RunOnce" #All values in this key are executed, and then their autostart reference is deleted#
        "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components" #All values in this key are executed#
        "HKLM:\SYSTEM\CurrentControlSet\services\VxD" #All values in this key are executed#        
        "HKCR:\vbsfile\shell\open\command" #Executed whenever a .VBS file is run#
        "HKCR:\vbefile\shell\open\command" #Executed whenever a .VBE file is run#
        "HKCR:\jsfile\shell\open\command" #Executed whenever a .JS file is run #
        "HKCR:\jsefile\shell\open\command" #Executed whenever a .JSE file is run#
        "HKCR:\wshfile\shell\open\command" #Executed whenever a .WSH file is run#
        "HKCR:\wsffile\shell\open\command" #Executed whenever a .WSF file is run#
        "HKCR:\exefile\shell\open\command" #Executed whenever a .EXE file is run#
        "HKCR:\comfile\shell\open\command" #Executed whenever a .COM file is run#
        "HKCR:\batfile\shell\open\command" #Executed whenever a .BAT file is run#
        "HKCR:\scrfile\shell\open\command" #Executed whenever a .SCR file is run#
        "HKCR:\piffile\shell\open\command" #Executed whenever a .PIF file is run#
        "HKLM:\System\CurrentControlSet\Services" #Services marked to startup automatically are executed before user login#
        "HKLM:\System\CurrentControlSet\Services\Winsock2\Parameters\Protocol_Catalog\Catalog_Entries" #Layered Service Providers, executed before user login#
        "HKLM:\System\Control\WOW\cmdline" #Executed when a 16-bit Windows executable is executed#
        "HKLM:\System\Control\WOW\wowcmdline" #Executed when a 16-bit DOS application is executed#
        "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit" #Executed when a user logs in#
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\ShellServiceObjectDelayLoad" #Executed by explorer.exe as soon as it has loaded#
        "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\run" #Executed when the user logs in#
        "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\load" #Executed when the user logs in#
        "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\run" #Subvalues are executed when Explorer initialises#
        "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\run" #Subvalues are executed when Explorer initialises#
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

        "HKCU:\Control Panel\Desktop" #the "SCRNSAVE.EXE" value is the only autorun value#
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" # the "sHELL" value is the only autorun Value#
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" #the "BootExecute" value is the only autorun value#
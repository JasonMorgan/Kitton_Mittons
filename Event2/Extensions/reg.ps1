<#

.SYNOPSIS
This script will collect information about autorun keys in the registry.

.DESCRIPTION
This script is intended to run as a scheduled job.  Use the register switch when loading the header data.

.EXAMPLE
.\reg.ps1

Outputs autorun registry data for the local computer

.EXAMPLE

. .\reg.ps1 -register

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
        Write-Verbose "Adding HKU"
        Try {New-PSDrive -PSProvider Registry -Root HKEY_USERS -Name HKU}
        Catch {Write-Error "Unable to load HKU drive"}
        Write-Verbose "Adding HKCR"
        try {New-PSDrive -PSProvider Registry -Root HKEY_CLASSES_ROOT -Name HKCR}
        catch {Write-Error "Unable to load HKCR"}
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
                if (Test-Path -Path $k)
                    {
                        Get-ItemProperty -path $k | select -Property @{l='Key';e={ ($_.pspath -split '::')[-1] }},* -ExcludeProperty PS*
                    }
            }
    }
#endregion Job

#region run
Switch ($Register)
    {
        $true {
                $Name = "Reg"
                $title = "AutoRun Keys"
                $format = "List"
            }
        $false {$job.invoke()}
    }
#endregion run
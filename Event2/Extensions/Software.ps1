<#

.SYNOPSIS
This script will collect information about installed software.

.DESCRIPTION
This script is intended to run as a scheduled job.  Use the register switch when loading the header data.

.EXAMPLE
.\Software.ps1

Outputs installed software data for the local computer

.EXAMPLE

. .\Software.ps1 -register

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

#region DefineFunctions
Function Get-InstalledSoftware # This is a lot more function than we need but it is reused from my Technet posting - Jason
{ 
<# 
.SYNOPSIS 
Get-ISDInstalledSoftware provides the Name, Publisher, InstallDate, UninstallString, and Version for all software listed in the registry 
 
.DESCRIPTION 
Get-ISDInstalledSoftware will query the x64 and x86 registry nodes in order to list out all installed software and there associated uninstall stings. 
 
.EXAMPLE 
Get-ISDInstalledSoftware 
 
Name         : VMware Tools 
Publisher    : VMware, Inc. 
ComputerName : LABTOOLS 
Uninstall    : MsiExec.exe /X{44D55920-B223-4702-81D9-4C07108A3C27} 
Version      : 9.2.2.18018 
 
Name         : Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161 
Publisher    : Microsoft Corporation 
ComputerName : LABTOOLS 
Uninstall    : MsiExec.exe /X{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4} 
Version      : 9.0.30729.6161 

.EXAMPLE 
Get-ISDInstalledSoftware | Format-Table 
 
Name                         Publisher                    ComputerName                Uninstall                   Version                     
-------                      -------                      --------                    ---------                   -------                     
VMware Tools                 VMware, Inc.                 LABTOOLS                    MsiExec.exe /X{44D55920-... 9.2.2.18018                 
Microsoft Visual C++ 2008... Microsoft Corporation        LABTOOLS                    MsiExec.exe /X{5FCE6D76-... 9.0.30729.6161              
Microsoft Visual C++ 2008... Microsoft Corporation        LABTOOLS                    MsiExec.exe /X{1F1C2DFC-... 9.0.30729.4148 
 
.EXAMPLE 
Get-content c:\servers.txt | Get-ISDInstalledSoftware
 
Gets the InstalledSoftware information for a list of computers specified in the file servers.txt 

.NOTES
Written by Jason Morgan
LastModified 1/30/2014
Version 3.0.0.1

.LINKS
 
#> 
[CmdletBinding(ConfirmImpact='Medium')]
param (
      # Enter a computername or multiple computernames
      [Parameter( 
      ValueFromPipeline=$True, 
      ValueFromPipelineByPropertyName=$True,
      HelpMessage="Enter a ComputerName or IP Address, accepts multiple ComputerNames")]             
      [Alias("__Server")]
      [String[]]$ComputerName = $ENV:COMPUTERNAME,
      # Enter a Credential object, like (Get-credential)
      [Parameter(
      HelpMessage="Enter a Credential object, like (Get-credential)")]
      [System.Management.Automation.PSCredential]$credential
      )
Begin 
    {
        $params = @{ScriptBlock = {
                if ((Get-WmiObject win32_operatingsystem).OSArchitecture -notlike '64-bit') 
                    {
                        $keys= (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
                    } 
                else 
                    {
                        $keys = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
                    }  
                $Keys | 
                Where-Object {$_.Publisher -or $_.UninstallString -or $_.displayversion -or $_.DisplayName} | 
                ForEach-Object {
                        New-Object -TypeName PSObject -Property @{ 
                                ComputerName = $env:COMPUTERNAME
                                Publisher = $_.Publisher 
                                Uninstall = $_.UninstallString 
                                Version = $_.displayversion 
                                Name = $_.DisplayName
                                InstallDate = $_.InstallDate
                            } 
                    }
                }}
        If ($credential) {$Params.Add('Credential',$credential)}
    }
Process
    {
        [System.Collections.ArrayList]$comps += $ComputerName 
    }
End {
        if ($Comps -contains $ENV:COMPUTERNAME)
                {
                    $Comps.Remove("$ENV:COMPUTERNAME")
                    $local = $True
                }
            if (($Comps |measure).Count -gt 0)
                {
                    $params.Add('ComputerName',$Comps)
                    Invoke-Command @params
                }
            if ($local)
                {
                    Try {$params.Remove('ComputerName')} Catch {}
                    Invoke-Command @params
                }   
    }
}
#endregion DefineFunctions

#region GatherData
$job = {
        Get-InstalledSoftware | Select Name,Publisher,Version,InstallDate
    }
#endregion GatherData

#region run
Switch ($Register)
    {
        $true {
                $Name = "Software"
                $title = "Installed Software"
                $format = "Table"
            }
        $false {$job.invoke()}
    }
#endregion run
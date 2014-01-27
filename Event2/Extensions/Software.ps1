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

#region SetVariables
$JobName = "Software"
$title = "Installed Software"
$format = "Table"
#endregion SetVariables

#region DefineFunctions

Function Get-InstalledSoftware # Needs work, Check prod for updated version then, if needed, update to current standard
{ 
<# 
.SYNOPSIS 
Get-ISDInstalledSoftware provides the DisplayName, Publisher and UninstallString for all software listed in the registry 
 
.DESCRIPTION 
Get-ISDInstalledSoftware will query the x64 and x86 registry nodes in order to list out all installed software and there associated uninstall stings. 
 
.EXAMPLE 
Get-ISDInstalledSoftware 
 
Product   : VMware Tools 
Company   : VMware, Inc. 
Computer  : LABTOOLS 
Uninstall : MsiExec.exe /X{44D55920-B223-4702-81D9-4C07108A3C27} 
Version   : 9.2.2.18018 
 
Product   : Microsoft Visual C++ 2008 Redistributable - x64 9.0.30729.6161 
Company   : Microsoft Corporation 
Computer  : LABTOOLS 
Uninstall : MsiExec.exe /X{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4} 
Version   : 9.0.30729.6161 
 
Product   : Microsoft Visual C++ 2008 Redistributable - x86 9.0.30729.4148 
Company   : Microsoft Corporation 
Computer  : LABTOOLS 
Uninstall : MsiExec.exe /X{1F1C2DFC-2D24-3E06-BCB8-725134ADF989} 
Version   : 9.0.30729.4148 
 
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
 
#> 
[CmdletBinding()] 
Param 
    ( 
        # Enter a ComputerName or IP Address, accepts multiple ComputerNames
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        HelpMessage="Enter a ComputerName or IP Address, accepts multiple ComputerNames")] 
        [String[]]$ComputerName = "$env:COMPUTERNAME",
        # Activate this switch to force the function to run an ICMP check before running
        [Parameter(
        HelpMessage="Activate this switch to force the function to run an ICMP check before running")]
        [Switch]$ping
    ) 
Begin  
    {
        Write-Verbose "Instantiating Function Paramaters"
            $param = @{ScriptBlock = {
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
    } 
Process 
    {
        foreach ($Computer in $ComputerName) 
            {
                If ($Ping) 
                    {
                        Write-Verbose "Testing connection to $Computer"
                        if (-not(Test-Connection -ComputerName $Computer -Quiet)) 
                            {
                                Write-Warning "Could not ping $Computer" ; $Problem = $true
                            }
                    }
                Write-Verbose "Beginning operation on $Computer"
                If (-not($Problem))
                    {
                        If ($Computer -ne $env:COMPUTERNAME) 
                            {
                                Write-Verbose "Adding ComputerName, $Computer, to Invoke-Command"
                                $param.Add("ComputerName",$Computer)
                            }
                        Try
                            {
                                Write-Verbose "Invoking Command on $Computer"
                                Invoke-Command @param
                            }
                        Catch 
                            {
                                Write-warning $_.Exception.Message
                            }
                    }
                if ($Problem) {$Problem = $false}
                if ($param.ContainsKey('ComputerName')) 
                    {
                        Write-Verbose "Clearing $Computer from Parameters"
                        $param.Remove("ComputerName")
                    } 
            }
    } 
End {} 
}

#endregion DefineFunctions

#region CreateData

Get-InstalledSoftware | Select Name,Publisher,Version,InstallDate

#endregion CreateData
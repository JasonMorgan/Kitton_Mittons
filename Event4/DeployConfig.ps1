<#
.SYNOPSIS
Generates and Deploys XML files to a computer or computers and sets a registry value

.DESCRIPTION
Generates an XML configuration file which is then deployed to a computer to a specified directory.

If the directory does not exist, it is created, then a registry key is created which is used by
the Dr's Monitoring tool.

.EXAMPLE
C:\powershell\scripts\DeployConfig.ps1 -ComputerName Server01 -IpAddress 192.168.10.1 -MonitorCPU True -MonitorRam True -MonitorDisk True -MonitorNetwork False

Creates an .XML file with the desired configuration and deploys it to Server01 in the default folder, then sets the registry value.

.Example
C:\powershell\scripts\Import-csv .\servers.csv | DeployConfig.ps1

Creates an .XML file for each server found in the servers.csv file and deploys it to each in the default folder, then sets the registry value.

.Example
C:\powershell\scripts\Import-csv .\servers.csv | DeployConfig.ps1 -Destination C:\ProgramFiles\DrsMonitoring

Creates an .XML file for each server found in the servers.csv file and deploys in a custom location, rather than the default path of C:\DrsMonitoring.

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 2/14/2014
Last Modified: 2/14/2014

#requires -Version 3

#>
[CmdletBinding(ConfirmImpact='High')]
Param
    (
    
    #
    [Parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('Server')]
    [string]$ComputerName,
        
    #
    [Parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('IP')]
    [ipaddress]$IPAddress,
        
    # Set monitor CPU, true/false
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('CPU')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorCPU,
        
    # Set monitor RAM, true/false
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('RAM')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorRam,
        
    # Set monitor disk, true/false
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('Disk')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorDisk,
        
    # Set monitor network, true/false
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('Network')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorNetwork,

    # Set Destination directory
    [parameter()]
    $Destination="c:\DrsMonitoring"

    )

#region Initialize
try{
    if ($VerbosePreference){
        Import-Module .\Monitoring.psm1 -PassThru -ErrorAction Stop}
        ELSE{
        Import-Module .\Monitoring.psm1 -ErrorAction Stop}
    }
catch{
    Throw "Unable to load Monitoring module, place in local directory and then rerun"
    }


#endregion Initialize

#region Create jobs

#if using pipeline, create for each object
New-XMLConfig
#if using express input, execute

#endregion



#region showprogress

#endregion

#region complete

#endregion
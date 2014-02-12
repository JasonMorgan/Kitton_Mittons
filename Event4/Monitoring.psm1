<##>

Function New-XMLConfig
{
<#
.SYNOPSIS
Create a new XML monitoring object

.DESCRIPTION


.EXAMPLE

.EXAMPLE

.NOTES
#>
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
        
        #
        [Parameter(
        ValueFromPipeline,
        ValueFromPipelineByPropertyName)]
        [Alias('CPU')]
        [ValidateSet('True','False')]
        [string]$MonitorCPU,
        
        #
        [Parameter(
        ValueFromPipeline,
        ValueFromPipelineByPropertyName)]
        [Alias('RAM')]
        [ValidateSet('True','False')]
        [string]$MonitorRam,
        
        #
        [Parameter(
        ValueFromPipeline,
        ValueFromPipelineByPropertyName)]
        [Alias('Disk')]
        [ValidateSet('True','False')]
        [string]$MonitorDisk,
        
        #
        [Parameter(
        ValueFromPipeline,
        ValueFromPipelineByPropertyName)]
        [Alias('Network')]
        [ValidateSet('True','False')]
        [string]$MonitorNetwork
    )
Begin
{
[xml]$xml = @"
<?xml version="1.0" encoding="utf-8"?>
<DRSmonitoring xmlns="http://schemas.drsmonitoring.org/metadata/2013/11">
  <Server> 
    <Name></Name> 
    <IPAddress></IPAddress>
  </Server>
  <Monitoring>
    <MonitorCPU></MonitorCPU>
    <MonitorRAM></MonitorRAM>
    <MonitorDisk></MonitorDisk>
    <MonitorNetwork></MonitorNetwork>
  </Monitoring>
</DRSmonitoring>
"@
}
Process
{
$xml.DRSmonitoring.Server.Name = $ComputerName
$xml.DRSmonitoring.Server.IPAddress = "$($IPAddress.IPAddressToString)"
$xml.DRSmonitoring.Monitoring.MonitorCPU = $MonitorCPU
$xml.DRSmonitoring.Monitoring.MonitorRAM = $MonitorRam
$xml.DRSmonitoring.Monitoring.MonitorDisk = $MonitorDisk
$xml.DRSmonitoring.Monitoring.MonitorNetwork = $MonitorNetwork
$xml
}
}

Function out-XMLFile
{
<##>
Param
    (
        #
        [Parameter(Mandatory)]
        [xml]$XML,
        
        #
        [Parameter(Mandatory)]
        [ValidateScript({ Test-path -PathType Container -Path (Split-Path -Parent -path $_) })]
        [string]$path
    )
Begin {}
Process 
{
    $XML.Save($path)
}
}

Function Deploy-Config
{
param (
    [parameter(Mandatory)]
    $ComputerName,

    [parameter(Mandatory)]
    $path
)
copy -Path $path -Destination "\\$computername\c$\DRSmonitoring"

}

Function Deploy-Key{
<#
.SYNOPSIS
   Deploys Registry Key for DRSmonitoring
.DESCRIPTION
   Checks for the presence of registry key HKLM:\SOFTWARE\DRSMonitoring with the dWord value of 1 for
   Monitoring.  If the object is missing or incorrect, function add or corrects the value
.EXAMPLE
   .\Deploy-Key -ComputerName $computername

   Deploys registry key to the computer specified by the variable $computername
.INPUTS
   Computer Name
.OUTPUTS
   none
#>
param(
    [parameter(Mandatory,
    ValuefromPipeline=$true)]
    [string] $ComputerName
    )

Invoke-Command  -ScriptBlock {-ComputerName $computername

If(Test-path 'HKLM:\SOFTWARE\DRSmonitoring'){
    Write-Verbose "Get Value from registry"
    Try {
    $a = Get-ItemProperty -path HKLM:\SOFTWARE\DRSMonitoring -Name Monitoring -ErrorAction Stop
        }
    Catch {
      New-ItemProperty -Path 'HKLM:\SOFTWARE\DRSMonitoring' -PropertyType Dword -Value 1 -Name Monitoring
        }
          
    If($a -ne 1){
        Write-Verbose " Need to add registry entry"
        set-ItemProperty -Path 'HKLM:\SOFTWARE\DRSMonitoring' -Value 2 -Name Monitoring
        }
Else {
    write-verbose "Create key"
    New-Item -Path 'HKLM:\SOFTWARE\DRSMonitoring'
    Write-Verbose "Create Registry Value"
    New-ItemProperty -Path 'HKLM:\SOFTWARE\DRSMonitoring' -PropertyType Dword -Value 1 -Name Monitoring
    }
  }
  }
}

Function Audit-Config
{
#      - Is the config file current?
#      - Able to update config.xml if required    


}

Function Audit-Deployment
{
<#
.SYNOPSIS
   Audits Registry Key and Config file for DRSmonitoring
.DESCRIPTION
   Checks for the presence of registry key HKLM:\SOFTWARE\DRSMonitoring with the dWord value of 1 for
   Monitoring.  The status of the registry key is either correct, incorrect or missing.  Checks for the 
   presence of the monitoring file in the path specified. 
.EXAMPLE
   .\Audit-Deployment -ComputerName $computername -path c:\DRSMonitoring

   Checks for registry key and value as well as config file at c:\DRSMonitoring
.INPUTS
   Computer Name and path to config file
.OUTPUTS
   PS Custom Object

#>

param (
    [parameter(Mandatory)]
    $ComputerName,

    [parameter(Mandatory)]
    $path
    )

# The directions appear to only ask for the the registry value, so this if else statement may not be necessary
Write-Verbose "Testing for Registry Key"
    If(Test-path 'HKLM:\SOFTWARE\DRSmonitoring'){
        $RegKey = 'present'
    }
    Else{
        $RegKey = 'missing'
    }
Write-Verbose "Testing for Registry Value"
    $a = Get-ItemProperty -path HKLM:\SOFTWARE\DRSMonitoring -Name Monitoring -ErrorAction Stop

     Switch ( $a.Monitoring)
     {
         '1' {
            $registryValuepresent = 'correct'
            }
         $null{
            $registryValuepresent = 'missing'
            } 
         {$_ -ne 1 -and $_ -ne $null} {
            $registryValuepresent = 'incorrect value'
            }
     }

Write-Verbose "Testing for Configuration File"
    If(Test-path $path){
        $ConfigFileStatus = 'present'
    }
    Else{$ConfigFileStatus = 'missing'
    }

Write-Verbose "Collecting data into PS Custom Object"
    $data = @()
    $data =[Pscustomobject]@{
        "Server" = (Get-WmiObject win32_computersystem -Property Name)
        "Audit Date" = (Get-Date -Format g);
        "Configuration File" = $ConfigFileStatus;
        "Registry Key" = $RegKey;
        "Registry Value" = $registryValuepresent
        } 

        $data 
}

# Requested report
#•	Servers where the registry key existed and was set correctly
#•	Servers where the registry key existed and was set incorrectly
#•	Servers where the registry key had to be created
#•	Servers that have had the monitoring config file installed



#      - custom Type
#      - Default Formatting




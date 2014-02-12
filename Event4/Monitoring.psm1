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

Function Deploy-Key
# this requires administrator permissions
{
param(
    [parameter(Mandatory)]
    [string] $ComputerName
    )

Invoke-Command  -ScriptBlock {    #-ComputerName $computername

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
        set-ItemProperty -Path 'HKLM:\SOFTWARE\DRSMonitoring' -Value 1 -Name Monitoring
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
param (
    [parameter(Mandatory)]
    $ComputerName,

    [parameter(Mandatory)]
    $path
    )

#   - Audit Deployment Function
#      - Does the Key exist?  HKLM:\SOFTWARE\DRSmonitoring
    Test-path 'HKLM:\SOFTWARE\DRSmonitoring'

#      - is it set correctly?
    $a = Get-ItemProperty -path HKLM:\SOFTWARE\DRSMonitoring -Name Monitoring -ErrorAction Stop
     If($a -ne 1){
        Write-Verbose "Registry entry is missing"
        $registryValuepresent = $false
        }
     Else {
        $registryValuepresent = $false
        }


#      - Key Value
    If((Get-ItemProperty -path HKLM:\SOFTWARE\DRSMonitoring -Name Monitoring -ErrorAction Stop) -ne 1){
        $RegValuePresent = $false
        }
    Else {
        $RegValuePresent = $true
        }

#      - Audit Date
$Auditdate = Get-Date 
#      - Computername
$computername = Get-WmiObject win32_computersystem -Property Name
#      - is the config file deployed?
    If(Test-path $path)


#hash table
#•	Servers where the registry key existed and was set correctly
#•	Servers where the registry key existed and was set incorrectly
#•	Servers where the registry key had to be created
#•	Servers that have had the monitoring config file installed

}

#      - custom Type
#      - Default Formatting



Function Test-RegistryValue {

param (
[parameter(Mandatory=$true)]
[ValidateNotNullorEmpty()]
$path,

[parameter(Mandatory=$true)]
[ValidateNotNullorEmpty()]
$Value
)

    Get-ItemProperty -Path $path | Select-Object -ExpandProperty $value -ErrorAction Stop | Out-Null
     $true
}
catch 
{
    return $false
}
}


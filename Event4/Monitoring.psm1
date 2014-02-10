<##>

Function New-XMLConfig
{
<#

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

}

Function Deploy-Key
{

}

Function Audit-Config
{

}

Function Audit-Deployment
{

}


Function New-XMLConfig  # Done -JM
{
<#
.SYNOPSIS
Create a new XML monitoring object

.DESCRIPTION
This function will create a new DRMonitoring configuration file.  It is able to accept input through the pipeline or be run on demand to generate a new configuration XML Object.

.EXAMPLE
New-XMLConfig -ComputerName Server01 -IPAddress 192.168.10.1 -MonitorCPU True -MonitorRam True -MonitorDisk True -MonitorNetwork False

.EXAMPLE
Import-csv .\computers.csv | New-XMLConfig | foreach { out-XML -XML $_ -Path "C:\MonitoringFiles\$($_.DRSmonitoring.Server.Name).xml" }

Create unique config.xml files for each server according to the name listed in Computers.csv

Load all 

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.2
Created on: 2/9/2014
Last Modified: 2/15/2014

#>
Param
  (
    # Enter the computername to be monitored
    [Parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('Server')]
    [string]$ComputerName,
        
    # Enter the IP of the Computer to be monitored
    [Parameter(Mandatory,
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('IP')]
    [ipaddress]$IPAddress,
        
    # Set the Value for Monitor CPU
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('CPU')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorCPU,
        
    # Set the Value for Monitor RAM
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('RAM')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorRam,
        
    # Set the Value for Monitor Disk
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('Disk')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorDisk,
        
    # Set the Value for Monitor Network
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('Network')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorNetwork
  )
Begin
{
Write-Verbose "Create XML body"
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
Write-Verbose "Create XML object"
$xml.DRSmonitoring.Server.Name = $ComputerName
Write-Debug "`$computername: $ComputerName"
$xml.DRSmonitoring.Server.IPAddress = "$($IPAddress.IPAddressToString)"
Write-Debug "`$Ipaddress: $($IPAddress.IPAddressToString)"
$xml.DRSmonitoring.Monitoring.MonitorCPU = $MonitorCPU
Write-Debug "`$monitorCPU: $MonitorCPU"
$xml.DRSmonitoring.Monitoring.MonitorRAM = $MonitorRam
Write-Debug "`$MonitorRam: $MonitorRam"
$xml.DRSmonitoring.Monitoring.MonitorDisk = $MonitorDisk
Write-Debug "`$monitorDisk: $MonitorDisk"
$xml.DRSmonitoring.Monitoring.MonitorNetwork = $MonitorNetwork
Write-Debug "`$MonitorNetwork: $MonitorNetwork"
$xml
}
}

Function out-XMLFile # Done -JM
{
<#
.SYNOPSIS
Write an XML object out to disk

.DESCRIPTION
This function will accept in an XML object and output it to disk.  This uses the save method on an XML object to write the file.

.EXAMPLE
$XML | Out-XMLFile -path C:\MonitoringFiles\Server1.xml

.EXAMPLE
Import-csv .\servers.csv | New-XMLConfig | foreach { out-XML -XML $_ -Path "C:\MonitoringFiles\$($_.DRSmonitoring.Server.Name).xml" }

Create unique config.xml files for each server according to the name listed in Computers.csv

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.2
Created on: 2/9/2014
Last Modified: 2/15/2014

.INPUTS
XML

.OUTPUTS
none

#>
Param
  (
    #
    [Parameter(Mandatory,
    ValuefromPipeline)]
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

Function Install-Config # Done -JM
{
<#
.SYNOPSIS
   Deploys XML file for DRSMonitoring.

.DESCRIPTION
   Copies configuration file to target system.  If target directory is missing, function will 
   create the directory.  

   The target path for the file can be specified, but the default is C:\DrsMonitoring

.EXAMPLE
   Install-Config -ComputerName Server1 -path C:\monitoringfiles\Server1.xml

   Deploys XML file to the computer specified by the variable $computername

.EXAMPLE
    Get-childitem c:\monitoringfiles | foreach {Install-config -computername ( ([xml] get-content $_).drsmonitoring.server.name) -Path $_ }

    Deploys the appropriate config.xml file for every server with a config file in C:\Monitoringfiles

.INPUTS
   ComputerName
   Path

.OUTPUTS
   none

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.3
Created on: 2/9/2014
Last Modified: 2/15/2014

#>
param 
  (
    # Enter one or more computer names separated by commas
    [parameter(Mandatory,HelpMessage="Enter one or more computer names separated by commas.")]
    [Alias("MachineName","Server")]
    [String[]]
    $ComputerName,

    # Set Destination directory
    [parameter()]
    $Destination="c:\DrsMonitoring",

    # Enter the name you want the file to take on the target server
    [parameter()]
    [string]$name = "Config.xml",

    # Enter path to target file you want installed
    [Parameter(Mandatory)]
    [ValidateScript({ (Test-path -PathType Leaf -Path $_) -and ( $_.endswith('.xml') ) })]
    $Path 
  )
$target = Join-Path -Path "\\$ComputerName" -ChildPath $($Destination.Replace(':','$'))
Write-Verbose "Checking Target directory"
Write-Debug "`$target: $target"
If (-not(Test-Path $target))
  {
    Write-Verbose "Create Target directory"
    New-Item -Path $target -ItemType directory -Force | Out-Null
  }
Try {
    Write-Verbose "Copying file"
    Copy-item -Path $Path -Destination $target\$name -ErrorAction Stop
    }

Catch [System.IO.DirectoryNotFoundException,Microsoft.PowerShell.Commands.CopyItemCommand]
    {
    Write-error "Wasn't able to copy the file, validate permissions and try again"
    }

}

Function Install-Key # Done -JM
{
<#

.SYNOPSIS
Deploys Registry Key for DRSmonitoring

.DESCRIPTION
Checks for the presence of registry key HKLM:\SOFTWARE\DRSMonitoring with the dWord value of 1 for
Monitoring.  If the object is missing or incorrect, function add or corrects the value

.EXAMPLE
Install-Key -ComputerName $computername

Deploys registry key to the computer specified by the variable $computername

.EXAMPLE
$names = Get-childitem c:\monitoringfiles | foreach {([xml] get-content $_).drsmonitoring.server.name)}
Install-Key -ComputerName $names

Deploys registry settings for every server with a config file in C:\Monitoringfiles

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 2/9/2014
Last Modified: 2/15/2014

#>
[CmdletBinding(ConfirmImpact='Medium')]
param (
      # Enter a computername or multiple computernames
      [Parameter(
      Mandatory=$True, 
      ValueFromPipeline=$True, 
      ValueFromPipelineByPropertyName=$True,
      HelpMessage="Enter a ComputerName or IP Address, accepts multiple ComputerNames")]             
      [Alias("__Server","PSComputerName")]
      [String[]]$ComputerName,

      # Enter a Credential object, like (Get-credential)
      [Parameter(
      HelpMessage="Enter a Credential object, like (Get-credential)")]
      [System.Management.Automation.PSCredential]$credential,

      # The full Registry Key you want created on the target Server
      [string]$Path = 'HKLM:\SOFTWARE\DRSmonitoring',

      # The Name of the property you wish to set
      [String]$Name = "Monitoring",

      # The value you want set for the property
      [String]$Value = 1,

      # Specify the Property type
      [string]$Type = "DWORD"
      )
Begin 
{
  $Params = @{
    ArgumentList = $Path,$Type,$Name,$Value
    Scriptblock = {
        Param ($Path,$Type,$Name,$Value)
        Try {$VerbosePreference = $Using:VerbosePreference} Catch {Write-Verbose "Sending errors to the void!"}
        Switch (Test-path $Path)
          {
            $true {
                Write-Verbose "Test property on registry key"
                Try {
                    Write-Verbose "Get registry value"
                    $monitoring = Get-ItemProperty -path $Path -Name $Name -ErrorAction Stop
                  }
                Catch {
                    Write-Verbose "Unable to locate property on Key: Creating new property"
                    New-ItemProperty -Path $Path -PropertyType $Type -Value $Value -Name $Name
                  }
                If($monitoring -ne 1) 
                  {
                    Write-Verbose "Set Monitoring property value to 1"
                    set-ItemProperty -Path $Path -Value $Value -Name $Name
                  }
              }
            $false {
                write-verbose "Create key"
                Try {New-Item -Path $Path -ErrorAction stop | Out-Null}
                Catch {Throw "Unable to create Key on $ENV:COMPUTERNAME"}
                Write-Verbose "Create Registry Value"
                Try {New-ItemProperty -Path $Path -PropertyType $Type -Value $Value -Name $Name}
                Catch {
                    Write-Error $_.exception.message
                    Write-Warning "Failed to set the Monitoring property on $ENV:COMPUTERNAME, please ensure you manually set the property value before continuing"
                  }
              }
          }
      }
            }
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
                Try {$params.Remove('ComputerName')} Catch {Write-Verbose "Sending errors to the void!"}
                Invoke-Command @params
            }   
    }
}

Function Test-Config # Done -JM
{
<#
.SYNOPSIS
    Compares the local copy of the original config file against the current config file on the remote server

.DESCRIPTION
    This function checks the SHA256 hash value of the local and remote xml configuration file
    If the hash values match, no action is taken, if the hash values differ it will 

.EXAMPLE
    Audit-Config -Target \\Server01\c$\DRSMonitoring\config.xml -Path c:\MonitoringFiles\Server01.xml

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 2/9/2014
Last Modified: 2/15/2014

#>

param (
    # Enter the path to the most current config.xml file
    [parameter(Mandatory)]
    [ValidateScript({(Test-Path $_ -PathType leaf) -and ($_.endswith('.xml'))})]
    [String]$Path,

    # Enter the path to the target XML file to test
    [parameter(Mandatory)]
    [ValidateScript({(Test-Path $_ -PathType Leaf) -and ($_.endswith('.xml'))} )]
    [String]$Target,

    # set this value if you'd like the function to automatically remediate any defferences found
    [switch]$Remediate
        )
Write-Verbose "Chech for variations in config file"
if (Compare-Object -ReferenceObject (Get-FileHash -Path $Target).SHA256 -DifferenceObject (Get-FileHash -Path $Path).SHA256) 
  {
    Switch ($Remediate)
      {
        $true { 
            Write-Verbose "Overwrite config file @ $Target"
            Try {Copy-Item -Path $Path -Destination $Target -Force -ErrorAction Stop}
            Catch {
                Write-Warning "Failed to overwrite $Target"
                $false
              }
          }
        Default {$false}
      }
  }
else {$true}
} 

Function Test-Deployment # Done -JM
{
<#
.SYNOPSIS
   Audits Registry Key and Config file for DRSmonitoring

.DESCRIPTION
   Checks for the presence of registry key HKLM:\SOFTWARE\DRSMonitoring with the dWord value of 1 for
   Monitoring.  The status of the registry key is either correct, incorrect or missing.  Checks for the 
   presence of the monitoring file in the path specified. 

.EXAMPLE
   Test-Deployment -ComputerName $computername

   Checks for registry key and value as well as config file at c:\DRSMonitoring

.EXAMPLE
   Get-childitem c:\monitoringfiles | foreach {Test-Deployment -computername ( ([xml] get-content $_).drsmonitoring.server.name)}

   Tests the deployment state for every computer with a valid config.xml file in c:\monitoringfiles

.INPUTS
   Computer Name and path to config file

.OUTPUTS
   PS Custom Object

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 2/9/2014
Last Modified: 2/12/2014

#>
[CmdletBinding(ConfirmImpact='Medium')]
param (
      # Enter a computername or multiple computernames
      [Parameter(
      Mandatory=$True, 
      ValueFromPipeline=$True, 
      ValueFromPipelineByPropertyName=$True,
      HelpMessage="Enter a ComputerName or IP Address, accepts multiple ComputerNames")]             
      [Alias("__Server")]
      [String[]]$ComputerName,
      # Enter a Credential object, like (Get-credential)
      [Parameter(
      HelpMessage="Enter a Credential object, like (Get-credential)")]
      [System.Management.Automation.PSCredential]$credential
      )
Begin 
  {
    $Params = @{
        Scriptblock = {
            Try {$VerbosePreference = $Using:VerbosePreference} Catch {}
            Write-Verbose "Auditing deployment on $env:COMPUTERNAME"
            $aud = [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                Last_Audit = Get-Date -Format g
                ConfigExists = Test-Path -Path C:\drsmonitoring\config.xml
                MonitoringKeyExists = Test-path -Path HKLM:\SOFTWARE\DRSmonitoring
                MonitoringKeyValue = (Get-ItemProperty -Path HKLM:\SOFTWARE\DRSmonitoring -ErrorAction SilentlyContinue).Monitoring
                MonitoringKeyCorrect = (Get-ItemProperty -Path HKLM:\SOFTWARE\DRSmonitoring -ErrorAction SilentlyContinue).Monitoring -eq 1
                }
            $aud.PSObject.TypeNames.Insert(0,'KittonMittons.Monitoring.State')
            $aud            
          }
        }
    If ($credential) {$Params.Add('Credential',$credential)}
  }
Process
  {
    [System.Collections.ArrayList]$comps += $ComputerName 
  }
End 
  {
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
            Try {$params.Remove('ComputerName')} Catch {Write-Verbose "Sending errors to the void!"}
            Invoke-Command @params
        }   
  }
}

Function Get-FileHash # This is not ours, we took it from Boe Prox's contribution to Technet
{ 
    <#
        .SYNOPSIS
            Calculates the hash on a given file based on the selected hash algorithm.

        .DESCRIPTION
            Calculates the hash on a given file based on the selected hash algorithm. Multiple hashing 
            algorithms can be used with this command.

        .PARAMETER Path
            File or files that will be scanned for hashes.

        .PARAMETER Algorithm
            The type of algorithm that will be used to determine the hash of a file or files.
            Default hash algorithm used is SHA256. More then 1 algorithm type can be used.
            
            Available hash algorithms:

            MD5
            SHA1
            SHA256 (Default)
            SHA384
            SHA512
            RIPEM160

        .NOTES
            Name: Get-FileHash
            Author: Boe Prox
            Created: 18 March 2013
            Modified:

        .OUTPUTS
            System.IO.FileInfo.Hash

        .EXAMPLE
            Get-FileHash -Path Test2.txt
            Path                             SHA256
            ----                             ------
            C:\users\prox\desktop\TEST2.txt 5f8c58306e46b23ef45889494e991d6fc9244e5d78bc093f1712b0ce671acc15      
            
            Description
            -----------
            Displays the SHA256 hash for the text file.   

        .EXAMPLE
            Get-FileHash -Path .\TEST2.txt -Algorithm MD5,SHA256,RIPEMD160 | Format-List
            Path      : C:\users\prox\desktop\TEST2.txt
            MD5       : cb8e60205f5e8cae268af2b47a8e5a13
            SHA256    : 5f8c58306e46b23ef45889494e991d6fc9244e5d78bc093f1712b0ce671acc15
            RIPEMD160 : e64d1fa7b058e607319133b2aa4f69352a3fcbc3

            Description
            -----------
            Displays MD5,SHA256 and RIPEMD160 hashes for the text file.

        .EXAMPLE
            Get-ChildItem -Filter *.exe | Get-FileHash -Algorithm MD5
            Path                               MD5
            ----                               ---
            C:\users\prox\desktop\handle.exe  50c128c5b28237b3a01afbdf0e546245
            C:\users\prox\desktop\PortQry.exe c6ac67f4076ca431acc575912c194245
            C:\users\prox\desktop\procexp.exe b4caa7f3d726120e1b835d52fe358d3f
            C:\users\prox\desktop\Procmon.exe 9c85f494132cc6027762d8ddf1dd5a12
            C:\users\prox\desktop\PsExec.exe  aeee996fd3484f28e5cd85fe26b6bdcd
            C:\users\prox\desktop\pskill.exe  b5891462c9ca5bddfe63d3bae3c14e0b
            C:\users\prox\desktop\Tcpview.exe 485bc6763729511dcfd52ccb008f5c59

            Description
            -----------
            Uses pipeline input from Get-ChildItem to get MD5 hashes of executables.

    #>
    [CmdletBinding()]
    Param(
       [Parameter(Position=0,Mandatory=$true, ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$True)]
       [Alias("PSPath","FullName")]
       [string[]]$Path, 

       [Parameter(Position=1)]
       [ValidateSet("MD5","SHA1","SHA256","SHA384","SHA512","RIPEMD160")]
       [string[]]$Algorithm = "SHA256"
    )
    Process {  
        ForEach ($item in $Path) { 
            $item = (Resolve-Path $item).ProviderPath
            If (-Not ([uri]$item).IsAbsoluteUri) {
                Write-Verbose ("{0} is not a full path, using current directory: {1}" -f $item,$pwd)
                $item = (Join-Path $pwd ($item -replace "\.\\",""))
            }
           If(Test-Path $item -Type Container) {
              Write-Warning ("Cannot calculate hash for directory: {0}" -f $item)
              Return
           }
           $object = New-Object PSObject -Property @{ 
                Path = $item
            }
            #Open the Stream
            $stream = ([IO.StreamReader]$item).BaseStream
            foreach($Type in $Algorithm) {                
                [string]$hash = -join ([Security.Cryptography.HashAlgorithm]::Create( $Type ).ComputeHash( $stream ) | ForEach { "{0:x2}" -f $_ })
                #If multiple algorithms are used, then they will be added to existing object                
                $object = Add-Member -InputObject $Object -MemberType NoteProperty -Name $Type -Value $Hash -PassThru
            }
            $object.pstypenames.insert(0,'System.IO.FileInfo.Hash')
            #Output an object with the hash, algorithm and path
            Write-Output $object

            #Close the stream
            $stream.Close()
        }
    }
}
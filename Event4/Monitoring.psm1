<##>

Function New-XMLConfig
{
<#
.SYNOPSIS
Create a new XML monitoring object

.DESCRIPTION
This function will create a new DRMonitoring configuration file.  It is able to accept input through the pipeline or be run on demand to generate a new configuration XML Object.

.EXAMPLE
New-XMLConfig -ComputerName Server01 -IPAddress 192.168.10.1 -MonitorCPU True -MonitorRam True -MonitorDisk True -MonitorNetwork False

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 2/9/2014
Last Modified: 2/12/2014

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
    [ValidateSet('True','False',$null)]
    [string]$MonitorCPU,
        
    #
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('RAM')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorRam,
        
    #
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('Disk')]
    [ValidateSet('True','False',$null)]
    [string]$MonitorDisk,
        
    #
    [Parameter(
    ValueFromPipeline,
    ValueFromPipelineByPropertyName)]
    [Alias('Network')]
    [ValidateSet('True','False',$null)]
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

Function out-XMLFile
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

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 2/9/2014
Last Modified: 2/12/2014

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


<#
.SYNOPSIS
   Deploys XML file for monitoring file.
.DESCRIPTION
   Copies configuration file to target system.  If target directory is missing, function will 
   create the directory.  

   The target path for the file can be specified, but the default is C:\DrsMonitoring
.EXAMPLE
   .\Deploy-Config -ComputerName $computername

   Deploys XML file to the computer specified by the variable $computername
.INPUTS
   ComputerName
   Path
.OUTPUTS
   none
#>
{
param (
    [parameter(Mandatory,HelpMessage="Enter one or more computer names separated by commas.")]
    [Alias("MachineName","Server")]
    [String[]]
    $ComputerName,

    [parameter(Mandatory)]
    [alias("CN","MachineName")]
    $Path="c:\DrsMonitoring"
)

#Copy file to server, test if copied ok, add error handle if unable to copy or create directory
If (!(Test-Path \\$Name\c$\drsmonitoring){Invoke-Command -ComputerName $Name -ScriptBlock { 
             New-Item -Path $Path -Type directory -Force 
             Write-Host "Folder creation complete"
         }

Try {
    Copy-item $filename -Destination \\$Name\C$\drsmonitoring -ErrorAction Stop
    }

Catch [System.IO.DirectoryNotFoundException,Microsoft.PowerShell.Commands.CopyItemCommand]
    {
    Write-error "Wasn't able to copy the file, check to see if we have rights to copy a file"
    }

}

Function Deploy-Key
{
<#

.SYNOPSIS
Deploys Registry Key for DRSmonitoring

.DESCRIPTION
Checks for the presence of registry key HKLM:\SOFTWARE\DRSMonitoring with the dWord value of 1 for
Monitoring.  If the object is missing or incorrect, function add or corrects the value

.EXAMPLE
Deploy-Key -ComputerName $computername

Deploys registry key to the computer specified by the variable $computername

.EXAMPLE

.NOTES


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
      [System.Management.Automation.PSCredential]$credential
      )
Begin 
{
  $Params = @{
    Scriptblock = {
        Try {$VerbosePreference = $Using:VerbosePreference} Catch {}
        Switch (Test-path 'HKLM:\SOFTWARE\DRSmonitoring')
          {
            $true {
                Write-Verbose "Test property and value registry"
                Try {
                    $monitoring = Get-ItemProperty -path HKLM:\SOFTWARE\DRSMonitoring -Name Monitoring -ErrorAction Stop
                  }
                Catch {
                    New-ItemProperty -Path 'HKLM:\SOFTWARE\DRSMonitoring' -PropertyType Dword -Value 1 -Name Monitoring
                  }
                If($monitoring -ne 1) 
                  {
                    Write-Verbose "Set Monitoring Value"
                    set-ItemProperty -Path 'HKLM:\SOFTWARE\DRSMonitoring' -Value 1 -Name Monitoring
                  }
              }
            $false {
                write-verbose "Create key"
                Try {New-Item -Path 'HKLM:\SOFTWARE\DRSMonitoring' -ErrorAction stop | Out-Null}
                Catch {Throw "Unable to create Key on $ENV:COMPUTERNAME"}
                Write-Verbose "Create Registry Value"
                Try {New-ItemProperty -Path 'HKLM:\SOFTWARE\DRSMonitoring' -PropertyType Dword -Value 1 -Name Monitoring}
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
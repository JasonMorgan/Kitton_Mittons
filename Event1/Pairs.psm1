<#Pairs Module#>
function Get-RandomArray 
{
<#
.SYNOPSIS  
Randomizes an array object

.DESCRIPTION
Accepts array throught the pipeline and randomizes 

.EXAMPLE
$object | Get-RandomArray

.EXAMPLE
$key = ,$key | Get-RandomArray

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/17/2014
Last Modified: 1/25/2014

#>
[cmdletbinding()]
Param 
    (
        [parameter(Mandatory=$true,
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$True,
        HelpMessage="Enter an array object to be randomized")]
        [System.Object[]]$array
    )
process 
    {
        Write-Verbose "Randomizing"
        $array | Get-Random -Count $array.Count
    }
}

#New-Team
function New-Team
{
<#
.SYNOPSIS
Creates pairs from two arrays of names

.DESCRIPTION
Accepts two arrays of objects and outputs a hash table 

.EXAMPLE
New-Team -Key $key -Value $value

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/17/2014
Last Modified: 1/25/2014
#>
[cmdletbinding()]
Param
    (
        [Parameter(Mandatory=$true,
        HelpMessage="Input the key object for the hash table")]
        [System.Object[]]$Key,
        [Parameter(Mandatory=$true,
        HelpMessage="input the value object for the hash table")]
        [System.Object[]]$Value
    )

Write-Verbose "Checking to make sure the number of keys is the same as values"

if ($Key.Count -ne $Value.Count)
    {Throw "The key and value entries are unequal, unable to continue this function"}

$hash = @{}

Write-Verbose "create counter to use while building hashtable"
$i = 0

Write-Verbose "Building hashtable"
$Key | foreach {$hash.Add($_,$Value[$i]) ; $i++}

$hash
}

# Export-History
function Export-History
{
<#
.SYNOPSIS
Saves a record of team pairings

.DESCRIPTION
Exports a CliXML file

.EXAMPLE
Export-History -Hash $hash -Path $path

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/17/2014
Last Modified: 1/25/2014
#>
[CmdletBinding()]
Param
    (
    [Parameter(Mandatory=$true,
    HelpMessage="Input the hashtable object")]
    [system.collections.hashtable]$Hash,

    [Parameter(Mandatory=$true,
    HelpMessage="Input the path for the CliXML file")]
    [string]$Path
    )

Begin{}
Process
    {
    Write-Verbose "Exporting CliXML to $path\Data"
    $Hash | Export-Clixml -Path $Path\Data_$(Get-Date -Format MM_DD_YY).xml
    }
End{}
}

#Import-History
function Import-History
{
<#
.SYNOPSIS 
Import CLiXML files from previous team matches

.DESCRIPTION
Collect all .xml files from directory path, sort by last write time and select the most recent based on the number requested

.EXAMPLE
Import-History -Path $storepath -Count 7


.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/17/2014
Last Modified: 1/25/2014
#>
[CmdletBinding()]
Param
    (
    [parameter(Mandatory=$true,
    HelpMessage="Enter path to CliXML files from previous pair matching"
    [string]$Path,

    [int]$Count=4
    )

Write-Verbose "Collecting $count .xml files from $path"

Get-ChildItem -Directory $Path -Include *.xml | Sort-Object -property LastAccessTime  |  Select-Object -Last $Count | Import-Clixml -Path $Path 

}


#test-history
function Test-History
{
<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/17/2014
Last Modified: 1/25/2014
#>
[cmdletbinding()]
Param 
    (
        [System.Collections.Hashtable]$Pairs,
        [System.Collections.Hashtable[]]$oldpairs
    )
Begin {}
Process 
    {
        Foreach ($o in $oldpairs)
            {
                if ($bad) {break}
                $invert = @{}
                $o.GetEnumerator() | foreach { $invert.add($_.value,$_.key)}
                foreach ($p in $Pairs.GetEnumerator())
                    {
                        If (($p -in $o.GetEnumerator()) -or ($p -in $invert.GetEnumerator()) )
                            {
                                $bad = $true
                                break
                            }
                    }
            }
    }
end 
    {
        if ($bad) {$false}
        else {$true}
    }
}
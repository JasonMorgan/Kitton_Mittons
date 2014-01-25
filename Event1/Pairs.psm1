<#Pairs Module#>
function Get-RandomArray 
{
<#
.SYNOPSIS  
Randomizes an array object

.DESCRIPTION
Accepts array throught the pipeline and randomizes 

.EXAMPLE
Get-RandomArray -Array 1,2,3,4,5

3
4
2
5
1

.EXAMPLE
$key = ,$key | Get-RandomArray

$key is filled with a random order verison of itself

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
        #Enter an array object to be randomized
        [parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        HelpMessage="Enter an array object to be randomized")]
        [System.Object[]]$Array
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
Accepts two arrays of objects and outputs a single hash table 

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
        #Input the key object for the hashtable
        [Parameter(Mandatory=$true,
        HelpMessage="Input the key object for the hashtable")]
        [System.Object[]]$Key,

        #input the value object for the hashtable
        [Parameter(Mandatory=$true,
        HelpMessage="input the value object for the hashtable")]
        [System.Object[]]$Value
    )

Write-Verbose "Checking to make sure the number of keys is equal to the number values"
if ($Key.Count -ne $Value.Count)
    {Throw "The key and value entries are unequal, unable to continue this function"}

Write-Verbose "Creating empty hashtable"
$hash = @{}

Write-Verbose "create counter"
$i = 0

Write-Verbose "Building hashtable"
$Key | foreach {$hash.Add($_,$Value[$i]) ; $i++}

Write-Verbose "Output hashtable"
$hash
}

# Export-History
function Export-History
{
<#
.SYNOPSIS
Saves a record of team pairings

.DESCRIPTION
Exports the record of a set of pairs to the history store.  This data is used for future iterations of the pair function in order to ensure pairings are not repeated

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
    #Accepts a Single Hashtable object
    [Parameter(Mandatory=$true,
    HelpMessage="Input the hashtable object")]
    [system.collections.hashtable]$Hash,
    
    #Input the path for the History store
    [Parameter(Mandatory=$true,
    HelpMessage="Input the path for the History store")]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [string]$Path
    )
Write-Verbose "Exporting history to $path"
$Hash | Export-Clixml -Path $Path\Data_$(Get-Date -Format MM_DD_YY).xml
}

#Import-History
function Import-History
{
<#
.SYNOPSIS 
Import historical data from previous team matches

.DESCRIPTION
Loads history data for the Pairing application, the number of history files loaded is determined by the history length specified in the count parameter.

.EXAMPLE
Import-History -Path $storepath -Count 7

Loads up to 7 instances of the history

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
    #Enter path to history directory from previous pair matchings
    [parameter(Mandatory=$true,
    HelpMessage="Enter path to history directory from previous pair matchings")]
    [string]$Path,
    
    #Specifiy the number of historical records to load
    [int]$Count=4
    )
Write-Verbose "Collecting $count .xml files from $path"
Get-ChildItem -Directory $Path -Include *.xml | Sort-Object -property LastWriteTime  |  Select-Object -Last $Count | Import-Clixml -Path $Path 
}


#test-history
function Test-History
{
<#
.SYNOPSIS
Tests a set of pairs against historical data

.DESCRIPTION
Accepts a test hashtable and compares each of the entries against all the entries in each historical hashtable provided.  The historical pairs are examined in their original form as well as in an inverted form to ensure no duplicate pairings are missed.

.EXAMPLE
Test-History -Pairs $hash -oldpairs $history 

Returns a boolean true or false depending on whether all pairings in $hash are unique when compared against the pairings in $history

.EXAMPLE
Test-History -Pairs @{'Jack'='Jill'} -oldpairs @{'Jill'='Jack'}

False

Because the function compares against the inverse of every hash any combination of jack and jill is detected

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
        #Enter the Hashtable object to be tested
        [parameter(Mandatory=$true,
        HelpMessage="Enter the Hashtable object to be tested")]
        [System.Collections.Hashtable]$Pairs,

        #Enter the Historical Hashtable object, or objects, to be tested against
        [parameter(Mandatory=$true,
        HelpMessage="Enter the Historical Hashtable object, or objects, to be tested against")]
        [System.Collections.Hashtable[]]$Oldpairs
    )
Write-Verbose "Iterating through historical instances"
Foreach ($o in $oldpairs)
    {
        if ($bad) 
            {
                Write-Verbose "Ending loop"
                break
            }
        Write-Verbose "Creating inverted hashtable"
        $invert = @{}
        $o.GetEnumerator() | foreach { $invert.add($_.value,$_.key)}
        Write-Verbose "Iterating through Pairs"
        foreach ($p in $Pairs.GetEnumerator())
            {
                Write-Verbose "Testing against Historical Hashtable and the inverse of the Historical Hashtable"
                If (($p -in $o.GetEnumerator()) -or ($p -in $invert.GetEnumerator()) )
                    {
                        Write-Verbose "Match found"
                        $bad = $true
                        Write-Verbose "Ending loop"
                        break
                    }
            }
    }
if ($bad) {$false}
else {$true}
}
<#Pairs Module#>
function Get-RandomArray 
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
        [Parameter(Mandatory=$true,
        HelpMessage="Input the key object for the hash table")]
        [System.Object[]]$Key,
        [Parameter(Mandatory=$true,
        HelpMessage="input the value object for the hash table")]
        [System.Object[]]$Value
    )
if ($Key.Count -ne $Value.Count)
    {Throw "The key and value entries are unequal, unable to continue this function"}
$hash = @{}
$i = 0
$Key | foreach {$hash.Add($_,$Value[$i]) ; $i++}
$hash
}
# Export-History
function Export-History
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
[CmdletBinding()]
Param
    (
    [system.collections.hashtable]$Hash,
    [string]$Path
    )
Begin{}
Process
    {
    $Hash | Export-Clixml -Path $Path\Data_$(Get-Date -Format MM_DD_YY).xml
    }
End{}
}
#Import-History
function Import-History
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
[CmdletBinding()]
Param
    (
    [string]$Path,
    [int]$Count=4
    )
Get-ChildItem -Directory $Path -Include *.csv | Select-Object -Last $Count | Import-Clixml -Path $Path 
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
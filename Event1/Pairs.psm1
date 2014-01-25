<#Pairs Module#>

function Get-RandomArray 
{
<#

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
Function New-Team
{
<##>
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
# Export-PairData
Function Export-History
{
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
#Import-PairData
Function Import-History
{
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
<##>
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


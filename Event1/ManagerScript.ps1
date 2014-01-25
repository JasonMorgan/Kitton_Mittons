<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.EXAMPLE

.NOTES

#>
<#Script for Manager#>
Param 
    (
        #Add validation
        [string[]]$names = @('Syed', 'Kim', 'Sam', 'Hazem', 'Pilar', 'Terry', 'Amy', 'Greg', 'Pamela', 'Julie', 'David', 'Robert', 'Shai', 'Ann', 'Mason', 'Sharon')
    )
Write-Verbose "Define Functions"
#region DefineFunctions
#Get-RandomArray
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
Write-Verbose "Finished defining functions"
#endregion DefineFunctions

#region split_names
Write-Verbose "Splitting name entries"
$names = ,$names | Get-RandomArray
    if (($names.Count % 2) -ne 0)
        {
            switch (Read-Host "Uneven numbers of entries found:
Y - Select Y to have a pair automatically assigned 
N - select N to abort the operation 
V - Select V to view a list of users and select the users to be grouped together
U - Select U to manually assign an individual to be paired with two users
Select Y, N, V, or U"
                )
                {
                    'Y' {
                            Write-Verbose "Auto assign 3 person team"
                            $odd = $true
                            $lead = $names | Get-Random -Count 1
                            $names = ($names | where {$_ -notin $lead})
                            Write-Verbose "The lead in the 3 person team is $lead"
                        }
                    'N' {Throw "Operation aborted by $env:USERNAME"}
                    'V' { 
                            $pair = $names | Out-GridView -OutputMode Multiple -Title "Please select 2 names from the following list, then click 'Ok'"
                            if ($pair.count -ne 2) { Throw "You must select 2 names to be paired"} 
                            $names = ($names | where {$_ -notin $pair})
                            $names += ,$pair
                        }
                    'U' {
                            Write-Verbose "Manually select leader of 3 person team"
                            $lead = $names | Out-GridView -OutputMode Single -Title "Please select the individual who will be paired with a two users then click 'Ok'"
                            $names = ($names | where {$_ -notin $lead})
                            $odd = $true
                            Write-Verbose "The lead in the 3 person team is $lead"
                        }
                    default {Throw "Operation aborted by $env:USERNAME"}    
                }
        }
    $key = @()
    $value = @()
    if ($odd)
        {
            Write-Verbose "Splitting off double partner from `$names"
            $double = $names | Get-Random -Count 2
            $names = ($names | where {$_ -notin $pair})
        }
    Write-verbose "Splitting name array into new arrays"
    Foreach ($n in $names)
        {
            if ($key.Count -lt ($names.Count/2)) 
                {
                    Write-Verbose "Adding $n to `$key array"
                    $key += $n
                }
            else 
                {
                    Write-Verbose "Adding $n to `$value array"
                    $value += $n 
                }
        }
Write-Verbose "Done Splitting names"
#endregion split_names
#region Randomize and assign
Write-Verbose "Randomize `$key"
$key = ,$key | Get-RandomArray
Write-Verbose "Randomize `$value"
$value = ,$value | Get-RandomArray
Write-Verbose "Creating pairs"
$hash = New-Team -Key $key -Value $value
if ($odd)
    {
        Write-Verbose "Add special pair to teams"
        $hash.add($lead,$double)
    }
#endregion Randomize and assign
Write-Verbose "Display content"
$hash.GetEnumerator() | foreach {"$($_.Key),$($_.Value)"}
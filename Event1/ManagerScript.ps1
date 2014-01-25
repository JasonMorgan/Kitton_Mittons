<#
.SYNOPSIS
Converts a list of names into a randomized set of pairs.  Can support an uneven number of names.

.DESCRIPTION
Accepts a variable number of names, at least 2, and splits them into a random set of pairs.  

.EXAMPLE
.\ManagerScript.ps1 

Sample results:
Syed,Shai
Robert,Terry
Pamela,David
Mason,Amy
Hazem,Kim
Greg,Julie
Sharon,Ann
Pilar,Sam

.EXAMPLE
.\ManagerScript.ps1 -names $names

Outputs a random pairing of of the names in the $names variable.

.EXAMPLE
.\ManagerScript.ps1 -names Jane,Jill,John,Edward,Sam,William

John,Edward
Sam,Jane
Jill,William

.EXAMPLE
.\ManagerScript.ps1 -names (get-content .\names.txt)

Outputs a random pairing of the names from the names.txt file

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
        #Names to be split into random pairs, at least 2 names required
        [Parameter()]
        [ValidateCount(2,999999)]
        [string[]]$names = @('Syed', 'Kim', 'Sam', 'Hazem', 'Pilar', 'Terry', 'Amy', 'Greg', 'Pamela', 'Julie', 'David', 'Robert', 'Shai', 'Ann', 'Mason', 'Sharon')
    )

#region ImportModule
Write-Verbose "Importing Pairs module"
Try {Import-Module Pairs -ErrorAction Stop} 
Catch {Throw "Unable to load pairs module, please ensure that the Pairs.psm1 file is loaded in your `$env:PSModulePath"}
#endregion ImportModule

#region split_names
Write-Verbose "Splitting name entries"
$names = ,$names | Get-RandomArray
if (($names.Count % 2) -ne 0)
    {
        switch (Read-Host "Uneven numbers of entries found:
Y - Select Y to have a pair automatically assigned 
N - select N to abort the operation 
V - Select V to view a list of users and select the users to be grouped together
M - Select M to manually assign an individual to be paired with two users
Select Y, N, V, or M"
            )
            {
                'Y' {
                        Write-Verbose "Auto assign 3 person team"
                        Write-Verbose "Set `$odd flag"
                        $odd = $true
                        Write-Verbose "Selecting `$lead"
                        $lead = $names | Get-Random -Count 1
                        Write-Verbose "Rebuiling `$names without `$lead"
                        $names = ($names | where {$_ -notin $lead})
                        Write-Verbose "The lead in the 3 person team is $lead"
                    }
                'N' {Throw "Operation aborted by $env:USERNAME"}
                'V' { 
                        Write-Verbose "Sending names to $env:USERNAME for selection, new variable `$pair to be created"
                        $pair = $names | Out-GridView -OutputMode Multiple -Title "Please select 2 names from the following list, then click 'Ok'"
                        Write-Verbose "Testing `$pair count"
                        if ($pair.count -ne 2) { Throw "You must select 2 names to be paired"} 
                        Write-Verbose "Rebuiling `$names without `$Pair"
                        $names = ($names | where {$_ -notin $pair})
                        Write-Verbose "Adding `$pair to `$names as a single entry"
                        $names += ,$pair
                    }
                'M' {
                        Write-Verbose "Manually select leader of 3 person team"
                        $lead = $names | Out-GridView -OutputMode Single -Title "Please select the individual who will be paired with a two users then click 'Ok'"
                        Write-Verbose "Rebuiling `$names without `$lead"
                        $names = ($names | where {$_ -notin $lead})
                        Write-Verbose "Set `$odd flag"
                        $odd = $true
                        Write-Verbose "The lead in the 3 person team is $lead"
                    }
                default {Throw "Operation aborted due to invalid selection"}    
            }
    }
Write-Verbose "Building empty arrays"
$key = @()
$value = @()
    if ($odd)
        {
            Write-Verbose "Splitting off double partner from `$names"
            $double = $names | Get-Random -Count 2
            Write-Verbose "Rebuiling `$names without `$double"
            $names = ($names | where {$_ -notin $double})
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
Try {$hash = New-Team -Key $key -Value $value -ErrorAction Stop}
Catch {
        Write-Warning "Creating the pairs failed, the operation will be aborted"
        Throw "Unable to build hashtable, please ensure you don't have any duplicate names in your input"
    }
if ($odd)
    {
        Write-Verbose "Add special pair to teams"
        Try {$hash.add($lead,$double)}
        Catch {
                Write-Warning "Creating the pairs failed, the operation will be aborted"
                Throw "Unable to build hashtable, please ensure you don't have any duplicate names"
            }
    }
#endregion Randomize and assign

#region Display
Write-Verbose "Display content"
$hash.GetEnumerator() | foreach {"$($_.Key),$($_.Value)"}
#endregion Display
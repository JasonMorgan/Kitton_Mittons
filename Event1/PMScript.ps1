<#

.SYNOPSIS  This script creates random name pair assignments with the option of identifying a primary person for a pair

.DESCRIPTION   
Accepts a variable number of names, at least 2, and splits them into a random set of pairs. 

.EXAMPLE 
.\PMScript.ps1 -path c:\Project\developers.csv 

.EXAMPLE
.\PMScript.ps1 -path c:\Project\developers.csv 

.EXAMPLE
.\PMScript.ps1 -path c:\Project\developers.csv -Store True  -Notify True -

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/17/2014
Last Modified: 1/25/2014


#>
<#Script for PM#>
Param 
    (
        # Add Validation

        # file path to .csv file containing names to be paired
        [Parameter(Mandatory=$true,)
        [string]$Path = "$env:USERPROFILE\Documents\Names.csv",

        # path to directory that stores the CliXML files to track historic team results
        [parameter()]
        [string]$StorePath = "$env:USERPROFILE\Documents\AssignTeams",

        # True False to determine if script will run for the Project Manager
        [parameter()]
        [bool]$store = $true,
        
        # True False to determine if email will be sent to team particpants
        [parameter()]
        [switch]$Notify,

        # Project Manager email address
        [parameter()]
        [string]$PMEmail = "PM@somecorp.com",

        # 
        [int]$count = 4
    )
#####
If (-not(Test-Path $path))
    {
        Write-Verbose "Create storage directory"
        New-Item $path -ItemType directory -Force | Out-Null
    }



Write-Verbose "Finished defining functions"


$names = Import-Csv -Path $Path
#region split_names
Write-Verbose "Splitting name entries"
$names = ,$names | Get-RandomArray | Sort -Property Principal
if (($names.Count % 2) -ne 0)
    {
        switch (Read-Host "Uneven numbers of entries found:
Y - Select Y to have a pair automatically assigned 
N - select N to abort the operation 
V - Select V to view a list of users and select the users to be grouped together
M - Select U to manually assign an individual to be paired with two users
Select Y, N, V, or M"
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
                'M' {
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
$History = Import-PairData -Path $storepath
$i = 0
do 
    {
        Write-Verbose "Randomize `$key"
        $key = ,$key | Get-RandomArray
        Write-Verbose "Randomize `$value"
        $value = ,$value | Get-RandomArray
        Write-Verbose "Creating pairs"
        $hash = New-Team -Key $key -Value $value
        $i++
    }
Until (Test-History -Pairs $hash -oldpairs $History) 
Write-Verbose "had to randomize $i times"
if ($odd)
    {
        Write-Verbose "Add special pair to teams"
        $hash.add($lead,$double)
    }
#endregion Randomize and assign
if ($store)
    {
        Export-PairData -Hash $hash -Path $path
    }
if ($Notify)
    {
        $hash.GetEnumerator() | foreach {
                Email-Team -name @($_.Key.name, $_.Value.name) -EmailAddress @($_.Key.email, $_.Value.email) -PMAddress $PMEmail
            }
    }
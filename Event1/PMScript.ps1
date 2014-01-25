<#

.SYNOPSIS  
This script creates random name pair assignments with the option of identifying a primary person for a pair

.DESCRIPTION   
Accepts a variable number of names, at least 2, and splits them into a random set of pairs. 

.EXAMPLE 
.\PMScript.ps1 -path c:\Project\developers.csv 

.EXAMPLE
.\PMScript.ps1 -path c:\Project\developers.csv 

.EXAMPLE
.\PMScript.ps1 -path c:\Project\developers.csv -Notify 

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/17/2014
Last Modified: 1/25/2014


#>
[cmdletbinding(DefaultParameterSetName="Default")]
Param ## Add aditional parameter set
    (
        # Please enter the path to a .csv file containing names to be paired
        [Parameter(Mandatory=$true,
        HelpMessage='Please enter the path to a .csv file containing names to be paired',
        ParameterSetName="Default")]
        [Parameter(Mandatory=$true,
        HelpMessage='Please enter the path to a .csv file containing names to be paired',
        ParameterSetName="notify")]
        [ValidateScript({(Test-Path $_ -PathType leaf) -and ($_.endswith('.csv'))})]
        [string]$Path,

        # path to the stored history directory
        [parameter(ParameterSetName="Default")]
        [parameter(ParameterSetName="Email")]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$StorePath = "$env:USERPROFILE\Documents\AssignTeams",

        # Indicate if historical data should be recorded for this iteration
        [parameter(ParameterSetName="Default")]
        [parameter(ParameterSetName="Email")]
        [bool]$store = $true,
        
        # Set if you wish particapants to be notified of their pairings
        [parameter(ParameterSetName="Email")]
        [switch]$Notify,

        # Email address for the PM, use if sending notifications
        [parameter(ParameterSetName="Email")]
        [string]$PMEmail = "PM@somecorp.com",

        # Set to indicate the number of historical runs to compare against the current pairings
        [parameter(ParameterSetName="Default")]
        [parameter(ParameterSetName="Email")]
        [int]$count = 4,

        # Specify the SMPTServer information
        [parameter(Mandatory=$true,
        ParameterSetName="Email",
        HelpMessage="Please specify the SMTP Server to be used for the email notification.  If you are unsure what SMTP server to use please contact the helpdesk at (877) 555-HELP")]
        [string]$SMTPServer 
    )
#region ImportModule
Write-Verbose "Importing Pairs module"
Try {Import-Module Pairs -ErrorAction Stop} 
Catch {Throw "Unable to load pairs module, please ensure that the Pairs.psm1 file is loaded in your `$env:PSModulePath"}
#endregion ImportModule

#region CreateNames
### Insert a test to ensure CSV data looks correct 
$names = Import-Csv -Path $Path
#endregion CreateNames

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
Write-Verbose "Importing History"
$History = Import-History -Path $storepath -Count $count
Write-Verbose "Set counter"
$i = 0
Write-Verbose "Begin History Loop"
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

#region StoreHistory
if ($store)
    {
        Write-Verbose "Storing historical data"
        Export-History -Hash $hash -Path $path
    }
#endregion StoreHistory

#region Notify
if ($Notify)
    {
        Write-Verbose "Sending notification"
        Write-Verbose
        $hash.GetEnumerator() | foreach {
                $body = @"
Hello,
The following people have now been assigned to a development team:
$(@($_.key.name,$_.value.name ) | ForEach-Object {$_+"`n"})
Your team members email addresses are all listed in the to block of this message

"@
                $emailparams =@{
                        To= @($_.key.email,$_.value.email)
                        Bcc = $PMEmail
                        From= $PMEmail
                        Subject="Project Pairings"
                        Body = $body
                        SMTPServer = $SMTPServer
                    }
                Send-MailMessage @emailparams
            }
    }
#endregion Notify

#region output
Write-Verbose "Output results as a single Hashtable"
$hash
#endregion output
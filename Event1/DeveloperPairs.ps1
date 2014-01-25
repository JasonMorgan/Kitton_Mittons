<#
.SYNOPSIS  
This script creates random name pair assignments with the option of identifying a primary person for a pair

.DESCRIPTION   
Accepts a variable number of names, at least 2, and splits them into a random set of pairs. 

.EXAMPLE 
.\PMScript.ps1 -path c:\Project\developers.csv 

Outputs team data

.EXAMPLE
.\PMScript.ps1 -path c:\Project\developers.csv | tee-object -variable Teams

Outputs pair data as text and stores the team data in a variable called $Teams

.EXAMPLE
.\PMScript.ps1 -path c:\Project\developers.csv -Notify -PMEmail PM@company.com -SMTPServer Email.Company.com

Outputs team data and sends ntoifications to all team members with their new assignments

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/17/2014
Last Modified: 1/25/2014

#>
[cmdletbinding(DefaultParameterSetName="Default")]
Param
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
        [string]$StorePath = "$env:USERPROFILE\Documents\Pairs\Store",

        # Indicate if historical data should be recorded for this iteration
        [parameter(ParameterSetName="Default")]
        [parameter(ParameterSetName="Email")]
        [bool]$store = $true,
        
        # Set if you wish particapants to be notified of their pairings
        [parameter(ParameterSetName="Email")]
        [switch]$Notify,

        # Email address for the PM, use if sending notifications
        [parameter(Mandatory=$true,
        ParameterSetName="Email")]
        [string]$PMEmail,

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
If (compare -ReferenceObject (Get-Content -TotalCount 1 -Path $Path).Split(',') -DifferenceObject @("Name","Email","Primary"))
    {
        Throw "The CSV file specificied to -Path was invalid.  Please review the Readme.txt file in order to view the approved header names and values for your csv file"
    }
Try {$data = Import-Csv -Path $Path -ErrorAction Stop}
Catch {
        Write-Warning "Unable to Import $Path"
        Throw "Aborting Script Execution"
    }
#endregion CreateNames

#region split_names
Write-Verbose "Splitting name entries"
$names = ,$data | Get-RandomArray | Sort -Property Principal | select -ExpandProperty name
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
Write-Verbose "Importing History"
$History = Import-History -Path $storepath -Count $count
Write-Verbose "Set counter"
$i = 0
Write-Verbose "Begin History Loop"
if ($History)
    {
        do 
            {
                Write-Verbose "Randomize `$key"
                $key = ,$key | Get-RandomArray
                Write-Verbose "Randomize `$value"
                $value = ,$value | Get-RandomArray
                Write-Verbose "Creating pairs"
                Try {$hash = New-Team -Key $key -Value $value -ErrorAction Stop}
                Catch {
                        Write-Warning "Creating the pairs failed, the operation will be aborted"
                        Throw "Unable to build hashtable, please ensure you don't have any duplicate names in your input file"
                    }
                $i++
            }
        Until (Test-History -Pairs $hash -oldpairs $History) 
    }
Else
    {
        Write-Verbose "Randomize `$key"
        $key = ,$key | Get-RandomArray
        Write-Verbose "Randomize `$value"
        $value = ,$value | Get-RandomArray
        Write-Verbose "Creating pairs"
        Try {$hash = New-Team -Key $key -Value $value -ErrorAction Stop}
        Catch {
                Write-Warning "Creating the pairs failed, the operation will be aborted"
                Throw "Unable to build hashtable, please ensure you don't have any duplicate names in your input file"
            }
        $i++
    }
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
        try {Export-History -Hash $hash -Path $StorePath -ErrorAction stop}
        Catch {
                Write-Warning "Unable to export historical data, please contact the helpdesk in order to generate a support ticket for this application"
                Write-Error "Historical data was not saved for this iteration"
            }
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
$(@($_.key,$_.value ) | ForEach-Object {$_+"`n"})
Your team members email addresses are all listed in the to block of this message

"@
                $emailparams =@{
                        To= $($data | where {$_.name -in @($_.key,$_.value)} | select -ExpandProperty email)
                        Bcc = $PMEmail
                        From= $PMEmail
                        Subject="Project Pairings"
                        Body = $body
                        SMTPServer = $SMTPServer
                    }
                Try {Send-MailMessage @emailparams -ErrorAction Stop}
                catch {
                        Write-Warning "Unable to send message to $($_.key,$_.value), please ensure to do manual notifications for this team" 
                        Write-Error $_.exception.message
                    }
            }
    }
#endregion Notify

#region Display
Write-Verbose "Display content"
$hash.GetEnumerator() | foreach {"$($_.Key),$($_.Value)"}
#endregion Display
<##>
<#Script for PM#>
Param 
    (
        [string]$namesfile = "$env:USERPROFILE\Documents\Names.csv",
        [string]$path = "$env:USERPROFILE\Documents\AssignTeams",
        [bool]$store = $true,
        [switch]$Notify,
        [string]$PMEmail = "PM@somecorp.com"
    )
Begin 
    {
        If (-not(Test-Path $path))
            {
                Write-Verbose "Create storage directory"
                New-Item $path -ItemType directory -Force | Out-Null
            }
        Write-Verbose "Define Functions"
#split-name
function Split-Name
{
<#
.INPUTS
Single Array

.OUTPUTS
two Arrays

#>
[cmdletbinding()]
Param 
    (
        [System.Object[]]$names
    )
Begin {}
Process 
    {
        $names = Get-RandomArray -array $names # add | sort by primary so primaries always come first
        ### Reusing get-randomarray to really break up the order We'll need to ensure we use a module file or defined all functions first
        $count = $names.Count
        if (($count % 2) -ne 0)
            {
                switch (Read-Host "Uneven numbers of entries found:
Y - Select Y to have pair automatically assigned 
N - select N to abort the operation 
V - Select V to view a list of users and select the users to be grouped together
Select Y, N, or V"
                    )
                    {
                        'Y' {$odd = $true}
                        'N' {Throw "Operation aborted by $env:USERNAME"}
                        'V' { 
                                $pair = $names | Out-GridView -OutputMode Multiple -Title "Please select 2 names from the following list, then click 'Ok'"
                                if ($pair.count -ne 2) { Throw "You may only select 2 names to be paired"} 
                                $names = ($names | where {$_ -notin $pair})
                                $names += ,$pair
                            }
                        default {break}    
                    }
            }
        $a = @()
        $b = @()
        if ($odd) { $double = @() }
        Foreach ($n in $names)
            {
                
                if ($n.primary) {$a += $n}
                if ($a.Count -lt ([int]($count/2))) {$a += $n}
                else 
                    {
                       $b += $n 
                    }
            }
    }
End 
    {
        if ($odd)
            {
                $pair = $b | Get-Random -Count 2
                $b = ($b | where {$_ -notin $pair})
                $b += ,$pair
            }
        $a,$b
    }
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
#Get-RandomArray
function Get-RandomArray 
{
<#

#>
[cmdletbinding()]
Param 
    (
        [System.Object[]]$array
    )
process 
    {
        $array | Get-Random -Count $array.Count
    }
}
#New-Team
Function New-Team
{
Param
    (
        [System.Object[]]$Keys,
        [System.Object[]]$Values
    )
Begin {}
Process 
    {
        $hash = @{}
        $i = 0
        $Keys | foreach {$hash.Add($_,$Values[$i]) ; $i++}
    }
End
    {
        $hash
    }
}
#Email-Team
function Email-Team
{
<#
.Synopsis
   This emails the Employees.
.DESCRIPTION
   This will inform the employess of what team they are on and what teammebers they will be working with.
.EXAMPLE
   Email-team
#>
    [CmdletBinding()]
    Param
    (
        #param 1 Names of the recipants.
        [string[]]$name,
        #param 2 Email of the names
        [string[]]$EmailAddress,
        #param 3 Email of Supervisor
        [string[]]$from = "something@somewhere.com",
        #param 4 Subjeft of the email
        [string[]]$subject = 'something',
        #
        [string]$PMAddress = "PM@company.com"
    )

 Begin{}
Process
    {
        $body = @"
Hello,
The following people are now on the same team:
 
    $($name | ForEach-Object {$_+"`n"})
All the above have been sent a copy of this email.
"@
        $emailparams = @{
                To = $EmailAddress,$PMAddress
                From = $from
                SMTPServer = $SMTPServer
                Subject = $subject
                Body = $body
            }
        Send-MailMessage @emailparams
    }
End{}
}
#Create-NameObject
function Create-NameObject
{
<#
.Synopsis
   Imports CSV file
.DESCRIPTION
   Inputs .csv file
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   .csv filepath
.OUTPUTS
   array to include fullname, email, and and Priority Partner Status

#>
    [CmdletBinding()]
    Param
    (
        #Path to .csv file
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0
                   )]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$path

    )

    Begin
    {
    }
    Process
    {
    Write-Verbose "Test file path"
        do
        {
         if(Test-Path $path)
            {$validatefile = $true}
         else 
            {
            $validatefile = $false
            $path = Read-Host "$path is not valid, Please enter valid file name"
            }
         } 
        until ($validatefile -eq $true)

       $users =  Import-csv $path 
       $users 
    }
    End
    {
    }
}
# Export-PairData
Function Export-PairData
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
Function Import-PairData
{
[CmdletBinding()]
Param
    (
    [string]$Path,
    [string]$Count=4
    )
Begin{}
Process
    {
    Get-ChildItem -Directory $Path | Select-Object -Last $Count | Import-Clixml -Path $Path 
    }
End{}
}
Write-Verbose "Finished defining functions"
    }
Process
    {
        $names = Create-NameObject -path $namesfile
        $key,$value = Split-Name -names $names
        $History = Import-PairData -Path $path
        $hash = @{}
        $i = 0
        do 
            {
                $key = Get-RandomArray -array $key
                $value = Get-RandomArray -array $value
                $hash = New-Team -Keys $key -Values $value
                $i++
                Write-Warning "had to run $i times"
            }
        Until (Test-History -Pairs $hash -oldpairs $History) ### this loop probably isn't required for this draft.  It's mostly in to test logic
    }
End 
    {
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
    }
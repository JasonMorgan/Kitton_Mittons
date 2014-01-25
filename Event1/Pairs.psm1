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


###
Lines from ManagerScript
#region DefineFunctions ### This will be replaced with import-module
Write-Verbose "Define Functions"
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

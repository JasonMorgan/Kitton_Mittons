function New-NameObject
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

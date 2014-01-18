<#
.Synopsis
   This emails the Employees.
.DESCRIPTION
   This will inform the employess of what team they are on and what teammebers they will be working with.
.EXAMPLE
   Email-teams
#>
function Email-Teams
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        #param 1 Names of the recipants.
        [string[]]$names,
        #param 2 Email of the names
        [string[]]$emails,
        #param 3 Email of Supervisor
        [string[]]$from = "something@somewhere.com",
        #param 4 Subjeft of the email
        [string[]]$subject = 'something'
    )

 Begin{}
 Process
{
    $emailparams = @{
    To = $Emails
    From = $from
    SMTPServer = $SMTPServer
    Subject = $subject
                   }
$body = @"
Hello,
The following people are now on the same team:
 
 $($names|ForEach-Object{$_+"`n"})
All the above have been sent a copy of this email.
"@
}
End{}
}

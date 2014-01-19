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
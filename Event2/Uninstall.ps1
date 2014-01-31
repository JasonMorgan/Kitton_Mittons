<#

.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.NOTES


#>
Param
    (
        [String]$Path = "$env:ProgramFiles\Security Audit",
        [string]$ModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\SecAudit"
    )
Remove-Item $Path -Recurse
Remove-Item $ModulePath -Recurse
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

if (-not(Test-path $Path))
    {
        New-Item -ItemType directory -Path $Path -Force | Out-Null
    }
if (-not(Test-path $ModulePath))
    {
        New-Item -ItemType directory -Path $ModulePath -Force | Out-Null
    }
$root = Split-Path $($MyInvocation.MyCommand.path)
Copy-Item -Path $root\SecAudit.psm1 -Destination $ModulePath -Force
Copy-Item -Path $root\SecAudit.ps1 -Destination $Path -Force
Copy-Item -Path $root\Key.xml -Destination $Path -Force
New-Item -ItemType file -Path $Path\Config.xml -Force | Out-Null
New-Item -ItemType Directory -Path $Path\Extensions | Out-Null
Copy-Item -Path $root\Extensions\* -Destination $Path\Extensions
Import-Module $ModulePath\SecAudit.psm1
Get-ChildItem -Path $Path\Extensions | Register-Extension -force 
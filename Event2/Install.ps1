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
Copy-Item -Path .\SecAudit.psm1 -Destination $ModulePath -Force
Copy-Item -Path .\SecAudit.ps1 -Destination $Path -Force
Copy-Item -Path .\Key.xml -Destination $Path -Force
New-Item -ItemType file -Path $Path\Config.xml -Force | Out-Null
New-Item -ItemType Directory -Path $Path\Extensions | Out-Null
Copy-Item -Path .\Extensions\* -Destination $Path\Extensions
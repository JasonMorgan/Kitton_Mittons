<#
.SYNOPSYS
Install script

.DESCRIPTION
Adds the Create Pairs tool from the current computer

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1
Created on: 1/25/2014
Last Modified: 1/25/2014

#>
Param
    (
        $path = "$env:USERPROFILE\Documents\Pairs"
    )
New-Item -ItemType directory -Path $path\store -Force | Out-Null
Copy-Item -Path .\SecretSanta.ps1,.\DeveloperPairs.ps1 -Destination $path -Force
New-Item -ItemType directory -Path $env:USERPROFILE\WindowsPowerShell\Modules\Pairs -Force
copy -path .\Pairs.psm1 -Destination $env:USERPROFILE\WindowsPowerShell\Modules\Pairs -Force
exit $LASTEXITCODE
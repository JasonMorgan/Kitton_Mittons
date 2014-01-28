<#

.SYNOPSIS
Registers extension scripts

.DESCRIPTION
Able to read header modules of properly formatted extension scripts.  Can also be used interactively to create new extension jobs for the Security Audit tool.

.EXAMPLE

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 1/26/2014
Last Modified: 1/26/2014

#>
[cmdletbinding(DefaultParameterSet="Default")]
Param 
    (
        # Specify the path to the extension file, this will not accept relative paths
        [Parameter(Mandatory=$true,
        ParameterSetName="Default")]
        [validateScript({[System.IO.Path]::IsPathRooted($_)})]
        [Alias("Fullname")]
        [string]$Path,

        #
        [Parameter(Mandatory=$true,
        ParameterSetName="job")]
        [string]$Name,
        
        #
        [Parameter(Mandatory=$true,
        ParameterSetName="job")]
        [string]$Scriptblock,
        
        #
        [Parameter(Mandatory=$true,
        ParameterSetName="job")]
        [string]$Title,
        
        #
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="job")]
        [string]$installroot = "C:\ProgramData\SecAudit"
    )
$default = {
        . $Path -register
        $job = New-Object -TypeName PSObject -Property @{ 
                Name = $Name  
                Title = $Title
                Format = $format
            }
        Try
            {
                Register-ScheduledJob -Name $Name -ScriptBlock {$Path}
            }
        Catch {}
        (Import-Clixml ) + $job | Export-Clixml
        
    }
switch ($PSCmdlet.ParameterSetName)
    {
        Default {}
        Job {}
    }
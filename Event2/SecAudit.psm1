
Function Register-Extension
{
<#

.SYNOPSIS
Registers extension scripts

.DESCRIPTION
Able to read header modules of properly formatted extension scripts.  Can also be used interactively to create new extension jobs for the Security Audit tool.

.EXAMPLE
Register-Extension -Path "C:\Program Files\Security Audit\Extensions\FileHash.ps1"

Reads the filehash script and attempts to register it as part of the Security Audit tool

.EXAMPLE
Register-Extension -Name TestKey -Title "Test key data" -Scriptblock {get-item HKLM:\Software\Testkey} -Format list

Creates a new Extension job with the specified Name, Title, Formatting, and Scriptblock

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 1/26/2014
Last Modified: 1/31/2014

#>
[cmdletbinding(DefaultParameterSet="Default")]
Param 
    (
        # Specify the path to the extension file, this will not accept relative paths
        [Parameter(Mandatory=$true,
        ParameterSetName="Default",
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [validateScript({[System.IO.Path]::IsPathRooted($_)})]
        [Alias("Fullname")]
        [string]$Path,

        # Enter the name of the Job
        [Parameter(Mandatory=$true,
        ParameterSetName="job")]
        [string]$Name,
        
        # Enter the scriptblock to be run as part of the job
        [Parameter(Mandatory=$true,
        ParameterSetName="job")]
        [scriptblock]$Scriptblock,
        
        # Enter the title for the extension, this title will be used in the audit report
        [Parameter(Mandatory=$true,
        ParameterSetName="job")]
        [string]$Title,
        
        # Specify the format for the data when added to the report
        [Parameter(Mandatory=$true,
        ParameterSetName="job")]
        [ValidateSet("List","Table")]
        [string]$Format,

        # List the path to the root folder for the SecAudit tool
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="job")]
        [string]$Installroot = "$env:ProgramFiles\Security Audit",

        # Use force to overwrite existing extensions
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="job")]
        [switch]$Force
    )
Begin 
    {
        if (-not (Test-Path $installroot\config.xml))
            {
                Write-Warning "Unable to locate the Security Audit configuration file, config.xml, please verify your install and try again"
                Throw "Operation aborted, install directoy not found at: $installroot"
            }
    }
Process 
    {
        #region BuildScriptBlocks

        $default = {
                Write-Verbose "Reading Extension Header"
                . $Path -register
                $scriptblock = [scriptblock]::Create($(Get-Content $Path | Out-String))
                Try
                    {
                        Write-Verbose "Registering Job: $Name"
                        Register-ScheduledJob -Name $Name -ScriptBlock $scriptblock -MaxResultCount 1 -ErrorAction Stop
                    }
                Catch 
                    {
                        if ((Get-Job -Name $Name ) -and ($Force))
                            {
                                Remove-Job -Name $Name -Force
                                Write-Verbose "Registering Job: $Name"
                                Try 
                                    {
                                        Register-ScheduledJob -Name $Name -ScriptBlock $scriptblock -MaxResultCount 1 -ErrorAction Stop
                                    }
                                catch
                                    {
                                        Write-Warning $_.exception.message
                                        Throw "Unable to register $Name"
                                    }
                            }
                        Else
                            {
                                Write-Warning $_.exception.message
                                Throw "Unable to register $Name"
                            }
                    }       
            }

        $job = {
                Try 
                    {
                        Write-Verbose "Registering Job: $Name"
                        Register-ScheduledJob -Name $Name -ScriptBlock $Scriptblock -MaxResultCount 1
                    }
                Catch 
                    {
                        if ((Get-Job -Name $Name ) -and ($Force))
                            {
                                Remove-Job -Name $Name -Force
                                Write-Verbose "Registering Job: $Name"
                                Try 
                                    {
                                        Register-ScheduledJob -Name $Name -ScriptBlock $Scriptblock -MaxResultCount 1 -ErrorAction Stop
                                    }
                                catch
                                    {
                                        Write-Warning $_.exception.message
                                        Throw "Unable to register $Name"
                                    }
                            }
                        Else
                            {
                                Write-Warning $_.exception.message
                                Throw "Unable to register $Name"
                            }
                    }       
                
            }

        #endregion BuildScriptBlocks
        
        #region Execution

        Write-Verbose "Registering Extension Job"
        switch ($PSCmdlet.ParameterSetName)
            {
                Default {Invoke-Command -ScriptBlock $default}
                Job {Invoke-Command -ScriptBlock $job}
            }
        Write-Verbose "Creating job configuration object"
        $job = New-Object -TypeName PSObject -Property @{ 
                        Name = $Name  
                        Title = $Title
                        Format = $format
                    }
        Write-Verbose "Loading Security Audit configuration file"
        [System.Collections.ArrayList]$jobs = Import-Clixml -Path $installroot\Config.xml
        if ($Force)
            {
                if ($jobs.name -contains $job.name)
                    {
                        Write-Verbose "Removing old extension: $($job.name)"
                        Try {$jobs.Remove($job)} # test this!!!
                        Catch {Throw "Not Working yet"}
                    }
            }
        Write-Verbose "Updating Security Audit configuration file"
        $jobs + $job | Export-Clixml -Path $installroot\Config.xml

        #endregion Execution
    }
}

Function Remove-Extension
{

}
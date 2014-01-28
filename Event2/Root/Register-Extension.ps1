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
        [string]$installroot = "C:\ProgramData\SecAudit"
    )
Process 
    {
        #region BuildScriptBlocks
        $default = {
                Write-Verbose "Reading Extension Header"
                . $Path -register
                Try
                    {
                        Write-Verbose "Registering Job: $Name"
                        Register-ScheduledJob -Name $Name -ScriptBlock {$Path} -MaxResultCount 1
                    }
                Catch {}        
            }

        $job = {
                Try 
                    {
                        Write-Verbose "Registering Job: $Name"
                        Register-ScheduledJob -Name $Name -ScriptBlock $Scriptblock -MaxResultCount 1
                    }
                Catch {}
                
            }
        #endregion BuildScriptBlocks
        
        #region Execution
        switch ($PSCmdlet.ParameterSetName)
            {
                Default {Invoke-Command -ScriptBlock $default}
                Job {Invoke-Command -ScriptBlock $job}
            }
        $job = New-Object -TypeName PSObject -Property @{ 
                        Name = $Name  
                        Title = $Title
                        Format = $format
                    }
        (Import-Clixml -Path $installroot\Config.xml) + $job | Export-Clixml -Path $installroot\Config.xml
        #endregion Execution
    }
#requires -Version 3

#region FunctionsFromTechNet

function Test-IsAdministrator # Taken from the TechNet Gallery, contribution by Ed Wilson
{ 
    <# 
    .Synopsis 
        Tests if the user is an administrator 
    .Description 
        Returns true if a user is an administrator, false if the user is not an administrator         
    .Example 
        Test-IsAdministrator 
    #>    
    param()  
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent() 
    (New-Object Security.Principal.WindowsPrincipal $currentUser).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) 
} #end function Test-IsAdministrator

#endregion FunctionsFromTechNet

Function Register-Extension #done
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
Version 1.3
Created on: 1/26/2014
Last Modified: 2/1/2014
#>
[cmdletbinding(DefaultParameterSetName="Default")]
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
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
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
                Throw "Operation aborted, install directory not found at: $installroot"
            }
        If (-not(Test-IsAdministrator))
            {
                Throw "You must be an administrator to run this function"
            }
    }
Process 
    {
        #region BuildScriptBlocks
        $default = {
               $scriptblock = [scriptblock]::Create($(Get-Content $Path | Out-String))
                Try
                    {
                        Write-Verbose "Registering Job: $Name"
                        Register-ScheduledJob -Name $Name -ScriptBlock $scriptblock -MaxResultCount 1 -ErrorAction Stop
                    }
                Catch 
                    {
                        if ((Get-ScheduledJob -Name $Name ) -and ($Force))
                            {
                                Unregister-ScheduledJob -Name $Name -Force
                                Write-Verbose "Registering Job: $Name"
                                Try 
                                    {
                                        Register-ScheduledJob -Name $Name -ScriptBlock $scriptblock -MaxResultCount 1 -ErrorAction Stop | 
                                        Out-Null
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
                                Write-Warning "Outerblock"
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
                                Unregister-ScheduledJob -Name $Name -Force
                                Write-Verbose "Registering Job: $Name"
                                Try 
                                    {
                                        Register-ScheduledJob -Name $Name -ScriptBlock $Scriptblock -MaxResultCount 1 -ErrorAction Stop |
                                        Out-Null
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
        Write-Debug "Parameter set = $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName)
            {
                'Default' {
                        Write-Verbose "Reading Extension Header"
                        . $Path -register
                        $default.Invoke()
                    }
                'Job' {$job.Invoke()}
            }
        Write-Verbose "Creating job configuration object"
        $job = New-Object -TypeName PSObject -Property @{ 
                        Name = $Name  
                        Title = $Title
                        Format = $format
                        Starttime = $null
                    }
        Write-Verbose "Loading Security Audit configuration file"
        Try {$jobs = {Import-Clixml -Path $installroot\Config.xml}.Invoke()}
        Catch {
                if ((Get-Item $installroot\Config.xml).length -eq 0) {$jobs = @()}
                Else {Throw "Unable to load config.xml"}
            }
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
        Try {$jobs + $job | Export-Clixml -Path $installroot\Config.xml -Force -ErrorAction Stop}
        Catch {Write-warning "Failed to register"}
        #endregion Execution
    }
}

Function Unregister-Extension #done
{
<#
.SYNOPSIS
Removes extensions that have been previously registered with the SecAudit tool

.DESCRIPTION
Removes a specified extension by name

.EXAMPLE
Unregister-Extension -Name Test

Unregisters the Test extension from the Secaudit tool

.EXAMPLE
Get-Extension -name test | Unregister-Extension

Unregisters the Test extension from the Secaudit tool

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.2
Created on: 1/30/2014
Last Modified: 2/1/2014

#>
Param 
    (
        # Enter the name of the Job to be removed
        [Parameter(Mandatory=$true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [string[]]$Name,

        # List the path to the root folder for the SecAudit tool
        [Parameter()]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Installroot = "$env:ProgramFiles\Security Audit"
    )
Begin
    {
        Try 
            {
                Import-Module PSScheduledJob
            }
        catch
            {
                Throw "Unable to load scheduled jobs module"
            }
        If (-not(Test-IsAdministrator))
            {
                Throw "You must be an administrator to run this function"
            }
    }
Process
    {
        foreach ($n in $Name)
            {
                Write-Verbose "Removing $n"
                Try {
                        Unregister-ScheduledJob -Name $n -Force -ErrorAction stop | Out-Null
                    }
                catch 
                    {
                        Write-Warning "Unable to remove $n"
                        $skip = $true
                    }
                if (-not($skip))
                    {
                        Write-Verbose "Update Config.xml"
                        Try {
                                $jobs = Import-Clixml -Path $Installroot\config.xml | where Name -Notlike $n
                                $jobs | Export-Clixml -Path $Installroot\config.xml -Force 
                            }
                        Catch
                            {
                                Write-Warning $_.exception.message
                                Throw "Unable to update config.xml"
                            }
                    }
                else {$skip = $false}
            }
    }
}

Function Get-Extension #done
{
<#
.SYNOPSIS
Gather data on an extension

.DESCRIPTION
Run in order to see details about one or more extensions

.EXAMPLE
Get-Extension -name test | set-extension -starttime (get-date 01:00:00)

Grab the test extension and send it on to set-extension.

.EXAMPLE
Get-extension -listavailable

List information about all currently registered extensions

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/31/2014
Last Modified: 2/1/2014

#>
[cmdletbinding(DefaultParameterSetName="Default")]
Param
    (
        # Enter the name of the Job
        [Parameter(Mandatory=$true,
        ParameterSetName="Default")]
        [string]$Name,

        # Activate to view all Jobs
        [Parameter(ParameterSetName="list")]
        [switch]$listAvailable,

        # List the path to the root folder for the SecAudit tool
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="list")]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Installroot = "$env:ProgramFiles\Security Audit"
    )
try {$jobs = Import-Clixml -Path $Installroot\Config.xml}
Catch {
        Write-Warning $_.exception.message
        Throw "Unable to load config.xml"
    }
Write-Debug "Parameter set = $($PSCmdlet.ParameterSetName)"
switch ($PSCmdlet.ParameterSetName)
            {
                Default {$jobs | where name -like $Name}
                List {$jobs}
            }
}

function Set-ExtensionSchedule #done
{
<#
.SYNOPSIS
set properties on an extension

.DESCRIPTION
Run in order to see details about one or more extensions

.EXAMPLE
Get-Extension -name test | Set-ExtensionSchedule -starttime (get-date 01:00:00)

Grab the test extension and send it on to set-extensionSchedule.

.EXAMPLE
Set-ExtensionSchedule -name Test -starttime (get-date)

Sets the starttime on the extension test to now

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.1
Created on: 1/31/2014
Last Modified: 2/1/2014
#>
[cmdletbinding(DefaultParameterSetName="Default")]
Param
    (
        # Enter Extension starttime, will overwrite current value
        [Parameter(Mandatory=$true,
        ParameterSetName="Default")]
        [datetime]$Starttime,

        # Enter the name of the Job
        [Parameter(Mandatory=$true,
        ParameterSetName="Default",
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory=$true,
        ValueFromPipeline = $true,
        ParameterSetName="Rem")]
        [string]$Name,
        
        # Activate to remove existing alternate Schedule
        [Parameter(Mandatory = $true,
        ParameterSetName="Rem")]
        [switch]$RemoveSchedule,

        # List the path to the root folder for the SecAudit tool
        [Parameter(ParameterSetName="Default")]
        [Parameter(ParameterSetName="Rem")]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$Installroot = "$env:ProgramFiles\Security Audit"
    )
Begin 
    {
        #region LoadConfig
        try {$Config = Import-Clixml -Path $Installroot\Config.xml}
        Catch {
                Write-Warning $_.exception.message
                Throw "Unable to load config.xml"
            }
        #endregion LoadConfig

        #region BuildScriptblocks
        $rem = {
                Try {$job = Get-ScheduledJob -Name $name}
                Catch {Throw "Unable to retrieve extension for $name"}
                Try {
                        Write-Verbose "Removing Schedule"
                        $job | Remove-JobTrigger -ErrorAction stop
                    }
                Catch
                    {
                        Write-Warning "Unable to remove triggers for $name"
                    }
                try {
                        $new = $Config | where Name -Like $name
                        $new.starttime = $null
                    }
                Catch
                    {
                        Write-Warning "Unable to update config.xml for $name"
                    }
            }
        $Default = {
                Try {$job = Get-ScheduledJob -Name $name}
                Catch {Throw "Unable to retrieve extension for $name"}
                try {$job | Set-ScheduledJob -Trigger (
                            New-JobTrigger -Once -At $starttime -RepetitionInterval (
                                    New-TimeSpan -Days 1
                                ) -RepetitionDuration ([timespan]::MaxValue)
                        )
                    }
                Catch
                    {
                        Write-Warning "Unable to add trigger to $name"
                    }
                try {
                        $new = $Config | where Name -Like $name
                        $new.starttime = $starttime 
                    }
                Catch
                    {
                        Write-Warning "Unable to update config.xml for $name"
                    }    
            }
        #region BuildScriptblocks
    }
Process 
    {
        Write-Verbose "Updating $name"
        Write-Debug "Parameter set = $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName)
            {
                Rem {$rem.Invoke()}
                Default {$Default.Invoke()}
            }
        $Config = ($Config | where Name -NotLike $new.name) + $new
        
    }
End {
        $Config | Export-Clixml -Path $Installroot\Config.xml
    }
}
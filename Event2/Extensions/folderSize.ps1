<#

.SYNOPSIS
Gather data about the size of key folders

.DESCRIPTION
This script is intended to run as a scheduled job.  Use the register switch when loading the header data.

.EXAMPLE
.\Foldersize.ps1

Outputs foldersize data for key folders

.EXAMPLE

. .\foldersize.ps1 -register

Load header variables into your current scope without triggering the data collection job

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 1/26/2014
Last Modified: 2/1/2014


#>

Param 
    (
        [switch]$Register
    )

#region DefineFunctions
 Function Get-FolderSize # Reused from my Technet uploads - Jason
{
<#
.SYNOPSIS
Get-FolderSize will recursively search all files and folders at a given path to show the total size

.DESCRIPTION
Get-.FolderSize accepts a file path through the Path parameter and then recursively searches the directory in order to calculate the overall file size. 
The size is displayed in GB, MB, or KB depending on the Unit selected, defaults to GB.  Will accept Multiple paths.

.EXAMPLE 
Get-FolderSize -path C:\users\Someuser\Desktop

Returns the size of the desktop folder in Gigabytes

.EXAMPLE 
Get-FolderSize -path \\Server\Share\Folder, c:\custom\folder -unit MB

Returns the size of the folders, \\Server\Share\Folder and C:\Custom\Folder, in Megabytes

#>
[CmdletBinding()]
Param
    (
        # Enter the path to the target folder
        [Parameter(
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        Mandatory=$true,
        HelpMessage= 'Enter the path to the target folder'
        )]
        [Alias('FullName')]
        [String]$Path,
        # Set the unit of measure for the function, defaults to GB, acceptable values are GB, MB, and KB
        [Parameter(
        HelpMessage="Set the unit of measure for the function, defaults to GB, acceptable values are GB, MB, and KB")]
        [ValidateSet('GB','MB','KB')]
        [String]$Unit = 'GB'
    )
Begin 
    {
        Write-Verbose "Setting unit of measure"
        $value = Switch ($Unit)
            {
                'GB' {1GB}
                'MB' {1MB}
                'KB' {1KB}
            }    
    }
Process
    {
        Try
            {
                Write-Verbose "Collecting Foldersize"
                $Size = Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property length -Sum
            }
        Catch {}
        Try 
            {
                Write-Verbose "Creating Object"
                New-Object -TypeName PSObject -Property @{
                        FolderName = $Path
                        "FolderSize_$($unit.toupper())" = $([math]::Round(($size.sum / $value), 2)) 
                    }
            }
        Catch {}
    }
End{}
}
#endregion DefineFunctions

#region Job
$job = {
        $folders = @(
                "$env:SystemRoot\System32"
                $env:ProgramData
                $env:ProgramFiles
            )
        $folders | Get-FolderSize
    }
#endregion Job

#region run
Switch ($Register)
    {
        $true {
                $Name = "FolderSize"
                $title = "Key Folders"
                $format = "Table"
            }
        $false {$job.invoke()}
    }
#endregion run
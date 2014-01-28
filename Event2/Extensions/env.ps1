<#

.SYNOPSIS
Collect Environment variables and export them to a cliXML file


.DESCRIPTION

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 1/27/2014
Last Modified: 1/27/2014


#>

Param 
    (
        [switch]$Register
    )

#region SetVariables
$Name = "Env"
$title = "Environmental Variables"
$format = "Table"
#endregion SetVariables

#region DefineFunctions
if ($Register)
    {
        Break
    }

Function Get-EnvVariables 
{

[CmdletBinding()] 
Param 
    ( 
        # Enter a ComputerName or IP Address, accepts multiple ComputerNames
        [Parameter( 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True,
        HelpMessage="Enter a ComputerName or IP Address, accepts multiple ComputerNames")] 
        [String[]]$ComputerName = "$env:COMPUTERNAME"

        #specify Ne

    ) 
Begin  
    {
        Write-Verbose "Instantiating Function Paramaters"
            $param = @{ScriptBlock = {
                 $keys= Get-ChildItem env
                  
                $Keys | 
                ForEach-Object {
                        New-Object -TypeName PSObject -Property @{ 
                                VariableName = $_.NAme
                                value = $_.Value 
                            } 
                    }
                }}
    } 
Process 
    {
        foreach ($Computer in $ComputerName) 
            {

                Write-Verbose "Beginning operation on $Computer"
                If (-not($Problem))
                    {
                        If ($Computer -ne $env:COMPUTERNAME) 
                            {
                                Write-Verbose "Adding ComputerName, $Computer, to Invoke-Command"
                                $param.Add("ComputerName",$Computer)
                            }
                        Try
                            {
                                Write-Verbose "Invoking Command on $Computer"
                                Invoke-Command @param
                            }
                        Catch 
                            {
                                Write-warning $_.Exception.Message
                            }
                    }
                if ($Problem) {$Problem = $false}
                if ($param.ContainsKey('ComputerName')) 
                    {
                        Write-Verbose "Clearing $Computer from Parameters"
                        $param.Remove("ComputerName")
                    } 
            }
    } 
End {} 
}

#endregion DefineFunctions

#region CreateData

Get-EnvVariables  $env:COMPUTERNAME | Export-Clixml $share

#endregion CreateData














}
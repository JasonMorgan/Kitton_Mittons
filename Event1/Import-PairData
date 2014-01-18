Function Import-PairData
{
[CmdletBinding()]
Param
    (
    [string]$Path,
    [string]$Count=4
    )
Begin{}
Process
    {
    Get-ChildItem -Directory $Path | Select-Object -Last $Count | Import-Clixml -Path $Path 
    }
End{}
}

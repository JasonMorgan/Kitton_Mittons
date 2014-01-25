Function Export-PairData
{
[CmdletBinding()]
Param
    (
    [system.collections.hashtable]$Hash,
    [string]$Path
    )
Begin{}
Process
    {
    $Hash | Export-Clixml -Path $Path\Data_$(Get-Date -Format MM_DD_YY).xml
    }
End{}
}

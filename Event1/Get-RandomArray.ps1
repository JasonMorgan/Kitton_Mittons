function Get-RandomArray 
{
<#

#>
[cmdletbinding()]
Param 
    (
        [System.Object[]]$array
    )
process 
    {
        $array | Get-Random -Count $array.Count
    }
}
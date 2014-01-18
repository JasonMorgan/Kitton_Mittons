function Split-Name
{
<#
.INPUTS
Single Array

.OUTPUTS
two Arrays

#>
[cmdletbinding()]
Param 
    (
        [System.Object[]]$names
    )
Begin {}
Process 
    {
        $count = $names.Count
        if (($count % 2) -ne 0)
            {
                switch (Read-Host "Uneven numbers of entries found:
Y - Select Y to have pair automatically assigned 
N - select N to abort the operation 
V - Select V to view a list of users and select the users to be grouped together
Select Y, N, or V"
                    )
                    {
                        'Y' {$odd = $true}
                        'N' {Throw "Operation aborted by $env:USERNAME"}
                        'V' { 
                                $pair = $names | Out-GridView -OutputMode Multiple -Title "Please select 2 names from the following list, then click 'Ok'"
                                if ($pair.count -ne 2) { Throw "You may only select 2 names to be paired"} 
                                $names = ($names | where {$_ -notin $pair})
                                $names += ,$pair
                            }
                        default {break}    
                    }
            }
        $a = @()
        $b = @()
        if ($odd) { $double = @() }
        Foreach ($n in $names)
            {
                
                if ($n.primary) {$a += $n}
                if ($a.Count -lt ([int]($count/2))) {$a += $n}
                else 
                    {
                       $b += $n 
                    }
            }
    }
End 
    {
        if ($odd)
            {
                $pair = $b | Get-Random -Count 2
                $b = ($b | where {$_ -notin $pair})
                $b += ,$pair
            }
        $a,$b
    }
}

function Set-RandomArray 
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

Function New-Team
{
Param
    (
        [System.Object[]]$Keys,
        [System.Object[]]$Values
    )
Begin {}
Process 
    {
        $hash = @{}
        $i = 0
        $Keys | foreach {$hash.Add($_,$Values[$i]) ; $i++}
    }
End
    {
        $hash
    }
}

function Test-History
{
<##>
[cmdletbinding()]
Param 
    (
        [System.Collections.Hashtable]$Pairs,
        [System.Collections.Hashtable[]]$oldpairs
    )
Begin {}
Process 
    {
        Foreach ($o in $oldpairs)
            {
                if ($bad) {break}
                foreach ($p in $Pairs.GetEnumerator())
                    {
                        If ($p -in $o.GetEnumerator())
                            {
                                $bad = $true
                                break
                            }
                    }
            }
    }
end 
    {
        if ($bad) {$true}
        else {$false}
    }
}
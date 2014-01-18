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
                        V - Select V to view a list of users
                        Select Y, N, or V"
                    )
                    {
                        'Y' {$odd = $true}
                        'N' {Throw "Operation aborted by $env:USERNAME"}
                        'V' { 
                                $pair = $names | Out-GridView -OutputMode Multiple -Title "Please select 2 names from the following list, then click 'Ok'"
                                if ($pair.count -ne 2) { Throw "You may only select 2 names to be paired"} 
                                $names = ($names | where {$_ -notin $pair}),$pair
                            }
                        default {break}    
                    }
            }
        $a = @()
        $b = @()
        Foreach ($n in $names)
            {
                if ($odd) 
                    {

                    }
                if ($n.primary) {$a += $n}
                if ($a.Count -lt ($count/2)) {$a += $n}
                else {$b += $n}
            }
    }
End {$a,$b}
}

Function Combine
{
$hash = @{}
$i = 0
(Split-Name -names a,b,c,d,e,f,g,h)[0] | foreach {$hash.Add($_,(Split-Name -names a,b,c,d,e,f,g,h)[1][$i]) ; $i++}
}
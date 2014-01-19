function Split-Name  ### Will need to find a way to determine how to pair a particular user with 2 partners, consider setting a flag for later of an operation in the end block
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
        $names = $names | Get-RandomArray # add | sort by primary so primaries always come first
        ### Reusing get-randomarray to really break up the order We'll need to ensure we use a module file or defined all functions first
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
function Split-Name  ### Will need to find a way to determine how to pair a particular user with 2 partners, consider setting a flag for later of an operation in the end block
### Will also need to find a way to sort by primary type
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
        #if (Get-ItemProperty -Name Primary - ## test property
        $count = $names.Count
        if (($count % 2) -ne 0)
            {
                switch (Read-Host "Uneven numbers of entries found:
Y - Select Y to have pair automatically assigned 
N - select N to abort the operation 
V - Select V to view a list of users and select the users to be grouped together
U - Select U to manually assign an individual to be paired with two users
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
                        'U' {
                                $specialpair = $true
                                $lead = $names | Out-GridView -OutputMode Single -Title "Please select the individual who will be paired with a two users then click 'Ok'"
                                $names = ($names | where {$_ -notin $lead})
                                $names += $lead 
                            }
                        default {break}    
                    }
            }
        $key = @()
        $Value = @()
        if ($odd) { $double = @() }
        Foreach ($n in $names)
            {
                
                if ($n.primary) {$key += $n}
                if ($key.Count -lt ([int]($count/2))) {$key += $n}
                else 
                    {
                       $Value += $n 
                    }
            }
    }
End 
    {
        if ($odd)
            {
                $pair = $Value | Get-Random -Count 2
                $Value = ($Value | where {$_ -notin $pair})
                $Value += ,$pair
            }
        if ($specialpair)
            {$key,$Value,$pair}
        Else {$Key,$Value}
    }
}
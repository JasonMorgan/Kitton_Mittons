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
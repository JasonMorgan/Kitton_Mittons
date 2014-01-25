function Test-History ### Revamped to include an inverted version of every old hashtable.  It was missing like pairs if the key and value were swapped
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
                $invert = @{}
                $o.GetEnumerator() | foreach { $invert.add($_.value,$_.key)}
                foreach ($p in $Pairs.GetEnumerator())
                    {
                        If (($p -in $o.GetEnumerator()) -or ($p -in $invert.GetEnumerator()) )
                            {
                                $bad = $true
                                break
                            }
                    }
            }
    }
end 
    {
        if ($bad) {$false}
        else {$true}
    }
}
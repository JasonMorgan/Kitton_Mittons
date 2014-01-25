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
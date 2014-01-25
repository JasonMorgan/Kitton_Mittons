<#
.SYNOPSYS
Uninstall script

.DESCRIPTION
Removes the Create Pairs tool from the current computer

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1
Created on: 1/25/2014
Last Modified: 1/25/2014

#>
Param
    (
        $path = "$env:USERPROFILE\Documents\Pairs"
    )
Remove-Item $path -Recurse
exit $LASTEXITCODE
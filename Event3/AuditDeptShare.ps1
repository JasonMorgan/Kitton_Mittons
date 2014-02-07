<#
.SYNOPSIS


.DESCRIPTION


.EXAMPLE
C:\powershell\Scripts\AuditDeptShare.ps1 -permissionsXML F:\Temp\Temp_Finance.xml -remediate

Audit settings and remediate variations as required.  If remediation is successful there will be not output from this command

.EXAMPLE
C:\powershell\Scripts\AuditDeptShare.ps1 -permissionsXML F:\Temp\Temp_Finance.xml -path c:\report.html

Audit settings and output them to an html report stored at c:\report.html

.NOTES

#>
[cmdletbinding(DefaultParameterSetName="Default")]
Param
    (
        # Enter the path to the Permissions XML file created by the "CreateDeptShare.ps1" script
        [Parameter(Mandatory,
        ParameterSetName = "Default")]
        [Parameter(Mandatory,
        ParameterSetName = "Report")]
        [ValidateScript({ (test-path $_ -PathType Leaf) -and ($_.endswith('.xml')) })]
        [string]$permissionsXML,
        
        # Set if you wish the function to remediate any variances found
        [Parameter(ParameterSetName = "Default")]
        [Parameter(ParameterSetName = "Report")]
        [switch]$remediate,
        
        # Enter the path for the HTML report, must end with .html
        [Parameter(Mandatory,
        ParameterSetName = "Report")]
        [ValidateScript({(Test-path -Path (split-path $_)) -and ($_.endswith('.html'))})]
        [string]$path
    )
Import-Module Permissions
$hash = Import-Clixml $permissionsXML
$entries = foreach ($e in $hash.GetEnumerator())
  {
    if (-not ($e | Test-FolderPermission -Remediate $remediate))
        {
          [pscustomobject]@{
              Path = $e.key
              RightACL = $e.value.access
              ACL = (Get-Acl -Path $e.key).Access
            }
        }
  }

switch ($PSCmdlet.ParameterSetName)
  {
    Report 
      {
        if ($entries) 
          {
          $report = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Permissions Report</title>
</head><body>
<h3>The following variances have been found</h3>
$($entries | foreach {
@"
<h4>$($_.path)</h4>
<h4>Correct Security Settings:</h4>
$($_.RightACL | foreach {$_ | ConvertTo-Html -Fragment -as list } | out-string )
<h4>Current Security Settings:</h4>
$($_.ACL | foreach {$_ | ConvertTo-Html -Fragment -as list} | out-string )
"@        
  }
ConvertTo-Html -Fragment -As list )
</body></html>
"@
          }
        else 
          {
            $report = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Permissions Report</title>
</head><body>
<h3>The following folders were audited and no variances have been found</h3>
$($hash.Keys)
</body></html>
"@
          }
        $report | Out-File -FilePath $path 
      }
    Default {$entries}
  }
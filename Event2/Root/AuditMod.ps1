<#

.SYNOPSIS
Master script that launches registered extension scripts, stores data on central share, and sends alerts if necessary

.DESCRIPTION

.EXAMPLE

.NOTES
Written by the Kitton Mittons
For the 2014 Winter Scripting Games
Version 1.0
Created on: 1/26/2014
Last Modified: 1/26/2014

***One  outstanding item will be a switch to allow you to set schedules for the various extensions.  Seems to be a requirement for this task.

#>

#region Initialize
#load config file
#endregion Initialize

#region RunScripts
#Add progress bar
#
#store each result set in variable
#one job per script
#watch for errors
#endregion RunScripts

#region TestShare
#be able to start network watcher job
#be able to switch to local store on failure
#endregion TestShare


#region CheckKeyfile
#endregion CheckKeyfile

#region HTMLReport
#endregion HTMLReport

#only do if you have time
#region XMLReport
#endregion XMLReport

#may be superfluous
#region SendNotification
#endregion SendNotification
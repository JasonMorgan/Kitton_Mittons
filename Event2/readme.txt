Description:
The SecAudit tool runs in the following configuration -

	One master script that launches all the extension scripts when triggered
	Extension scripts are written with a particular header, the header is documented in the extension header section

There is a register-extension script to load new extensions into the tool

Essentially every extension is built as a scheduled job and the master script, SecAudit, runs as a scheduled task

An install and uninstall script will be provided to deploy the scripts, run the register-extensions script for every extension file, and create a new scheduled task for the SecAudit tool.

Common criteria
Master runs as system
Uses scheduled task - hidden

Root:
Master script in root - run as system
Key file
register extension script
Config.xml

Network share for storing reports - Encryption available
Common HTML report

Entension Header:
Param 
    (
        [switch]$Register
    )

#region SetVariables
$Name = "Env" - job name
$title = "Environmental Variables" - Report title
$format = "Table" - report format
#endregion SetVariables

Extensions:
Env
Reg
FileSystem - Core folder size and disks
FileHash - Hash all dlls and exes
InstalledSoftware
Processes
Services
NetworkShares
Eventlogs - properties and last purge

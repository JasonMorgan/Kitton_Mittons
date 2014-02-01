Description:
The SecAudit tool runs in the following configuration -

	One master script that launches all the extension scripts when triggered
	Extension scripts are written with a particular header

There is a register-extension function to load new extensions into the tool
Essentially every extension is built as a scheduled job and the master script, SecAudit.ps1, calls those jobs when triggered

An install and uninstall script are provided to deploy the scripts, run the register-extension for every extension you wish to add beyond the default


To Install:
Add extension scripts to a folder called extensions in your download folder
run install.ps1

To add a custom extension:
Use Register-Extension from the SecAudit Module

To uninstall:
Call the uninstall.ps1 script.

Included Extensions:
Env
Disks
Reg
FolderSize
Hash 
InstalledSoftware
Processes
Services
NetworkShares

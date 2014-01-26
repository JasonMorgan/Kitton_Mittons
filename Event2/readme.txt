Creating SecAudit tool

Common criteria
All stored data encrypted
Master runs as system
Uses scheduled task - hidden
watcher task -hidden different folder

Client side:

Root:
Master script in root - run as system
Key file
register extension script
Job to load reports on server when network connection becomes available
Watcher script
	Report if Master disabled or fails or won't run <24hrs

Extensions:
Component scripts

History:
Historical data stored in History - function to test free space to ensure > 5% still free


Network share for storing reports - Encrypt on moving to share
Common HTML peport
Common XML report




Server Side:
Script to verify and set NTFS permissions
ReKey Function
Distributes new key file to clients
Stores historical keys for reopening old data


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
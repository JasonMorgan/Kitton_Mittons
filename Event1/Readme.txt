Welcome to the Create Pairs tool!

This readme will cover the installation, usage, and removal of Create Pairs.

All data for this tool is stored in your userprofile at %userprofile%\Documents\Pairs

Install:
To install this tool do the following:

Browse to the application folder you downloaded
Double click the Install.bat file

Usage:
This tool includes 2 distinct scripts:

SecretSanta.ps1
This tool was written in order to allow the simple random pairings of individuals into secret santa teams.
For more detailed information run:
get-help $env:userprofile\Documents\Pairs\SecretSanta.ps1 -full

DeveloperPairs.ps1
This tool was written to be used by Company Project Managers in order to create teams of Developers.
For more detailed information run:
get-help $env:userprofile\Documents\Pairs\SecretSanta.ps1 -full

When Running DevelopersPairs.ps1 you need to specify a csv file to the -path parameter
The csv file must have the following headers:
Name,Email,Primary

Uninstall:
To uninstall this tool do the following:

Browse to the application folder you downloaded
Double click the Uninstall.bat file

It's important to note that all historical data will be removed when this is run


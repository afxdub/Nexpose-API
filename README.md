This project utilizes the Nexpose API in Powershell though a module with two cmdlets - Get-IDFromIP and Add-Exception.
The goal is to automate bulk tasks in Nexpose.  Currently, the module has only one primary use.  That is to automate
the creation of exception requests using the Add-Exception cmdlet.  I hope to create more cmdlets and extend the module
as I find more use cases.

INSTALLATION

1. Create a new folder named 'Nexpose-API' in 'My Documents\WindowsPowerShell\Modules'.
2. Download the Nexpose-API.psm1 file and place it in the 'Nexpose-API' folder.
3. From within a Powershell console, type the command 'Import-Module Nexpose-API'.
4. The cmdlets should now be ready to use.

USAGE

Please see the Manual on the Wiki page

https://github.com/afxdub/Nexpose-API/wiki/Manual

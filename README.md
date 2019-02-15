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

The module contains two cmdlets - Get-IDFromIP and Add-Exception.  Their usage and parameters are expalined below.

1. Get-IDFromIP
  
  a. Purpose
  This cmdlet is designed to retrieve the Nexpose ID of an asset given the IP address of the asset.  If the ID is successfully
  retrived, the ID of the asset is returned.  If the ID cannot be retrieved, NULL is returned.
  
  b. Parameters
  
  IP - The IP address of the asset to be found
  NexposeURL - The full URL of your Nexpose server.  Ex. https://nexpose.example.com:3780
  credential - A PSCredential object.  Use the Get-Credential cmdlet to get this.  Used to authenticate to the Nexpose server.
  
  c. Example Usage
  
  $assetID = Get-IDFromIP -IP 10.10.10.10 -credentials Get-Credential -NexposeURL 'https://nexpose.example.com:3780'
  
2. Add-Exception

  a. Purpose
  To create an exception request in Nexpose.  If the exception request is successfully created, the ID of the exception request is
  returned.  If the exception request could not be created, NULL is returned.
  
  b. Parameters.
  assetIP - Required. The IP address of the asset in Nexpose.
  NexposeURL - Required. The URL of your Nexpose server.
  vulnID - Required. The vulnerability ID. For example http-options-enabled.
  credentials - Required. A Powershell credential object. This will be used to authenticate to the Nexpose server
  Reason - Required. valid values are False Positive, Compensating Control, Acceptable Use, Acceptable Risk, Other
  Comment - Required. Additional information about the vulnerability exception
  Type - Required. Supported values are Asset and Instance. I'll try to add support for Global, Site, and Asset Group later.
  VulnKey - Optional. If Type is 'Instance', the Key to uniquely identify the vulnerability
  Port - Optional. If Type is 'Instance', the Port to uniquely identify the vulnerability
  ExpirationDate - Optional. Expiration date for the exception. If no value is provided, the exception will never expire.
  
  c. Example Usage
  
  Create an exception request for all instances of the http-options-enabled vulnerability on an asset because of a
  compensating control.
  
  Add-Exception -assetIP 10.10.10.10 -NexposeURL 'https://nexpose.example.com:3780' -credentials Get-Credential -vulnID 'http-options-enabled' -Reason 'Compensating Control' -Comment "Testing" -Type Asset
  
  Create an exception request for a specific instance of http-options-enabled found on port 80 on an asset.
  Exception will expire on December 3rd, 2019.
  
  Add-Exception -assetIP 10.10.10.10 -NexposeURL 'https://nexpose.example.com:3780' -credentials Get-Credential -vulnID 'http-options-enabled' -Reason 'Compensating Control' -Comment "Testing" -Type Instance -port 80 -ExpirationDate '12/3/2019'

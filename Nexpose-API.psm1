Function Get-IDFromIP
{
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='IP Address')]
        [string]$IP,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Nexpose URL.  Example: nexpose.example.com:3780')]
        [string]$NexposeURL,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Get-Credential object')]
        [System.Management.Automation.PSCredential]$credentials
    )

    Process
    {
        $APIURL = "$NexposeURL/api/3/assets/search"

        $TempHash = @{
            match = "all"
            filters = @(
                @{
                    field = "ip-address"
                    operator = "is"
                    value = "$IP"
                }
            )
        }
        $Json = $TempHash | ConvertTo-Json -Depth 5

        $user = $credentials.UserName
        $pass = $credentials.GetNetworkCredential().password

        $pair = "$($user):$($pass)"

        $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

        $basicAuthValue = "Basic $encodedCreds"

        $Headers = @{
            Authorization = $basicAuthValue
        }

        $WebRequestContent = ""
        $ErrResp = ""

        try
        {
            $WebRequestContent = Invoke-WebRequest -Uri $APIURL -Headers $Headers -Body $Json -ContentType "application/json" -Method Post
        }
        catch
        {
            $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
            $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
            $streamReader.Close()
        }

        if ($ErrResp)
        {
            Write-Host "There was an error!" -ForegroundColor Red
            Write-Host $ErrResp -ForegroundColor Yellow
            Return $null
        }
        else
        {
            $JsonFromResponse = $WebRequestContent.Content | ConvertFrom-Json
            Return $JsonFromResponse.resources.id
        }
    }
}

Function Add-Exception
{
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='ID of the Nexpose Asset')]
        [string]$assetIP,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Nexpose URL.  Example: nexpose.example.com:3780')]
        [string]$NexposeURL,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='The Nexpose vulnerability ID.  Ex. ssl-only-weak-ciphers')]
        [string]$vulnID,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Get-Credential object')]
        [System.Management.Automation.PSCredential]$credentials,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Reason for the exceptions.  Valid reasons are - False Positive, Compensating Control, Acceptable Use, Acceptable Risk, Other')]
        [ValidateSet("False Positive","Compensating Control","Acceptable Use","Acceptable Risk","Other")]
        [string]$Reason,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='The Nexpose vulnerability ID.  Ex. ssl-only-weak-ciphers')]
        [string]$Comment,
        [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Exception Request Type.  Valid types are - Global, Site, Asset, Asset Group, Instance')]
        [ValidateSet("Global","Site","Asset","Asset Group","Instance")]
        [string]$Type,
        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Optional - For Type INSTANCE only - port number associated with the vulnerability')]
        [string]$Port,
        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Optional - Date the exception request will expire. Example: 5/22/2019')]
        [string]$ExpirationDate,
        [Parameter(Mandatory=$False,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Optional - For Type INSTANCE only - key to discriminate the instance the exception applies to')]
        [string]$VulnKey
    )

    Process
    {
        $APIURL = "$NexposeURL//api/3/vulnerability_exceptions"

        $assetID = Get-IDFromIP -IP $assetIP -credentials $cred -NexposeURL $NexposeURL

        if ($assetID)
        {
            Write-Host "Processing $assetIP with Asset ID $assetID"

            if ($ExpirationDate)
            {
                $exDate = "{0:yyyy-MM-ddTHH:mm:ss.ffffZ}" -f (Get-Date $ExpirationDate).ToUniversalTime()
            }
            $TempHash = @{
    #            expires = "2019-04-01T04:59:59.999Z"
                expires = "$exDate"
                links = @(
                    @{
                        href = "https://secsvr2-vm.velaw.com:3780/api/3/assets/$assetID"
                        rel = "Asset"
                    }
                )
                review = @{
                    links = @(
                        @{
                            href = "https://secsvr2-vm.velaw.com:3780/api/3/assets/$assetID"
                            rel = "Asset"
                        }
                    )      
                }
                scope = @{
                    id = "$assetID"
                    links = @(
                        @{
                            href = "https://secsvr2-vm.velaw.com:3780/api/3/assets/$assetID"
                            rel = "Asset"
                        }
                    )
                    type = "$Type"
                    vulnerability = "$vulnID"
                    port = "$Port"
                    key = "$VulnKey"
                }
                state = "under review"
                submit = @{
                    comment = "$Comment"                
                    reason = "$Reason"
                }        
            }
            $Json = $TempHash | ConvertTo-Json -Depth 5

            $user = $credentials.UserName
            $pass = $credentials.GetNetworkCredential().password

            $pair = "$($user):$($pass)"

            $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

            $basicAuthValue = "Basic $encodedCreds"

            $Headers = @{
                Authorization = $basicAuthValue
            }

            $WebRequestContent = ""
            $ErrResp = ""

            try
            {
                $WebRequestContent = Invoke-WebRequest -Uri $APIURL -Headers $Headers -Body $Json -ContentType "application/json" -Method Post
            }
            catch
            {
                $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                $streamReader.Close()
            }

            if ($ErrResp)
            {
                Write-Host "There was an error!" -ForegroundColor Red
                Write-Host $ErrResp -ForegroundColor Yellow
                Return $null
            }
            else
            {
                $JsonFromResponse = $WebRequestContent.Content | ConvertFrom-Json
                Return $JsonFromResponse.id
            }
        }
        else
        {
            Write-Host "IP Search failed for $assetIP" -ForegroundColor Cyan
        }
    }
}
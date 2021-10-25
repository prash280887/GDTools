Param 
( 
    # Location of .Zip file 
    [Parameter(Mandatory = $true)] 
    [String] 
    $Zipfilelocation,

    # Name of job where the application is deployed to 
    [Parameter(Mandatory = $true)] 
    [String] 
    $jobname, 
         
    # Name of the web site the application is deployed to 
    [Parameter(Mandatory = $true)] 
    [String] 
    $WebsiteName, 
 
    # job type 
    [Parameter(Mandatory = $true)] 
    [String] 
    $jobtype,

    #$resource Group
    [Parameter(Mandatory = $true)] 
    [String] 
    $rgname
)

#Pulling authorization access token :
function Get-ApiAuthorisationHeaderValue($resourceGroupName, $WebsiteName){

$PublishingProfile = [xml](Get-AzureRmWebAppPublishingProfile -ResourceGroupName $resourceGroupName -Name $WebsiteName)


$Username = (Select-Xml -Xml $PublishingProfile -XPath "//publishData/publishProfile[contains(@profileName,'Web Deploy')]/@userName").Node.Value
$Password = (Select-Xml -Xml $PublishingProfile -XPath "//publishData/publishProfile[contains(@profileName,'Web Deploy')]/@userPWD").Node.Value
return ("Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f 
$Username, $Password))))
}


$accessToken = Get-ApiAuthorisationHeaderValue $rgname $WebsiteName

#Generating header to create and publish the Webjob :
$filename = Split-Path $Zipfilelocation -leaf
#Generating header to create and publish the Webjob :
$Header = @{
"Content-Disposition"="attachment; attachment; filename=$filename.zip"
"Authorization"=$accessToken
        }

Write-Host $filename
#publish the Webjob :
$apiUrl = "https://$WebsiteName.scm.azurewebsites.net/api/triggeredwebjobs/$jobname"
$result = Invoke-RestMethod -Uri $apiUrl -Headers $Header -Method put -InFile $Zipfilelocation -ContentType 'application/zip' -TimeoutSec 600
    
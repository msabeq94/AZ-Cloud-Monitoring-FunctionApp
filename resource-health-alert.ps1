
$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}
$tagKey = "vf-core-cloud-monitoring"
$tagValue = "true"
$RGhealthURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/activityLogAlerts/vf-core-cm-resource-health-alert?api-version=2017-04-01"

$resourceGroups = Get-AzResourceGroup | Where-Object { $_.Tags -and $_.Tags[$tagKey] -eq $tagValue }

foreach ($resourceGroup in $resourceGroups) {
    $RGName = $resourceGroup.ResourceGroupName

  
   $RGAlert= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header  | ConvertTo-Json -Depth 100
    $RGScopr = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
    

if ($RGScopr -contains $RGName) {
    Write-Output "Resource Group $RGName already exists in the alert scope"
} else {
  $newResourceGroup = @{
    "field" = "resourceGroup"
    "equals" = "$RGName"
}

$RGScopr += $newResourceGroup

$updatedJsonResponse = $RGScopr | ConvertTo-Json -Depth 10

$BodyAzLogAlertRule = @"




"@
    
}
}
 
 
 
 










$functionURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/activityLogAlerts/vf-core-cm-resource-health-alert?api-version=2017-04-01"
Invoke-RestMethod -Uri $functionURI -Method get -Headers $header | ConvertTo-Json -Depth 100
Invoke-RestMethod -Uri $CustomAlertURI -Method Put -Headers $header -Body $CustomAlertbody

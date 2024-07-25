
$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$tagKey = "vf-core-cloud-monitoring"
$tagValue = "true"

$RGhealthURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/activityLogAlerts/vf-core-cm-resource-health-alert?api-version=2017-04-01"

$RGAlert= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
$AzLogAlertRuleeachLogAlert = $RGAlert 

$RGScope = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
$newResourceGroup = @{
  "field" = "resourceGroup"
  "equals" = "vf3"
}
$RGScope += $newResourceGroup


$RTyScope = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" } 





$AzLogAlertRuleExistingId = $AzLogAlertRuleeachLogAlert.id | ConvertTo-Json
$AzLogAlertRuleExistingName = $AzLogAlertRuleeachLogAlert.name | ConvertTo-Json
$AzLogAlertRuleExistingTags = $AzLogAlertRuleeachLogAlert.tags | ConvertTo-Json
$AzLogAlertRuleExistinScopes = $AzLogAlertRuleeachLogAlert.properties.scopes | ConvertTo-Json
$AzLogAlertRuleExistinScopesv2 = @"
[
  $AzLogAlertRuleExistinScopes
]
"@

$AzLogAlertRuleExistingConditionResourceGroup = $RGScope | ConvertTo-Json -Depth 10
$AzLogAlertRuleExistingConditionResourceType = $RTyScope | ConvertTo-Json -Depth 10
$AzLogAlertRuleExistingCondition = @"
{
  "allOf": [
    {
      "field": "category",
      "equals": "ResourceHealth"
    },
    {
      "anyOf": $AzLogAlertRuleExistingConditionResourceGroup 
    },
    {
      "anyOf": $AzLogAlertRuleExistingConditionResourceType
    }
  ]
}
"@

$AzLogAlertRuleExistingActions = $AzLogAlertRuleeachLogAlert.properties.actions | ConvertTo-Json
$AzLogAlertRuleExistingDescription = $AzLogAlertRuleeachLogAlert.properties.description | ConvertTo-Json

$BodyAzLogAlertRule = @"
{
    "id": $AzLogAlertRuleExistingId,
    "name": $AzLogAlertRuleExistingName,
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": $AzLogAlertRuleExistingTags,
    "properties": {
        "scopes": $AzLogAlertRuleExistinScopesv2,
        "condition": $AzLogAlertRuleExistingCondition,
        "actions": $AzLogAlertRuleExistingActions,
        "enabled": true,
        "description": $AzLogAlertRuleExistingDescription
    }
}
"@

$RGAlertPUT= Invoke-RestMethod -Uri $RGhealthURI -Method put   -Headers $header  -Body $BodyAzLogAlertRule
$RGScopeUPdate = $RGAlertPUT.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 
write-output $RGScopeUPdate

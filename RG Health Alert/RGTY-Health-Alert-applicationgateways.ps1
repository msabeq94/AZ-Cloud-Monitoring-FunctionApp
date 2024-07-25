

$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token
$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$tagKey = "vf-core-cloud-monitoring"
$tagValue = "true"

$RGhealthURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/activityLogAlerts/vf-core-cm-resource-health-alert?api-version=2017-04-01"

$applicationgateways = @()

$resourceGroups = Get-AzResourceGroup | Where-Object { $_.Tags -and $_.Tags[$tagKey] -eq $tagValue }

foreach ($resourceGroup in $resourceGroups) {
  # Get all resources of type microsoft.network/applicationgateways in each resource group
  $resources = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName | Where-Object {$_.ResourceType -eq "microsoft.network/applicationgateways"}
  $applicationgateways += $resources  # Add the found storage accounts to the array
}

$RGAlert= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
$RGTYScope = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" -and $_.equals -eq "microsoft.network/applicationgateways" } 


if ($null -eq $RGTYScope -and $applicationgateways.count -gt 0) {

  $newResourceType = @{
    "field" = "resourceType"
    "equals" = "microsoft.network/applicationgateways"
  }
  $newResourceTypev1 = "microsoft.network/applicationgateways"
  $NEWRTyScope = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" }
  $NEWRGScope = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 

  if ($NEWRTyScope.count -gt 1) {
    $UpdateNEWRTYScope = $NEWRTyScope +=  $newResourceType
    $UpdateNEWRTYScopev2 = $UpdateNEWRTYScope | ConvertTo-Json -Depth 10
    

  }
  $equalsValueTY = $NEWRTyScope.equals


  $AzLogAlertRuleeachLogAlert =  $RGAlert

        $AzLogAlertRuleExistingId = $AzLogAlertRuleeachLogAlert.id | ConvertTo-Json
        $AzLogAlertRuleExistingName = $AzLogAlertRuleeachLogAlert.name | ConvertTo-Json
        $AzLogAlertRuleExistingTags = $AzLogAlertRuleeachLogAlert.tags | ConvertTo-Json
        $AzLogAlertRuleExistinScopes = $AzLogAlertRuleeachLogAlert.properties.scopes | ConvertTo-Json
        $AzLogAlertRuleExistinScopesv2 = @"
[
  $AzLogAlertRuleExistinScopes
]
"@
          $AzLogAlertRuleExistingConditionResourceGroup = $NEWRGScope | ConvertTo-Json -Depth 10
          $AzLogAlertRuleExistingConditionResourceType = $UpdateNEWRTYScopev2 

          $AzLogAlertRuleExistingConditionV1 = @"
          {
              "allOf": [
                  {
                      "field": "category",
                      "equals": "ResourceHealth"
                  },
                  {
                      "anyOf": 
                      $AzLogAlertRuleExistingConditionResourceGroup
                  },
                  {
                      "anyOf": [
                        {
                          "field": "resourceType",
                          "equals": "$($equalsValueTY)"
                        },
                        {
                          "field": "resourceType",
                          "equals": "$($newResourceTypev1)"
                        }
                      ]
                      
                  }
              ]
          }
"@

$AzLogAlertRuleExistingCondition = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceGroup
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceType
        }
    ]
}
"@
if ($NEWRTyScope.count -eq 1) {
  $AzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV1
 
}

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

      try {
        $RGAlertPUT= Invoke-RestMethod -Uri $RGhealthURI -Method put   -Headers $header  -Body $BodyAzLogAlertRule

      }
      catch {
        <#Do this if a terminating exception happens#>
        throw "Terminating exception occurred. Stopping the script."
      }
      $RGScopeUPdate = $RGAlertPUT.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" } |ConvertTo-Json -Depth 10
      write-output $RGScopeUPdate
      start-sleep -s 5
      $functionURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-uk-resources-rg/providers/Microsoft.Web/sites/VF-Core-Function/functions/RGTY-Health-Alert-storageaccounts?api-version=2015-08-01"
      Invoke-RestMethod -Uri $functionURI -Method Delete -Headers $header 
      

  
}




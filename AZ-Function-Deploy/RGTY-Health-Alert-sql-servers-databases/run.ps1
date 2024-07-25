# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"



$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token
$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$tagKey = "vf-core-cloud-monitoring"
$tagValue = "true"

$RGhealthURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/activityLogAlerts/vf-core-cm-resource-health-alert?api-version=2017-04-01"

$sqlserversdatabases = @()

$resourceGroups = Get-AzResourceGroup | Where-Object { $_.Tags -and $_.Tags[$tagKey] -eq $tagValue }

foreach ($resourceGroup in $resourceGroups) {
  # Get all resources of type microsoft.sql/servers/databases in each resource group
  $resources = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName | Where-Object {$_.ResourceType -eq "microsoft.sql/servers/databases"}
  $sqlserversdatabases += $resources  # Add the found storage accounts to the array
}

$RGAlert= Invoke-RestMethod -Uri $RGhealthURI -Method get -Headers $header 
$RGTYScope = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" -and $_.equals -eq "microsoft.sql/servers/databases" } 


if ($null -eq $RGTYScope -and $sqlserversdatabases.count -gt 0) {

  $newResourceType = @{
    "field" = "resourceType"
    "equals" = "microsoft.sql/servers/databases"
  }
  $newResourceTypev1 = "microsoft.sql/servers/databases"
  $NEWRTyScope = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceType" }
  $NEWRGScope = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 

  if ($NEWRTyScope.count -gt 1) {
    $UpdateNEWRTYScope = $NEWRTyScope +=  $newResourceType
    $UpdateNEWRTYScopev2 = $UpdateNEWRTYScope | ConvertTo-Json -Depth 10
    

  }
  $equalsValueRG = $NEWRGScope.equals
  $equalsValueRGTY =  $NEWRTyScope.equals


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

          
#1 RG and 1 RGTY
$AzLogAlertRuleExistingConditionV1 = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": [
                {
                  "field": "resourceGroup",
                  "equals": "$($equalsValueRG)"
                }
              ]
        },
        {
            "anyOf": [
              {
                "field": "resourceType",
                "equals": "$($equalsValueRGTY)"
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

      #mult RG & one RGTY
$AzLogAlertRuleExistingConditionV2 = @"
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
        "equals": "$($equalsValueRGTY)"
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

#1 RG & mult RGTY
$AzLogAlertRuleExistingConditionV3 = @"
{
"allOf": [
{
    "field": "category",
    "equals": "ResourceHealth"
},
{
    "anyOf": [
        {
          "field": "resourceGroup",
          "equals": "$($equalsValueRG)"
        },

      ]
},
{
    "anyOf": [
      {
        "field": "resourceType",
        "equals": "$($equalsValueRGTY)"
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


#mut RG & Mut RGTY
$AzLogAlertRuleExistingConditionV4 = @"
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

if ($NEWRGScope.count -eq 1 -and $NEWRTyScope.count -eq 1) {
$UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV1

}elseif ($NEWRGScope.count -gt 1 -and $NEWRTyScope.count -eq 1) {
$UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV2
}elseif ($NEWRGScope.count -eq 1 -and $NEWRTyScope.count -gt 1) {
$UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionv3
} else {
$UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV4
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
        "condition": $UPAzLogAlertRuleExistingCondition,
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
    }elseif ($RGTYScope.count -gt 0) {
        $functionURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-uk-resources-rg/providers/Microsoft.Web/sites/VF-Core-Function/functions/RGTY-Health-Alert-sql-servers-databases?api-version=2015-08-01"
        Invoke-RestMethod -Uri $functionURI -Method Delete -Headers $header 
      }else {
        write-output "No sql-servers-databases resources found"
      } 

  





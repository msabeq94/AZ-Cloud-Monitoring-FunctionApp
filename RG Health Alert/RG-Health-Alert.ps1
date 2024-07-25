# Assuming $newResourceGroupPath is defined elsewhere in your script

# JSON data from the provided file
$jsonData = @"
{
  "id": "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/activitylogalerts/vf-core-cm-resource-health-alert",
  "name": "vf-core-cm-resource-health-alert",
  "type": "Microsoft.Insights/ActivityLogAlerts",
  "location": "global",
  "tags": {},
  "properties": {
    "scopes": [
      "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f"
    ],
    "condition": {
      "allOf": [
        {
          "field": "category",
          "equals": "ResourceHealth"
        },
        {
          "anyOf": [
            {
              "field": "resourceGroup",
              "equals": "ahmed"
            },
            {
              "field": "resourceGroup",
              "equals": "ms-terraform-aws"
            },
            {
              "field": "resourceGroup",
              "equals": "vf-core-uk-resources-rg"
            }
          ]
        },
        {
          "anyOf": [
            {
              "field": "resourceType",
              "equals": "microsoft.compute/virtualmachines"
            },
            {
              "field": "resourceType",
              "equals": "microsoft.network/applicationgateways"
            },
            {
              "field": "resourceType",
              "equals": "microsoft.dbforpostgresql/flexibleservers"
            },
            {
              "field": "resourceType",
              "equals": "microsoft.dbformysql/flexibleservers"
            },
            {
              "field": "resourceType",
              "equals": "microsoft.sql/servers/databases"
            },
            {
              "field": "resourceType",
              "equals": "microsoft.network/loadbalancers"
            }
          ]
        }
      ]
    },
    "actions": {
      "actionGroups": [
        {
          "actionGroupId": "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourcegroups/vf-core-uk-resources-rg/providers/microsoft.insights/actiongroups/ vf-core-cm-notifications",
          "webhookProperties": {}
        }
      ]
    },
    "enabled": true,
    "description": ""
  }
}
"@

$RGAlert | Convertto-Json -Depth 100


# Convert JSON data to PowerShell object
$AzLogAlertRuleeachLogAlert = $RGAlert 

# Update the scopes with the new resource group path
#$updatedScopesAzLogAlertRule = ($AzLogAlertRuleeachLogAlert.properties.scopes + $newResourceGroupPath) | ConvertTo-Json
$RGScopr = $RGAlert.properties.condition.allOf.anyof | Where-Object { $_.field -eq "resourceGroup" } 

# Extract existing properties of the Azure Log Alert Rule
$AzLogAlertRuleExistingCondition = $AzLogAlertRuleeachLogAlert.properties.condition | ConvertTo-Json
# $AzLogAlertRuleExistingConditionv2 = @" 
# {
#   "allOf": [
#     {
#       "field": "category",
#       "equals": "ResourceHealth"
#     },
#     {
#       "anyOf": 
$AzLogAlertRuleExistingActions = $AzLogAlertRuleeachLogAlert.properties.actions | ConvertTo-Json
$AzLogAlertRuleExistingDescription = $AzLogAlertRuleeachLogAlert.properties.description | ConvertTo-Json
$AzLogAlertRuleExistingTags = $AzLogAlertRuleeachLogAlert.tags | ConvertTo-Json
$AzLogAlertRuleExistingName = $AzLogAlertRuleeachLogAlert.name | ConvertTo-Json
$AzLogAlertRuleExistingId = $AzLogAlertRuleeachLogAlert.id | ConvertTo-Json
$AzLogAlertRuleExistinScopes = $AzLogAlertRuleeachLogAlert.properties.scopes | ConvertTo-Json
$AzLogAlertRuleExistinScopesv2 = @"
[
  $AzLogAlertRuleExistinScopes
]
"@


# Construct the body for updating the Azure Log Alert Rule
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

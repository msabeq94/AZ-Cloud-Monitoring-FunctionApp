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


$storageAccountAvailability = get-AzResource -ResourceGroupName "vf-core-UK-resources-rg" | Where-Object {$_.Name -eq "vf-core-cm-SQL-server-failed-connection" -and $_.Type -eq "Microsoft.Insights/scheduledQueryRules" }

if ($storageAccountAvailability -eq $null) {

    $CustomAlertURI = "https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-SQL-server-failed-connection?api-version=2021-08-01"

$CustomAlertbody = @"
{
  "id": "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-SQL-server-failed-connection",
  "name": "vf-core-cm-SQL-server-failed-connection",
  "type": "Microsoft.Insights/scheduledQueryRules",
  "location": "uksouth",
  "tags": {},
  "properties": {
    "createdWithApiVersion": "2023-03-15-preview",
    "displayName": "vf-core-cm-SQL-server-failed-connection",
    "description": "The Failed Connection for a Azure SQL Database has been crossed the threshold value",
    "severity": 1,
    "enabled": true,
    "evaluationFrequency": "PT5M",
    "scopes": [
      "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourcegroups/vf-core-uk-resources-rg/providers/microsoft.operationalinsights/workspaces/vf-core-log-analytics"
    ],
    "targetResourceTypes": [
      "microsoft.operationalinsights/workspaces"
    ],
    "windowSize": "PT5M",
    "overrideQueryTimeRange": "P2D",
    "criteria": {
      "allOf": [
        {
          "query": "AzureMetrics\n| where ResourceProvider == \"MICROSOFT.SQL\" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in ('connection_failed')\n| summarize Failed_Connections_Max = max(Maximum), Failed_Connections_Min = min(Minimum), Failed_Connections_Avg = avg(Average) by Resource , MetricName, _ResourceId\n",
          "timeAggregation": "Average",
          "metricMeasureColumn": "Failed_Connections_Avg",
          "dimensions": [],
          "resourceIdColumn": "_ResourceId",
          "operator": "GreaterThan",
          "threshold": 1.0,
          "failingPeriods": {
            "numberOfEvaluationPeriods": 1,
            "minFailingPeriodsToAlert": 1
          }
        }
      ]
    },
    "autoMitigate": false,
    "actions": {
      "actionGroups": [
        "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourcegroups/vf-core-uk-resources-rg/providers/microsoft.insights/actiongroups/ vf-core-cm-notifications"
      ],
      "customProperties": {}
    }
  }
}
"@


 try {
        
        Invoke-RestMethod -Uri $CustomAlertURI -Method Put -Headers $header -Body $CustomAlertbody
    } catch {
        
    }
} else {
  $functionURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-uk-resources-rg/providers/Microsoft.Web/sites/mos49/functions/SQL-server-failed-connection?api-version=2015-08-01"
  Invoke-RestMethod -Uri $functionURI -Method Delete -Headers $header 

}

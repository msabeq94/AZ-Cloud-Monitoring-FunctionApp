
$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}


$storageAccountAvailability = get-AzResource -ResourceGroupName "vf-core-UK-resources-rg" | Where-Object {$_.Name -eq "vf-core-cm-SQL-server-log-IO-percent-connection" -and $_.Type -eq "Microsoft.Insights/scheduledQueryRules" }

if ($storageAccountAvailability -eq $null) {

    $CustomAlertURI = "https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-SQL-server-log-IO-percent-connection?api-version=2021-08-01"

$CustomAlertbody = @"
{
  "id": "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-SQL-server-log-IO-percent-connection",
  "name": "vf-core-cm-SQL-server-log-IO-percent-connection",
  "type": "Microsoft.Insights/scheduledQueryRules",
  "location": "uksouth",
  "tags": {},
  "systemData": {
    "createdBy": "mohamed.omar18@live.com",
    "createdByType": "User",
    "createdAt": "2024-07-21T08:41:29.6960936Z",
    "lastModifiedBy": "mohamed.omar18@live.com",
    "lastModifiedByType": "User",
    "lastModifiedAt": "2024-07-21T08:41:29.6960936Z"
  },
  "properties": {
    "createdWithApiVersion": "2023-03-15-preview",
    "displayName": "vf-core-cm-SQL-server-log-IO-percent-connection",
    "description": "The SQL Server Log IO for a Azure SQL Database has been crossed the threshold value",
    "severity": 0,
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
          "query": "AzureMetrics\n| where ResourceProvider == \"MICROSOFT.SQL\" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in ('log_write_percent')\n| summarize LOG_IO_Maximum = max(Maximum), LOG_IO_Minimum = min(Minimum), LOG_IO_Average = avg(Average) by Resource , MetricName, _ResourceId\n",
          "timeAggregation": "Average",
          "metricMeasureColumn": "LOG_IO_Average",
          "dimensions": [],
          "resourceIdColumn": "_ResourceId",
          "operator": "GreaterThan",
          "threshold": 90.0,
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
  $functionURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-uk-resources-rg/providers/Microsoft.Web/sites/mos49/functions/SQL-server-log-IO-percent-connection?api-version=2015-08-01"
  Invoke-RestMethod -Uri $functionURI -Method Delete -Headers $header 

}

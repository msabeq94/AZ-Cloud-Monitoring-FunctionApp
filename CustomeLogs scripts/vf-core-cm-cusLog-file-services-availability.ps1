
$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}


$storageAccountAvailability = get-AzResource -ResourceGroupName "vf-core-UK-resources-rg" | Where-Object {$_.Name -eq "vf-core-cm-file-services-availability" -and $_.Type -eq "Microsoft.Insights/scheduledQueryRules" }

if ($storageAccountAvailability -eq $null) {

    $CustomAlertURI = "https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-file-services-availability?api-version=2021-08-01"

$CustomAlertbody = @"
{
  "id": "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-file-services-availability",
  "name": "vf-core-cm-file-services-availability",
  "type": "Microsoft.Insights/scheduledQueryRules",
  "location": "uksouth",
  "tags": {},
  "properties": {
    "createdWithApiVersion": "2023-03-15-preview",
    "displayName": "vf-core-cm-file-services-availability",
    "description": "",
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
    "criteria": {
      "allOf": [
        {
          "query": "AzureMetrics\n| where ResourceProvider == \"MICROSOFT.STORAGE\" // /DATABASES\n| where _ResourceId contains \"fileservices\" \n| where MetricName in ('Availability')\n| summarize AVL_fileservices_Max = max(Maximum), AVL_fileservices_Min = min(Minimum), AVL_fileservicesAvg = avg(Average) by Resource , MetricName, _ResourceId\n",
          "timeAggregation": "Average",
          "metricMeasureColumn": "AVL_fileservicesAvg",
          "dimensions": [],
          "resourceIdColumn": "_ResourceId",
          "operator": "LessThan",
          "threshold": 20.0,
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
  $functionURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-uk-resources-rg/providers/Microsoft.Web/sites/mos49/functions/file-services-availability?api-version=2015-08-01"
  Invoke-RestMethod -Uri $functionURI -Method Delete -Headers $header 

}

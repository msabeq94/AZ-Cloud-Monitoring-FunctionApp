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


$storageAccountAvailability = get-AzResource -ResourceGroupName "vf-core-UK-resources-rg" | Where-Object {$_.Name -eq "vf-core-cm-blob-services-availability" -and $_.Type -eq "Microsoft.Insights/scheduledQueryRules" }

if ($storageAccountAvailability -eq $null) {

    $CustomAlertURI = "https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-blob-services-availability?api-version=2021-08-01"

$CustomAlertbody = @"
{
    "id": "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-blob-services-availability",
    "name": "vf-core-cm-blob-services-availability",
    "type": "Microsoft.Insights/scheduledQueryRules",
    "location": "uksouth",
    "tags": {},
    "systemData": {
      "createdBy": "mohamed.omar18@live.com",
      "createdByType": "User",
      "createdAt": "2024-07-21T07:17:12.1513586Z",
      "lastModifiedBy": "mohamed.omar18@live.com",
      "lastModifiedByType": "User",
      "lastModifiedAt": "2024-07-21T07:17:12.1513586Z"
    },
    "properties": {
      "createdWithApiVersion": "2023-03-15-preview",
      "displayName": "vf-core-cm-blob-services-availabilit",
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
            "query": "AzureMetrics\n| where ResourceProvider == \"MICROSOFT.STORAGE\" // /DATABASES\n| where _ResourceId contains \"blobservices\" \n| where MetricName in ('Availability')\n| summarize AVL_blob_Max = max(Maximum), AVL_blob_Min = min(Minimum), AVL_blob_Avg = avg(Average) by Resource , MetricName, _ResourceId\n",
            "timeAggregation": "Average",
            "metricMeasureColumn": "AVL_blob_Avg",
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
  $functionURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-uk-resources-rg/providers/Microsoft.Web/sites/VF-Core-Function/functions/blob-services-availability?api-version=2015-08-01"
  Invoke-RestMethod -Uri $functionURI -Method Delete -Headers $header 

}

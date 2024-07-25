# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    write-output "PowerShell timer is running late!"
}

# Write an information log with the current time.
write-output "PowerShell timer trigger function ran! TIME: $currentUTCtime"



$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}


$storageAccountAvailability = get-AzResource -ResourceGroupName "vf-core-UK-resources-rg" | Where-Object {$_.Name -eq "vf-core-cm-PostgreSQL-flexible-server-cpu-percent" -and $_.Type -eq "Microsoft.Insights/scheduledQueryRules" }

if ($storageAccountAvailability -eq $null) {

    $CustomAlertURI = "https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-PostgreSQL-flexible-server-cpu-percent?api-version=2021-08-01"

$CustomAlertbody = @"
{
    "id": "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-PostgreSQL-flexible-server-cpu-percent",
    "name": "vf-core-cm-PostgreSQL-flexible-server-cpu-percent",
    "type": "Microsoft.Insights/scheduledQueryRules",
    "location": "uksouth",
    "tags": {},
    "properties": {
      "createdWithApiVersion": "2023-03-15-preview",
      "displayName": "vf-core-cm-PostgreSQL-flexible-server-cpu-percent",
      "description": "The CPU percentage for a Azure PostgreSQL Flexible Server Database has been crossed the threshold value",
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
            "query": " AzureMetrics\n| where ResourceProvider == \"MICROSOFT.DBFORPOSTGRESQL\" // /DATABASES\n| where TimeGenerated >= ago(60min)\n| where MetricName in ('cpu_percent')\n| summarize CPU_Maximum = max(Maximum), CPU_Minimum = min(Minimum), CPU_Average = avg(Average) by Resource , MetricName, _ResourceId\n",
            "timeAggregation": "Average",
            "metricMeasureColumn": "CPU_Average",
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
        throw "Terminating exception occurred. Stopping the script."
      }
} else {
  $functionURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-uk-resources-rg/providers/Microsoft.Web/sites/VF-Core-Function/functions/PostgreSQL-flexible-server-cpu-percent?api-version=2015-08-01"
  Invoke-RestMethod -Uri $functionURI -Method Delete -Headers $header 

}

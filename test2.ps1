# Define variables for resource names and details
$ruleName = "vf-core-cm-blob-services-availability"
$resourceGroupName = "vf-core-UK-resources-rg"
$location = "uksouth"
$actionGroupId = "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/actiongroups/vf-core-cm-notifications"
$scope = "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/VF-CloudMonitoring"

# Define the query
$query = @"
AzureMetrics
| where ResourceProvider == "MICROSOFT.STORAGE" // /DATABASES
| where _ResourceId contains "blobservices"
| where MetricName in ('Availability')
| summarize AVL_blob_Max = max(Maximum), AVL_blob_Min = min(Minimum), AVL_blob_Avg = avg(Average) by Resource, MetricName, _ResourceId
"@

# Convert evaluation frequency and window size to TimeSpan
$evaluationFrequency = [System.TimeSpan]::Parse("00:05:00") # PT5M
$windowSize = [System.TimeSpan]::Parse("00:05:00") # PT5M

# Create the criteria
$criteria = @{
    query = $query
    timeAggregation = "Average"
    metricMeasureColumn = "AVL_blob_Avg"
    resourceIdColumn = "_ResourceId"
    operator = "LessThan"
    threshold = 99
    failingPeriods = @{
        numberOfEvaluationPeriods = 1
        minFailingPeriodsToAlert = 1
    }
}

# Create the scheduled query rule
New-AzScheduledQueryRule -ResourceGroupName $resourceGroupName -Location $location `
-Name $ruleName -Description "Storage Account Blob Service Availability has been below threshold value" `
 -Enabled $true  -Action $actionGroupId -Scope $scope

 $query = @"
 AzureMetrics
 | where ResourceProvider == "MICROSOFT.STORAGE" // /DATABASES
 | where _ResourceId contains "blobservices"
 | where MetricName in ('Availability')
 | summarize AVL_blob_Max = max(Maximum), AVL_blob_Min = min(Minimum), AVL_blob_Avg = avg(Average) by Resource, MetricName, _ResourceId
"@
 $source = New-AzScheduledQueryRuleSource -Query  $query
 
 $accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

 $header = @{
     "Authorization" = "Bearer $accessToken"
     "Content-Type" = "application/json"
 }


 $AllMatricURI = "https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/scheduledqueryrules/vf-core-cm-storage-account-availability?api-version=2021-08-01"

 $MAexistingmetricalerts = Invoke-RestMethod -Uri $AllMatricURI -Method get -Headers $header | Convertto-Json -Depth 100
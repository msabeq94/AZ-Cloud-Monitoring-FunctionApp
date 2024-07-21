$subscriptionId = (Get-AzContext).Subscription.Id
$metric = @()
$log = @()
$metric += New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category AllMetrics -RetentionPolicyDay 7 -RetentionPolicyEnabled $true
$log += New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category ContainerEventLogs -RetentionPolicyDay 7 -RetentionPolicyEnabled $true
New-AzDiagnosticSetting -Name test-setting -ResourceId $resource.ResourceId  -WorkspaceId $workspaceId -Log $log -Metric $metric




$KV = Get-AzKeyVault -ResourceGroupName <resource group name> -VaultName <key vault name>
$Law = Get-AzOperationalInsightsWorkspace -ResourceGroupName <resource group name> -Name <workspace name>  # LAW name is case sensitive

$metric = New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category AllMetrics
# For all available logs, use:
$log = New-AzDiagnosticSettingLogSettingsObject -Enabled $true -CategoryGroup allLogs  
# or, for audit logs, use:
   
New-AzDiagnosticSetting -Name 'KeyVault-Diagnostics' -ResourceId $resource.ResourceId -WorkspaceId $workspaceId -Log $log -Metric $metric -Verbose






$metric = @()
$log = @()
$metric += New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category AllMetrics -RetentionPolicyDay 7 -RetentionPolicyEnabled $true
#$log += New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category ContainerEventLogs -RetentionPolicyDay 7 -RetentionPolicyEnabled $true
New-AzDiagnosticSetting -Name test-setting -ResourceId "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/VF-CloudMonitoring/providers/Microsoft.Storage/storageAccounts/msabeq111324352413" -WorkspaceId $workspaceId -Log $log -Metric $metric




$subscriptionId = (Get-AzContext).Subscription.Id
$metric = @()
$log = @()
$categories = Get-AzDiagnosticSettingCategory -ResourceId "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/VF-CloudMonitoring/providers/Microsoft.Storage/storageAccounts/msabeq111324352413"
$categories | ForEach-Object {if($_.CategoryType -eq "Metrics"){$metric+=New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category $_.Name } else{$log+=New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_.Name }}
New-AzDiagnosticSetting -Name test-setting -ResourceId "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/VF-CloudMonitoring/providers/Microsoft.Storage/storageAccounts/msabeq111324352413" -WorkspaceId $workspaceId -Log $log -Metric $metric






$metric = New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category Transaction -RetentionPolicyDay 7 -RetentionPolicyEnabled $true
New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $ResourceId -WorkspaceId $WorkspaceId -Metric $metric

$Ids = @($ResourceId + "/blobServices/default"
        $ResourceId + "/fileServices/default"
        $ResourceId + "/queueServices/default"
        $ResourceId + "/tableServices/default"
)
$Ids | ForEach-Object {
    $metric = @()
    $log = @()
    $categories = Get-AzDiagnosticSettingCategory -ResourceId $_
    $categories | ForEach-Object {if($_.CategoryType -eq "Metrics"){$metric+=New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category $_.Name -RetentionPolicyDay 7 -RetentionPolicyEnabled $true} else{$log+=New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_.Name -RetentionPolicyDay 7 -RetentionPolicyEnabled $true}}
    New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $_ -WorkspaceId $WorkspaceId -Log $log -Metric $metric
}


$CheckDiagnosticSetting = Get-AzDiagnosticSetting -ResourceId $resource.ResourceId | Where-Object {$_.Name -eq $DiagnosticSettingName}

if ($CheckDiagnosticSetting -eq $null) {
    $metric = @()
    $log = @()
    $categories = Get-AzDiagnosticSettingCategory -ResourceId $resource.ResourceId
    $categories | ForEach-Object {if($_.CategoryType -eq "Metrics"){$metric+=New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category $_.Name } else{$log+=New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_.Name }}
    New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $resource.ResourceId -WorkspaceId $workspaceId -Log $log -Metric $metric
    write-host "Diagnostic settings created for $($resource.Name) in $($resourceGroup.ResourceGroupName)  || $($resource.Type)"
}
else {
    write-host "Diagnostic settings already exist for $($resource.Name) in $($resourceGroup.ResourceGroupName)  || $($resource.Type)"
}


#i want to creat Custom log search alert for the below query
#AzureMetrics
| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL" // /DATABASES
| where TimeGenerated >= ago(60min)
| where MetricName in ('cpu_percent')
| summarize CPU_Maximum = max(Maximum), CPU_Minimum = min(Minimum), CPU_Average = avg(Average) by Resource , MetricName, _ResourceId



# Define parameters
$resourceGroup = "vf-core-UK-resources-rg"
$alertRuleName = "vf-core-cm-PostgreSQL-flexible-server-cpu-percent"
$actionGroupId = "f0d7ba94-8d18-42c7-8eb5-c375d7a4303c"
$location = "uksouth"
$query = @"
AzureMetrics
| where ResourceProvider == "MICROSOFT.DBFORPOSTGRESQL"
| where TimeGenerated >= ago(60min)
| where MetricName in ('cpu_percent')
| summarize CPU_Maximum = max(Maximum), CPU_Minimum = min(Minimum), CPU_Average = avg(Average) by Resource , MetricName, _ResourceId
"@

# Create a new log alert rule
New-AzScheduledQueryRule -ResourceGroupName $resourceGroup -Location $location -ActionGroup $actionGroupId -Query $query -Description "PostgreSQL CPU usage alert" -Enabled 1 -Frequency 5 -TimeWindow 5 -Severity 3 -Name $alertRuleName


New-AzScheduledQueryRule -ResourceGroupName $resourceGroup -Location $location `
-Name "vf-core-cm-storage-account-availability-$resourceGroup" -Description "Storage Account Availability has been below threshold value" `
 -Severity "0" -Source `
@"
AzureMetrics
| where ResourceProvider == "MICROSOFT.STORAGE" // /DATABASES
| where TimeGenerated >= ago(60m)
| where MetricName in ("Availability")
| summarize AVL_Storage_Max = max(Maximum), AVL_Storage_Min = min(Minimum), AVL_Storage_Avg = avg(Average) by Resource, MetricName, ResourceId
"@ -TimeWindow "PT60M" -Frequency "PT5M" -Operator "LessThan" -Threshold "20" -TargetResourceType "Resource" -MetricName "AVL_Storage_Avg" `
-SplitByDimension "Resource" -IncludeAllDimensions


$source =  '
| where ResourceProvider == "MICROSOFT.STORAGE"
| where TimeGenerated >= ago(60m)
| where MetricName in ("Availability")
| summarize AVL_Storage_Max = max(Maximum), AVL_Storage_Min = min(Minimum), AVL_Storage_Avg = avg(Average) by Resource, MetricName, ResourceId' -DataSourceId "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.OperationalInsights/workspaces/ vf-core-log-analytics"

 -FrequencyInMinutes 5 -TimeWindowInMinutes 60

$metricTrigger = New-AzScheduledQueryRuleLogMetricTrigger -ThresholdOperator "LessThan" -Threshold 20 -MetricTriggerType "Average" -MetricColumn "AVL_Storage_Avg"

$triggerCondition = New-AzScheduledQueryRuleTriggerCondition -ThresholdOperator "LessThan" -Threshold 20 -MetricTrigger $metricTrigger

$aznsActionGroup = New-AzScheduledQueryRuleAznsActionGroup -ActionGroup "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/actiongroups/vf-core-cm-notifications" -EmailSubject "Storage Account Availability Alert" -CustomWebhookPayload "{ `"alert`":`"vf-core-cm-storage-account-availability`", `"IncludeSearchResults`":true }"

$alertingAction = New-AzScheduledQueryRuleAlertingAction -AznsAction $aznsActionGroup -Severity "0" -Trigger $triggerCondition

New-AzScheduledQueryRule -ResourceGroupName "vf-core-UK-resources-rg" -Location "uksouth" -FrequencyInMinutes 5  -ThresholdOperator "LessThan" -Threshold 20 -MetricTriggerType "Average" -MetricColumn "AVL_Storage_Avg" -TimeWindowInMinutes 60 -Action "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/actiongroups/vf-core-cm-notifications" -Enabled $true -Description "Storage Account Availability has been below threshold value"  -Source $source -Name "vf-core-cm-storage-account-availability"





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
-DisplayName $ruleName -Severity 0 -Enabled $true -EvaluationFrequency $evaluationFrequency `
-WindowSize $windowSize -TargetResourceType "Microsoft.Storage/storageAccounts" `
-Criteria $criteria -ActionGroupId $actionGroupId -Scope $scope

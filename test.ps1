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


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


$tagKey = "vf-core-cloud-monitoring"
$tagValue = "true"

$LogAnalytics =  get-AzResource -ResourceType "Microsoft.OperationalInsights/workspaces" | Where-Object {$_.Name -eq "vf-core-log-analytics"}
$workspaceId = $LogAnalytics.ResourceId
$DiagnosticSettingName = "vf-core-cm-diag-setting" 
# Get all resources in the resource group that have the specific tag
$resourceGroups = Get-AzResourceGroup | Where-Object { $_.Tags -and $_.Tags[$tagKey] -eq $tagValue }


foreach ($resourceGroup in $resourceGroups) {
    $resources = Get-AzResource -ResourceGroupName $resourceGroup.ResourceGroupName | Where-Object { $_.ResourceType -eq "Microsoft.DBforPostgreSQL/flexibleServers" -or $_.ResourceType -eq "Microsoft.Sql/servers/databases" -or $_.ResourceType -eq "Microsoft.DBforMySQL/flexibleServers"  -or $_.ResourceType -eq "Microsoft.Network/applicationGateways"  
 }
    # Loop through each resource
    foreach ($resource in $resources) {
        $CheckDiagnosticSetting = Get-AzDiagnosticSetting -ResourceId $resource.ResourceId | Where-Object {$_.Name -eq $DiagnosticSettingName}

    if ($CheckDiagnosticSetting -eq $null) {
        $metric = @()
        $log = @()
        $categories = Get-AzDiagnosticSettingCategory -ResourceId $resource.ResourceId
        $categories | ForEach-Object {if($_.CategoryType -eq "Metrics"){$metric+=New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category $_.Name } else{$log+=New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_.Name }}
        $DiagnosticSettingSET = New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $resource.ResourceId -WorkspaceId $workspaceId -Log $log -Metric $metric
        Write-Output "Diagnostic settings created for $($resource.Name) in $($resourceGroup.ResourceGroupName)  || $($resource.Type)"
    }
    else {
        Write-Output "Diagnostic settings already exist for $($resource.Name) in $($resourceGroup.ResourceGroupName)  || $($resource.Type)"
    }
}
}




$StorgeresourceGroups = Get-AzResourceGroup | Where-Object { $_.Tags -and $_.Tags[$tagKey] -eq $tagValue }
foreach ($StorgeresourceGroup in $StorgeresourceGroups) {
    $Storgeresources = Get-AzResource -ResourceGroupName $StorgeresourceGroup.ResourceGroupName | Where-Object {$_.ResourceType -eq "Microsoft.Storage/storageAccounts"}
    # Loop through each resource
    foreach ($Storgeresource in $Storgeresources) {
        $StorgeCheckDiagnosticSetting = Get-AzDiagnosticSetting -ResourceId $Storgeresource.ResourceId | Where-Object {$_.Name -eq $DiagnosticSettingName}

    if ($StorgeCheckDiagnosticSetting -eq $null) {
        $Storgemetric = @()
        $Storgelog = @()
        $Storgecategories = Get-AzDiagnosticSettingCategory -ResourceId $Storgeresource.ResourceId
        $Storgecategories | ForEach-Object {if($_.CategoryType -eq "Metrics"){$Storgemetric+=New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category $_.Name } else{$Storgelog+=New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_.Name }}
        $StorgeDiagnosticSettingSET = New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $Storgeresource.ResourceId -WorkspaceId $workspaceId -Log $Storgelog -Metric $Storgemetric
        Write-Output "Diagnostic settings created for $($Storgeresource.Name) in $($StorgeresourceGroup.ResourceGroupName)  || $($Storgeresource.Type)"
        $StorgeResourceId = $Storgeresource.ResourceId
        $StorgeIds = @($StorgeResourceId + "/blobServices/default"
                        $StorgeResourceId + "/fileServices/default"
                        #$StorgeResourceId + "/queueServices/default"
                        #$StorgeResourceId + "/tableServices/default"
        )
    $StorgeIds | ForEach-Object {
        $StorgeAmetric = @()
        $StorgeAlog = @()
        $StorgeAcategories = Get-AzDiagnosticSettingCategory -ResourceId $_
        $StorgeAcategories | ForEach-Object {if($_.CategoryType -eq "Metrics"){$StorgeAmetric+=New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category $_.Name} else{$StorgeAlog+=New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_.Name }}
        $StorgeOneDiagnosticSettingSET = New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $_ -WorkspaceId $WorkspaceId -Log $StorgeAlog -Metric $StorgeAmetric
        Write-Output "Diagnostic settings created for $($Storgeresource.Name) in $($StorgeresourceGroup.ResourceGroupName)  || $($Storgeresource.Type)"
    }
}
else {
    Write-Output "Diagnostic settings already exist for $($Storgeresource.Name) in $($StorgeresourceGroup.ResourceGroupName)  || $($Storgeresource.Type)"
}
}
}



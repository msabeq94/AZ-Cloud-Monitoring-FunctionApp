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
        write-host "Diagnostic settings created for $($Storgeresource.Name) in $($StorgeresourceGroup.ResourceGroupName)  || $($Storgeresource.Type)"
        $StorgeResourceId = $Storgeresource.ResourceId
        $StorgeIds = @($StorgeResourceId + "/blobServices/default"
                        $StorgeResourceId + "/fileServices/default"
                        $StorgeResourceId + "/queueServices/default"
                        $StorgeResourceId + "/tableServices/default"
        )
    $StorgeIds | ForEach-Object {
        $StorgeAmetric = @()
        $StorgeAlog = @()
        $StorgeAcategories = Get-AzDiagnosticSettingCategory -ResourceId $_
        $StorgeAcategories | ForEach-Object {if($_.CategoryType -eq "Metrics"){$StorgeAmetric+=New-AzDiagnosticSettingMetricSettingsObject -Enabled $true -Category $_.Name} else{$StorgeAlog+=New-AzDiagnosticSettingLogSettingsObject -Enabled $true -Category $_.Name }}
        $StorgeOneDiagnosticSettingSET = New-AzDiagnosticSetting -Name $DiagnosticSettingName -ResourceId $_ -WorkspaceId $WorkspaceId -Log $StorgeAlog -Metric $StorgeAmetric
        write-host "Diagnostic settings created for $($Storgeresource.Name) in $($StorgeresourceGroup.ResourceGroupName)  || $($Storgeresource.Type)"
    }
}
else {
    write-host "Diagnostic settings already exist for $($Storgeresource.Name) in $($StorgeresourceGroup.ResourceGroupName)  || $($Storgeresource.Type)"
}
}
}



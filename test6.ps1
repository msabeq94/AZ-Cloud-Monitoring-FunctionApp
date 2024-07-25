# Retrieve access token and set headers
$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token
$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# Define the URI for the resource group's health alert
$RGhealthURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-UK-resources-rg/providers/microsoft.insights/activityLogAlerts/vf-core-cm-resource-health-alert?api-version=2017-04-01"

$tagKey = "vf-core-cloud-monitoring"
$tagValue = "true"

# Retrieve the existing alert condition
$RGAlert = Invoke-RestMethod -Uri $RGhealthURI -Method Get -Headers $header 
$RGScope = $RGAlert.properties.condition.allOf | Where-Object { $_.field -eq "resourceGroup" }

# Retrieve resource groups with the specified tag
$resourceGroups = Get-AzResourceGroup | Where-Object { $_.Tags -and $_.Tags[$tagKey] -eq $tagValue }

foreach ($resourceGroup in $resourceGroups) {
    # Create a new resource group condition
    $newResourceGroup = @{
        "field" = "resourceGroup"
        "equals" = $resourceGroup.ResourceGroupName
    }

    # Check if the resource group already exists in the alert
    $resourceGroupExists = $RGScope | Where-Object { $_.equals -eq $resourceGroup.ResourceGroupName }
    if (-not $resourceGroupExists) {
        # Update the alert with the new resource group
        $NEWRGScope = $RGScope + $newResourceGroup
        $NEWRGScopeJSON = $NEWRGScope | ConvertTo-Json -Depth 10

        $NEWRTyScope = $RGAlert.properties.condition.allOf | Where-Object { $_.field -eq "resourceType" }

        # Define the new condition for the alert
        $AzLogAlertRuleExistingCondition = @"
        {
            "allOf": [
                {
                    "field": "category",
                    "equals": "ResourceHealth"
                },
                {
                    "anyOf": $NEWRGScopeJSON
                },
                {
                    "anyOf": $NEWRTyScope | ConvertTo-Json -Depth 10
                }
            ]
        }
"@

        # Define the body for the PUT request
        $BodyAzLogAlertRule = @"
        {
            "id": "$($RGAlert.id)",
            "name": "$($RGAlert.name)",
            "type": "Microsoft.Insights/ActivityLogAlerts",
            "location": "global",
            "tags": $($RGAlert.tags | ConvertTo-Json -Depth 10),
            "properties": {
                "scopes": $($RGAlert.properties.scopes | ConvertTo-Json -Depth 10),
                "condition": $AzLogAlertRuleExistingCondition,
                "actions": $($RGAlert.properties.actions | ConvertTo-Json -Depth 10),
                "enabled": true,
                "description": "$($RGAlert.properties.description)"
            }
        }
"@

        # Update the alert with the new configuration
        $RGAlertPUT = Invoke-RestMethod -Uri $RGhealthURI -Method Put -Headers $header -Body $BodyAzLogAlertRule
        $RGScopeUpdate = $RGAlertPUT.properties.condition.allOf | Where-Object { $_.field -eq "resourceGroup" }
        Write-Output $RGScopeUpdate
        Start-Sleep -Seconds 5
    } else {
        Write-Host "Resource Group already exists in the alert"
    }
}



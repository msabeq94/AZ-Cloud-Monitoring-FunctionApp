$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$CustomAlertbody = @"
{
    "id": "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/VF-CloudMonitoring/providers/microsoft.insights/activitylogalerts/vf-core-cm-resource-health-alerttest",
    "name": "vf-core-cm-resource-health-alerttest",
    "type": "Microsoft.Insights/ActivityLogAlerts",
    "location": "global",
    "tags": {},
    "properties": {
        "scopes": [
            "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f"
        ],
        "condition": {
            "allOf": [
                {
                    "field": "category",
                    "equals": "ServiceHealth"
                },
                {
                    "field": "properties.impactedServices[*].ServiceName",
                    "containsAny": [
                        "Azure API for FHIR"
                    ]
                },
                {
                    "field": "properties.impactedServices[*].ImpactedRegions[*].RegionName",
                    "containsAny": [
                        "Australia Central",
                        "Australia Central 2",
                        "Australia East",
                        "Australia Southeast",
                        "Brazil South",
                        "Brazil Southeast",
                        "Brazil US",
                        "Canada Central",
                        "Canada East",
                        "Central India",
                        "Central US",
                        "East Asia",
                        "East US",
                        "East US 2",
                        "France Central",
                        "France South",
                        "Germany North",
                        "Germany West Central",
                        "Israel Central",
                        "Italy North",
                        "Japan East",
                        "Japan West",
                        "Korea Central",
                        "Korea South",
                        "Mexico Central",
                        "North Central US",
                        "North Europe",
                        "Norway East",
                        "Norway West",
                        "Poland Central",
                        "Qatar Central",
                        "South Africa North",
                        "South Africa West",
                        "South Central US",
                        "Southeast Asia",
                        "South India",
                        "Spain Central",
                        "Sweden Central",
                        "Switzerland North",
                        "Switzerland West",
                        "UAE Central",
                        "UAE North",
                        "UK South",
                        "UK West",
                        "West Central US",
                        "West Europe",
                        "West India",
                        "West US",
                        "West US 2",
                        "West US 3",
                        "Global"
                    ]
                }
            ]
        },
        "actions": {
            "actionGroups": [
                {
                    "actionGroupId": "/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourcegroups/vf-core-uk-resources-rg/providers/microsoft.insights/actiongroups/ vf-core-cm-notifications",
                    "webhookProperties": {}
                }
            ]
        },
        "enabled": true,
        "description": "Resource Health Alert Notification"
    }
}
"@
$CustomAlertURI = "https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/VF-CloudMonitoring/providers/microsoft.insights/activitylogalerts/vf-core-cm-resource-health-alerttest?api-version=2017-04-01"
Invoke-RestMethod -Uri $CustomAlertURI -Method Put -Headers $header -Body $CustomAlertbody
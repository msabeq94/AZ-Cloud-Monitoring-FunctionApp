$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}
$storageAccountAvailability = get-AzResource -ResourceGroupName "vf-core-UK-resources-rg" | Where-Object {$_.Name -eq "vf-core-cm-MySQL-flexible-server-replica-lag" -and $_.Type -eq "Microsoft.Insights/scheduledQueryRules" }


if ($null -ne $storageAccountAvailability) {

    $functionURI ="https://management.azure.com/subscriptions/f5980816-b478-413b-ae0b-5fb6d820a88f/resourceGroups/vf-core-uk-resources-rg/providers/Microsoft.Web/sites/VF-Core-Function/functions/MySQL-flexible-server-replica-lag?api-version=2015-08-01"
  Invoke-RestMethod -Uri $functionURI -Method Delete -Headers $header  
{
    else
{
    Write-Host "Alert found for MySQL-flexible-server-replica-lag " }
}}

# Define the resource group name
$resourceGroupName = "vf-core-UK-resources-rg"

# Get all scheduled query rules in the resource group
$rules = Get-AzScheduledQueryRule -ResourceGroupName $resourceGroupName

# Loop through each rule and delete it
foreach ($rule in $rules) {
    Remove-AzScheduledQueryRule -ResourceGroupName $resourceGroupName -Name $rule.Name
    write-host "Deleted rule: " $rule.Name
}
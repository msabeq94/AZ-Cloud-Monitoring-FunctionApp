if ($NEWRGScope.count -eq 1) {
    $AzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV1
   
  }









  
  # Action to perform if the condition is true
  $AzLogAlertRuleExistingConditionV1 = @"
  {
      "allOf": [
          {
              "field": "category",
              "equals": "ResourceHealth"
          },
          {
              "anyOf": [
                  {
                    "field": "resourceGroup",
                    "equals": "$($equalsValueRG)"
                  },
                  {
                    "field": "resourceGroup",
                    "equals": "$($resourceGroup.resourceGroupName)"
                  }
                ]
          },
          {
              "anyOf": 
              $AzLogAlertRuleExistingConditionResourceType
          }
      ]
  }
"@


$AzLogAlertRuleExistingCondition = @"
{
    "allOf": [
        {
            "field": "category",
            "equals": "ResourceHealth"
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceGroup
        },
        {
            "anyOf": 
            $AzLogAlertRuleExistingConditionResourceType
        }
    ]
}
"@
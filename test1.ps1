if ($NEWRGScope.count -eq 1 -and $NEWRTyScope.count -eq 1) {
    $UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV1
   
  }elseif ($NEWRGScope.count -gt 1 -and $NEWRTyScope.count -eq 1) {
    $UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV2
  }
    elseif ($NEWRGScope.count -eq 1 -and $NEWRTyScope.count -gt 1) {
        $UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionv3
  } else {
    $UPAzLogAlertRuleExistingCondition = $AzLogAlertRuleExistingConditionV4
    
  }

# 1 RG and 1 RGTY
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
                  }
                ]
          },
          {
              "anyOf": [
                {
                  "field": "resourceType",
                  "equals": "$($equalsValueRGTY)"
                },
                {
                  "field": "resourceType",
                  "equals": "$($newResourceTypev1)"
                }
              ]
          }
      ]
  }
"@




#mut RG & Mut RGTY
$AzLogAlertRuleExistingConditionV4 = @"
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







#mult RG & one RGTY
  $AzLogAlertRuleExistingConditionV2 = @"
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
              "anyOf": [
                {
                  "field": "resourceType",
                  "equals": "$($equalsValueRGTY)"
                },
                {
                  "field": "resourceType",
                  "equals": "$($newResourceTypev1)"
                }
              ]
              
          }
      ]
  }
"@

#1 RG & mult RGTY
$AzLogAlertRuleExistingConditionV3 = @"
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

                ]
          },
          {
              "anyOf": [
                {
                  "field": "resourceType",
                  "equals": "$($equalsValueRGTY)"
                },
                {
                  "field": "resourceType",
                  "equals": "$($newResourceTypev1)"
                }
              ]
              
              
          }
      ]
  }
"@




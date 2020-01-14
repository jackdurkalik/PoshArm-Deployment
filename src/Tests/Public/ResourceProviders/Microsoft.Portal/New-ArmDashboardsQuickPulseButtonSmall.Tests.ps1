$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "New-ArmDashboardsQuickPulseButtonSmall" {
    $Depth = 99
    $ExpectedResourceName = 'SomeApplicationInsight'
    $ExpectedApplicationInsights = New-ArmApplicationInsightsResource -Name $ExpectedResourceName

    $ExpectedSubscriptionId = "SomeId"
    $ExpectedResourceGroupName = "SomeResourceGroup"
    
    Context "Unit tests" {
      It "Given valid ApplicationInsights object it returns '<Expected>'" -TestCases @(
        @{  
          SubscriptionId      = $ExpectedSubscriptionId
          ResourceGroupName   = $ExpectedResourceGroupName
          ApplicationInsights = $ExpectedApplicationInsights
          Expected            = [PSCustomObject][ordered]@{
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'ComponentId'
                  value = @{
                    Name           = $ExpectedResourceName
                    SubscriptionId = $ExpectedSubscriptionId
                    ResourceGroup  = $ExpectedResourceGroupName
                  }
                }, @{
                  name  = 'ResourceId'
                  value = $ExpectedApplicationInsights._ResourceId
                })
              type   = 'Extension/AppInsightsExtension/PartType/QuickPulseButtonSmallPart'
              asset  = @{
                idInputName = 'ComponentId'
                type        = 'ApplicationInsights'
              }
            }      
          }
        }
      ) {
        param(
          $SubscriptionId,
          $ResourceGroupName,
          $ApplicationInsights,
          $Expected
        )              
        
        $actual = New-ArmDashboardsQuickPulseButtonSmall -ApplicationInsights $ApplicationInsights `
          -SubscriptionId $SubscriptionId `
          -ResourceGroupName $ResourceGroupName

        ($actual | ConvertTo-Json -Compress -Depth $Depth | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -BeExactly ($Expected | ConvertTo-Json -Compress -Depth $Depth | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }


      $ExpectedException = "MismatchedPSTypeName"

      It "Given an invalid Application Insight, it throws '<Expected>'" -TestCases @(
        @{ ApplicationInsights = "ApplicationInsights"
          Expected             = $ExpectedException
        }
        @{ ApplicationInsights = [PSCustomObject]@{Name = "Value" }
          Expected             = $ExpectedException
        }
      ) { param($ApplicationInsights, $Expected)
        { New-ArmDashboardsQuickPulseButtonSmall -ApplicationInsights $ApplicationInsights `
            -SubscriptionId $ExpectedSubscriptionId `
            -ResourceGroupName $ExpectedResourceGroupName } | Should -Throw -ErrorId $Expected
      }

      Context "Integration tests" {
        It "Default" -Test {
          Invoke-IntegrationTest -ArmResourcesScriptBlock `
          {
            $part = New-ArmDashboardsQuickPulseButtonSmall -ApplicationInsights $ExpectedApplicationInsights `
              -SubscriptionId $ExpectedSubscriptionId `
              -ResourceGroupName $ExpectedResourceGroupName
              
            New-ArmResourceName "microsoft.portal/dashboards" `
            | New-ArmDashboardsResource -Location 'centralus' `
            | Add-ArmDashboardsPartsElement -Part $part `
            | Add-ArmResource
          }
        }
      }
    }
  }
}

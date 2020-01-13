$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "New-ArmDashboardsApplicationMap" {
    $Depth = 4
    $ApplicationInsights = New-ArmResourceName "microsoft.insights/components" `
    | New-ArmApplicationInsightsResource -Location "SomeLocation"

    $ExpectedSubscriptionId = 'subscriptionId'
    $ExpectedResourceGroupName = 'resource-group-name'

    Context "Unit tests" {
      It "Given a '<ApplicationInsights>', '<SubscriptionId>', '<ResourceGroupName>' it returns '<Expected>'" -TestCases @(
        @{ 
          ApplicationInsights = $ApplicationInsights
          SubscriptionId      = $ExpectedSubscriptionId
          ResourceGroupName   = $ExpectedResourceGroupName  
          Expected            = [PSCustomObject][ordered]@{
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'ComponentId'
                  value = @{
                    Name           = $ApplicationInsights.Name
                    SubscriptionId = $ExpectedSubscriptionId
                    ResourceGroup  = $ExpectedResourceGroupName
                  }
                }, 
                @{
                  name  = 'TimeContext'
                  value = @{
                    durationMs            = 86400000
                    endTime               = $null
                    createdTime           = $null
                    isInitialTime         = $false
                    grain                 = 1
                    useDashboardTimeRange = $false
                  }
                })
              type   = 'Extension/AppInsightsExtension/PartType/ApplicationMapPart'
              asset  = @{
                idInputName = 'ComponentId'
                type        = 'ApplicationInsights'
              }      
            }      
          }
        }
      ) {
        param($ApplicationInsights, $SubscriptionId, $ResourceGroupName, $Expected)

        $actual = New-ArmDashboardsApplicationMap -ApplicationInsights $ApplicationInsights -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName
        [datetime]::Parse($actual.metadata.inputs[1].value.createdTime) - (Get-Date) | Should -BeLessThan ([TimeSpan]::FromSeconds(10))
        $actual.metadata.inputs[1].value.createdTime = $null

        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }  

      $ExpectedException = "MismatchedPSTypeName"

      It "Given a parameter of incorrect type, it throws '<Expected>'" -TestCases @(
        @{ 
          ApplicationInsights = "ApplicationInsights"
          SubscriptionId      = $ExpectedSubscriptionId
          ResourceGroupName   = $ExpectedResourceGroupName  
          Expected            = $ExpectedException
        }
        @{
          ApplicationInsights = "ApplicationInsights"
          SubscriptionId      = $ExpectedSubscriptionId
          ResourceGroupName   = $ExpectedResourceGroupName  
          Expected            = $ExpectedException
        }) { param($ApplicationInsights, $SubscriptionId, $ResourceGroupName, $Expected)
        { New-ArmDashboardsApplicationMap -ApplicationInsights $ApplicationInsights -SubscriptionId $SubscriptionId `
            -ResourceGroupName $ResourceGroupName } | Should -Throw -ErrorId $Expected
      }
    }

    Context "Integration tests" {
      It "Default" -Test {
        Invoke-IntegrationTest -ArmResourcesScriptBlock `
        {
          $part = New-ArmDashboardsApplicationMap -ApplicationInsights $ApplicationInsights -SubscriptionId $ExpectedSubscriptionId `
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
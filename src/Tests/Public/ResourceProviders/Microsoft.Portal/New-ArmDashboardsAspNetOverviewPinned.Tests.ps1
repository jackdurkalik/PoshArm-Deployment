$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "New-ArmDashboardsAspNetOverviewPinned" {
    $Depth = 3
    $ApplicationInsights = New-ArmResourceName "microsoft.insights/components" `
    | New-ArmApplicationInsightsResource -Location "SomeLocation"

    Context "Unit tests" {
      It "Given a '<ApplicationInsights>' it returns '<Expected>'" -TestCases @(
        @{ 
          ApplicationInsights = $ApplicationInsights     
          Expected            = [PSCustomObject][ordered]@{
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs            = @(@{
                  name  = 'id'
                  value = $ApplicationInsights._ResourceId
                }, @{
                  name  = 'Version'
                  value = '1.0'
                })
              type              = 'Extension/AppInsightsExtension/PartType/AspNetOverviewPinnedPart'
              asset             = @{
                idInputName = 'id'
                type        = 'ApplicationInsights'
              }
              defaultMenuItemId = 'overview'
            }      
          }
        }
      ) {
        param($ApplicationInsights, $Expected)

        $actual = New-ArmDashboardsAspNetOverviewPinned -ApplicationInsights $ApplicationInsights 
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }     

      $ExpectedException = "MismatchedPSTypeName"

      It "Given a parameter of incorrect type, it throws '<Expected>'" -TestCases @(
        @{ 
          ApplicationInsights = "ApplicationInsights"
          Expected            = $ExpectedException
        }
        @{
          ApplicationInsights = "ApplicationInsights"
          Expected            = $ExpectedException
        }) { param($ApplicationInsights, $Expected)
        { New-ArmDashboardsAspNetOverviewPinned -ApplicationInsights $ApplicationInsights } | Should -Throw -ErrorId $Expected
      }
    }

    Context "Integration tests" {
      It "Default" -Test {
        Invoke-IntegrationTest -ArmResourcesScriptBlock `
        {
          $part = New-ArmDashboardsAspNetOverviewPinned -ApplicationInsights $ApplicationInsights

          New-ArmResourceName "microsoft.portal/dashboards" `
          | New-ArmDashboardsResource -Location 'centralus' `
          | Add-ArmDashboardsPartsElement -Part $part `
          | Add-ArmResource
        }
      }
    }
  }
}
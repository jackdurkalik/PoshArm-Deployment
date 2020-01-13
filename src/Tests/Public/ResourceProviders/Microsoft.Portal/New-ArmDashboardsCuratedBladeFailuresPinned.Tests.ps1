$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "New-ArmDashboardsCuratedBladeFailuresPinned" {
    $Depth = 5
    $ApplicationInsights = New-ArmResourceName "microsoft.insights/components" `
    | New-ArmApplicationInsightsResource -Location "SomeLocation"

    Context "Unit tests" {
      It "Given a '<ApplicationInsights>' it returns '<Expected>'" -TestCases @(
        @{ 
          ApplicationInsights = $ApplicationInsights     
          Expected            = [PSCustomObject] @{
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs            = @(@{
                  name  = 'ResourceId'
                  value = $ApplicationInsights._ResourceId
                }, 
                @{
                  name       = 'DataModel'
                  value      = @{    
                    version     = '1.0.0'               
                    timeContext = @{
                      durationMs            = 86400000
                      endTime               = $null
                      createdTime           = $null
                      isInitialTime         = $false
                      grain                 = 1
                      useDashboardTimeRange = $false
                    }                    
                  }
                  isOptional = $true
                })
              type              = 'Extension/AppInsightsExtension/PartType/CuratedBladeFailuresPinnedPart'
              isAdapter         = $true
              asset             = @{
                idInputName = 'ComponentId'
                type        = 'ApplicationInsights'
              }      
              defaultMenuItemId = 'failures'
            }      
          }
        }
      ) {
        param($ApplicationInsights, $Expected)

        $actual = New-ArmDashboardsCuratedBladeFailuresPinned -ApplicationInsights $ApplicationInsights 
        [datetime]::Parse($actual.metadata.inputs[1].value.timeContext.createdTime) - (Get-Date) | Should -BeLessThan ([TimeSpan]::FromSeconds(5))
        $actual.metadata.inputs[1].value.timeContext.createdTime = $null
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
        { New-ArmDashboardsCuratedBladeFailuresPinned -ApplicationInsights $ApplicationInsights } | Should -Throw -ErrorId $Expected
      }
    }

    Context "Integration tests" {
      It "Default" -Test {
        Invoke-IntegrationTest -ArmResourcesScriptBlock `
        {
          $part = New-ArmDashboardsCuratedBladeFailuresPinned -ApplicationInsights $ApplicationInsights

          New-ArmResourceName "microsoft.portal/dashboards" `
          | New-ArmDashboardsResource -Location 'centralus' `
          | Add-ArmDashboardsPartsElement -Part $part `
          | Add-ArmResource
        }
      }
    }
  }
}
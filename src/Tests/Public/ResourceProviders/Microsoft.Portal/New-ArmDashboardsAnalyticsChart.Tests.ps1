$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "New-ArmDashboardsAnalyticsChart" {
    $Depth = 6
    $Source = New-ArmResourceName "microsoft.insights/components" `
    | New-ArmApplicationInsightsResource -Location "SomeLocation"

    $ExpectedSubscriptionId = 'subscriptionId'
    $ExpectedResourceGroupName = 'resource-group-name'
    $ExpectedQuery = 'query exemple'
    $ExpectedResourceType = 'resource-type'
    $ExpectedChartType = 'chart-type'
    $ExpectedTitle = 'title'
    $ExpectedSubtitle = 'subtitle'

    Context "Unit tests" {
      It "Given a '<Source>', '<SubscriptionId>', '<ResourceGroupName>', '<Query>', '<Dimensions>', '<ResourceType>',
       '<ChartType>', '<Title>', '<SubTitle>' it returns '<Expected>'" -TestCases @(
        @{ 
          Source            = $Source
          SubscriptionId    = $ExpectedSubscriptionId
          ResourceGroupName = $ExpectedResourceGroupName
          Query             = $ExpectedQuery
          ResourceType      = $ExpectedResourceType
          ChartType         = $ExpectedChartType
          Title             = $ExpectedTitle
          SubTitle          = $ExpectedSubtitle        
          Expected          = [PSCustomObject][ordered]@{
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'ComponentId'
                  value = @{
                    Name           = $Source.Name
                    SubscriptionId = $ExpectedSubscriptionId
                    ResourceGroup  = $ExpectedResourceGroupName
                    ResourceId     = $Source._ResourceId
                  }
                }, @{
                  name  = 'Query'
                  value = $ExpectedQuery
                },
                @{
                  name  = 'Version'
                  value = 'v1.0'
                },
                @{
                  name  = 'PartTitle'
                  value = $ExpectedTitle
                }, @{
                  name  = 'PartSubTitle'
                  value = $ExpectedSubtitle
                }, @{
                  name  = 'resourceTypeMode'
                  value = $ExpectedResourceType
                }, @{
                  name  = 'ControlType'
                  value = 'AnalyticsChart'
                }, @{
                  name  = 'SpecificChart'
                  value = $ExpectedChartType
                })
              type   = 'Extension/AppInsightsExtension/PartType/AnalyticsPart'
              asset  = @{
                idInputName = 'ComponentId'
                type        = 'ApplicationInsights'
              }
            }      
          }
        }
      ) {
        param($Source, $SubscriptionId, $ResourceGroupName, $Query, $ResourceType, $ChartType, $Title, $SubTitle, $Expected)

        $actual = New-ArmDashboardsAnalyticsChart -Source $Source -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -Query $Query `
          -ResourceType $ResourceType -ChartType $ChartType -Title $Title -SubTitle $SubTitle
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })

        @('DashboardPart', 'AnalyticsChart') | ForEach-Object { $actual.PSTypeNames | Should -Contain $_ }
      }   

      $ExpectedException = "MismatchedPSTypeName"

      It "Given a parameter of incorrect type, it throws '<Expected>'" -TestCases @(
        @{ 
          Source            = 'Source'
          SubscriptionId    = $ExpectedSubscriptionId
          ResourceGroupName = $ExpectedResourceGroupName
          Query             = $ExpectedQuery
          ResourceType      = $ExpectedResourceType
          ChartType         = $ExpectedChartType
          Title             = $ExpectedTitle
          SubTitle          = $ExpectedSubtitle      
          Expected          = $ExpectedException
        }
        @{ 
          Source            = [PSCustomObject]@{Name = "Value" }
          SubscriptionId    = $ExpectedSubscriptionId
          ResourceGroupName = $ExpectedResourceGroupName
          Query             = $ExpectedQuery
          ResourceType      = $ExpectedResourceType
          ChartType         = $ExpectedChartType
          Title             = $ExpectedTitle
          SubTitle          = $ExpectedSubtitle      
          Expected          = $ExpectedException
        }) { param($Source, $SubscriptionId, $ResourceGroupName, $Query, $ResourceType, $ChartType, $Title, $SubTitle, $Expected)
        { New-ArmDashboardsAnalyticsChart -Source $Source -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -Query $Query `
            -ResourceType $ResourceType -ChartType $ChartType -Title $Title -SubTitle $SubTitle } | Should -Throw -ErrorId $Expected
      }
    }

    Context "Integration tests" {
      It "Default" -Test {
        Invoke-IntegrationTest -ArmResourcesScriptBlock `
        {
          $part = New-ArmDashboardsAnalyticsChart -Source $Source -SubscriptionId $ExpectedSubscriptionId `
            -ResourceGroupName $ExpectedResourceGroupName -Query $ExpectedQuery  -ResourceType $ExpectedResourceType `
            -ChartType $ExpectedChartType -Title $ExpectedTitle -SubTitle $SubTitle

          New-ArmResourceName "microsoft.portal/dashboards" `
          | New-ArmDashboardsResource -Location 'centralus' `
          | Add-ArmDashboardsPartsElement -Part $part `
          | Add-ArmResource
        }
      }
    }
  }
}
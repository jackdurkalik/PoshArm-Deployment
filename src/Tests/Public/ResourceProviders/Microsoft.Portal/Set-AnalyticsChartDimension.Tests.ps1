$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "Set-AnalyticsChartDimension" {
    $Depth = 2
    $ExpectedXName = 'TimeGenerated' 
    $ExpectedXType = 'datetime'
    $ExpectedYName = 'sum_Count'
    $ExpectedYType = 'long'
    $ExpectedAggregation = 'Sum'

    $Source = New-ArmResourceName "microsoft.insights/components" `
    | New-ArmApplicationInsightsResource -Location "SomeLocation"

    BeforeEach {
      $Chart = New-ArmDashboardsAnalyticsChart -Source $Source -SubscriptionId 'subscriptionId' -ResourceGroupName 'resource-group-name' -Query 'query exemple' `
        -ResourceType 'resource-type' -ChartType 'chart-type' -Title 'title' -SubTitle 'subtitle'
      $ExpectedChart = $Chart.PSObject.Copy()
    }   

    Context "Unit tests" {
      It "Given an '<xName>', '<xType>', '<yName>', '<yType>' and '<aggregation>' it set the chart dimension to '<ExpectedDimension>' " -TestCases @(
        @{ 
          XName             = $ExpectedXName
          XType             = $ExpectedXType
          YName             = $ExpectedYName
          YType             = $ExpectedYType
          Aggregation       = $ExpectedAggregation
          ExpectedDimension = [PSCustomObject]@{ 
            PSTypeName  = "ChartDimension"
            xAxis       = @{ 
              name = $ExpectedXName
              type = $ExpectedXType
            }
            yAxis       = @(
              @{
                name = $ExpectedYName
                type = $ExpectedYType
              })
            splitBy     = @(); 
            aggregation = $ExpectedAggregation
          }
        }
      ) {
        param($XName, $XType, $YName, $YType, $Aggregation, $ExpectedDimension)

        $ExpectedChart.metadata.inputs += $dimension

        $actual = $Chart | Set-AnalyticsChartDimension -xName $XName -xType $XType -yName $YName -yType $YType -aggregation $Aggregation
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($ExpectedChart | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }

      $ExpectedException = "MismatchedPSTypeName"

      It "Given a parameter of incorrect type, it throws '<Expected>'" -TestCases @(
        @{ 
          Chart       = "Chart"
          XName       = $ExpectedXName
          XType       = $ExpectedXType
          YName       = $ExpectedYName
          YType       = $ExpectedYType
          Aggregation = $ExpectedAggregation
          Expected    = $ExpectedException
        }
        @{ 
          Chart       = [PSCustomObject]@{Name = "Value" }
          XName       = $ExpectedXName
          XType       = $ExpectedXType
          YName       = $ExpectedYName
          YType       = $ExpectedYType
          Aggregation = $ExpectedAggregation
          Expected    = $ExpectedException
        }
      ) { param($Chart, $XName, $XType, $YName, $YType, $Aggregation, $ExpectedDimension)
        { Set-AnalyticsChartDimension -Chart $Chart -xName $XName -xType $XType -yName $YName -yType $YType -aggregation $Aggregation } `
        | Should -Throw -ErrorId $Expected
      }

      Context "Integration tests" {
        It "Default" -Test {
          Invoke-IntegrationTest -ArmResourcesScriptBlock `
          {
            $part = $Chart | Set-AnalyticsChartDimension -xName $ExpectedXName -xType $ExpectedXType -yName $ExpectedYName `
              -yType $ExpectedYType -aggregation $ExpectedAggregation
              
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
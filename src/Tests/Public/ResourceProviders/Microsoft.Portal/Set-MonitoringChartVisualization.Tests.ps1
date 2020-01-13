$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "Set-MonitoringChartVisualization" {
    $Depth = 2
    $ExpectedChartType = 2
    $ExpectedLegendVisible = $false
    $ExpectedLegendPosition = 2
    $ExpectedHideLegendSubtitle = $true
    $ExpectedXIsVisible = $false
    $ExpectedXAxisType = 2
    $ExpectedYIsVisible = $false
    $ExpectedYAxisType = 1
    $ExpectedMonitorChartName = "AlwaysPipeline"

    BeforeEach {
      $MonitorChart = $ExpectedMonitorChartName | New-ArmDashboardsMonitorChart
      $Expected = $MonitorChart.PSObject.Copy()
    }

    Context "Unit tests" {
      It "Given valid parameters, it sets '<ExpectedVisualization>' " -TestCases @(
        @{ 
          ChartType             = $ExpectedChartType
          LegendVisible         = $ExpectedLegendVisible
          LegendPosition        = $ExpectedLegendPosition
          HideLegendSubtitle    = $ExpectedHideLegendSubtitle
          XIsVisible            = $ExpectedXIsVisible
          XAxisType             = $ExpectedXAxisType
          YIsVisible            = $ExpectedYIsVisible
          YAxisType             = $ExpectedYAxisType
          ExpectedVisualization = [PSCustomObject]@{ 
            PSTypeName          = "ChartVisualization"
            chartType           = $ExpectedChartType
            legendVisualization = @{ 
              isVisible    = $ExpectedLegendVisible
              position     = $ExpectedLegendPosition
              hideSubtitle = $ExpectedHideLegendSubtitle 
            }
            axisVisualization   = @{ 
              x = @{ 
                isVisible = $ExpectedXIsVisible
                axisType  = $ExpectedXAxisType 
              }
              y = @{ 
                isVisible = $ExpectedYIsVisible
                axisType  = $ExpectedYAxisType
              } 
            } 
          }
          
        }
      ) {
        param($ChartType, $LegendVisible, $LegendPosition, $HideLegendSubtitle, $XIsVisible, $XAxisType, $YIsVisible, $YAxisType, $ExpectedVisualization)

        $Expected.metadata.inputs[0].value.chart.visualization = $ExpectedVisualization

        $actual = $MonitorChart | Set-MonitoringChartVisualization -ChartType $ChartType -LegendVisible $LegendVisible -LegendPosition $LegendPosition `
          -HideLegendSubtitle $HideLegendSubtitle -XIsVisible $XIsVisible -XAxisType $XAxisType -YIsVisible $YIsVisible -YAxisType $YAxisType
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })

        @('DashboardPart', 'MonitoringChart') | ForEach-Object { $actual.PSTypeNames | Should -Contain $_ }
      }

      $ExpectedException = "MismatchedPSTypeName"

      It "Given a parameter of incorrect type, it throws '<Expected>'" -TestCases @(
        @{ 
          Chart              = "Chart"
          ChartType          = $ExpectedChartType
          LegendVisible      = $ExpectedLegendVisible
          LegendPosition     = $ExpectedLegendPosition
          HideLegendSubtitle = $ExpectedHideLegendSubtitle
          XIsVisible         = $ExpectedXIsVisible
          XAxisType          = $ExpectedXAxisType
          YIsVisible         = $ExpectedYIsVisible
          YAxisType          = $ExpectedYAxisType
          Expected           = $ExpectedException
        }
        @{ 
          Chart              = [PSCustomObject]@{Name = "Value" }
          ChartType          = $ExpectedChartType
          LegendVisible      = $ExpectedLegendVisible
          LegendPosition     = $ExpectedLegendPosition
          HideLegendSubtitle = $ExpectedHideLegendSubtitle
          XIsVisible         = $ExpectedXIsVisible
          XAxisType          = $ExpectedXAxisType
          YIsVisible         = $ExpectedYIsVisible
          YAxisType          = $ExpectedYAxisType
          Expected           = $ExpectedException
        }) { param($Chart, $ChartType, $LegendVisible, $LegendPosition, $HideLegendSubtitle, $XIsVisible, $XAxisType, $YIsVisible, $YAxisType, $Expected)
        { Set-MonitoringChartVisualization -Chart $Chart -ChartType $ChartType -LegendVisible $LegendVisible -LegendPosition $LegendPosition `
            -HideLegendSubtitle $HideLegendSubtitle -XIsVisible $XIsVisible -XAxisType $XAxisType -YIsVisible $YIsVisible -YAxisType $YAxisType
        } | Should -Throw -ErrorId $Expected
      }
    }

    Context "Integration tests" {
      It "Default" -Test {
        Invoke-IntegrationTest -ArmResourcesScriptBlock `
        {
          $part = New-ArmDashboardsMonitorChart -Title 'Service Bus Requests' `
          | Set-MonitoringChartVisualization -ChartType $ExpectedChartType -LegendVisible $ExpectedLegendVisible `
            -LegendPosition $ExpectedLegendPosition -HideLegendSubtitle $ExpectedHideLegendSubtitle -XIsVisible $ExpectedXIsVisible `
            -XAxisType $ExpectedXAxisType -YIsVisible $ExpectedYIsVisible -YAxisType $ExpectedYAxisType
        
          New-ArmResourceName "microsoft.portal/dashboards" `
          | New-ArmDashboardsResource -Location 'centralus' `
          | Add-ArmDashboardsPartsElement -Part $part `
          | Add-ArmResource
        }
      }
    }      
  }
}
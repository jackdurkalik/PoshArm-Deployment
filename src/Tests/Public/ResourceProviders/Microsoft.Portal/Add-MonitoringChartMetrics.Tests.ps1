$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "Add-MonitoringChartMetrics" {
    $Depth = 9
    $ExpectedName = 'performanceCounters/processorCpuPercentage' 
    $ExpectedAggregationType = 4
    $ExpectedNamespace = 'microsoft.insights/components'
    $ExpectedDisplayName = 'Processor time'
    $ExpectedColor = '#47BDF5'
    $ExpectedResourceDisplayName = 'SomeResourceName'

    $ExpectedName2 = 'performanceCounters/processorCpuPercentage2' 
    $ExpectedAggregationType2 = 6
    $ExpectedNamespace2 = 'microsoft.insights/components2'
    $ExpectedDisplayName2 = 'Processor time2'
    $ExpectedColor2 = '#47BDF9'
    $ExpectedResourceDisplayName2 = 'SomeResourceName2'

    BeforeEach {
      $title = 'chart title'
      $Chart = $title | New-ArmDashboardsMonitorChart
      $ExpectedChart = $Chart.PSObject.Copy()
    }    

    $ApplicationInsights = New-ArmResourceName "microsoft.insights/components" `
    | New-ArmApplicationInsightsResource -Location "SomeLocation"

    Context "Unit tests" {
      It "Given an '<Id>', '<Name>', '<DisplayName>', '<Namespace>', '<AggregationType>', '<ResourceDisplayName>',
       '<Color>' it returns expected chart" -TestCases @(
        @{ 
          Color               = $ExpectedColor
          ResourceDisplayName = $ExpectedResourceDisplayName
          Namespace           = $ExpectedNamespace
          Name                = $ExpectedName
          Id                  = $ApplicationInsights._ResourceId
          DisplayName         = $ExpectedDisplayName
          AggregationType     = $ExpectedAggregationType 
          ExpectedMetric      = [PSCustomObject]@{
            PSTypeName          = "ChartMetric"
            resourceMetadata    = @{ id = $ApplicationInsights._ResourceId }
            name                = $ExpectedName;
            aggregationType     = $ExpectedAggregationType;
            namespace           = $ExpectedNamespace;
            metricVisualization = [PSCustomObject]@{              
              displayName         = $ExpectedDisplayName        
              resourceDisplayName = $ExpectedResourceDisplayName   
              color               = $ExpectedColor 
            }
          } 
        }      
      ) {
        param($Color, $ResourceDisplayName, $Namespace, $Name, $Id, $DisplayName, $AggregationType, $ExpectedMetric)

        $ExpectedChart.metadata.inputs[0].value.chart.metrics += $ExpectedMetric

        $actual = $Chart | Add-MonitoringChartMetrics -Color $Color -Namespace $Namespace -Name $Name -Id $Id -DisplayName $DisplayName -AggregationType $AggregationType -ResourceDisplayName $ResourceDisplayName
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($ExpectedChart | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }
      It "Given an '<Id>', '<Name>', '<DisplayName>', '<Namespace>', '<AggregationType>' it returns chart without resourceDisplayName or color" -TestCases @(
        @{ 
          Namespace       = $ExpectedNamespace
          Name            = $ExpectedName
          Id              = $ApplicationInsights._ResourceId
          DisplayName     = $ExpectedDisplayName
          AggregationType = $ExpectedAggregationType 
          ExpectedMetric  = [PSCustomObject]@{
            PSTypeName          = "ChartMetric"
            resourceMetadata    = @{ id = $ApplicationInsights._ResourceId }
            name                = $ExpectedName;
            aggregationType     = $ExpectedAggregationType;
            namespace           = $ExpectedNamespace;
            metricVisualization = [PSCustomObject]@{              
              displayName = $ExpectedDisplayName        
            }
          }
        }
      ) {
        param($Namespace, $Name, $Id, $DisplayName, $AggregationType, $ExpectedMetric)

        $ExpectedChart.metadata.inputs[0].value.chart.metrics += $ExpectedMetric

        $actual = $Chart | Add-MonitoringChartMetrics -Namespace $Namespace -Name $Name -Id $Id -DisplayName $DisplayName -AggregationType $AggregationType
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($ExpectedChart | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }
      It "Given multiple metrics they all get all added to '<Expected>' " -TestCases @(
        @{ 
          Color                = $ExpectedColor
          ResourceDisplayName  = $ExpectedResourceDisplayName
          Namespace            = $ExpectedNamespace
          Name                 = $ExpectedName
          Id                   = $ApplicationInsights._ResourceId
          DisplayName          = $ExpectedDisplayName
          AggregationType      = $ExpectedAggregationType 
          Color2               = $ExpectedColor2
          ResourceDisplayName2 = $ExpectedResourceDisplayName2
          Namespace2           = $ExpectedNamespace2
          Name2                = $ExpectedName2
          DisplayName2         = $ExpectedDisplayName2
          AggregationType2     = $ExpectedAggregationType2
          ExpectedMetrics      = @([PSCustomObject]@{
              PSTypeName          = "DashboardMetric"
              resourceMetadata    = @{ id = $ApplicationInsights._ResourceId }
              name                = $ExpectedName;
              aggregationType     = $ExpectedAggregationType;
              namespace           = $ExpectedNamespace;
              metricVisualization = [PSCustomObject]@{              
                displayName         = $ExpectedDisplayName        
                resourceDisplayName = $ExpectedResourceDisplayName   
                color               = $ExpectedColor 
              }
            }, [PSCustomObject]@{
              PSTypeName          = "DashboardMetric"
              resourceMetadata    = @{ id = $ApplicationInsights._ResourceId }
              name                = $ExpectedName2
              aggregationType     = $ExpectedAggregationType2
              namespace           = $ExpectedNamespace2
              metricVisualization = [PSCustomObject]@{              
                displayName         = $ExpectedDisplayName2        
                resourceDisplayName = $ExpectedResourceDisplayName2   
                color               = $ExpectedColor2
              }
            })
        }
      ) {
        param($Color, $ResourceDisplayName, $Namespace, $Name, $Id, $DisplayName, $AggregationType,
          $Color2, $ResourceDisplayName2, $Namespace2, $Name2, $DisplayName2, $AggregationType2, $ExpectedMetrics)

        $ExpectedChart.metadata.inputs[0].value.chart.metrics = $ExpectedMetrics

        $actual = $Chart | Add-MonitoringChartMetrics -Color $Color -Namespace $Namespace -Name $Name -Id $Id `
          -DisplayName $DisplayName -AggregationType $AggregationType -ResourceDisplayName $ResourceDisplayName `
        | Add-MonitoringChartMetrics -Color $Color2 -Namespace $Namespace2 -Name $Name2 -Id $Id -DisplayName $DisplayName2 `
          -AggregationType $AggregationType2 -ResourceDisplayName $ResourceDisplayName2
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($ExpectedChart | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }
      
      $ExpectedException = "MismatchedPSTypeName"

      It "Given a parameter of incorrect type, it throws '<Expected>'" -TestCases @(
        @{ 
          Chart           = "Chart"
          Namespace       = $ExpectedNamespace
          Name            = $ExpectedName
          Id              = $ApplicationInsights._ResourceId
          DisplayName     = $ExpectedDisplayName
          AggregationType = $ExpectedAggregationType 
          Expected        = $ExpectedException
        }
        @{ 
          Chart           = [PSCustomObject]@{Name = "Value" }
          Namespace       = $ExpectedNamespace
          Name            = $ExpectedName
          Id              = $ApplicationInsights._ResourceId
          DisplayName     = $ExpectedDisplayName
          AggregationType = $ExpectedAggregationType 
          Expected        = $ExpectedException
        }) { param($Chart, $Namespace, $Name, $Id, $DisplayName, $AggregationType, $ExpectedMetric)
        { Add-MonitoringChartMetrics -Chart $Chart -Namespace $Namespace -Name $Name -Id $Id -DisplayName $DisplayName `
            -AggregationType $AggregationType } | Should -Throw -ErrorId $Expected
      }
    }

    Context "Integration tests" {
      It "Default" -Test {
        Invoke-IntegrationTest -ArmResourcesScriptBlock `
        {
          $part = New-ArmDashboardsMonitorChart -Title 'Service Bus Requests' `
          | Add-MonitoringChartMetrics -ResourceDisplayName 'serviceBusName' -Namespace 'microsoft.servicebus/namespaces' `
            -Name 'IncomingRequests' -Id 'ServiceBusId' -DisplayName 'Incoming Requests' -AggregationType 1

          New-ArmResourceName "microsoft.portal/dashboards" `
          | New-ArmDashboardsResource -Location 'centralus' `
          | Add-ArmDashboardsPartsElement -Part $part `
          | Add-ArmResource
        }
      }
    }
  }
}

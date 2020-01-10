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

    $ApplicationInsights = New-ArmResourceName "microsoft.insights/components" `
    | New-ArmApplicationInsightsResource -Location "SomeLocation"

    Context "Unit tests" {
      It "Given an '<Id>', '<Name>', '<DisplayName>', '<Namespace>', '<AggregationType>', '<ResourceDisplayName>',
       '<Color>' and a <Chart> it returns '<Expected>' " -TestCases @(
        @{ 
          Chart               = [PSCustomObject][ordered]@{
            PSTypeName = "MonitoringChart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @()
                      title            = $ExpectedTitle
                      visualization    = $ExpectedVisualization
                      openBladeOnClick = @{ }
                    }
                  }
                })
              type   = 'Extension/HubsExtension/PartType/MonitorChartPart'  
            }    
          }
          Color               = $ExpectedColor
          ResourceDisplayName = $ExpectedResourceDisplayName
          Namespace           = $ExpectedNamespace
          Name                = $ExpectedName
          Id                  = $ApplicationInsights._ResourceId
          DisplayName         = $ExpectedDisplayName
          AggregationType     = $ExpectedAggregationType 
          Expected            = [PSCustomObject][ordered]@{
            PSTypeName = "MonitoringChart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @([PSCustomObject]@{
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
                        })
                      title            = $ExpectedTitle
                      visualization    = $ExpectedVisualization
                      openBladeOnClick = @{ }
                    }
                  }
                })
              type   = 'Extension/HubsExtension/PartType/MonitorChartPart'  
            }    
          }
        }
      ) {
        param($Chart, $Color, $ResourceDisplayName, $Namespace, $Name, $Id, $DisplayName, $AggregationType, $Expected)

        $actual = $Chart | Add-MonitoringChartMetrics -Color $Color -Namespace $Namespace -Name $Name -Id $Id -DisplayName $DisplayName -AggregationType $AggregationType -ResourceDisplayName $ResourceDisplayName
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }
      It "Given an '<Chart>', '<Id>', '<Name>', '<DisplayName>', '<Namespace>', '<AggregationType>' it returns '<Expected>' without resourceDisplayName or color" -TestCases @(
        @{ 
          Chart           = [PSCustomObject][ordered]@{
            PSTypeName = "MonitoringChart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @()
                      title            = $ExpectedTitle
                      visualization    = $ExpectedVisualization
                      openBladeOnClick = @{ }
                    }
                  }
                })
              type   = 'Extension/HubsExtension/PartType/MonitorChartPart'  
            }    
          }
          Namespace       = $ExpectedNamespace
          Name            = $ExpectedName
          Id              = $ApplicationInsights._ResourceId
          DisplayName     = $ExpectedDisplayName
          AggregationType = $ExpectedAggregationType 
          Expected        = [PSCustomObject][ordered]@{
            PSTypeName = "MonitoringChart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @([PSCustomObject]@{
                          PSTypeName          = "ChartMetric"
                          resourceMetadata    = @{ id = $ApplicationInsights._ResourceId }
                          name                = $ExpectedName;
                          aggregationType     = $ExpectedAggregationType;
                          namespace           = $ExpectedNamespace;
                          metricVisualization = [PSCustomObject]@{              
                            displayName = $ExpectedDisplayName        
                          }
                        })
                      title            = $ExpectedTitle
                      visualization    = $ExpectedVisualization
                      openBladeOnClick = @{ }
                    }
                  }
                })
              type   = 'Extension/HubsExtension/PartType/MonitorChartPart'  
            }    
          }
        }
      ) {
        param($Chart, $Namespace, $Name, $Id, $DisplayName, $AggregationType, $Expected)

        $actual = $Chart | Add-MonitoringChartMetrics -Namespace $Namespace -Name $Name -Id $Id -DisplayName $DisplayName -AggregationType $AggregationType
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }
      It "Given multiple metrics they all get all added to '<Expected>' " -TestCases @(
        @{ 
          Chart                = [PSCustomObject][ordered]@{
            PSTypeName = "MonitoringChart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @()
                      title            = $ExpectedTitle
                      visualization    = $ExpectedVisualization
                      openBladeOnClick = @{ }
                    }
                  }
                })
              type   = 'Extension/HubsExtension/PartType/MonitorChartPart'  
            }    
          }
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
          Id2                  = $ApplicationInsights._ResourceId
          DisplayName2         = $ExpectedDisplayName2
          AggregationType2     = $ExpectedAggregationType2
          Expected             = [PSCustomObject][ordered]@{
            PSTypeName = "MonitoringChart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @([PSCustomObject]@{
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
                      title            = $ExpectedTitle
                      visualization    = $ExpectedVisualization
                      openBladeOnClick = @{ }
                    }
                  }
                })
              type   = 'Extension/HubsExtension/PartType/MonitorChartPart'  
            }    
          }
        }
      ) {
        param($Chart, $Color, $ResourceDisplayName, $Namespace, $Name, $Id, $DisplayName, $AggregationType,
          $Color2, $ResourceDisplayName2, $Namespace2, $Name2, $Id2, $DisplayName2, $AggregationType2, $Expected)

        $actual = $Chart | Add-MonitoringChartMetrics -Color $Color -Namespace $Namespace -Name $Name -Id $Id `
          -DisplayName $DisplayName -AggregationType $AggregationType -ResourceDisplayName $ResourceDisplayName `
        | Add-MonitoringChartMetrics -Color $Color2 -Namespace $Namespace2 -Name $Name2 -Id $Id2 -DisplayName $DisplayName2 `
          -AggregationType $AggregationType2 -ResourceDisplayName $ResourceDisplayName2
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }        
    }
  }
}
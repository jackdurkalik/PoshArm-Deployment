$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "Add-MonitoringChartMetrics" {
    $Depth = 2
    $ExpectedName = 'performanceCounters/processorCpuPercentage' 
    $ExpectedAggregationType = 4
    $ExpectedNamespace = 'microsoft.insights/components'
    $ExpectedDisplayName = 'Processor time'
    $ExpectedColor = '#47BDF5'
    $ExpectedResourceDisplayName = 'SomeResourceName'

    $ApplicationInsights = New-ArmResourceName "microsoft.insights/components" `
    | New-ArmApplicationInsightsResource -Location "SomeLocation"

    Context "Unit tests" {
      It "Given an '<Id>', '<Name>', '<DisplayName>', '<Namespace>', '<AggregationType>', '<ResourceDisplayName>',
       '<Color>' and a <Chart> it returns '<Expected>' " -TestCases @(
        @{ 
          Dashboard           = [PSCustomObject][ordered]@{
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @{ }
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
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = [PSCustomObject]@{
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
                      }
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
        param($Dashboard, $Color, $ResourceDisplayName, $Namespace, $Name, $Id, $DisplayName, $AggregationType, $Expected)

        $actual = $Dashboard | Add-MonitoringChartMetrics -Color $Color -Namespace $Namespace -Name $Name -Id $Id -DisplayName $DisplayName -AggregationType $AggregationType -ResourceDisplayName $ResourceDisplayName
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }
      It "Given an '<Id>', '<Name>', '<DisplayName>', '<Namespace>', '<AggregationType>' it returns '<Expected>' without resourceDisplayName or color" -TestCases @(
        @{ 
          Namespace       = $ExpectedNamespace
          Name            = $ExpectedName
          Id              = $ApplicationInsights._ResourceId
          DisplayName     = $ExpectedDisplayName
          AggregationType = $ExpectedAggregationType 
          Expected        = [PSCustomObject][ordered]@{
            PSTypeName          = "DashboardMetric"
            resourceMetadata    = @{ id = $ApplicationInsights._ResourceId }
            name                = $ExpectedName;
            aggregationType     = $ExpectedAggregationType;
            namespace           = $ExpectedNamespace;
            metricVisualization = @{ 
              displayName = $ExpectedDisplayName
            }
          }
        }
      ) {
        param($Namespace, $Name, $Id, $DisplayName, $AggregationType, $Expected)

        $actual = New-MonitoringChartMetrics -Namespace $Namespace -Name $Name -Id $Id -DisplayName $DisplayName -AggregationType $AggregationType
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }
      It "Given multiple metrics they all get all added to '<Expected>' " -TestCases @(
        @{ 
          Dashboard           = [PSCustomObject][ordered]@{
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @{ }
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
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @(@{
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
                        }, @{
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
        param($Dashboard, $Color, $ResourceDisplayName, $Namespace, $Name, $Id, $DisplayName, $AggregationType, $Expected)

        $actual = $Dashboard | Add-MonitoringChartMetrics -Color $Color -Namespace $Namespace -Name $Name -Id $Id `
          -DisplayName $DisplayName -AggregationType $AggregationType -ResourceDisplayName $ResourceDisplayName `
        | Add-MonitoringChartMetrics -Color $Color -Namespace $Namespace -Name $Name -Id $Id -DisplayName $DisplayName `
          -AggregationType $AggregationType -ResourceDisplayName $ResourceDisplayName
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }        
    }
  }
}
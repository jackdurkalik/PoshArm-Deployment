function New-ArmDashboardsMonitorChart {
  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType("MonitoringChart")]
  Param(
    [string]
    [Parameter(Mandatory, ValueFromPipeline)]
    $Title
  )

  If ($PSCmdlet.ShouldProcess("Adding MonitorChartPart to Dashboards")) {
    $MonitorChart = [PSCustomObject][ordered]@{
      position = @{ }
      metadata = @{
        inputs = @(@{
            name  = 'options'
            value = @{
              chart = @{
                metrics          = @()
                title            = $Title
                visualization    = [PSCustomObject]@{ }
                openBladeOnClick = [PSCustomObject]@{ }
              }
            }
          })
        type   = 'Extension/HubsExtension/PartType/MonitorChartPart'  
      }    
    }

    $MonitorChart.PSTypeNames.Insert(0, 'DashboardPart')
    $MonitorChart.PSTypeNames.Insert(0, 'MonitoringChart')

    return $MonitorChart
  }  
}
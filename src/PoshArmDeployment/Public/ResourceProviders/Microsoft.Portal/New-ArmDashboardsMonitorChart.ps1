function New-ArmDashboardsMonitorChart {
  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType("DashboardPart")]
  Param(
    [string]
    [Parameter(Mandatory)]
    $Title
  )

  If ($PSCmdlet.ShouldProcess("Adding MonitorChartPart to Dashboards")) {
    $MonitorChart = [PSCustomObject][ordered]@{
      PSTypeName = "DashboardPart"
      position   = @{ }
      metadata   = @{
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
    $MonitorChart.PSTypeNames.Insert(0, 'MonitoringChart')
    return $MonitorChart
  }  
}
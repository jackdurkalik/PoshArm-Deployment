function Set-MonitoringChartVisualization {
  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType("MonitoringChart")]
  param(
    [PSTypeName("MonitoringChart")]
    [Parameter(Mandatory, ValueFromPipeline)]
    $Chart,
    [Parameter(Mandatory)]
    [int]
    $ChartType,
    [Parameter(Mandatory)]
    [int]
    $LegendPosition,
    [Parameter(Mandatory)]
    [int]
    $XAxisType,
    [Parameter(Mandatory)]
    [int]
    $YAxisType,
    [bool]
    $HideLegendSubtitle = $false,
    [bool]
    $XIsVisible = $true,
    [bool]
    $YIsVisible = $true,
    [bool]
    $LegendVisible = $true
  )
  Process {
    If ($PSCmdlet.ShouldProcess("Creating visualization for monitoring chart")) {
   
      $visualization = [PSCustomObject][ordered]@{ 
        PSTypeName          = "ChartVisualization"
        chartType           = $ChartType
        legendVisualization = @{ 
          isVisible    = $LegendVisible
          position     = $LegendPosition
          hideSubtitle = $HideLegendSubtitle 
        }
        axisVisualization   = @{ 
          x = @{ 
            isVisible = $XIsVisible
            axisType  = $XAxisType 
          }
          y = @{ 
            isVisible = $YIsVisible
            axisType  = $YAxisType
          } 
        } 
      }
      
      $Chart.metadata.inputs[0].value.chart.visualization = $visualization

      return $Chart
    }
  }
}
function Add-MonitoringChartMetrics {
  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType("MonitoringChart")]
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [PSTypeName("MonitoringChart")]
    $Chart,
    [Parameter(Mandatory)]
    [string]
    $Id,
    [Parameter(Mandatory)]
    [string]
    $Name,
    [Parameter(Mandatory)]
    [string]
    $DisplayName,
    [Parameter(Mandatory)]
    [string]
    $Namespace,
    [Parameter(Mandatory)]
    [int]
    $AggregationType,
    [string]
    $ResourceDisplayName = $null,
    [string]
    $Color = $null)
  Process {
    If ($PSCmdlet.ShouldProcess("Creating metrics for monitoring chart")) {
   
      $metric = [PSCustomObject][ordered]@{
        PSTypeName          = "ChartMetric"
        resourceMetadata    = @{ id = $Id }
        name                = $Name;
        aggregationType     = $AggregationType;
        namespace           = $Namespace;
        metricVisualization = [PSCustomObject][ordered]@{ 
          displayName = $DisplayName
        }
      }

      if ($ResourceDisplayName) {
        $metric.metricVisualization | Add-Member -MemberType NoteProperty -Name "resourceDisplayName" -Value $ResourceDisplayName 
      }

      if ($Color) {
        $metric.metricVisualization | Add-Member -MemberType NoteProperty -Name "color" -Value $Color 
      }

      $Chart.metadata.inputs[0].value.chart.metrics += $metric

      return $Chart
    }
  }
}
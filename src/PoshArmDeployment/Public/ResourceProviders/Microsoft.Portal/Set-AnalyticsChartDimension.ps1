function Set-AnalyticsChartDimension {
  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType("AnalyticsChart")]
  param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [PSTypeName("AnalyticsChart")]
    $Chart,
    [Parameter(Mandatory)]
    [string]
    $XName,
    [Parameter(Mandatory)]
    [string]
    $XType,
    [Parameter(Mandatory)]
    [string]
    $YName,
    [Parameter(Mandatory)]
    [string]
    $YType,
    [Parameter(Mandatory)]
    [string]
    $Aggregation)
  Process {
    If ($PSCmdlet.ShouldProcess("Creating dimension for analytics chart")) {
      $dimension = @{
        PSTypeName = "ChartDimension"
        name       = 'Dimensions'
        value      = @{           
          xAxis       = @{ 
            name = $XName
            type = $XType
          }
          yAxis       = @(
            @{
              name = $YName
              type = $YType
            })
          splitBy     = @(); 
          aggregation = $Aggregation
        }     
        
      }
      $Chart.metadata.inputs += $dimension

      return $Chart
    }
  }
}
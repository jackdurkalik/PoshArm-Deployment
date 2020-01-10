function Set-OpenApplicationInsightsBladeOnClick {
  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType("MonitoringChart")]
  param(
    [PSTypeName("MonitoringChart")]
    [Parameter(Mandatory, ValueFromPipeline)]
    $Chart,
    [Parameter(Mandatory)]
    [string]
    $ApplicationInsightsResourceId,
    [Parameter(Mandatory)]
    [string]
    $MenuId)
  Process {
    If ($PSCmdlet.ShouldProcess("Creating OpenBladeOnClick")) {
      $openBladeOnClick = [PSCustomObject]@{ 
        PSTypeName       = "OpenBladeOnClick"
        openBlade        = $true
        destinationBlade = @{ 
          extensionName = 'HubsExtension'
          bladeName     = 'ResourceMenuBlade'
          parameters    = @{ 
            id     = $ApplicationInsightsResourceId
            menuid = $MenuId
          }
        }
      }

      $Chart.metadata.inputs[0].value.chart.openBladeOnClick = $openBladeOnClick
      return $Chart
    }
  }
}
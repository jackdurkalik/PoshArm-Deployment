function New-ArmDashboardsCuratedBladePerformancePinned {
  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType("DashboardPart")]
  Param(
    [PSTypeName("ApplicationInsights")]
    [Parameter(Mandatory)]
    $ApplicationInsights
  )

  If ($PSCmdlet.ShouldProcess("Creating CuratedBladePerformancePinnedPart")) {
    $Now = Get-Date
    $ApplicationInsightsResourceId = $ApplicationInsights._ResourceId
    $CuratedBlade = [PSCustomObject][ordered]@{
      PSTypeName = "DashboardPart"
      position   = @{ }
      metadata   = @{
        inputs            = @( @{
            name  = 'ResourceId'
            value = $ApplicationInsightsResourceId
          }, 
          @{
            name       = 'DataModel'
            value      = @{
              version     = '1.0.0'
              timeContext = @{
                durationMs            = 86400000
                endTime               = $null
                createdTime           = $Now.ToUniversalTime().ToString('O')
                isInitialTime         = $false
                grain                 = 1
                useDashboardTimeRange = $false
              }
            }
            isOptional = $true
          })
        type              = 'Extension/AppInsightsExtension/PartType/CuratedBladePerformancePinnedPart'
        isAdapter         = $true
        asset             = @{
          idInputName = 'ResourceId'
          type        = 'ApplicationInsights'
        }      
        defaultMenuItemId = 'performance'
      }      
    }
    return $CuratedBlade
  }  
}
function Add-ArmDashboardsPartsElement {
  [CmdletBinding(SupportsShouldProcess = $true)]
  [OutputType("Dashboards")]
  Param(
    [PSTypeName("Dashboards")]
    [Parameter(Mandatory, ValueFromPipeline)]
    $Dashboards,
    [PSTypeName("DashboardPart")][object[]]
    [Parameter(Mandatory)]
    $Parts
  )
  If ($PSCmdlet.ShouldProcess("Adding DashboardParts to Dashboards")) {
    foreach ($part in $Parts) {
      $index = ($Dashboards.properties.lenses.'0'.parts | Get-Member -View Extended).count 
      $Dashboards.properties.lenses.'0'.parts | Add-Member -MemberType NoteProperty -Name $index.ToString() -Value $part
    }
    return $Dashboards
  }  
}
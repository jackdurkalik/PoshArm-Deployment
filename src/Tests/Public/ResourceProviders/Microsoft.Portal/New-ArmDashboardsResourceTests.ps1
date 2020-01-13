$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "New-ArmDashboardsResource" {
    $Depth = 99
    $ExpectedResourceName = New-ArmResourceName 'microsoft.portal/dashboards'
    $ExpectedApiVersion = "SomeApiVersion"
    $ExpectedLocation = "canadacentral"
    
    Context "Unit tests" {
      It "Given valid resource name it returns '<Expected>'" -TestCases @(
        @{  
          ApiVersion   = $ExpectedApiVersion
          Location     = $ExpectedLocation
          ResourceName = $ExpectedResourceName
          Expected     = [PSCustomObject][ordered]@{
            _ResourceId = $ExpectedResourceName | New-ArmFunctionResourceId -ResourceType 'microsoft.portal/dashboards'
            PSTypeName  = "Dashboards"
            type        = 'microsoft.portal/dashboards'
            name        = $ExpectedResourceName
            apiVersion  = $ApiVersion
            location    = $Location
            metadata    = @{ }
            properties  = [PSCustomObject]@{ 
              lenses = [PSCustomObject]@{
                0 = [PSCustomObject]@{ 
                  order = 0
                  parts = [PSCustomObject]@{ }
                }
              }
            }
            resources   = @()
            dependsOn   = @()
          }
        }
      ) {
        param(
          $ApiVersion,
          $Location,
          $ResourceName,
          $Expected
        )
        
        $actual = $ResourceName | New-ArmDashboardsResource -ApiVersion $ApiVersion -Location $Location

        ($actual | ConvertTo-Json -Compress -Depth $Depth | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -BeExactly ($Expected | ConvertTo-Json -Compress -Depth $Depth | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }

      Context "Integration tests" {
        It "Default" -Test {
          Invoke-IntegrationTest -ArmResourcesScriptBlock `
          {
            $ResourceName | New-ArmDashboardsResource -ApiVersion $ExpectedApiVersion -Location $ExpectedLocation `
            | Add-ArmResource
          }
        }
      }
    }
  }
}

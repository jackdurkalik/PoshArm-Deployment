$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "New-ArmDashboardsMonitorChart" {
    $Depth = 99
    $ExpectedTitle = "SomeTitle"

    Context "Unit tests" {
      It "Given <Title> it returns '<Expected>'" -TestCases @(
        @{  
          Title    = $ExpectedTitle
          Expected = [PSCustomObject][ordered]@{
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs = @(@{
                  name  = 'options'
                  value = @{
                    chart = @{
                      metrics          = @()
                      title            = $ExpectedTitle
                      visualization    = [PSCustomObject]@{ }
                      openBladeOnClick = [PSCustomObject]@{ }
                    }
                  }
                })
              type   = 'Extension/HubsExtension/PartType/MonitorChartPart'  
            }    
          }
        }
      ) {
        param(
          $Title,
          $Expected)               
        
        $actual = $Title | New-ArmDashboardsMonitorChart

        ($actual | ConvertTo-Json -Compress -Depth $Depth | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -BeExactly ($Expected | ConvertTo-Json -Compress -Depth $Depth | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }     
    }

    Context "Integration tests" {
      It "Default" -Test {
        Invoke-IntegrationTest -ArmResourcesScriptBlock `
        {
          $part = New-ArmDashboardsMonitorChart -Title $ExpectedTitle
              
          New-ArmResourceName "microsoft.portal/dashboards" `
          | New-ArmDashboardsResource -Location 'centralus' `
          | Add-ArmDashboardsPartsElement -Part $part `
          | Add-ArmResource
        }
      }
    }
  }
}

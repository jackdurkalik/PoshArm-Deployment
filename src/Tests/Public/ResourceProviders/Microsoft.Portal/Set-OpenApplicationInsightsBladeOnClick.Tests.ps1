$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
    Describe "Set-OpenApplicationInsightsBladeOnClick" {

        $ExpectedApplicationInsightsResourceId = 'xbox'
        $ExpectedMenuId = 'playstation'

        $MonitorChart = "AlwaysPipeline" | New-ArmDashboardsMonitorChart
    
        Context "Unit tests" {
            It "Given valid DashboardPart it returns '<Expected>'" -TestCases @(
                @{  
                    ApplicationInsightsResourceId = $ExpectedApplicationInsightsResourceId
                    MenuId                        = $ExpectedMenuId
                    Types                         = @('DashboardPart', 'MonitoringChart')
                    Expected                      = "AlwaysPipeline" | New-ArmDashboardsMonitorChart
                }
            ) {
                param(
                    $ApplicationInsightsResourceId,
                    $MenuId,
                    $Types,
                    $Expected
                )

                $Expected = "AlwaysPipeline" | New-ArmDashboardsMonitorChart
                $Expected.metadata.inputs[0].value.chart.openBladeOnClick = [PSCustomObject]@{ 
                    openBlade        = $true
                    destinationBlade = @{ 
                        extensionName = 'HubsExtension'
                        bladeName     = 'ResourceMenuBlade'
                        parameters    = @{
                            id     = $ExpectedApplicationInsightsResourceId
                            menuid = $ExpectedMenuId
                        }
                    }
                }

                $actual = $MonitorChart | Set-OpenApplicationInsightsBladeOnClick `
                    -ApplicationInsightsResourceId $ApplicationInsightsResourceId `
                    -MenuId $MenuId

                $Depth = 8

                ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
                | Should -BeExactly ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })

                $Types | ForEach-Object { $actual.PSTypeNames | Should -Contain $_ }
            }
        }

        Context "Integration tests" {
            It "Default" -Test {
                Invoke-IntegrationTest -ArmResourcesScriptBlock `
                {
                    $part = "AlwaysPipeline" | New-ArmDashboardsMonitorChart `
                    | Set-OpenApplicationInsightsBladeOnClick `
                        -ApplicationInsightsResourceId $ExpectedApplicationInsightsResourceId `
                        -MenuId $ExpectedMenuId

                    New-ArmResourceName "microsoft.portal/dashboards" `
                    | New-ArmDashboardsResource -Location 'centralus' `
                    | Add-ArmDashboardsPartsElement -Parts $part `
                    | Add-ArmResource
                }
            }
        }
    }
}

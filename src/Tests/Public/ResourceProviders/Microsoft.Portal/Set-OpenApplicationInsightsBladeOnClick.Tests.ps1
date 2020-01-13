$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
    Describe "Set-OpenApplicationInsightsBladeOnClick" {

        $Depth = 8
        $ExpectedApplicationInsightsResourceId = 'xbox'
        $ExpectedMenuId = 'playstation'
        $ExpectedMonitorChartName = "AlwaysPipeline"

        BeforeEach {
            $MonitorChart = $ExpectedMonitorChartName | New-ArmDashboardsMonitorChart
            $Expected = $MonitorChart.PSObject.Copy()
        }
    
        Context "Unit tests" {
            It "Given valid DashboardPart it returns '<Expected>'" -TestCases @(
                @{  
                    ApplicationInsightsResourceId           = $ExpectedApplicationInsightsResourceId
                    MenuId                                  = $ExpectedMenuId
                    ExpectedApplicationInsightsBladeOnClick = [PSCustomObject]@{ 
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
                }
            ) {
                param(
                    $ApplicationInsightsResourceId,
                    $MenuId,
                    $ExpectedApplicationInsightsBladeOnClick
                )
                
                $Expected.metadata.inputs[0].value.chart.openBladeOnClick = $ExpectedApplicationInsightsBladeOnClick

                $actual = $MonitorChart | Set-OpenApplicationInsightsBladeOnClick `
                    -ApplicationInsightsResourceId $ApplicationInsightsResourceId `
                    -MenuId $MenuId
                    
                ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
                | Should -BeExactly ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })

                @('DashboardPart', 'MonitoringChart') | ForEach-Object { $actual.PSTypeNames | Should -Contain $_ }
            }

            $ExpectedException = "MismatchedPSTypeName"

            It "Given a parameter of incorrect type, it throws '<Expected>'" -TestCases @(
                @{ 
                    Chart                         = "Chart"
                    ApplicationInsightsResourceId = $ExpectedApplicationInsightsResourceId
                    MenuId                        = $ExpectedMenuId
                    Expected                      = $ExpectedException
                }
                @{ 
                    Chart                         = [PSCustomObject]@{Name = "Value" }
                    ApplicationInsightsResourceId = $ExpectedApplicationInsightsResourceId
                    MenuId                        = $ExpectedMenuId
                    Expected                      = $ExpectedException
                }) { param(
                    $Chart,
                    $ApplicationInsightsResourceId,
                    $MenuId,
                    $Expected
                )
                
                { Set-OpenApplicationInsightsBladeOnClick -Chart $Chart `
                        -ApplicationInsightsResourceId $ApplicationInsightsResourceId `
                        -MenuId $MenuId
                } | Should -Throw -ErrorId $Expected
            }

            Context "Integration tests" {
                It "Default" -Test {
                    Invoke-IntegrationTest -ArmResourcesScriptBlock `
                    {
                        $part = $MonitorChart | Set-OpenApplicationInsightsBladeOnClick `
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
}
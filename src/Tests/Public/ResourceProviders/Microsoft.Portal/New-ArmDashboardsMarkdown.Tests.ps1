$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "New-ArmDashboardsMarkdown" {
    $Depth = 4

    $ExpectedContent = 'content'
    $ExpectedTitle = 'title'
    $ExpectedSubtitle = 'subtitle'

    Context "Unit tests" {
      It "Given a '<Content>', '<Title>', '<Subtitle>' it returns '<Expected>'" -TestCases @(
        @{ 
          Content  = $ExpectedContent    
          Title    = $ExpectedTitle  
          Subtitle = $ExpectedSubtitle
          Expected = [PSCustomObject][ordered]@{
            PSTypeName = "DashboardPart"
            position   = @{ }
            metadata   = @{
              inputs   = @()
              type     = 'Extension/HubsExtension/PartType/MarkdownPart'
              settings = @{
                content = @{
                  settings = @{
                    content  = $ExpectedContent
                    title    = $ExpectedTitle  
                    subtitle = $ExpectedSubtitle
                  }
                }      
              }
            }      
          }
        }
      ) {
        param($Content, $Title, $Subtitle, $Expected)

        $actual = New-ArmDashboardsMarkdown -Content $Content -Title $Title -Subtitle $Subtitle
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }   
    }

    Context "Integration tests" {
      It "Default" -Test {
        Invoke-IntegrationTest -ArmResourcesScriptBlock `
        {
          $part = New-ArmDashboardsMarkdown -Content $ExpectedContent -Title $ExpectedTitle -Subtitle $ExpectedSubtitle

          New-ArmResourceName "microsoft.portal/dashboards" `
          | New-ArmDashboardsResource -Location 'centralus' `
          | Add-ArmDashboardsPartsElement -Part $part `
          | Add-ArmResource
        }
      }
    }
  }
}
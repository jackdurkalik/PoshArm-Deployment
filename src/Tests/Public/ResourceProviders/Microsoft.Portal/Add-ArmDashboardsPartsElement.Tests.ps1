$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
Import-Module "$ScriptDir/../../../../PoshArmDeployment" -Force

InModuleScope PoshArmDeployment {
  Describe "Add-ArmDashboardsPartsElement" {
    $Depth = 9
    $ExpectedName = 'dashboard'
    $ExpectedMarkdown = [PSCustomObject][ordered]@{
      PSTypeName = "DashboardPart"
      position   = @{ }
      metadata   = @{
        inputs   = @()
        type     = 'Extension/HubsExtension/PartType/MarkdownPart'
        settings = @{
          content = @{
            settings = @{
              content  = ''
              title    = 'Test part'
              subtitle = ''
            }
          }      
        }
      }      
    }
    $ExpectedPinned = [PSCustomObject][ordered]@{
      PSTypeName = "DashboardPart"
      position   = @{ }
      metadata   = @{
        inputs            = @(@{
            name  = 'id'
            value = 'resource-id'
          }, @{
            name  = 'Version'
            value = '1.0'
          })
        type              = 'Extension/AppInsightsExtension/PartType/AspNetOverviewPinnedPart'
        asset             = @{
          idInputName = 'id'
          type        = 'ApplicationInsights'
        }
        defaultMenuItemId = 'overview'
      }      
    }
    $ExpectedDashboard = [PSCustomObject][ordered]@{
      _ResourceId = "[resourceId('Microsoft.Portal/dashboards','dashboard')]"
      PSTypeName  = "Dashboards"
      type        = 'microsoft.portal/dashboards'
      name        = $ExpectedName
      apiVersion  = '2015-08-01-preview'
      location    = ''
      metadata    = @{ }
      properties  = [PSCustomObject]@{ 
        lenses = [PSCustomObject]@{
          0 = [PSCustomObject]@{ 
            order = 0
            parts = [PSCustomObject]@{ 
              0 = $ExpectedMarkdown
              1 = $ExpectedPinned
            }
          }
        }
      }
      resources   = @()
      dependsOn   = @()
    }

    BeforeEach {            
      $Dashboard = $ExpectedName | New-ArmDashboardsResource
    }    

    Context "Unit tests" {
      It "Given a dashboard with no parts and '<Parts>', it returns '<Expected>' with all parts" -TestCases @(
        @{ 
          Parts    = @($ExpectedMarkdown, $ExpectedPinned)
          Expected = $ExpectedDashboard
        }
      ) { param($Parts, $Expected)

        $actual = $Dashboard | Add-ArmDashboardsPartsElement -Part $Parts
        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }
      It "Given a dashboard, adding multiple parts it returns '<Expected>' with all parts" -TestCases @(
        @{ 
          Part1    = $ExpectedMarkdown
          Part2    = $ExpectedPinned
          Expected = $ExpectedDashboard
        }
      ) { param($Part1, $Part2, $Expected)

        $actual = $Dashboard | Add-ArmDashboardsPartsElement -Part $Part1 `
        | Add-ArmDashboardsPartsElement -Part $Part2

        ($actual | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) }) `
        | Should -Be ($Expected | ConvertTo-Json -Depth $Depth -Compress | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) })
      }

      $ExpectedException = "MismatchedPSTypeName"

      It "Given a parameter of incorrect type, it throws '<Expected>'" -TestCases @(
        @{ 
          Dashboard = "Dashboard"
          Part      = $ExpectedPinned
          Expected  = $ExpectedException
        }
        @{ 
          Dashboard = [PSCustomObject]@{Name = "Value" }
          Part      = $ExpectedPinned
          Expected  = $ExpectedException
        }
        @{ 
          Dashboard = $ExpectedDashboard
          Part      = "Part"
          Expected  = $ExpectedException
        }
        @{ 
          Dashboard = $ExpectedDashboard
          Part      = [PSCustomObject]@{Name = "Value" }
          Expected  = $ExpectedException
        }) { param($Dashboard, $Part, $Expected)
        { Add-ArmDashboardsPartsElement -Dashboards $Dashboard -Parts $Part } | Should -Throw -ErrorId $Expected
      }
    }

    Context "Integration tests" {
      It "Default" -Test {
        Invoke-IntegrationTest -ArmResourcesScriptBlock `
        {
          $part = New-ArmDashboardsMarkdown -Content 'content' -Title 'title' -Subtitle 'subtitle'
          New-ArmResourceName "microsoft.portal/dashboards" `
          | New-ArmDashboardsResource -Location 'centralus' `
          | Add-ArmDashboardsPartsElement -Part $part `
          | Add-ArmResource
        }
      }
    }
  }  
}
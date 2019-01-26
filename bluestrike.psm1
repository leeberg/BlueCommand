function New-UDPreloader {
    [CmdletBinding(DefaultParameterSetName = "indeterminate")]
    param(
        [Parameter(ParameterSetName = "determinate")]
        [ValidateRange(0, 100)]
        $PercentComplete
        )
    
    New-UDElement -Tag "div" -Attributes @{
        className = "progress"
    } -Content {
        $Attributes = @{
            className = $PSCmdlet.ParameterSetName
        }

        if ($PSCmdlet.ParameterSetName -eq "determinate") {
            $Attributes["style"] = @{
                width = "$($PercentComplete)%"
            }
        }

        New-UDElement -Tag "div" -Attributes $Attributes
    }
}


function Start-BSDash {

    #### SETUP STUFF
    param($Port = 10000) 
        
    $Pages = @()
    $Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

    Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
        $Pages += . $_.FullName
    }

    Start-UDDashboard -Port $Port -Content {
        New-UDDashboard -Title "BlueStrike" -Pages $Pages <#@(
            $HomeUDPage, 
            
            $Global:NetworkDiscoveryUDPage, 
            $Global:NetworkOperationsUDPage, 
            
            $Global:EmpireOperationsUDPage,
            $Global:EmpireResultsUDPage,
            $Global:EmpireConfigurationUDPage,

            $Global:AboutUDPage
            ) #>
    }



}


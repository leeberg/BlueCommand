function Start-BSDash {
    param(
        $EmpireServer = ''
    )

    # Empire Server
    $Cache:EmpireServer = $EmpireServer

    $Pages = @()
    $Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

    Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
        $Pages += . $_.FullName
    }
    


    #### THEME    
    
    $DarkDefault = New-UDTheme -Name "Basic" -Definition @{
            UDDashboard = @{
                BackgroundColor = "#393F47"
                FontColor = "#FFFFFF"
            }
            UDNavBar = @{
                BackgroundColor =  "#272C33"
                FontColor = "#FFFFFF"
            }
            UDFooter = @{
                BackgroundColor =  "#272C33"
                FontColor = "#FFFFFF"
            }
            UDCard = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDChart = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDMonitor = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDTable = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDGrid = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDCounter = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
            UDInput = @{
                BackgroundColor = "#272C33"
                FontColor = "#FFFFFF"
            }
    }
    




    $BSEndpoints = New-UDEndpointInitialization -Module @("Modules\Empire\BlueStrikeData.psm1", "Modules\Empire\BlueStrikeEmpire.psm1")
    $Dashboard = New-UDDashboard -Title "BlueStrike" -Pages $Pages -EndpointInitialization $BSEndpoints -Theme $DarkDefault
    
    Try{
 
        Start-UDDashboard -Dashboard $Dashboard -Port 10000
      
    }
    Catch
    {
        Write-Error($_.Exception)
        Write-BSAuditLog -BSLogContent "BlueStrike Failed to Start!"
    }
    



}

function Start-BSAPI{

    ### Haven't messed around with this at all
    ### Next Step to replace module calls with API Calls?

    $Endpoints = @()

    $Endpoints += New-UDEndpoint -url 'GetEmpireModules' -Endpoint {
        Get-BSEmpireModuleData | ConvertTo-Json
        
    }

    Start-UDRestApi -Endpoint $Endpoints -Port 10001 -AutoReload




}
function Start-BSDash {
    
    Write-BSAuditLog -BSLogContent "Starting BlueStrike!"

    $Pages = @()
    $Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

    Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
        $Pages += . $_.FullName
    }
    
    $BSEndpoints = New-UDEndpointInitialization -Module @("PowerShellModules\Empire\BlueStrikeData.psm1", "PowerShellModules\Empire\BlueStrikeEmpire.psm1")

    $Dashboard = New-UDDashboard -Title "BlueStrike" -Pages $Pages -EndpointInitialization $BSEndpoints
    Try{
        Start-UDDashboard -Dashboard $Dashboard -Port 10000
        Write-BSAuditLog -BSLogContent "BlueStrike Started!"
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
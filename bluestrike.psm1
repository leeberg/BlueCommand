function Start-BSDash {
    
    Write-BSAuditLog -BSLogContent "Starting BlueStrike!"

    $Pages = @()
    $Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

    Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
        $Pages += . $_.FullName
    }
    
    $BSEndpoints = New-UDEndpointInitialization -Module @("Modules\Empire\BlueStrikeData.psm1", "Modules\Empire\BlueStrikeEmpire.psm1")

    $Dashboard = New-UDDashboard -Title "BlueStrike" -Pages $Pages -EndpointInitialization $BSEndpoints
    Try{
        Start-UDDashboard -Dashboard $Dashboard -Port 10000
        Write-BSAuditLog -BSLogContent "BlueStrike Started!"
    }
    Catch
    {
        Write-BSAuditLog -BSLogContent "BlueStrike Failed to Start!"
    }
    



}
Import-Module .\bluestrike.psd1 -Force
Import-Module .\PowerShellModules\Empire\BlueStrikeData.psm1 -Force
Import-Module .\PowerShellModules\Empire\BlueStrikeEmpire.psm1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BSDash
Start-BSAPI 
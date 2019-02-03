Import-Module .\bluestrike.psd1 -Force
Import-Module .\Modules\Empire\BlueStrikeData.psm1 -Force
Import-Module .\Modules\Empire\BlueStrikeEmpire.psm1 -Force

Get-UDDashboard | Stop-UDDashboard
Start-BSDash


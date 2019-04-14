# BlueStrike Start Script

# Set These Variables - and populate the Credential Object
$Credential = Get-Credential
$EmpireServerIP = '192.168.200.106'


Import-Module .\bluestrike.psd1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BSDash -EmpireServer $EmpireServer


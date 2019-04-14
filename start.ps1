# BlueStrike Start Script

# Set These Variables - and populate the Credential Object
$Credential = Get-Credential
$BlueStrikeFolder = 'C:\Users\lee\git\BlueStrike'
$EmpireServerIP = '192.168.200.106'


Import-Module .\bluestrike.psd1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BSDash -EmpireServer $EmpireServerIP -BlueStrikeFolder $BlueStrikeFolder


#192.168.200.106
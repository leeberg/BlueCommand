# BlueStrike Start Script

# Set These Variables - and populate the Credential Object
$BlueCommandFolder = 'C:\Users\lee\git\BlueStrike'
$EmpireServerIP = '192.168.200.106'
$WindowsCredentialName = 'empireserver'

Import-Module .\bluestrike.psd1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BSDash -EmpireServer $EmpireServerIP -BlueCommandFolder $BlueCommandFolder -BlueCommandPort 10001 -WinCred $WindowsCredentialName
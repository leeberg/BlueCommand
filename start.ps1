# BlueCommand Start Script

# Set These Variables - and populate the Credential Object
$BlueCommandFolder = 'C:\Users\lee\git\BlueCommand'
$EmpireServerIP = '192.168.200.106'
$WindowsCredentialName = 'empireserver'
$EmpireDirectory = '/home/lee/Empire'
$EmpirePort = '1337'


Import-Module .\BlueCommand.psd1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BSDash -EmpireServer $EmpireServerIP -EmpireDirectory $EmpireDirectory -EmpirePort $EmpirePort -BlueCommandFolder $BlueCommandFolder -BlueCommandPort 10001 -WindowsCredentialName $WindowsCredentialName
$cred = Get-Credential
$EmpireServer = 'empireserver01'
$EmpireDirectory = "/home/lee/Empire"
$LocalDownloadFolder = 'C:\Users\lee\Desktop\bluestriketesting'
$EmpireAgentName = "8BYZEAXN"

New-SSHSession -ComputerName $EmpireServer -Credential $cred -AcceptKey
Invoke-SSHCommand -Index 0 -Command 'ls'

Get-SCPFolder -LocalFolder $LocalDownloadFolder -RemoteFolder ($EmpireDirectory +'/downloads/'+$EmpireAgentName) -ComputerName $EmpireServer -Credential $cred
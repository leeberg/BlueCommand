
Param(
    #$Credential = (Get-Credential),
    $EmpireServer = 'empireserver01',
    $EmpireDirectory = "/home/lee/Empire",
    $EmpireAgentName = "8BYZEAXN",
    $DownloadFolder = "C:\Users\lee\Desktop\bluestriketesting\"
        
)


$username = "lee" 
$password = 'P@ssword' | ConvertTo-SecureString -AsPlainText -Force 
$Credential= New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $password


$LocalDownloadFolder = ($DownloadFolder + $EmpireAgentName)
$ExecutionResult = ""

Try{
    Get-SCPFolder -LocalFolder $LocalDownloadFolder -RemoteFolder ($EmpireDirectory +'/downloads/'+$EmpireAgentName) -ComputerName $EmpireServer -Credential $Credential -Force
    $ExecutionResult = "OK"
}
Catch
{
    $ExecutionResult = "FAIL"
}

return $ExecutionResult


